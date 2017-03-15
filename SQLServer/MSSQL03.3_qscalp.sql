

-- импорт склеенных 5-минуток из qscalp

-- обработать тиковые данные с помощью F:\DelphiProjects\qscalp\qscalp.exe
-- получатся склеенные 5-минутки
-- сделать файлы
-- G:\qscalp_data\test_3_Total_files\Total_AuxInfo.txt
-- G:\qscalp_data\test_3_Total_files\Total_Ticks.txt
-- G:\qscalp_data\test_3_Total_files\Total_OrdLog.txt

-- Переместить их в 
-- G:\forex\MSSQL\Total_AuxInfo.txt
-- G:\forex\MSSQL\Total_Ticks.txt
-- G:\forex\MSSQL\Total_OrdLog.txt (в файле заменить , на .)

-- удалить таблицы для импорта:
drop table Total_AuxInfo
drop table Total_Ticks
drop table Total_OrdLog

---------------
CREATE TABLE [dbo].[Total_OrdLog] (
[idn] int identity(1,1),
[cPeriod] varchar(10),
[cExchTimeClose] varchar(50),
[cBSV] real,
[cBSC] real,
[cVolume] real,
[cDealsCount] real,
[cOpen] real,
[cHigh] real,
[cLow] real,
[cClose] real,
[cAskTotal] real,
[cBidTotal] real,
[cBidAskTotal] real,
[cOpenInterest] real,
[cAskMovedTotal] real,
[cBidMovedTotal] real,
[cBidAskMovedTotal] bigint,
[cntAsk] bigint,
[cntBid] bigint,
[AskAvgVolume] real,
[BidAvgVolume] real,
[BidAskAvgVolume] real
)
---------------

-- запустить
-- G:\forex\MSSQL\Total_AuxInfo.dtsx
-- G:\forex\MSSQL\Total_Ticks.dtsx
-- G:\forex\MSSQL\Total_OrdLog.dtsx ------------- !!!!! изменить этот пакет, т.к. в файл добавлены столбцы (cntAsk	cntBid	AskAvgVolume	BidAvgVolume	BidAskAvgVolume)

-- данные появятся в таблицах
select * from Total_AuxInfo order by idn
select * from _Total_AuxInfo_v2 order by idn
select * from Total_Ticks order by idn
select * from Total_OrdLog order by idn



----------------

-- меняем 19:00 на 18:45
-- 1. проверяем
select * from Total_AuxInfo where cExchTimeClose like '% 19:00' -- д.б.
select * from Total_AuxInfo where cExchTimeClose like '% 18:45' -- не д.б.

select * from Total_Ticks where cExchTimeClose like '% 19:00' -- д.б.
select * from Total_Ticks where cExchTimeClose like '% 18:45' -- не д.б.

select * from Total_OrdLog where cExchTimeClose like '% 19:00' -- д.б.
select * from Total_OrdLog where cExchTimeClose like '% 18:45' -- не д.б.

-- 2. меняем
update Total_AuxInfo set cExchTimeClose = left(cExchTimeClose,11) + '18:45' where cExchTimeClose like '% 19:00'
update Total_Ticks set cExchTimeClose = left(cExchTimeClose,11) + '18:45' where cExchTimeClose like '% 19:00'
update Total_OrdLog set cExchTimeClose = left(cExchTimeClose,11) + '18:45' where cExchTimeClose like '% 19:00'

----------------


-- проверяем косяки (не д.б. задвоенных данных)
select cExchTimeClose, count(*) 
from Total_AuxInfo
group by cExchTimeClose
having count(*) > 1
order by cExchTimeClose

select cExchTimeClose, count(*) 
from Total_Ticks
group by cExchTimeClose
having count(*)  > 1
order by cExchTimeClose

select cExchTimeClose, count(*) 
from Total_OrdLog
group by cExchTimeClose
having count(*)  > 1
order by cExchTimeClose

select * from Total_AuxInfo where cExchTimeClose in ('2014.10.09 15:45')





------------------
-- если в таблице Total_AuxInfo есть дубли, то:
-- убираем задвоенные строки в таблице Total_AuxInfo (появляются когда данные в исходном текстовом файле появляются перед последующими)
-- (если будут задвоенные строки в таблице Total_Ticks - то сделать для нее аналогичную процедуру)

If object_ID('tempdb..#Total_AuxInfo') Is not Null drop table #Total_AuxInfo

select cExchTimeClose, 
	min(idn) as idn_min, 
	max(idn) as idn_max, 
	min(cAskTotal) as cAskTotal,
	min(cBidTotal) as cBidTotal,
	min(cOpenInterest) as cOpenInterest,
	min(cDealsCount) as cDealsCount,
	min(cOpen) as cOpen,
	min(cHigh) as cHigh,
	min(cLow) as cLow,
	min(cClose) as cClose,
	count(*) as cnt_rows
into #Total_AuxInfo
from Total_AuxInfo
group by cExchTimeClose
having count(*) > 1
order by cExchTimeClose

select * from #Total_AuxInfo

-- берем значения из исходных записей
update t 
set t.cAskTotal = (case when t1.cAskTotal > t2.cAskTotal then t1.cAskTotal else t2.cAskTotal end), 
	t.cBidTotal = (case when t1.cBidTotal > t2.cBidTotal then t1.cBidTotal else t2.cBidTotal end), 
	t.cOpenInterest = (case when t1.cOpenInterest > t2.cOpenInterest then t1.cOpenInterest else t2.cOpenInterest end),
	t.cDealsCount = t1.cDealsCount + t2.cDealsCount, 
	t.cOpen = t1.cOpen, 
	t.cHigh = (case when t1.cHigh > t2.cHigh then t1.cHigh else t2.cHigh end), 
	t.cLow = (case when t1.cLow < t2.cLow then t1.cLow else t2.cLow end), 
	t.cClose = t2.cClose
-- select * 
from #Total_AuxInfo t
left outer join Total_AuxInfo t1 on t1.idn = t.idn_min
left outer join Total_AuxInfo t2 on t2.idn = t.idn_max

-- убираем ненужные дубли
update t1
set t1.cPeriod = '[delete]'
-- select * 
from #Total_AuxInfo t
left outer join Total_AuxInfo t1 on t1.cExchTimeClose = t.cExchTimeClose 
	and t1.idn <> t.idn_min
	
delete from Total_AuxInfo where cPeriod = '[delete]'

-- восстанавливаем нужные значения
update t1
set t1.cAskTotal = t.cAskTotal, 
	t1.cBidTotal = t.cBidTotal, 
	t1.cOpenInterest = t.cOpenInterest,
	t1.cDealsCount = t.cDealsCount, 
	t1.cOpen = t.cOpen, 
	t1.cHigh = t.cHigh, 
	t1.cLow = t.cLow, 
	t1.cClose = t.cClose
-- select * 
from #Total_AuxInfo t
left outer join Total_AuxInfo t1 on t1.cExchTimeClose = t.cExchTimeClose 
	and t1.idn = t.idn_min
	
	
-- снова проверяем косяки (не д.б. задвоенных данных)
select cExchTimeClose, count(*) 
from Total_AuxInfo
group by cExchTimeClose
having count(*) > 1
order by cExchTimeClose

--------------------------------

-- теперь исправленные итоговые данные из qscalp находятся в таблицах Total_AuxInfo и Total_Ticks и Total_OrdLog

-- select * from Total_Ticks where cExchTimeClose in ('2015.04.30 23:50')

select * 
from Total_Ticks t
left outer join Total_AuxInfo a on a.cExchTimeClose = t.cExchTimeClose
left outer join Total_AuxInfo a2 on a2.cExchTimeClose < t.cExchTimeClose and a2.cExchTimeClose = (select max(cExchTimeClose) from Total_AuxInfo where cExchTimeClose < t.cExchTimeClose) -- последняя запись ДО текущей
-- where a.cExchTimeClose is null
order by t.cExchTimeClose



select * from ntcurrency

-- insert into ntcurrency (CurrencyName, cdatasourceid, cdescription, FullContractCode)
-- select 'qs_Si',3,'Фьючерсный контракт на курс доллар США - российский рубль (qscalp)','qs_f_Si'
-- update ntcurrency set cdatasourceid = 2 where idn = 46
-- update ntcurrency set CurrencyName = 'qsSi' where idn = 46
-- update ntcurrency set NTName = 'qsSi' where idn = 46


-- преобразуем импортированные данные
-- в таблице ntImportNTdata хранятся исходные импортированные данные по всем валютам



CREATE UNIQUE CLUSTERED INDEX [cExchTimeCloseIndex] ON [dbo].[Total_Ticks] 
(cExchTimeClose ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [cExchTimeCloseIndex] ON [dbo].[Total_AuxInfo] 
(cExchTimeClose ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE UNIQUE CLUSTERED INDEX [cExchTimeCloseIndex] ON [dbo].[Total_OrdLog] 
(cExchTimeClose ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--/*
declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 46, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1
--*/

--/*
--delete 
select *
from ntImportNTdata
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes
order by idn --desc
*/

-- !!!! сначала задать поправки (разница с последней уже существующей в таблице ntImportNTdata записью)
-- !!!! также задать первую дату после уже существующей в таблице ntImportNTdata
-- insert into ntImportNTdata(CurrencyId, DataSourceId, PeriodMinutes, cdate, ctime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, cDealsCount, cBidAskMovedTotal, cBidAskAvgVolume)
	select @pCurrencyId, @pDataSourceId, @pPeriodMinutes,
		 left(o.cExchTimeClose,10) as cdate,
		 right(o.cExchTimeClose,5) as ctime,
		 o.copen, o.chigh, o.clow, o.cclose,
         o.cVolume as Volume, 
         o.cBidAskTotal + 514328557 as ABV, 
         o.cOpenInterest as ABVMini,
         o.cBSV + 3132682 as ABMmPosition0,
         o.cBSC + -67910 as ABMmPosition1,
		 o.cDealsCount as cDealsCount,
         o.cBidAskMovedTotal + -13080633244 as cBidAskMovedTotal,
         o.BidAskAvgVolume as cBidAskAvgVolume
from Total_OrdLog o
where left(o.cExchTimeClose,10) >= '2016.07.19' -- задать первую дату после уже существующей в таблице ntImportNTdata
order by o.cExchTimeClose





/*
-- старый вариант ( с использованием Total_Ticks и Total_AuxInfo)
--delete 
select *
from ntImportNTdata
where CurrencyId = @pCurrencyId and DataSourceId = @pDataSourceId and PeriodMinutes = @pPeriodMinutes
order by idn --desc

insert into ntImportNTdata(CurrencyId, DataSourceId, PeriodMinutes, cdate, ctime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, cDealsCount, cBidAskMovedTotal)
	select @pCurrencyId, @pDataSourceId, @pPeriodMinutes,
		 left(t.cExchTimeClose,10) as cdate,
		 right(t.cExchTimeClose,5) as ctime,
		 t.copen, t.chigh, t.clow, t.cclose,
         t.cVolume as Volume, 
         coalesce(a.cBidAskTotal, a2.cBidAskTotal, 0) as ABV, 
         coalesce(a.cOpenInterest, a2.cOpenInterest, 0) as ABVMini,
         t.cBSV as ABMmPosition0,
         t.cBSC as ABMmPosition1,
		 t.cDealsCount as cDealsCount,
         coalesce(o.cBidAskMovedTotal, o2.cBidAskMovedTotal, 0) as cBidAskMovedTotal		 
from Total_Ticks t
left outer join Total_AuxInfo a on a.cExchTimeClose = t.cExchTimeClose
left outer join Total_AuxInfo a2 on a2.cExchTimeClose < t.cExchTimeClose and a2.cExchTimeClose = (select max(cExchTimeClose) from Total_AuxInfo where cExchTimeClose < t.cExchTimeClose) -- последняя запись ДО текущей
left outer join Total_OrdLog o on o.cExchTimeClose = t.cExchTimeClose
left outer join Total_OrdLog o2 on o2.cExchTimeClose < t.cExchTimeClose and o2.cExchTimeClose = (select max(cExchTimeClose) from Total_OrdLog where cExchTimeClose < t.cExchTimeClose) -- последняя запись ДО текущей
order by t.cExchTimeClose
*/

-- select * from ntImportNTdata
-- select * from ntImportNTdata where CurrencyId = 46
-- update ntImportNTdata set DataSourceId = 2 where CurrencyId = 46

-- select count(*) from ntImportNTdata where CurrencyId = 5 and PeriodMinutes = 5
-- select * from ntImportNTdata where cdate = '2012.09.10'
-- select * from ntImportNTdata where PeriodMinutes <> 5


-- далее - см. запрос [MSSQL03.0_NT_M5_v04.sql] (с места "заполняем таблицу ntPeriodsData данными")
--------------------------------------------------


-- данее - не нужно (начальный вариант)

-- 1. импорт данных из qscalp (файл AuxInfo)

-- запустить в cmd:
F:\downloads\qsh2txt\qsh2txt.exe F:\downloads\qsh2txt\AuxInfo.Si-3.14_FT.2014-02-06.qsh

-- select * from AuxInfo order by ExchTime
-- truncate table AuxInfo

-- оставить в файле 
-- F:\downloads\qsh2txt\AuxInfo.Si-3.14_FT.2014-02-06.{1-AuxInfo}_v2.txt
-- только заголовок и данные

-- запустить 
-- F:\downloads\qsh2txt\AuxInfo.dtsx

-- даннае появятся в таблице AuxInfo



-- 2. импорт данных из qscalp (файл Ticks)

-- запустить в cmd:
F:\downloads\qsh2txt\qsh2txt.exe F:\downloads\qsh2txt\Ticks.Si-3.14_FT.2014-02-06.qsh

-- select * from Ticks order by ExchTime
-- truncate table Ticks

-- оставить в файле 
-- F:\downloads\qsh2txt\Ticks.txt
-- только заголовок и данные

-- запустить 
-- F:\downloads\qsh2txt\Ticks.dtsx

-- даннае появятся в таблице Ticks




-- 3. импорт данных из MICEX (futures_trades.txt)

-- запустить в cmd:
F:\downloads\qsh2txt\qsh2txt.exe F:\downloads\qsh2txt\Ticks.Si-3.14_FT.2014-02-06.qsh

-- select * from futures_trades where #SYMBOL = 'SiH4' order by MOMENT
-- truncate table futures_trades

-- сделать файл
F:\downloads\qsh2txt\from_micex\OrderBook20140206\futures_trades.txt

-- запустить 
F:\downloads\qsh2txt\from_micex\futures_trades.dtsx

-- даннае появятся в таблице futures_trades






--------------------------------

        if ((pTotalFilePeriodMinutes=5)
              and ((RightStr(ExchTimeCurrent,1)='0') or (RightStr(ExchTimeCurrent,1)='5')) // âðåìÿ òåêóùåé ñäåëêè êðàòíî 5 ìèíóòàì
              and (RightStr(ExchTimePrevious,2) <> RightStr(ExchTimeCurrent,2)) // ïðåäûäóùàÿ ñäåëêà áûëà â äðóãîé ìèíóòå
              and (ExchTimePrevious <> '') // íå íîâûé èíñòðóìåíò
              and (ExchTimeCurrent <> '')  // íå íîâûé èíñòðóìåíò
              and (not ((RightStr(ExchTimePrevious,5) = '23:49') and (RightStr(ExchTimeCurrent,5) = '10:00')) // íå ïåðâàÿ ñäåëêà â ôàéëå
              and (DealCDate = Copy(RightStr(pFileName,26),1,10)) // äàòà ñäåëêè ñîâïàäàåò ñ äàòîé ôàéëà
              )
              ) then
              
              
              
-- данные из qscalp (AuxInfo)
select * 
from AuxInfo
where ExchTime <= '06.02.2014 18:45:00.000'
order by ExchTime

-- данные из qscalp (Ticks)
select * --top 65000 * 
from Ticks 
where ExchTime <= '06.02.2014 18:45:00.000'
order by ExchTime

-- данные из MICEX
select * --top 65000 * 
from futures_trades where #SYMBOL = 'SiH4'
	and MOMENT >= '20140206000000000'
order by MOMENT




------------------------------------



F:\downloads\qsh2txt\qsh2txt.exe F:\downloads\qsh2txt\Ticks.Si-9.14_FT.2014-09-01.qsh















