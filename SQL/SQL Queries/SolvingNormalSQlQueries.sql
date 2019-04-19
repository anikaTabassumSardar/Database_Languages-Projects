-Q1: List of consumer names and number of requests for each (0 if no requests)

print 'Q1:';
print '';

Select SC.cn as 'Name', ISNULL(SC.cprod,0) as "Number of Requests"
From (Select c.Name cn, count(prod_ID) cprod
	From Tb_Consumer c left join tb_Requests r
	on c.con_ID= r.con_ID
Group by c.name) SC;
 
--Q2: List of consumer names from Wausau and number of computer requests for each (0 if no
--requests)
print 'Q2:';
print '';

Select c.Name, count(r.prod_ID) as 'Number of Requests'
From Tb_Consumer c left join (Tb_Product p Inner Join Tb_Requests r on p.prod_ID=r.prod_ID AND p.name='Computer') on c.con_ID = r.con_ID
Where c.city='Wausau'  
Group by c.name;



--Q3: List of supplier names from Wausau and number of offers for each (0 if no offers)

Select s.Name , count(prod_ID) 'Number of Offers'
From Tb_Supplier s left join tb_Offers o
	on s.supp_ID=o.supp_ID
Where s.city = 'Wausau'
Group by s.name;

--Q4: List of product names and average value of offers for that product (0 if no offers)


Select PA.pn as 'Name', ISNULL(PA.oa,0) as "Average Offer Value" 
From (Select p.name pn, AVG (o.quantity*o.price) oa
From tb_Product p left join Tb_Offers o 
	on p.prod_ID= o.prod_ID 
Group by p.name) PA;


--Q5: List of product names and number of offers and requests for each product (0 if no offers or no
--requests)
print 'Q5:';
print '';

Select P.Name, isnull(count(Distinct O.Supp_ID), 0) as "Number of Offers" ,
		isnull(count( Distinct R.Con_id),0) as "Number of Requests"
From Tb_Product P left Join TB_Offers O  on P.prod_id= O.Prod_ID 
	 left join  tb_requests R on  P.Prod_id = R.Prod_ID
Group by P.Name;


--Q6: List of product names and average value of offers, requests and transactions (0 if none)

print 'Q6:';
print '';

Select P.Name, count( Distinct O.Supp_ID) as "Number of Offers", 
	   isnull(avg(O.quantity * O.price),0) as " Average Offer Value",
	   count ( Distinct R.Con_ID) as "Number of Requests" , 
	   isnull(avg(R.quantity * R.price),0) as "Average Request Value", 
	   count (Distinct T.Tran_ID) as "Number of transactions", 
	   isnull(avg(T.quantity * T.price),0) as "Average Transaction Value"
From Tb_product P left join tb_offers O on P.prod_id= O.prod_id 
     left join tb_requests R on P.prod_id=R.prod_id left join tb_transactions T
on P.prod_id= T.prod_id
Group by P.Name;



--Q7: List of Consumer-Product pairs and quantity of product requested by consumer(0 if none)
print 'Q7:';
print '';

Select Distinct C.Name, P.Name as "Product", Isnull(R.Quantity,0) as "Requested Quantity"
From tb_requests R right join (Tb_Consumer C cross join Tb_Product P)
on R.Prod_ID = P.Prod_ID
and R.Con_ID = C.Con_ID;


--Q8: List of pairs of Supplier-Consumer cities and number of Supplier-Consumers pairs, with supplier
--in the first city and consumer in the second city, having at least one transaction between them (0
--if no transactions between the two cities)

print 'Q8:';
print '';
Select sc.scity as [Supplier City] , sc.ccity as [Consumer City] ,
		 count(sc.tsid) [Number of Supplier-Consumer Pairs]
From	(Select s.city scity, c.city ccity, t.supp_ID tsid, t.con_ID
		From(Tb_Supplier s Cross Join Tb_consumer c)left join tb_transactions t 
		on s.supp_ID=t.supp_ID AND c.con_ID=t.con_ID
Group by s.city, c.city, t.supp_ID, t.con_ID) SC 
Group by sc.scity, sc.ccity
Order by sc.scity, sc.ccity;
