# INSTEAD OF Trigger

**Author:** <br>
Anika Neela<br>

**Project Description:**<br>
An INSTEAD OF trigger, called Delete_Suppliers_INSTEAD_OF that replaces DELETE operations on the Tb_Supplier table and provides the following functionality:<br>

a)	It supports single row or multi-row DELETE operations and it returns immediately if no rows are affected.<br>

b)	If the supplier to delete has no offers in the Tb_Offers table then it is deleted and the following message is displayed: <br>

*“Successfully deleted supplier Supplier_Name.”*<br>

c)	If the supplier has more than 5 offers then it does not delete the supplier row or any of her/his offers. Displays a message with the name of the supplier and the count of the offers she has that is formatted as follows:<br>

*“Cannot delete supplier Supplier_Name because she has Offers_Count offers.”*<br>

d)	If the supplier has up to 5 offers then deletes the supplier and its dependent offers in the Tb_Offers table.
Also displays the name of the supplier and the name of each product for which the offer has been removed. <br>
Formatted the messages as below:<br>

“Deleted supplier with name: Supplier_Name<br>
	Deleted offer for product with name: Product_Name1<br>
	Deleted offer for product with name: Product_Name2<br>
	Deleted offer for product with name: Product_Name3<br>
	Deleted offer for product with name: Product_Name4<br>
	Deleted offer for product with name: Product_Name5”<br>

e)	Created test queries for:
-	Single row DELETE operation. <br>
-	Multi row DELETE operation. <br>

**#Prerequisites:**<br>
-Language used: SQL<br>
-Software: MS SQL Server Management Studio<br>
-Version: 14.0.17289.0
