select sum(sellCnt), sum(buyCnt), sum(sellCnt) - sum(buyCnt) from QuickOrders
select * from QuickOrders order by price desc
