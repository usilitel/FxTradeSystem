

alter PROCEDURE ntp_rt_CheckAlerts_single (
	-- ��������� ������� ��� ���������� ������, �������� � ������� nt_rt_parameters_ParamsIdentifyersSets
	-- ������� #ntImportCurrentChartAverageValues ������ ���� ���������	
	
		@activation_ParamsIdentifyer varchar(50), -- ParamsIdentifyer, ������� ���������� �������� ������� ������
		@ParamsIdentifyersSetId int, -- id ������ ParamsIdentifyer-�� �� ������� nt_rt_parameters_ParamsIdentifyersSets (�� �������� ����� �������� ������)
		-- ��������� ������
		--@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
		@param_cntSignalsBeforeDeal int, -- ���������� �������� ������, ������ ��� ���������� ������
		--@param_volume real,
		@param_IsOnlyOneActiveDeal int, -- 1 = ������ ���� �������� �������  � ���� ������� (�������� ���� Buy � ���� Sell ������������), 0 = �������������� ����� �������� ������� (1 ������ = 1 ������)
		@param_IsOpenOppositeDeal int, -- 1 = ���� ��������� ��������������� ������ - �� ��������� ��� �������� ������� � ��������� ������� �� �������, 0 = ��������� ������� ������ �� SL � TP
		@param_cntBuySignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntSellSignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntBuySignalsLimit_Stop int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
		@param_cntSellSignalsLimit_Stop int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
		@result int Output -- ������������ ��������: 0 - ��� �������, 1 - ������ �� �������, 2 - ������ �� �������
)
AS BEGIN 

SET NOCOUNT ON




	
	-- ��������������� ����������
	declare @cntBuySignals int -- ���������� �������� �� �������
	declare @cntSellSignals int -- ���������� �������� �� �������

		
	select @result = 0
	
	If object_ID('tempdb..#ntAverageValuesResults') Is not Null drop table #ntAverageValuesResults



	-- ������� �� ������� ntAverageValuesResults �������� ������ �� ������ ��� ParamsIdentifyer-�� �� ������� ����
	select v.* 
	into #ntAverageValuesResults
	from #ntImportCurrentChartAverageValues c
	left outer join ntSettingsFilesParameters_cn fp on fp.ParamsIdentifyer = @activation_ParamsIdentifyer -- �������� ParamsIdentifyer (����� ��� ����������� ���������� ������� ��)
	left outer join nt_rt_parameters_ParamsIdentifyersSets ps on -- ������ ��� ParamsIdentifyer-�
			ps.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and ps.is_active = 1
	left outer join ntSettingsFilesParameters_cn fp2 on fp2.ParamsIdentifyer = ps.ParamsIdentifyer -- ������ ��� ParamsIdentifyer-�
	left outer join ntAverageValuesResults v on -- ������ �� ������ ��� ParamsIdentifyer-�� �� ������� ����
				v.cdatetime_last = c.cdatetime
			and v.copen_last = c.copen and v.chigh_last = c.chigh and v.clow_last = c.clow and v.cclose_last = c.cclose
			and v.ParamsIdentifyer = fp2.ParamsIdentifyer 



	--select * from #ntAverageValuesResults

	-- ��������� ���������� �������� �� �������
	select @cntBuySignals = count(*)
	from #ntAverageValuesResults vb
	left outer join nt_rt_parameters_ParamsIdentifyersSets p on -- ������ ��� ParamsIdentifyer-�
			p.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and p.is_active = 1
		and p.ParamsIdentifyer = vb.ParamsIdentifyer
	where	(
			 vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_AtOnce_up_AvgCnt-vb.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_Daily_up_AvgCnt-vb.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta	
		and (
			 vb.ClowMin_AtOnce_Avg <= p.limit_ClowMin_AtOnce_Avg
			 )
		and
			abs(vb.ChighMax_AtOnce_Avg-vb.ClowMin_AtOnce_Avg) >= p.limit_ChighMax_ClowMin_AtOnce_Avg_delta	

	
	
	-- ��������� ���������� �������� �� �������
	select @cntSellSignals = count(*)
	from #ntAverageValuesResults vs
	left outer join nt_rt_parameters_ParamsIdentifyersSets p on -- ������ ��� ParamsIdentifyer-�
			p.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and p.is_active = 1
		and p.ParamsIdentifyer = vs.ParamsIdentifyer
	where	(
			 vs.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_AtOnce_up_AvgCnt-vs.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vs.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_Daily_up_AvgCnt-vs.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
		and (
			 vs.ChighMax_AtOnce_Avg <= p.limit_ClowMin_AtOnce_Avg
			 )
		and
			abs(vs.ChighMax_AtOnce_Avg-vs.ClowMin_AtOnce_Avg) >= p.limit_ChighMax_ClowMin_AtOnce_Avg_delta	


	-- ���������, ����������� �� ������� ��� ���������� ������
	select @result = 
		case when (
								@cntBuySignals >= @param_cntBuySignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
								and
								@cntSellSignals <= @param_cntSellSignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
								)
			then 1
			when (
								@cntSellSignals >= @param_cntSellSignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
								and
								@cntBuySignals <= @param_cntBuySignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
								)
			then 2
			else 0
			end
			
			
			
				

/*

		@param_cntBuySignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntSellSignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
		@param_cntBuySignalsLimit_Stop int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
		@param_cntSellSignalsLimit_Stop int -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������

*/



END



