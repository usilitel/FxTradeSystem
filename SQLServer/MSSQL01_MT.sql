
SELECT *
FROM tPeriodsData
where idn = 5024869

SELECT *
FROM tcorrresults
where idn = 5024862

5024862


abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2)))
abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2))
abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2))



select cr.idn, pd.cdate, pd.ctime, p.cperiod, cr.ccorr,
  case when abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2)) > 720
    then 1440 - abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2))
    else abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2))
  end as deltaMinutes,
pd.ctime, c.ctime,
  case when abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - (left(c.ctime,2)*60)+right(c.ctime,2)) > 720
    then 1
    else 0
  end as deltaMinutes,
(left(pd.ctime,2)*60)+right(pd.ctime,2),
(left(c.ctime,2)*60)+right(c.ctime,2),
956	- 860
from tCorrResults cr
left outer join tPeriodsData pd on pd.idn = cr.idn
left outer join tPeriods p on p.idn_first <= cr.idn and p.idn_last >= cr.idn
--left outer join #tCCorrMax_CdateCperiod t on t.cdate = pd.cdate and t.cperiod = p.cperiod and t.ccorrMax = cr.ccorr
left outer join EURUSD5Curr c on c.idn = (select max(idn) from EURUSD5Curr)
where --t.ccorrMax is not null
  cr.idn=3838181
order by cr.ccorr desc




-- просмотр результирующей таблицы
select * 
from tCorrResultsReport
order by (case when deltaMinutes <= 120 then 0 else 1 end),
          ccorr desc










/*
-- импорт минуток (E:\forex\MSSQL\EURUSD1.csv) из Metatrader:
-- drop table EURUSD1
CREATE TABLE [dbo].[EURUSD1](
    idn int identity(1,1),
	[cdate] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[ctime] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[copen] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[chigh] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[clow] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[cclose] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL
	--[cvol] [nvarchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[EURUSD1] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
*/


-- E:\forex\MSSQL\importEURUSD1csv.dtsx
-- select * from EURUSD1
-- select count(*) from EURUSD1
-- select max(idn) from EURUSD1

----------

-- преобразуем импортированные данные из MT, добавляем IDN
/*
-- drop table tImportMTdata
CREATE TABLE [dbo].[tImportMTdata](
    idn int identity(1,1),
	[cdate] [varchar](10),
	[ctime] [varchar](5),
	[copen] [real],
	[chigh] [real],
	[clow] [real],
	[cclose] [real]
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[tImportMTdata] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

-- select * from tImportMTdata

insert into tImportMTdata(cdate, ctime, copen, chigh, clow, cclose)
  select cdate, ctime, convert(real,copen), convert(real,chigh), convert(real,clow), convert(real,cclose)
  from EURUSD1
  order by idn
*/

----------




-- select min(idn), max(idn) from tImportMTdata -- 1	2002490
-- select min(idn), max(idn) from tPeriodsData -- 1	7999910
-- select * from tPeriods

-- делаем разные временные периоды из минуток

/*
-- создаем таблицу c разными периодами
-- drop table tPeriodsData
CREATE TABLE tPeriodsData (  
	idn int identity(1,1),
	[cdate] [varchar](10),
	[ctime] [varchar](5),
	[copen] [real],
	[chigh] [real],
	[clow] [real],
	[cclose] [real],
    [idnMTdata] int,
	Volume [int],
	ABV [int],
	ABVMini [int],
	ABMmPosition0 [real],
	ABMmPosition1 [real],
	ABMmPosition0_M5 [real],
	ABMmPosition1_M5 [real]
) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[tPeriodsData] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
-- select * from tPeriodsData


-- создаем таблицу c данными о границах периодов
-- drop table tPeriods
CREATE TABLE tPeriods (  
  CPERIOD SMALLINT,
  idn_first int,
  idn_last int
) ON [PRIMARY]
-- select * from tPeriods
CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[tPeriods] 
(	idn_first ASC, idn_last ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
*/










-- select * from tImportMTdata
-- select * from tPeriodsData
-- select count(*) from tPeriodsData -- 7999910

/*
-- создаем процедуру для заполнения таблицы tPeriodsData данными
-- drop PROCEDURE pPeriodsData
alter PROCEDURE pPeriodsData (@pperiod int)
AS BEGIN 
-- процедура для заполнения таблицы tPeriodsData данными

SET NOCOUNT ON
DECLARE @idnfirst int, @idnlast int

select @idnfirst = isnull(max(idn),0)+1 from tPeriodsData;

 insert into tPeriodsData (CDATE, CTIME, CCLOSE, idnMTdata, copen, chigh, clow)
    select t1.CDATE, t1.CTIME, t1.CCLOSE, t1.idn, 
           t2.copen as copen,
           max(t3.chigh) as chigh,
           min(t3.clow) as clow
	from tImportMTdata t1
	left outer join tImportMTdata t2 on t2.idn=t1.idn-@pperiod+1 -- для расчета copen
	left outer join tImportMTdata t3 on t3.idn>(t1.idn-@pperiod) and t3.idn<=t1.idn -- для расчета chigh и clow
	where t1.idn/@pperiod = t1.idn*1.0/@pperiod
	group by t1.CDATE, t1.CTIME, t1.CCLOSE, t1.idn, t2.copen
	order by t1.idn

select @idnlast = max(idn) from tPeriodsData

insert into tPeriods (CPERIOD, idn_first, idn_last)
  select @pperiod as CPERIOD, @idnfirst, @idnlast

END
*/

/*

-- заполняем таблицу tPeriodsData данными
truncate table tPeriodsData;
truncate table tPeriods;

declare @i int
select @i=1 -- начальный период
WHILE @i<=30 -- конечный период  
begin
  exec pPeriodsData @i
  set @i = @i + 1
end
*/

-- select * from tPeriodsData order by IDN
-- select IDN, to_char(CDATETIME,'YYYYMMDD HH24MiSS') as CDATETIME, CCLOSE from tPeriodsData where idn >= 4171854 order by IDN
-- select * from tPeriods order by CPERIOD
-- select max(IDN)+1 from tPeriodsData
-- select max(CPERIOD) from tPeriodsData
-- select count(*) from tPeriodsData -- 7999910

-- таблицы tPeriodsData и tPeriods заполнены






-- заполняем поля tPeriodsData с показателями V

-- update pd
set pd.Volume = d.Volume, 
	pd.ABV = d.ABV, 
	pd.ABVMini = d.ABVMini, 
	pd.ABMmPosition0_M5 = d.ABMmPosition0,
	pd.ABMmPosition1_M5 = d.ABMmPosition1
-- select * --count(*)
from tPeriodsData pd
left outer join ntImportNTdata d on d.cdate = pd.cdate 
								and left(d.ctime,2) = left(pd.ctime,2)
								and right(d.ctime,2) = (
case when right(pd.ctime,2) in ('00','01','02','03','04') then '00'
	 when right(pd.ctime,2) in ('05','06','07','08','09') then '05'
	 when right(pd.ctime,2) in ('10','11','12','13','14') then '10'
	 when right(pd.ctime,2) in ('15','16','17','18','19') then '15'
	 when right(pd.ctime,2) in ('20','21','22','23','24') then '20'
	 when right(pd.ctime,2) in ('25','26','27','28','29') then '25'
	 when right(pd.ctime,2) in ('30','31','32','33','34') then '30'
	 when right(pd.ctime,2) in ('35','36','37','38','39') then '35'
	 when right(pd.ctime,2) in ('40','41','42','43','44') then '40'
	 when right(pd.ctime,2) in ('45','46','47','48','49') then '45'
	 when right(pd.ctime,2) in ('50','51','52','53','54') then '50'
	 when right(pd.ctime,2) in ('55','56','57','58','59') then '55'
else '' end
)

select * --count(*)
from ntImportNTdata
*/

----------
/*
-- делаем таблицу для хранения только cclose только по нужным периодам
CREATE TABLE [dbo].[tPeriodsDataCCLOSE](
	[idn] [int] NULL,
	[cclose] [real] NOT NULL
) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[tPeriodsDataCCLOSE] 
(	[idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


-- заполняем таблицу для хранения только cclose только по нужным периодам

-- truncate table tPeriodsDataCCLOSE

-- insert into tPeriodsDataCCLOSE (idn, cclose)
select pd.idn, pd.cclose
from tPeriods p
left outer join tPeriodsData pd on p.idn_first <= pd.idn and p.idn_last >= pd.idn
where p.cperiod >= 4  -- задать минимальный период
  and p.cperiod <= 6 -- задать максимальный период
order by pd.idn
*/
-- select count(*) from tPeriodsDataCCLOSE

-- после заполнения таблицы tPeriodsDataCCLOSE нужно импортироватье ее в Access с именем tPeriodsDataCCLOSE
-- сделать на нее в Access индекс и ключ по полю idn
----------
/*
-- таблица для текущих данных, заполняется из Access (нужна для вычисления времени последнего бара)
CREATE TABLE [dbo].[EURUSD5Curr](
    idn int identity(1,1),
	[cdate] [varchar](10),
	[ctime] [varchar](5),
	[copen] [real],
	[chigh] [real],
	[clow] [real],
	[cclose] [real]
) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[EURUSD5Curr] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

-- select * from [EURUSD5Curr]


-- таблица для хранения idn рассчитанных записей
-- drop TABLE [tCorrResultsReport]
CREATE TABLE [dbo].[tCorrResultsReport](
	[idn] int identity(1,1),
	[idnData] [int] NULL,
	[cdate] [varchar](10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[ctime] [varchar](5) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[deltaMinutes] [int] NULL,
	[cperiod] [int] NULL,
	[ccorr] [real] NULL,
	[cperiodsAll] [varchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL,
	[is_replaced] [int] NOT NULL,
	[deltaKmaxPercent] [real] NULL,
	[ccorrmax_replaced] [real] NULL,
	[cperiodMax_replaced] [int] NULL,
	[deltaMinutesMax_replaced] [int] NULL,
	[idnmax_replaced] [int] NULL
) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [idn0index] ON [dbo].[tCorrResultsReport] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from [tCorrResultsReport]
*/



/*
-- после расчета К:
-- резальтаты расчета К находятся в таблице tCorrResults
-- делаем процедуру поиска нужных значений

-- select * from tCorrResultsReport
-- exec pCorrResultsReport
-- delete from tCorrResultsReport
-- drop PROCEDURE pCorrResultsReport

alter PROCEDURE pCorrResultsReport
AS BEGIN 
-- процедура ищет информацию по записям, находящимся в таблице tCorrResults
-- и заполняет таблицу tCorrResultsReport

SET NOCOUNT ON

If object_ID('tempdb..#tCCorrMax_CdateCperiod') Is not Null drop table #tCCorrMax_CdateCperiod
If object_ID('tempdb..#tCCorrMax_Cdate') Is not Null drop table #tCCorrMax_Cdate
If object_ID('tempdb..#tCPeriodMax') Is not Null drop table #tCPeriodMax
If object_ID('tempdb..#tctimeAll') Is not Null drop table #tctimeAll
If object_ID('tempdb..#tCorrResultsReport') Is not Null drop table #tCorrResultsReport

truncate table tCorrResultsReport

-- максимальные значения К по дням и периодам
select pd.cdate, p.cperiod, max(cr.ccorr) as ccorrMax
into #tCCorrMax_CdateCperiod
from tCorrResults cr
left outer join tPeriodsData pd on pd.idn = cr.idn
left outer join tPeriods p on p.idn_first <= cr.idn and p.idn_last >= cr.idn
group by pd.cdate, p.cperiod

-- максимальные значения К по дням
select cdate, max(ccorrMax) as ccorrMax
into #tCCorrMax_Cdate
from #tCCorrMax_CdateCperiod
group by cdate

-- период с максимальной К, максимальная К за день
select d.cdate, d.ccorrMax, dp.cperiod as cperiodMax
into #tCPeriodMax
from #tCCorrMax_Cdate d
left outer join #tCCorrMax_CdateCperiod dp on dp.cdate = d.cdate and dp.ccorrMax = d.ccorrMax

-- время, разница по времени с текущими данными
select cr.idn, pd.cdate, pd.ctime, p.cperiod, cr.ccorr,
  case when abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2))) > 720
    then 1440 - abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2)))
    else abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2)))
  end as deltaMinutes
into #tctimeAll
from tCorrResults cr
left outer join tPeriodsData pd on pd.idn = cr.idn
left outer join tPeriods p on p.idn_first <= cr.idn and p.idn_last >= cr.idn
left outer join #tCCorrMax_CdateCperiod t on t.cdate = pd.cdate and t.cperiod = p.cperiod and t.ccorrMax = cr.ccorr
left outer join EURUSD5Curr c on c.idn = (select max(idn) from EURUSD5Curr)
where t.ccorrMax is not null
order by cr.ccorr desc



select 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		 then t5.idn
		 else tm.idn
	end 
as idnData,
m.cdate,
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		 then t5.ctime
		 else tm.ctime
	end 
as ctime,
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		 then t5.deltaMinutes
		 else tm.deltaMinutes
	end 
as deltaMinutes,
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		 then 5
		 else m.cperiodMax
	end 
as cperiod,
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		 then t5.ccorr
		 else m.ccorrmax
	end 
as ccorr,
	  case when t3.ccorr is null then '' else '3, ' end
	+ case when t4.ccorr is null then '' else '4, ' end
	+ case when t5.ccorr is null then '' else '5, ' end
	+ case when t6.ccorr is null then '' else '6, ' end
	+ case when t7.ccorr is null then '' else '7' end
as cperiodsAll,
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then 1
		 else 0
	end 
as is_replaced, 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then (m.ccorrmax - t5.ccorr)*100 
		 else 0
	end 
as deltaKmaxPercent, 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then m.ccorrmax
		 else 0
	end 
as ccorrmax_replaced, 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then m.cperiodMax
		 else 0
	end 
as cperiodMax_replaced, 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then tm.deltaMinutes
		 else 0
	end 
as deltaMinutesMax_replaced, 
	case when t5.ccorr is not null -- есть 5-минутки
		   and ((m.ccorrmax - t5.ccorr)*100)<3 -- (Кmax - К5) < 3%
		   and m.ccorrmax > t5.ccorr -- К5 < Кmax
		 then tm.idn
		 else 0
	end 
as idnmax_replaced
into #tCorrResultsReport
from #tCPeriodMax m -- период с максимальной К
left outer join #tctimeAll t3 on t3.cdate = m.cdate and t3.cperiod = 3
left outer join #tctimeAll t4 on t4.cdate = m.cdate and t4.cperiod = 4
left outer join #tctimeAll t5 on t5.cdate = m.cdate and t5.cperiod = 5
left outer join #tctimeAll t6 on t6.cdate = m.cdate and t6.cperiod = 6
left outer join #tctimeAll t7 on t7.cdate = m.cdate and t7.cperiod = 7
left outer join #tctimeAll tm on tm.cdate = m.cdate and tm.cperiod = m.cperiodMax -- период с максимальной К



insert into tCorrResultsReport (
	[idnData] ,
	[cdate] ,
	[ctime] ,
	[deltaMinutes] ,
	[cperiod] ,
	[ccorr] ,
	[cperiodsAll] ,
	[is_replaced] ,
	[deltaKmaxPercent] ,
	[ccorrmax_replaced] ,
	[cperiodMax_replaced] ,
	[deltaMinutesMax_replaced] ,
	[idnmax_replaced] 
)
select  
	[idnData] ,
	[cdate] ,
	[ctime] ,
	[deltaMinutes] ,
	[cperiod] ,
	[ccorr] ,
	[cperiodsAll] ,
	[is_replaced] ,
	[deltaKmaxPercent] ,
	[ccorrmax_replaced] ,
	[cperiodMax_replaced] ,
	[deltaMinutesMax_replaced] ,
	[idnmax_replaced] 
from #tCorrResultsReport
order by (case when deltaMinutes <= 120 then 0 else 1 end),
          ccorr desc


END

*/



-- select * from tCorrResultsReport
-- delete from tCorrResultsReport

/*
-- делаем таблицу для графиков
-- drop TABLE [dbo].[tCorrResultsPeriodsData]
CREATE TABLE [dbo].[tCorrResultsPeriodsData](
	[idn] [int] IDENTITY(1,1) NOT NULL,
	[idnData] [int] NOT NULL,
	[cdate] [varchar](10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[ctime] [varchar](5) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[cdatetime] [varchar](16) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[copen] [real] NULL,
	[chigh] [real] NULL,
	[clow] [real] NULL,
	[cclose] [real] NULL,
	[cperiodResult] [smallint] NULL,
	[cdateResult] [varchar](10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[ctimeResult] [varchar](5) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
	[deltaMinutesResult] [smallint] NULL,
	[ccorrResult] [real] NULL,
	[cperiodsAll] [varchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL,
	[is_replaced] [int] NOT NULL,
	[deltaKmaxPercent] [real] NULL,
	[ccorrmax_replaced] [real] NULL,
	[cperiodMax_replaced] [int] NULL,
	[deltaMinutesMax_replaced] [int] NULL,
	Volume [int],
	ABV [int],
	ABVMini [int],
	ABMmPosition0 [real],
	ABMmPosition1 [real]
) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[tCorrResultsPeriodsData] 
([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
*/


/*
-- создаем процедуру для заполнения таблицы tCorrResultsPeriodsData (графики) данными
-- drop PROCEDURE tCorrResultsPeriodsData

alter PROCEDURE pCorrResultsPeriodsData (@pCountCharts int, @pbarsBefore int, @pbarsTotal int)
AS BEGIN 
-- процедура для заполнения таблицы tCorrResultsPeriodsData данными
-- @pCountCharts - сколько графиков строить
-- @pbarsBefore  - сколько баров в графике брать до текущего
-- @pbarsTotal   - сколько баров в графике брать всего

SET NOCOUNT ON

DECLARE @idn int
DECLARE @Counter int

truncate table [tCorrResultsPeriodsData]
SET @Counter = 0

DECLARE cCorrResultsReport CURSOR FOR
SELECT idnData
FROM tCorrResultsReport r
order by (case when r.deltaMinutes <= 120 then 0 else 1 end),
          r.ccorr desc

OPEN cCorrResultsReport

FETCH NEXT FROM cCorrResultsReport 
INTO @idn
WHILE @@FETCH_STATUS = 0
BEGIN

	insert into [tCorrResultsPeriodsData](
		[idnData],
		[cdate], 
		[ctime], 
		[cdatetime],
		[copen], 
		[chigh], 
		[clow], 
		[cclose], 
		cperiodResult, 
		cdateResult, 
		ctimeResult, 
		deltaMinutesResult, 
		ccorrResult, 
		[cperiodsAll], 
		[is_replaced], 
		[deltaKmaxPercent], 
		[ccorrmax_replaced], 
		[cperiodMax_replaced], 
		[deltaMinutesMax_replaced],
		Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1)
	select 
		pd.idn,
		pd.cdate, 
		pd.ctime, 
		pd.cdate + ' ' + pd.ctime, 
		pd.copen, 
		pd.chigh, 
		pd.clow, 
		pd.cclose, 
		r.cperiod, 
		r.cdate, 
		r.ctime, 
		r.deltaMinutes, 
		r.ccorr, 
		r.cperiodsAll, 
		r.is_replaced, 
		r.deltaKmaxPercent, 
		r.ccorrmax_replaced, 
		r.cperiodMax_replaced, 
		r.deltaMinutesMax_replaced,
		pd.Volume, pd.ABV, pd.ABVMini, pd.ABMmPosition0_M5, pd.ABMmPosition1_M5
	from tCorrResultsReport r
	left outer join tPeriodsData pd on pd.idn >= (@idn-@pbarsBefore+1) 
								   and pd.idn <= (@idn+@pbarsTotal-@pbarsBefore)
	where r.idnData = @idn
	order by pd.idn

	SET @Counter = @Counter + 1
    IF @Counter = @pCountCharts GOTO exit_cursor

    FETCH NEXT FROM cCorrResultsReport 
    INTO @idn
END 

exit_cursor:
CLOSE cCorrResultsReport;
DEALLOCATE cCorrResultsReport;

-- ставим отсечки в начале дня
update t1
set t1.chigh = t1.copen*(1+2.0/1000),
    t1.clow = t1.copen*(1-2.0/1000)
from [tCorrResultsPeriodsData] t1
left outer join [tCorrResultsPeriodsData] t2 on t2.idnData = t1.idnData-1
where t1.ctime like '00:%' and t2.ctime not like '00:%'

-- ставим отсечки в нулевых барах
update t1
set t1.chigh = t1.copen*(1+2.0/1000),
    t1.clow = t1.copen*(1-2.0/1000)
from [tCorrResultsPeriodsData] t1
inner join tCorrResultsReport r on r.idnData = t1.idnData


END


*/


 select * from tPeriodsData where idn >= 4086233 and idn <= 4086263

 select * from ntImportNTdata where cdate = '2014.06.20'
 select * from ntEURUSD1 where cdate >= '20140615'

 select * from tPeriodsData where cdate = '2014.06.20'


left outer join ntImportNTdata d on d.cdate = pd.cdate 
								and left(d.ctime,2) = left(pd.ctime,2)
								and right(d.ctime,2) = (


-- select * from tCorrResultsReport order by idn
-- select * from tCorrResultsPeriodsData order by idn
-- delete from tCorrResultsPeriodsData
-- exec pCorrResultsPeriodsData 10,300,1000

-- select * from tCorrResultsReport




