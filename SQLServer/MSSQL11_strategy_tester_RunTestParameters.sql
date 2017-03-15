

-- тестер стратегий
-- запускаем тест стратегии с перебором параметров



SET NOCOUNT ON

declare
	@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	-- переменные для расчета сделок
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- прочие параметры стратегии
	@param_StopLoss real, 
	@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int, -- количество сигналов подряд, нужное для заключения сделки
	@param_volume real,
	@param_DealTimeInMinutesFirst int, @param_DealTimeInMinutesLast int,
	@cnt_variants int,
	@is_count_cnt_variants int,
	-- границы параметров
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt_min real, @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_max real, @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_step real, 
	@limit_TakeProfit_isOk_AtOnce_down_AvgCnt_min real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_max real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_step real, 
	@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_min real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_max real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_step real, 
	@limit_ChighMax_AtOnce_Avg_min real, @limit_ChighMax_AtOnce_Avg_max real, @limit_ChighMax_AtOnce_Avg_step real, 
	@limit_ClowMin_AtOnce_Avg_min real, @limit_ClowMin_AtOnce_Avg_max real, @limit_ClowMin_AtOnce_Avg_step real, 
	@limit_ChighMax_ClowMin_AtOnce_Avg_delta_min real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta_max real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta_step real,
	@param_StopLoss_min real, @param_StopLoss_max real, @param_StopLoss_step real, 
	@param_TakeProfit_min real, @param_TakeProfit_max real, @param_TakeProfit_step real,
	@param_cntSignalsBeforeDeal_min int, @param_cntSignalsBeforeDeal_max int, @param_cntSignalsBeforeDeal_step int,
	@param_DealTimeInMinutesFirst_min int, @param_DealTimeInMinutesFirst_max int, @param_DealTimeInMinutesFirst_step int,
	@param_DealTimeInMinutesFirstLast_delta int
	
select
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt_min = 0.432, @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_max = 0.432, @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_step = 0.066, -- 0.4 0.466 0.532 0.598 0.664
	@limit_TakeProfit_isOk_AtOnce_down_AvgCnt_min = 0.498, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_max = 0.498, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_step = 0.066,  -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
	@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_min = 0.298, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_max = 0.298, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_step = 0.066, 
	@limit_ChighMax_AtOnce_Avg_min = 25, @limit_ChighMax_AtOnce_Avg_max = 25, @limit_ChighMax_AtOnce_Avg_step = 5, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ClowMin_AtOnce_Avg_min = 30, @limit_ClowMin_AtOnce_Avg_max = 30, @limit_ClowMin_AtOnce_Avg_step = 5, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ChighMax_ClowMin_AtOnce_Avg_delta_min = 8, @limit_ChighMax_ClowMin_AtOnce_Avg_delta_max = 8, @limit_ChighMax_ClowMin_AtOnce_Avg_delta_step = 2,
	@param_StopLoss_min = 15, @param_StopLoss_max = 23, @param_StopLoss_step = 1, 
	@param_TakeProfit_min = 20, @param_TakeProfit_max = 100, @param_TakeProfit_step = 1,
	@param_cntSignalsBeforeDeal_min = 1, @param_cntSignalsBeforeDeal_max = 1, @param_cntSignalsBeforeDeal_step = 1,
	@param_DealTimeInMinutesFirst_min = (11*60), @param_DealTimeInMinutesFirst_max = (11*60), @param_DealTimeInMinutesFirst_step = 60,
	@param_DealTimeInMinutesFirstLast_delta = (60*1)-5, -- интервал (55 = 1 час)
	--@param_DealTimeInMinutesFirst = (15*60), 
	--@param_DealTimeInMinutesLast  = (16*60)-5,
	@CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',
	@cdatetime_first = '2015.06.11 05:00', @cdatetime_last = '2016.02.05 21:00'

select @is_count_cnt_variants = 0 -- 1 = подсчет числа вариантов

select @cnt_variants = 0






	If object_ID('tempdb..#nt_st_chart') Is not Null drop table #nt_st_chart
	If object_ID('tempdb..#nt_st_deals') Is not Null drop table #nt_st_deals
	
	select top 1 *
	into #nt_st_deals
	from nt_st_deals

	-- select * from #nt_st_deals
	-- select * from nt_st_deals
	-- select * from #nt_st_chart
	truncate table #nt_st_deals

-- @CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',



	-- выбираем все цены и рассчитанные общие показатели
	-- если надо считать не за весь срок - то раскомментировать условия по датам
	SELECT  c.idn, c.copen, c.chigh, c.clow, c.cclose, c.Volume, c.ABV, c.ABVMini, CONVERT(int,LEFT(c.ctime,2))*60 + CONVERT(int,SUBSTRING(c.ctime,4,2)) as TimeInMinutes,
			v.CcorrMax, v.CcorrAvg, v.TakeProfit_isOk_Daily_up_AvgCnt, v.TakeProfit_isOk_Daily_down_AvgCnt, v.TakeProfit_isOk_Daily_up_PrcBars, v.TakeProfit_isOk_Daily_down_PrcBars, v.TakeProfit_isOk_AtOnce_up_AvgCnt, v.TakeProfit_isOk_AtOnce_down_AvgCnt, v.ChighMax_Daily_Avg, v.ClowMin_Daily_Avg, v.ChighMax_AtOnce_Avg, v.ClowMin_AtOnce_Avg,
			v.idn as idn_AverageValues,
			c.cdatetime		
	into #nt_st_chart
	from nt_st_chart c with (nolock)
	left outer join ntAverageValuesResults v with (nolock) on 
			v.CurrencyId_current = c.CurrencyIdCurrent
		and v.CurrencyId_history = c.CurrencyIdHistory
		and v.DataSourceId = c.DataSourceId
		and v.PeriodMinutes = c.PeriodMinutes
		and v.cdatetime_last = c.cdatetime
		and v.copen_last = c.copen
		and v.chigh_last = c.chigh
		and v.clow_last = c.clow
		and v.cclose_last = c.cclose
	where
			c.CurrencyIdCurrent = @CurrencyIdCurrent
		and c.CurrencyIdHistory = @CurrencyIdHistory
		and c.DataSourceId = @DataSourceId
		and c.PeriodMinutes = @PeriodMinutes
		and c.PeriodMultiplicatorMin = @PeriodMultiplicatorMin
		and c.PeriodMultiplicatorMax = @PeriodMultiplicatorMax
		and c.ParamsIdentifyer = @ParamsIdentifyer
		and c.cdatetime >= @cdatetime_first
		and c.cdatetime <= @cdatetime_last			
		and v.cdatetime_last is not null -- на данное время рассчитаны общие показатели
		-- and CONVERT(int,LEFT(c.ctime,2))*60 + CONVERT(int,SUBSTRING(c.ctime,4,2)) >= @param_DealTimeInMinutesFirst -- не делать, т.к. будет неверно считаться закрытие сделки на следующий день
	order by c.cdatetime --c.idn
	


-- select getdate() as getdate_before_calc

select @param_DealTimeInMinutesFirst = @param_DealTimeInMinutesFirst_min
select @param_DealTimeInMinutesLast = @param_DealTimeInMinutesFirst + @param_DealTimeInMinutesFirstLast_delta -- интервал = 1 час
WHILE @param_DealTimeInMinutesFirst <= @param_DealTimeInMinutesFirst_max
BEGIN
	select  @limit_TakeProfit_isOk_AtOnce_up_AvgCnt = @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_min
	WHILE @limit_TakeProfit_isOk_AtOnce_up_AvgCnt <= @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_max --0.8
	BEGIN
		select @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_min
		WHILE @limit_TakeProfit_isOk_AtOnce_down_AvgCnt <= @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_max --0.8
		BEGIN
			select @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_min --0.066
			WHILE @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta <= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_max --0.8
			BEGIN
				select @limit_ChighMax_AtOnce_Avg = @limit_ChighMax_AtOnce_Avg_min -- 10
				WHILE @limit_ChighMax_AtOnce_Avg <= @limit_ChighMax_AtOnce_Avg_max -- 60
				BEGIN
					select @limit_ClowMin_AtOnce_Avg = @limit_ClowMin_AtOnce_Avg_min -- 10
					WHILE @limit_ClowMin_AtOnce_Avg <= @limit_ClowMin_AtOnce_Avg_max -- 60
					BEGIN
						select @limit_ChighMax_ClowMin_AtOnce_Avg_delta = @limit_ChighMax_ClowMin_AtOnce_Avg_delta_min --5
						WHILE @limit_ChighMax_ClowMin_AtOnce_Avg_delta <= @limit_ChighMax_ClowMin_AtOnce_Avg_delta_max --50
						BEGIN
							select @param_StopLoss = @param_StopLoss_min --10
							WHILE @param_StopLoss <= @param_StopLoss_max --30
							BEGIN
								select @param_TakeProfit = @param_TakeProfit_min --10 
								WHILE @param_TakeProfit <= @param_TakeProfit_max --30
								BEGIN
									select @param_cntSignalsBeforeDeal = @param_cntSignalsBeforeDeal_min
									WHILE @param_cntSignalsBeforeDeal <= @param_cntSignalsBeforeDeal_max
									BEGIN
										if @is_count_cnt_variants = 0
											exec ntp_st_MakeDeals 
												-- переменные для построения графика цены
												--@CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',
												--@cdatetime_first = @cdatetime_first, @cdatetime_last = @cdatetime_last,
												@cntCharts = @cntCharts, @StopLoss = @StopLoss, @TakeProfit = @TakeProfit, @OnePoint = @OnePoint, @ParamsIdentifyer = @ParamsIdentifyer,
												-- переменные для расчета сделок
												@limit_CcorrMax = 0, @limit_CcorrAvg = 0, @limit_TakeProfit_isOk_Daily_up_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_down_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_up_PrcBars = 0, @limit_TakeProfit_isOk_Daily_down_PrcBars = 0, 
												@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = @limit_TakeProfit_isOk_AtOnce_up_AvgCnt, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
												@limit_TakeProfit_isOk_AtOnce_down_AvgCnt = @limit_TakeProfit_isOk_AtOnce_down_AvgCnt, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
												@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,
												@limit_ChighMax_Daily_Avg = 0, @limit_ClowMin_Daily_Avg = 0, 
												@limit_ChighMax_AtOnce_Avg = @limit_ChighMax_AtOnce_Avg, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
												@limit_ClowMin_AtOnce_Avg = @limit_ClowMin_AtOnce_Avg, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
												@limit_ChighMax_ClowMin_AtOnce_Avg_delta = @limit_ChighMax_ClowMin_AtOnce_Avg_delta,
												-- прочие параметры стратегии
												@param_StopLoss = @param_StopLoss, 
												@param_TakeProfit = @param_TakeProfit, 
												@param_cntSignalsBeforeDeal = @param_cntSignalsBeforeDeal, -- количество сигналов подряд, нужное для заключения сделки
												@param_volume = 10000,
												@param_DealTimeInMinutesFirst = @param_DealTimeInMinutesFirst, 
												@param_DealTimeInMinutesLast = @param_DealTimeInMinutesLast
										select @cnt_variants = @cnt_variants + 1
										select @param_cntSignalsBeforeDeal = @param_cntSignalsBeforeDeal + @param_cntSignalsBeforeDeal_step
									END	
									select @param_TakeProfit = @param_TakeProfit + @param_TakeProfit_step
								END	
								select @param_StopLoss = @param_StopLoss + @param_StopLoss_step
							END	
							select @limit_ChighMax_ClowMin_AtOnce_Avg_delta = @limit_ChighMax_ClowMin_AtOnce_Avg_delta + @limit_ChighMax_ClowMin_AtOnce_Avg_delta_step
						END	
						select @limit_ClowMin_AtOnce_Avg = @limit_ClowMin_AtOnce_Avg + @limit_ClowMin_AtOnce_Avg_step
					END	
					select @limit_ChighMax_AtOnce_Avg = @limit_ChighMax_AtOnce_Avg + @limit_ChighMax_AtOnce_Avg_step
				END	
				select @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta + @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta_step
			END	
			select @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = @limit_TakeProfit_isOk_AtOnce_down_AvgCnt + @limit_TakeProfit_isOk_AtOnce_down_AvgCnt_step
		END
		select @limit_TakeProfit_isOk_AtOnce_up_AvgCnt = @limit_TakeProfit_isOk_AtOnce_up_AvgCnt + @limit_TakeProfit_isOk_AtOnce_up_AvgCnt_step
	END
	select @param_DealTimeInMinutesFirst = @param_DealTimeInMinutesFirst + @param_DealTimeInMinutesFirst_step
	select @param_DealTimeInMinutesLast = @param_DealTimeInMinutesFirst + @param_DealTimeInMinutesFirstLast_delta -- интервал = 1 час
END

	
	
select getdate() as getdate_, @cnt_variants as cnt_variants


