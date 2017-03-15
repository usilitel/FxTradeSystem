Attribute VB_Name = "mCorr"
'Option Compare Database
Option Explicit

Sub CountCorr_cn()

' в цикле определяем параметры n-го расчета и рассчитываем все нужные К

Dim SQLString As String
Dim SQLString2 As String
Dim i As Long
Dim j As Long
Dim j2 As Long
Dim j3 As Long
Dim cntRowsTemp As Long
Dim counterDaysAgo As Integer
Dim CurrentDayCntBars As Integer

' определяем параметры всех расчетов для данного ParamsIdentifyer
SQLString = " select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '" & ParamsIdentifyer & "' and WeightCORR <> 0 order by idn"
Set rstPeriodsParameters = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
rstPeriodsParameters.MoveLast
cntRowsTemp = rstPeriodsParameters.RecordCount
rstPeriodsParameters.MoveFirst
    
    For i = 1 To cntRowsTemp

        ' определение параметров n-го расчета
            PeriodMinutes_cn = rstPeriodsParameters.Fields("PeriodMinutes").Value ' период данных в минутах, по которому надо считать К
            
            FieldNumCurrent_cn = rstPeriodsParameters.Fields("FieldNumCurrent").Value ' номер столбца (начиная с 0) в таблице tblDataCurrent, по которому считаем К
            FieldNumHistory_cn = rstPeriodsParameters.Fields("FieldNumHistory").Value ' номер столбца (начиная с 0) в таблице с историей, по которому считаем К
                
            idAlgorithmCalcCorr_cn = rstPeriodsParameters.Fields("idAlgorithmCalcCorr").Value ' алгоритм расчета К: 1 - обычный, 2 - упрощенный (CalcCorrelationEasy)
            
            ' параметры для определения конечной точки расчета К
            'cTimeLast_cn = rstPeriodsParameters.Fields("cTimeLast").Value ' время, на которое считаем К (если не указано, то равно ntSettingsFilesParameters_cn.cTimeLast)
            If ((IsNull(rstPeriodsParameters.Fields("cTimeLast").Value)) Or (rstPeriodsParameters.Fields("cTimeLast").Value = "")) Then
                cTimeLast_cn = cTimeLast
            Else
                cTimeLast_cn = rstPeriodsParameters.Fields("cTimeLast").Value
            End If
            cntDaysAgoLast_cn = rstPeriodsParameters.Fields("cntDaysAgoLast").Value ' количество дней назад от даты ntSettingsFilesParameters_cn.cDateTimeCalc
                
            ' параметры для определения начальной точки расчета К
            'cTimeFirst_cn = rstPeriodsParameters.Fields("cTimeFirst").Value ' время, начиная с которого считаем К (если не указано, то равно ntSettingsFilesParameters_cn.cTimeFirst)
            If ((IsNull(rstPeriodsParameters.Fields("cTimeFirst").Value)) Or (rstPeriodsParameters.Fields("cTimeFirst").Value = "")) Then
                cTimeFirst_cn = cTimeFirst
            Else
                cTimeFirst_cn = rstPeriodsParameters.Fields("cTimeFirst").Value
            End If
            cntDaysAgoFirst_cn = rstPeriodsParameters.Fields("cntDaysAgoFirst").Value ' количество дней назад от конечной точки расчета К
        
        
            WeightCORR_cn = rstPeriodsParameters.Fields("WeightCORR").Value / WeightCORR_cn_sum ' вес К по данному расчету в общей К
        
            MAPeriod_cn = rstPeriodsParameters.Fields("MAPeriod").Value ' период MA (по которой считаем К)
            
        
            IsCalcCclosePosition_cn = rstPeriodsParameters.Fields("IsCalcCclosePosition").Value ' 1 - считать CclosePosition, 0 - не считать
            vCclosePositionDelta_cn = rstPeriodsParameters.Fields("vCclosePositionDelta").Value ' допустимое отклонение положения cclose в процентах при расчете К
            
            'CntBarsMinLimit_cn = rstPeriodsParameters.Fields("CntBarsMinLimit").Value ' минимальное количество баров, которое может быть в расчетном дне
            If ((IsNull(rstPeriodsParameters.Fields("CntBarsMinLimit").Value)) Or (rstPeriodsParameters.Fields("CntBarsMinLimit").Value = "")) Then
                CntBarsMinLimit_cn = CntBarsMinLimit
            Else
                CntBarsMinLimit_cn = rstPeriodsParameters.Fields("CntBarsMinLimit").Value
            End If
            
            
            
            
            'DeltaCcloseRangeMaxLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value ' максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
            If ((IsNull(rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value)) Or (rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value = "")) Then
                DeltaCcloseRangeMaxLimit_cn = DeltaCcloseRangeMaxLimit
            Else
                DeltaCcloseRangeMaxLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value
            End If
            
            'DeltaCcloseRangeMinLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value ' минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
            If ((IsNull(rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value)) Or (rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value = "")) Then
                DeltaCcloseRangeMinLimit_cn = DeltaCcloseRangeMinLimit
            Else
                DeltaCcloseRangeMinLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value
            End If
            
            'IsCalcCorrOnlyForSameTime_cn = rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value ' 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
            If ((IsNull(rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value)) Or (rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value = "")) Then
                IsCalcCorrOnlyForSameTime_cn = IsCalcCorrOnlyForSameTime
            Else
                IsCalcCorrOnlyForSameTime_cn = rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value
            End If
            
            'DeltaMinutesCalcCorr_cn = rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value ' количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
            If ((IsNull(rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value)) Or (rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value = "")) Then
                DeltaMinutesCalcCorr_cn = DeltaMinutesCalcCorr
            Else
                DeltaMinutesCalcCorr_cn = rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value
            End If
            
            
            
            
            
            
            
            
            
            
            
            ' cntBarsCalcCorr_cn всегда равен cntBarsCalcCorr
            ' !!! Если менять - то надо проверять корректность расчета К !!!
            cntBarsCalcCorr_cn = cntBarsCalcCorr
            'If ((IsNull(rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value)) or (rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value="")) Then
            '    cntBarsCalcCorr_cn = cntBarsCalcCorr
            'Else
            '    cntBarsCalcCorr_cn = rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value ' количество баров, по которым считать К (0 - задается начальная дата-время)
            'End If
            
        
        
        
        
        
        
        
        
        
        
        ' определяем название таблицы с историческими данными для n-го расчета
        tblDataHistory_cn = "ntPeriodsDataCCLOSE_" & CurrencyId_history & "_" & DataSourceId & "_" & PeriodMinutes_cn & "_1_1"
        
        ' определяем название таблицы с текущими данными для n-го расчета
        If DataSourceId = 2 Then 'NT
            tblDataCurrent_cn = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId
            
            'SourceFileNameCurrentRealTime_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_RealTime.txt"
            'SourceFileNameCurrent_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId & ".txt"
            
            Call CopySourceFile_cn
        
        End If
        If DataSourceId = 3 Then 'Quik
            tblDataCurrent_cn = "QuikDDE_" & CurrencyId_current & "_" & PeriodMinutes_cn
        End If
        
        

'-----------------------

        ' определяем границы текущих данных
        
        ' 1. определяем конечную дату текущих данных
        cDateCalcLast_cn = cDateCalc

        ' если cntDaysAgoLast_cn > 0, то меняем конечную границу текущих данных
        If cntDaysAgoLast_cn > 0 Then
            ' выбираем даты с количеством баров больше чем CntBarsMinLimit_cn
            SQLString2 = " select cdate, count(cdate) as cntBars from " & tblDataCurrent_cn & " group by cdate having  count(cdate) > " & CntBarsMinLimit_cn & " order by cdate "
                
            Set rstTemp = DB.OpenRecordset(SQLString2, dbOpenDynaset, dbSeeChanges)
            rstTemp.MoveLast
            counterDaysAgo = 0
            
            Do While Not rstTemp.BOF
                ' увеличиваем счетчик количества дней назад
                If rstTemp.Fields("cdate").Value < cDateCalc And counterDaysAgo > 0 Then
                    counterDaysAgo = counterDaysAgo + 1
                End If
                
                ' на первом предыдущем дне начинаем отсчет дней назад
                If rstTemp.Fields("cdate").Value < cDateCalc And counterDaysAgo = 0 Then
                    counterDaysAgo = 1
                End If
                
                ' нашли нужный день
                If counterDaysAgo = cntDaysAgoLast_cn Then
                    'MsgBox rstTemp.Fields("cdate").Value
                    cDateCalcLast_cn = rstTemp.Fields("cdate").Value
                End If
                
                rstTemp.MovePrevious
            Loop
            rstTemp.Close
        End If
        
        cDateTimeLast_cn = cDateCalcLast_cn & " " & cTimeLast_cn  ' время окончания расчета К


        
        
        
        ' 2. определяем начальную дату текущих данных
        cDateCalcFirst_cn = cDateCalcLast_cn

        ' если cntDaysAgoFirst_cn > 0, то меняем начальную границу текущих данных
        If cntDaysAgoFirst_cn > 0 Then
            ' выбираем даты с количеством баров больше чем CntBarsMinLimit_cn
                
            If DataSourceId = 2 Then 'NT
                SQLString2 = " select cdate, count(cdate) as cntBars from " & tblDataCurrent_cn & " group by cdate having  count(cdate) > " & CntBarsMinLimit_cn & " order by cdate "
            End If
            If DataSourceId = 3 Then 'Quik
                SQLString2 = " select date as cdate, count(date) as cntBars from " & tblDataCurrent_cn & " group by date having  count(date) > " & CntBarsMinLimit_cn & " order by date "
            End If
                
                
                
            Set rstTemp = DB.OpenRecordset(SQLString2, dbOpenDynaset, dbSeeChanges)
            rstTemp.MoveLast
            counterDaysAgo = 0
            
            Do While Not rstTemp.BOF
                ' увеличиваем счетчик количества дней назад
                If rstTemp.Fields("cdate").Value < cDateCalcLast_cn And counterDaysAgo > 0 Then
                    counterDaysAgo = counterDaysAgo + 1
                End If
                
                ' на первом предыдущем дне начинаем отсчет дней назад
                If rstTemp.Fields("cdate").Value < cDateCalcLast_cn And counterDaysAgo = 0 Then
                    counterDaysAgo = 1
                End If
                
                ' нашли нужный день
                If counterDaysAgo = cntDaysAgoFirst_cn Then
                    'MsgBox rstTemp.Fields("cdate").Value
                    cDateCalcFirst_cn = rstTemp.Fields("cdate").Value
                End If
                rstTemp.MovePrevious
            Loop
            rstTemp.Close
        End If
        
        cDateTimeFirst_cn = cDateCalcFirst_cn & " " & cTimeFirst_cn  ' время начала расчета К





                
        
        
        
        ' берем историю для n-го расчета (если еще не брали)
        'If Not ((arrDataHistory_cn_filled = 1) And (tblDataHistory_cn_previous = tblDataHistory_cn)) Then
            Call FillArrDataHistory_cn
        'End If
        
        
        ' берем текущие данные для n-го расчета
        Call FillArrDataCurrent_cn



        ' Считаем К для n-го расчета
        'Call WriteLog("-- запуск CalcCorrelation_" & UBound(arrDataHistoryCompare) & "_" & UBound(arrCclose_cn) & "_" & UBound(arrCorr_cn) & "_" & UBound(arrCclose) & "_" & DeltaCcloseRangeMinLimit_cn & "_" & DeltaCcloseRangeMaxLimit_cn)
        Call CalcCorrelation(arrDataHistoryCompare, arrCclose_cn, arrCorr_cn, arrCclose, DeltaCcloseRangeMinLimit_cn, DeltaCcloseRangeMaxLimit_cn)
        'Call WriteLog("-- CalcCorrelation выполнена")
        ' теперь рассчитанная К содержится в массиве arrCorr_cn


'-----------------------
        
        ' сдвигаем рассчитанную К на нужное количество дней
        If cntDaysAgoLast_cn > 0 Then
        
            CcorrCurrentDayMax = -10
            cDateLastStep = ""
            CurrentDayCntBars = 0
            j2 = 0
            
        ' сначала рассчитываем максимальную К по дням
            For j = 1 To cntDataHistoryRows_cn ' цикл по большой таблице
            
                If j = 1 Then
                    ' запоминаем текущую дату
                    cDateLastStep = arrCdate(j - 1)
                End If
            
            
            'If arrCdate(j - 1) >= "2014.12.06" Then
            '    j2 = j2
            'End If
            
                ' если перешли на следующую дату - то обнуляем CcorrCurrentDayMax (максимальная К за текущий день)
                If arrCdate(j - 1) <> cDateLastStep And CurrentDayCntBars > CntBarsMinLimit_cn Then
                    ' запоминаем максимальное значение К за день
                    arrCorrMaxForDates_cn(0, j2) = cDateLastStep ' дата
                    arrCorrMaxForDates_cn(1, j2) = CcorrCurrentDayMax ' максимальная К
                    j2 = j2 + 1
                
                    CcorrCurrentDayMax = -10
                    CurrentDayCntBars = 0
                    
                End If
                
                ' обновляем CcorrCurrentDayMax (максимальная К за текущий день)
                If arrCorr_cn(j - 1) > CcorrCurrentDayMax Then
                    CcorrCurrentDayMax = arrCorr_cn(j - 1)
                End If
                
                If j2 >= cntDaysAgoLast_cn Then
                    arrCorr_cn(j - 1) = arrCorrMaxForDates_cn(1, j2 - cntDaysAgoLast_cn)
                End If
                
                ' запоминаем текущую дату
                cDateLastStep = arrCdate(j - 1)
                
                ' увеличиваем счетчик баров в дне
                CurrentDayCntBars = CurrentDayCntBars + 1
            Next j
            ' теперь в массиве arrCorrMaxForDates_cn содержится максимальная К по дням
            
                'Call ClearTable("ttemp3")
                'Call WriteArr3ToTable(arrCorrMaxForDates_cn, "ttemp3", "f2", "f1", 2000)
            
            
            'j2 = 0
            'Do While arrCorrMaxForDates_cn(1, j2) <> -100
                
            '    j2 = j2 + 1
            'Loop
            
            
        End If

'------------------------------





        ' суммируем К по данному расчету с К по всем предыдущим расчетам
        ' если временной период, по которому рассчитывалась К, совпадает с периодом графика, то просто суммируем К
        If cntDataHistoryRows = cntDataHistoryRows_cn Then
            For j = 1 To cntDataHistoryRows
                arrCORRTotal(j - 1) = arrCORRTotal(j - 1) + arrCorr_cn(j - 1) * WeightCORR_cn
            Next j
        End If
        
        ' если временной период, по которому рассчитывалась К, НЕ совпадает с периодом графика, то перебираем К
        If cntDataHistoryRows > cntDataHistoryRows_cn Then
            j3 = 0
            For j = 1 To cntDataHistoryRows_cn
                Do While arrCdateTime(j3) <= arrCdateTime_cn(j - 1)
                    arrCORRTotal(j3) = arrCORRTotal(j3) + arrCorr_cn(j - 1) * WeightCORR_cn
                    j3 = j3 + 1
                Loop
            Next j
        End If
        
        ' если временной период, по которому рассчитывалась К, НЕ совпадает с периодом графика, то перебираем К
'        If cntDataHistoryRows < cntDataHistoryRows_cn Then
'            j3 = 0
'            On Error GoTo err1 ' если cntDataHistoryRows < cntDataHistoryRows_cn, то на последних барах будет возникать ошибка (выход за пределы массива)
'            For j = 1 To cntDataHistoryRows_cn - 1
'                Do While arrCdateTime(j3) <= arrCdateTime_cn(j - 1)
'                    arrCORRTotal(j3) = arrCORRTotal(j3) + arrCorr_cn(j - 1) * WeightCORR_cn
'                    j3 = j3 + 1
'                Loop
'            Next j
'        End If
'err1:
        
        If cntDataHistoryRows < cntDataHistoryRows_cn Then
            j3 = 0
            For j = 1 To cntDataHistoryRows
                Do While arrCdateTime(j - 1) > arrCdateTime_cn(j3)
                    j3 = j3 + 1
                Loop
                arrCORRTotal(j - 1) = arrCORRTotal(j - 1) + arrCorr_cn(j3) * WeightCORR_cn
            Next j
        End If
        
        
        rstPeriodsParameters.MoveNext
    Next i
    
rstPeriodsParameters.Close


'------------------------------


Call WriteLog("общая К посчитана (заполнен массив arrCORRTotal)") ' пишем лог

' пишем лог
Call WriteLog("начало сортировки")

    QuickSortNonRecursive3 arrCORRTotal, arrIDNSorted 'Rng   'производим сортировку

Call WriteLog("конец сортировки") ' пишем лог


' заполняем таблицу tCorrResults на SQL Server
Call ClearTable(tCorrResultsBufer)



' сначала заполняем таблицу в Access
Call WriteArr2ToTable(arrIDNSorted, arrCORRTotal, tCorrResultsBufer, "IDN", "ccorr", cntRowsCorr)
Call WriteLog("таблица " & tCorrResultsBufer & " заполнена ")

' сохраняем копию таблицы для проверки
If isLogTables = 1 Then
    SQLString = "insert into " & tCorrResultsBufer & "_log" & " (cinfo) "
    SQLString = SQLString & " select " & """" & cDateTimeFirst & "; cDateTimeLast=" & cDateTimeLast & "; CurrentBarTimeInMinutes=" & CurrentBarTimeInMinutes & "; DeltaMinutesCalcCorr=" & DeltaMinutesCalcCorr_cn & "; PeriodMinutes=" & PeriodMinutes & "; cntDataCurrentRows=" & cntDataCurrentRows & "; " & CStr(Now) & """"
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteArr2ToTable(arrIDNSorted, arrCORRTotal, tCorrResultsBufer & "_log", "IDN", "ccorr", cntRowsCorr) ' НЕполностью логируем массив arrCORRTotal (только те записи, которые попали в таблицу tCorrResultsBufer)
    Call WriteLog("таблица " & tCorrResultsBufer & "_log" & " заполнена; cDateTimeLast = " & cDateTimeLast)
End If

' потом перебрасываем уже готовую таблицу из Access на SQL Server (так быстрее работает)
SQLString = "delete from " & tCorrResults & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
DB.Execute SQLString, dbSeeChanges + dbFailOnError

SQLString = "insert into " & tCorrResults & " (idn, ccorr, ParamsIdentifyer) "
SQLString = SQLString & " select idn, ccorr, '" & ParamsIdentifyer & "' from " & tCorrResultsBufer
SQLString = SQLString & " order by idn "
    
'Call ClearTableMSSQL(tCorrResults)
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString

Call WriteLog("таблица " & tCorrResults & " на SQL Server заполнена (1)")


' процедура просчитывает результирующие данные
' таблица tCorrResults на SQL Server должна быть уже заполнена
' заполняем таблицу tCorrResultsReport на SQL Server
'Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & DeltaMinutesCalcCorr & ",'" & ParamsIdentifyer & "'")
Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "' ,'" & ParamsIdentifyer & "'") ' НЕ сортируем по DeltaMinutesCalcCorr, т.к. уже отобрали только нужные данные
Call WriteLog("конец exec " & pCorrResultsReport)







End Sub




Sub CountAverageValues()

Dim SQLString As String

    

    ' рассчитываем общие показатели (заполняем таблицу ntAverageValuesResults)
    Call WriteLog("запускаем процедуру ntpCorrResultsAverageValues на MSSQL")
    'SQLString = "exec ntpCorrResultsAverageValues " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes_cn & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "', " & cntBarsCalcCorr & ", '" & ctime_CalcAverageValuesWithNextDay & "', " & CntBarsMinLimit
    SQLString = "exec ntpCorrResultsAverageValuesParamRanges " & " '" & ParamsIdentifyer & "' "
    'Debug.Print SQLString
    Call ExecProcedureMSSQL(SQLString)
    Call WriteLog("процедура ntpCorrResultsAverageValues на MSSQL выполнена")


End Sub


Public Sub PearsonCorrelationPrepare(ByRef arrHistory() As Double, _
                                     ByRef arrCurrent() As Double, _
                                     ByVal n As Long)
' предварительный расчет показателей для дальнейшего расчета К

Dim i As Long

v1 = 0
v2 = 0
v3 = 0
v4 = 0
v5 = 0
v6 = 0
v7 = 0
v8 = 0
v9 = 0
v10 = 0
v11 = 0
v12 = 0
v13 = 0
v14 = 0
v15 = 0
v16 = 0
v17 = 0
v18 = 0
v19 = 0
v20 = 0
v21 = 0
'v22 = 0
'v23 = 0

For i = 1 To n
  v3 = v3 + arrCurrent(i - 1)
  v8 = v8 + arrCurrent(i - 1) * arrCurrent(i - 1)
  
Next i
v10 = v3 * v3
v15 = v8 * n
v17 = v15 - v10

End Sub

Public Function PearsonCorrelationFirst(ByRef arrHistory() As Double, _
                                     ByRef arrCurrent() As Double, _
                                     ByVal n As Long) _
                                     As Double
' расчет К для первого элемента
Dim i As Long

  v4 = 0
  v5 = 0
  v9 = 0
  
For i = 1 To n
  v4 = v4 + arrHistory(i - 1)
  v5 = v5 + arrHistory(i - 1) * arrCurrent(i - 1)
  v9 = v9 + arrHistory(i - 1) * arrHistory(i - 1)
Next i

v11 = v4 * v4
v12 = v3 * v4
v13 = v5 * n
v14 = v13 - v12
v16 = v9 * n
v18 = v16 - v11
v19 = v17 * v18
v20 = Sqr(v19)

'v21 = v14 / v20

If v14 = 0 And v20 = 0 Then
    v21 = 0
Else
    v21 = v14 / v20
End If

iNum = iNum

'v22 = (n * v9) - v16 * v8 - v10
'v22 = n * (v9 - v11) * (n * v8 - v10)
'v22 = v18
'v22 = n * (v9 - v11) * (n * v8 - v10)
PearsonCorrelationFirst = v21
'PearsonCorrelationFirst = (n * (v4 - v3) - v12) / Sqr(v22)
'PearsonCorrelationFirst = (v13 - v12) / Sqr(v22)
'PearsonCorrelationFirst = (v14) / (Sqr(v18) * Sqr(v17))

End Function

Public Function PearsonCorrelationAll(ByRef arrHistory() As Double, _
                                     ByRef arrCurrent() As Double, _
                                     ByVal n As Long)
                                     'ByVal arrHistoryOld As Double, _
                                     'ByVal arrHistoryNew As Double _
                                     ') As Double

' arrHistoryOld - удаленный элемент массива (на предыдущем шаге он был первым)
' arrHistoryNew - новый элемент массива

Dim i As Long

  v4 = 0
  v5 = 0
  v9 = 0
v13 = 0

For i = 1 To n
  v4 = v4 + arrHistory(i - 1)
  v5 = v5 + arrHistory(i - 1) * arrCurrent(i - 1)
  v9 = v9 + arrHistory(i - 1) * arrHistory(i - 1)
Next i

v13 = v5 * n
'v4 = v4 - arrHistoryOld + arrHistoryNew
'v9 = v9 - (arrHistoryOld * arrHistoryOld) + (arrHistoryNew * arrHistoryNew)
v11 = v4 * v4
v12 = v4 * v3
v14 = v13 - v12
v16 = v9 * n
v18 = v16 - v11
v19 = v18 * v17
v20 = Sqr(v19)

If v14 = 0 And v20 = 0 Then
    v21 = 0
Else
    v21 = v14 / v20
End If

iNum = iNum

'v22 = (n * v9) - v16 * v8 - v10
'v22 = n * (v9 - v11) * (n * v8 - v10)

PearsonCorrelationAll = v21
'PearsonCorrelationAll = (n * (v4 - v3) - v12) / Sqr(v22)
'PearsonCorrelationAll = (v14) / (Sqr(v18) * Sqr(v17))

End Function

Sub CalcCorrelation(ByRef arrHistoryCompare() As Double, ByRef arrCurrentCompare() As Double, arrCorrelationValues() As Variant, arrHistoryAll() As Variant, DeltaRangeMinLimit As Single, DeltaRangeMaxLimit As Single)
' расчет К:
' двигаем окно по массиву arrHistoryAll и считаем К с массивом arrCurrentCompare

'описание параметров:
'arrHistoryCompare() - массив-окно с историческими данными (по которым считаем К)
'arrCurrentCompare() - массив с текущими данными (по которым считаем К)
'arrCorrelationValues() - массив, в который записываем рассчитанные значения К
'arrHistoryAll() - массив со всеми историческими данными (по нему двигаем массив-окно)
'DeltaRangeMinLimit - минимально допустимая разница между текущими и историческими данными (0 - не учитывать эту разницу)
'DeltaRangeMaxLimit - максимально допустимая разница между текущими и историческими данными (0 - не учитывать эту разницу)

Dim SQLString As String
Dim i As Long
Dim j As Long
Dim CurrentRange As Single
Dim HistoryRange As Single
'Dim ArrValueFirst As Double




' предварительный расчет показателей
Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)



For i = 1 To (cntDataCurrentRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i




' считаем К для первого элемента
For i = 1 To 1 ' цикл по большой таблице
  For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
    
    'ArrValueFirst = 0
    '' при расчете К по ABV/ABVMini обнуляем первый элемент (иначе  будет округление/переполнение)
    'If ((DataSourceId = 2) And (FieldNumHistory_cn = 2 Or FieldNumHistory_cn = 3)) Then
    '    If j = 1 Then
    '        'ArrValueFirst = arrHistoryCompare(j - 1)
    '        ArrValueFirst = fMinValue(arrHistoryCompare) - 1
    '    End If
    '    arrHistoryCompare(j - 1) = arrHistoryCompare(j - 1) - ArrValueFirst '+ 1000000
    'End If
  Next j
  
    
  
  
  
  arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)
  'arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0

'------------------------
        'SQLString = "insert into ttemp(idn, f1) values(" & arrABVIDN(i - 1) & "," & Replace(arrCorrelationValues(i - 1), ",", ".") & ")"
        'DoCmd.RunSQL SQLString
'------------------------

Next i

' считаем К для всех баров
If IsCalcCorrOnlyForSameTime_cn = 0 Then
    For i = 2 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' цикл по большой таблице
      For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
        arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
        
        'ArrValueFirst = 0
        '' при расчете К по ABV/ABVMini обнуляем первый элемент (иначе  будет округление/переполнение)
        'If ((DataSourceId = 2) And (FieldNumHistory_cn = 2 Or FieldNumHistory_cn = 3)) Then
        '    If j = 1 Then
        '        'ArrValueFirst = arrHistoryCompare(j - 1)
        '        ArrValueFirst = fMinValue(arrHistoryCompare) - 1
        '    End If
        '    arrHistoryCompare(j - 1) = arrHistoryCompare(j - 1) - ArrValueFirst
        'End If
      
      Next j
      'arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows, arrHistoryAll(i - 2), arrHistoryCompare(j - 2))
      arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)
    Next i
End If




' считаем К только для баров, близких по времени к текущему
If IsCalcCorrOnlyForSameTime_cn = 1 Then


    ' если задан DeltaRangeMinLimit или DeltaRangeMaxLimit, то вычисляем диапазон текущих данных
    If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
        CurrentRange = fMaxValue(arrCurrentCompare) - fMinValue(arrCurrentCompare)
    End If



    For i = 2 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' цикл по большой таблице
      
      'arrCcloseTimeInMinutes (i + cntDataCurrentRows - 2) - время последнего исторического бара
      'CurrentBarTimeInMinutes - время текущего бара (в минутах с начала дня)
      'arrCcloseTimeInMinutes() - массив с временем исторических баров (в минутах с начала дня)
      'arrCorrelationValues(i - 1 + cntDataCurrentRows - 2) - значение К, рассчитанное на предыдущем шаге
      
      'If i = 272 Then
      '  i = i
      'End If
      
      iNum = i
      

      
      ' если время последнего исторического бара попадает в рассчитываемый промежуток, то заполняем массив для сравнения и считаем К (плюс захватываем один лишний бар для предварительного расчета)
      If ((((arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) >= (CurrentBarTimeInMinutes - DeltaMinutesCalcCorr_cn - PeriodMinutes_cn)) And (arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) <= (CurrentBarTimeInMinutes + DeltaMinutesCalcCorr_cn)))) _
            And _
          (arrCdate(i + cntDataCurrentRows - 2) < cdate_current)) Then ' И дата последнего исторического бара меньше чем дата текущего бара
            For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
                arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
                
                'ArrValueFirst = 0
                '' при расчете К по ABV/ABVMini обнуляем первый элемент (иначе  будет округление/переполнение)
                'If ((DataSourceId = 2) And (FieldNumHistory_cn = 2 Or FieldNumHistory_cn = 3)) Then
                '    If j = 1 Then
                '        'ArrValueFirst = arrHistoryCompare(j - 1)
                '        ArrValueFirst = fMinValue(arrHistoryCompare) - 1
                '    End If
                '    arrHistoryCompare(j - 1) = arrHistoryCompare(j - 1) - ArrValueFirst '+ 1000000
                'End If
                
            Next j
            
            ' если задан DeltaRangeMinLimit или DeltaRangeMaxLimit, то вычисляем диапазон исторических данных
            If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
                HistoryRange = fMaxValue(arrHistoryCompare) - fMinValue(arrHistoryCompare)
            End If
            
            ' если диапазон исторических данных превышает лимит, то ставим К = 0
            If ((DeltaRangeMinLimit > 0) And (HistoryRange < CurrentRange * DeltaRangeMinLimit)) Or ((DeltaRangeMaxLimit > 0) And (HistoryRange > CurrentRange * DeltaRangeMaxLimit)) Then
                arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
            Else
                ' иначе продолжаем расчет К
                ' если К считается для первого элемента из рассчитываемого промежутка, то считаем К заново (чтобы рассчитать заново все переменные)

                Call MakeArrayPlusAsDouble(arrHistoryCompare)
                'If ArrValueMin = ArrValueMinPrevious Then
                '    arrHistoryRemoved = ArrValueFirstPrevious
                'Else
                '    arrHistoryRemoved = ArrValueMin - ArrValueMinPrevious
                'End If
                
                'If iNum = 2 Then
                '    Call ClearTable("ttemp4") ' 1000000
                '    Call ClearTable("ttemp5") ' 1000000
                '    Call WriteArrToTable(arrHistoryCompare, "ttemp4", "f1")
                '    Call WriteArrToTable(arrCurrentCompare, "ttemp5", "f1")
                'End If
                
                'If iNum = 358046 Then
                '    Call ClearTable("ttemp4") ' 1000000
                '    Call ClearTable("ttemp5") ' 1000000
                '    Call WriteArrToTable(arrHistoryCompare, "ttemp4", "f1")
                '    Call WriteArrToTable(arrCurrentCompare, "ttemp5", "f1")
                'End If
                
                
                
                
                If arrCorrelationValues(i - 1 + cntDataCurrentRows - 2) = 0 Then
                    Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)
                    arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)
                Else
                    'arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows, arrHistoryAll(i - 2) - ArrValueFirst, arrHistoryCompare(j - 2))
                    'arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows, arrHistoryAll(i - 2), arrHistoryCompare(j - 2))
                    'arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows, arrHistoryRemoved, arrHistoryCompare(j - 2))
                    arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)
                End If
            End If
          
      Else
            'если время последнего исторического бара не попадает в рассчитываемый промежуток, то ставим К = 0
            arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
      End If
    Next i
    
'Call ClearTable("ttemp3_") ' 1000000
'Call WriteArr2ToTable(arrIDNSorted, arrCorrelationValues, "ttemp3_", "f1", "f2") ' 1000000


    
    
End If


End Sub





Sub CalcCorrelationPreviousDay_old(ByRef arrHistoryCompare() As Double, ByRef arrCurrentCompare() As Double, arrCorrelationValues() As Variant, arrHistoryAll() As Variant, DeltaRangeMinLimit As Single, DeltaRangeMaxLimit As Single)
' расчет К за предыдущий день:
' двигаем окно по массиву arrHistoryAll и считаем К с массивом arrCurrentCompare

'описание параметров:
'arrHistoryCompare() - массив-окно с историческими данными (по которым считаем К)
'arrCurrentCompare() - массив с текущими данными (по которым считаем К)
'arrCorrelationValues() - массив, в который записываем рассчитанные значения К
'arrHistoryAll() - массив со всеми историческими данными (по нему двигаем массив-окно)
'DeltaRangeMinLimit - минимально допустимая разница между текущими и историческими данными (0 - не учитывать эту разницу)
'DeltaRangeMaxLimit - максимально допустимая разница между текущими и историческими данными (0 - не учитывать эту разницу)

Dim SQLString As String
Dim i As Long
Dim j As Long
Dim CurrentRange As Single
Dim HistoryRange As Single

' предварительный расчет показателей
Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)



For i = 1 To (cntDataPreviousDayRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i

' считаем К для первого элемента
For i = 1 To 1 ' цикл по большой таблице
  For j = 1 To cntDataPreviousDayRows ' цикл по маленькой таблице
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
  Next j
  arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
  'arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = 0

'------------------------
        'SQLString = "insert into ttemp(idn, f1) values(" & arrABVIDN(i - 1) & "," & Replace(arrCorrelationValues(i - 1), ",", ".") & ")"
        'DoCmd.RunSQL SQLString
'------------------------

Next i




    ' если задан DeltaRangeMinLimit или DeltaRangeMaxLimit, то вычисляем диапазон текущих данных
    If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
        CurrentRange = fMaxValue(arrCurrentCompare) - fMinValue(arrCurrentCompare)
    End If



    For i = 2 To (cntDataHistoryRows - cntDataPreviousDayRows + 1) ' цикл по большой таблице
      
      'arrCcloseTimeInMinutes_cn (i + cntDataPreviousDayRows - 2) - время последнего исторического бара
      'CurrentBarTimeInMinutes - время текущего бара (в минутах с начала дня)
      'arrCcloseTimeInMinutes_cn() - массив с временем исторических баров (в минутах с начала дня)
      'arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 2) - значение К, рассчитанное на предыдущем шаге
      
      ' если время последнего исторического бара попадает в рассчитываемый промежуток, то заполняем массив для сравнения и считаем К (плюс захватываем один лишний бар для предварительного расчета)
      'If ((arrCcloseTimeInMinutes_cn(i + cntDataPreviousDayRows - 2) >= (cTimeInMinutesPreviousDayLast - cTimeInMinutesPreviousDayFirst - PeriodMinutes)) And (arrCcloseTimeInMinutes_cn(i + cntDataPreviousDayRows - 2) <= (24 * 60))) Then
      ' если дата последнего исторического бара совпадает с датой первого исторического бара, то заполняем массив для сравнения и считаем К (плюс захватываем один лишний бар для предварительного расчета)
       If arrCdate(i + cntDataPreviousDayRows - 2) = arrCdate(i - 1) Then
            
            For j = 1 To cntDataPreviousDayRows ' цикл по маленькой таблице
                arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
            Next j
            
            ' если задан DeltaRangeMinLimit или DeltaRangeMaxLimit, то вычисляем диапазон исторических данных
            If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
                HistoryRange = fMaxValue(arrHistoryCompare) - fMinValue(arrHistoryCompare)
            End If
            
            ' если диапазон исторических данных превышает лимит, то ставим К = 0
            If ((DeltaRangeMinLimit > 0) And (HistoryRange < CurrentRange * DeltaRangeMinLimit)) Or ((DeltaRangeMaxLimit > 0) And (HistoryRange > CurrentRange * DeltaRangeMaxLimit)) Then
                arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = 0
            Else
                ' иначе продолжаем расчет К
                ' если К считается для первого элемента из рассчитываемого промежутка, то считаем К заново (чтобы рассчитать заново все переменные)
                If arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 2) = 0 Then
                    Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
                    arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
                Else
                    arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows, arrHistoryAll(i - 2), arrHistoryCompare(j - 2))
                End If
            End If
          
      Else
            'если время последнего исторического бара не попадает в рассчитываемый промежуток, то ставим К = 0
            arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = 0
      End If
    Next i
    
    'Call ClearTable("ttemp3")
    'Call WriteArr2ToTable(arrIDNSorted, arrCorrelationValues, "ttemp3", "f1", "f2")
    
    CcorrPreviousDayMax = 0
    CcorrCurrentDayMax = 0
    cDateLastStep = ""
    CurrentDayCntBars = 10000
    
    'Call ClearTable("ttemp3")
    'Call WriteArr2ToTable(arrCdateIDN, arrCdate, "ttemp3", "f1", "f2")
    


    ' теперь переносим максимальное значение К за текущий день на весь следующий день
    For i = 1 To cntDataHistoryRows ' цикл по большой таблице
        ' если перешли на следующую дату - то обнуляем CcorrCurrentDayMax (максимальная К за текущий день)
        If arrCdate(i - 1) <> cDateLastStep And CurrentDayCntBars > CurrentDayCntBarsMinLimit Then
            CcorrPreviousDayMax = CcorrCurrentDayMax
            CcorrCurrentDayMax = 0
            CurrentDayCntBars = 0
            
            ' запоминаем текущую дату
            cDateLastStep = arrCdate(i - 1)
        End If
        
        ' обновляем CcorrCurrentDayMax (максимальная К за текущий день)
        If arrCorrelationValues(i - 1) > CcorrCurrentDayMax Then
            CcorrCurrentDayMax = arrCorrelationValues(i - 1)
        End If
        
        ' переносим К с прошлого дня на текущий
        arrCorrelationValues(i - 1) = CcorrPreviousDayMax
        
        ' увеличиваем счетчик баров в дне
        CurrentDayCntBars = CurrentDayCntBars + 1
    Next i
    
    'Call ClearTable("ttemp3")
    'Call WriteArr2ToTable(arrIDNSorted, arrCorrelationValues, "ttemp3", "f1", "f2")
    


End Sub


