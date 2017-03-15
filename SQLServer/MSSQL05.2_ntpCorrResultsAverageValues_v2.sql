


-- откуда берутся столбцы:
		
-- ntPeriodsData.idn -> arrDataHistory(0) -> arrIDNSorted -> ntCorrResultsBufer.idn -> ntCorrResults.idn -> ntCorrResultsReport.idndata    --->    #ntCorrResultsReport.idnData -> @idn
			 -- ntImportNTdata.idn -> ntPeriodsData.idnNTdata -> ntCorrResults.idn								   --->    #ntPeriodsData.idn (сравнивается с) @idn

-- MSSQL ntCorrResultsReport identity: ntCorrResultsReport.idn
-- MSSQL ntPeriodsData identity: ntPeriodsData.idn

-- select * from ntPeriodsData
-- select * from ntCorrResultsReport
				
		

--delete from ntAverageValuesResults where idn >= 17797
--go

-- создаем процедуру для расчета средних/суммарных показателей по всем похожим ситуациям
-- drop PROCEDURE ntpCorrResultsAverageValues
alter PROCEDURE ntpCorrResultsAverageValues (
	-- входные параметры
		@cntCharts int, -- количество похожих графиков, которые берем для анализа
		@StopLossInCurrentPrice real, -- StopLoss в пунктах (в текущих ценах)
		@TakeProfitInCurrentPrice real, -- TakeProfit в пунктах (в текущих ценах)
	@OnePoint real, -- значение одного пункта в цене
	@CurrencyId_current	int, -- CurrencyId валюты текущих данных
	@CurrencyId_history	int, -- CurrencyId валюты исторических данных (с которыми сравниваем)
	@DataSourceId	int,
	@PeriodMinutes int,
		@isCalcAverageValuesInPercents int, -- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@pParamsIdentifyer VARCHAR(50),
	@pCntBarsCalcCorr int, -- количество баров, по которым считать К (0 - задается начальная дата-время)
	@ctime_CalcAverageValuesWithNextDay varchar(5), -- время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
		@CntBarsMinLimit integer, -- минимальное количество баров, которое может быть в торговом дне
	
		@DeltaCcloseRangeMaxLimit real, -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMinLimit real, -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@IsCalcCorrOnlyForSameTime int, -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		@DeltaMinutesCalcCorr int, -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
	@CalcCorrParamsId varchar(20), -- идентификатор параметров расчета К	
	
	@isTakeHistoryResultsFromTempTable int -- 1 = таблица #ntCorrResultsReport уже есть и заполнена, 0 = ее надо сделать и заполнить самому из постоянной таблицы
	
)
AS BEGIN 
-- процедура для расчета средних/суммарных показателей по похожим ситуациям

-- условия для расчета: 
-- 1) таблица #ntCorrResultsReport д.б. уже заполнена
-- 2) таблица #ntImportCurrent д.б. заполнена (нужны только 1-я и последняя записи)

-- результат: 
-- 1) в таблицу ntCorrResultsReport добавляются рассчитанные величины
-- 2) в таблицу ntAverageValuesResults записываются общие рассчитанные величины


	SET NOCOUNT ON


	declare @idn int
	declare @cclose real
	declare @idnlast int
	
	declare @CurrentPriceCloseLastBar real -- последняя cclose по текущим данным
	--declare @HistoryPriceCloseLastBar real -- последняя cclose по историческим данным
	declare @StopLoss real -- StopLoss в пунктах
	declare @TakeProfit real -- TakeProfit в пунктах
	
	
	

	declare @ctime_last varchar(5)
	declare @nextTradeDay varchar(10)

	--declare @ctime_CalcAverageValuesWithNextDay varchar(5) -- время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
	--declare @CntBarsMinLimit integer -- минимальное количество баров, которое может быть в торговом дне

	--select @ctime_CalcAverageValuesWithNextDay = '00:01'
	--select @CntBarsMinLimit = 30



	-- вычисляемые величины
	declare @cntBars_day int -- кол-во баров до конца дня
	-- (1)
	declare @TakeProfit_isOk_Daily_up int -- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
	declare @TakeProfit_isOk_Daily_down int -- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
	-- (2)
	declare @TakeProfit_isOk_AtOnce_up int -- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
	declare @TakeProfit_isOk_AtOnce_down int -- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
	-- (3)
	declare @ChighMax_Daily int -- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
	declare @ClowMin_Daily int -- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
	-- (4)
	declare @ChighMax_AtOnce int -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	declare @ClowMin_AtOnce int -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	
	-- declare @idn_first int -- первый idn, начиная с которого берем данные из таблицы ntCorrResultsReport


	declare @idnMin int
	declare @idnMax int


	declare @CcorrMax real
	declare @CcorrAvg real

-- select * from #ntCorrResultsReport

  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 1
  --select @idn, @pParamsIdentifyer, GETDATE(), 1
  --select 1111

	  	 --select 1/0 from ntAverageValuesResults


	select @idnMin = MIN(idn) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @pParamsIdentifyer
	select @idnMax = MAX(idn) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @pParamsIdentifyer

	  
-- если в таблице ntAverageValuesResults уже есть строка с рассчитанными общими показателями по текущим данным, то выходим из процедуры
if (select COUNT(*)
	from ntAverageValuesResults r WITH(NOLOCK)
	left outer join #ntImportCurrent cf WITH(NOLOCK) on cf.idn = @idnMin
	left outer join #ntImportCurrent cl WITH(NOLOCK) on cl.idn = @idnMax
	where r.cdate_first = cf.cdate -- совпадает первый бар
	  and r.ctime_first = cf.ctime
	  and r.copen_first = cf.copen
	  and r.chigh_first = cf.chigh
	  and r.clow_first = cf.clow
	  and r.cclose_first = cf.cclose  
	  and r.cdate_last = cl.cdate -- совпадает последний бар
	  and r.ctime_last = cl.ctime
	  and r.copen_last = cl.copen
	  and r.chigh_last = cl.chigh
	  and r.clow_last = cl.clow
	  and r.cclose_last = cl.cclose
	  and r.cntCharts = @cntCharts -- совпадают параметры расчета общих показателей
	  and r.StopLoss = @StopLossInCurrentPrice
	  and r.TakeProfit = @TakeProfitInCurrentPrice
	  and r.OnePoint = @OnePoint
	  and r.CurrencyId_current = @CurrencyId_current
	  and r.CurrencyId_history = @CurrencyId_history
	  and r.DataSourceId = @DataSourceId
	  and r.PeriodMinutes = @PeriodMinutes
	  and r.isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents
	  and r.CntBarsCalcCorr = @pCntBarsCalcCorr	  

	  and r.CntBarsMinLimit = @CntBarsMinLimit
	  and r.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
	  and r.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
	  and r.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
	  and r.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
	  and r.CalcCorrParamsId = @CalcCorrParamsId	  
	) > 0 GOTO exit_proc
	
	--select @idnMin, @idnMax
	
  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 2

-- select 111

	-- обнуляем ранее рассчитанные показатели
	update ntCorrResultsReport 
	set cntBars_day = null,
		TakeProfit_isOk_Daily_up = null,
		TakeProfit_isOk_Daily_down = null,
		TakeProfit_isOk_AtOnce_up = null,
		TakeProfit_isOk_AtOnce_down = null,
		ChighMax_Daily = null,
		ClowMin_Daily = null,
		ChighMax_AtOnce = null,
		ClowMin_AtOnce = null
	where ParamsIdentifyer = @pParamsIdentifyer
		
	-- последняя cclose по текущим данным
	--select @CurrentPriceCloseLastBar = (select top 1 cclose from ntImportCurrent WITH(NOLOCK) where ParamsIdentifyer = @pParamsIdentifyer order by idn desc) 
	select @CurrentPriceCloseLastBar = (select top 1 cclose from #ntImportCurrent order by idn desc) 
	
	-- select @idn_first = (select top 1 idn from ntCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer order by idn)
	
	

--select 9
--select * from #ntCorrResultsReport


	if @isTakeHistoryResultsFromTempTable = 0
	begin
		-- временная таблица для упорядочивания idn записей из таблицы ntCorrResultsReport (нужна для того, чтобы убрать разрывы в idn)
		If object_ID('tempdb..#ntCorrResultsReport') Is not Null drop table #ntCorrResultsReport
		CREATE TABLE #ntCorrResultsReport(
			[idn_temp] int identity(1,1),
			[idn] int,
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
			[idnmax_replaced] [int] NULL,
			
			StopLoss real, -- StopLoss в пунктах
			TakeProfit real, -- TakeProfit в пунктах
				
			-- вычисляемые средние/суммарные показателей по всем похожим ситуациям (вычисляются в процедуре ntpCorrResultsAverageValues)
			cntBars_day int NULL, -- кол-во баров до конца дня
			-- (1)
			TakeProfit_isOk_Daily_up int NULL, -- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
			TakeProfit_isOk_Daily_down int NULL, -- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
			-- (2)
			TakeProfit_isOk_AtOnce_up int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
			TakeProfit_isOk_AtOnce_down int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
			-- (3)
			ChighMax_Daily int NULL, -- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
			ClowMin_Daily int NULL, -- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
			-- (4)
			ChighMax_AtOnce int NULL, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			ClowMin_AtOnce int NULL, -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

			cntBars_day_nd int NULL, -- кол-во баров до конца дня
			-- (1)
			TakeProfit_isOk_Daily_up_nd int NULL, -- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
			TakeProfit_isOk_Daily_down_nd int NULL, -- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
			-- (2)
			TakeProfit_isOk_AtOnce_up_nd int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
			TakeProfit_isOk_AtOnce_down_nd int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
			-- (3)
			ChighMax_Daily_nd int NULL, -- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
			ClowMin_Daily_nd int NULL, -- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
			-- (4)
			ChighMax_AtOnce_nd int NULL, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			ClowMin_AtOnce_nd int NULL, -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

			ParamsIdentifyer VARCHAR(50) NULL
		) ON [PRIMARY]
		CREATE UNIQUE CLUSTERED INDEX [idn0index] ON #ntCorrResultsReport 
		([idn_temp] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

		-- select * from #ntCorrResultsReport

		insert into #ntCorrResultsReport(idn, idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, ParamsIdentifyer)
		select idn, idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, ParamsIdentifyer
		from ntCorrResultsReport WITH(NOLOCK)
		where ParamsIdentifyer = @pParamsIdentifyer 
		order by idn	
	end
	


	delete from #ntCorrResultsReport where idn_temp > @cntCharts


	-- определяем время, на которое делаем расчет
	select @ctime_last = ctime
	from #ntImportCurrent --WITH(NOLOCK)
	where --ParamsIdentifyer = @pParamsIdentifyer 
	  idn = @idnMax --(select MAX(idn) from ntImportCurrent WITH(NOLOCK) where ParamsIdentifyer = @pParamsIdentifyer)


	If object_ID('tempdb..#TradeDays') Is not Null drop table #TradeDays

	if @ctime_last >= @ctime_CalcAverageValuesWithNextDay
		-- таблица с торговыми днями
		select PeriodMultiplicator, cdate
		into #TradeDays
		from ntTradeDays WITH(NOLOCK)
		where   CurrencyId = @CurrencyId_history
			and DataSourceId = @DataSourceId
			and PeriodMinutes = @PeriodMinutes
			and cntBars >= @CntBarsMinLimit
		group by PeriodMultiplicator, cdate

--select 111
	
	-- делаем курсор по нужным idn
	DECLARE cCorrResultsReport CURSOR FOR
	SELECT idnData
	FROM #ntCorrResultsReport r WITH(NOLOCK)
	where --r.ParamsIdentifyer = @pParamsIdentifyer
		--and r.idn >= @idn_first
		r.idn_temp <= @cntCharts
	order by r.idn

	OPEN cCorrResultsReport

	FETCH NEXT FROM cCorrResultsReport 
	INTO @idn
	WHILE @@FETCH_STATUS = 0
	BEGIN

--		 select @idn
-- 		 select 111

  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 3

		If object_ID('tempdb..#ntPeriodsData') Is not Null drop table #ntPeriodsData
		--If object_ID('tempdb..#ntPeriodsData1') Is not Null drop table #ntPeriodsData1
		--If object_ID('tempdb..#ntPeriodsData2') Is not Null drop table #ntPeriodsData2

		CREATE TABLE #ntPeriodsData (  
			idn int,
			[cdate] [varchar](10),
			[ctime] [varchar](5),
			[chigh] [real],
			[clow] [real],
			[cclose] [real]
		)



			


		--select * from #ntPeriodsData order by idn
		--select * from ntPeriodsData order by idn
		--select * from ntCorrResultsReport order by idn




			
------------------------------------------------

		-- до времени @ctime_CalcAverageValuesWithNextDay выбираем данные от idnData до конца дня
		--if @ctime_last < @ctime_CalcAverageValuesWithNextDay
		--begin
			--select d2.* --d2.idn, d2.cdate, d2.ctime, d2.chigh, d2.clow, d2.cclose --d2.* --r.*, d2.* --top 10 r.* --r.idn, r.idnData 
			--into #ntPeriodsData1
			insert into #ntPeriodsData (idn, cdate, ctime, chigh, clow, cclose)
			select d2.idn, d2.cdate, d2.ctime, d2.chigh, d2.clow, d2.cclose
			from #ntCorrResultsReport r WITH(NOLOCK)
			left outer join ntPeriodsData d1 WITH(NOLOCK index=idnindex) on d1.idn = r.idnData
			left outer join ntPeriodsData d2 WITH(NOLOCK index=index4) on 
					d2.CurrencyId = d1.CurrencyId
				and d2.DataSourceId = d1.DataSourceId
				and d2.PeriodMinutes = d1.PeriodMinutes
				and d2.cdate = d1.cdate
				and d2.idn >= d1.idn
				and d2.PeriodMultiplicator = d1.PeriodMultiplicator
			where --r.ParamsIdentifyer = @pParamsIdentifyer
				  r.idnData = @idn 
			order by r.idn, d2.idn
		--end
		
--select * from #ntCorrResultsReport
--select * from #ntPeriodsData



--CREATE INDEX [index4] ON [dbo].[ntPeriodsData] 
--(CurrencyId, DataSourceId, PeriodMinutes, cdate, idn, PeriodMultiplicator ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 4
  -- select @idn, @pParamsIdentifyer, GETDATE(), 4
------------------------------------------------



		-- первая цена закрытия
		select @cclose = cclose from #ntPeriodsData WITH(NOLOCK) where idn = @idn
		

		-- пересчитываем @StopLoss и @TakeProfit
		IF @isCalcAverageValuesInPercents = 1
		BEGIN
			select @StopLoss = @StopLossInCurrentPrice * (@cclose*1.0/@CurrentPriceCloseLastBar)
			select @TakeProfit = @TakeProfitInCurrentPrice * (@cclose*1.0/@CurrentPriceCloseLastBar)
		END
		ELSE
		BEGIN
			select @StopLoss = @StopLossInCurrentPrice
			select @TakeProfit = @TakeProfitInCurrentPrice
		END
   

	-- Поехали считать
		-- кол-во баров до конца дня
		select @cntBars_day = COUNT(*) from #ntPeriodsData WITH(NOLOCK) 


		-- (1)
		-- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
		select @TakeProfit_isOk_Daily_up = COUNT(*)
		from #ntPeriodsData WITH(NOLOCK) 
		where idn > @idn
		  and chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
		--order by idn
		
		-- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
		select @TakeProfit_isOk_Daily_down = COUNT(*)
		from #ntPeriodsData WITH(NOLOCK) 
		where idn > @idn
		  and clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
		--order by idn

		--select @idn, chigh, (@cclose + @TakeProfit*@OnePoint), *
		--from #ntPeriodsData WITH(NOLOCK) 
		--where idn > @idn
		--  --and chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
		  
		--select @idn, *
		--from #ntPeriodsData WITH(NOLOCK) 
		--where idn > @idn
		----  --and clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit

		--select @idn, clow, (@cclose - @TakeProfit*@OnePoint), *
		--from #ntPeriodsData WITH(NOLOCK) 
		--where idn <> idnNTdata

	  

		-- (2)
		-- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
		select @TakeProfit_isOk_AtOnce_up = COUNT(*)
		from #ntPeriodsData d1 WITH(NOLOCK) 
		left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
				d2.idn > @idn 
			and d2.idn < d1.idn 
			and d2.clow <= (@cclose - @StopLoss*@OnePoint)
		where d1.idn > @idn
		  and d1.chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
		  and d2.clow is null -- цена не зашла за StopLoss
		--order by d1.idn
			
		-- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
		select @TakeProfit_isOk_AtOnce_down = COUNT(*)
		--select @idn as idn, @cclose as cclose, @cclose - @StopLoss*@OnePoint as sl, @cclose + @TakeProfit*@OnePoint as tp, * 
		from #ntPeriodsData d1 WITH(NOLOCK) 
		left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
				d2.idn > @idn 
			and d2.idn < d1.idn 
			and d2.chigh >= (@cclose + @StopLoss*@OnePoint)
		where d1.idn > @idn
		  and d1.clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
		  and d2.chigh is null -- цена не зашла за StopLoss
		--order by d1.idn


		


		-- (3)
		-- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		select @ChighMax_Daily = ROUND((Max(d1.chigh) - @cclose)*1.0/@OnePoint,0)
		from #ntPeriodsData d1 WITH(NOLOCK) 
		where d1.idn > @idn

		-- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		select @ClowMin_Daily = ROUND((@cclose - MIN(d1.clow))*1.0/@OnePoint,0)
		from #ntPeriodsData d1 WITH(NOLOCK) 
		where d1.idn > @idn
		--order by d1.idn



		-- (4)
		-- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		select @ChighMax_AtOnce = ROUND((Max(d1.chigh) - @cclose)*1.0/@OnePoint,0)
		from #ntPeriodsData d1 WITH(NOLOCK) 
		left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
				d2.idn > @idn 
			and d2.idn < d1.idn 
			and d2.clow <= (@cclose - @StopLoss*@OnePoint)
		where d1.idn > @idn
		  and d1.chigh >= @cclose -- цена зашла выше текущей
		  and d2.clow is null -- цена не зашла за StopLoss

		-- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		select @ClowMin_AtOnce = ROUND((@cclose - MIN(d1.clow))*1.0/@OnePoint,0)
		from #ntPeriodsData d1 WITH(NOLOCK) 
		left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
				d2.idn > @idn 
			and d2.idn < d1.idn 
			and d2.chigh >= (@cclose + @StopLoss*@OnePoint)
		where d1.idn > @idn
		  and d1.clow <= @cclose -- цена зашла ниже текущей
		  and d2.chigh is null -- цена не зашла за StopLoss
		--order by d1.idn
		

		
		--declare @ClowMin_AtOnce real -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		--declare @ChighMax_AtOnce real -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)


		-- select @TakeProfit_isOk_Daily_up, @TakeProfit_isOk_Daily_down, @TakeProfit_isOk_AtOnce_up, @TakeProfit_isOk_AtOnce_down, @ChighMax_Daily, @ClowMin_Daily, @ChighMax_AtOnce, @ClowMin_AtOnce

  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 5
		update #ntCorrResultsReport
		set cntBars_day = isnull(@cntBars_day,0), 
			TakeProfit_isOk_Daily_up = isnull(@TakeProfit_isOk_Daily_up,0), 
			TakeProfit_isOk_Daily_down = isnull(@TakeProfit_isOk_Daily_down,0), 
			TakeProfit_isOk_AtOnce_up = isnull(@TakeProfit_isOk_AtOnce_up,0), 
			TakeProfit_isOk_AtOnce_down = isnull(@TakeProfit_isOk_AtOnce_down,0), 
			ChighMax_Daily = isnull(@ChighMax_Daily,0), 
			ClowMin_Daily = isnull(@ClowMin_Daily,0), 
			ChighMax_AtOnce = isnull(@ChighMax_AtOnce,0), 
			ClowMin_AtOnce = isnull(@ClowMin_AtOnce,0),
			StopLoss = @StopLoss,
			TakeProfit = @TakeProfit
		where --ParamsIdentifyer = @pParamsIdentifyer
			idnData = @idn

  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 6



--------------------------------------
		---- после времени @ctime_CalcAverageValuesWithNextDay общие показатели считаем с учетом следующего дня
		if @ctime_last >= @ctime_CalcAverageValuesWithNextDay
		begin

			---- выбираем следующий полноценный торговый день
			select @nextTradeDay = d2.cdate
			from #ntCorrResultsReport r WITH(NOLOCK)
			left outer join ntPeriodsData d1 WITH(NOLOCK index=idnindex) on d1.idn = r.idnData
			left outer join #TradeDays    d2 WITH(NOLOCK) on 
				    d2.cdate > d1.cdate
				and d2.PeriodMultiplicator = d1.PeriodMultiplicator
			where --r.ParamsIdentifyer = @pParamsIdentifyer
				r.idnData = @idn 
			order by d2.cdate desc

			-- выбираем данные от idnData до конца СЛЕДУЮЩЕГО дня
			insert into #ntPeriodsData (idn, cdate, ctime, chigh, clow, cclose)
			select d2.idn, d2.cdate, d2.ctime, d2.chigh, d2.clow, d2.cclose			
			from #ntCorrResultsReport r WITH(NOLOCK)
			left outer join ntPeriodsData d1 WITH(NOLOCK index=idnindex) on d1.idn = r.idnData
			left outer join ntPeriodsData d2 WITH(NOLOCK index=index4) on 
					d2.CurrencyId = d1.CurrencyId
				and d2.DataSourceId = d1.DataSourceId
				and d2.PeriodMinutes = d1.PeriodMinutes
				and d2.cdate >= d1.cdate
				and d2.cdate <= @nextTradeDay
				and d2.idn >= d1.idn
				and d2.PeriodMultiplicator = d1.PeriodMultiplicator
			where --r.ParamsIdentifyer = @pParamsIdentifyer
				r.idnData = @idn 
			order by r.idn, d2.idn
			


--CREATE INDEX [index4] ON [dbo].[ntPeriodsData] 
--(CurrencyId, DataSourceId, PeriodMinutes, cdate, idn, PeriodMultiplicator ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



			-- первая цена закрытия
			--select @cclose = cclose from #ntPeriodsData WITH(NOLOCK) where idn = @idn
			

			-- пересчитываем @StopLoss и @TakeProfit
			--IF @isCalcAverageValuesInPercents = 1
			--BEGIN
			--	select @StopLoss = @StopLossInCurrentPrice * (@cclose*1.0/@CurrentPriceCloseLastBar)
			--	select @TakeProfit = @TakeProfitInCurrentPrice * (@cclose*1.0/@CurrentPriceCloseLastBar)
			--END
			--ELSE
			--BEGIN
			--	select @StopLoss = @StopLossInCurrentPrice
			--	select @TakeProfit = @TakeProfitInCurrentPrice
			--END
	    

		-- Поехали считать
			-- кол-во баров до конца дня
			select @cntBars_day = COUNT(*) from #ntPeriodsData WITH(NOLOCK) 


			-- (1)
			-- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
			select @TakeProfit_isOk_Daily_up = COUNT(*)
			from #ntPeriodsData WITH(NOLOCK) 
			where idn > @idn
			  and chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
			--order by idn
			
			-- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
			select @TakeProfit_isOk_Daily_down = COUNT(*)
			from #ntPeriodsData WITH(NOLOCK) 
			where idn > @idn
			  and clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
			--order by idn

			--select @idn, chigh, (@cclose + @TakeProfit*@OnePoint), *
			--from #ntPeriodsData WITH(NOLOCK) 
			--where idn > @idn
			--  --and chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
			  
			--select @idn, *
			--from #ntPeriodsData WITH(NOLOCK) 
			--where idn > @idn
			----  --and clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit

			--select @idn, clow, (@cclose - @TakeProfit*@OnePoint), *
			--from #ntPeriodsData WITH(NOLOCK) 
			--where idn <> idnNTdata


--select * from #ntPeriodsData
--select 111222 

	 
			-- (2)
			-- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
			select @TakeProfit_isOk_AtOnce_up = COUNT(*)
			from #ntPeriodsData d1 WITH(NOLOCK) 
			left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
					d2.idn > @idn 
				and d2.idn < d1.idn 
				and d2.clow <= (@cclose - @StopLoss*@OnePoint)
			where d1.idn > @idn
			  and d1.chigh >= (@cclose + @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
			  and d2.clow is null -- цена не зашла за StopLoss
			--order by d1.idn
 
			-- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
			select @TakeProfit_isOk_AtOnce_down = COUNT(*)
			--select @idn as idn, @cclose as cclose, @cclose - @StopLoss*@OnePoint as sl, @cclose + @TakeProfit*@OnePoint as tp, * 
			from #ntPeriodsData d1 WITH(NOLOCK) 
			left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
					d2.idn > @idn 
				and d2.idn < d1.idn 
				and d2.chigh >= (@cclose + @StopLoss*@OnePoint)
			where d1.idn > @idn
			  and d1.clow <= (@cclose - @TakeProfit*@OnePoint) -- цена зашла за TakeProfit
			  and d2.chigh is null -- цена не зашла за StopLoss
			--order by d1.idn





			-- (3)
			-- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
			select @ChighMax_Daily = ROUND((Max(d1.chigh) - @cclose)*1.0/@OnePoint,0)
			from #ntPeriodsData d1 WITH(NOLOCK) 
			where d1.idn > @idn

			-- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
			select @ClowMin_Daily = ROUND((@cclose - MIN(d1.clow))*1.0/@OnePoint,0)
			from #ntPeriodsData d1 WITH(NOLOCK) 
			where d1.idn > @idn
			--order by d1.idn



			-- (4)
			-- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			select @ChighMax_AtOnce = ROUND((Max(d1.chigh) - @cclose)*1.0/@OnePoint,0)
			from #ntPeriodsData d1 WITH(NOLOCK) 
			left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
					d2.idn > @idn 
				and d2.idn < d1.idn 
				and d2.clow <= (@cclose - @StopLoss*@OnePoint)
			where d1.idn > @idn
			  and d1.chigh >= @cclose -- цена зашла выше текущей
			  and d2.clow is null -- цена не зашла за StopLoss

			-- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			select @ClowMin_AtOnce = ROUND((@cclose - MIN(d1.clow))*1.0/@OnePoint,0)
			from #ntPeriodsData d1 WITH(NOLOCK) 
			left outer join #ntPeriodsData d2  WITH(NOLOCK) on 
					d2.idn > @idn 
				and d2.idn < d1.idn 
				and d2.chigh >= (@cclose + @StopLoss*@OnePoint)
			where d1.idn > @idn
			  and d1.clow <= @cclose -- цена зашла ниже текущей
			  and d2.chigh is null -- цена не зашла за StopLoss
			--order by d1.idn
			

			
			--declare @ClowMin_AtOnce real -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			--declare @ChighMax_AtOnce real -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)


			-- select @TakeProfit_isOk_Daily_up, @TakeProfit_isOk_Daily_down, @TakeProfit_isOk_AtOnce_up, @TakeProfit_isOk_AtOnce_down, @ChighMax_Daily, @ClowMin_Daily, @ChighMax_AtOnce, @ClowMin_AtOnce


			update #ntCorrResultsReport
			set cntBars_day_nd = isnull(@cntBars_day,0), 
				TakeProfit_isOk_Daily_up_nd = isnull(@TakeProfit_isOk_Daily_up,0), 
				TakeProfit_isOk_Daily_down_nd = isnull(@TakeProfit_isOk_Daily_down,0), 
				TakeProfit_isOk_AtOnce_up_nd = isnull(@TakeProfit_isOk_AtOnce_up,0), 
				TakeProfit_isOk_AtOnce_down_nd = isnull(@TakeProfit_isOk_AtOnce_down,0), 
				ChighMax_Daily_nd = isnull(@ChighMax_Daily,0), 
				ClowMin_Daily_nd = isnull(@ClowMin_Daily,0), 
				ChighMax_AtOnce_nd = isnull(@ChighMax_AtOnce,0), 
				ClowMin_AtOnce_nd = isnull(@ClowMin_AtOnce,0)
				--StopLoss = @StopLoss,
				--TakeProfit = @TakeProfit
			where --ParamsIdentifyer = @pParamsIdentifyer
				idnData = @idn
				

		end
		
----------------------------------------

		FETCH NEXT FROM cCorrResultsReport 
		INTO @idn
	END 

	CLOSE cCorrResultsReport;
	DEALLOCATE cCorrResultsReport;

  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 7
--select 123




				










	-- начинаем заполнение таблицы ntAverageValuesResults (для хранения общих рассчитанных величин)

	If object_ID('tempdb..#ntAverageValuesResults') Is not Null drop table #ntAverageValuesResults


	-- делаем копии таблиц (сначала заполним их, а потом разом перебросим в постоянные)
	select top 1 *
	into #ntAverageValuesResults
	from ntAverageValuesResults WITH(NOLOCK) 
	
	truncate table #ntAverageValuesResults
	
	



	insert into #ntAverageValuesResults(
		[cdate_first] ,
		[ctime_first] ,
		[cdatetime_first] ,
		[copen_first] ,
		[chigh_first] ,
		[clow_first] ,
		[cclose_first])
	select cdate,	ctime,	cdate + ' ' + ctime,	copen,	chigh,	clow,	cclose
	from #ntImportCurrent WITH(NOLOCK) 
	where --ParamsIdentifyer = @pParamsIdentifyer and 
		idn = @idnMin --(select MIN(idn) from ntImportCurrent where ParamsIdentifyer = @pParamsIdentifyer)
																  
-- select @idnMin, * from #ntImportCurrent
-- select 1, * from #ntAverageValuesResults



  -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 8
  
	-- запоминаем текущий idn
	--select @idnlast = MAX(idn) from ntAverageValuesResults WITH(NOLOCK) 

	update r
	set r.[cdate_last] = c.cdate,
		r.[ctime_last] = c.ctime,
		r.[cdatetime_last] = c.cdate + ' ' + c.ctime,
		r.[copen_last] = c.copen,
		r.[chigh_last] = c.chigh,
		r.[clow_last] = c.clow,
		r.[cclose_last] = c.cclose
	from #ntAverageValuesResults r WITH(NOLOCK) 
	--left outer join ntImportCurrent c  WITH(NOLOCK) on c.ParamsIdentifyer = @pParamsIdentifyer and c.idn = @idnMax --(select MAX(idn) from ntImportCurrent where ParamsIdentifyer = @pParamsIdentifyer)
	left outer join #ntImportCurrent c  on --c.ParamsIdentifyer = @pParamsIdentifyer and 
		c.idn = @idnMax --(select MAX(idn) from ntImportCurrent where ParamsIdentifyer = @pParamsIdentifyer)
	--where r.idn = @idnlast


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 9

	update r
	set r.cntCharts = @cntCharts,
		r.StopLoss = @StopLossInCurrentPrice,
		r.TakeProfit = @TakeProfitInCurrentPrice,
		r.OnePoint = @OnePoint,
		r.CurrencyId_current = @CurrencyId_current,
		r.CurrencyId_history = @CurrencyId_history,
		r.DataSourceId = @DataSourceId,
		r.PeriodMinutes = @PeriodMinutes,
		r.isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents,
		r.cntBarsCalcCorr = @pCntBarsCalcCorr,
		
		r.CntBarsMinLimit = @CntBarsMinLimit,
		r.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit,  
		r.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit,	  
		r.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime,	  
		r.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr,	  
		r.CalcCorrParamsId = @CalcCorrParamsId	  
	from #ntAverageValuesResults r WITH(NOLOCK) 
	--where r.idn = @idnlast


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 10

	--update r
	--set r.CurrencyId_current = c.CurrencyId,
	--	r.CurrencyId_history = c.CurrencyId,
	--	r.DataSourceId = c.DataSourceId,
	--	r.PeriodMinutes = c.PeriodMinutes
	--from ntAverageValuesResults r
	--left outer join #ntPeriodsData c on c.idn = (select MIN(idn) from #ntPeriodsData)
	--where r.idn = @idnlast

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 11




	select @CcorrMax = MAX(ccorr), @CcorrAvg = AVG(ccorr)
	from #ntCorrResultsReport  WITH(NOLOCK)
	
	update #ntAverageValuesResults
	set CcorrMax = @CcorrMax,
		CcorrAvg = @CcorrAvg
		

	--update r
	--set r.CcorrMax = c.CcorrMax,
	--	r.CcorrAvg = c.CcorrAvg
	--from #ntAverageValuesResults r WITH(NOLOCK) 
	--left outer join (
	--		select MAX(ccorr) as CcorrMax, AVG(ccorr) as CcorrAvg
	--		from ntCorrResultsReport  WITH(NOLOCK) 
	--		where ParamsIdentifyer = @pParamsIdentifyer and cntBars_day is not null 
	--		group by cperiod	
	--) c on 1=1
	--where r.idn = @idnlast


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 12

	update r
	set r.TakeProfit_isOk_Daily_up_AvgCnt = c.TakeProfit_isOk_Daily_up_AvgCnt,
		r.TakeProfit_isOk_Daily_down_AvgCnt = c.TakeProfit_isOk_Daily_down_AvgCnt,
		r.TakeProfit_isOk_Daily_up_PrcBars = c.TakeProfit_isOk_Daily_up_PrcBars,
		r.TakeProfit_isOk_Daily_down_PrcBars = c.TakeProfit_isOk_Daily_down_PrcBars,
		r.TakeProfit_isOk_AtOnce_up_AvgCnt = c.TakeProfit_isOk_AtOnce_up_AvgCnt,
		r.TakeProfit_isOk_AtOnce_down_AvgCnt = c.TakeProfit_isOk_AtOnce_down_AvgCnt,
		r.ChighMax_Daily_Avg = c.ChighMax_Daily_Avg,
		r.ClowMin_Daily_Avg = c.ClowMin_Daily_Avg,
		r.ChighMax_AtOnce_Avg = c.ChighMax_AtOnce_Avg,
		r.ClowMin_AtOnce_Avg = c.ClowMin_AtOnce_Avg,
		r.cdatetime_calc = GETDATE()
	from #ntAverageValuesResults r WITH(NOLOCK) 
	left outer join (
			select 
				-- (1)
				sum(case when TakeProfit_isOk_Daily_up > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_Daily_up_AvgCnt , -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
				sum(case when TakeProfit_isOk_Daily_down > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_Daily_down_AvgCnt , -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
				avg(TakeProfit_isOk_Daily_up*1.0/cntBars_day) as TakeProfit_isOk_Daily_up_PrcBars , -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
				avg(TakeProfit_isOk_Daily_down*1.0/cntBars_day) as TakeProfit_isOk_Daily_down_PrcBars , -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
				-- (2)
				sum(case when TakeProfit_isOk_AtOnce_up > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_AtOnce_up_AvgCnt , -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
				sum(case when TakeProfit_isOk_AtOnce_down > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_AtOnce_down_AvgCnt , -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
				-- (3)
				avg(ChighMax_Daily*1.0) as ChighMax_Daily_Avg , -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
				avg(ClowMin_Daily*1.0) as ClowMin_Daily_Avg , -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
				-- (4)
				avg(ChighMax_AtOnce*1.0) as ChighMax_AtOnce_Avg , -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
				avg(ClowMin_AtOnce*1.0) as ClowMin_AtOnce_Avg  -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			from #ntCorrResultsReport  WITH(NOLOCK) 
			--where ParamsIdentifyer = @pParamsIdentifyer and cntBars_day is not null 	
	) c on 1=1
	--where r.idn = @idnlast
	
	
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 13
	
	-- считаем общие показатели с учетом СЛЕДУЮЩЕГО дня
	update r
	set r.TakeProfit_isOk_Daily_up_AvgCnt_nd = c.TakeProfit_isOk_Daily_up_AvgCnt,
		r.TakeProfit_isOk_Daily_down_AvgCnt_nd = c.TakeProfit_isOk_Daily_down_AvgCnt,
		r.TakeProfit_isOk_Daily_up_PrcBars_nd = c.TakeProfit_isOk_Daily_up_PrcBars,
		r.TakeProfit_isOk_Daily_down_PrcBars_nd = c.TakeProfit_isOk_Daily_down_PrcBars,
		r.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = c.TakeProfit_isOk_AtOnce_up_AvgCnt,
		r.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = c.TakeProfit_isOk_AtOnce_down_AvgCnt,
		r.ChighMax_Daily_Avg_nd = c.ChighMax_Daily_Avg,
		r.ClowMin_Daily_Avg_nd = c.ClowMin_Daily_Avg,
		r.ChighMax_AtOnce_Avg_nd = c.ChighMax_AtOnce_Avg,
		r.ClowMin_AtOnce_Avg_nd = c.ClowMin_AtOnce_Avg
		--r.cdatetime_calc = GETDATE()
	from #ntAverageValuesResults r WITH(NOLOCK) 
	left outer join (
			select 
				-- (1)
				sum(case when TakeProfit_isOk_Daily_up_nd > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_Daily_up_AvgCnt , -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
				sum(case when TakeProfit_isOk_Daily_down_nd > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_Daily_down_AvgCnt , -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
				avg(TakeProfit_isOk_Daily_up_nd*1.0/cntBars_day_nd) as TakeProfit_isOk_Daily_up_PrcBars , -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
				avg(TakeProfit_isOk_Daily_down_nd*1.0/cntBars_day_nd) as TakeProfit_isOk_Daily_down_PrcBars , -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
				-- (2)
				sum(case when TakeProfit_isOk_AtOnce_up_nd > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_AtOnce_up_AvgCnt , -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
				sum(case when TakeProfit_isOk_AtOnce_down_nd > 0 then 1 else 0 end)*1.0/@cntCharts as TakeProfit_isOk_AtOnce_down_AvgCnt , -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
				-- (3)
				avg(ChighMax_Daily_nd*1.0) as ChighMax_Daily_Avg , -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
				avg(ClowMin_Daily_nd*1.0) as ClowMin_Daily_Avg , -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
				-- (4)
				avg(ChighMax_AtOnce_nd*1.0) as ChighMax_AtOnce_Avg , -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
				avg(ClowMin_AtOnce_nd*1.0) as ClowMin_AtOnce_Avg  -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			from #ntCorrResultsReport  WITH(NOLOCK) 
			--where ParamsIdentifyer = @pParamsIdentifyer and cntBars_day is not null 	
	) c on 1=1
	--where r.idn = @idnlast




	-- переносим рассчитанные данные в постоянные таблицы
	update t1
	set t1.cntBars_day = t2.cntBars_day, 
		t1.TakeProfit_isOk_Daily_up = t2.TakeProfit_isOk_Daily_up, 
		t1.TakeProfit_isOk_Daily_down = t2.TakeProfit_isOk_Daily_down, 
		t1.TakeProfit_isOk_AtOnce_up = t2.TakeProfit_isOk_AtOnce_up, 
		t1.TakeProfit_isOk_AtOnce_down = t2.TakeProfit_isOk_AtOnce_down, 
		t1.ChighMax_Daily = t2.ChighMax_Daily, 
		t1.ClowMin_Daily = t2.ClowMin_Daily, 
		t1.ChighMax_AtOnce = t2.ChighMax_AtOnce, 
		t1.ClowMin_AtOnce = t2.ClowMin_AtOnce,
		t1.StopLoss = t2.StopLoss,
		t1.TakeProfit = t2.TakeProfit,
		t1.cntBars_day_nd = t2.cntBars_day_nd, 
		t1.TakeProfit_isOk_Daily_up_nd = t2.TakeProfit_isOk_Daily_up_nd, 
		t1.TakeProfit_isOk_Daily_down_nd = t2.TakeProfit_isOk_Daily_down_nd, 
		t1.TakeProfit_isOk_AtOnce_up_nd = t2.TakeProfit_isOk_AtOnce_up_nd, 
		t1.TakeProfit_isOk_AtOnce_down_nd = t2.TakeProfit_isOk_AtOnce_down_nd, 
		t1.ChighMax_Daily_nd = t2.ChighMax_Daily_nd, 
		t1.ClowMin_Daily_nd = t2.ClowMin_Daily_nd, 
		t1.ChighMax_AtOnce_nd = t2.ChighMax_AtOnce_nd, 
		t1.ClowMin_AtOnce_nd = t2.ClowMin_AtOnce_nd
	from ntCorrResultsReport t1
	inner join #ntCorrResultsReport t2 on t2.idn=t1.idn
	where t2.TakeProfit_isOk_Daily_up is not null
	
--select 2, * from #ntAverageValuesResults
	
--	select 3, max(idn) from ntAverageValuesResults
	
	insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, CntBarsMinLimit, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, ParamsIdentifyer)
	select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, CntBarsMinLimit, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, @pParamsIdentifyer
	from #ntAverageValuesResults
	
--	select 4, max(idn) from ntAverageValuesResults
	
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 14
	

exit_proc:

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 15


END

--go
--exec ntpCorrResultsAverageValues 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5_v11_PA2', 0, '00:01', 30

--exec ntpCorrResultsAverageValues 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5_v10_PAB100', 100, '00:01', 30
--exec ntpCorrResultsAverageValues 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5', 0
--exec ntpCorrResultsAverageValues 15, 100, 200, 1, 6, 6, 3, 5, 1, '6_5', 0
--go
--select * from ntCorrResultsReport where ParamsIdentifyer = '6_5'


-- select * from #ntPeriodsData
-- select * from ntCorrResultsReport
-- select * from ntCorrResultsPeriodsData
-- select * from ntAverageValuesResults
-- select * from ntImportCurrent

--go
--exec ntpCorrResultsAverageValues 15, 10, 20, 0.00010, 1, 1, 2, 5, 1, '1_5', 0
