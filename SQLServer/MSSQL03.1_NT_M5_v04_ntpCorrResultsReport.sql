

-- после расчета  :
-- результаты расчета   наход€тс€ в таблице ntCorrResults
-- делаем процедуру поиска нужных значений

-- select * from ntCorrResultsReport
-- exec ntpCorrResultsReport
-- delete from ntCorrResultsReport
-- drop PROCEDURE ntpCorrResultsReport
--/*
alter PROCEDURE ntpCorrResultsReport (@pDeltaMinutes int, @pParamsIdentifyer VARCHAR(50), @pParamsIdentifyer_Report VARCHAR(50))
AS BEGIN 
-- процедура ищет информацию по запис€м, наход€щимс€ в таблице ntCorrResults
-- и заполн€ет таблицу ntCorrResultsReport

-- @pDeltaMinutes - максимальное отклонение в минутах, до которого истори€ идет в первую очередь
-- @pParamsIdentifyer - ParamsIdentifyer из таблицы ntCorrResults
-- @@pParamsIdentifyer_Report - ParamsIdentifyer, который нужно записать в таблицу ntCorrResultsReport


		SET NOCOUNT ON

		If object_ID('tempdb..#tCCorrMax_CdateCperiod') Is not Null drop table #tCCorrMax_CdateCperiod
		If object_ID('tempdb..#tCCorrMax_Cdate') Is not Null drop table #tCCorrMax_Cdate
		If object_ID('tempdb..#tCPeriodMax') Is not Null drop table #tCPeriodMax
		If object_ID('tempdb..#tctimeAll') Is not Null drop table #tctimeAll
		If object_ID('tempdb..#tCorrResultsReport') Is not Null drop table #tCorrResultsReport
		


		declare @idnMax int
		declare @cdate_current varchar(10)
		declare @ctime_current varchar(5)

		if @pParamsIdentifyer = @pParamsIdentifyer_Report
		begin
			select top 1 0 as idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer
			into #ntImportCurrent
			from ntImportCurrent

			truncate table #ntImportCurrent
			
			insert into #ntImportCurrent (idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer)
			select idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer
			from ntImportCurrent with (nolock)
			where ParamsIdentifyer = @pParamsIdentifyer
			order by idn		
		end
		
		
		select @idnMax = MAX(idn) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @pParamsIdentifyer
		select @cdate_current = cdate, @ctime_current = ctime from #ntImportCurrent where idn = @idnMax


		-- truncate table ntCorrResultsReport
		delete from ntCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer_Report
		


		-- перекидываем данные во временную таблицу
		If object_ID('tempdb..#ntCorrResults') Is not Null drop table #ntCorrResults
		
		select *, convert(int,null) as DeltaMinutes
		into #ntCorrResults
		from ntCorrResults with (nolock)
		where ParamsIdentifyer = @pParamsIdentifyer -- '6E_5_v01_PA2' 
		
		

		-- вычисл€ем deltaMinutes
		update cr
		set DeltaMinutes = 
		  case when     abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2))) > 720
			then 1440 - abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2)))
			else        abs((left(pd.ctime,2)*60)+right(pd.ctime,2) - ((left(c.ctime,2)*60)+right(c.ctime,2)))
		  end
		from #ntCorrResults cr
		left outer join ntPeriodsData pd with (nolock index=idnindex) on pd.idn = cr.idn
		left outer join #ntImportCurrent c with (nolock) on c.idn = @idnMax --(select max(idn) from ntImportCurrent where ParamsIdentifyer = @pParamsIdentifyer)
		
 
		-- удал€ем записи со слишком большим deltaMinutes
		if @pParamsIdentifyer <> @pParamsIdentifyer_Report
			delete from #ntCorrResults where DeltaMinutes > @pDeltaMinutes		

		
		-- максимальные значени€   по дн€м и периодам
		select pd.cdate, (pd.PeriodMinutes*pd.PeriodMultiplicator) as cperiod, max(cr.ccorr) as ccorrMax
		into #tCCorrMax_CdateCperiod
		from #ntCorrResults cr
		left outer join ntPeriodsData pd with (nolock index=idnindex) on pd.idn = cr.idn
		--left outer join ntPeriods p on p.idn_first <= cr.idn and p.idn_last >= cr.idn
		--where cr.ParamsIdentifyer = @pParamsIdentifyer
		group by pd.cdate, pd.PeriodMinutes,pd.PeriodMultiplicator


		-- максимальные значени€   по дн€м
		select cdate, max(ccorrMax) as ccorrMax
		into #tCCorrMax_Cdate
		from #tCCorrMax_CdateCperiod
		group by cdate

		-- период с максимальной  , максимальна€   за день
		select d.cdate, d.ccorrMax, dp.cperiod as cperiodMax
		into #tCPeriodMax
		from #tCCorrMax_Cdate d
		left outer join #tCCorrMax_CdateCperiod dp on dp.cdate = d.cdate and dp.ccorrMax = d.ccorrMax


		-- врем€, разница по времени с текущими данными
		select cr.idn, pd.cdate, pd.ctime, (pd.PeriodMinutes*pd.PeriodMultiplicator) as cperiod, cr.ccorr,
			   cr.deltaMinutes
		into #tctimeAll
		from #ntCorrResults cr
		left outer join ntPeriodsData pd with (nolock index=idnindex) on pd.idn = cr.idn
		--left outer join ntPeriods p on p.idn_first <= cr.idn and p.idn_last >= cr.idn
		left outer join #tCCorrMax_CdateCperiod t on t.cdate = pd.cdate and t.cperiod = (pd.PeriodMinutes*pd.PeriodMultiplicator) and t.ccorrMax = cr.ccorr
		--left outer join ntImportCurrent c on c.idn = @idnMax --(select max(idn) from ntImportCurrent where ParamsIdentifyer = @pParamsIdentifyer)
		where --cr.ParamsIdentifyer = @pParamsIdentifyer
			t.ccorrMax is not null
		order by cr.ccorr desc



		select 
		tm.idn as idnData,
		m.cdate,
		tm.ctime as ctime,
		tm.deltaMinutes as deltaMinutes,
		m.cperiodMax as cperiod,
		m.ccorrmax as ccorr,
		'' as cperiodsAll,
		0 as is_replaced, 
		0 as deltaKmaxPercent, 
		0 as ccorrmax_replaced, 
		0 as cperiodMax_replaced, 
		0 as deltaMinutesMax_replaced, 
		0 as idnmax_replaced
		into #tCorrResultsReport
		from #tCPeriodMax m -- период с максимальной  
		--left outer join #tctimeAll t3 on t3.cdate = m.cdate and t3.cperiod = 3
		--left outer join #tctimeAll t4 on t4.cdate = m.cdate and t4.cperiod = 4
		--left outer join #tctimeAll t5 on t5.cdate = m.cdate and t5.cperiod = 5
		--left outer join #tctimeAll t6 on t6.cdate = m.cdate and t6.cperiod = 6
		--left outer join #tctimeAll t7 on t7.cdate = m.cdate and t7.cperiod = 7
		left outer join #tctimeAll tm on tm.cdate = m.cdate and tm.cperiod = m.cperiodMax -- период с максимальной  

-- select 3, * from #tCorrResultsReport

		if @pParamsIdentifyer = @pParamsIdentifyer_Report
		begin
			insert into ntCorrResultsReport (
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				[cperiodsAll] ,
				[is_replaced] ,
				[deltaKmaxPercent] ,
				[ccorrmax_replaced] ,
				[cperiodMax_replaced] ,
				[deltaMinutesMax_replaced] ,
				[idnmax_replaced] ,
				ParamsIdentifyer
			)
			select  
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				[cperiodsAll] ,
				[is_replaced] ,
				[deltaKmaxPercent] ,
				[ccorrmax_replaced] ,
				[cperiodMax_replaced] ,
				[deltaMinutesMax_replaced] ,
				[idnmax_replaced] ,
				@pParamsIdentifyer_Report
			from #tCorrResultsReport
			order by (case when deltaMinutes <= @pDeltaMinutes then 0 else 1 end), -- @pDeltaMinutes был 120 (2 часа)
					  ccorr desc
					  
					  
			/*
			-- сохран€ем результаты расчета   (потом вернуть, надо будет сделать процедуру котора€ может использовать эту таблицу дл€ пересчета)
			insert into ntCorrResultsReport_history (
				[cdate_current],
				[ctime_current],
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				ParamsIdentifyer 
			)
			select  
				@cdate_current,
				@ctime_current,
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				@pParamsIdentifyer_Report 
			from #tCorrResultsReport
			--order by (case when deltaMinutes <= @pDeltaMinutes then 0 else 1 end), -- @pDeltaMinutes был 120 (2 часа)
			--		  ccorr desc
			*/

		end


		If object_ID('tempdb..#ntCorrResultsReport1') Is not Null
			insert into #ntCorrResultsReport1 (
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				[cperiodsAll] ,
				[is_replaced] ,
				[deltaKmaxPercent] ,
				[ccorrmax_replaced] ,
				[cperiodMax_replaced] ,
				[deltaMinutesMax_replaced] ,
				[idnmax_replaced] ,
				ParamsIdentifyer
			)
			select  
				[idnData] ,
				[cdate] ,
				[ctime] ,
				[deltaMinutes] ,
				[cperiod] ,
				[ccorr] ,
				[cperiodsAll] ,
				[is_replaced] ,
				[deltaKmaxPercent] ,
				[ccorrmax_replaced] ,
				[cperiodMax_replaced] ,
				[deltaMinutesMax_replaced] ,
				[idnmax_replaced] ,
				@pParamsIdentifyer_Report
			from #tCorrResultsReport
			order by (case when deltaMinutes <= @pDeltaMinutes then 0 else 1 end), -- @pDeltaMinutes был 120 (2 часа)
					  ccorr desc
		
		--If object_ID('tempdb..#ntCorrResultsReport1') Is not Null 			select 4, * from #ntCorrResultsReport1



--		select @pParamsIdentifyer_Report
--		select * from ntCorrResultsReport where ParamsIdentifyer = @pParamsIdentifyer_Report

--	If object_ID('tempdb..#ntImportCurrent') Is not Null drop table #ntImportCurrent

END
