Attribute VB_Name = "mStart"
Option Explicit


Sub ProcStart3()
' запускаем расчет за период дат

' перед запуском:
' 1) в настроечной таблице ntSettingsFilesParameters по текущей БД поставить:
'    IsExportToExcelCurrent=0, IsOpenExcelCurrent=0, IsExportToExcelHistory=0, IsOpenExcelHistory=0
'    cDateTimeFirst, cDateTimeLast, cDateTimeFirstCalc, cDateTimeLastCalc
' 2) сделать копии исходного файла для всех баз
' 3) проверить чтобы исторические данные не пересекались с текущими
' 4) если делается одновременный расчет нескольких К по одной таблице с текущими данными, то перед расчетом перенести эту таблицу из текстового файла в Access (запрос copy_source_table_current, иначе будет конфликт при доступе к файлу).
'    Новую таблицу назвать точно как старую (из txt файла).
'    Потом (после расчета) вернуть обратно.
' 5) (еще не сделано) задать параметры IsExportToTxtCurrent = 0, IsExportToTxtHistory = 0 (если текстовые файлы не нужны)


    Dim i As Long
    Dim SQLString As String
    
    On Error Resume Next ' на случай если день был нерабочий (чтобы расчет не вылетал с ошибкой)
    
    cDateTimeCalcAsDate = "2016.10.31" ' первая дата на которую делаем расчет
    
    Set DB = Access.CurrentDb
    CurrDBName = CurrentProject.Name

    For i = 1 To 14 ' количество дней вперед на которые надо сделать расчет
        cDateTimeCalc = Format(cDateTimeCalcAsDate, "yyyy.mm.dd") & " " '& "_"
        If Weekday(cDateTimeCalc, vbMonday) <> 6 And Weekday(cDateTimeCalc, vbMonday) <> 7 Then ' за субботу и воскресенье расчет не делаем
            SQLString = " update ntSettingsFilesParameters_cn set cDateCalc = '" & cDateTimeCalc & "' where dbFileName = '" & CurrDBName & "'"
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
            
            'MsgBox cDateTimeCalc & Weekday(cDateTimeCalc, vbMonday)
            Call ProcStart
        End If
        cDateTimeCalcAsDate = DateAdd("y", 1, cDateTimeCalcAsDate)
    Next i
    
    
    MsgBox Now() & " - " & cDateTimeCalc
    

End Sub

Sub ProcStart()
    
    
    'Call WriteLog("--------------------------")
    
    ' берем значения параметров из имени файла
    Call DefineParametersFromFileName

    
    If DataSourceId = 1 Then 'MT
        tblDataHistory = "_tPeriodsDataCCLOSE"
        tblDataCurrentChart = "_EURUSD5CurrChart"
        tblDataCurrentBufer = "_EURUSD5CurrBufer"
        tblDataCurrentMSSQL = "_EURUSD5Curr"
        tCorrResultsPeriodsData = "_tCorrResultsPeriodsData"
        tCorrResults = "_tCorrResults"
        pCorrResultsReport = "pCorrResultsReport"
        pCorrResultsPeriodsData = "pCorrResultsPeriodsData"
    End If
    
    If (DataSourceId = 2) Or (DataSourceId = 3) Then '2 - NT (5-минутки склеены из 1-минуток), 3 - Quik
        tblDataHistory = "ntPeriodsDataCCLOSE_" & CurrencyId_history & "_" & DataSourceId & "_" & PeriodMinutes & "_1_1" ' ntPeriodsDataCCLOSE_[CurrencyId]_[DataSourceId]_[PeriodMinutes]_[PeriodMultiplicatorMin]_[PeriodMultiplicatorMax]
        tblDataCurrentChart = "ntImportCurrentChart"
        tblDataCurrentChartMSSQL = "ntImportCurrentChartAverageValues"
        tblDataCurrentBufer = "ntImportCurrentBufer"
        tblDataCurrentMSSQL = "ntImportCurrent"
        tblDataCurrentNoAverageValuesMSSQL = "ntImportCurrent_NoAverageValues"
        tCorrResultsPeriodsData = "ntCorrResultsPeriodsData"
        tCorrResults = "ntCorrResults"
        tCorrResultsBufer = "ntCorrResultsBufer"
        pCorrResultsReport = "ntpCorrResultsReport"
        pCorrResultsPeriodsData = "ntpCorrResultsPeriodsData"
    End If
    
    Dim SQLString As String
    Dim SQLString2 As String
    Dim i As Long
    Dim j As Long
    Dim CountNoAverageValues As Integer
    Dim CountCurrentChartMSSQL As Integer
    Dim rstTemp01 As DAO.Recordset
    
    
    StartTime = GetTickCount    'запоминаем начальное время
    
    


'----------------------------

    If isCalcCorr1 = 1 Then ' 1 = считать К, 0 = не считать К (д.б. уже посчитана по другому ParamsIdentifyer)
    

    
        
        Call CopySourceFile ' делаем копию исходного файла с текущими данными, чтобы избежать блокировки файла в NT
        
        CurrPathAccess = CurrentProject.Path
        
        
        
        ' заполнение ArrDataHistory (делать только 1 раз)
        Call FillArrDataHistory_new(tblDataHistory)
        
        
        
    
        
        
        
        ' если cTimeFirstCalc был задан, то определяем даты с нерассчитанными общими оказателями и считаем К по этим датам в цикле
        If cTimeFirstCalc <> "" Then
            ' отбираем текущие данные, по которым не рассчитаны общие показатели (заполняем таблицу ntImportCurrent_NoAverageValues)
            Call FillTablesDataCurrent(1, 0)
            
            

            ' если таблица с текщими данными пустая (нет данных за текущий день), то прекращаем выполнение программы
            If fnCntDataCurrentBufer = 0 Then
                SQLString = "insert into nt_rt_log (log_message, cdatetime_log) select '" & ParamsIdentifyer & ": в таблице с исходными данными нет записей за текущую дату', getdate()"
                Call ExecProcedureMSSQL(SQLString)
                GoTo exitProc
            End If
            
            
            
            Call ChangeCDateTimeFirstToReal
            Call WriteLog("запускаем процедуру ntpSearchAverageValues на MSSQL")
            SQLString = "exec ntpSearchAverageValues '" & cDateTimeFirst & "', '" & cDateTimeFirstCalc & "', '" & cDateTimeLastCalc & "', " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "'" & ", " & cntBarsCalcCorr & ", " & DeltaCcloseRangeMaxLimit & ", " & DeltaCcloseRangeMinLimit & ", " & IsCalcCorrOnlyForSameTime & ", " & DeltaMinutesCalcCorr & ", '" & CalcCorrParamsId & "' "
            'Debug.Print (SQLString)
            Call ExecProcedureMSSQL(SQLString)
            Call WriteLog("процедура ntpSearchAverageValues на MSSQL выполнена")
            
            Call WriteLog("(5) SQLString = " & SQLString)
            Call WriteLog("(6) cDateTimeFirst = " & cDateTimeFirst)
            
            
            ' перебираем в обратном порядке текущие данные, по которым нужно рассчитать общие показатели
            SQLString = "             select idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer "
            SQLString = SQLString & " from  " & tblDataCurrentNoAverageValuesMSSQL
            SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
            SQLString = SQLString & " order by idn "
            

            
            Set rstTemp2 = DB.OpenRecordset(SQLString)
            'MsgBox DCount("*", tblDataCurrentNoAverageValuesMSSQL)
            'If DCount("*", tblDataCurrentNoAverageValuesMSSQL) > 0 Then
            'If rstTemp2.RecordCount > 0 Then
            If Not (rstTemp2.EOF And rstTemp2.BOF) Then ' если рекордсет не пустой (есть нерассчитанные промежутки)
                rstTemp2.MoveLast
                cDateTimeLastTemp = rstTemp2.Fields("cdate_last").Value & " " & rstTemp2.Fields("ctime_last").Value ' по последнему cDateTimeLast расчет в цикле не делаем, сделаем этот расчет потом
                Do While Not rstTemp2.BOF
                    cDateTimeLast = rstTemp2.Fields("cdate_last").Value & " " & rstTemp2.Fields("ctime_last").Value
                    cTimeLast = rstTemp2.Fields("ctime_last").Value
                    Call WriteLog("-- начало расчета(1) (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    If cDateTimeLast = cDateTimeLastTemp Then GoTo next_i ' cDateTimeLast пропускаем, посчитаем ее потом
                    ' оставляем в таблице с текущмим данными только нужные записи
                    Call WriteLog("-- начало расчета (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    
                    Call FillArrCorrTotal(tblDataHistory) ' определение массива с общей К
                    Call FillTablesDataCurrent(1, cntBarsCalcCorr)
                    Call ChangeCDateTimeFirstToReal
                    Call WriteLog("-- запуск CountCorr_cn") ' считаем К (итог - заполненная таблица ntCorrResults (5000 максимальных К) -> ntCorrResultsReport (20 точек с максимальной К))
                    Call CountCorr_cn
                    Call WriteLog("-- CountCorr_cn выполнена")
                    Call CountAverageValues ' считаем общие показатели (итог - заполненная таблица ntAverageValuesResults (общие показатели))
                    
                    Call WriteLog("-- конец расчета (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    
next_i:
                    rstTemp2.MovePrevious
                Loop
            End If
            rstTemp2.Close
        End If
        
        
    
        Call DefineParametersFromFileName ' заново берем значения параметров из имени файла
        Call FillArrCorrTotal(tblDataHistory) ' определение массива с общей К
        Call FillTablesDataCurrent(1, cntBarsCalcCorr)
        Call ChangeCDateTimeFirstToReal
        Call WriteLog("-- запуск CountCorr_cn") ' считаем К (итог - заполненная таблица ntCorrResults (5000 максимальных К) -> ntCorrResultsReport (20 точек с максимальной К))
        Call CountCorr_cn
        Call WriteLog("-- CountCorr_cn выполнена")
        Call CountAverageValues ' считаем общие показатели (итог - заполненная таблица ntAverageValuesResults (общие показатели))
    
    
    
    
    
    
        If IsCalcCalendar = 1 Then
            Call CalcCalendarIdnData ' отбираем данные по событиям календаря
        End If
        
    
    
   
   
   
   End If
'----------------------------
   
   
   
    ' заполняем таблицу tCorrResultsPeriodsData на SQL Server (итог - заполненная таблица ntCorrResultsPeriodsData (20 графиков с историей))
    SQLString = "exec " & pCorrResultsPeriodsData & " " & pCountCharts & "," & pbarsBefore & "," & pbarsTotal & "," & 10000 & ",'" & ParamsIdentifyer & "'" & "," & cntBarsCalcCorr
    Call ExecProcedureMSSQL(SQLString) ' НЕ сортируем по DeltaMinutesCalcCorr, т.к. уже отобрали только нужные данные
    
    
    Call WriteLog("конец exec " & pCorrResultsPeriodsData)
    
    
    Call FillChartCurrent ' заполняем таблицу с текущим графиком
    
    
    'Call CheckAlerts ' проверяем условия алерта
    
    
    If (is_makeDeals_RealTrade = 1) Then
        Call CheckAlerts_RealTrade
    End If
    
    
    
    
    
    ' очищаем каталог ForexChartsHistoryData
    'If ((IsExportToExcel = 1) Or (IsOpenExcel = 1)) Then
    'If ((IsExportToExcelCurrent = 1) Or (IsExportToExcelHistory = 1) Or (IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
    If ((IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
        Call ClearDataFolder
        Call WriteLog("процедура ClearDataFolder выполнена")
    End If
    
    
    'If ((IsExportToExcelCurrent = 1) Or (IsExportToExcelHistory = 1)) Then
    '    Call ExportToExcel
    'End If
    
    If ((IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
        Call ExportToTxt
    End If
    
    
    
    
    
    'Call OpenExcel
    'открываем файл с графиками, меняем шкалы на графиках
    Call ProcessExcelCharts
    
    
    
    ' основной расчет выполнен
    Beep
    
    
    
    
        TotalTime = GetTickCount - StartTime    'вычисляем затраченное время
        'MsgBox "Затрачено времени: " & TotalTime & " мс", , ""
    
exitProc:
    
    'графики:
    
    ' -- 1 --
    'оранжевый  -   ABV
    'коричневый -   для DataSourceId = 2 (NT):   ABVMini
    '           -   для DataSourceId = 3 (Quik): ccntOpenPos (количество открытых позиций)
    ' -- 2 --
    'оранжевый  -   CcorrMax real NULL, -- максимальное значение К
    'коричневый -   CcorrAvg real NULL, -- среднее значение К
    'зеленый    -   TakeProfit_isOk_Daily_up_AvgCnt real NULL, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
    'синий      -   TakeProfit_isOk_Daily_down_AvgCnt real NULL, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
    ' -- 2_nd --
    'зеленый    -   TakeProfit_isOk_Daily_up_AvgCnt real NULL, -- кол-во срабатываний TakeProfit до конца СЛЕДУЮЩЕГО дня вверх (процент ситуаций)
    'синий      -   TakeProfit_isOk_Daily_down_AvgCnt real NULL, -- кол-во срабатываний TakeProfit до конца СЛЕДУЮЩЕГО дня вниз (процент ситуаций)
    
    ' -- 3 --
    'оранжевый  -   TakeProfit_isOk_Daily_up_PrcBars real NULL, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
    'коричневый -   TakeProfit_isOk_Daily_down_PrcBars real NULL, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
    'зеленый    -   TakeProfit_isOk_AtOnce_up_AvgCnt real NULL, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
    'синий      -   TakeProfit_isOk_AtOnce_down_AvgCnt real NULL, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
    ' -- 3_nd --
    'оранжевый  -   TakeProfit_isOk_Daily_up_PrcBars real NULL, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца СЛЕДУЮЩЕГО дня) (среднее значение по всем ситуациям)
    'коричневый -   TakeProfit_isOk_Daily_down_PrcBars real NULL, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца СЛЕДУЮЩЕГО дня) (среднее значение по всем ситуациям)
    'зеленый    -   TakeProfit_isOk_AtOnce_up_AvgCnt real NULL, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
    'синий      -   TakeProfit_isOk_AtOnce_down_AvgCnt real NULL, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
    
    ' -- 4 --
    'оранжевый  -   ChighMax_Daily_Avg real NULL, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
    'коричневый -   ClowMin_Daily_Avg real NULL, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
    'зеленый    -   ChighMax_AtOnce_Avg real NULL, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
    'синий      -   ClowMin_AtOnce_Avg real NULL, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
    ' -- 4_nd --
    'оранжевый  -   ChighMax_Daily_Avg real NULL, -- среднее максимальное отклонение вверх от текущей цены до конца СЛЕДУЮЩЕГО дня (кол-во пунктов)
    'коричневый -   ClowMin_Daily_Avg real NULL, -- среднее максимальное отклонение вниз от текущей цены до конца СЛЕДУЮЩЕГО дня (кол-во пунктов)
    'зеленый    -   ChighMax_AtOnce_Avg real NULL, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня
    'синий      -   ClowMin_AtOnce_Avg real NULL, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня
    
    ' -- 5 -- (только для DataSourceId = 3 (Quik))
    'оранжевый  -   countbuy -- количество заявок на покупку
    'коричневый -   countsell -- количество заявок на продажу
    'зеленый    -   avgBuyOrder -- средний размер заявки на покупку ( = суммарный спрос / количество заявок на покупку)
    'синий      -   avgSellOrder -- средний размер заявки на продажу ( = суммарное предложение / количество заявок на продажу)



End Sub



Sub CheckAlerts_RealTrade()

Dim strSubject As String

    'Dim SQLString As String
    
    'Call ExecProcedureMSSQL("exec ntp_rt_CheckAlerts @activation_ParamsIdentifyer = '" & ParamsIdentifyer & "'")
    
    Call ExecProcedureMSSQL_ntp_rt_CheckAlerts(ParamsIdentifyer)
    ' получили AlertStrBody
    
    If AlertStrBody <> "" Then ' есть важное сообщение
        'MsgBox AlertStrBody
        
        ' посылаем email
        If isSendEmailOnAlert = 1 Then
            strSubject = ParamsIdentifyer & " " & CurrencyNTName_current & " " & cDateTimeLast
            'Call GenerateAlertStrBody(1)
            Call send_Email(strSubject, AlertStrBody)
        End If
        
        ' посылаем SMS
        If isSendSmsOnAlert = 1 Then
            'Call GenerateAlertStrBody(2)
            Call sendSMS(AlertStrBody)
        End If
        
    End If


End Sub


Sub CheckAlerts()

    Dim SQLString As String
    'Dim SQLString2 As String
    Dim i As Long
    'Dim j As Long
    'Dim CountNoAverageValues As Integer
    Dim CountCurrentChartMSSQL As Integer
    Dim strSubject As String
    'Dim strBody As String
    
    ' проверяем условия алерта
    Call WriteLog("начало проверки условий алерта")
    
    'Set rstTemp2 = DB.OpenRecordset(tblDataCurrentChartMSSQL, dbOpenDynaset, dbSeeChanges)
    SQLString = "             select * "
    SQLString = SQLString & " from  " & tblDataCurrentChartMSSQL
    SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
    SQLString = SQLString & " order by idn "
    
    Set rstTemp2 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    rstTemp2.MoveLast
    CountCurrentChartMSSQL = rstTemp2.RecordCount
    
    ' если в последней строке нет нужных нам значений, то прокручиваем таблицу назад до тех пор, пока не найдем ненулевые значения
    For i = 1 To CountCurrentChartMSSQL 'DCount("*", tblDataCurrentChartMSSQL)
        If IsNull(rstTemp2.Fields("TakeProfit_isOk_AtOnce_up_AvgCnt").Value) _
        Or IsNull(rstTemp2.Fields("TakeProfit_isOk_AtOnce_down_AvgCnt").Value) _
        Or IsNull(rstTemp2.Fields("ChighMax_AtOnce_Avg").Value) _
        Or IsNull(rstTemp2.Fields("ClowMin_AtOnce_Avg").Value) Then
            rstTemp2.MovePrevious
        Else
            Exit For
        End If
    Next i
    
    
    'CcorrMax = rstTemp2.Fields("CcorrMax").Value
    'CcorrAvg = rstTemp2.Fields("CcorrAvg").Value
    'TakeProfit_isOk_Daily_up_AvgCnt = rstTemp2.Fields("TakeProfit_isOk_Daily_up_AvgCnt").Value
    'TakeProfit_isOk_Daily_down_AvgCnt = rstTemp2.Fields("TakeProfit_isOk_Daily_down_AvgCnt").Value
    'TakeProfit_isOk_Daily_up_PrcBars = rstTemp2.Fields("TakeProfit_isOk_Daily_up_PrcBars").Value
    'TakeProfit_isOk_Daily_down_PrcBars = rstTemp2.Fields("TakeProfit_isOk_Daily_down_PrcBars").Value
    TakeProfit_isOk_AtOnce_up_AvgCnt = rstTemp2.Fields("TakeProfit_isOk_AtOnce_up_AvgCnt").Value
    TakeProfit_isOk_AtOnce_down_AvgCnt = rstTemp2.Fields("TakeProfit_isOk_AtOnce_down_AvgCnt").Value
    'ChighMax_Daily_Avg = rstTemp2.Fields("ChighMax_Daily_Avg").Value
    'ClowMin_Daily_Avg = rstTemp2.Fields("ClowMin_Daily_Avg").Value
    ChighMax_AtOnce_Avg = rstTemp2.Fields("ChighMax_AtOnce_Avg").Value
    ClowMin_AtOnce_Avg = rstTemp2.Fields("ClowMin_AtOnce_Avg").Value
    
    ' берем общие показатели с учетом СЛЕДУЮЩЕГО дня
    TakeProfit_isOk_AtOnce_up_AvgCnt_nd = rstTemp2.Fields("TakeProfit_isOk_AtOnce_up_AvgCnt_nd").Value
    TakeProfit_isOk_AtOnce_down_AvgCnt_nd = rstTemp2.Fields("TakeProfit_isOk_AtOnce_down_AvgCnt_nd").Value
    ChighMax_AtOnce_Avg_nd = rstTemp2.Fields("ChighMax_AtOnce_Avg_nd").Value
    ClowMin_AtOnce_Avg_nd = rstTemp2.Fields("ClowMin_AtOnce_Avg_nd").Value
    
    rstTemp2.Close
    
     
    
    ' если хотя бы одно условие выполнено, то вызываем алерт
    'If (Abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) _
    'Or (TakeProfit_isOk_AtOnce_up_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert Or TakeProfit_isOk_AtOnce_down_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) _
    'Or (Abs(ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) >= CPoints_AtOnce_Avg_delta_alert) _
    'Or (ChighMax_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert Or ClowMin_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert) Then
    ' если все условия выполнены, то вызываем алерт
    If (((Abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) _
    And (TakeProfit_isOk_AtOnce_up_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert Or TakeProfit_isOk_AtOnce_down_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) _
    And (Abs(ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) >= CPoints_AtOnce_Avg_delta_alert) _
    And (ChighMax_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert Or ClowMin_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert)) _
    Or _
    ((Abs(TakeProfit_isOk_AtOnce_up_AvgCnt_nd - TakeProfit_isOk_AtOnce_down_AvgCnt_nd) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) _
    And (TakeProfit_isOk_AtOnce_up_AvgCnt_nd >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert Or TakeProfit_isOk_AtOnce_down_AvgCnt_nd >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) _
    And (Abs(ChighMax_AtOnce_Avg_nd - ClowMin_AtOnce_Avg_nd) >= CPoints_AtOnce_Avg_delta_alert) _
    And (ChighMax_AtOnce_Avg_nd >= CPoints_AtOnce_Avg_limit_alert Or ClowMin_AtOnce_Avg_nd >= CPoints_AtOnce_Avg_limit_alert))) _
    Then
        'Beep
        'Shell "cmd.exe /c " & CurrPathAccess & "\sounds\sound.bat"
        'Call WriteLog("вызван алерт")
        
        ' посылаем email
        If isSendEmailOnAlert = 1 Then
            strSubject = ParamsIdentifyer & " " & CurrencyNTName_current & " " & cDateTimeLast
            Call GenerateAlertStrBody(1)
            Call send_Email(strSubject, AlertStrBody)
        End If
        
        ' посылаем SMS
        If isSendSmsOnAlert = 1 Then
            Call GenerateAlertStrBody(2)
            Call sendSMS(AlertStrBody)
        End If
        
        
        If pExcelWindowState = 4 Then
            pExcelWindowState = 1
        End If
    End If
    
    If pExcelWindowState = 4 Then
        pExcelWindowState = 2
    End If
        
    Call WriteLog("проверка условий алерта выполнена")


End Sub


Sub GenerateAlertStrBody(idDestination As Integer)
' генерируем текст сообщения
' idDestination: 1 - сообщение по email, 2 - сообщение по sms

            AlertStrBody = ""
            
            If idDestination = 2 Then
                AlertStrBody = AlertStrBody & ParamsIdentifyer & " " & CurrencyNTName_current & " " & cDateTimeLast
            End If
            
            
            
            If (TakeProfit_isOk_AtOnce_up_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) Then
                AlertStrBody = AlertStrBody & " TP_up=" & Round(TakeProfit_isOk_AtOnce_up_AvgCnt, 2)
            End If
            
            If (TakeProfit_isOk_AtOnce_down_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) Then
                AlertStrBody = AlertStrBody & " TP_down=" & Round(TakeProfit_isOk_AtOnce_down_AvgCnt, 2)
            End If
            
            If (Abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) Then
                AlertStrBody = AlertStrBody & " TP_delta=" & Round(Abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt), 2)
            End If
            
            
            
            If (ChighMax_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert) Then
                AlertStrBody = AlertStrBody & " ChighMax=" & Round(ChighMax_AtOnce_Avg, 2)
            End If
            
            If (ClowMin_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert) Then
                AlertStrBody = AlertStrBody & " ClowMin=" & Round(ClowMin_AtOnce_Avg, 2)
            End If
            
            If (Abs(ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) >= CPoints_AtOnce_Avg_delta_alert) Then
                AlertStrBody = AlertStrBody & " CPoints_delta=" & Round(Abs(ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg), 2)
            End If
            
            
            
            AlertStrBody = AlertStrBody & " (TP_up=" & Round(TakeProfit_isOk_AtOnce_up_AvgCnt, 2) & "; TP_down=" & Round(TakeProfit_isOk_AtOnce_down_AvgCnt, 2) & "; ChighMax=" & Round(ChighMax_AtOnce_Avg, 2) & "; ClowMin=" & Round(ClowMin_AtOnce_Avg, 2) & ")"
            
            
            If idDestination = 1 Then
                AlertStrBody = AlertStrBody & " fx_alert"
                AlertStrBody = AlertStrBody & " ____ "
            End If
            
            
            
            ' выводим общие показатели с учетом СЛЕДУЮЩЕГО дня
            If (TakeProfit_isOk_AtOnce_up_AvgCnt_nd >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) Then
                AlertStrBody = AlertStrBody & " TP_up_nd=" & Round(TakeProfit_isOk_AtOnce_up_AvgCnt_nd, 2)
            End If
            
            If (TakeProfit_isOk_AtOnce_down_AvgCnt_nd >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) Then
                AlertStrBody = AlertStrBody & " TP_down_nd=" & Round(TakeProfit_isOk_AtOnce_down_AvgCnt_nd, 2)
            End If
            
            If (Abs(TakeProfit_isOk_AtOnce_up_AvgCnt_nd - TakeProfit_isOk_AtOnce_down_AvgCnt_nd) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) Then
                AlertStrBody = AlertStrBody & " TP_delta_nd=" & Round(Abs(TakeProfit_isOk_AtOnce_up_AvgCnt_nd - TakeProfit_isOk_AtOnce_down_AvgCnt_nd), 2)
            End If
            
            
            
            If (ChighMax_AtOnce_Avg_nd >= CPoints_AtOnce_Avg_limit_alert) Then
                AlertStrBody = AlertStrBody & " ChighMax_nd=" & Round(ChighMax_AtOnce_Avg_nd, 2)
            End If
            
            If (ClowMin_AtOnce_Avg_nd >= CPoints_AtOnce_Avg_limit_alert) Then
                AlertStrBody = AlertStrBody & " ClowMin_nd=" & Round(ClowMin_AtOnce_Avg_nd, 2)
            End If
            
            If (Abs(ChighMax_AtOnce_Avg_nd - ClowMin_AtOnce_Avg_nd) >= CPoints_AtOnce_Avg_delta_alert) Then
                AlertStrBody = AlertStrBody & " CPoints_delta_nd=" & Round(Abs(ChighMax_AtOnce_Avg_nd - ClowMin_AtOnce_Avg_nd), 2)
            End If
            
            
            
End Sub

Sub WriteArrToTable(ArrName() As Double, TableName As String, TableColName As String)
' запись значений массива ArrName в поле TableColName таблицы TableName

Dim i As Long

Set rstTemp = DB.OpenRecordset(TableName, dbOpenDynaset, dbSeeChanges)
For i = 1 To UBound(ArrName) + 1
  rstTemp.AddNew
  rstTemp(TableColName) = ArrName(i - 1)
  rstTemp.Update
Next i
rstTemp.Close

End Sub

Sub WriteArr3ToTable(ArrName(), TableName As String, TableColName1 As String, TableColName2 As String, cntrows As Long)
' запись значений двумерного массива ArrName в поля TableColName1 и TableColName2 таблицы TableName

Dim i As Long

Set rstTemp = DB.OpenRecordset(TableName, dbOpenDynaset, dbSeeChanges)
For i = 1 To cntrows
  rstTemp.AddNew
  rstTemp(TableColName1) = ArrName(0, i - 1)
  rstTemp(TableColName2) = ArrName(1, i - 1)
  rstTemp.Update
Next i
rstTemp.Close

End Sub

Sub WriteArr2ToTable(ArrName1(), ArrName2(), TableName As String, _
                     TableColName1 As String, TableColName2 As String, _
                     Optional ByRef cntrows As Long = 0)
' запись значений массивов ArrName1 и ArrName2 в поля TableColName1 и TableColName2 таблицы TableName
' берем cntRows с конца массива

Dim i As Long
Dim cntRowsTotal As Long

cntRowsTotal = UBound(ArrName1) + 1 ' кол-во строк в массиве

If cntrows = 0 Then
  cntrows = cntRowsTotal
End If

Set rstTemp = DB.OpenRecordset(TableName, dbOpenDynaset, dbSeeChanges)
For i = 1 To cntrows
  rstTemp.AddNew
  
  If SortBack = 0 Then  ' 0 - сортировка К в прямом порядке
    rstTemp(TableColName1) = ArrName1(cntRowsTotal - i)
    rstTemp(TableColName2) = ArrName2(cntRowsTotal - i)
  End If
  If SortBack = 1 Then  ' 1 - сортировка К в обратном порядке
    rstTemp(TableColName1) = ArrName1(i - 1)
    rstTemp(TableColName2) = ArrName2(i - 1)
  End If
  
  rstTemp.Update
Next i
rstTemp.Close

End Sub

Sub ExecProcedureMSSQL(SQLString As String)

Dim conn As ADODB.Connection
Dim Cmd As ADODB.Command
 
Set conn = New ADODB.Connection
'conn.ConnectionString = "DRIVER=SQL Server;Server=MNIKOLAEV79;Database=forex;Trusted_Connection=True;"

If CreateObject("wscript.network").ComputerName = "MNIKOLAEV79" Then
    conn.ConnectionString = "DRIVER=SQL Server;Server=MNIKOLAEV79;Database=forex;Trusted_Connection=True;"
End If

If CreateObject("wscript.network").ComputerName = "MAX" Then
    'conn.ConnectionString = "DRIVER=SQL Server;Server=MAX\MSSQLMAX;Database=forex;Trusted_Connection=True;"
    conn.ConnectionString = "DRIVER=SQL Server;Server=MAX;Database=forex;Trusted_Connection=True;"
End If

If CreateObject("wscript.network").ComputerName = "SERVER1" Then
    conn.ConnectionString = "DRIVER=SQL Server;Server=SERVER1;Database=forex;Trusted_Connection=True;"
End If

conn.Open
Set Cmd = New ADODB.Command
Cmd.ActiveConnection = conn
Cmd.CommandText = SQLString
Cmd.CommandType = adCmdText
Cmd.CommandTimeout = 120
Cmd.Execute

conn.Close
Set conn = Nothing
Set Cmd = Nothing


End Sub


Sub ExecProcedureMSSQL_ntp_rt_CheckAlerts(activation_ParamsIdentifyer As String)

Dim conn As ADODB.Connection
Dim Cmd As ADODB.Command
 
Set conn = New ADODB.Connection
'conn.ConnectionString = "DRIVER=SQL Server;Server=MNIKOLAEV79;Database=forex;Trusted_Connection=True;"

If CreateObject("wscript.network").ComputerName = "MNIKOLAEV79" Then
    conn.ConnectionString = "DRIVER=SQL Server;Server=MNIKOLAEV79;Database=forex;Trusted_Connection=True;"
End If

If CreateObject("wscript.network").ComputerName = "MAX" Then
    conn.ConnectionString = "DRIVER=SQL Server;Server=MAX\MSSQLMAX;Database=forex;Trusted_Connection=True;"
End If

If CreateObject("wscript.network").ComputerName = "SERVER1" Then
    conn.ConnectionString = "DRIVER=SQL Server;Server=SERVER1;Database=forex;Trusted_Connection=True;"
End If


conn.Open
Set Cmd = New ADODB.Command
Cmd.ActiveConnection = conn
'Cmd.CommandText = SQLString
'Cmd.CommandType = adCmdText


Cmd.CommandText = "ntp_rt_CheckAlerts"
Cmd.CommandType = adCmdStoredProc

Cmd.Parameters.Append Cmd.CreateParameter("@activation_ParamsIdentifyer", adVarChar, adParamInput, 50)
Cmd.Parameters("@activation_ParamsIdentifyer").Value = activation_ParamsIdentifyer

Cmd.Parameters.Append Cmd.CreateParameter("@resultMessage", adVarChar, adParamOutput, 1000)

Cmd.Execute

AlertStrBody = Cmd.Parameters("@resultMessage").Value
'MsgBox Cmd.Parameters("@pout").Value


conn.Close
Set conn = Nothing
Set Cmd = Nothing


End Sub


Sub ClearTable(TableName As String)

' очищаем таблицу
Dim sql As String
sql = "delete from " & TableName
DB.Execute sql

End Sub

Sub ClearTableMSSQL(TableName As String)


' очищаем таблицу
Dim sql As String
sql = "delete from " & TableName

 DB.Execute sql, dbSeeChanges + dbFailOnError

End Sub













Function Evalu(ByVal S As String) As String
Evalu = Evaluate(S)
End Function







