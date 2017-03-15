
select * from nnImportCurrent where ParamsIdentifyer = '6E_15_120_PA211'
select * from ntImportCurrent where ParamsIdentifyer = '6E_15_120_PA211'


-- ������� ������ ��� �������� ��
exec nnpPrepareDataForNnTrain '6E_15_120_PA211'

	-- ������� ������ �������� ��� ��������
	select * from nnPeriodsData where ParamsIdentifyer = '6E_15_120_PA211'
	-- ���������� ��� �������� ��
	select * from nnCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211'
	-- ������� ������� ������
	select * from nnImportCurrent where ParamsIdentifyer = '6E_15_120_PA211'
	-- ��������� ��� �������� ��
	select * from nnSettingsPeriodsParameters where ParamsIdentifyer = '6E_15_120_PA211'
	
/*
	 update nnSettingsPeriodsParameters set FieldNameHistory = 'ABVMini' where FieldNameHistory = 'ABVMini_'
	 update nnSettingsPeriodsParameters set FieldNameHistory = 'ABV' where FieldNameHistory = 'ABV_'
	 update nnSettingsPeriodsParameters set FieldNameHistory = 'cclose' where FieldNameHistory = 'cclose_'

	 update nnSettingsPeriodsParameters set FieldNameHistory = 'ABVMini_' where FieldNameHistory = 'ABVMini'
	 update nnSettingsPeriodsParameters set FieldNameHistory = 'ABV_' where FieldNameHistory = 'ABV'
	 update nnSettingsPeriodsParameters set FieldNameHistory = 'cclose_' where FieldNameHistory = 'cclose'
*/
	
-- ������� ������� ������ �������� ��� �������� ��
exec nnpSelect_nnPeriodsData '6E_15_120_PA211'

-- ������� ���������� ��� �������� ��
exec nnpSelect_nnCorrResultsReport '6E_15_120_PA211'

-- ������� ������� ������� ������
exec nnpSelect_nnImportCurrent '6E_15_120_PA211'


----------------------------------------------------------
----------------------------------------------------------



-- �������� ���������


-- alter 
-- exec tempproc3

1111

alter PROCEDURE tempproc3
AS BEGIN 
SET NOCOUNT ON
/*
	Select t1.idn, t1.val2/1000 as c1, t2.val2/1000 as r1
	From test1_v1 t1
	left outer join test1_v1 t2 on t2.idn = t1.idn+1
	where t2.val2 is not null
	order by t1.idn
*/
	Select t1.idn, t1.c1/1000 as c2, t1.c2/1000 as c1, t2.c2/1000 as r1
	From test1 t1
	left outer join test1 t2 on t2.idn = t1.idn+1
	where t2.c2 is not null
	order by t1.idn

END
go
exec tempproc3


CREATE TABLE [dbo].[test1] (
idn int identity(1,1),
[val2] real
)

	Select t1.val2/1000, t2.val2/1000
	From test1 t1
	left outer join test1 t2 on t2.idn = t1.idn+1
	where t2.val2 is not null
	order by t1.idn


-- drop table [dbo].[test1]
CREATE TABLE [dbo].[test1] (
idn int identity(1,1),
[c1] real,
[c2] real,
[r1] real
)
select * from test1 order by idn
update test1 set r1=null where idn = 144
alter table test1 drop column r1


--------------------------


-- ������ �������� � ������ --

-- ntpSearchAverageValues
-- ��������� ���������� � ������� ntImportCurrent_NoAverageValues �� ������� ����, �� ������� ����� ���������� ��� �� ����������.

-- ntpCorrResultsReport -- exec ntpCorrResultsReport 120, '1_5'
-- ��������� ���� ���������� �� �������, ����������� � ������� ntCorrResults � ��������� ������� ntCorrResultsReport (����� ���������� �� ������ 15 ��������)

-- ntpCorrResultsPeriodsData
-- ��������� ��� ���������� ������� ntCorrResultsPeriodsData (�������) �������

-- ntpCorrResultsAverageValues
-- ���������: 
-- 1) � ������� ntCorrResultsReport ����������� ������������ ��������
-- 2) � ������� ntAverageValuesResults ������������ ����� ������������ ��������

-- ntpImportCurrentChartAverageValues
-- ������� ��� �������: 
-- ������� ntImportCurrentChartAverageValues �.�. ��� ���������
-- ���������: 
-- 1) � ������� ntImportCurrentChartAverageValues (������� ������) ����������� ����� ������������ �������� (�� ������� ntAverageValuesResults)

-- delete from ntCorrResultsReport
select * from ntCorrResults (nolock) where ParamsIdentifyer = '6E_15_120_PA211' order by ccorr desc
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntAverageValuesResults where ParamsIdentifyer = 'qsSi_15_120_PA211' 
select * from ntCorrResultsPeriodsData 
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '6E_15_120_PA211' order by idn
select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = '6E_15_120_PA211'

select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntImportCurrent where ParamsIdentifyer = '6E_15_120_PA211' 



alter 
create PROCEDURE nnpPrepareDataForNnTrain_test
AS BEGIN 
SET NOCOUNT ON
/*
	Select t1.idn, t1.val2/1000 as c1, t2.val2/1000 as r1
	From test1_v1 t1
	left outer join test1_v1 t2 on t2.idn = t1.idn+1
	where t2.val2 is not null
	order by t1.idn
*/
	Select t1.idn, t1.c1/1000 as c2, t1.c2/1000 as c1, t2.c2/1000 as r1
	From test1 t1
	left outer join test1 t2 on t2.idn = t1.idn+1
	where t2.c2 is not null
	order by t1.idn

END
go
exec nnpPrepareDataForNnTrain
	 nnpPrepareDataForNnTrain_test



