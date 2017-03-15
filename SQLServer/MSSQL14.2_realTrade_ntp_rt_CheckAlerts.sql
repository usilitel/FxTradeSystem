

alter PROCEDURE ntp_rt_CheckAlerts (@activation_ParamsIdentifyer varchar(50), @resultMessage varchar(1000) output)

AS BEGIN 
-- процедура проверяет, выполняются ли условия для заключения сделки по последнему бару 
-- в цикле по таблице nt_rt_parameters_Start запускается процедура ntp_rt_CheckAlerts_single)

-- select * from nt_rt_parameters_Start

SET NOCOUNT ON

	-- переменные выбираемые из курсора
	declare
		@ParamsIdentifyersSetId int, -- id набора ParamsIdentifyer-ов из таблицы nt_rt_parameters_ParamsIdentifyersSets (по которому будет делаться расчет)
		@param_DealTimeInMinutesFirst int, -- время в минутах от 00:00, начиная с которого заключаем сделки
		@param_DealTimeInMinutesLast int,   -- время в минутах от 00:00, заканчивая которым заключаем сделки
		@param_MaxDeltaMinutesCheckAlert int,   -- максимальное время в минутах с момента закрытия бара до проверки условий сделки (-1 = не проверять)
		-- параметры сделок
		@param_cntSignalsBeforeDeal int, -- количество сигналов подряд, нужное для заключения сделки
		@param_IsOnlyOneActiveDeal int, -- 1 = только одна открытая позиция  в одну сторону (максимум один Buy и один Sell одновременно), 0 = неограниченное число открытых позиций (1 сигнал = 1 сделка)
		@param_IsOpenOppositeDeal int, -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу, 0 = закрываем позиции только по SL и TP
		@param_cntBuySignalsLimit_Start int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
		@param_cntSellSignalsLimit_Start int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
		@param_cntBuySignalsLimit_Stop int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
		@param_cntSellSignalsLimit_Stop int -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ

	-- вспомогательные переменные
	declare @TimeInMinutes_current int
	declare @TimeInMinutes_CurrentChart int
	declare @result int
	declare @is_error int
	
	declare @Date_Current varchar(10)
	declare @Date_CurrentChart varchar(10)
	declare @DateTime_CurrentChart varchar(16)
	declare @CurrencyId_current int



	

	-- параметры заключения сделок
	declare
	--@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
	--@param_volume real
	@SignalFileName varchar(500), -- имя сигнального файла
	@PeriodMinutes int,
	@cdatetime_open datetime,
		@SignalFolder varchar(500), -- каталог, в который нужно передавать сигнальные файлы для сделок
		@Symbol varchar(50), -- название Symbol в MetaTrader
		@Period varchar(50),	-- название Period в MetaTrader
		@MaxDeltaMinutesMakeDeal int, -- максимальное время в минутах с момента возникновения сигнала до заключения сделки
		@DealVolume real, -- размер лота
		@DealStopLossPoints int, -- StopLoss в пунктах
		@DealTakeProfitPoints int, -- TakeProfit в пунктах
		@DealOnePoint real, -- размер 1 пункта. Если Null - то берется из таблицы ntSettingsFilesParameters_cn
		@MaxDeltaPointsMakeDeal real, -- максимально допустимое для заключения сделки отклонение цены в сторону прибыли от цены закрытия сигнального бара (в пунктах)
		@Slippage int -- допустимое проскальзывание (в пунктах)

	declare @cmd varchar(500)

	declare @currentDate datetime
	declare @hoursShift int	
	
	
	select @result = 0
	select @resultMessage = ''
	

	select @activation_ParamsIdentifyer = ltrim(rtrim(@activation_ParamsIdentifyer))
	
	select @currentDate = getdate()




	If object_ID('tempdb..#ntImportCurrentChartAverageValues') Is not Null drop table #ntImportCurrentChartAverageValues
	
	
	

	-- берем последнюю запись в таблице ntImportCurrentChartAverageValues с нужным ParamsIdentifyer
	select top 1 *, 
			cdate as cdate_open, ctime as ctime_open, cdatetime as cdatetime_open
	into #ntImportCurrentChartAverageValues
	from ntImportCurrentChartAverageValues
	where ParamsIdentifyer = @activation_ParamsIdentifyer -- '6E_15_120_PA211'
		and TakeProfit_isOk_AtOnce_up_AvgCnt is not null
		and TakeProfit_isOk_AtOnce_down_AvgCnt is not null
		and ChighMax_AtOnce_Avg is not null
		and ClowMin_AtOnce_Avg is not null
	order by cdatetime desc
	
	
	-- запоминаем дату-время сигнального бара
	select  @TimeInMinutes_CurrentChart = left(ctime,2)*60 + right(ctime,2),
			@Date_CurrentChart = cDate,
			@DateTime_CurrentChart = cDateTime
	from #ntImportCurrentChartAverageValues
	
	select @Date_Current = convert(varchar(10),getdate(),102)
	-- select convert(varchar(10),getdate(),102)
	
	--select @DateTime_CurrentChart
	


	-- вычисляем время открытия сигнального бара
	select @PeriodMinutes = PeriodMinutes from ntSettingsFilesParameters_cn where ParamsIdentifyer = @activation_ParamsIdentifyer
	
	--select convert(datetime,cdatetime_open) from #ntImportCurrentChartAverageValues
	select @cdatetime_open = dateadd(mi,-@PeriodMinutes,convert(datetime,replace(cdatetime_open,'.','-'),121))
	from #ntImportCurrentChartAverageValues

	update #ntImportCurrentChartAverageValues
	set cdate_open = convert(varchar(10),@cdatetime_open,102), 
		ctime_open = convert(varchar(5),@cdatetime_open,108), 
		cdatetime_open = replace(convert(varchar(16),@cdatetime_open,121),'-','.')	
	


------------------------------

	-- работаем с календарем
	
	select @CurrencyId_current = CurrencyId_current
	from ntSettingsFilesParameters_cn
	where ParamsIdentifyer = @activation_ParamsIdentifyer
	
	If object_ID('tempdb..#nt_rt_CalendarIdnData') Is not Null drop table #nt_rt_CalendarIdnData
	
	-- выбираем события экономического календаря за сегодняшний день
	select * 
	into #nt_rt_CalendarIdnData
	from nt_rt_CalendarIdnData
	where cdate = @Date_Current -- '2016.07.11'

	select @is_error = 0
	
	-- определяем, загружены ли события экономического календаря за сегодняшний день
	if (select count(*) from #nt_rt_CalendarIdnData) = 0
		select @is_error = 1	


	if @is_error = 1 
	begin
		insert into nt_rt_log (log_message, cdatetime_log)
		select @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': за текущую дату нет записей в экономическом календаре (nt_rt_CalendarIdnData)', getdate()
		select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': за текущую дату нет записей в экономическом календаре (nt_rt_CalendarIdnData)' + ']'
	end
	if @is_error = 1 
		GOTO exit_proc
		
		
		
	-- определяем, есть ли за сегодняшний день "запрещенные" события экономического календаря
	if (select count(*)
		from #nt_rt_CalendarIdnData c
		left outer join nt_rt_CalendarActive ca on -- неактивные новости за день сделки
				ca.CurrencyId = @CurrencyId_current
			and ca.cName = c.cName
			and ca.cCountry = c.cCountry
			and ((ca.cVolatility = c.cVolatility) or (ca.cVolatility = -1))
			and ca.isActive = 0
		where ca.isActive = 0
		) > 0
		select @is_error = 1
	
	if @is_error = 1 
		insert into nt_rt_log (log_message, cdatetime_log)
		select @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': за текущую дату есть "запрещенные" события экономического календаря', getdate()
	if @is_error = 1 
		GOTO exit_proc
	
	-- select * from nt_rt_CalendarActive order by CurrencyId, cName
	-- select * from nt_rt_CalendarIdnData where cName = 'ECB Interest Rate Decision'

------------------------------


-- SELECT * from nt_rt_parameters_Start
	
	-- делаем курсор по параметрам расчета сделок
	DECLARE cParamsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
	SELECT  ParamsIdentifyersSetId,  param_DealTimeInMinutesFirst,  param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert,  param_cntSignalsBeforeDeal,  param_IsOnlyOneActiveDeal,  param_IsOpenOppositeDeal,  param_cntBuySignalsLimit_Start,  param_cntSellSignalsLimit_Start,  param_cntBuySignalsLimit_Stop,  param_cntSellSignalsLimit_Stop 
	from nt_rt_parameters_Start
	where activation_ParamsIdentifyer = @activation_ParamsIdentifyer -- ParamsIdentifyer, который активирует проверку условий сделки
		and is_active = 1
	order by ParamsIdentifyersSetId
	
	OPEN cParamsCursor

	-- запоминаем параметры расчета сделок
	FETCH NEXT FROM cParamsCursor 
	INTO @ParamsIdentifyersSetId, @param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast, @param_MaxDeltaMinutesCheckAlert, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop
	WHILE @@FETCH_STATUS = 0
	BEGIN

		
		--select @ParamsIdentifyersSetId, @param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop
		--select @param_MaxDeltaMinutesCheckAlert
		
		select @TimeInMinutes_current = datepart(hh,getdate())*60 + datepart(mi,getdate())
		
		
		
		
		select @is_error = 1	
		
		-- 1. проверяем, чтобы текущее время попадало в заданный расчетный промежуток
		if ((@TimeInMinutes_current >= @param_DealTimeInMinutesFirst) and (@TimeInMinutes_current <= @param_DealTimeInMinutesLast))
			select @is_error = 0
		
		--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': текущее время не попадает в заданный расчетный промежуток', getdate()
		
--insert into nt_rt_log (log_message, cdatetime_log) select '1;' + convert(varchar,@is_error), getdate()
					
		if @is_error = 1 
			insert into nt_rt_log (log_message, cdatetime_log)
			select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': текущее время не попадает в заданный расчетный промежуток', getdate()
		if @is_error = 1 
			GOTO exit_step
		
		
		
		
		--if ((@TimeInMinutes_current >= @param_DealTimeInMinutesFirst) and (@TimeInMinutes_current <= @param_DealTimeInMinutesLast))
		begin
			-- 2. проверяем, чтобы последняя запись в таблице ntImportCurrentChartAverageValues с нужным ParamsIdentifyer была создана недавно
			 ----------------------- !!!!!!!!!!!!!!!!! вернуть проверку при реальном запуске !!!!!!!!!!!!!!!!!

			select @is_error = 1	
			
			if ((@TimeInMinutes_current >= @TimeInMinutes_CurrentChart) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- время сейчас больше, чем у сигнального бара
				select @is_error = 0
			
--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': время сейчас меньше, чем у сигнального бара', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '2;' + convert(varchar,@is_error), getdate()			

			if @is_error = 1 
			begin
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': время сейчас меньше, чем у сигнального бара', getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': время сейчас меньше, чем у сигнального бара' + ']'
			end
			if @is_error = 1 
				GOTO exit_step
			
			
			
			select @is_error = 1	
			
			if (((@TimeInMinutes_current - @TimeInMinutes_CurrentChart)<@param_MaxDeltaMinutesCheckAlert) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- со времени окончания бара прошло не более 2-х минут
				select @is_error = 0

--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': со времени окончания бара прошло более ' + convert(varchar,@param_MaxDeltaMinutesCheckAlert) + ' минут', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '3;' + convert(varchar,@is_error) + ';' + convert(varchar,@TimeInMinutes_current) + ';' + convert(varchar,@TimeInMinutes_CurrentChart) + ';' + convert(varchar,@param_MaxDeltaMinutesCheckAlert), getdate()
			
			if @is_error = 1 
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': со времени окончания бара прошло более ' + convert(varchar,@param_MaxDeltaMinutesCheckAlert) + ' минут', getdate()
			if @is_error = 1 
				GOTO exit_step
			
			
			select @is_error = 1	
			
			if ((@Date_Current = @Date_CurrentChart) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- сейчас та же дата, что и у сигнального бара
				select @is_error = 0
			
--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сейчас не та же дата, что у сигнального бара (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '4;' + convert(varchar,@is_error), getdate()

			if @is_error = 1 
			begin
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сейчас не та же дата, что у сигнального бара (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')', getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сейчас не та же дата, что у сигнального бара (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')' + ']'
			end
			if @is_error = 1 
				GOTO exit_step



			 

			--if (((@TimeInMinutes_current >= @TimeInMinutes_CurrentChart) and ((@TimeInMinutes_current - @TimeInMinutes_CurrentChart)<=@param_MaxDeltaMinutesCheckAlert)) -- со времени окончания бара прошло не более 2-х минут
			--	and (@Date_Current = @Date_CurrentChart) -- сейчас та же дата, что и у сигнального бара
			--	)
			begin
				-- проверяем, выполняются ли условия для заключения сделки
				exec ntp_rt_CheckAlerts_single @activation_ParamsIdentifyer, @ParamsIdentifyersSetId, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop, @result output
				--select @result



			insert into nt_rt_log (log_message, cdatetime_log)
			select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': result = ' + convert(varchar,@result), getdate()

			-------------------------------------------
			-- если получен сигнал на сделку - то запускаем сигнал в MetaTrader

			if @result <> 0
			begin

--insert into nt_rt_log (log_message, cdatetime_log) select '5', getdate()			

				--insert into nt_rt_log (log_message, cdatetime_log)
				--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': получен сигнал ' + convert(varchar,@result), getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': result = ' + convert(varchar,@result) + ']'
				
			    
				-- делаем курсор по параметрам расчета сделок
				DECLARE cSignalFoldersCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
				SELECT SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage
				from nt_rt_SignalFolders
				where activation_ParamsIdentifyer = @activation_ParamsIdentifyer -- ParamsIdentifyer, который активирует проверку условий сделки
					and ParamsIdentifyersSetId = @ParamsIdentifyersSetId
					and is_active = 1
				order by SignalFolder
				
				OPEN cSignalFoldersCursor

				-- запоминаем параметры расчета сделок
				FETCH NEXT FROM cSignalFoldersCursor 
				INTO @SignalFolder, @Symbol, @Period, @MaxDeltaMinutesMakeDeal, @DealVolume, @DealStopLossPoints, @DealTakeProfitPoints, @DealOnePoint, @MaxDeltaPointsMakeDeal, @Slippage
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--select @DealOnePoint
					
					if @DealOnePoint is null
						select @DealOnePoint = OnePoint
						from ntSettingsFilesParameters_cn
						where ParamsIdentifyer = @activation_ParamsIdentifyer
					

					-- select @currentDate = getdate()
					-- select @currentDate = convert(datetime,'2016/06/01',111)
					-- select @currentDate

					-- определяем сдвиг времени между местным временем и временем МТ
					select @hoursShift = 
						   case when ((@currentDate > convert(datetime,'2016/10/30',111)) and (@currentDate <= convert(datetime,'2017/03/26',111))) then -1 
								when ((@currentDate > convert(datetime,'2017/10/29',111)) and (@currentDate <= convert(datetime,'2018/03/25',111))) then -1 
								when ((@currentDate > convert(datetime,'2018/10/28',111)) and (@currentDate <= convert(datetime,'2019/03/31',111))) then -1 
								when ((@currentDate > convert(datetime,'2019/10/27',111)) and (@currentDate <= convert(datetime,'2020/03/29',111))) then -1 
								when ((@currentDate > convert(datetime,'2020/10/25',111)) and (@currentDate <= convert(datetime,'2021/03/28',111))) then -1 
								when ((@currentDate > convert(datetime,'2021/10/31',111)) and (@currentDate <= convert(datetime,'2022/03/27',111))) then -1 
								when ((@currentDate > convert(datetime,'2022/10/30',111)) and (@currentDate <= convert(datetime,'2023/03/26',111))) then -1 
								when ((@currentDate > convert(datetime,'2023/10/29',111)) and (@currentDate <= convert(datetime,'2024/03/31',111))) then -1 
								when ((@currentDate > convert(datetime,'2024/10/27',111)) and (@currentDate <= convert(datetime,'2025/03/30',111))) then -1 
								when ((@currentDate > convert(datetime,'2025/10/26',111)) and (@currentDate <= convert(datetime,'2026/03/29',111))) then -1 			
						else 0 end

					-- select @hoursShift
					

					-- формируем имя сигнального файла
					select @SignalFileName = @Symbol + ';' + 
											@Period + ';' +											
											cdate + ';' + 
											-- left(ctime,2) + ';' + 
											convert(varchar,convert(int,left(ctime,2))+@hoursShift) + ';' + 
											right(ctime,2) + ';' + 
											cdate_open + ';' + 
											--left(ctime_open,2) + ';' + 
											convert(varchar,convert(int,left(ctime_open,2))+@hoursShift) + ';' + 
											right(ctime_open,2) + ';' + 
											convert(varchar,@MaxDeltaMinutesMakeDeal) + ';' +
											convert(varchar,@result) + ';' +
											convert(varchar,@DealVolume) + ';' +
											convert(varchar,@DealStopLossPoints) + ';' + 
											convert(varchar,@DealTakeProfitPoints) + ';' +
											convert(varchar,@MaxDeltaPointsMakeDeal) + ';' + 
											convert(varchar,@DealOnePoint) + ';' + 
											convert(varchar,@Slippage) + ';' + 
											@activation_ParamsIdentifyer + ';' + 
											convert(varchar,@ParamsIdentifyersSetId) + ';.txt'
					from #ntImportCurrentChartAverageValues
					
					



					-- создаем сигнальный файл		
					-- вариант 1: сразу создаем файл		
					select @cmd = 'echo on>>' + @SignalFolder + '\"' + @SignalFileName + '"'
					EXEC master..xp_cmdshell @cmd, NO_OUTPUT

--insert into nt_rt_log (log_message, cdatetime_log) select '6', getdate()

					insert into nt_rt_log (log_message, cdatetime_log)
					select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сформирован файл ' + @SignalFolder + '\"' + @SignalFileName + '"', getdate()
					select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': сформирован файл ' + @SignalFileName + ']'
				
					
/*
					-- вариант 2: сначала создаем временный файл, потом его переименовываем
					select @cmd = 'echo on>>' + @SignalFolder + '\"tmp_' + @SignalFileName + '"'
					EXEC master..xp_cmdshell @cmd, NO_OUTPUT
					select @cmd = 'rename ' + @SignalFolder + '\"tmp_' + @SignalFileName + '" "' + @SignalFileName + '"'
					EXEC master..xp_cmdshell @cmd, NO_OUTPUT
*/



				FETCH NEXT FROM cSignalFoldersCursor 
				INTO @SignalFolder, @Symbol, @Period, @MaxDeltaMinutesMakeDeal, @DealVolume, @DealStopLossPoints, @DealTakeProfitPoints, @DealOnePoint, @MaxDeltaPointsMakeDeal, @Slippage
				END 
				--exit_cursor:
				CLOSE cSignalFoldersCursor;
				DEALLOCATE cSignalFoldersCursor;			
			end
	

			-------------------------------------------



			end
			
		end
		
		
exit_step:
		
	FETCH NEXT FROM cParamsCursor 
	INTO @ParamsIdentifyersSetId, @param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast, @param_MaxDeltaMinutesCheckAlert, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop
	END 
	--exit_cursor:
	CLOSE cParamsCursor;
	DEALLOCATE cParamsCursor;
	
exit_proc:

END

-- go
-- exec ntp_rt_CheckAlerts @activation_ParamsIdentifyer = '6E_15_120_PA211'
 

/*	
select * from nt_rt_parameters_ParamsIdentifyersSets
update nt_rt_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.498, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.498, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.298, limit_TakeProfit_isOk_Daily_up_AvgCnt = 0.498, limit_TakeProfit_isOk_Daily_down_AvgCnt = 0.498, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.298
update nt_rt_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.41, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.41, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.1, limit_TakeProfit_isOk_Daily_up_AvgCnt = 0.1, limit_TakeProfit_isOk_Daily_down_AvgCnt = 0.1, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.1

*/


