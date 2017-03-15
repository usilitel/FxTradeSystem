

alter PROCEDURE ntp_st_MakeDealsAllDays_v04 (
	-- процедура прогоняет тест стратегии с указанными параметрами по таблице #nt_st_chart
	-- и записывает совершенные сделки в таблицу #nt_st_deals
	
	-- неверно: (параметры в зависимости от времени дня берутся из таблицы nt_st_parameters_TimeInMinutes)
	-- верно:    параметры берутся из таблицы nt_st_parameters_ParamsIdentifyersSets
	
	-- таблица #nt_st_chart должна быть создана и заполнена
	-- таблица #nt_st_deals должна быть создана
	-- таблица #ntAverageValuesResults должна быть создана и заполнена
	
	
	-- переменные для построения графика цены
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	--@cntCharts int, 
	@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
	-- переменные для расчета сделок
	--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	--@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	--@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	---- прочие параметры стратегии
	--@param_StopLoss real, 
	--@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int, -- количество сигналов подряд, нужное для заключения сделки
	@param_volume real,
	--@param_DealTimeInMinutesFirst int, -- время в минутах от 00:00, начиная с которого заключаем сделки
	--@param_DealTimeInMinutesLast int,   -- время в минутах от 00:00, заканчивая которым заключаем сделки
	@param_IsOnlyOneActiveDeal int, -- 1 = только одна открытая позиция  в одну сторону (максимум один Buy и один Sell одновременно), 0 = неограниченное число открытых позиций (1 сигнал = 1 сделка)
	@param_IsOpenOppositeDeal int, -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу, 0 = закрываем позиции только по SL и TP
	
	
--	@ParamsIdentifyersSetId int,
	@param_cntBuySignalsLimit_Start int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
	@param_cntSellSignalsLimit_Start int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
	@param_cntBuySignalsLimit_Stop int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
	@param_cntSellSignalsLimit_Stop int -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ





	
)
AS BEGIN 
-- процедура для заполнения таблицы tPeriodsData данными

SET NOCOUNT ON

	-- переменные выбираемые из курсора
	declare @c_idn int, @c_idn_chart int, @c_deal_direction int, @c_idn_chart_deal_cclose int,
			@c_idn_previous int, @c_idn_chart_previous int, @c_deal_direction_previous int, @c_idn_chart_deal_cclose_previous int,
	
	@c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real,

	-- переменные для расчета сделок
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- прочие параметры стратегии
	@param_StopLoss real, 
	@param_TakeProfit real
--	@param_cntSignalsBeforeDeal int -- количество сигналов подряд, нужное для заключения сделки

	-- вспомогательные переменные	
	declare 
	@is_DealActive int, -- 1 - есть открытая длинная позиция, 2 - есть открытая короткая позиция, 0 - нет открытых позиций
	@cntSignalsBefore int, -- количество сигналов подряд, которые были до текущего момента (+ = количество сигналов на покупку, - = количество сигналов на продажу)
	--@is_first_deal int,
	@idn_AverageValues int, -- idn записи из таблицы ntAverageValuesResults
	@DealTimeInMinutesFirstCurrent int, -- текущее начало периода
	@DealTimeInMinutesLastCurrent int, -- текущий конец периода
	--@DealTimeInMinutesFirstPrevious int -- предыдущее начало периода (используется для определения перехода в следующий временной период)

	@cntBuySignals int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам
	@cntSellSignals int -- количество сигналов на продажу по разным ParamsIdentifyer-ам



	
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
	

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 1

	-- начальное заполнение переменных
	select  @is_DealActive = 0,
			@cntSignalsBefore = 0,
			@deal_direction = 0,
			@deal_profit_total = 0
			

	truncate table #nt_st_deals








	If object_ID('tempdb..#t_cntBuySignals') Is not Null drop table #t_cntBuySignals
	If object_ID('tempdb..#t_cntSellSignals') Is not Null drop table #t_cntSellSignals

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 2




	-- вычисляем количество сигналов на покупку
	select  c.idn, 
			count(distinct vb.ParamsIdentifyer) as cntBuySignals
			--count(distinct p2.CalcCorrParamsId) as cntCalcCorrParamsId
			--count(distinct p2.CalcCorrParamsId) as cntBuySignals
	into #t_cntBuySignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = @ParamsIdentifyersSetId
	left outer join #ntAverageValuesResults vb with (index=index1) on -- сигналы на покупку
			vb.ParamsIdentifyer = p.ParamsIdentifyer
		and vb.cdatetime_last = c.cdatetime
		and (
			 vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_AtOnce_up_AvgCnt-vb.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_Daily_up_AvgCnt-vb.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--left outer join ntSettingsFilesParameters_cn p2 with (nolock) on p2.ParamsIdentifyer = vb.ParamsIdentifyer
	group by c.idn
	order by c.idn

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 3
-- select * from ntSettingsFilesParameters_cn

	-- вычисляем количество сигналов на продажу
	select  c.idn, 
			count(distinct vs.ParamsIdentifyer) as cntSellSignals
			--count(distinct p2.CalcCorrParamsId) as cntCalcCorrParamsId
			--count(distinct p2.CalcCorrParamsId) as cntSellSignals
	into #t_cntSellSignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = @ParamsIdentifyersSetId
	left outer join #ntAverageValuesResults vs with (index=index1) on -- сигналы на продажу
			vs.ParamsIdentifyer = p.ParamsIdentifyer
		and vs.cdatetime_last = c.cdatetime
		and (
			 vs.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_AtOnce_up_AvgCnt-vs.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vs.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_Daily_up_AvgCnt-vs.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--left outer join ntSettingsFilesParameters_cn p2 with (nolock) on p2.ParamsIdentifyer = vs.ParamsIdentifyer
	group by c.idn
	order by c.idn



	
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 4

	-- запоминаем количество сигналов на покупку и на продажу
	update c
	set c.cntBuySignals = bs.cntBuySignals,
		c.cntSellSignals = ss.cntSellSignals
	from #nt_st_chart c
	left outer join #t_cntBuySignals bs on bs.idn = c.idn -- сигналы на продажу
	left outer join #t_cntSellSignals ss on ss.idn = c.idn -- сигналы на продажу




-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 5


	-- записываем сделки
	insert into #nt_st_deals(
		idn_chart,
		-- параметры расчета общих показателей
		StopLoss, TakeProfit, OnePoint, 
		-- прочие параметры стратегии
		param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, 
		-- параметры сделки
		deal_copen, -- цена открытия сделки
		deal_direction, -- направление сделки (1=buy, 2=sell)
		--deal_StopLoss, -- StopLoss по сделке
		--deal_TakeProfit, -- TakeProfit по сделке
		deal_volume, -- объем сделки
		cdatetime,
		CurrencyIdCurrent,
		CurrencyIdHistory,
		ABMmPosition0,
		ABMmPosition1,
		TimeInMinutes_deal_copen
		)
	select
		idn,
		@StopLoss, @TakeProfit, @OnePoint, 
		-- прочие параметры стратегии
		@StopLoss, 
		@TakeProfit, 
		@param_cntSignalsBeforeDeal, -- количество сигналов подряд, нужное для заключения сделки
		@param_volume, 
		-- параметры сделки
		cclose, -- цена открытия сделки

		case when (
								cntBuySignals >= @param_cntBuySignalsLimit_Start -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
								and
								cntSellSignals <= @param_cntSellSignalsLimit_Stop -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПОКУПКУ
								)
			then 1
			when (
								cntSellSignals >= @param_cntSellSignalsLimit_Start -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
								and
								cntBuySignals <= @param_cntBuySignalsLimit_Stop -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПРОДАЖУ
								)
			then 2
			else 0
			end as deal_direction, -- направление сделки (1=buy, 2=sell)
		--@deal_StopLoss, -- StopLoss по сделке
		--@deal_TakeProfit, -- TakeProfit по сделке
		@param_volume as deal_volume,  -- объем сделки
		cdatetime,
		CurrencyIdCurrent,
		CurrencyIdHistory,
		ABMmPosition0,
		ABMmPosition1,		
		CONVERT(int,SUBSTRING(cdatetime,12,2))*60 + CONVERT(int,SUBSTRING(cdatetime,15,2))
	from #nt_st_chart
	where	(
			cntBuySignals >= @param_cntBuySignalsLimit_Start -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
			and
			cntSellSignals <= @param_cntSellSignalsLimit_Stop -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПОКУПКУ
			)
			or
			(
			cntSellSignals >= @param_cntSellSignalsLimit_Start -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
			and
			cntBuySignals <= @param_cntBuySignalsLimit_Stop -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПРОДАЖУ
			)
						

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 6

	-- вычисляем deal_StopLoss и deal_TakeProfit
	update #nt_st_deals
	set deal_StopLoss = case when deal_direction = 1
							 then deal_copen - (StopLoss * OnePoint)
							 when deal_direction = 2
							 then deal_copen + (StopLoss * OnePoint)
							 else 0
						end ,
		deal_TakeProfit = case when deal_direction = 1
							 then deal_copen + (TakeProfit * OnePoint)
							 when deal_direction = 2
							 then deal_copen - (TakeProfit * OnePoint)
							 else 0
						end


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 7


	-- вычисляем закрытие сделок по покупке
	update d
	set d.deal_cclose = case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then deal_TakeProfit
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then deal_StopLoss
							 else 0 
						end,
		d.idn_chart_deal_cclose = -- idn_chart бара закрытия сделки
						case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then isnull(cp.idn,100000000)
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then isnull(cl.idn,100000000)
							 else 0 
						end
	from #nt_st_deals d
	left outer join #nt_st_chart cp on -- первый бар с TakeProfit
			cp.idn > d.idn_chart
		and cp.chigh >= d.deal_TakeProfit
		and cp.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and chigh >= d.deal_TakeProfit)
	left outer join #nt_st_chart cl on -- первый бар с StopLoss
			cl.idn > d.idn_chart
		and cl.clow <= d.deal_StopLoss
		and cl.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and clow <= d.deal_StopLoss)
	where d.deal_direction = 1


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 8

	-- вычисляем закрытие сделок по продаже
	update d
	set d.deal_cclose = case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then deal_TakeProfit
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then deal_StopLoss
							 else 0 
						end,
		d.idn_chart_deal_cclose = -- idn_chart бара закрытия сделки
						case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then isnull(cp.idn,100000000)
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then isnull(cl.idn,100000000)
							 else 0 
						end
	from #nt_st_deals d
	left outer join #nt_st_chart cp on -- первый бар с TakeProfit
			cp.idn > d.idn_chart
		and cp.clow <= d.deal_TakeProfit
		and cp.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and clow <= d.deal_TakeProfit)
	left outer join #nt_st_chart cl on -- первый бар с StopLoss
			cl.idn > d.idn_chart
		and cl.chigh >= d.deal_StopLoss
		and cl.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and chigh >= d.deal_StopLoss)
	where d.deal_direction = 2


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 9

	-- ставим время закрытия сделки
	update d
	set d.cdatetime_deal_cclose = c.cdatetime,
		d.TimeInMinutes_deal_cclose = CONVERT(int,SUBSTRING(c.cdatetime,12,2))*60 + CONVERT(int,SUBSTRING(c.cdatetime,15,2))
	from #nt_st_deals d
	left outer join #nt_st_chart c on c.idn = d.idn_chart_deal_cclose



-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 10


	-- убираем сделки, открытые раньше чем закрылась предыдущая
	if @param_IsOnlyOneActiveDeal = 1
	begin
		DECLARE cDealsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
		-- выбираем все сделки на покупку
		SELECT  idn, idn_chart, deal_direction, idn_chart_deal_cclose
		from #nt_st_deals
		where deal_direction = 1
		order by cdatetime

		select @c_idn = 0, @c_idn_chart = 0, @c_deal_direction = 0, @c_idn_chart_deal_cclose = 0
		select @c_idn_previous = 0, @c_idn_chart_previous = 0, @c_deal_direction_previous = 0, @c_idn_chart_deal_cclose_previous = 0
		
		OPEN cDealsCursor

		-- запоминаем все цены и рассчитанные общие показатели
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		WHILE @@FETCH_STATUS = 0
		BEGIN

			if @c_idn_previous = 0 -- если первая сделка
				select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- запоминаем последнюю открытую сделку
			else -- если не первая сделка
			begin
				if @c_idn_chart < @c_idn_chart_deal_cclose_previous -- сделка открыта раньше чем закрылась предыдущая
					update #nt_st_deals
					set deal_direction = 0
					where idn = @c_idn
				else
					select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- запоминаем последнюю открытую сделку
			end
			
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		END 
		--exit_cursor:
		CLOSE cDealsCursor;
		DEALLOCATE cDealsCursor;
		
		
		
		
		
		DECLARE cDealsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
		-- выбираем все сделки на продажу
		SELECT  idn, idn_chart, deal_direction, idn_chart_deal_cclose
		from #nt_st_deals
		where deal_direction = 2
		order by cdatetime

		select @c_idn = 0, @c_idn_chart = 0, @c_deal_direction = 0, @c_idn_chart_deal_cclose = 0
		select @c_idn_previous = 0, @c_idn_chart_previous = 0, @c_deal_direction_previous = 0, @c_idn_chart_deal_cclose_previous = 0
		
		OPEN cDealsCursor

		-- запоминаем все цены и рассчитанные общие показатели
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		WHILE @@FETCH_STATUS = 0
		BEGIN

			if @c_idn_previous = 0 -- если первая сделка
				select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- запоминаем последнюю открытую сделку
			else -- если не первая сделка
			begin
				if @c_idn_chart < @c_idn_chart_deal_cclose_previous -- сделка открыта раньше чем закрылась предыдущая
					update #nt_st_deals
					set deal_direction = 0
					where idn = @c_idn
				else
					select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- запоминаем последнюю открытую сделку
			end
			
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		END 
		--exit_cursor:
		CLOSE cDealsCursor;
		DEALLOCATE cDealsCursor;	
		
		delete from #nt_st_deals where deal_direction = 0
	end
	
	
---------------------------------------

	-- убираем сделки за дни с "плохими" новостями
	update d
	set d.deal_direction = 0
	from #nt_st_deals d
	left outer join ntCalendarIdnData c on c.cdate = left(d.cdatetime,10) -- все новости за день сделки
	left outer join ntCalendarActive ca on -- неактивные новости за день сделки
			ca.CurrencyId = d.CurrencyIdCurrent
		and ca.cName = c.cName
		and ca.cCountry = c.cCountry
		and ((ca.cVolatility = c.cVolatility) or (ca.cVolatility = -1))
		and ca.isActive = 0
	where ca.isActive = 0
		
	delete from #nt_st_deals where deal_direction = 0


	-- убираем сделки заключенные раньше 11:30
	-- !!! ПОТОМ ПЕРЕДЕЛАТЬ: добавить условие "после резкого движения"
	delete from #nt_st_deals where TimeInMinutes_deal_copen < (11*60+30)

	--delete from #nt_st_deals where deal_direction = 2

---------------------------------------




	update #nt_st_deals
	set deal_profit = 	case when deal_direction = 1 then round(((deal_cclose - deal_copen) * param_volume),0)
							 when deal_direction = 2 then round(((deal_cclose - deal_copen) * param_volume),0) * (-1)
						else 0 end
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 11

	update t1
	set deal_profit_total = (select sum(deal_profit) from #nt_st_deals t2 where t2.idn <= t1.idn)
	from #nt_st_deals t1
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 12
	
	
	/*
	update d
	set d.cdatetime = c.cdatetime
	from #nt_st_deals d
	left outer join nt_st_chart c on c.idn=d.idn_chart

	*/


	---- вставляем рассчитанные данные в постоянную таблицу
	--insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	--select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	--from #nt_st_deals
	--order by idn


END


