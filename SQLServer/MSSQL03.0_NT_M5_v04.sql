
select *
from ntImportNTdata_6C_old
where cdate >= '2013.12.01' and cdate <= '2014.03.01'
order by cdate

select *
from ntImportNTdata
where CurrencyId = 5 and DataSourceId = 2 and PeriodMinutes = 5
  and cdate >= '2013.12.01' and cdate <= '2014.03.01'
order by cdate

into ntImportNTdata_6C_old

select *, CONVERT(datetime, cdate, 21)
from ntImportNTdata_6C_old
order by cdate

select distinct cdate
into #t1
from ntImportNTdata_6C_old
where CurrencyId = 5 and DataSourceId = 2 and PeriodMinutes = 5

select *, datediff(dd,CONVERT(datetime, t1.cdate, 21),CONVERT(datetime, t2.cdate, 21))
from #t1 t1
left outer join #t1 t2 on t2.cdate = (select min(cdate) from #t1 where cdate > t1.cdate)
order by datediff(dd,CONVERT(datetime, t1.cdate, 21),CONVERT(datetime, t2.cdate, 21))

select distinct cdate
into #t2
from ntImportNTdata
where CurrencyId = 5 and DataSourceId = 2 and PeriodMinutes = 5

select *, datediff(dd,CONVERT(datetime, t1.cdate, 21),CONVERT(datetime, t2.cdate, 21))
from #t2 t1
left outer join #t2 t2 on t2.cdate = (select min(cdate) from #t2 where cdate > t1.cdate)
order by datediff(dd,CONVERT(datetime, t1.cdate, 21),CONVERT(datetime, t2.cdate, 21))


select distinct cdate
from ntImportNTdata
where CurrencyId = 5 and DataSourceId = 2 and PeriodMinutes = 5


------------

	
	
	
select * from ntImportCurrentChartAverageValues

select idn into #ntCorrResultsReport from ntImportCurrentChartAverageValues where ParamsIdentifyer = '1400_40_1_1_2_5_1_1_0_0' order by idn
select * from #ntCorrResultsReport

alter table #ntCorrResultsReport add idn_temp int identity(1,1)

If object_ID('tempdb..#ntCorrResultsReport') Is not Null drop table #ntCorrResultsReport



CREATE TABLE #t1(
    idn int identity(1,1),
	idn1 int
) 
insert into #t1 (idn1) select idn from ntImportCurrentChartAverageValues where ParamsIdentifyer = '1400_40_1_1_2_5_1_1_0_0' order by idn

select * from ntAverageValuesResults order by idn

insert into #t1 (ctext) select 'test2'
select idn1-idn, * from #t1 where (idn1-idn) <> 582911 order by idn1

select * from ntAverageValuesResults order by idn desc -- рассчитанные общие показатели (за все время)



CREATE TABLE [dbo].[tlog](
    idn int identity(1,1),
	[ctext] [varchar](100),
	cdatetime datetime
) ON [PRIMARY]

insert into tlog (ctext, cdatetime) select 'test1', GETDATE()
select * from tlog

-- добавляем в процедуры параметр @pParamsIdentifyer VARCHAR(50)

	ntpCorrResultsReport
	ntpCorrResultsPeriodsData
	ntpSearchAverageValues
	
	ntpImportCurrentChartAverageValues
	ntpCalcCalendarIdnDataCCLOSE

 & ",'" & ParamsIdentifyer & "'"

-- по алфавиту
ntpCalcCalendarIdnDataCCLOSE

ntpCorrResultsPeriodsData
ntpCorrResultsReport
ntpImportCurrentChartAverageValues
ntpSearchAverageValues



-- добавляем в таблицы столбец ParamsIdentifyer

SELECT * FROM sys.objects WHERE type in (N'U') order by name
SELECT * FROM sys.objects WHERE type in ('P') order by name

-- таблицы для добавления столбца ParamsIdentifyer:
select top 5 (select COUNT(*) from ntCalendarIdnData), * from ntCalendarIdnData
select top 5 (select COUNT(*) from ntCorrResults), * from ntCorrResults
select top 5 (select COUNT(*) from ntCorrResultsPeriodsData), * from ntCorrResultsPeriodsData
select top 5 (select COUNT(*) from ntCorrResultsReport), * from ntCorrResultsReport
select top 5 (select COUNT(*) from ntImportCurrent), * from ntImportCurrent
select top 5 (select COUNT(*) from ntImportCurrent_NoAverageValues), * from ntImportCurrent_NoAverageValues
select top 5 (select COUNT(*) from ntImportCurrentChartAverageValues), * from ntImportCurrentChartAverageValues

ALTER TABLE dbo.ntCalendarIdnData ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntCorrResults ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntCorrResultsPeriodsData ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntCorrResultsReport ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntImportCurrent ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntImportCurrent_NoAverageValues ADD ParamsIdentifyer VARCHAR(50) NULL
ALTER TABLE dbo.ntImportCurrentChartAverageValues ADD ParamsIdentifyer VARCHAR(50) NULL

update ntCalendarIdnData set ParamsIdentifyer = '0'
update ntCorrResults set ParamsIdentifyer = '0'
update ntCorrResultsPeriodsData set ParamsIdentifyer = '0'
update ntCorrResultsReport set ParamsIdentifyer = '0'
update ntImportCurrent set ParamsIdentifyer = '0'
update ntImportCurrent_NoAverageValues set ParamsIdentifyer = '0'
update ntImportCurrentChartAverageValues set ParamsIdentifyer = '0'



----------------------------------------
select CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator, min(cdate)
from ntPeriodsData
group by CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator
order by CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator

		ctime	copen	chigh	clow	cclose	idnNTdata	Volume	ABV	ABVMini	ABMmPosition0	ABMmPosition1	ABMmPosition0_M5	ABMmPosition1_M5



declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 2, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1

select * --idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes
from ntPeriodsData
where CurrencyId = @pCurrencyId 
  and DataSourceId = @pDataSourceId 
  and PeriodMinutes = @pPeriodMinutes -- импортированный период
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin -- задать минимальный множитель периода
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax -- задать минимальный множитель периода
order by ntPeriodsData.idn


select * from ntCurrency

select cdate, min(clow), max(chigh)
from ntPeriodsData
where CurrencyId = 6 
group by cdate
order by cdate

select * from ntSettingsFilesParameters_cn where threadid>0

--update ntSettingsFilesParameters_cn set threadid=0 where threadid=-1





	select * from ntCorrResultsReport where cntBars_day is not null order by idn

select * from ntImportCurrent



select * from ntCorrResultsPeriodsData
select * from ntCorrResults
select * from ntCorrResultsReport

-- выбираем данные от idnData до конца дня
select r.*, d2.* --top 10 r.* --r.idn, r.idnData 
from ntCorrResultsReport r
left outer join ntPeriodsData d1 on d1.idn = r.idnData
left outer join ntPeriodsData d2 on 
	    d2.CurrencyId = d1.CurrencyId
	and d2.DataSourceId = d1.DataSourceId
	and d2.PeriodMinutes = d1.PeriodMinutes
	and d2.cdate = d1.cdate
	and d2.idn >= d1.idn
where r.idnData in (select top 10 idnData from ntCorrResultsReport order by idn)
  and r.idnData = 1104295
order by r.idn, d2.idn




select d2.* 
from ntPeriodsData d1
left outer join ntPeriodsData d2 on 
	    d2.CurrencyId = d1.CurrencyId
	and d2.DataSourceId = d1.DataSourceId
	and d2.PeriodMinutes = d1.PeriodMinutes
	and d2.cdate = d1.cdate
	and d2.idn >= d1.idn
where d1.idn = 1104295
order by d2.idn
			
1	2	5	1	2014.12.30	11:45


idn	idnData	cdate	ctime	deltaMinutes	cperiod	ccorr	cperiodsAll	is_replaced	deltaKmaxPercent	ccorrmax_replaced	cperiodMax_replaced	deltaMinutesMax_replaced	idnmax_replaced
1	1104295	2014.12.30	11:45	20	5	0,9226933		0	0	0	0	0	0


pCorrResultsReport
pCorrResultsPeriodsData

ntpCorrResultsReport
ntpCorrResultsPeriodsData




/*
SELECT * 
FROM ntCorrResultsReport r
left outer join ntPeriodsData pd on pd.cdate = (select max(cdate) from ntPeriodsData where cdate < pd.cdate)
  and 
)
< r.cdate

SELECT * FROM ntPeriodsData

SELECT cdate, max(ctime)
FROM ntPeriodsData
group by cdate

2013.07.06

SELECT * 
FROM [ntCorrResultsPeriodsData] pd
--left outer join [ntCorrResultsPeriodsData] pdc on pdc.cdate = pd.cdateResult 
--  and pdc.ctime = pd.ctimeResult
where pd.cdate = pd.cdateResult 
  and pd.ctime = pd.ctimeResult

--update t1
set t1.chigh = t1.copen*(1+2.0/1000),
    t1.clow = t1.copen*(1-2.0/1000)
select *
from [ntCorrResultsPeriodsData] t1
left outer join [ntCorrResultsPeriodsData] t2 on t2.idnData = t1.idnData-1
where --t1.ctime like '00:%' and t2.ctime not like '00:%'
  t1.cdate <> t2.cdate


Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1
SELECT * FROM ntCorrResultsPeriodsData
SELECT * FROM ntPeriodsData

SELECT * FROM ntPeriods -- 5	3843981	4213002


SELECT *
into ntPeriodsData_test1
FROM ntPeriodsData
where idn >= (4213002-3000) and idn <= 4213002

SELECT *
FROM ntcorrresults
where idn = 5024862



-- просмотр результирующей таблицы
select * 
from ntCorrResultsReport
order by (case when deltaMinutes <= 120 then 0 else 1 end),
          ccorr desc




select datediff(dd,'2009.04.18','2015.06.15')
select datediff(dd,'2011.02.21','2015.06.09')

*/


-----------------------------------------------
-- v3 (NT+MT, разные периоды)

declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 5, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1


select datediff(dd,'20140110','20160331')
select datediff(dd,'20140204','20160413')
select datediff(dd,'20090101','20131229')
select datediff(dd,'20090301','20131229')
select datediff(dd,'20090601','20131229') - ок
select datediff(dd,'20090401','20131229') - ок (1732)
select datediff(dd,'20090421','20160430')

/*

select * from ntCurrency order by idn
select * from ntImportNTdata
select CurrencyId, count(*) from ntPeriodsData group by CurrencyId order by CurrencyId
select * from ntPeriodsData where CurrencyId = 33 order by cdate, ctime

1
2
3
4
5
6
11
13
28
29
30
32
33
35
36
38
40
41
42

*/




-- экспорт исторических данных из NT:
-- (не надо) удалить файл "C:\Documents and Settings\max\Мои документы\NinjaTrader 7\MyTestFile.txt"
-- (не надо) закрыть каталог "C:\Documents and Settings\max\Мои документы\NinjaTrader 7\" (чтобы не мешать записи)

-- вывести график за нужное количество дней (в DataSeries указывать полное количество календарных дней включая выходные)
-- 30.12.2013 - 31.12.2013 - ошибочные дни, история за них не грузится
-- (исправлено) до 20090401 - не грузится ABV
-- рекомендуемые интервалы:
-- 10.01.2014 - 31.03.2016 (810 дней)
-- 01.04.2009 - 29.12.2013 (1732 дня) (если идет ошибка по ABVMini - то 1702 дня)
select datediff(dd,'01.12.2012','03.08.2016')
select datediff(dd,'10.01.2014','03.08.2016')
select datediff(dd,'01.12.2012','29.12.2013')
-- !! последний день на графике не д.б. текущим, иначе при сохранении данных будет вылетать ошибка "Default	Error on calling 'OnBarUpdate' method for indicator 'ASampleStreamWriter': Процесс не может получить доступ к файлу ..., так как этот файл используется другим процессом."
-- !! если график не грузится и выходит ошибка "... You are accessing an index with a value that is invalid since its out of range...", то посмотреть при загрузке какого периода выходит эта ошибка и исключить этот период из графика.

-- не закрывая график зайти в NT / Tools / Historical Data Manager / Reload / нажать Reload All
-- после загрузки данных на график: 1) прокрутить график в конец. 2) подключить к нему индикатор ASampleStreamWriter
-- после этого появится файл "C:\Documents and Settings\max\Мои документы\NinjaTrader 7\MyTestFile.txt"

/*

-- импорт файла с историческими данными на SQL Server:
-- скопировать файл "C:\Documents and Settings\max\Мои документы\NinjaTrader 7\MyTestFile.txt" в каталог E:\forex\MSSQL
-- переименовать его в ntEURUSD1.txt
-- очистить таблицу [dbo].[ntEURUSD1]
-- запустить E:\forex\MSSQL\importntEURUSD1txt.dtsx
-- данные из NT появятся в таблице ntEURUSD1
*/


-- truncate table ntEURUSD1
-- select count(*) from ntEURUSD1 with (nolock) -- 403872 1847772 -> 1845111
-- select * from ntEURUSD1 where idn = 403872 


-- тикеры (если надо - добавить нужный тикер в таблицу):
-- select * from ntCurrency
-- insert into ntCurrency (CurrencyName, cdatasourceid, cdescription, FullContractCode, NTName) 
-- values ('EURUSD2',2,'курс EURUSD (NT8)','EURUSD2','6E2')


-- склейка двух исходных файлов в один (добавление показателей по другой валюте) (запускать в Access):
select t1.*, 
	t2.cclose as ccloseEURUSD,
	t2.ABV as ABVEURUSD,
	t2.ABVMini as ABVMiniEURUSD
into t111
from NtImport_6B_Minute_5_id1 as t1
left outer join NtImport_6E_Minute_5_id1 as t2 on t2.cdatetime = t1.cdatetime
order by t1.cdatetime

update ntPeriodsDataCCLOSE_4_2_5_1_1 
set 
ABV = ABV * 0.01, 
ABVMini = ABVMini * 0.01, 
ABVEURUSD = ABVEURUSD * 0.01, 
ABVMiniEURUSD = ABVMiniEURUSD * 0.01 

----------



-- на всякий случай сохраним старые данные по USDCAD (6C)
--select *
--into ntImportNTdata_6B_old
--from ntImportNTdata
--where CurrencyId = 4 and DataSourceId = 2 and PeriodMinutes = 5

-- преобразуем импортированные данные из MT, добавляем IDN
-- в таблице ntImportNTdata хранятся исходные импортированные данные по всем валютам

-- select * from ntcurrency

--/*
declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 42, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1
--*/

delete 
-- select *
from ntImportNTdata
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes
--order by cdate, ctime

insert into ntImportNTdata(CurrencyId, DataSourceId, PeriodMinutes, cdate, ctime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1)
  select @pCurrencyId, @pDataSourceId, @pPeriodMinutes,
		 left(cdate,4) + '.' + SUBSTRING(cdate,5,2) + '.' + right(cdate,2) as cdate,
		 left((REPLICATE('0',6-len(ctime)) + ctime),2) + ':' + SUBSTRING((REPLICATE('0',6-len(ctime)) + ctime),3,2) as ctime
		 ,convert(real,replace(copen,',','.'))
		 ,convert(real,replace(chigh,',','.'))
		 ,convert(real,replace(clow,',','.')) 
		 ,convert(real,replace(cclose,',','.'))
         ,convert(int,Volume), convert(int,ABV)
		 ,convert(int,ABVMini) --0
		 ,convert(real,replace(ABMmPosition0,',','.'))
		 ,0
		 --,convert(real,replace(ABMmPosition1,',','.'))
  from ntEURUSD1
  order by idn



-- select * from ntImportNTdata
-- select * from ntImportNTdata where CurrencyId = 5
-- select count(*) from ntImportNTdata where CurrencyId = 5 and PeriodMinutes = 5
-- select * from ntImportNTdata where cdate = '2012.09.10'
-- select * from ntImportNTdata where PeriodMinutes <> 5



/*
-- проверяем "дырки" в данных из NT (сравниваем с данными из MT)
drop table #tnt
drop table #tmt

select cdate, count(*) as cnt into #tnt from ntImportNTdata group by cdate
select cdate, count(*) as cnt into #tmt from tImportMTdata group by cdate

select *, DATEPART(dw,mt.cdate)
from #tmt mt
left outer join #tnt nt on nt.cdate=mt.cdate
order by isnull(nt.cnt,0), mt.cdate
-- where mt.cdate = '2015.05.26'
*/

----------




-- select min(idn), max(idn) from ntImportNTdata -- 1	1845111
-- select min(idn), max(idn) from ntPeriodsData -- 1	
-- select * from ntPeriods

-- делаем разные временные периоды из импортированного периода







-- select * from ntImportMTdata
-- select * from ntPeriodsData where CurrencyId = 2
-- select count(*) from ntPeriodsData -- 





/*
-- 
If object_ID('tempdb..#ntImportNTdata') Is not Null drop table #ntImportNTdata
select * into #ntImportNTdata from ntImportNTdata where 
order by idn
*/



/*
-- создаем процедуру для заполнения таблицы ntPeriodsData данными
-- drop PROCEDURE ntpPeriodsData
alter PROCEDURE ntpPeriodsData (
	@pCurrencyId int,
	@pDataSourceId int,
	@pPeriodMinutes int,
	@pPeriodMultiplicator int
)
AS BEGIN 
-- процедура для заполнения таблицы ntPeriodsData данными

SET NOCOUNT ON
DECLARE @idnfirst int, @idnlast int

select @idnfirst = isnull(max(idn),0)+1 from ntPeriodsData;

 insert into ntPeriodsData (CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator,
							CDATE, CTIME, CCLOSE, idnNTdata, copen, chigh, clow, 
							Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, 
							cBidAskMovedTotal, cBidAskAvgVolume)
    select @pCurrencyId, @pDataSourceId, @pPeriodMinutes, @pPeriodMultiplicator,
		   t1.CDATE, t1.CTIME, t1.CCLOSE, t1.idn, 
           t2.copen as copen,
           max(t3.chigh) as chigh,
           min(t3.clow) as clow,
		   sum(t3.Volume), 
		   t1.ABV, 
		   t1.ABVMini, 
		   t1.ABMmPosition0, 
		   t1.ABMmPosition1,
		   t1.cBidAskMovedTotal,
		   t1.cBidAskAvgVolume
	from ntImportNTdata t1
	left outer join ntImportNTdata t2 on t2.idn=t1.idn-@pPeriodMultiplicator+1 -- для расчета copen
	left outer join ntImportNTdata t3 on t3.idn>(t1.idn-@pPeriodMultiplicator) and t3.idn<=t1.idn -- для расчета chigh и clow
	where t1.CurrencyId = @pCurrencyId 
	  and t1.DataSourceId = @pDataSourceId 
	  and t1.PeriodMinutes = @pPeriodMinutes
	  and t1.idn/@pPeriodMultiplicator = t1.idn*1.0/@pPeriodMultiplicator
	group by t1.CDATE, t1.CTIME, t1.CCLOSE, t1.idn, t2.copen,
		   t1.ABV, 
		   t1.ABVMini, 
		   t1.ABMmPosition0, 
		   t1.ABMmPosition1,
		   t1.cBidAskMovedTotal,
		   t1.cBidAskAvgVolume
	order by t1.idn

select @idnlast = max(idn) from ntPeriodsData

--insert into ntPeriods (CPERIOD, idn_first, idn_last)
--  select @pperiod as CPERIOD, @idnfirst, @idnlast

END
*/




	
	
  
  
-- заполняем таблицу ntPeriodsData данными
--/*
declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 46, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 12, @pPeriodMultiplicatorMax = 12

--*/


--delete 
 select *
from ntPeriodsData
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes 
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax
order by cdate, ctime


declare @i int
select @i=@pPeriodMultiplicatorMin -- начальный период
WHILE @i<=@pPeriodMultiplicatorMax -- конечный период  
begin
  exec ntpPeriodsData @pCurrencyId = @pCurrencyId, @pDataSourceId = @pDataSourceId, @pPeriodMinutes = @pPeriodMinutes, @pPeriodMultiplicator = @i
  set @i = @i + 1
end


 
 -- select * from ntPeriodsData where PeriodMultiplicator <> 1
 -- select * from ntPeriodsData where PeriodMultiplicator = 7
 
-- select * from ntPeriodsData order by IDN
-- select * from ntPeriodsData where idn >= 800000 order by IDN
-- select * from ntPeriodsData where CurrencyId = 46 and PeriodMinutes = 1
-- select * from ntPeriodsData where CurrencyId = 46 and PeriodMultiplicator = 1
-- select * from ntPeriodsData where CurrencyId = 46 and PeriodMultiplicator <> 1 order by idn
-- select top 30000 * from ntPeriodsData where CurrencyId = 46 and cdate >= '2016.01.01' order by idn


-- select * from ntPeriods order by CPERIOD
-- select max(IDN)+1 from ntPeriodsData
-- select max(CPERIOD) from ntPeriodsData
-- select count(*) from ntPeriodsData -- 4520520

-- таблица ntPeriodsData заполнена

--/*
declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 46, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1
--*/
-- заполняем поля ntPeriodsData.ABMmPosition0_M5 и ntPeriodsData.ABMmPosition1_M5
  

update ntPeriodsData 
set BSV = ABMmPosition0, BSVMini = ABMmPosition1
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax


update ntPeriodsData 
set ABMmPosition0_M5 = ABMmPosition0,
	ABMmPosition1_M5 = ABMmPosition1
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax
  




-- ОБЯЗАТЕЛЬНО: заново заполняем таблицу ntTradeDays (количество баров по дням)
-- select * from ntTradeDays
truncate table ntTradeDays

insert into ntTradeDays (
	CurrencyId,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicator,
	cdate,
	cntBars)
select 
	CurrencyId,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicator,
	cdate,
	count(*) as cntBars
from ntPeriodsData WITH(NOLOCK) -- index=index4)
group by 
	CurrencyId,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicator,
	cdate
order by 
	CurrencyId,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicator,
	cdate
	
	
	











/*
-- 

-- update pd
set pd.ABMmPosition0_M5 = d.ABMmPosition0,
	pd.ABMmPosition1_M5 = d.ABMmPosition1
-- select * --count(*)
from ntPeriodsData pd
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
from ntPeriodsData
*/



----------
/*

idn         CurrencyId  DataSourceId PeriodMinutes PeriodMultiplicator cdate      ctime copen         chigh         clow          cclose        idnNTdata   Volume      ABV         ABVMini     ABMmPosition0 ABMmPosition1 ABMmPosition0_M5 ABMmPosition1_M5

*/
-- заполняем таблицу для хранения только cclose только по нужным периодам

-- select * from ntCurrency
--/*
declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 46, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1

--truncate table ntPeriodsDataCCLOSE

--insert into ntPeriodsDataCCLOSE (idn, cclose, ABV, ABVMini, TimeInMinutes, cdate, volume, BSV, BSVMini, cBidAskMovedTotal) --, ccloseEURUSD, ABVEURUSD, ABVMiniEURUSD)
--select idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes, cdate, volume --, (copen+cclose)/2
select idn, cclose, ABV, ABVMini, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes, cdate, volume, BSV, BSVMini, cBidAskMovedTotal --, (copen+cclose)/2
--select idn, cclose, ABV, ABVMini, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes, cdate, volume, BSV, BSVMini, cclose as ccloseEURUSD, ABV as ABVEURUSD, ABVMini as ABVMiniEURUSD
from ntPeriodsData
where CurrencyId = @pCurrencyId 
  and DataSourceId = @pDataSourceId 
  and PeriodMinutes = @pPeriodMinutes -- импортированный период
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin -- задать минимальный множитель периода
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax -- задать минимальный множитель периода
order by ntPeriodsData.idn

-- select * from ntPeriodsDataCCLOSE order by idn


-- ПРОВЕРИТЬ ТОЧНОСТЬ ДАННЫХ (чтобы она не потерялась)


--------------------------


-- делаем из исторических данных файл с текущими данными


declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 46, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1

-- truncate table ntPeriodsDataCCLOSE
drop table ntImport_temp

--insert into ntPeriodsDataCCLOSE (idn, cclose, ABV, ABVMini, TimeInMinutes, cdate, volume, BSV, BSVMini) --, ccloseEURUSD, ABVEURUSD, ABVMiniEURUSD)
--select idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes, cdate, volume --, (copen+cclose)/2
select cdate as cdateOld,
		ctime as ctimeOld,
		copen, chigh, clow, cclose, 
		Volume, ABV, ABVMini, 
		BSV as ABMmPosition0,
		BSVMini as ABMmPosition1,
		cdate,
		ctime,
		cdate + ' ' + ctime as cdatetime,
		cBidAskMovedTotal
into ntImport_temp
from ntPeriodsData
where CurrencyId = @pCurrencyId 
  and DataSourceId = @pDataSourceId 
  and PeriodMinutes = @pPeriodMinutes -- импортированный период
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin -- задать минимальный множитель периода
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax -- задать минимальный множитель периода
order by ntPeriodsData.idn





--select * from ntPeriodsDataCCLOSE 
select * from ntImport_temp

cclose	ABV	ABVMini	TimeInMinutes	
cdate	volume	BSV	BSVMini





--------------------------
-- добавляем информацию по EURUSD
update ntPeriodsDataCCLOSE set ccloseEURUSD = null, ABVEURUSD = null, ABVMiniEURUSD = null

-- заполняем поля ccloseEURUSD, ABVEURUSD, ABVMiniEURUSD
select * 
-- update d1 set d1.ccloseEURUSD = d2.cclose, 	d1.ABVEURUSD = d2.ABV, 	d1.ABVMiniEURUSD = d2.ABVMini
from ntPeriodsDataCCLOSE d1
left outer join ntPeriodsData d2 on d2.CurrencyId = 1 
  and d2.DataSourceId = 2 
  and d2.PeriodMinutes = 5 -- импортированный период
  and d2.PeriodMultiplicator >= 1 -- задать минимальный множитель периода
  and d2.PeriodMultiplicator <= 1 -- задать минимальный множитель периода
  and d2.cdate = d1.cdate
  and CONVERT(int,LEFT(d2.ctime,2))*60 + CONVERT(int,SUBSTRING(d2.ctime,4,2)) = d1.TimeInMinutes
where d2.CurrencyId is not null
--order by d1.cdate, d1.TimeInMinutes

-- заполняем пробелы (делать)
select * from ntPeriodsDataCCLOSE where ccloseEURUSD is null

select * 
-- update d1 set d1.ccloseEURUSD = d2.ccloseEURUSD, d1.ABVEURUSD = d2.ABVEURUSD, d1.ABVMiniEURUSD = d2.ABVMiniEURUSD
from ntPeriodsDataCCLOSE d1
left outer join ntPeriodsDataCCLOSE d2 on d2.idn = (select max(idn) from ntPeriodsDataCCLOSE where idn < d1.idn and ccloseEURUSD is not null)
where d1.ccloseEURUSD is null


-- (не делать) удаляем пробелы
select * 
-- delete
from ntPeriodsDataCCLOSE where ccloseEURUSD is null

--------------------------

If object_ID('tempdb..#dates_notActive') Is not Null drop table #dates_notActive

-- выбираем даты с "запрещенными" новостями
select distinct c.cdate --cName, c.cCountry
into #dates_notActive
from ntCalendarIdnData c -- загруженные события экономического календаря
inner join nt_rt_CalendarActive ca on -- таблица для определения новостей, которые можно/нельзя использовать при торговле (для realTrade)
		ca.CurrencyId = 1 --@pCurrencyId -- поставить нужный CurrencyId
	and ca.cName = c.cName 
	and ca.cCountry = c.cCountry
	and ca.isActive = 0

-- убираем даты с "запрещенными" новостями
select * 
-- delete
from ntPeriodsDataCCLOSE 
where cdate in (select cdate from #dates_notActive)

--------------------------








--------------------------



*/
--declare @idnMin int, @cntFirstRecordsToDelete int
--set @cntFirstRecordsToDelete = 


-- select * from ntPeriodsDataCCLOSE
-- select * from ntPeriodsData where idn >= 1000000
-- select count(*) from ntPeriodsDataCCLOSE -- 433506

-- delete from ntPeriodsDataCCLOSE where idn >= 2980047

-- после заполнения таблицы ntPeriodsDataCCLOSE нужно импортировать ее в Access (не связывая) 
-- с именем ntPeriodsDataCCLOSE_[CurrencyId]_[DataSourceId]_[PeriodMinutes]_[PeriodMultiplicatorMin]_[PeriodMultiplicatorMax]
-- например: ntPeriodsDataCCLOSE_2_2_5_1_1
-- сделать на нее в Access ключ по полю idn (индекс создастся автоматически)
----------

-- select * from [_ntEURUSD5Curr]





















-------------




*/



-- select * from ntCorrResultsReport
-- delete from ntCorrResultsReport
-- select * from [ntCorrResultsPeriodsData]




-- select * from ntPeriodsData
-- select * from ntCorrResultsReport order by idn
-- select * from ntCorrResultsPeriodsData order by idn
-- delete from ntCorrResultsPeriodsData
-- exec ntpCorrResultsPeriodsData 10,300,1000

-- select * from ntCorrResultsReport





-----------------------

-- Access:
























