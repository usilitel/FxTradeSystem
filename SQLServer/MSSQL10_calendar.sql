
-- работа с экономическим календарем
-- в SQL Server календарь не импортируется, поэтому работаем через Access


-----------------------------------------------
-- закачка календаря для realTrade

-- 1. http://www.fxstreet.com/economic-calendar/
-- залогиниться
-- в фильтрах указать даты, все страны, все события.
-- сохранить календарь в формате *.csv, склеить файлы в один (за 1 раз сохраняется календарь за 1 год). В первой строке оставить заголовок.
-- положить файл в каталог g:\forex\MSSQL\nt_rt_ImportEventdates_temp.csv

-- в файле заменить [,] на [@] (предварительно проверить, чтобы в файле не было знаков @)
-- в Access удалить таблицу nt_rt_ImportEventdates_temp
-- в Access импортировать файл g:\forex\MSSQL\nt_rt_ImportEventdates_temp.csv , используя спецификацию импорта nt_rt_ImportEventdates_temp (появится таблица nt_rt_ImportEventdates_temp)


-- на всякий случай сохраняем копию таблицы
-- select * into _nt_rt_CalendarIdnData_v3 from nt_rt_CalendarIdnData

-- очищаем таблицу перед новой вставкой
truncate table nt_rt_CalendarIdnData

-- select * from nt_rt_ImportEventdates_temp
-- select * from nt_rt_CalendarIdnData

-- перекидываем данные календаря из Access на SQL Server (запустить запрос в Access)
insert into nt_rt_CalendarIdnData (idnDataEventdates, cdatetimeFromEventdates, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus)
select [Код], [DateTime], [Name], [Country], [Volatility], [Actual], [Previous], [Consensus]
from nt_rt_ImportEventdates_temp
order by [Код]



-- "кривые" записи (проверяем, их не должно быть)
select * 
from nt_rt_CalendarIdnData
where cVolatility not in ('0','1','2','3')
order by cactual desc


-- меняем обратно [@] на [,]
select replace(cName,'@',','), * 
from nt_rt_CalendarIdnData
where cName like '%@%'

update nt_rt_CalendarIdnData
set cName = replace(cName,'@',',')
where cName like '%@%'



select replace(cCountry,'@',','), * 
from nt_rt_CalendarIdnData
where cCountry like '%@%'

update nt_rt_CalendarIdnData
set cCountry = replace(cCountry,'@',',')
where cCountry like '%@%'







-- проверяем время событий (д.б. московское время минус 3 часа)
select * 
from nt_rt_CalendarIdnData
where cCountry = 'United States'
	and cVolatility = 3
	and cName = 'Unemployment Rate'
	
	
select * 
from nt_rt_CalendarIdnData
where cCountry = 'United States'
	and cName like '%speech%'


	-- вычисляем дату/время событий календаря
	update nt_rt_CalendarIdnData
	set cdatetime = SUBSTRING(cdatetimeFromEventdates,7,4) + '.' + SUBSTRING(cdatetimeFromEventdates,1,2) + '.' + SUBSTRING(cdatetimeFromEventdates,4,2) + ' ' + SUBSTRING(cdatetimeFromEventdates,12,5)
	where cdatetime is null

	-- вычисляем московское время
	update nt_rt_CalendarIdnData
	set cdatetime_moscow = dateadd(hh,3,CONVERT(datetime, cdatetime, 21))
	where cdatetime_moscow is null

	-- вычисляем дату/время событий календаря
	update nt_rt_CalendarIdnData
	set cdate = replace(CONVERT(varchar(10),cdatetime_moscow,111),'/','.'),
		ctime = left(CONVERT(varchar(10),cdatetime_moscow,108),5)
	where cdate is null and ctime is null

	update nt_rt_CalendarIdnData
	-- set TimeInMinutes = CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2))
	set TimeInMinutes = datepart(hh,cdatetime_moscow)*60 + datepart(mi,cdatetime_moscow)
	where TimeInMinutes is null
	
	-- убираем кавычку (чтобы не мешалась при вставке в таблицу ntCalendarActive)
	update nt_rt_CalendarIdnData
	set cName = replace(cName,'''','_')
	-- select * from nt_rt_CalendarIdnData
	where CHARINDEX ('''',cName) <> 0
	

	update nt_rt_CalendarIdnData
	set cName = ltrim(rtrim(cName)), cCountry = ltrim(rtrim(cCountry))
	-- select * from nt_rt_CalendarIdnData
	where (ltrim(rtrim(cName)) <> cName) or (ltrim(rtrim(cCountry)) <> cCountry)

select distinct cName, cCountry, cVolatility
from nt_rt_CalendarIdnData

select * from nt_rt_CalendarIdnData where cdate = '2016.07.19'
select * from _nt_rt_CalendarIdnData_v3 where cdate = '2016.07.19'

 
-----------------------------------------------




-- 1. http://www.fxstreet.com/economic-calendar/
-- в фильтрах указать все страны, все события
-- сохранить календарь в формате *.csv, склеить файлы в один (за 1 раз сохраняется календарь за 1 год). В первой строке оставить заголовок.
-- положить файл в каталог E:\forex\MSSQL\eventdates.csv

-- 2. импортировать файл E:\forex\MSSQL\eventdates.csv в Access, в таблицу ntImportEventdates (дополнить таблицу)
--    как делать: см. [закачка календаря для realTrade]
-- !!!!  ВСЕ ДАЛЬНЕЙШИЕ ИНСТРУКЦИИ ПЕРЕДЕЛАТЬ КАК В РАЗДЕЛЕ [закачка календаря для realTrade]

-- select * from ntCalendarIdnData

-- перекидываем данные календаря из Access на SQL Server (запустить запрос в Access)
insert into ntCalendarIdnData (idnDataEventdates, cdatetimeFromEventdates, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus)
select cIdn, cDateTime, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus
from ntImportEventdates
order by cIdn

-- "кривые" записи
select * 
from ntCalendarIdnData
where cVolatility not in ('0','1','2','3')
order by cactual desc

-- исправляем "кривые" записи
update ntCalendarIdnData
set cName = cName + ' ' + cCountry, 
	cCountry = cVolatility,
	cVolatility = cActual,
	cActual = cPrevious,
	cPrevious = cConsensus,
	cConsensus = null
from ntCalendarIdnData
where cVolatility not in ('0','1','2','3')

-- проверяем время событий (д.б. московское время минус 3 часа)
select * 
from ntCalendarIdnData
where cCountry = 'United States'
	and cVolatility = 3
	and cName = 'Unemployment Rate'
	
	
select * 
from ntCalendarIdnData
where cCountry = 'United States'
	and cName like '%speech%'


	-- вычисляем дату/время событий календаря
	update ntCalendarIdnData
	set cdatetime = SUBSTRING(cdatetimeFromEventdates,7,4) + '.' + SUBSTRING(cdatetimeFromEventdates,1,2) + '.' + SUBSTRING(cdatetimeFromEventdates,4,2) + ' ' + SUBSTRING(cdatetimeFromEventdates,12,5)
	--where ParamsIdentifyer = @pParamsIdentifyer

	-- вычисляем московское время
	update ntCalendarIdnData
	set cdatetime_moscow = dateadd(hh,3,CONVERT(datetime, cdatetime, 21))
	--where ParamsIdentifyer = @pParamsIdentifyer

	-- вычисляем дату/время событий календаря
	update ntCalendarIdnData
	set cdate = replace(CONVERT(varchar(10),cdatetime_moscow,111),'/','.'),
		ctime = left(CONVERT(varchar(10),cdatetime_moscow,108),5)
	--where ParamsIdentifyer = @pParamsIdentifyer

	update ntCalendarIdnData
	-- set TimeInMinutes = CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2))
	set TimeInMinutes = datepart(hh,cdatetime_moscow)*60 + datepart(mi,cdatetime_moscow)
	--where ParamsIdentifyer = @pParamsIdentifyer
	
	-- убираем кавычку (чтобы не мешалась при вставке в таблицу ntCalendarActive)
	update ntCalendarIdnData
	set cName = replace(cName,'''','_')
	where CHARINDEX ('''',cName) <> 0
	

	
		


select * 
from ntCalendarIdnData
where (ltrim(rtrim(cName)) <> cName) or (ltrim(rtrim(cCountry)) <> cCountry)

select distinct cName, cCountry, cVolatility
from ntCalendarIdnData

ntCalendarActive

select IsCalcCalendar, * from ntSettingsFilesParameters_cn



-- select * from nt_rt_CalendarIdnData where cname like '%ECB Interest Rate Decision%'
-----------------------------------------------------------------



-- создаем процедуру для вычисления idn баров, на которых происходили события календаря
-- drop PROCEDURE ntpCalcCalendarIdnDataCCLOSE
alter PROCEDURE ntpCalcCalendarIdnDataCCLOSE (
	@pParamsIdentifyer VARCHAR(50)
)
AS BEGIN 
-- процедура для вычисления idn баров, на которых происходили события календаря

	SET NOCOUNT ON

	declare
		@strCalendarNewsName varchar(100), -- текст показателя в календаре
		@strCalendarCountryName varchar(100),
		
	@pCurrencyId int,
	@pDataSourceId int,
	@pPeriodMinutes int,
	@pPeriodMultiplicator int
	
	
	select
		@strCalendarNewsName = strCalendarNewsName, -- текст показателя в календаре
		@strCalendarCountryName = strCalendarCountryName,
		@pCurrencyId = CurrencyId_Current ,
		@pDataSourceId = DataSourceId,
		@pPeriodMinutes = PeriodMinutes,
		@pPeriodMultiplicator = PeriodMultiplicatorForCalendar
	from ntSettingsFilesParameters_cn
	where ParamsIdentifyer = @pParamsIdentifyer


	
	If object_ID('tempdb..#ntCalendarIdnData') Is not Null drop table #CalendarIdnData
	
	select * --, convert(real,0) as ccorr
	into #CalendarIdnData
	from nt_rt_CalendarIdnData
	where cName	like @strCalendarNewsName and cCountry like @strCalendarCountryName
	
	
	update c
	set c.idnDataCCLOSE = p.idn
	-- select *
	from #CalendarIdnData c
	left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
	  and p.DataSourceId = @pDataSourceId 
	  and p.PeriodMinutes = @pPeriodMinutes
	  and p.PeriodMultiplicator = @pPeriodMultiplicator
	  and p.cdate = c.cdate
	  and p.ctime = c.ctime
	--order by p.cdate, p.ctime
	
	


	-- удаляем записи календаря, для которых нет исторических данных по ценам
	delete from #CalendarIdnData where idnDataCCLOSE is null

	-- проставляем ccorr по убыванию
	update #CalendarIdnData
	set ccorr = 1-((select COUNT(*) from #CalendarIdnData t2 where t2.cdatetime_moscow >= t1.cdatetime_moscow) * 0.001)
	from #CalendarIdnData t1

	
	-- перекидываем данные о idn и ccorr в таблицу tCorrResults
	delete 
	from ntCorrResults 
	where ParamsIdentifyer = @pParamsIdentifyer
	
	insert into ntCorrResults (idn, ccorr, ParamsIdentifyer)
	select idnDataCCLOSE, max(ccorr), @pParamsIdentifyer 
	from #CalendarIdnData 
	group by idnDataCCLOSE
	order by idnDataCCLOSE desc 

	
	select * from #CalendarIdnData order by cdatetime
	select * from ntCorrResults order by ParamsIdentifyer
	
		
END

go
 exec ntpCalcCalendarIdnDataCCLOSE '6E_15_120_PA211'



	select *
	--into #CalendarIdnData
	from nt_rt_CalendarIdnData
	where cName	like 'MBA Mortgage Applications' and cCountry like 'United States'
	
	select * from ntPeriodsData
	select * from ntCorrResults where ParamsIdentifyer = '6E_15_120_PA211' order by ccorr desc
	-- truncate table ntCorrResults
	
	
	
	
/*
-- создаем процедуру для вычисления idn баров, на которых происходили события календаря
-- drop PROCEDURE ntpCalcCalendarIdnDataCCLOSE
alter PROCEDURE ntpCalcCalendarIdnDataCCLOSE (
	@pCurrencyId int,
	@pDataSourceId int,
	@pPeriodMinutes int,
	@pPeriodMultiplicator int,
	@pParamsIdentifyer VARCHAR(50)
)
AS BEGIN 
-- процедура для вычисления idn баров, на которых происходили события календаря

	SET NOCOUNT ON


	-- вычисляем дату/время событий календаря
	update ntCalendarIdnData
	set cdatetime = SUBSTRING(cdatetimeFromEventdates,7,4) + '.' + SUBSTRING(cdatetimeFromEventdates,1,2) + '.' + SUBSTRING(cdatetimeFromEventdates,4,2) + ' ' + SUBSTRING(cdatetimeFromEventdates,12,5)
	where ParamsIdentifyer = @pParamsIdentifyer

	-- вычисляем московское время
	update ntCalendarIdnData
	set cdatetime_moscow = dateadd(hh,3,CONVERT(datetime, cdatetime, 21))
	where ParamsIdentifyer = @pParamsIdentifyer

	-- вычисляем дату/время событий календаря
	update ntCalendarIdnData
	set cdate = replace(CONVERT(varchar(10),cdatetime_moscow,111),'/','.'),
		ctime = left(CONVERT(varchar(10),cdatetime_moscow,108),5)
	where ParamsIdentifyer = @pParamsIdentifyer

	update ntCalendarIdnData
	-- set TimeInMinutes = CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2))
	set TimeInMinutes = datepart(hh,cdatetime_moscow)*60 + datepart(mi,cdatetime_moscow)
	where ParamsIdentifyer = @pParamsIdentifyer

	-- вычисляем idn записей из таблицы ntPeriodsData
	update ntCalendarIdnData
	set idnDataCCLOSE = p.idn
	from ntCalendarIdnData c
	left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
	  and p.DataSourceId = @pDataSourceId 
	  and p.PeriodMinutes = @pPeriodMinutes
	  and p.PeriodMultiplicator = @pPeriodMultiplicator
	  and p.cdate = c.cdate
	  and p.ctime = c.ctime
	where c.ParamsIdentifyer = @pParamsIdentifyer
	  
	-- удаляем записи календаря, для которых нет исторических данных по ценам
	delete from ntCalendarIdnData where ParamsIdentifyer = @pParamsIdentifyer and idnDataCCLOSE is null

	-- проставляем ccorr по убыванию
	update ntCalendarIdnData
	set ccorr = 1-((select COUNT(*) from ntCalendarIdnData t2 where t2.ParamsIdentifyer = @pParamsIdentifyer and t2.idn >= t1.idn) * 0.001)
	from ntCalendarIdnData t1
	where t1.ParamsIdentifyer = @pParamsIdentifyer
	
END
*/

 select * from ntCalendarIdnData
-- exec ntpCalcCalendarIdnDataCCLOSE @pCurrencyId = 1, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicator = 1



------------------------------------



 select * from ntPeriodsData



select *, 1-((select COUNT(*) from ntCalendarIdnData t2 where t2.idn >= t1.idn) * 0.001),
	   CONVERT(datetime, cdatetime, 21),
	   dateadd(hh,3,CONVERT(datetime, cdatetime, 21)),
	   datepart(hh,cdatetime_moscow),
	   datepart(mi,cdatetime_moscow),
	   datepart(hh,cdatetime_moscow)*60 + datepart(mi,cdatetime_moscow)
from ntCalendarIdnData t1

select *, 
		datepart(yy,cdatetime_moscow),
	    datepart(mm,cdatetime_moscow),
	    datepart(dd,cdatetime_moscow),
	    datepart(hh,cdatetime_moscow),
	    datepart(mi,cdatetime_moscow),
	    
	    convert(varchar(4),datepart(yy,cdatetime_moscow)) + '.' + convert(varchar(2),datepart(mm,cdatetime_moscow)) + '.' + convert(varchar(2),datepart(dd,cdatetime_moscow)),
	    replace(CONVERT(varchar(10),cdatetime_moscow,111),'/','.'),
	    left(CONVERT(varchar(10),cdatetime_moscow,108),5)
--	    datepart(hh,cdatetime_moscow) + ':' + datepart(mi,cdatetime_moscow)
from ntCalendarIdnData
 
 
 
cdatetime_moscow
2009-04-24 15:30:00.000



select * --idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes
from ntCalendarIdnData c
left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
  and p.DataSourceId = @pDataSourceId 
  and p.PeriodMinutes = @pPeriodMinutes
  and p.PeriodMultiplicator = @pPeriodMultiplicator
  and p.cdate = c.cdate
  and p.ctime = c.ctime
order by c.idn, p.idn











select * from ntCalendarIdnData



declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicator int
select @pCurrencyId = 1, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicator = 1


select * --idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes
from ntCalendarIdnData c
left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
  and p.DataSourceId = @pDataSourceId 
  and p.PeriodMinutes = @pPeriodMinutes
  and p.PeriodMultiplicator = @pPeriodMultiplicator
  and p.cdate = c.cdate
  and p.ctime = c.ctime
order by c.idn, p.idn




If object_ID('tempdb..#ntPeriodsDataFilered') Is not Null drop table #ntPeriodsDataFilered

select c.*, p.*, 
	   CONVERT(int,LEFT(p.ctime,2))*60 + CONVERT(int,SUBSTRING(p.ctime,4,2)) as TimeInMinutes, 
	   c.TimeInMinutes as TimeInMinutesFromCalendar,
	   c.ctime as ctimeFromCalendar,
	   CONVERT(int,LEFT(p.ctime,2))*60 + CONVERT(int,SUBSTRING(p.ctime,4,2)) - c.TimeInMinutes as DeltaTimeInMinutes
--into #ntPeriodsDataFilered 
from ntCalendarIdnData c
left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
  and p.DataSourceId = @pDataSourceId 
  and p.PeriodMinutes = @pPeriodMinutes
  and p.PeriodMultiplicator = @pPeriodMultiplicator
  and p.cdate = c.cdate
where p.idn is not null
and CONVERT(int,LEFT(p.ctime,2))*60 + CONVERT(int,SUBSTRING(p.ctime,4,2)) - c.TimeInMinutes = 0
order by c.idn, p.idn

select * from #ntPeriodsDataFilered


from 
where 
order by idn



-- truncate table ntPeriodsDataCCLOSE

-- insert into ntPeriodsDataCCLOSE (idn, cclose, ABV, ABVMini, TimeInMinutes)
select * --idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes
from ntCalendarIdnData c
left outer join ntPeriodsData p on p.CurrencyId = @pCurrencyId 
  and p.DataSourceId = @pDataSourceId 
  and p.PeriodMinutes = @pPeriodMinutes
  and p.PeriodMultiplicator = @pPeriodMultiplicator
  and p.cdate = c.cdate
  and p.ctime = c.ctime
  
  
  
  (select MIN(ctime) from ntPeriodsData p1 where  p1.CurrencyId = @pCurrencyId 
															and p1.DataSourceId = @pDataSourceId 
															and p1.PeriodMinutes = @pPeriodMinutes
															and p1.PeriodMultiplicator = @pPeriodMultiplicator
  															and p1.cdate = c.cdate
  															and p1.ctime >= c.ctime)



  
  

where CurrencyId = @pCurrencyId 
  and DataSourceId = @pDataSourceId 
  and PeriodMinutes = @pPeriodMinutes -- импортированный период
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin -- задать минимальный множитель периода
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax -- задать минимальный множитель периода
order by ntPeriodsData.idn





select * from ntPeriodsData




idnDataCCLOSE


select *
from ntCalendarIdnData





cdatetimeFromEventdates
01/26/2009 15:00












DECLARE @idnfirst int, @idnlast int

select @idnfirst = isnull(max(idn),0)+1 from ntPeriodsData;

 insert into ntPeriodsData (CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator,
							CDATE, CTIME, CCLOSE, idnNTdata, copen, chigh, clow, 
							Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1)
    select @pCurrencyId, @pDataSourceId, @pPeriodMinutes, @pPeriodMultiplicator,
		   t1.CDATE, t1.CTIME, t1.CCLOSE, t1.idn, 
           t2.copen as copen,
           max(t3.chigh) as chigh,
           min(t3.clow) as clow,
		   sum(t3.Volume), 
		   t1.ABV, 
		   t1.ABVMini, 
		   t1.ABMmPosition0, 
		   t1.ABMmPosition1
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
		   t1.ABMmPosition1
	order by t1.idn

select @idnlast = max(idn) from ntPeriodsData

--insert into ntPeriods (CPERIOD, idn_first, idn_last)
--  select @pperiod as CPERIOD, @idnfirst, @idnlast






------------------------------------------------------------


declare @pCurrencyId int,@pDataSourceId int,@pPeriodMinutes int,@pPeriodMultiplicatorMin int,@pPeriodMultiplicatorMax int
select @pCurrencyId = 1, @pDataSourceId = 2, @pPeriodMinutes = 5, @pPeriodMultiplicatorMin = 1, @pPeriodMultiplicatorMax = 1


-- truncate table ntPeriodsDataCCLOSE

-- insert into ntPeriodsDataCCLOSE (idn, cclose, ABV, ABVMini, TimeInMinutes)
select * --idn, cclose, ABV*0.01, ABVMini*0.01, CONVERT(int,LEFT(ctime,2))*60 + CONVERT(int,SUBSTRING(ctime,4,2)) as TimeInMinutes
from ntPeriodsData
where CurrencyId = @pCurrencyId 
  and DataSourceId = @pDataSourceId 
  and PeriodMinutes = @pPeriodMinutes -- импортированный период
  and PeriodMultiplicator >= @pPeriodMultiplicatorMin -- задать минимальный множитель периода
  and PeriodMultiplicator <= @pPeriodMultiplicatorMax -- задать минимальный множитель периода
order by ntPeriodsData.idn

select * from ntPeriodsDataCCLOSE












-- truncate table ntImportCalendar


-- 2. сохранить файл в формате Excel (т.к. из текстового файла SQL Server не импортирует данный длиной больше 50 символов)
-- Для этого:
-- в Excel: Данные / Импорт внешних данных / Импортировать данные
-- указать разделитель - запятая
-- формат столбцов делать "текст"
-- Из файла Excel удалить все листы кроме нужного.

-- 3. положить файл в каталог
-- E:\forex\MSSQL\eventdates.xls





select * from ntImportCalendar
select * from [dbo].[ntImportCalendar]
-- truncate table ntImportCalendar

select * from ntImportCalendar2


ntImportCalendarcsv
ntImportCalendarxls

ImportCalendarxls

ImportCalendarFromAccess

SELECT * from ntImportEventdates where cName like  'Existing Home Sales (MoM)*' and ccountry = 'United States' order by код
SELECT * from ntImportEventdates where cName like  'Existing Home Sales (MoM)*' and ccountry = 'United States' order by cIdn


