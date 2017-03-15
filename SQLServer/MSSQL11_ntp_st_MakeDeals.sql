

alter PROCEDURE ntp_st_MakeDeals (
	-- процедура прогоняет тест стратегии с указанными параметрами по таблице #nt_st_chart 
	-- и записывает совершенные сделки в таблицу nt_st_deals
	
	-- таблица #nt_st_chart должна быть создана и заполнена
	-- таблица #nt_st_deals должна быть создана
	
	
	-- переменные для построения графика цены
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	@cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
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
	@param_DealTimeInMinutesFirst int, -- время в минутах от 00:00, начиная с которого заключаем сделки
	@param_DealTimeInMinutesLast int   -- время в минутах от 00:00, заканчивая которым заключаем сделки
	
)
AS BEGIN 
-- процедура для заполнения таблицы tPeriodsData данными

SET NOCOUNT ON

	-- переменные выбираемые из курсора
	declare
	@c_idn int, @c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real

	-- вспомогательные переменные	
	declare 
	@is_DealActive int, -- 1 - есть открытая длинная позиция, 2 - есть открытая короткая позиция, 0 - нет открытых позиций
	@cntSignalsBefore int, -- количество сигналов подряд, которые были до текущего момента (+ = количество сигналов на покупку, - = количество сигналов на продажу)
	@is_first_deal int,
	@idn_AverageValues int -- idn записи из таблицы ntAverageValuesResults
	
	-- параметры сделки
	declare 
	@deal_copen real, -- цена открытия сделки
	@deal_direction int, -- направление сделки (1=buy, 2=sell)
	@deal_StopLoss real, -- StopLoss по сделке
	@deal_TakeProfit real, -- TakeProfit по сделке
	@deal_volume real, -- объем сделки
	@deal_cclose real, -- цена закрытия сделки
	@deal_profit real, -- прибыль по сделке
	@deal_profit_total real -- общая прибыль по всем сделкам
	


	-- начальное заполнение переменных
	select  @is_DealActive = 0,
			@cntSignalsBefore = 0,
			@deal_direction = 0,
			@deal_profit_total = 0,
			@is_first_deal = 1

	truncate table #nt_st_deals
	
	




	DECLARE cPriceCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
	-- выбираем все цены и рассчитанные общие показатели
	SELECT  idn, copen, chigh, clow, cclose, Volume, ABV, ABVMini, TimeInMinutes,
			CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg,
			idn_AverageValues
	from #nt_st_chart
	order by cdatetime


	OPEN cPriceCursor

	-- запоминаем все цены и рассчитанные общие показатели
	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes,
		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
		 @idn_AverageValues
	WHILE @@FETCH_STATUS = 0
	BEGIN

-- select @c_idn, @is_DealActive, @c_chigh, @c_clow, @deal_TakeProfit

		-- вычисляем закрытие сделки по StopLoss и TakeProfit
		if @is_DealActive = 1 and @c_chigh >= @deal_TakeProfit -- Buy, TakeProfit
			select 
			@deal_cclose = @deal_TakeProfit, -- цена закрытия сделки
			@deal_profit = (@deal_TakeProfit - @deal_copen) * @param_volume -- прибыль по сделке
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_TakeProfit - @deal_copen) * @param_volume) -- общая прибыль по всем сделкам

		if @is_DealActive = 1 and @c_clow <= @deal_StopLoss -- Buy, StopLoss
			select 
			@deal_cclose = @deal_StopLoss, -- цена закрытия сделки
			@deal_profit = (@deal_StopLoss - @deal_copen) * @param_volume -- прибыль по сделке
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_StopLoss - @deal_copen) * @param_volume) -- общая прибыль по всем сделкам

		if @is_DealActive = 2 and @c_clow <= @deal_TakeProfit -- Sell, TakeProfit
			select 
			@deal_cclose = @deal_TakeProfit, -- цена закрытия сделки
			@deal_profit = (@deal_copen - @deal_TakeProfit) * @param_volume -- прибыль по сделке
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_copen - @deal_TakeProfit) * @param_volume) -- общая прибыль по всем сделкам

		if @is_DealActive = 2 and @c_chigh >= @deal_StopLoss -- Sell, StopLoss
			select 
			@deal_cclose = @deal_StopLoss, -- цена закрытия сделки
			@deal_profit = (@deal_copen- @deal_StopLoss) * @param_volume -- прибыль по сделке
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_copen- @deal_StopLoss) * @param_volume) -- общая прибыль по всем сделкам



-- if @c_idn >= 51240 select @c_idn, @c_chigh, @c_clow, @deal_StopLoss

		if @is_DealActive <> 0 and @deal_cclose is not null
		begin
			update #nt_st_deals
			set deal_cclose = @deal_cclose, -- цена закрытия сделки
				deal_profit = round(@deal_profit,0), -- прибыль по сделке
				deal_profit_total = round(case when @is_first_deal = 1 then @deal_profit else @deal_profit + isnull((select deal_profit_total from #nt_st_deals where idn = (select MAX(idn)-1 from #nt_st_deals)),0) end,0) -- общая прибыль по всем сделкам
			where idn = (select MAX(idn) from #nt_st_deals)
			
			select @is_DealActive = 0 -- позиция закрыта
			select @is_first_deal = 0
			
			

			--IF (@c_TimeInMinutes >= @param_DealTimeInMinutesLast) break -- если закрыли сделку за пределами времени заключения сделок - то прекращаем тест
		end

		--IF ((@is_DealActive = 0) and (@c_TimeInMinutes > @param_DealTimeInMinutesLast)) break -- если нет открытых позиций и вышли за пределы времени заключения сделок - то прекращаем тест


		-- вычисляем сигнал на ПОКУПКУ
		if		@is_DealActive = 0
			and @v_TakeProfit_isOk_AtOnce_up_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			and (@v_TakeProfit_isOk_AtOnce_up_AvgCnt - @v_TakeProfit_isOk_AtOnce_down_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
			and @v_ChighMax_AtOnce_Avg >= @limit_ChighMax_AtOnce_Avg
			and (@v_ChighMax_AtOnce_Avg - @v_ClowMin_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
			and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
			and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
		begin
			-- проверяем условия для открытия позиции на ПОКУПКУ
			-- if @is_DealActive = 0
			-- вычисляем параметры сделки
			select @deal_copen = @c_cclose, -- цена открытия сделки
				   @deal_direction = 1, -- направление сделки (1=buy, 2=sell)
				   @deal_StopLoss = @c_cclose - (@param_StopLoss * @OnePoint), -- StopLoss по сделке
				   @deal_TakeProfit = @c_cclose + (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
				   @deal_volume = @param_volume, -- объем сделки
				   @deal_cclose = null, -- цена закрытия сделки
				   @deal_profit = null, -- прибыль по сделке
				   @deal_profit_total = null, -- общая прибыль по всем сделкам
				   @cntSignalsBefore = (case when @cntSignalsBefore < 0 then 1 else @cntSignalsBefore + 1 end) -- увеличиваем счетчик сигналов
			--select 1, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
		end
				
				
				
				
		-- вычисляем сигнал на ПРОДАЖУ
		if		@is_DealActive = 0
			and @v_TakeProfit_isOk_AtOnce_down_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			and (@v_TakeProfit_isOk_AtOnce_down_AvgCnt - @v_TakeProfit_isOk_AtOnce_up_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
			and @v_ClowMin_AtOnce_Avg >= @limit_ClowMin_AtOnce_Avg
			and (@v_ClowMin_AtOnce_Avg - @v_ChighMax_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
			and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
			and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
		begin
			-- проверяем условия для открытия позиции на ПРОДАЖУ
			-- if @is_DealActive = 0
			-- вычисляем параметры сделки
			select @deal_copen = @c_cclose, -- цена открытия сделки
				   @deal_direction = 2, -- направление сделки (1=buy, 2=sell)
				   @deal_StopLoss = @c_cclose + (@param_StopLoss * @OnePoint), -- StopLoss по сделке
				   @deal_TakeProfit = @c_cclose - (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
				   @deal_volume = @param_volume, -- объем сделки
				   @deal_cclose = null, -- цена закрытия сделки
				   @deal_profit = null, -- прибыль по сделке
				   @deal_profit_total = null, -- общая прибыль по всем сделкам
				   @cntSignalsBefore = (case when @cntSignalsBefore > 0 then -1 else @cntSignalsBefore - 1 end) -- увеличиваем счетчик сигналов
			--select 2, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
		end
		
		if @deal_direction = 0 -- если нет сигнала ни на покупку, ни на продажу - то обнуляем счетчик сигналов
			select @cntSignalsBefore = 0 
		
					

		-- открываем позицию
		if @is_DealActive = 0 and @deal_direction <> 0 and abs(@cntSignalsBefore) >= @param_cntSignalsBeforeDeal
		begin			
			insert into #nt_st_deals(
				idn_chart,
				idn_AverageValues,
				-- параметры расчета общих показателей
				cntCharts, StopLoss, TakeProfit, OnePoint, 
				-- параметры стратегии
				-- переменные для расчета сделок
				limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, 
				limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
				limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, 
				limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta,
				-- прочие параметры стратегии
				param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, 
				param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast,
				-- параметры сделки
				deal_copen, -- цена открытия сделки
				deal_direction, -- направление сделки (1=buy, 2=sell)
				deal_StopLoss, -- StopLoss по сделке
				deal_TakeProfit, -- TakeProfit по сделке
				deal_volume, -- объем сделки
				ParamsIdentifyer
				--deal_cclose, -- цена закрытия сделки
				--deal_profit, -- прибыль по сделке
				--deal_profit_total -- общая прибыль по всем сделкам
				)
			select
				@c_idn,
				@idn_AverageValues,
				@cntCharts, @StopLoss, @TakeProfit, @OnePoint, 
				-- переменные для расчета сделок
				@limit_CcorrMax, @limit_CcorrAvg, @limit_TakeProfit_isOk_Daily_up_AvgCnt, @limit_TakeProfit_isOk_Daily_down_AvgCnt, @limit_TakeProfit_isOk_Daily_up_PrcBars, @limit_TakeProfit_isOk_Daily_down_PrcBars, 
				@limit_TakeProfit_isOk_AtOnce_up_AvgCnt, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
				@limit_ChighMax_Daily_Avg, @limit_ClowMin_Daily_Avg, 
				@limit_ChighMax_AtOnce_Avg, @limit_ClowMin_AtOnce_Avg, @limit_ChighMax_ClowMin_AtOnce_Avg_delta,
				-- прочие параметры стратегии
				@param_StopLoss, 
				@param_TakeProfit, 
				@param_cntSignalsBeforeDeal, -- количество сигналов подряд, нужное для заключения сделки
				@param_volume, 
				@param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast,
				-- параметры сделки
				@deal_copen, -- цена открытия сделки
				@deal_direction, -- направление сделки (1=buy, 2=sell)
				@deal_StopLoss, -- StopLoss по сделке
				@deal_TakeProfit, -- TakeProfit по сделке
				@deal_volume,  -- объем сделки
				@ParamsIdentifyer
				--@deal_cclose, -- цена закрытия сделки
				--@deal_profit, -- прибыль по сделке
				--@deal_profit_total real -- общая прибыль по всем сделкам
				
				select @is_DealActive = @deal_direction

		end
		
		select @deal_direction = 0
		


	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes,
		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
		 @idn_AverageValues
	END 


	--exit_cursor:
	
	CLOSE cPriceCursor;
	DEALLOCATE cPriceCursor;

	-- вставляем рассчитанные данные в постоянную таблицу
	insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	from #nt_st_deals
	order by idn


END


