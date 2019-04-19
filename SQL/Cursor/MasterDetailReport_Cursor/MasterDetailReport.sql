CREATE PROCEDURE MasterDetailReport AS
DECLARE @Supp_ID int
DECLARE @Name varchar(30)
DECLARE @SCity varchar(30)
DECLARE @City varchar(30)
DECLARE @Num varchar(30)
DECLARE @Total varchar(30)

DECLARE supplier SCROLL CURSOR FOR
              SELECT Supp_ID, Name, City FROM Tb_Supplier Order By City,Name
OPEN supplier

FETCH FROM supplier INTO @Supp_ID, @Name, @City 
PRINT 'Supplier city is : ' + @City;
PRINT 'Suppliers in city: ' ;
WHILE @@FETCH_STATUS = 0
BEGIN
         IF EXISTS(Select * From Tb_Supplier)
         BEGIN
              Set @SCity = @City;
                     PRINT '                                                ' + @Name;
       END
      FETCH FROM supplier INTO @Supp_ID,@Name,@City 
         IF Not @SCity = @City
              BEGIN
					SET @Num = (Select Count(Name) From Tb_Supplier Where @SCity = City)
					PRINT 'Number of suppliers in ' +  @SCity + ' is: ' + @Num;
                     PRINT 'Supplier city is : ' + @City;
                     PRINT 'Suppliers in city: ';
              END
		SET @Total = (Select Count(Name) From Tb_Supplier) 
END
SET @Num = (Select Count(Name) From Tb_Supplier Where @SCity = City)
PRINT 'Number of suppliers in ' +  @SCity + ' is: ' + @Num;
PRINT 'Total number of suppliers is: ' + @Total;
CLOSE supplier
DEALLOCATE supplier
GO

Exec MasterDetailReport
