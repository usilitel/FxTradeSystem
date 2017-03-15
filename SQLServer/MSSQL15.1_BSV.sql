
-- работаем с BSV, BSP

-- разархивировать тиковую историю
-- запустить индикатор TestReadBinFile (задать директорию с тиковой историей). На выходе получатся файлы с тиковыми данными с шагом в 5 минут.
-- состыковать все текстовые файлы
-- импортировать таблицу с тиковыми данными на SQL Server (t_6E2_v2)

-- данные с ценами: сделать в NT7 тестовый файл с ценами и ABV по нужной валюте за нужный период), импортировать его в ntEURUSD1 и т.д. до заполнения таблицы ntTradeDays включительно




-- select * from t_6E2 order by cprice desc

-- удаляем ошибочные данные (со слишком большой ценой)
select * 
-- delete
from t_6E2_v2
--where cprice >= 211400
order by cprice desc

-- исправляем цену
select *, cprice * 0.0001
-- update t_6E2_v2 set cprice = cprice * 0.0001
from t_6E2_v2
where cprice < 20000

select *, cprice * 0.00001
-- update t_6E2_v2 set cprice = cprice * 0.00001
from t_6E2_v2
where cprice > 20000

-----------------




-- приводим время к виду yyyy.mm.dd hh:mm

If object_ID('tempdb..#t1') Is not Null drop table #t1
If object_ID('tempdb..#t2') Is not Null drop table #t2
If object_ID('tempdb..#t3') Is not Null drop table #t3
If object_ID('tempdb..#t4') Is not Null drop table #t4
If object_ID('tempdb..#t5') Is not Null drop table #t5
If object_ID('tempdb..#t6') Is not Null drop table #t6
If object_ID('tempdb..#ntPeriodsData') Is not Null drop table #ntPeriodsData
If object_ID('tempdb..#ntPeriodsData2') Is not Null drop table #ntPeriodsData2

select case when len(cTime) = 18 
		then (substring(cTime,7,4) + '.' + substring(cTime,4,2) + '.' + substring(cTime,1,2) + ' 0' + substring(cTime,12,4))
		else (substring(cTime,7,4) + '.' + substring(cTime,4,2) + '.' + substring(cTime,1,2) + ' ' + substring(cTime,12,5)) 
		end as cTime2,
		*
into #t1
from t_6E2_v2
--order by len(cTime) desc


-- исправляем минуты
select case when right(cTime2,1) in ('0','1','2','3','4')
			then (left(cTime2,15) + '0')
			when right(cTime2,1) in ('5','6','7','8','9')
			then (left(cTime2,15) + '5')
		else ''
		end as cTime3,
*
into #t2
from #t1
--where right(cTime2,1) not in ('0','5')

-- проверяем количество записей с одинаковым временем (в идеале д.б. count(*) <=2)
select cTime3, count(*) 
from #t2
group by cTime3
having count(*)>1
order by cTime3 desc

select *
from #t2
where cTime3 = '2016.06.10 15:20'

-- If object_ID('tempdb..#t3') Is not Null drop table #t3

-- группируем записи с одним cdatetime
select  cTime3 as cdatetime, left(cTime3,10) as cdate, substring(cTime3,12,5) as ctime,
		min(cprice) as cprice, sum(cBSV) as cBSV, sum(cBSPValue) as cBSP,
		convert(real,0) as sumBSV,
		convert(real,0) as sumBSP
into #t3
from #t2
group by cTime3
order by cTime3

select *
from #t3
order by cdatetime




-----------------------------------------

-- считаем сумму по BSV и BSP

CREATE INDEX [index1] ON #t3 
(cdatetime) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


update #t3 set sumBSV = 0, sumBSP = 0
		

	declare @cdatetime varchar(50)
	declare @cBSV real, @sumBSV real
	declare @cBSP real, @sumBSP real
	select @cBSV = 0, @sumBSV = 0
	select @cBSP = 0, @sumBSP = 0
	
	-- делаем курсор по нужным idn
	DECLARE c1 CURSOR FOR
	SELECT cdatetime, cBSV, cBSP
	FROM #t3 WITH(NOLOCK)
	order by cdatetime

	OPEN c1

	FETCH NEXT FROM c1 
	INTO @cdatetime, @cBSV, @cBSP
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @sumBSV = @sumBSV + @cBSV 
		select @sumBSP = @sumBSP + @cBSP
		
		update #t3
		set sumBSV = @sumBSV, sumBSP = @sumBSP
		where cdatetime = @cdatetime

		FETCH NEXT FROM c1 
		INTO @cdatetime, @cBSV, @cBSP
	END 

	CLOSE c1;
	DEALLOCATE c1;
	
select *
from #t3
order by cdatetime

-----------------------------------------


-- определяем московское время
-- If object_ID('tempdb..#t4') Is not Null drop table #t4

select	*,
		convert(datetime,replace(cdatetime,'.','-'),120) as cdatetime_dt, 
		--dateadd(mi,60*8+5,convert(datetime,replace(cdatetime,'.','-'),120)) as cdatetime_moscow_dt,
		--replace(convert(varchar(16),dateadd(mi,60*8+5,convert(datetime,replace(cdatetime,'.','-'),120)),120),'-','.') as cdatetime_moscow_txt 
		convert(datetime,null) as cdatetime_moscow_dt, 
		convert(varchar(16),null) as cdatetime_moscow_txt
into #t4
from #t3
order by cdatetime

select	* from #t4 order by cdatetime_dt


CREATE INDEX [index1] ON #t4 
(cdatetime_dt) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

------------------------

-- вычисляем пробелы в тиковых данных (перерывы в работе биржи)
-- If object_ID('tempdb..#t5') Is not Null drop table #t5
select	*, 
		(select min(cdatetime_dt) from #t4 where cdatetime_dt > d.cdatetime_dt) as cdatetime_next_dt, -- следующая запись
		0 as deltaMinutes,
		0 as deltaMinutes_moscow
into #t5
from #t4 d
order by d.cdatetime_dt

CREATE INDEX [index1] ON #t5
(cdatetime_dt) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


update #t5
set deltaMinutes = datediff(mi,cdatetime_dt,isnull(cdatetime_next_dt,cdatetime_dt))

select	* from #t5 order by deltaMinutes


------------------------
-- вычисляем пробелы в данных из NT (перерывы в работе биржи)
-- If object_ID('tempdb..#ntPeriodsData') Is not Null drop table #ntPeriodsData

select	*, 
		convert(datetime,replace((d.cdate + ' ' + d.ctime),'.','-'),120) as cdatetime_dt		
into #ntPeriodsData
from ntPeriodsData d
where d.CurrencyId = 42
order by d.cdate, d.ctime

CREATE INDEX [index1] ON #ntPeriodsData 
(cdatetime_dt) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


-- If object_ID('tempdb..#ntPeriodsData2') Is not Null drop table #ntPeriodsData2

select	*, 
		(select min(cdatetime_dt) from #ntPeriodsData where cdatetime_dt > d.cdatetime_dt) as cdatetime_next_dt, -- следующая запись
		0 as deltaMinutes
into #ntPeriodsData2
from #ntPeriodsData d
order by d.cdatetime_dt

update #ntPeriodsData2
set deltaMinutes = datediff(mi,cdatetime_dt,isnull(cdatetime_next_dt,cdatetime_dt))

select	*
from #ntPeriodsData2
order by deltaMinutes
------------------------

-- update #t5 set deltaMinutes_moscow = 0


-- определяем разницу между временем тиковых данных и московским временем
update t set deltaMinutes_moscow = datediff(mi,t.cdatetime_dt,d.cdatetime_dt)
-- select	*,	datediff(mi,t.cdatetime_dt,d.cdatetime_dt)
from #t5 t
left outer join #ntPeriodsData2 d on
	d.cdatetime_dt = (select min(cdatetime_dt) from #ntPeriodsData2 where deltaMinutes = 65 and cdatetime_dt > t.cdatetime_dt)
where t.deltaMinutes = 65 -- перерыв между будними днями
	and datediff(mi,t.cdatetime_dt,d.cdatetime_dt) in (480,485,540,545,605) -- берем только "хорошие" записи
--order by datediff(mi,t.cdatetime_dt,d.cdatetime_dt)

update t set deltaMinutes_moscow = datediff(mi,t.cdatetime_dt,d.cdatetime_dt)
-- select	*,	datediff(mi,t.cdatetime_dt,d.cdatetime_dt)
from #t5 t
left outer join #ntPeriodsData2 d on
	d.cdatetime_dt = (select min(cdatetime_dt) from #ntPeriodsData2 where deltaMinutes in (2945,2950) and cdatetime_dt > t.cdatetime_dt)
where t.deltaMinutes in (2945,2950) -- перерыв на выходные дни
	and datediff(mi,t.cdatetime_dt,d.cdatetime_dt) in (480,485,540,545,605) -- берем только "хорошие" записи
--order by datediff(mi,t.cdatetime_dt,d.cdatetime_dt)


update #t5 set deltaMinutes_moscow = 480 where deltaMinutes_moscow = 485
update #t5 set deltaMinutes_moscow = 540 where deltaMinutes_moscow = 545
update #t5 set deltaMinutes_moscow = 600 where deltaMinutes_moscow = 605

select * from #t5
----------------------

-- проставляем московское время

-- ищем ближайший "чистый" переход
-- If object_ID('tempdb..#t6') Is not Null drop table #t6
select	t1.cdatetime, t1.cdate, t1.ctime, t1.cprice, t1.cBSV, t1.cBSP, t1.sumBSV, t1.sumBSP, t1.cdatetime_dt, t1.cdatetime_moscow_dt, t1.cdatetime_moscow_txt, t1.cdatetime_next_dt, t1.deltaMinutes, t1.deltaMinutes_moscow, 
		t2.deltaMinutes_moscow as deltaMinutes_moscow_all
into #t6
from #t5 t1
left outer join #t5 t2 on t2.cdatetime_dt = (select min(cdatetime_dt) from #t5 where cdatetime_dt >= t1.cdatetime_dt and deltaMinutes_moscow > 0) -- ближайший "чистый" переход
order by t1.cdatetime_dt

update #t6
set cdatetime_moscow_dt = dateadd(mi,deltaMinutes_moscow_all,cdatetime_dt)

update #t6
set cdatetime_moscow_txt = replace(convert(varchar(16),cdatetime_moscow_dt,120),'-','.')

select *
from #t6
order by cdatetime_dt

-- теперь #t6.cdatetime_moscow_txt = #ntPeriodsData2.cdate + ' ' + #ntPeriodsData2.ctime
-- теперь #t6.cdatetime_moscow_dt = #ntPeriodsData2.cdatetime_dt
---------------------------------------------

-- проверяем синхронность данных (первые 3 столбца вставляем в Excel)
select	d.cdatetime_dt, d.cclose, t.cprice, *
from #ntPeriodsData2 d
left outer join #t6 t on t.cdatetime_moscow_dt = d.cdatetime_dt
order by d.cdatetime_dt


---------------------------------------------

-- заполняем пробелы

-- сначала вычисляем лишние данные (даты, по которым нет тиковых данных)
select	d.cdatetime_dt, d.cclose, t.cprice, *
from #ntPeriodsData2 d
left outer join #t6 t on t.cdatetime_moscow_dt = d.cdatetime_dt
--where   d.cdate >= '2012.12.10'
--	and d.cdate <= '2016.07.27'
order by d.cdatetime_dt

-- удаляем из исходной таблицы лишние данные (за даты, по которым нет тиковых данных)
select *
-- delete
from ntPeriodsData
where CurrencyId = 42
	and (idn <= 15090091 or idn >= 15342527)
order by cdate, ctime

-- удаляем из временной таблицы лишние данные (за даты, по которым нет тиковых данных)
select *
-- delete
from #ntPeriodsData2
where CurrencyId = 42
	and (idn <= 15090091 or idn >= 15342527)
order by cdate, ctime

-- проверяем чтобы не было лишних данных (за начало и конец д.б.тиковые данные)
select	d.cdatetime_dt, d.cclose, t.cprice, *
from #ntPeriodsData2 d
left outer join #t6 t on t.cdatetime_moscow_dt = d.cdatetime_dt
order by d.cdatetime_dt




CREATE INDEX [index1] ON #t6 
(cdatetime_moscow_dt) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE INDEX [index1] ON #ntPeriodsData2 
(cdatetime_dt) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

-- заполняем пробелы
select	*
-- update d set d.BSV = t.sumBSV, d.BSP = t.sumBSP
from #ntPeriodsData2 d
left outer join #t6 t on t.cdatetime_moscow_dt = (select max(cdatetime_moscow_dt) from #t6 where cdatetime_moscow_dt <= d.cdatetime_dt)
order by d.cdatetime_dt

select	*
from #ntPeriodsData2
order by cdatetime_dt

-- переносим данные в постоянную таблицу
select	*
-- update d set d.BSV = t.BSV, d.BSP = t.BSP
from ntPeriodsData d
left outer join #ntPeriodsData2 t on t.cdate = d.cdate and t.ctime = d.ctime
where d.CurrencyId = 42
order by d.cdate, d.ctime

-- проверяем (сверяем BSV с NT через Excel)
select	*
from ntPeriodsData d
where d.CurrencyId = 42
	and d.cdate = '2016.02.02'
order by d.cdate, d.ctime


-- теперь поля ntPeriodsData.BSV и ntPeriodsData.BSP заполнены из тиковых данных

------------------------------------
------------------------------------

select	cclose, BSV, *
from ntPeriodsData d
where d.CurrencyId = 42
	and d.ctime like '%:00'
order by d.cdate, d.ctime



-- перекидываем BSV, BSVMini из currencyid











