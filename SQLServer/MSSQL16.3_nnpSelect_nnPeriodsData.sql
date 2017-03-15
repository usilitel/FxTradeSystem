
alter PROCEDURE nnpSelect_nnPeriodsData (@pParamsIdentifyer VARCHAR(50))
AS BEGIN 
-- процедура выводит входные данные примеров для обучения НС
-- все переменные выводятся в разных столбцах

SET NOCOUNT ON

	declare @i int
	declare @str_FieldList1 varchar(500)
	declare @str_FieldList2 varchar(500)
	declare @str_FieldList3 varchar(500)
	declare @strQuery1 varchar(5000)
	declare @strQuery2 varchar(5000)
	declare @strQuery3 varchar(5000)
	
	select @i = 1
	select @str_FieldList1=''
	select @str_FieldList2=''
	select @str_FieldList3=''

	-- заполняем строковые переменные для создания текстов запросов
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'cclose') = 1
	begin
		select @str_FieldList1=@str_FieldList1+'inputValue' + convert(varchar(500),@i) + ' real,'
		select @str_FieldList2=@str_FieldList2+'inputValue' + convert(varchar(500),@i) + ','
		select @str_FieldList3=@str_FieldList3+'cclose,'
		select @i=@i+1
	end
	
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'ABV') = 1
	begin
		select @str_FieldList1=@str_FieldList1+'inputValue' + convert(varchar(500),@i) + ' real,'
		select @str_FieldList2=@str_FieldList2+'inputValue' + convert(varchar(500),@i) + ','
		select @str_FieldList3=@str_FieldList3+'ABV,'
		select @i=@i+1
	end
	
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'ABVMini') = 1
	begin
		select @str_FieldList1=@str_FieldList1+'inputValue' + convert(varchar(500),@i) + ' real,'
		select @str_FieldList2=@str_FieldList2+'inputValue' + convert(varchar(500),@i) + ','
		select @str_FieldList3=@str_FieldList3+'ABVMini,'
		select @i=@i+1
	end
	
	if right(@str_FieldList1,1)=',' select @str_FieldList1 = left(@str_FieldList1,len(@str_FieldList1)-1)
	if right(@str_FieldList2,1)=',' select @str_FieldList2 = left(@str_FieldList2,len(@str_FieldList2)-1)
	if right(@str_FieldList3,1)=',' select @str_FieldList3 = left(@str_FieldList3,len(@str_FieldList3)-1)
	
	-- текстовые переменные созданы


	-- начинаем создавать тексты запросов
	select @strQuery1 = 'CREATE TABLE #t_nnPeriodsData (idn int identity(1,1),' + @str_FieldList1 + ') ON [PRIMARY]'
	select @strQuery2 = 'insert into #t_nnPeriodsData (' + @str_FieldList2 + ') select ' + @str_FieldList3 + ' from nnPeriodsData WITH(NOLOCK) where ParamsIdentifyer = ''' + @pParamsIdentifyer + ''' order by ccorr desc, idnDataLast, idn'
	select @strQuery3 = 'select ' + @str_FieldList2 + ' from #t_nnPeriodsData order by idn'



	-- выполняем запросы
	If object_ID('tempdb..#t_nnPeriodsData') Is not Null drop table #t_nnPeriodsData

	exec(@strQuery1 + ' ' + @strQuery2 + ' ' + @strQuery3)




/*

		insert into #t_nnPeriodsData_Sample (inputValue)
		select cclose from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer order by ccorr desc, idnDataLast, idn



	If object_ID('tempdb..#t_nnPeriodsData_Sample') Is not Null drop table #t_nnPeriodsData_Sample
	CREATE TABLE #t_nnPeriodsData_Sample (  
		idn int identity(1,1),
		inputValue1 real,
		inputValue2 real,
		inputValue3 real
	) ON [PRIMARY]
	
		insert into #t_nnPeriodsData_Sample (inputValue1,inputValue2,inputValue3) select cclose,ABV,ABVMini from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer order by ccorr desc, idnDataLast, idn

*/

	
	/*
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'cclose') = 1
		insert into #t_nnPeriodsData_Sample (inputValue)
		select cclose from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer order by ccorr desc, idnDataLast, idn
	
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'ABV') = 1
		insert into #t_nnPeriodsData_Sample (inputValue)
		select ABV from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer order by ccorr desc, idnDataLast, idn
	
	if (select count(*) from nnSettingsPeriodsParameters where ParamsIdentifyer = @pParamsIdentifyer and FieldNameHistory = 'ABVMini') = 1
		insert into #t_nnPeriodsData_Sample (inputValue)
		select ABVMini from nnPeriodsData where ParamsIdentifyer = @pParamsIdentifyer order by ccorr desc, idnDataLast, idn
	*/
	
	--select inputValue1,inputValue2,inputValue3 from #t_nnPeriodsData_Sample order by idn

END

-- выводим входные данные примеров для обучения НС
-- exec nnpSelect_nnPeriodsData '6E_15_120_PA211'