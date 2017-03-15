
111 -- не удалять, нужно на случай случайного запуска

-----------------


	SELECT * -- ParamsIdentifyersSetId,  param_DealTimeInMinutesFirst,  param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert,  param_cntSignalsBeforeDeal,  param_IsOnlyOneActiveDeal,  param_IsOpenOppositeDeal,  param_cntBuySignalsLimit_Start,  param_cntSellSignalsLimit_Start,  param_cntBuySignalsLimit_Stop,  param_cntSellSignalsLimit_Stop 
	from nt_rt_parameters_Start
	where activation_ParamsIdentifyer = '6E_15_120_PA211' -- ParamsIdentifyer, который активирует проверку условий сделки
		and is_active = 1
	order by ParamsIdentifyersSetId
	
	

-- настроечные таблицы для реальной торговли
select * from nt_rt_parameters_Start -- настроечная таблица с параметрами для realTrade
select * from nt_rt_SignalFolders -- таблица с каталогами, в которые нужно передавать сигнальные файлы для сделок (и с параметрами сделок)
select * from nt_rt_parameters_ParamsIdentifyersSets -- настроечная таблица с наборами ParamsIdentifyer-ов для realTrade

select * from nt_rt_log order by idn desc -- лог для realTrade 
------------------
6E_15_120_P211_2d;13;2016.12.01 13:35: сформирован файл C:\Users\user1\AppData\Roaming\MetaQuotes\Terminal\1FC724C8C211BFE8ECF8B599A855301E\MQL4\Files\signals\"EURUSD;PERIOD_M5;2016.12.01;13;35;2016.12.01;13;30;2;1;0.01;30;15;5;0.0001;3;6E_15_120_P211_2d;13;.txt"
6E_15_120_P211_2d;13;2016.12.01 13:35: сформирован файл C:\Users\user1\AppData\Roaming\MetaQuotes\Terminal\1FC724C8C211BFE8ECF8B599A855301E\MQL4\Files\signals\

					select @cmd = 'echo on>>C:\Users\user1\AppData\Roaming\MetaQuotes\Terminal\1FC724C8C211BFE8ECF8B599A855301E\MQL4\Files\signals\"EURUSD;PERIOD_M5;2016.12.01;13;35;2016.12.01;13;30;2;1;0.01;30;15;5;0.0001;3;6E_15_120_P211_2d;13;.txt"'
					EXEC master..xp_cmdshell 'echo on>>C:\Users\user1\AppData\Roaming\MetaQuotes\Terminal\1FC724C8C211BFE8ECF8B599A855301E\MQL4\Files\signals\"EURUSD;PERIOD_M5;2016.12.01;13;35;2016.12.01;13;30;2;1;0.01;30;15;5;0.0001;3;6E_15_120_P211_2d;13;.txt"', NO_OUTPUT

--insert into nt_rt_log (log_message, cdatetime_log) select '6', getdate()

					insert into nt_rt_log (log_message, cdatetime_log)
					select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сформирован файл ' + @SignalFolder + '\"' + @SignalFileName + '"', getdate()
					select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сформирован файл ' + @SignalFileName + ']'
					
					
------------------

select * from nt_rt_CalendarActive
select * from nt_rt_CalendarIdnData where cdate = '2016.08.02'


select * from nt_rt_CalendarIdnData -- загруженные события экономического календаря (для realTrade)
select * from nt_rt_CalendarActive -- таблица для определения новостей, которые можно/нельзя использовать при торговле (для realTrade)

update nt_rt_parameters_Start set is_active = 0 where ParamsIdentifyersSetId = 3 -- тестовые условия сделок (всегда sell)
update nt_rt_parameters_Start set is_active = 0 where ParamsIdentifyersSetId = 7 -- реальные условия сделок
update nt_rt_parameters_Start set is_active = 0 where ParamsIdentifyersSetId = 8 -- реальные условия сделок
update nt_rt_parameters_Start set is_active = 1 where ParamsIdentifyersSetId in (11,12,13,14) -- реальные условия сделок




update nt_rt_SignalFolders set DealVolume = 0.01 where ParamsIdentifyersSetId = 3 -- тестовые условия сделок (всегда sell)
update nt_rt_SignalFolders set DealVolume = 0.01 where ParamsIdentifyersSetId = 7 -- реальные условия сделок
update nt_rt_SignalFolders set DealVolume = 0.01 where ParamsIdentifyersSetId = 8 -- реальные условия сделок



-------------------------

-- даты с "запрещенными" событиями календаря
select *
		from nt_rt_CalendarIdnData c
		left outer join nt_rt_CalendarActive ca on -- неактивные новости за день сделки
				ca.CurrencyId = 1
			and ca.cName = c.cName
			and ca.cCountry = c.cCountry
			and ((ca.cVolatility = c.cVolatility) or (ca.cVolatility = -1))
			and ca.isActive = 0
		where ca.isActive = 0
order by cdatetime

-------------------

update nt_rt_parameters_Start set param_DealTimeInMinutesFirst = 1 where ParamsIdentifyersSetId = 3
update nt_rt_parameters_Start set param_DealTimeInMinutesFirst = 690 where ParamsIdentifyersSetId = 7


update nt_rt_parameters_Start set param_MaxDeltaMinutesCheckAlert = 2

select * from nt_rt_parameters_ParamsIdentifyersSets

--------------------------------------------
-- добавляем новый ParamsIdentifyersSetId
insert into nt_rt_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
select 8 as ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
from nt_rt_parameters_ParamsIdentifyersSets
where ParamsIdentifyersSetId = 7

insert into nt_rt_parameters_Start (activation_ParamsIdentifyer, ParamsIdentifyersSetId, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert, param_cntSignalsBeforeDeal, param_IsOnlyOneActiveDeal, param_IsOpenOppositeDeal, param_cntBuySignalsLimit_Start, param_cntSellSignalsLimit_Start, param_cntBuySignalsLimit_Stop, param_cntSellSignalsLimit_Stop, is_active)
select activation_ParamsIdentifyer, 8 as ParamsIdentifyersSetId, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert, param_cntSignalsBeforeDeal, param_IsOnlyOneActiveDeal, param_IsOpenOppositeDeal, param_cntBuySignalsLimit_Start, param_cntSellSignalsLimit_Start, param_cntBuySignalsLimit_Stop, param_cntSellSignalsLimit_Stop, is_active
from nt_rt_parameters_Start
where ParamsIdentifyersSetId = 7

insert into nt_rt_SignalFolders (activation_ParamsIdentifyer, ParamsIdentifyersSetId, SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage, is_active)
select activation_ParamsIdentifyer, 8 as ParamsIdentifyersSetId, SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage, is_active
from nt_rt_SignalFolders
where ParamsIdentifyersSetId = 7
--------------------------------------------
-- добавляем новый ParamsIdentifyersSetId
insert into nt_rt_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
select 14 as ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
from nt_rt_parameters_ParamsIdentifyersSets
where ParamsIdentifyersSetId = 7 and ParamsIdentifyer = '6E_15_120_PA211'

insert into nt_rt_parameters_Start (activation_ParamsIdentifyer, ParamsIdentifyersSetId, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert, param_cntSignalsBeforeDeal, param_IsOnlyOneActiveDeal, param_IsOpenOppositeDeal, param_cntBuySignalsLimit_Start, param_cntSellSignalsLimit_Start, param_cntBuySignalsLimit_Stop, param_cntSellSignalsLimit_Stop, is_active)
select activation_ParamsIdentifyer, 14 as ParamsIdentifyersSetId, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert, param_cntSignalsBeforeDeal, param_IsOnlyOneActiveDeal, param_IsOpenOppositeDeal, param_cntBuySignalsLimit_Start, param_cntSellSignalsLimit_Start, param_cntBuySignalsLimit_Stop, param_cntSellSignalsLimit_Stop, is_active
from nt_rt_parameters_Start
where ParamsIdentifyersSetId = 7

insert into nt_rt_SignalFolders (activation_ParamsIdentifyer, ParamsIdentifyersSetId, SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage, is_active, comment)
select activation_ParamsIdentifyer, 14 as ParamsIdentifyersSetId, SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage, is_active, comment
from nt_rt_SignalFolders
where ParamsIdentifyersSetId = 7


-----
-- проверяем/исправляем параметры
select * from nt_rt_parameters_Start -- настроечная таблица с параметрами для realTrade
select * from nt_rt_SignalFolders -- таблица с каталогами, в которые нужно передавать сигнальные файлы для сделок (и с параметрами сделок)
select * from nt_rt_parameters_ParamsIdentifyersSets -- настроечная таблица с наборами ParamsIdentifyer-ов для realTrade

update nt_rt_parameters_Start set param_cntBuySignalsLimit_Start = 1, param_cntSellSignalsLimit_Start = 1 where ParamsIdentifyersSetId in (11,12,13,14) -- реальные условия сделок
update nt_rt_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.2 where ParamsIdentifyersSetId in (11,12,13,14) -- реальные условия сделок
update nt_rt_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.2 where ParamsIdentifyersSetId in (11,12,13,14) -- реальные условия сделок
update nt_rt_parameters_ParamsIdentifyersSets set limit_ChighMax_AtOnce_Avg = 12, limit_ClowMin_AtOnce_Avg = 12, limit_ChighMax_ClowMin_AtOnce_Avg_delta = 25 where ParamsIdentifyersSetId in (11,12,13,14) -- реальные условия сделок

update nt_rt_parameters_ParamsIdentifyersSets set ParamsIdentifyer = '6E_15_120_PA211' where ParamsIdentifyersSetId = 11
update nt_rt_parameters_ParamsIdentifyersSets set ParamsIdentifyer = '6E_15_120_P211' where ParamsIdentifyersSetId = 12
update nt_rt_parameters_ParamsIdentifyersSets set ParamsIdentifyer = '6E_15_120_P211_2d' where ParamsIdentifyersSetId = 13
update nt_rt_parameters_ParamsIdentifyersSets set ParamsIdentifyer = '6E_15_120_PA211_MA5' where ParamsIdentifyersSetId = 14

update nt_rt_parameters_Start set activation_ParamsIdentifyer = '6E_15_120_PA211' where ParamsIdentifyersSetId = 11
update nt_rt_parameters_Start set activation_ParamsIdentifyer = '6E_15_120_P211' where ParamsIdentifyersSetId = 12
update nt_rt_parameters_Start set activation_ParamsIdentifyer = '6E_15_120_P211_2d' where ParamsIdentifyersSetId = 13
update nt_rt_parameters_Start set activation_ParamsIdentifyer = '6E_15_120_PA211_MA5' where ParamsIdentifyersSetId = 14

update nt_rt_SignalFolders set activation_ParamsIdentifyer = '6E_15_120_PA211' where ParamsIdentifyersSetId = 11
update nt_rt_SignalFolders set activation_ParamsIdentifyer = '6E_15_120_P211' where ParamsIdentifyersSetId = 12
update nt_rt_SignalFolders set activation_ParamsIdentifyer = '6E_15_120_P211_2d' where ParamsIdentifyersSetId = 13
update nt_rt_SignalFolders set activation_ParamsIdentifyer = '6E_15_120_PA211_MA5' where ParamsIdentifyersSetId = 14



--------------------------------------------







-- для реальной торговли
update nt_rt_parameters_ParamsIdentifyersSets 
set limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.498, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.498, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.298, limit_TakeProfit_isOk_Daily_up_AvgCnt = 0.498, limit_TakeProfit_isOk_Daily_down_AvgCnt = 0.498, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.298
where ParamsIdentifyersSetId = 7

-- для тестовой торговли
update nt_rt_parameters_ParamsIdentifyersSets 
set limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.41, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.41, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.1, limit_TakeProfit_isOk_Daily_up_AvgCnt = 0.1, limit_TakeProfit_isOk_Daily_down_AvgCnt = 0.1, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.1
where ParamsIdentifyersSetId = 7

-- для тестовой торговли
update nt_rt_parameters_ParamsIdentifyersSets 
set limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.99, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.2, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = -0.99, limit_TakeProfit_isOk_Daily_up_AvgCnt = 0.99, limit_TakeProfit_isOk_Daily_down_AvgCnt = 0.2, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = -0.99
where ParamsIdentifyersSetId = 3




-- задаем максимальное время в минутах с момента закрытия бара до проверки условий сделки
update nt_rt_parameters_Start set param_MaxDeltaMinutesCheckAlert = 2 -- для реальной торговли
update nt_rt_parameters_Start set param_MaxDeltaMinutesCheckAlert = -1 -- для тестирования








select * from ntSettingsFilesParameters_cn





-- разрешаем запуск xp_cmdshell

sp_configure 'allow updates', 0;
GO
RECONFIGURE;
GO

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO



select getdate()

DECLARE @cmd sysname, @var sysname
SET @var = '1'
SET @cmd = 'echo ' + @var + ' >> G:\forex\Access\temp\222.txt'
EXEC master..xp_cmdshell @cmd

select getdate()

select getdate()
EXEC master..xp_cmdshell  'rename G:\forex\Access\temp\7.txt 6.txt', NO_OUTPUT
select getdate()

select getdate()
EXEC master..xp_cmdshell  'move G:\forex\Access\temp\7.txt G:\forex\Access\temp\6.txt', NO_OUTPUT
select getdate()

select getdate()
EXEC master..xp_cmdshell  'echo on>>G:\forex\Access\temp\2.txt', NO_OUTPUT
select getdate()

select getdate()
EXEC master..xp_cmdshell  'echo on>>G:\forex\Access\temp\1.txt', NO_OUTPUT
select getdate()
EXEC master..xp_cmdshell  'rename G:\forex\Access\temp\1.txt 2.txt', NO_OUTPUT
select getdate()

select convert(varchar,getdate(),104) -- Только дата
, convert(varchar,getdate(),104) +' '+ convert(char(5),getdate(),108) -- Дата + часы + минуты
, convert(varchar,getdate(),104) +' '+ convert(varchar,getdate(),108) -- Дата + часы + минуты + секунды
, convert(varchar,getdate(),104) +' '+ stuff(convert(char(12),getdate(),114), 9, 1, '.') -- С миллисекундами

select convert(varchar,getdate(),101)

select CONVERT(char(13),getdate(),120)
select CONVERT(char(10),getdate(),120)
select CONVERT(char(7),getdate(),120)
select CONVERT(char(4),getdate(),120)

select CONVERT(varchar,getdate(),120)

select CONVERT(varchar,getdate(),121)

SELECT dbo.fnFormatDate (getdate(), 'YYYYMMDD')             – 20120103

select CONVERT(datetime,'2016-07-09 12:55',121)




select * from nt_rt_parameters_Start
select * from nt_rt_parameters_ParamsIdentifyersSets


select * from ntImportCurrentChartAverageValues
where 1=1
	and ParamsIdentifyer = '6E_15_120_PA211_v02'
	--and ParamsIdentifyer like '6E_%_PA211'
	--and cdatetime = '2016.06.28 10:50'
order by cdatetime

EURUSD.m;PERIOD_M5;2016.07.08;21.00;2;1;0.01;15;30;6E_15_120_PA211.txt

