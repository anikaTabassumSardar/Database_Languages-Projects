IF EXISTS (SELECT name FROM sysobjects
WHERE name = 'Delete_Suppliers_INSTEAD' AND type = 'TR')
DROP TRIGGER Delete_Suppliers_INSTEAD
GO

CREATE TRIGGER Delete_Suppliers_INSTEAD
ON Tb_Supplier
INSTEAD OF DELETE AS
IF(@@ROWCOUNT = 0) RETURN --If no rows are there, return

DECLARE @suppName varchar(30)
DECLARE @offersCount int
DECLARE @suppId int
DECLARE @prodName varchar(30)
DECLARE @prodID int

IF NOT EXISTS(Select * from Tb_offers o, deleted d WHERE o.Supp_ID = d.Supp_ID) --if no offers for this supplier, delete
	BEGIN
		SELECT @suppName = Name, @suppId =Supp_ID from deleted
		DELETE Tb_Supplier WHERE Supp_ID = @suppId
		PRINT('Successfully deleted supplier ' + @suppName + '.');
	END

IF EXISTS(Select o.Supp_ID FROM Tb_Offers o, deleted d, Tb_Supplier s WHERE s.Supp_ID = d.Supp_ID AND o.Supp_ID=d.Supp_ID GROUP BY o.Supp_ID HAVING COUNT(o.Supp_ID)>5) --supplier has more than 5 offers
	BEGIN
		SELECT @suppName = Name from deleted

		SELECT @offersCount = COUNT(o.Supp_ID)
		FROM Tb_Offers o, Tb_Supplier s, deleted d
		WHERE o.Supp_ID = s.Supp_ID AND d.Supp_ID = s.Supp_ID

		PRINT 'Cannot delete supplier ' + @suppName + ' because he/she has ' + convert(varchar(30),@offersCount) + ' offers.' ;
	END
IF EXISTS(Select o.Supp_ID FROM Tb_Offers o, deleted d, Tb_Supplier s WHERE s.Supp_ID = d.Supp_ID AND o.Supp_ID=d.Supp_ID GROUP BY o.Supp_ID HAVING COUNT(o.Supp_ID) BETWEEN 1 AND 5) 
	BEGIN
		DECLARE supplier_cursor CURSOR FOR Select Name, Supp_ID from deleted
			OPEN supplier_cursor
			FETCH FROM supplier_cursor INTO @suppName, @suppId
			WHILE (@@FETCH_STATUS=0)
			BEGIN
				PRINT 'Deleted supplier with name: ' + @suppName;
				
					DECLARE product_cursor CURSOR FOR SELECT p.Name, p.Prod_ID FROM Tb_Product p, Tb_Offers o, Tb_Supplier s, deleted d WHERE p.Prod_ID = o.Prod_ID AND d.Supp_ID = o.Supp_ID AND s.Supp_ID = d.Supp_ID
						OPEN product_cursor
						FETCH NEXT FROM product_cursor INTO @prodName,@prodID
						WHILE (@@FETCH_STATUS=0)
							BEGIN
								DELETE Tb_Offers WHERE Prod_ID = @prodID AND Supp_ID = @suppId
								PRINT 'Deleted offer for product with name: ' + @prodName
								FETCH NEXT FROM product_cursor INTO @prodName,@prodID
							END
						DELETE Tb_Supplier WHERE Name = @suppName
						FETCH NEXT FROM supplier_cursor INTO @suppName,@suppId
						CLOSE product_cursor
						DEALLOCATE product_cursor
			END
				CLOSE supplier_cursor
				DEALLOCATE supplier_cursor
				
	END
GO

/*
--The Test Queries

--This creates a supplier with no offers and then deletes it
INSERT INTO Tb_Supplier VALUES('NoOffersSupp', 'x','y')
DELETE Tb_Supplier WHERE Name = 'NoOffersSupp'


--supplier with more than 5 offers
DELETE Tb_Supplier Where Name = 'Supp_with_Six_Offers' AND Supp_ID = 303


--supplier with equal or less than 5 offers
INSERT INTO Tb_Supplier VALUES('SuppsDeletable', 'a','y')
INSERT INTO Tb_Offers VALUES((Select Supp_ID From Tb_Supplier WHERE Name='SuppsDeletable'),7,'30', 4), ((Select Supp_ID From Tb_Supplier WHERE Name='SuppsDeletable'),2,'30', 4),((Select Supp_ID From Tb_Supplier WHERE Name='SuppsDeletable'),3,'30', 4)
DELETE Tb_Supplier Where Name = 'Supps'

DELETE Tb_Supplier Where City = 'Stevens Point'

*/
