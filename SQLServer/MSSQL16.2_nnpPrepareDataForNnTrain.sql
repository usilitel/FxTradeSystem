


alter PROCEDURE nnpPrepareDataForNnTrain (@pParamsIdentifyer VARCHAR(50), @resultMessage int =0 output)
AS BEGIN 
-- процедура готовит данные для обучения НС

-- результат:
-- заполнены таблицы:
-- nnPeriodsData (входные данные примеров для обучения)
-- nnCorrResultsReport (результаты для обучения)
-- nnImportCurrent (текущие входные данные)



SET NOCOUNT ON
	
	declare @cntCurrentRecords int -- количество баров в текущих данных
	
	declare @cntRecords_nnPeriodsData int
	declare @cntRecords_nnCorrResultsReport int
	declare @cntRecords_nnImportCurrent int
	
	
		
	/*declare @CurrencyId_history int
	declare @PeriodMinutes int
	
	-- запоминаем параметры @pParamsIdentifyer-а
	select @CurrencyId_history = CurrencyId_history,
		   @PeriodMinutes = PeriodMinutes
	from ntSettingsFilesParameters_cn
	where ParamsIdentifyer = @pParamsIdentifyer
	*/

	-- вычисляем количество баров в текущих данных (чтобы брать такое же количество исторических баров в примерах)
	select @cntCurrentRecords = count(*)
	from ntImportCurrent WITH(NOLOCK) 
	where ParamsIdentifyer = @pParamsIdentifyer
	
	--select @cntCurrentRecords --, @CurrencyId_history, @PeriodMinutes
	
	delete from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer
	
	-- select * from nnPeriodsData

	insert into nnPeriodsData  (ParamsIdentifyer, idnDataLast, ccorr, idnData, CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator, cdate, ctime, 
								copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, ABMmPosition0_M5, ABMmPosition1_M5, BSV, BSVMini, BSP, cBidAskMovedTotal, cBidAskAvgVolume)
	select  @pParamsIdentifyer, 
			r.idnData as idnDataLast,
			r.ccorr,
			pdp.idn as idnData,			
			pdp.CurrencyId,
			pdp.DataSourceId,
			pdp.PeriodMinutes,
			pdp.PeriodMultiplicator,
			pdp.cdate, 
			pdp.ctime, 
			pdp.copen, 
			pdp.chigh, 
			pdp.clow, 
			pdp.cclose, 
			pdp.Volume, 
			pdp.ABV, 
			pdp.ABVMini, 
			pdp.ABMmPosition0, 
			pdp.ABMmPosition1, 
			pdp.ABMmPosition0_M5, 
			pdp.ABMmPosition1_M5, 
			pdp.BSV, 
			pdp.BSVMini, 
			pdp.BSP, 
			pdp.cBidAskMovedTotal, 
			pdp.cBidAskAvgVolume
	from ntCorrResultsReport r WITH(NOLOCK) 
	left outer join ntPeriodsData pd WITH(NOLOCK)  on pd.idn = r.idnData
	left outer join ntPeriodsData pdp WITH(NOLOCK) on pdp.idn <= r.idnData
		and pdp.idn >= (r.idnData-@cntCurrentRecords+1)
	where r.ParamsIdentifyer = @pParamsIdentifyer		
		--and pdp.CurrencyId = pd.CurrencyId -- проверяем, чтобы в примерах были только нужные данные (по нужной валюте/периоду)
		--and pdp.DataSourceId = pd.DataSourceId
		--and pdp.PeriodMinutes = pd.PeriodMinutes
		--and pdp.PeriodMultiplicator = pd.PeriodMultiplicator
		--and r.idnData = 812760
	order by r.ccorr desc, r.idnData, pdp.idn
		
	
	-- убираем примеры, в которых недостаточно данных	
	If object_ID('tempdb..#t_idnData_delete') Is not Null drop table #t_idnData_delete
	
	select idnDataLast, count(*) as cnt_records
	into #t_idnData_delete
	from nnPeriodsData WITH(NOLOCK)
	where ParamsIdentifyer = @pParamsIdentifyer
	group by idnDataLast
	having count(*) <> @cntCurrentRecords
	
	delete from nnPeriodsData where idnDataLast in (select idnDataLast from #t_idnData_delete)	
	--select * from #t_idnData_delete



	-- проверяем, чтобы в примерах были только нужные данные (по нужной валюте/периоду)
	If object_ID('tempdb..#t_idnData_delete2') Is not Null drop table #t_idnData_delete2
	
	select idnDataLast, CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator, count(*) as cnt_records
	into #t_idnData_delete2
	from nnPeriodsData WITH(NOLOCK)
	where ParamsIdentifyer = @pParamsIdentifyer
	group by idnDataLast, CurrencyId, DataSourceId, PeriodMinutes, PeriodMultiplicator
	having count(*) <> @cntCurrentRecords
	
	delete from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer and idnDataLast in (select idnDataLast from #t_idnData_delete2)	
	--select * from #t_idnData_delete2
	
	-- select * from nnPeriodsData order by ccorr desc
	



-----------------------------------------------
	-- заполняем таблицу с текущими данными
	delete from nnImportCurrent where ParamsIdentifyer = @pParamsIdentifyer

	insert into nnImportCurrent(
			ParamsIdentifyer,
			cdate,
			ctime,
			copen, 
			chigh, 
			clow, 
			cclose,
			Volume,
			ABV,
			ABVMini,
			ABMmPosition0,
			ABMmPosition1,
			ABMmPosition0_M5,
			ABMmPosition1_M5,
			BSV,
			BSVMini,
			BSP,
			cBidAskMovedTotal,
			cBidAskAvgVolume
		)
	select  @pParamsIdentifyer,
			t1.cdate,
			t1.ctime,
			t1.copen, 
			t1.chigh, 
			t1.clow, 
			t1.cclose,
			t2.Volume,
			t2.ABV,
			t2.ABVMini,
			t2.ABMmPosition0,
			t2.ABMmPosition1,
			null as ABMmPosition0_M5,
			null as ABMmPosition1_M5,
			t2.BSV,
			t2.BSVMini,
			null as BSP,
			null as cBidAskMovedTotal,
			null as cBidAskAvgVolume
	from ntImportCurrent t1 WITH(NOLOCK)
	left outer join ntImportCurrentChartAverageValues t2 WITH(NOLOCK) on t2.ParamsIdentifyer = @pParamsIdentifyer
		and t2.cdate = t1.cdate
		and t2.ctime = t1.ctime
	where t1.ParamsIdentifyer = @pParamsIdentifyer
	order by t1.cdate, t1.ctime


	-- масштабируем текущие данные
	If object_ID('tempdb..#t_nnImportCurrent_scale') Is not Null drop table #t_nnImportCurrent_scale

	select 
			min(cdate + ' ' + ctime) as cdatetimeFirst,
			max(cclose) - min(cclose) as cclose_delta,
			max(cclose) - min(cclose) as cclose_first,
			max(Volume) as Volume_delta,
			--max(Volume) - min(Volume) as Volume_first,
			max(ABV) - min(ABV) as ABV_delta,
			max(ABV) - min(ABV) as ABV_first,
			max(ABVMini) - min(ABVMini) as ABVMini_delta,
			max(ABVMini) - min(ABVMini) as ABVMini_first,
			max(ABMmPosition0) - min(ABMmPosition0) as ABMmPosition0_delta,
			max(ABMmPosition0) - min(ABMmPosition0) as ABMmPosition0_first,
			max(ABMmPosition1) - min(ABMmPosition1) as ABMmPosition1_delta,
			max(ABMmPosition1) - min(ABMmPosition1) as ABMmPosition1_first,
			max(ABMmPosition0_M5) - min(ABMmPosition0_M5) as ABMmPosition0_M5_delta,
			max(ABMmPosition0_M5) - min(ABMmPosition0_M5) as ABMmPosition0_M5_first,
			max(ABMmPosition1_M5) - min(ABMmPosition1_M5) as ABMmPosition1_M5_delta,
			max(ABMmPosition1_M5) - min(ABMmPosition1_M5) as ABMmPosition1_M5_first,
			max(BSV) - min(BSV) as BSV_delta,
			max(BSV) - min(BSV) as BSV_first,
			max(BSVMini) - min(BSVMini) as BSVMini_delta,
			max(BSVMini) - min(BSVMini) as BSVMini_first,
			max(BSP) - min(BSP) as BSP_delta,
			max(BSP) - min(BSP) as BSP_first,
			max(cBidAskMovedTotal) - min(cBidAskMovedTotal) as cBidAskMovedTotal_delta,
			max(cBidAskMovedTotal) - min(cBidAskMovedTotal) as cBidAskMovedTotal_first,
			max(cBidAskAvgVolume) - min(cBidAskAvgVolume) as cBidAskAvgVolume_delta,
			max(cBidAskAvgVolume) - min(cBidAskAvgVolume) as cBidAskAvgVolume_first	
	into #t_nnImportCurrent_scale
	from nnImportCurrent WITH(NOLOCK)
	where ParamsIdentifyer = @pParamsIdentifyer
	--group by idnDataLast
	
	update s
	set s.cclose_first = d.cclose,
		--s.Volume_first = d.Volume,
		s.ABV_first = d.ABV,
		s.ABVMini_first = d.ABVMini,
		s.ABMmPosition0_first = d.ABMmPosition0,
		s.ABMmPosition1_first = d.ABMmPosition1,
		s.ABMmPosition0_M5_first = d.ABMmPosition0_M5,
		s.ABMmPosition1_M5_first = d.ABMmPosition1_M5,
		s.BSV_first = d.BSV,
		s.BSVMini_first = d.BSVMini,
		s.BSP_first = d.BSP,
		s.cBidAskMovedTotal_first = d.cBidAskMovedTotal,
		s.cBidAskAvgVolume_first = d.cBidAskAvgVolume
	from #t_nnImportCurrent_scale s
	left outer join nnImportCurrent d WITH(NOLOCK) on d.ParamsIdentifyer = @pParamsIdentifyer
		and (d.cdate + ' ' + d.ctime) = s.cdatetimeFirst 
		
	-- теперь в таблице #t_nnImportCurrent_scale шкала по текущим данным
		

	
	
-----------------------------------------------

	
	-- select * from nnPeriodsData
	
	-- масштабируем входные данные
	If object_ID('tempdb..#t_nnPeriodsData_scale') Is not Null drop table #t_nnPeriodsData_scale
	If object_ID('tempdb..#t_nnPeriodsData_scale_max') Is not Null drop table #t_nnPeriodsData_scale_max
	
	select idnDataLast, ccorr,
			min(idnData) as idnDataFirst,
			max(cclose) - min(cclose) as cclose_delta,
			max(cclose) - min(cclose) as cclose_first,
			max(Volume) as Volume_delta,
			--max(Volume) - min(Volume) as Volume_first,
			max(ABV) - min(ABV) as ABV_delta,
			max(ABV) - min(ABV) as ABV_first,
			max(ABVMini) - min(ABVMini) as ABVMini_delta,
			max(ABVMini) - min(ABVMini) as ABVMini_first,
			max(ABMmPosition0) - min(ABMmPosition0) as ABMmPosition0_delta,
			max(ABMmPosition0) - min(ABMmPosition0) as ABMmPosition0_first,
			max(ABMmPosition1) - min(ABMmPosition1) as ABMmPosition1_delta,
			max(ABMmPosition1) - min(ABMmPosition1) as ABMmPosition1_first,
			max(ABMmPosition0_M5) - min(ABMmPosition0_M5) as ABMmPosition0_M5_delta,
			max(ABMmPosition0_M5) - min(ABMmPosition0_M5) as ABMmPosition0_M5_first,
			max(ABMmPosition1_M5) - min(ABMmPosition1_M5) as ABMmPosition1_M5_delta,
			max(ABMmPosition1_M5) - min(ABMmPosition1_M5) as ABMmPosition1_M5_first,
			max(BSV) - min(BSV) as BSV_delta,
			max(BSV) - min(BSV) as BSV_first,
			max(BSVMini) - min(BSVMini) as BSVMini_delta,
			max(BSVMini) - min(BSVMini) as BSVMini_first,
			max(BSP) - min(BSP) as BSP_delta,
			max(BSP) - min(BSP) as BSP_first,
			max(cBidAskMovedTotal) - min(cBidAskMovedTotal) as cBidAskMovedTotal_delta,
			max(cBidAskMovedTotal) - min(cBidAskMovedTotal) as cBidAskMovedTotal_first,
			max(cBidAskAvgVolume) - min(cBidAskAvgVolume) as cBidAskAvgVolume_delta,
			max(cBidAskAvgVolume) - min(cBidAskAvgVolume) as cBidAskAvgVolume_first	
	into #t_nnPeriodsData_scale
	from nnPeriodsData WITH(NOLOCK)
	where ParamsIdentifyer = @pParamsIdentifyer
	group by idnDataLast, ccorr

	
	update s
	set s.cclose_first = d.cclose,
		--s.Volume_first = d.Volume,
		s.ABV_first = d.ABV,
		s.ABVMini_first = d.ABVMini,
		s.ABMmPosition0_first = d.ABMmPosition0,
		s.ABMmPosition1_first = d.ABMmPosition1,
		s.ABMmPosition0_M5_first = d.ABMmPosition0_M5,
		s.ABMmPosition1_M5_first = d.ABMmPosition1_M5,
		s.BSV_first = d.BSV,
		s.BSVMini_first = d.BSVMini,
		s.BSP_first = d.BSP,
		s.cBidAskMovedTotal_first = d.cBidAskMovedTotal,
		s.cBidAskAvgVolume_first = d.cBidAskAvgVolume
	from #t_nnPeriodsData_scale s
	left outer join nnPeriodsData d WITH(NOLOCK) on d.ParamsIdentifyer = @pParamsIdentifyer
		and d.idnDataLast = s.idnDataLast 
		and d.idnData = s.idnDataFirst
	
	-- теперь в таблице #t_nnPeriodsData_scale шкала по историческим данным
/*
	select * from ntCorrResultsReport
	select * from ntPeriodsData
	select * from nnPeriodsData
	*/
	
	-- убираем те исторические данные, у которых колебания выходят за допустимые диапазоны
	If object_ID('tempdb..#t_idnData_delete3') Is not Null drop table #t_idnData_delete3
	
	select	sh.idnDataLast
			/*r.cdate, r.ctime, 
			sc.cclose_delta, sh.cclose_delta, sh.cclose_delta/sc.cclose_delta, s1.RangeMin, s1.RangeMax,
			sc.ABV_delta, sh.ABV_delta, sh.ABV_delta/sc.ABV_delta, s2.RangeMin, s2.RangeMax,
			sc.ABVMini_delta, sh.ABVMini_delta, sh.ABVMini_delta/sc.ABVMini_delta, s3.RangeMin, s3.RangeMax,
			* */
	into #t_idnData_delete3
	from #t_nnPeriodsData_scale sh
	left outer join #t_nnImportCurrent_scale sc on 1=1
	--left outer join ntCorrResultsReport r on r.idnData=sh.idnDataLast
	left outer join nnSettingsPeriodsParameters s1 WITH(NOLOCK) on s1.ParamsIdentifyer = @pParamsIdentifyer and s1.FieldNameHistory = 'cclose'
	left outer join nnSettingsPeriodsParameters s2 WITH(NOLOCK) on s2.ParamsIdentifyer = @pParamsIdentifyer and s2.FieldNameHistory = 'ABV'
	left outer join nnSettingsPeriodsParameters s3 WITH(NOLOCK) on s3.ParamsIdentifyer = @pParamsIdentifyer and s3.FieldNameHistory = 'ABVMini'
	where	((sh.cclose_delta/sc.cclose_delta < s1.RangeMin) or (sh.cclose_delta/sc.cclose_delta > s1.RangeMax))
			or
			((sh.ABV_delta/sc.ABV_delta < s2.RangeMin) or (sh.ABV_delta/sc.ABV_delta > s2.RangeMax))
			or
			((sh.ABVMini_delta/sc.ABVMini_delta < s3.RangeMin) or (sh.ABVMini_delta/sc.ABVMini_delta > s3.RangeMax))
			
			
	-- select * from nnPeriodsData order by ccorr desc
	delete from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer and idnDataLast in (select idnDataLast from #t_idnData_delete3)	
	-- select * from nnPeriodsData order by ccorr desc
	 
	delete from #t_nnPeriodsData_scale where idnDataLast in (select idnDataLast from #t_idnData_delete3)	

--	select * from #t_nnPeriodsData_scale
--	select * from nnSettingsPeriodsParameters






	-- вычисляем максимальные колебания показателей (среди примеров для обучения)
	select 
			max(cclose_delta) as cclose_delta_max,
			max(Volume_delta) as Volume_delta_max,
			max(ABV_delta) as ABV_delta_max,
			max(ABVMini_delta) as ABVMini_delta_max,
			max(ABMmPosition0_delta) as ABMmPosition0_delta_max,
			max(ABMmPosition1_delta) as ABMmPosition1_delta_max,
			max(ABMmPosition0_M5_delta) as ABMmPosition0_M5_delta_max,
			max(ABMmPosition1_M5_delta) as ABMmPosition1_M5_delta_max,
			max(BSV_delta) as BSV_delta_max,
			max(BSVMini_delta) as BSVMini_delta_max,
			max(BSP_delta) as BSP_delta_max,
			max(cBidAskMovedTotal_delta) as cBidAskMovedTotal_delta_max,
			max(cBidAskAvgVolume_delta) as cBidAskAvgVolume_delta_max
	into #t_nnPeriodsData_scale_max
	from #t_nnPeriodsData_scale
	--group by idnDataLast
	

	-- если диапазон текущих данных больше, чем диапазон исторических данных, то обновляем максимумы диапазонов	
	update sm
	set sm.cclose_delta_max = (case when sc.cclose_delta > sm.cclose_delta_max then sc.cclose_delta else sm.cclose_delta_max end),
		sm.Volume_delta_max = (case when sc.Volume_delta > sm.Volume_delta_max then sc.Volume_delta else sm.Volume_delta_max end),
		sm.ABV_delta_max = (case when sc.ABV_delta > sm.ABV_delta_max then sc.ABV_delta else sm.ABV_delta_max end),
		sm.ABVMini_delta_max = (case when sc.ABVMini_delta > sm.ABVMini_delta_max then sc.ABVMini_delta else sm.ABVMini_delta_max end),
		sm.ABMmPosition0_delta_max = (case when sc.ABMmPosition0_delta > sm.ABMmPosition0_delta_max then sc.ABMmPosition0_delta else sm.ABMmPosition0_delta_max end),
		sm.ABMmPosition1_delta_max = (case when sc.ABMmPosition1_delta > sm.ABMmPosition1_delta_max then sc.ABMmPosition1_delta else sm.ABMmPosition1_delta_max end),
		sm.ABMmPosition0_M5_delta_max = (case when sc.ABMmPosition0_M5_delta > sm.ABMmPosition0_M5_delta_max then sc.ABMmPosition0_M5_delta else sm.ABMmPosition0_M5_delta_max end),
		sm.ABMmPosition1_M5_delta_max = (case when sc.ABMmPosition1_M5_delta > sm.ABMmPosition1_M5_delta_max then sc.ABMmPosition1_M5_delta else sm.ABMmPosition1_M5_delta_max end),
		sm.BSV_delta_max = (case when sc.BSV_delta > sm.BSV_delta_max then sc.BSV_delta else sm.BSV_delta_max end),
		sm.BSVMini_delta_max = (case when sc.BSVMini_delta > sm.BSVMini_delta_max then sc.BSVMini_delta else sm.BSVMini_delta_max end),
		sm.BSP_delta_max = (case when sc.BSP_delta > sm.BSP_delta_max then sc.BSP_delta else sm.BSP_delta_max end),
		sm.cBidAskMovedTotal_delta_max = (case when sc.cBidAskMovedTotal_delta > sm.cBidAskMovedTotal_delta_max then sc.cBidAskMovedTotal_delta else sm.cBidAskMovedTotal_delta_max end),
		sm.cBidAskAvgVolume_delta_max = (case when sc.cBidAskAvgVolume_delta > sm.cBidAskAvgVolume_delta_max then sc.cBidAskAvgVolume_delta else sm.cBidAskAvgVolume_delta_max end)
	from #t_nnPeriodsData_scale_max sm
	left outer join #t_nnImportCurrent_scale sc on 1=1
	
	
	


	-- масштабируем данные примеров
	update d
	set d.copen = (d.copen - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.chigh = (d.chigh - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.clow = (d.clow - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,	
		d.cclose = (d.cclose - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.Volume = d.Volume/sm.Volume_delta_max,
		d.ABV = (d.ABV - s.ABV_first)/(sm.ABV_delta_max*2)+0.5,
		d.ABVMini = (d.ABVMini - s.ABVMini_first)/(sm.ABVMini_delta_max*2)+0.5,
		d.ABMmPosition0 = (d.ABMmPosition0 - s.ABMmPosition0_first)/(sm.ABMmPosition0_delta_max*2)+0.5,
		d.ABMmPosition1 = (d.ABMmPosition1 - s.ABMmPosition1_first)/(sm.ABMmPosition1_delta_max*2)+0.5,
		d.ABMmPosition0_M5 = (d.ABMmPosition0_M5 - s.ABMmPosition0_M5_first)/(sm.ABMmPosition0_M5_delta_max*2)+0.5,
		d.ABMmPosition1_M5 = (d.ABMmPosition1_M5 - s.ABMmPosition1_M5_first)/(sm.ABMmPosition1_M5_delta_max*2)+0.5,
		d.BSV = (d.BSV - s.BSV_first)/(sm.BSV_delta_max*2)+0.5,
		d.BSVMini = (d.BSVMini - s.BSVMini_first)/(sm.BSVMini_delta_max*2)+0.5,
		d.BSP = (d.BSP - s.BSP_first)/(sm.BSP_delta_max*2)+0.5,
		d.cBidAskMovedTotal = (d.cBidAskMovedTotal - s.cBidAskMovedTotal_first)/(sm.cBidAskMovedTotal_delta_max*2)+0.5,
		d.cBidAskAvgVolume = (d.cBidAskAvgVolume - s.cBidAskAvgVolume_first)/(sm.cBidAskAvgVolume_delta_max*2)+0.5
	from nnPeriodsData d WITH(NOLOCK)
	left outer join #t_nnPeriodsData_scale s on s.idnDataLast = d.idnDataLast
	left outer join #t_nnPeriodsData_scale_max sm on 1=1
	where d.ParamsIdentifyer = @pParamsIdentifyer
	

	-- масштабируем текущие данные
	update d
	set d.copen = (d.copen - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.chigh = (d.chigh - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.clow = (d.clow - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,	
		d.cclose = (d.cclose - s.cclose_first)/(sm.cclose_delta_max*2)+0.5,
		d.Volume = d.Volume/sm.Volume_delta_max,
		d.ABV = (d.ABV - s.ABV_first)/(sm.ABV_delta_max*2)+0.5,
		d.ABVMini = (d.ABVMini - s.ABVMini_first)/(sm.ABVMini_delta_max*2)+0.5,
		d.ABMmPosition0 = (d.ABMmPosition0 - s.ABMmPosition0_first)/(sm.ABMmPosition0_delta_max*2)+0.5,
		d.ABMmPosition1 = (d.ABMmPosition1 - s.ABMmPosition1_first)/(sm.ABMmPosition1_delta_max*2)+0.5,
		d.ABMmPosition0_M5 = (d.ABMmPosition0_M5 - s.ABMmPosition0_M5_first)/(sm.ABMmPosition0_M5_delta_max*2)+0.5,
		d.ABMmPosition1_M5 = (d.ABMmPosition1_M5 - s.ABMmPosition1_M5_first)/(sm.ABMmPosition1_M5_delta_max*2)+0.5,
		d.BSV = (d.BSV - s.BSV_first)/(sm.BSV_delta_max*2)+0.5,
		d.BSVMini = (d.BSVMini - s.BSVMini_first)/(sm.BSVMini_delta_max*2)+0.5,
		d.BSP = (d.BSP - s.BSP_first)/(sm.BSP_delta_max*2)+0.5,
		d.cBidAskMovedTotal = (d.cBidAskMovedTotal - s.cBidAskMovedTotal_first)/(sm.cBidAskMovedTotal_delta_max*2)+0.5,
		d.cBidAskAvgVolume = (d.cBidAskAvgVolume - s.cBidAskAvgVolume_first)/(sm.cBidAskAvgVolume_delta_max*2)+0.5
	from nnImportCurrent d WITH(NOLOCK)
	left outer join #t_nnImportCurrent_scale s on 1=1
	left outer join #t_nnPeriodsData_scale_max sm on 1=1
	where d.ParamsIdentifyer = @pParamsIdentifyer

	-- теперь данные в таблицах nnPeriodsData и nnImportCurrent отмасштабированы

	
	--select * from nnPeriodsData
	--select * from nnImportCurrent
	--select * from #t_nnPeriodsData_scale
	--select * from #t_nnPeriodsData_scale_max
	--select * from nnSettingsPeriodsParameters
	

	--select * from #t_nnPeriodsData_scale order by ccorr desc
	--select * from #t_nnPeriodsData_scale_max
	

	-- выбираем исторические данные до конца дня
	If object_ID('tempdb..#t_TradeDaysHistory') Is not Null drop table #t_TradeDaysHistory
	
	select s.idnDataLast, s.ccorr, s.idnDataFirst, d2.idn as idnData, d2.cdate, d2.ctime, d2.copen, d2.chigh, d2.clow, d2.cclose
	into #t_TradeDaysHistory
	from #t_nnPeriodsData_scale s
	left outer join ntPeriodsData d1 WITH(NOLOCK index=idnindex) on d1.idn = s.idnDataLast
	left outer join ntPeriodsData d2 WITH(NOLOCK index=index4) on 
			d2.CurrencyId = d1.CurrencyId
		and d2.DataSourceId = d1.DataSourceId
		and d2.PeriodMinutes = d1.PeriodMinutes
		and d2.cdate = d1.cdate
		and d2.idn >= d1.idn
		and d2.PeriodMultiplicator = d1.PeriodMultiplicator
	order by s.ccorr desc, s.idnDataLast, d2.idn
	/*
CREATE INDEX [idnDataLastIndex] ON [dbo].[#t_TradeDaysHistory] 
([idnDataLast] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]	
CREATE INDEX [idnDataIndex] ON [dbo].[#t_TradeDaysHistory] 
([idnData] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]	
	*/

	--select * from #t_TradeDaysHistory order by ccorr desc, idnDataLast, idnData
	--select distinct idnDataLast from #t_TradeDaysHistory
/*
	select idnDataLast, d.*, p.*
	from #t_TradeDaysHistory d
	left outer join ntSettingsFilesParameters_cn p on p.ParamsIdentifyer = @pParamsIdentifyer
	order by d.ccorr desc, d.idnDataLast, d.idnData
*/
















--------------------------------------------
	-- начинаем расчет общих показателей
	delete from nnCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer
/*
	insert into nnCorrResultsReport (ParamsIdentifyer,
		idnData,
		cdate,
		ctime,
		ccorr,
		FirstMove, -- первое движение больше чем StopLoss (количество пунктов)
		FirstMoveCorrection, -- коррекция перед первым движением больше чем StopLoss (количество пунктов)
		ChighMax_Daily, -- колическво пунктов вверх до конца дня
		ClowMin_Daily, -- колическво пунктов вниз до конца дня
		TakeProfit_isOk_AtOnce -- количество пунктов больше TakeProfit сразу (без срабатывания StopLoss)
		)
*/
		
	If object_ID('tempdb..#nnCorrResultsReport') Is not Null drop table #nnCorrResultsReport
	
	
	
	
	select  --@pParamsIdentifyer as ParamsIdentifyer,
		s.idnDataLast as idnDataLast,
		d1.cclose as ccloseLast,
		d1.cdate,
		d1.ctime,
		s.ccorr,
		--convert(int,null) as FirstMoveIdnData, -- df.idnData
		--convert(int,null) as FirstCorrectionIdnDataLast,
		convert(real,null) as FirstMove, -- первое движение больше чем StopLoss (количество пунктов)
		convert(real,null) as FirstMoveCorrection, -- коррекция перед первым движением больше чем StopLoss (количество пунктов)
		convert(real,null) as ChighMax_Daily, -- колическво пунктов вверх до конца дня
		convert(real,null) as ClowMin_Daily, -- колическво пунктов вниз до конца дня
		--convert(real,null) as TakeProfit_isOk_AtOnce, -- количество пунктов больше TakeProfit сразу (без срабатывания StopLoss)
		convert(real,null) as ChighMax_AtOnce, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		convert(real,null) as ClowMin_AtOnce -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	into #nnCorrResultsReport
	from #t_nnPeriodsData_scale s
	left outer join ntSettingsFilesParameters_cn p WITH(NOLOCK) on p.ParamsIdentifyer = @pParamsIdentifyer -- параметры текушего ParamsIdentifyer
	left outer join #t_TradeDaysHistory d1 on d1.idnData = s.idnDataLast -- первая запись в таблице с последующими данными
	order by s.ccorr desc
	
	
		
	
	/*	
	
	-- сначала вычисляем направление первого движения больше чем StopLoss (количество пунктов)
	select  @pParamsIdentifyer as ParamsIdentifyer,
		s.idnDataLast as idnDataLast,
		d1.cclose as ccloseLast,
		d1.cdate,
		d1.ctime,
		s.ccorr,
		convert(int,null) as FirstMoveIdnData, -- df.idnData
		convert(int,null) as FirstCorrectionIdnDataLast,
		case when (df.idnData is not null) and (df.chigh > (d1.cclose + (p.StopLoss*p.OnePoint))) then (df.chigh - d1.cclose)
			 when (df.idnData is not null) and (df.clow  < (d1.cclose - (p.StopLoss*p.OnePoint))) then (df.clow - d1.cclose)
			 when (df.idnData is null) then 0
			 else 0 
		end as FirstMove, -- первое движение больше чем StopLoss (количество пунктов)
		convert(real,null) as FirstMoveCorrection, -- коррекция перед первым движением больше чем StopLoss (количество пунктов)
		convert(real,null) as ChighMax_Daily, -- колическво пунктов вверх до конца дня
		convert(real,null) as ClowMin_Daily, -- колическво пунктов вниз до конца дня
		convert(real,null) as TakeProfit_isOk_AtOnce, -- количество пунктов больше TakeProfit сразу (без срабатывания StopLoss)
		convert(real,null) as ChighMax_AtOnce, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		convert(real,null) as ClowMin_AtOnce -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	into #nnCorrResultsReport
	from #t_nnPeriodsData_scale s
	left outer join ntSettingsFilesParameters_cn p on p.ParamsIdentifyer = @pParamsIdentifyer -- параметры текушего ParamsIdentifyer
	left outer join #t_TradeDaysHistory d1 on d1.idnData = s.idnDataLast -- первая запись в таблице с последующими данными
	left outer join #t_TradeDaysHistory df on df.idnDataLast = s.idnDataLast -- первая запись с движением больше чем StopLoss
		and df.idnData > d1.idnData
		and df.idnData = (select min(idnData) 
						 from #t_TradeDaysHistory t 
						 where t.idnDataLast = s.idnDataLast 
						  and t.idnData > s.idnDataLast
						  and ((t.chigh > (d1.cclose + (p.StopLoss*p.OnePoint))) or (t.clow < (d1.cclose - (p.StopLoss*p.OnePoint))))	
						)
	order by s.ccorr desc
	
	--select * from #nnCorrResultsReport where idnDataLast = 776631
	
	
						
						
					
	-- теперь вычисляем первый бар, у которого коррекция превысила StopLoss
	--select d1.cclose, (d1.cclose - (p.StopLoss*p.OnePoint)), *
	update r set r.FirstCorrectionIdnDataLast = df.idnData
	from #nnCorrResultsReport r
	left outer join ntSettingsFilesParameters_cn p on p.ParamsIdentifyer = @pParamsIdentifyer -- параметры текушего ParamsIdentifyer
	left outer join #t_TradeDaysHistory d1 on d1.idnData = r.idnDataLast -- первая запись в таблице с последующими данными
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast -- первая запись с коррекцией больше чем StopLoss
		and df.idnData > r.idnDataLast
		and df.idnData = (select min(t.idnData) 
						 from #t_TradeDaysHistory t 
						 where t.idnDataLast = r.idnDataLast 
						  and t.idnData > r.idnDataLast
						  and  ((r.FirstMove < 0) and (t.chigh > (d1.cclose + (p.StopLoss*p.OnePoint))) -- если первое движение было вниз, то ищем крайний бар коррекции вверх
								or 
								(r.FirstMove > 0) and (t.clow < (d1.cclose - (p.StopLoss*p.OnePoint))))	-- если первое движение было вверх, то ищем крайний бар коррекции вниз
						)
	

	

	
	-- вычисляем максимальный размер первого движения больше чем StopLoss (количество пунктов) (берем все бары до того как коррекция превысила StopLoss)
	
	If object_ID('tempdb..#t_chighMax') Is not Null drop table #t_chighMax
	If object_ID('tempdb..#t_clowMin') Is not Null drop table #t_clowMin
	
	select  r.idnDataLast, 
			max(df.chigh) as chighMax,
			convert(int,null) as FirstMoveIdnData,
			convert(real,null) as FirstMoveCorrection
	into #t_chighMax
	from #nnCorrResultsReport r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast -- первая запись с коррекцией больше чем StopLoss
		and df.idnData > r.idnDataLast
		and ((df.idnData < r.FirstCorrectionIdnDataLast) or (r.FirstCorrectionIdnDataLast is null))
	where r.FirstMove > 0 -- берем записи, у которых первое движение было вверх
	group by r.idnDataLast

	select  r.idnDataLast, 
			min(df.clow) as clowMin,
			convert(int,null) as FirstMoveIdnData,
			convert(real,null) as FirstMoveCorrection
	into #t_clowMin
	from #nnCorrResultsReport r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast -- первая запись с коррекцией больше чем StopLoss
		and df.idnData > r.idnDataLast
		and ((df.idnData < r.FirstCorrectionIdnDataLast) or (r.FirstCorrectionIdnDataLast is null))
	where r.FirstMove < 0 -- берем записи, у которых первое движение было вниз
	group by r.idnDataLast
	
	
	
	-- вычисляем последний бар первого движения
	--select *
	update r
	set r.FirstMoveIdnData = df.idnData
	from #t_chighMax r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast
		and df.idnData > r.idnDataLast
		and df.chigh = r.chighMax
		and df.idnData = (select min(idnData) from #t_TradeDaysHistory where idnDataLast = r.idnDataLast
							and idnData > r.idnDataLast
							and chigh = r.chighMax) -- первый бар с нужным chigh


	--select *
	update r
	set r.FirstMoveIdnData = df.idnData
	from #t_clowMin r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast
		and df.idnData > r.idnDataLast
		and df.clow = r.clowMin
		and df.idnData = (select min(idnData) from #t_TradeDaysHistory where idnDataLast = r.idnDataLast
							and idnData > r.idnDataLast
							and clow = r.clowMin) -- первый бар с нужным chigh
	
	
	
	-- вычисляем размер коррекции перед первым движением
	--select *
	update r
	set r.FirstMoveCorrection = df.clow
	from #t_chighMax r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast
		and df.idnData > r.idnDataLast
		and df.idnData <= r.FirstMoveIdnData
		and df.clow = (select min(clow) from #t_TradeDaysHistory where idnDataLast = r.idnDataLast
							and idnData > r.idnDataLast
							and idnData <= r.FirstMoveIdnData) -- бар с минимальным clow до первого движения вверх

	update r
	set r.FirstMoveCorrection = df.chigh
	from #t_clowMin r
	left outer join #t_TradeDaysHistory df on df.idnDataLast = r.idnDataLast
		and df.idnData > r.idnDataLast
		and df.idnData <= r.FirstMoveIdnData
		and df.chigh = (select max(chigh) from #t_TradeDaysHistory where idnDataLast = r.idnDataLast
							and idnData > r.idnDataLast
							and idnData <= r.FirstMoveIdnData) -- бар с максимальным chigh до первого движения вниз



--	select * from #t_clowMin
	
	
	
	--select *
	update r
	set r.FirstMove = (t.chighMax - r.ccloseLast),
		r.FirstMoveIdnData = t.FirstMoveIdnData,
		r.FirstMoveCorrection = (t.FirstMoveCorrection - r.ccloseLast)
	from #nnCorrResultsReport r
	left outer join #t_chighMax t on t.idnDataLast = r.idnDataLast
	where r.FirstMove > 0 -- берем записи, у которых первое движение было вверх

	--select *
	update r
	set r.FirstMove = (t.clowMin - r.ccloseLast),
		r.FirstMoveIdnData = t.FirstMoveIdnData,
		r.FirstMoveCorrection = (t.FirstMoveCorrection - r.ccloseLast)
	from #nnCorrResultsReport r
	left outer join #t_clowMin t on t.idnDataLast = r.idnDataLast
	where r.FirstMove < 0 -- берем записи, у которых первое движение было вверх


	
	-- если первого движения больше чем StopLoss не было - то просто ставим FirstMoveCorrection = 0 (в дальнейшем можно будет считать максимальное движение)	
	update #nnCorrResultsReport set FirstMoveCorrection = 0 where FirstMoveCorrection is null
*/



	-- теперь поля #nnCorrResultsReport.FirstMove,FirstMoveIdnData,FirstMoveCorrection заполнены
--------------------------------------------------

	-- рассчитываем поля ChighMax_Daily и ClowMin_Daily
	If object_ID('tempdb..#t_Daily') Is not Null drop table #t_Daily
	
	select  idnDataLast, 
			min(clow) as ClowMin_Daily, 
			max(chigh) as ChighMax_Daily
	into #t_Daily
	from #t_TradeDaysHistory 
	where idnData <> idnDataLast
	group by idnDataLast
	
	--select * 
	update r
	set r.ChighMax_Daily = isnull(d.ChighMax_Daily,r.ccloseLast) - r.ccloseLast,
		r.ClowMin_Daily = -(isnull(d.ClowMin_Daily,r.ccloseLast) - r.ccloseLast)
	from #nnCorrResultsReport r
	left outer join #t_Daily d on d.idnDataLast = r.idnDataLast
	
--------------------------------------------------

	-- рассчитываем поля ChighMax_AtOnce и ClowMin_AtOnce
	
--		convert(real,null) as ChighMax_AtOnce, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
--		convert(real,null) as ClowMin_AtOnce -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	If object_ID('tempdb..#t_ChighMax_AtOnce') Is not Null drop table #t_ChighMax_AtOnce
	If object_ID('tempdb..#t_ClowMin_AtOnce') Is not Null drop table #t_ClowMin_AtOnce
	
	-- select * from #t_TradeDaysHistory
	
	select r.idnDataLast, max(d1.chigh) as ChighMax_AtOnce
	into #t_ChighMax_AtOnce
	from #nnCorrResultsReport r
	left outer join ntSettingsFilesParameters_cn p WITH(NOLOCK) on p.ParamsIdentifyer = @pParamsIdentifyer -- параметры текушего ParamsIdentifyer
	left outer join #t_TradeDaysHistory d1 on d1.idnDataLast = r.idnDataLast 
		and d1.idnData <> r.idnDataLast
		and d1.chigh > r.ccloseLast -- все бары, зашедшие выше текущего
	left outer join #t_TradeDaysHistory d2 on d2.idnDataLast = r.idnDataLast
		and d2.idnData <> r.idnDataLast
		and d2.idnData < d1.idnData -- коррекция до движения
		and d2.clow <= (r.ccloseLast - (p.StopLoss*p.OnePoint)) -- цена зашла ниже чем StopLoss
	where d2.idnData is null -- до движения цена не выбила StopLoss
	group by r.idnDataLast

	select r.idnDataLast, min(d1.clow) as ClowMin_AtOnce
	into #t_ClowMin_AtOnce
	from #nnCorrResultsReport r
	left outer join ntSettingsFilesParameters_cn p WITH(NOLOCK) on p.ParamsIdentifyer = @pParamsIdentifyer -- параметры текушего ParamsIdentifyer
	left outer join #t_TradeDaysHistory d1 on d1.idnDataLast = r.idnDataLast 
		and d1.idnData <> r.idnDataLast
		and d1.clow < r.ccloseLast -- все бары, зашедшие ниже текущего
	left outer join #t_TradeDaysHistory d2 on d2.idnDataLast = r.idnDataLast
		and d2.idnData <> r.idnDataLast
		and d2.idnData < d1.idnData -- коррекция до движения
		and d2.chigh >= (r.ccloseLast + (p.StopLoss*p.OnePoint)) -- цена зашла выше чем StopLoss
	where d2.idnData is null -- до движения цена не выбила StopLoss
	group by r.idnDataLast

-- select * from #t_ChighMax_AtOnce
-- select * from #t_ClowMin_AtOnce

	--select * 
	update r
	set r.ChighMax_AtOnce = (isnull(t.ChighMax_AtOnce,r.ccloseLast) - r.ccloseLast)
	from #nnCorrResultsReport r
	left outer join #t_ChighMax_AtOnce t on t.idnDataLast = r.idnDataLast

	update r
	set r.ClowMin_AtOnce = -(isnull(t.ClowMin_AtOnce,r.ccloseLast) - r.ccloseLast)
	from #nnCorrResultsReport r
	left outer join #t_ClowMin_AtOnce t on t.idnDataLast = r.idnDataLast
	


	-- select * from #nnCorrResultsReport where idnDataLast = 853744
	-- select 1, * from #nnCorrResultsReport --where idnDataLast = 1038447


	update #nnCorrResultsReport
	set FirstMove = case when ChighMax_AtOnce >= ClowMin_AtOnce then ChighMax_AtOnce
						 when ClowMin_AtOnce >= ChighMax_AtOnce then -ClowMin_AtOnce
					else 0 end,
		FirstMoveCorrection = case when ChighMax_AtOnce >= ClowMin_AtOnce then -ClowMin_AtOnce
						 when ClowMin_AtOnce >= ChighMax_AtOnce then ChighMax_AtOnce
					else 0 end					
	
	
	--select 1, * from #nnCorrResultsReport
	
	
	-- масштабируем общие показатели
	--select *
	update r
	set r.FirstMove = r.FirstMove/(sm.cclose_delta_max*2)+0.5, 
		r.FirstMoveCorrection = r.FirstMoveCorrection/(sm.cclose_delta_max*2)+0.5, 
		r.ChighMax_Daily = r.ChighMax_Daily/(sm.cclose_delta_max*2)+0.5, 
		r.ClowMin_Daily = r.ClowMin_Daily/(sm.cclose_delta_max*2)+0.5, 
		r.ChighMax_AtOnce = r.ChighMax_AtOnce/(sm.cclose_delta_max*2)+0.5, 
		r.ClowMin_AtOnce = r.ClowMin_AtOnce/(sm.cclose_delta_max*2)+0.5
	from #nnCorrResultsReport r
	left outer join #t_nnPeriodsData_scale_max sm on 1=1

	-- теперь общие показатели отмасштабированы

	--select 2, * from #nnCorrResultsReport
	--select 3, * from #t_nnPeriodsData_scale_max

	
	insert into nnCorrResultsReport (ParamsIdentifyer, idnDataLast, cdate, ctime, ccorr, FirstMove, FirstMoveCorrection, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce)
	select @pParamsIdentifyer, idnDataLast, cdate, ctime, ccorr, FirstMove, FirstMoveCorrection, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce
	from #nnCorrResultsReport
	order by ccorr desc


	-- сохраняем в постоянную таблицу множители для масштабирования
	delete from nnPeriodsData_scale_max where ParamsIdentifyer = @pParamsIdentifyer
	
	insert into nnPeriodsData_scale_max (ParamsIdentifyer, cclose_delta_max, Volume_delta_max, ABV_delta_max, ABVMini_delta_max, ABMmPosition0_delta_max, ABMmPosition1_delta_max, ABMmPosition0_M5_delta_max, ABMmPosition1_M5_delta_max, BSV_delta_max, BSVMini_delta_max, BSP_delta_max, cBidAskMovedTotal_delta_max, cBidAskAvgVolume_delta_max)
	select @pParamsIdentifyer, cclose_delta_max, Volume_delta_max, ABV_delta_max, ABVMini_delta_max, ABMmPosition0_delta_max, ABMmPosition1_delta_max, ABMmPosition0_M5_delta_max, ABMmPosition1_M5_delta_max, BSV_delta_max, BSVMini_delta_max, BSP_delta_max, cBidAskMovedTotal_delta_max, cBidAskAvgVolume_delta_max
	from #t_nnPeriodsData_scale_max





----------------------------------
	

/*
	-- входные данные примеров для обучения
	select * from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer
	
	-- результаты для обучения
	select * from nnCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer

	-- текущие входные данные
	select * from nnImportCurrent where ParamsIdentifyer = @pParamsIdentifyer

	-- настройки для обучения НС
	select * from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer
	*/
	
	-- проверяем, чтобы количество данных в таблицах для обучения НС совпадало
	select @cntRecords_nnPeriodsData = count(*) from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer
	select @cntRecords_nnCorrResultsReport = count(*) from nnCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer
	select @cntRecords_nnImportCurrent = count(*) from nnImportCurrent where ParamsIdentifyer = @pParamsIdentifyer

	select @resultMessage = 0
	if ((@cntRecords_nnImportCurrent * @cntRecords_nnCorrResultsReport = @cntRecords_nnPeriodsData) and (@cntRecords_nnPeriodsData > 0)) select @resultMessage = 1


END
--go
--exec nnpPrepareDataForNnTrain '6E_15_120_PA211'

