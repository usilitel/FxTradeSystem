

alter PROCEDURE ntp_rt_CheckAlerts (@activation_ParamsIdentifyer varchar(50), @resultMessage varchar(1000) output)

AS BEGIN 
-- ��������� ���������, ����������� �� ������� ��� ���������� ������ �� ���������� ���� 
-- � ����� �� ������� nt_rt_parameters_Start ����������� ��������� ntp_rt_CheckAlerts_single)

-- select * from nt_rt_parameters_Start

SET NOCOUNT ON

	-- ���������� ���������� �� �������
	declare
		@ParamsIdentifyersSetId int, -- id ������ ParamsIdentifyer-�� �� ������� nt_rt_parameters_ParamsIdentifyersSets (�� �������� ����� �������� ������)
		@param_DealTimeInMinutesFirst int, -- ����� � ������� �� 00:00, ������� � �������� ��������� ������
		@param_DealTimeInMinutesLast int,   -- ����� � ������� �� 00:00, ���������� ������� ��������� ������
		@param_MaxDeltaMinutesCheckAlert int,   -- ������������ ����� � ������� � ������� �������� ���� �� �������� ������� ������ (-1 = �� ���������)
		-- ��������� ������
		@param_cntSignalsBeforeDeal int, -- ���������� �������� ������, ������ ��� ���������� ������
		@param_IsOnlyOneActiveDeal int, -- 1 = ������ ���� �������� �������  � ���� ������� (�������� ���� Buy � ���� Sell ������������), 0 = �������������� ����� �������� ������� (1 ������ = 1 ������)
		@param_IsOpenOppositeDeal int, -- 1 = ���� ��������� ��������������� ������ - �� ��������� ��� �������� ������� � ��������� ������� �� �������, 0 = ��������� ������� ������ �� SL � TP
		@param_cntBuySignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntSellSignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntBuySignalsLimit_Stop int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
		@param_cntSellSignalsLimit_Stop int -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������

	-- ��������������� ����������
	declare @TimeInMinutes_current int
	declare @TimeInMinutes_CurrentChart int
	declare @result int
	declare @is_error int
	
	declare @Date_Current varchar(10)
	declare @Date_CurrentChart varchar(10)
	declare @DateTime_CurrentChart varchar(16)
	declare @CurrencyId_current int



	

	-- ��������� ���������� ������
	declare
	--@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
	--@param_volume real
	@SignalFileName varchar(500), -- ��� ����������� �����
	@PeriodMinutes int,
	@cdatetime_open datetime,
		@SignalFolder varchar(500), -- �������, � ������� ����� ���������� ���������� ����� ��� ������
		@Symbol varchar(50), -- �������� Symbol � MetaTrader
		@Period varchar(50),	-- �������� Period � MetaTrader
		@MaxDeltaMinutesMakeDeal int, -- ������������ ����� � ������� � ������� ������������� ������� �� ���������� ������
		@DealVolume real, -- ������ ����
		@DealStopLossPoints int, -- StopLoss � �������
		@DealTakeProfitPoints int, -- TakeProfit � �������
		@DealOnePoint real, -- ������ 1 ������. ���� Null - �� ������� �� ������� ntSettingsFilesParameters_cn
		@MaxDeltaPointsMakeDeal real, -- ����������� ���������� ��� ���������� ������ ���������� ���� � ������� ������� �� ���� �������� ����������� ���� (� �������)
		@Slippage int -- ���������� ��������������� (� �������)

	declare @cmd varchar(500)

	declare @currentDate datetime
	declare @hoursShift int	
	
	
	select @result = 0
	select @resultMessage = ''
	

	select @activation_ParamsIdentifyer = ltrim(rtrim(@activation_ParamsIdentifyer))
	
	select @currentDate = getdate()




	If object_ID('tempdb..#ntImportCurrentChartAverageValues') Is not Null drop table #ntImportCurrentChartAverageValues
	
	
	

	-- ����� ��������� ������ � ������� ntImportCurrentChartAverageValues � ������ ParamsIdentifyer
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
	
	
	-- ���������� ����-����� ����������� ����
	select  @TimeInMinutes_CurrentChart = left(ctime,2)*60 + right(ctime,2),
			@Date_CurrentChart = cDate,
			@DateTime_CurrentChart = cDateTime
	from #ntImportCurrentChartAverageValues
	
	select @Date_Current = convert(varchar(10),getdate(),102)
	-- select convert(varchar(10),getdate(),102)
	
	--select @DateTime_CurrentChart
	


	-- ��������� ����� �������� ����������� ����
	select @PeriodMinutes = PeriodMinutes from ntSettingsFilesParameters_cn where ParamsIdentifyer = @activation_ParamsIdentifyer
	
	--select convert(datetime,cdatetime_open) from #ntImportCurrentChartAverageValues
	select @cdatetime_open = dateadd(mi,-@PeriodMinutes,convert(datetime,replace(cdatetime_open,'.','-'),121))
	from #ntImportCurrentChartAverageValues

	update #ntImportCurrentChartAverageValues
	set cdate_open = convert(varchar(10),@cdatetime_open,102), 
		ctime_open = convert(varchar(5),@cdatetime_open,108), 
		cdatetime_open = replace(convert(varchar(16),@cdatetime_open,121),'-','.')	
	


------------------------------

	-- �������� � ����������
	
	select @CurrencyId_current = CurrencyId_current
	from ntSettingsFilesParameters_cn
	where ParamsIdentifyer = @activation_ParamsIdentifyer
	
	If object_ID('tempdb..#nt_rt_CalendarIdnData') Is not Null drop table #nt_rt_CalendarIdnData
	
	-- �������� ������� �������������� ��������� �� ����������� ����
	select * 
	into #nt_rt_CalendarIdnData
	from nt_rt_CalendarIdnData
	where cdate = @Date_Current -- '2016.07.11'

	select @is_error = 0
	
	-- ����������, ��������� �� ������� �������������� ��������� �� ����������� ����
	if (select count(*) from #nt_rt_CalendarIdnData) = 0
		select @is_error = 1	


	if @is_error = 1 
	begin
		insert into nt_rt_log (log_message, cdatetime_log)
		select @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': �� ������� ���� ��� ������� � ������������� ��������� (nt_rt_CalendarIdnData)', getdate()
		select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': �� ������� ���� ��� ������� � ������������� ��������� (nt_rt_CalendarIdnData)' + ']'
	end
	if @is_error = 1 
		GOTO exit_proc
		
		
		
	-- ����������, ���� �� �� ����������� ���� "�����������" ������� �������������� ���������
	if (select count(*)
		from #nt_rt_CalendarIdnData c
		left outer join nt_rt_CalendarActive ca on -- ���������� ������� �� ���� ������
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
		select @activation_ParamsIdentifyer + ';' + @DateTime_CurrentChart + ': �� ������� ���� ���� "�����������" ������� �������������� ���������', getdate()
	if @is_error = 1 
		GOTO exit_proc
	
	-- select * from nt_rt_CalendarActive order by CurrencyId, cName
	-- select * from nt_rt_CalendarIdnData where cName = 'ECB Interest Rate Decision'

------------------------------


-- SELECT * from nt_rt_parameters_Start
	
	-- ������ ������ �� ���������� ������� ������
	DECLARE cParamsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
	SELECT  ParamsIdentifyersSetId,  param_DealTimeInMinutesFirst,  param_DealTimeInMinutesLast, param_MaxDeltaMinutesCheckAlert,  param_cntSignalsBeforeDeal,  param_IsOnlyOneActiveDeal,  param_IsOpenOppositeDeal,  param_cntBuySignalsLimit_Start,  param_cntSellSignalsLimit_Start,  param_cntBuySignalsLimit_Stop,  param_cntSellSignalsLimit_Stop 
	from nt_rt_parameters_Start
	where activation_ParamsIdentifyer = @activation_ParamsIdentifyer -- ParamsIdentifyer, ������� ���������� �������� ������� ������
		and is_active = 1
	order by ParamsIdentifyersSetId
	
	OPEN cParamsCursor

	-- ���������� ��������� ������� ������
	FETCH NEXT FROM cParamsCursor 
	INTO @ParamsIdentifyersSetId, @param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast, @param_MaxDeltaMinutesCheckAlert, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop
	WHILE @@FETCH_STATUS = 0
	BEGIN

		
		--select @ParamsIdentifyersSetId, @param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop
		--select @param_MaxDeltaMinutesCheckAlert
		
		select @TimeInMinutes_current = datepart(hh,getdate())*60 + datepart(mi,getdate())
		
		
		
		
		select @is_error = 1	
		
		-- 1. ���������, ����� ������� ����� �������� � �������� ��������� ����������
		if ((@TimeInMinutes_current >= @param_DealTimeInMinutesFirst) and (@TimeInMinutes_current <= @param_DealTimeInMinutesLast))
			select @is_error = 0
		
		--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������� ����� �� �������� � �������� ��������� ����������', getdate()
		
--insert into nt_rt_log (log_message, cdatetime_log) select '1;' + convert(varchar,@is_error), getdate()
					
		if @is_error = 1 
			insert into nt_rt_log (log_message, cdatetime_log)
			select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������� ����� �� �������� � �������� ��������� ����������', getdate()
		if @is_error = 1 
			GOTO exit_step
		
		
		
		
		--if ((@TimeInMinutes_current >= @param_DealTimeInMinutesFirst) and (@TimeInMinutes_current <= @param_DealTimeInMinutesLast))
		begin
			-- 2. ���������, ����� ��������� ������ � ������� ntImportCurrentChartAverageValues � ������ ParamsIdentifyer ���� ������� �������
			 ----------------------- !!!!!!!!!!!!!!!!! ������� �������� ��� �������� ������� !!!!!!!!!!!!!!!!!

			select @is_error = 1	
			
			if ((@TimeInMinutes_current >= @TimeInMinutes_CurrentChart) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- ����� ������ ������, ��� � ����������� ����
				select @is_error = 0
			
--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ����� ������ ������, ��� � ����������� ����', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '2;' + convert(varchar,@is_error), getdate()			

			if @is_error = 1 
			begin
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ����� ������ ������, ��� � ����������� ����', getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ����� ������ ������, ��� � ����������� ����' + ']'
			end
			if @is_error = 1 
				GOTO exit_step
			
			
			
			select @is_error = 1	
			
			if (((@TimeInMinutes_current - @TimeInMinutes_CurrentChart)<@param_MaxDeltaMinutesCheckAlert) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- �� ������� ��������� ���� ������ �� ����� 2-� �����
				select @is_error = 0

--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': �� ������� ��������� ���� ������ ����� ' + convert(varchar,@param_MaxDeltaMinutesCheckAlert) + ' �����', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '3;' + convert(varchar,@is_error) + ';' + convert(varchar,@TimeInMinutes_current) + ';' + convert(varchar,@TimeInMinutes_CurrentChart) + ';' + convert(varchar,@param_MaxDeltaMinutesCheckAlert), getdate()
			
			if @is_error = 1 
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': �� ������� ��������� ���� ������ ����� ' + convert(varchar,@param_MaxDeltaMinutesCheckAlert) + ' �����', getdate()
			if @is_error = 1 
				GOTO exit_step
			
			
			select @is_error = 1	
			
			if ((@Date_Current = @Date_CurrentChart) or (@param_MaxDeltaMinutesCheckAlert = -1)) -- ������ �� �� ����, ��� � � ����������� ����
				select @is_error = 0
			
--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������ �� �� �� ����, ��� � ����������� ���� (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')', getdate()
--insert into nt_rt_log (log_message, cdatetime_log) select '4;' + convert(varchar,@is_error), getdate()

			if @is_error = 1 
			begin
				insert into nt_rt_log (log_message, cdatetime_log)
				select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������ �� �� �� ����, ��� � ����������� ���� (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')', getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������ �� �� �� ����, ��� � ����������� ���� (' + @Date_Current + ' <> ' + @Date_CurrentChart + ')' + ']'
			end
			if @is_error = 1 
				GOTO exit_step



			 

			--if (((@TimeInMinutes_current >= @TimeInMinutes_CurrentChart) and ((@TimeInMinutes_current - @TimeInMinutes_CurrentChart)<=@param_MaxDeltaMinutesCheckAlert)) -- �� ������� ��������� ���� ������ �� ����� 2-� �����
			--	and (@Date_Current = @Date_CurrentChart) -- ������ �� �� ����, ��� � � ����������� ����
			--	)
			begin
				-- ���������, ����������� �� ������� ��� ���������� ������
				exec ntp_rt_CheckAlerts_single @activation_ParamsIdentifyer, @ParamsIdentifyersSetId, @param_cntSignalsBeforeDeal, @param_IsOnlyOneActiveDeal, @param_IsOpenOppositeDeal, @param_cntBuySignalsLimit_Start, @param_cntSellSignalsLimit_Start, @param_cntBuySignalsLimit_Stop, @param_cntSellSignalsLimit_Stop, @result output
				--select @result



			insert into nt_rt_log (log_message, cdatetime_log)
			select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': result = ' + convert(varchar,@result), getdate()

			-------------------------------------------
			-- ���� ������� ������ �� ������ - �� ��������� ������ � MetaTrader

			if @result <> 0
			begin

--insert into nt_rt_log (log_message, cdatetime_log) select '5', getdate()			

				--insert into nt_rt_log (log_message, cdatetime_log)
				--select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ������� ������ ' + convert(varchar,@result), getdate()
				select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': result = ' + convert(varchar,@result) + ']'
				
			    
				-- ������ ������ �� ���������� ������� ������
				DECLARE cSignalFoldersCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
				SELECT SignalFolder, Symbol, Period, MaxDeltaMinutesMakeDeal, DealVolume, DealStopLossPoints, DealTakeProfitPoints, DealOnePoint, MaxDeltaPointsMakeDeal, Slippage
				from nt_rt_SignalFolders
				where activation_ParamsIdentifyer = @activation_ParamsIdentifyer -- ParamsIdentifyer, ������� ���������� �������� ������� ������
					and ParamsIdentifyersSetId = @ParamsIdentifyersSetId
					and is_active = 1
				order by SignalFolder
				
				OPEN cSignalFoldersCursor

				-- ���������� ��������� ������� ������
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

					-- ���������� ����� ������� ����� ������� �������� � �������� ��
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
					

					-- ��������� ��� ����������� �����
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
					
					



					-- ������� ���������� ����		
					-- ������� 1: ����� ������� ����		
					select @cmd = 'echo on>>' + @SignalFolder + '\"' + @SignalFileName + '"'
					EXEC master..xp_cmdshell @cmd, NO_OUTPUT

--insert into nt_rt_log (log_message, cdatetime_log) select '6', getdate()

					insert into nt_rt_log (log_message, cdatetime_log)
					select @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ����������� ���� ' + @SignalFolder + '\"' + @SignalFileName + '"', getdate()
					select @resultMessage = @resultMessage + '[' + @activation_ParamsIdentifyer + ';' + convert(varchar,@ParamsIdentifyersSetId) + ';' + @DateTime_CurrentChart + ': ����������� ���� ' + @SignalFileName + ']'
				
					
/*
					-- ������� 2: ������� ������� ��������� ����, ����� ��� ���������������
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


