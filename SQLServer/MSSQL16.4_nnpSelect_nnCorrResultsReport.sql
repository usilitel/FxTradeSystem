
alter PROCEDURE nnpSelect_nnCorrResultsReport (@pParamsIdentifyer VARCHAR(50))
AS BEGIN 
-- ��������� ������� ���������� ��� �������� ��
-- ��� ���������� ��������� � ������ ��������

SET NOCOUNT ON

	--select FirstMove as FirstMove, FirstMoveCorrection, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce
	select ChighMax_AtOnce as FirstMove, FirstMoveCorrection, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce
	from nnCorrResultsReport WITH(NOLOCK) 
	where ParamsIdentifyer = @pParamsIdentifyer
	order by ccorr desc, idnDataLast

END

-- ������� ���������� ��� �������� ��
-- exec nnpSelect_nnCorrResultsReport '6E_15_120_PA211'