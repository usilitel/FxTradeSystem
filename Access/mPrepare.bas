Attribute VB_Name = "mPrepare"
'Option Compare Database
Option Explicit


Sub FillArrDataHistory_new(tblDataHistoryName As String)
' заполнение ArrDataHistory (делать только 1 раз)

Dim SQLString As String

    cntDataHistoryRows = DCount("*", tblDataHistoryName)

    SQLString = " select * from " & tblDataHistory & " order by idn"

    Set rstTemp = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    Erase arrDataHistory
    arrDataHistory = rstTemp.GetRows(cntDataHistoryRows)
    rstTemp.Close
    
    
End Sub


Sub FillArrCorrTotal(tblDataHistoryName As String)
' определение массива с общей К

Dim i As Long
    
    cntDataHistoryRows = DCount("*", tblDataHistoryName)
    Erase arrCORRTotal
    ReDim arrCORRTotal(0 To (cntDataHistoryRows - 1))
    Erase arrIDNSorted
    ReDim arrIDNSorted(0 To (cntDataHistoryRows - 1))
    
    For i = 1 To cntDataHistoryRows
        arrIDNSorted(i - 1) = arrDataHistory(0, i - 1)
    Next i

End Sub




Sub FillArrDataHistory_cn()
' берем историю для n-го расчета

Dim i As Long
Dim SQLString As String
'Dim arrCcloseMin, arrCcloseMin As Double



    ' если брать данные непосредственно из таблицы (без запроса), то возникает ошибка:
    ' первые записи в массиве почему-то перемешаны (возможно не только первые)
    ' поэтому лучше заполнять массив из жестко отсортированного набора
    

    ' берем историю для n-го расчета (если еще не брали)
    If Not ((arrDataHistory_cn_filled = 1) And (tblDataHistory_cn_previous = tblDataHistory_cn)) Then
    
        SQLString = " select * from " & tblDataHistory_cn & " order by idn"
    
        Set rstTemp = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
        rstTemp.MoveLast
        cntDataHistoryRows_cn = rstTemp.RecordCount
        
        rstTemp.MoveFirst
        
        Erase arrDataHistory_cn
        arrDataHistory_cn = rstTemp.GetRows(cntDataHistoryRows_cn)
        rstTemp.Close
        
        Erase arrCclose
        Erase arrCdate
        Erase arrCcloseTimeInMinutes_cn
        Erase arrCorr_cn
        Erase arrCorrMaxForDates_cn
        
        ReDim arrCclose(0 To (cntDataHistoryRows_cn - 1))
        ReDim arrCdate(0 To (cntDataHistoryRows_cn - 1))
        ReDim arrCcloseTimeInMinutes_cn(0 To (cntDataHistoryRows_cn - 1))
        ReDim arrCorr_cn(0 To (cntDataHistoryRows_cn - 1))
        ReDim arrCorrMaxForDates_cn(1, 0 To (cntDataHistoryRows_cn - 1))
        
        For i = 1 To cntDataHistoryRows_cn
            'arrCclose(i - 1) = arrDataHistory_cn(FieldNumHistory_cn, i - 1) ' + 1000000
            arrCdate(i - 1) = arrDataHistory_cn(5, i - 1)
            arrCcloseTimeInMinutes_cn(i - 1) = arrDataHistory_cn(4, i - 1)
            'arrCorrMaxForDates_cn(0, i - 1) = "__________"
            'arrCorrMaxForDates_cn(1, i - 1) = -100
        Next i
        
        
        ' если считаем К по ABV/ABVMini, то приводим значения массива
        
        
        
    
        ' если временной период, по которому рассчитывалась К, НЕ совпадает с периодом графика, то заполняем массив arrCdateTime (понадобится для перебора К)
        If cntDataHistoryRows <> cntDataHistoryRows_cn Then
            Erase arrCdateTime
            Erase arrCdateTime_cn
            
            ReDim arrCdateTime(0 To (cntDataHistoryRows - 1))
            ReDim arrCdateTime_cn(0 To (cntDataHistoryRows_cn - 1))
            
            For i = 1 To cntDataHistoryRows
                ' получаем CdateTime по историческим данным (для графика)
                arrCdateTime(i - 1) = arrDataHistory(5, i - 1) & " " & Replace(Space(2 - Len(arrDataHistory(4, i - 1) \ 60)), " ", "0") & (arrDataHistory(4, i - 1) \ 60) & ":" & Replace(Space(2 - Len(arrDataHistory(4, i - 1) Mod 60)), " ", "0") & (arrDataHistory(4, i - 1) Mod 60)
            Next i
            
            For i = 1 To cntDataHistoryRows_cn
                ' получаем CdateTime по историческим данным (для n-го расчета К)
                arrCdateTime_cn(i - 1) = arrDataHistory_cn(5, i - 1) & " " & Replace(Space(2 - Len(arrDataHistory_cn(4, i - 1) \ 60)), " ", "0") & (arrDataHistory_cn(4, i - 1) \ 60) & ":" & Replace(Space(2 - Len(arrDataHistory_cn(4, i - 1) Mod 60)), " ", "0") & (arrDataHistory_cn(4, i - 1) Mod 60)
            Next i
        End If
    
    
    End If
        
        
    'Erase arrCorr_cn
    'Erase arrCorrMaxForDates_cn
            
    'ReDim arrCorr_cn(0 To (cntDataHistoryRows_cn - 1))
    'ReDim arrCorrMaxForDates_cn(1, 0 To (cntDataHistoryRows_cn - 1))
            
    For i = 1 To cntDataHistoryRows_cn
        arrCclose(i - 1) = arrDataHistory_cn(FieldNumHistory_cn, i - 1) ' + 1000000
        arrCorr_cn(i - 1) = -1
        arrCorrMaxForDates_cn(0, i - 1) = "__________"
        arrCorrMaxForDates_cn(1, i - 1) = -100
    Next i
        
    If MAPeriod_cn > 1 Then
        Call CalcMAasVariant(arrCclose(), MAPeriod_cn) ' вычисляем МА
    End If
        

    
    arrDataHistory_cn_filled = 1 ' 1 - исторические массивы для расчета _cn заполнены
    tblDataHistory_cn_previous = tblDataHistory_cn ' запоминаем название исторической таблицы
    
    
    
End Sub




Sub FillArrDataCurrent_cn()
' берем текущие данные для n-го расчета

Dim i As Long
Dim SQLString As String
'Dim ABVFirst, ABVMiniFirst As Double
'Dim ArrValueFirst As Double


    
    


    If cntBarsCalcCorr_cn = 0 Then
        SQLString = " select * from " & tblDataCurrent_cn & " where cdatetime >= '" & cDateTimeFirst_cn & "' and cdatetime <= '" & cDateTimeLast_cn & "' order by cdatetime"
    Else
        SQLString = " SELECT * FROM (select top " & cntBarsCalcCorr_cn & " * from " & tblDataCurrent_cn & " where cdatetime <= '" & cDateTimeLast_cn & "' order by cdatetime desc) order by cdatetime"
    End If
    
    
    
    Set rstTemp = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    rstTemp.MoveLast
    cntDataCurrentRows_cn = rstTemp.RecordCount
    cntDataCurrentRows = cntDataCurrentRows_cn
    cdate_current = rstTemp.Fields("cdate").Value
    rstTemp.MoveFirst
    
    Erase arrDataCurrent_cn
    arrDataCurrent_cn = rstTemp.GetRows(cntDataCurrentRows_cn)
    rstTemp.Close
    
    Erase arrCclose_cn
    'Erase arrIDN_cn
    'Erase arrCdate_cn
    Erase arrDataHistoryCompare
    
    ReDim arrCclose_cn(0 To (cntDataCurrentRows_cn - 1))
    'ReDim arrIDN_cn(0 To (cntDataCurrentRows_cn - 1))
    'ReDim arrCdate_cn(0 To (cntDataCurrentRows_cn - 1))
    ReDim arrDataHistoryCompare(0 To (cntDataCurrentRows_cn - 1))
     
     
    

    For i = 1 To cntDataCurrentRows_cn
        arrCclose_cn(i - 1) = arrDataCurrent_cn(FieldNumCurrent_cn, i - 1)
        
'        ArrValueFirst = 0
'        ' при расчете К по ABV/ABVMini обнуляем первый элемент (иначе  будет округление/переполнение)
'        If ((DataSourceId = 2) And (FieldNumCurrent_cn = 7 Or FieldNumCurrent_cn = 8)) Then
'            If i = 1 Then
'                'ArrValueFirst = arrCclose_cn(i - 1)
'                ArrValueFirst = fMinValue(arrCclose_cn) - 1
'            End If
'            arrCclose_cn(i - 1) = arrCclose_cn(i - 1) - ArrValueFirst '+ 1000000
'        End If
        
        'arrIDN_cn(i - 1) = arrDataCurrent_cn(0, i - 1)
        'arrCdate_cn(i - 1) = arrDataCurrent_cn(5, i - 1)
        If i = cntDataCurrentRows_cn Then
            'CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(12, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(12, i - 1), 4, 2)) ' время текущего бара (в минутах с начала дня)
            If DataSourceId = 2 Then
                CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(12, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(12, i - 1), 4, 2)) ' время текущего бара (в минутах с начала дня)
            End If
            If DataSourceId = 3 Then
                CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(2, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(2, i - 1), 4, 2)) ' время текущего бара (в минутах с начала дня)
            End If
        End If
    Next i
    
    Call MakeArrayPlusAsDouble(arrCclose_cn)

    If MAPeriod_cn > 1 Then
        Call CalcMAasDouble(arrCclose_cn(), MAPeriod_cn) ' вычисляем МА
    End If
    
    'Call ClearTable("t1")
    'Call WriteArrToTable(arrCclose_cn, "t1", "c1")
    
    
    
End Sub



Sub FillArrDataHistory_old(tblDataHistoryName As String, idValue As Integer)
' первоначальное заполнение массивов с историческими данными
'idValue - какое значение из tblDataHistoryName заносим в массив:
'1 - cclose
'2 - ABV
'3 - ABVMini


Dim i As Long

' tblDataHistoryName = "ntPeriodsDataCCLOSE_1_2_5_1_1"

    'StartTime = GetTickCount    'запоминаем начальное время

'Set DB = Access.CurrentDb

Call WriteLog("--------------------------")
Call WriteLog("начало заполнения массивов (idValue = " & idValue & ")")


cntDataHistoryRows = DCount("*", tblDataHistoryName)
'cntDataHistoryRows = 50000

Erase arrDataHistory
Erase arrCclose
Erase arrIDN
Erase arrABV
Erase arrABVIDN
Erase arrABVMini
Erase arrABVMiniIDN
Erase arrCcloseTimeInMinutes
Erase arrMAVolume
Erase arrMAVolumeIDN
Erase arrPreviousDay
Erase arrPreviousDayIDN
Erase arrCdate
Erase arrCdateIDN



      
      



' берем историю
Set rstTemp = DB.OpenRecordset(tblDataHistoryName)
' !!! ошибка: первые записи в массиве почему-то перемешаны (возможно не только первые)
'     лучше заполнять массив из жестко отсортированного набора
arrDataHistory = rstTemp.GetRows(cntDataHistoryRows)
rstTemp.Close
    
ReDim arrCclose(0 To (cntDataHistoryRows - 1)) 'As Double
ReDim arrIDN(0 To (cntDataHistoryRows - 1)) 'As Double
ReDim arrABV(0 To (cntDataHistoryRows - 1))
ReDim arrABVIDN(0 To (cntDataHistoryRows - 1))
ReDim arrABVMini(0 To (cntDataHistoryRows - 1))
ReDim arrABVMiniIDN(0 To (cntDataHistoryRows - 1))
ReDim arrCcloseTimeInMinutes(0 To (cntDataHistoryRows - 1))
ReDim arrMAVolume(0 To (cntDataHistoryRows - 1))
ReDim arrMAVolumeIDN(0 To (cntDataHistoryRows - 1))
ReDim arrPreviousDay(0 To (cntDataHistoryRows - 1))
ReDim arrPreviousDayIDN(0 To (cntDataHistoryRows - 1))
ReDim arrCdate(0 To (cntDataHistoryRows - 1))
ReDim arrCdateIDN(0 To (cntDataHistoryRows - 1))



For i = 1 To cntDataHistoryRows
  arrCclose(i - 1) = arrDataHistory(1, i - 1) '.Value
  arrIDN(i - 1) = arrDataHistory(0, i - 1)
  'arrABV(i - 1) = arrDataHistory(2, i - 1)
  'arrABVIDN(i - 1) = arrDataHistory(0, i - 1)
  'arrABVMini(i - 1) = arrDataHistory(3, i - 1)
  'arrABVMiniIDN(i - 1) = arrDataHistory(0, i - 1)
Next i

If MACclosePeriod > 1 Then
    Call CalcMAasVariant(arrCclose(), MACclosePeriod) ' вычисляем МА(Cclose)
End If


If WeightCORRABV <> 0 Or WeightCORREasyABV <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrABV(i - 1) = arrDataHistory(2, i - 1)
      arrABVIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MAABVPeriod > 1 Then
        Call CalcMAasVariant(arrABV(), MAABVPeriod) ' вычисляем МА(ABV)
    End If
End If

If WeightCORRABVMini <> 0 Or WeightCORREasyABVMini <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrABVMini(i - 1) = arrDataHistory(3, i - 1)
      arrABVMiniIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i

    If MAABVMiniPeriod > 1 Then
        Call CalcMAasVariant(arrABVMini(), MAABVMiniPeriod) ' вычисляем МА(ABVMini)
    End If
End If

' вычисляем МА(Volume) и записываем в массив
If WeightCORRMAVolume <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrMAVolume(i - 1) = arrDataHistory(6, i - 1)
      arrMAVolumeIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MAVolumePeriod > 1 Then
        Call CalcMAasVariant(arrMAVolume(), MAVolumePeriod) ' вычисляем МА(Volume)
    End If
End If


If IsCalcCorrOnlyForSameTime = 1 Or WeightCORRPreviousDay <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrCcloseTimeInMinutes(i - 1) = arrDataHistory(4, i - 1)
    Next i
End If


' заполняем массив cclose за предыдущий день (для расчета К за предыдущий день)
If WeightCORRPreviousDay <> 0 Then
    For i = 1 To cntDataHistoryRows
        arrPreviousDay(i - 1) = arrDataHistory(1, i - 1) '.Value
        arrPreviousDayIDN(i - 1) = arrDataHistory(0, i - 1)
        
        arrCdate(i - 1) = arrDataHistory(5, i - 1) '.Value
        arrCdateIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MACclosePreviousDayPeriod > 1 Then
        Call CalcMAasVariant(arrPreviousDay(), MACclosePreviousDayPeriod) ' вычисляем МА(Cclose за предыдущий день)
    End If
    
End If





    'TotalTime = GetTickCount - StartTime    'вычисляем затраченное время
    'MsgBox "Затрачено времени: " & TotalTime & " мс", , ""

' массивы arrDataHistory, arrCCLOSE, arrIDN заполнены
'MsgBox LBound(arrCCLOSE)

Call WriteLog("конец заполнения массивов (idValue = " & idValue & ")")

End Sub


Public Sub CalcMAasVariant(ArrayValues() As Variant, MAPeriod As Integer)
' процедура вычисляет MA с периодом MAPeriod по массиву ArrayValues и записывает значения MA на место исходного массива
' !!! править синхронно с процедурой CalcMAasDouble !!!

' ArrayValues() - одномерный массив с данными, по которым нужно вычислить МА
'                 нумерация элементов должна начинаться с 0
' MAPeriod - период МА
    
    Dim ArrayMAValues() As Variant
    Dim MAValue As Single
    Dim ValueFirst As Single
    Dim ValueNext As Single
    Dim i As Long
    Dim lb As Long, ub As Long
    
    lb = LBound(ArrayValues)
    ub = UBound(ArrayValues)
    
    Erase ArrayMAValues
    ReDim ArrayMAValues(lb To ub)

    ' вычисляем первые значения MA
    MAValue = 0
    For i = 1 To MAPeriod
      MAValue = MAValue + ArrayValues(i - 1)
      ArrayMAValues(i - 1) = MAValue * (MAPeriod / i) ' умножаем на вес для равномерности
    Next i

    ' заполняем весь остальной массив ArrayMAValues
    For i = (MAPeriod + 1) To (ub + 1)
      ValueFirst = ArrayValues(i - MAPeriod - 1) ' элемент, который нужно вычесть из MAValue
      ValueNext = ArrayValues(i - 1) ' элемент, который нужно добавить к MAValue
      MAValue = MAValue - ValueFirst + ValueNext
      ArrayMAValues(i - 1) = MAValue
    Next i

    ' переписываем массив ArrayMAValues в исходный массив ArrayValues
    For i = lb To ub
      ArrayValues(i) = ArrayMAValues(i)
    Next i
    
    Erase ArrayMAValues

End Sub

Public Sub CalcMAasDouble(ArrayValues() As Double, MAPeriod As Integer)
' процедура вычисляет MA с периодом MAPeriod по массиву ArrayValues и записывает значения MA на место исходного массива
' !!! править синхронно с процедурой CalcMAasVariant !!!

' ArrayValues() - одномерный массив с данными, по которым нужно вычислить МА
'                 нумерация элементов должна начинаться с 0
' MAPeriod - период МА
    
    Dim ArrayMAValues() As Double
    Dim MAValue As Single
    Dim ValueFirst As Single
    Dim ValueNext As Single
    Dim i As Long
    Dim lb As Long, ub As Long
    
    lb = LBound(ArrayValues)
    ub = UBound(ArrayValues)
    
    Erase ArrayMAValues
    ReDim ArrayMAValues(lb To ub)

    ' вычисляем первые значения MA
    MAValue = 0
    For i = 1 To MAPeriod
      MAValue = MAValue + ArrayValues(i - 1)
      ArrayMAValues(i - 1) = MAValue * (MAPeriod / i) ' умножаем на вес для равномерности
    Next i

    ' заполняем весь остальной массив ArrayMAValues
    For i = (MAPeriod + 1) To (ub + 1)
      ValueFirst = ArrayValues(i - MAPeriod - 1) ' элемент, который нужно вычесть из MAValue
      ValueNext = ArrayValues(i - 1) ' элемент, который нужно добавить к MAValue
      MAValue = MAValue - ValueFirst + ValueNext
      ArrayMAValues(i - 1) = MAValue
    Next i

    ' переписываем массив ArrayMAValues в исходный массив ArrayValues
    For i = lb To ub
      ArrayValues(i) = ArrayMAValues(i)
    Next i
    
    Erase ArrayMAValues

End Sub


Sub FillTablesDataCurrent(FillTblDataCurrentMSSQL As Integer, pCntBarsCalcCorr As Integer)
' заполнение таблиц с текущими данными
' процедура нужна для:
' 1) получения нерассчитанных промежутков
' 2) вычисления К по нерассчитанным промежуткам


' FillTblDataCurrentMSSQL: 1 - заполнять tblDataCurrentMSSQL, 0 - не заполнять


Dim i As Long
Dim SQLString As String
Dim ABV_total As Single
Dim SourceTableName As String

    'StartTime = GetTickCount    'запоминаем начальное время

Call WriteLog("-----начало заполнения таблиц с текущими данными")



' перекидываем только нужные текущие данные в буферную таблицу
If DataSourceId = 1 Then
    'MT
    SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose) "
    SQLString = SQLString & "select cdate, ctime, cdate + "" "" + ctime, copen, chigh, clow, cclose from " & tblDataCurrent
    SQLString = SQLString & " where (cdate+"" "" +ctime) >= """ & cDateTimeFirst & """"
    SQLString = SQLString & "   and (cdate+"" "" +ctime) <= """ & cDateTimeLast & """"
End If



If DataSourceId = 3 Then
    'Quik
    ' перекидываем текущие данные в буферную таблицу (иначе виснет дальнейший расчет)
    SQLString = "insert into " & tblDataCurrentDDEBufer & "(cdatetime, cdate, ctime, copen, chigh, clow, cclose, cvolume, sumspros, sumpredl, countbuy, countsell, cntOpenPos) "
    SQLString = SQLString & "select cdatetime, date, time, open, high, low, close, volume, sumspros, sumpredl, countbuy, countsell, cntOpenPos from " & tblDataCurrentDDE

    Call ClearTable(tblDataCurrentDDEBufer)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("таблица " & tblDataCurrentDDEBufer & " заполнена")


    'вычисляем ABV и другие показатели
    SQLString = "insert into " & tblDataCurrent & "(cdatetime, cdate, ctime, copen, chigh, clow, cclose, volume, ABV, ABVMini, countbuy, countsell, avgBuyOrder, avgSellOrder, ccntOpenPos, sumspros, sumpredl) "
    SQLString = SQLString & " select t1.cdatetime, t1.cdate, t1.ctime, t1.copen, t1.chigh, t1.clow, t1.cclose, t1.cvolume, "
    'SQLString = SQLString & "       (select SUM(sumspros-sumpredl) from QuikDDEBufer where cdatetime <= t1.cdatetime) as ABV, "
    SQLString = SQLString & "        0 as ABV, "
    SQLString = SQLString & "        0 as ABVMini, "
    'SQLString = SQLString & "        countbuy as ABMmPosition0, "
    'SQLString = SQLString & "        countsell as ABMmPosition1, "
    SQLString = SQLString & "        countbuy as countbuy, "
    SQLString = SQLString & "        countsell as countsell, "
    SQLString = SQLString & "        IIF(countbuy = 0, 0, sumspros/countbuy) as avgBuyOrder, "
    SQLString = SQLString & "        IIF(countsell = 0, 0, sumpredl/countsell) as avgSellOrder, "
    SQLString = SQLString & "        cntOpenPos, sumspros, sumpredl "
    SQLString = SQLString & " from " & tblDataCurrentDDEBufer & " t1 "
    SQLString = SQLString & " order by t1.cdatetime "

    Call ClearTable(tblDataCurrent)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("таблица " & tblDataCurrent & " заполнена")



    ' удаляем последнюю запись (т.к. в QUIK это - текущий бар)
    Set rstTemp3 = DB.OpenRecordset(tblDataCurrent)
    rstTemp3.MoveLast
    rstTemp3.Delete
    rstTemp3.Close
    Call WriteLog("последняя запись в таблице " & tblDataCurrent & " удалена")


    'вычисляем ABV
    ABV_total = 0
    Set rstTemp3 = DB.OpenRecordset(tblDataCurrent)
    rstTemp3.MoveFirst
    For i = 1 To DCount("*", tblDataCurrent)
        ABV_total = ABV_total + rstTemp3.Fields("sumspros").Value - rstTemp3.Fields("sumpredl").Value
        rstTemp3.Edit
        rstTemp3.Fields("ABV").Value = ABV_total
        rstTemp3.Update
        rstTemp3.MoveNext
    Next i
    rstTemp3.Close
    
    
    Call WriteLog("ABV в таблице " & tblDataCurrent & " вычислен")
End If


If DataSourceId = 2 Then
    'NT
    
    If ((pCntBarsCalcCorr = 0) And (cntSourceFiles = 1)) Then ' NT7
        SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, cvolume) "
        SQLString = SQLString & "select cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, Volume from " & tblDataCurrent
        SQLString = SQLString & " where cdatetime >= """ & cDateTimeFirst & """"
        SQLString = SQLString & "   and cdatetime <= """ & cDateTimeLast & """"
        SQLString = SQLString & " order by cdatetime "
    End If
    
    If ((pCntBarsCalcCorr = 0) And (cntSourceFiles > 1)) Then ' NT8
        SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, cvolume, BSV, BSVMini) "
        SQLString = SQLString & "select cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, Volume, BSV, BSVMini from " & tblDataCurrent
        SQLString = SQLString & " where cdatetime >= """ & cDateTimeFirst & """"
        SQLString = SQLString & "   and cdatetime <= """ & cDateTimeLast & """"
        SQLString = SQLString & " order by cdatetime "
    End If
    
    If (pCntBarsCalcCorr <> 0) Then
        SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, cvolume) "
        SQLString = SQLString & "select cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, Volume from "
        SQLString = SQLString & "(select top " & pCntBarsCalcCorr & " * from " & tblDataCurrent & " where cdatetime <= """ & cDateTimeLast & """" & " order by cdatetime desc) "
        SQLString = SQLString & " order by cdatetime "
    End If
    
    Call ClearTable(tblDataCurrentBufer)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
End If

If DataSourceId = 3 Then
    'Quik
    
    If pCntBarsCalcCorr = 0 Then
        SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, cvolume) "
        SQLString = SQLString & "select cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, Volume from " & tblDataCurrent
        SQLString = SQLString & " where cdatetime >= """ & cDateTimeFirst & """"
        SQLString = SQLString & "   and cdatetime <= """ & cDateTimeLast & """"
        SQLString = SQLString & " order by cdatetime "
    Else
        'SQLString = " SELECT * FROM (select top " & cntBarsCalcCorr_cn & " * from " & tblDataCurrent_cn & " where cdatetime <= '" & cDateTimeLast_cn & "' order by cdatetime desc) order by cdatetime"
        SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, cvolume) "
        SQLString = SQLString & "select cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini, Volume from "
        SQLString = SQLString & "(select top " & pCntBarsCalcCorr & " * from " & tblDataCurrent & " where cdatetime <= """ & cDateTimeLast & """" & " order by cdatetime desc) "
        SQLString = SQLString & " order by cdatetime "
    End If
    
    Call WriteLog("начало заполнения " & tblDataCurrentBufer)
    
    Call ClearTable(tblDataCurrentBufer)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("конец заполнения " & tblDataCurrentBufer)
    
End If




If (isLogTables = 2 Or isLogTables = 1) And DataSourceId = 2 Then
    SQLString = "insert into ntImport_log (cinfo) "
    SQLString = SQLString & " select " & """" & cDateTimeLast & "; " & CStr(Now) & """"
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString

    SQLString = "insert into ntImport_log (cdateOld, ctimeOld, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, cdate, ctime, cdatetime) "
    SQLString = SQLString & " select cdateOld, ctimeOld, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, cdate, ctime, cdatetime "
    SQLString = SQLString & " from  " & tblDataCurrent
    SQLString = SQLString & " order by cdatetime "
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("таблица ntImport_log заполнена; cDateTimeLast = " & cDateTimeLast)

    SQLString = "insert into " & tblDataCurrentBufer & "_log" & " (cinfo) "
    SQLString = SQLString & " select " & """" & cDateTimeLast & "; " & CStr(Now) & """"
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    SQLString = "insert into " & tblDataCurrentBufer & "_log" & " (idn, cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini) "
    SQLString = SQLString & " select idn, cdate, ctime, copen, chigh, clow, cclose, ABV, ABVMini "
    SQLString = SQLString & " from " & tblDataCurrentBufer
    SQLString = SQLString & " order by idn "
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("таблица " & tblDataCurrentBufer & "_log" & " заполнена; cDateTimeLast = " & cDateTimeLast)

End If
    
' сохраняем копию таблицы для проверки
'If isLogTables = 1 Then
    
'End If

' оставляем в буферной таблице только нужные записи
'SQLString = "delete from " & tblDataCurrentBufer
'SQLString = SQLString & " where (cdate+"" "" +ctime) < """ & cDateTimeFirst & """"
'SQLString = SQLString & "    or (cdate+"" "" +ctime) > """ & cDateTimeLast & """"
'Application.SetOption "Confirm Action Queries", False
'DoCmd.RunSQL SQLString

cntDataCurrentRows = DCount("*", tblDataCurrentBufer)


If FillTblDataCurrentMSSQL = 1 Then
    ' перекидываем текущие данные на SQL Server
    'Call ClearTableMSSQL(tblDataCurrentMSSQL)
    SQLString = "delete from " & tblDataCurrentMSSQL & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
    DB.Execute SQLString, dbSeeChanges + dbFailOnError
    
    'SQLString = " BEGIN TRANSACTION "
    SQLString = " insert into " & tblDataCurrentMSSQL & "(cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer) select cdate, ctime, copen, chigh, clow, cclose, '" & ParamsIdentifyer & "' from " & tblDataCurrentBufer
    'SQLString = SQLString & " COMMIT TRANSACTION "
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    
    '-----------------------------
    If (isLogTables = 2 Or isLogTables = 1) Then
        ' проверяем все ли записи вставились на MSSQL
    
        SQLString = " select count(*) as cntrecords from " & tblDataCurrentBufer
        Set rstTemp3 = DB.OpenRecordset(SQLString)
        i = rstTemp3.Fields(0)
        rstTemp3.Close
        Call WriteLog("(7) количество записей в tblDataCurrentBufer = " & i)
        
        SQLString = " select count(*) as cntrecords from " & tblDataCurrentMSSQL & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
        Set rstTemp3 = DB.OpenRecordset(SQLString)
        i = rstTemp3.Fields(0)
        rstTemp3.Close
        Call WriteLog("(8) количество записей в tblDataCurrentMSSQL = " & i)
    End If
    '-----------------------------
    
    
End If


Call WriteLog("-----конец заполнения таблиц с текущими данными")



End Sub

Public Function IsTable(NameTable As String) As Boolean
   Dim i As Integer
   IsTable = False
   For i = 0 To CurrentDb.TableDefs.Count - 1
      If CurrentDb.TableDefs(i).Name = NameTable Then IsTable = True
   Next i
End Function

Sub ChangeCDateTimeFirstToReal()
' меняем cDateTimeFirst на реальный (вместо того который задан в настройках)
Dim SQLString As String
Dim rstTemp02 As DAO.Recordset

    SQLString = "SELECT TOP 1 cdate + "" "" +  ctime as cDateTimeFirst from " & tblDataCurrentBufer & " ORDER BY idn "
    Set rstTemp02 = DB.OpenRecordset(SQLString)
    rstTemp02.MoveLast
    cDateTimeFirst = rstTemp02.Fields("cDateTimeFirst").Value
    rstTemp02.Close

End Sub


Function fnCntDataCurrentBufer() As Integer
' считаем количество строк в таблице с текущими данными
Dim SQLString As String
Dim rstTemp02 As DAO.Recordset

    SQLString = "SELECT count(*) as cntBars from " & tblDataCurrentBufer
    Set rstTemp02 = DB.OpenRecordset(SQLString)
    fnCntDataCurrentBufer = rstTemp02.Fields("cntBars").Value
    rstTemp02.Close

End Function




Sub FillChartCurrent()
' заполняем таблицу с текущим графиком

Dim i As Long
Dim SQLString As String

' перекидываем все текущие данные в таблицу для графика
If DataSourceId = 1 Then
    'MT
    SQLString = "insert into " & tblDataCurrentChart & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose) "
    SQLString = SQLString & "select cdate, ctime, cdate + "" "" + ctime, copen, chigh, clow, cclose from " & tblDataCurrent
End If
If DataSourceId = 2 Then
    'NT
    If (cntSourceFiles = 1) Then ' NT7
        SQLString = "insert into " & tblDataCurrentChart & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1) "
        SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1 from  " & tblDataCurrent
        SQLString = SQLString & " order by cdatetime "
    End If
    
    If (cntSourceFiles > 1) Then ' NT8
        SQLString = "insert into " & tblDataCurrentChart & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, BSV, BSVMini) "
        SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, BSV, BSVMini from  " & tblDataCurrent
        SQLString = SQLString & " order by cdatetime "
    End If
End If
If DataSourceId = 3 Then
    'Quik
    SQLString = "insert into " & tblDataCurrentChart & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, countbuy, countsell, avgBuyOrder, avgSellOrder, ccntOpenPos) "
    SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, countbuy, countsell, avgBuyOrder, avgSellOrder, ccntOpenPos from  " & tblDataCurrent
    SQLString = SQLString & " order by cdatetime "
End If

Call ClearTable(tblDataCurrentChart)
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString


' считаем максимальный idn у нужных нам текущих данных
SQLString = " select max(idn) as idnmax from " & tblDataCurrentChart
SQLString = SQLString & " where cdatetime <= """ & cDateTimeLast & """"

Set rstTemp = DB.OpenRecordset(SQLString)
i = rstTemp.Fields(0)
rstTemp.Close

' оставляем в таблице для графика только нужные записи
SQLString = "delete from " & tblDataCurrentChart & " where ((idn > " & i + pbarsTotal - pbarsBefore & ") or (idn <= " & i - pbarsBefore & "))"
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString





' заполняем таблицу с текущим графиком на MSSQL
'Call ClearTableMSSQL(tblDataCurrentChartMSSQL)
SQLString = "delete from " & tblDataCurrentChartMSSQL & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
DB.Execute SQLString, dbSeeChanges + dbFailOnError
Application.SetOption "Confirm Action Queries", False

If ((DataSourceId = 1) Or (DataSourceId = 2)) Then
    'MT,NT
    If (cntSourceFiles = 1) Then ' NT7
        SQLString = "insert into " & tblDataCurrentChartMSSQL & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, BSV, BSVMini, ParamsIdentifyer) "
        SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, ABMmPosition0, ABMmPosition1, '" & ParamsIdentifyer & "' from  " & tblDataCurrentChart
    End If
    
    If (cntSourceFiles > 1) Then ' NT8
        SQLString = "insert into " & tblDataCurrentChartMSSQL & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, BSV, BSVMini, ABMmPosition0, ABMmPosition1, ParamsIdentifyer) "
        SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, BSV, BSVMini, ABMmPosition0, ABMmPosition1, '" & ParamsIdentifyer & "' from  " & tblDataCurrentChart
    End If
End If
If DataSourceId = 3 Then
    'Quik
    SQLString = "insert into " & tblDataCurrentChartMSSQL & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, countbuy, countsell, avgBuyOrder, avgSellOrder, ccntOpenPos, ParamsIdentifyer) "
    SQLString = SQLString & " select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, countbuy, countsell, avgBuyOrder, avgSellOrder, ccntOpenPos, '" & ParamsIdentifyer & "' from  " & tblDataCurrentChart
End If

DoCmd.RunSQL SQLString

' в таблицу с текущим графиком на MSSQL добавляем общие показатели
SQLString = "exec ntpImportCurrentChartAverageValues '" & cDateTimeFirst & "', '" & cDateTimeFirstCalc & "', '" & cDateTimeLastCalc & "', " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "'" & ", " & cntDaysPreviousShowABV & ", " & cntBarsCalcCorr
'Debug.Print SQLString
Call ExecProcedureMSSQL(SQLString)




' ставим отсечки в начале дня
SQLString = "             update " & tblDataCurrentChart & " t1 "
SQLString = SQLString & " left outer join " & tblDataCurrentChart & " t2 on t2.idn = t1.idn-1 "
SQLString = SQLString & " set t1.chigh = t1.copen*(1+2.0/1000), t1.clow = t1.copen*(1-2.0/1000) "
SQLString = SQLString & " WHERE ((Left(t1.ctime,3)=""00:"")) and  ((Left(t2.ctime,3)<>""00:"")) "
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString



End Sub
Sub WriteLog(textlog As String)

'Set db = Access.CurrentDb

    TotalTime = GetTickCount - StartTime    'вычисляем затраченное время
    'MsgBox "Затрачено времени: " & TotalTime & " мс", , ""
    
' пишем лог
Set rstTemp = DB.OpenRecordset("tlog")
rstTemp.AddNew
rstTemp("ctext") = textlog & " (Затрачено времени: " & TotalTime & " мс)"
rstTemp.Update
rstTemp.Close




    
    
End Sub




Sub DefineParametersFromFileName()
' процедура берет значения параметров из имени файла

Set DB = Access.CurrentDb

Dim SQLString As String
Dim datepart_yyyy, datepart_m, datepart_d, datepart_h, datepart_n As String

CurrDBName = CurrentProject.Name
'MsgBox CurrDBName


MdbFileId = Mid(Mid(CurrDBName, 1, Len(CurrDBName) - 4), Len(CurrDBName) - 4, 1) ' MdbFileId = последний символ в имени mdb-файла
'MsgBox MdbFileId

SQLString = " select * from ntSettingsFilesParameters_cn where dbFileName = '" & CurrDBName & "'"
Set rstTemp5 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
rstTemp5.MoveFirst

    DataSourceId = rstTemp5.Fields("DataSourceId").Value ' 1 - MT, 2 - NT, 3 - Quik
    CurrencyId_current = rstTemp5.Fields("CurrencyId_current").Value ' CurrencyId валюты текущих данных (1 - EURUSD, 2 - AUDUSD, 3 - NZDUSD, 4 - GBPUSD, 5 - USDCAD)
    CurrencyId_history = rstTemp5.Fields("CurrencyId_history").Value ' Currenc yId валюты исторических данных (с которыми сравниваем)
    PeriodMinutes = rstTemp5.Fields("PeriodMinutes").Value ' период данных в минутах
    IsCalcCalendar = rstTemp5.Fields("IsCalcCalendar").Value ' 1 - ищем события в календаре, 0 - обычный расчет К
    ParamsIdentifyer = rstTemp5.Fields("ParamsIdentifyer").Value

    ' задаем диапазон текущих данных
    If IsNull(rstTemp5.Fields("cDateCalc").Value) Then
        cDateCalc = "" ' пусто = сегодня
    Else
        cDateCalc = rstTemp5.Fields("cDateCalc").Value ' пусто = сегодня
    End If
    
    cTimeFirst = rstTemp5.Fields("cTimeFirst").Value ' время начала расчета К
    cTimeLast = rstTemp5.Fields("cTimeLast").Value ' время, на которое считаем К и строим графики
    
    If IsNull(rstTemp5.Fields("cTimeFirstCalc").Value) Then
        cTimeFirstCalc = "" ' пусто = сейчас
    Else
        cTimeFirstCalc = rstTemp5.Fields("cTimeFirstCalc").Value
    End If
    
    'cTimeLastCalc = rstTemp5.Fields("cTimeLastCalc").Value  ' время окончания расчета общих показателей
    cTimeLastCalc = rstTemp5.Fields("cTimeLast").Value  ' время окончания расчета общих показателей

    ' параметры для расчета общих показателей по похожим ситуациям
    cntCharts = rstTemp5.Fields("cntCharts").Value ' количество похожих графиков, которые берем для анализа
    StopLoss = rstTemp5.Fields("StopLoss").Value ' StopLoss в пунктах
    TakeProfit = rstTemp5.Fields("TakeProfit").Value ' TakeProfit в пунктах
    OnePoint = rstTemp5.Fields("OnePoint").Value ' значение одного пункта в цене
    
    ' задаем лимиты для алертов
    TakeProfit_isOk_AtOnce_AvgCnt_delta_alert = rstTemp5.Fields("TakeProfit_isOk_AtOnce_AvgCnt_delta_alert").Value ' минимальная разница между TakeProfit_isOk_AtOnce_up_AvgCnt и TakeProfit_isOk_AtOnce_down_AvgCnt, при которой возникает алерт (процент ситуаций)
    TakeProfit_isOk_AtOnce_AvgCnt_limit_alert = rstTemp5.Fields("TakeProfit_isOk_AtOnce_AvgCnt_limit_alert").Value ' минимальное значение TakeProfit_isOk_AtOnce_up_AvgCnt или TakeProfit_isOk_AtOnce_down_AvgCnt, при котором возникает алерт (процент ситуаций)
    CPoints_AtOnce_Avg_delta_alert = rstTemp5.Fields("CPoints_AtOnce_Avg_delta_alert").Value ' минимальная разница между ChighMax_AtOnce_Avg и ClowMin_AtOnce_Avg, при которой возникает алерт (кол-во пунктов)
    CPoints_AtOnce_Avg_limit_alert = rstTemp5.Fields("CPoints_AtOnce_Avg_limit_alert").Value ' минимальное значение ChighMax_AtOnce_Avg или ClowMin_AtOnce_Avg, при котором возникает алерт (кол-во пунктов)
    
    cntDaysPreviousShowABV = rstTemp5.Fields("cntDaysPreviousShowABV").Value ' количество предыдущих дней, за которое показывать ABV на графике (1 - показывать только за текущий день)
    
    isLogTables = rstTemp5.Fields("isLogTables").Value  ' 1 - логировать таблицы, 2 - логировать только ntImport_log, 0 - не логировать таблицы

    IsExportToExcelCurrent = rstTemp5.Fields("IsExportToExcelCurrent").Value ' 1 - экспортировать текущие данные в Excel, 0 - не экспортировать
    IsOpenExcelCurrent = rstTemp5.Fields("IsOpenExcelCurrent").Value ' 1 - открыть Excel для вывода текущих графиков, 0 - не открывать (если изменилось количество графиков)
    IsExportToExcelHistory = rstTemp5.Fields("IsExportToExcelHistory").Value ' 1 - экспортировать исторические данные в Excel, 0 - не экспортировать
    IsOpenExcelHistory = rstTemp5.Fields("IsOpenExcelHistory").Value ' 1 - открыть Excel для вывода исторических графиков, 0 - не открывать (если изменилось количество графиков)
    
    strCalendarNewsName = rstTemp5.Fields("strCalendarNewsName").Value ' текст показателя в календаре
    strCalendarCountryName = rstTemp5.Fields("strCalendarCountryName").Value ' страна, по которой выходит показатель в календаре United States  Eur* Canada Japan
    PeriodMultiplicatorForCalendar = rstTemp5.Fields("PeriodMultiplicatorForCalendar").Value ' множитель периода, который берем для поиска событий в календаре
    isCalcAverageValuesInPercents = rstTemp5.Fields("isCalcAverageValuesInPercents").Value ' 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
    
    
    pCountCharts = rstTemp5.Fields("pCountCharts").Value ' количество графиков с историей
    pbarsBefore = rstTemp5.Fields("pbarsBefore").Value '+ 700 ' количество баров на графике с историей до момента К 8200
    pbarsTotal = rstTemp5.Fields("pbarsTotal").Value '+ 1200 ' количество баров на графике с историей всего 9000
    cntRowsCorr = rstTemp5.Fields("cntRowsCorr").Value ' количество первых строк с максимальным значением К, которые берем для дальнейшего анализа
    
    IsInverse = rstTemp5.Fields("IsInverse").Value ' 0 - график цены прямой (EURUSD), 1 - обратный (USDCAD)
    SortBack = rstTemp5.Fields("SortBack").Value ' 0 - сортировка К в прямом порядке, 1 - в обратном
    
    pExcelWindowState = rstTemp5.Fields("pExcelWindowState").Value ' 1 = разворачивать окно Excel, 2 = сворачивать окно, 3 = ничего не делать, 4 = сворачивать, но при наступлении алерта разворачивать

    isSendEmailOnAlert = rstTemp5.Fields("isSendEmailOnAlert").Value ' 1 - посылать email при алерте
    isSendSmsOnAlert = rstTemp5.Fields("isSendSmsOnAlert").Value ' 1 - посылать sms при алерте
    isCountAverageValuesWithNextDay = rstTemp5.Fields("isCountAverageValuesWithNextDay").Value ' 1 - рассчитывать общие показатели (срабатывание стопов, верхи/низы) с учетом следующего дня, 0 - рассчитывать общие показатели только в пределах текущего дня

    SourceFilePath = rstTemp5.Fields("SourceFilePath").Value
    
    ctime_CalcAverageValuesWithNextDay = rstTemp5.Fields("ctime_CalcAverageValuesWithNextDay").Value ' время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
    CntBarsMinLimit = rstTemp5.Fields("CntBarsMinLimit").Value ' минимальное количество баров, которое может быть в торговом дне (нужно для вычисления СЛЕДУЮЩЕГО торгового дня)
    
    
    If ((IsNull(rstTemp5.Fields("cntBarsCalcCorr").Value)) Or (rstTemp5.Fields("cntBarsCalcCorr").Value = "")) Then
        cntBarsCalcCorr = 0
    Else
        cntBarsCalcCorr = rstTemp5.Fields("cntBarsCalcCorr").Value ' количество баров, по которым считать К (0 - задается начальная дата-время)
    End If
    
    
    
    
    
    
    DeltaCcloseRangeMaxLimit = rstTemp5.Fields("DeltaCcloseRangeMaxLimit").Value ' максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
    DeltaCcloseRangeMinLimit = rstTemp5.Fields("DeltaCcloseRangeMinLimit").Value ' минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
    IsCalcCorrOnlyForSameTime = rstTemp5.Fields("IsCalcCorrOnlyForSameTime").Value ' 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
    DeltaMinutesCalcCorr = rstTemp5.Fields("DeltaMinutesCalcCorr").Value ' количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
    CalcCorrParamsId = rstTemp5.Fields("CalcCorrParamsId").Value ' идентификатор параметров расчета К
    
    
    If IsNull(rstTemp5.Fields("cntCharts_last").Value) Then
        isCalcCorr1 = 0 ' 1 = считать К, 0 = не считать К (д.б. уже посчитана по другому ParamsIdentifyer)
    Else
        isCalcCorr1 = 1
    End If
    
    
    
    
    
    'tblDataCurrent = rstTemp5.Fields("tblDataCurrent").Value

    If DataSourceId = 3 Then 'Quik
        tblDataCurrentDDE = "QuikDDE_" & CurrencyId_current & "_" & PeriodMinutes
        tblDataCurrentDDEBufer = "QuikDDEBufer"
    End If


    IsExportToTxtCurrent = IsExportToExcelCurrent
    IsExportToTxtHistory = IsExportToExcelHistory
    
    is_makeDeals_RealTrade = rstTemp5.Fields("is_makeDeals_RealTrade").Value ' 1 - совершать сделки
    
    cntSourceFiles = rstTemp5.Fields("cntSourceFiles").Value ' количество исходных текстовых файлов
    

rstTemp5.Close





' считаем сумму весов К
SQLString = " select sum(WeightCORR) as WeightCORR_cn_sum from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '" & ParamsIdentifyer & "' "
Set rstTemp5 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
rstTemp5.MoveFirst
WeightCORR_cn_sum = rstTemp5.Fields("WeightCORR_cn_sum").Value
rstTemp5.Close







If cDateCalc = "" Then
    datepart_yyyy = DatePart("yyyy", Now)
    datepart_m = DatePart("m", Now)
    datepart_d = DatePart("d", Now)
    
    If Len(datepart_m) = 1 Then
        datepart_m = "0" & datepart_m
    End If
    
    If Len(datepart_d) = 1 Then
        datepart_d = "0" & datepart_d
    End If
    
    cDateCalc = datepart_yyyy & "." & datepart_m & "." & datepart_d ' дата, за которую считаем К (по умолчанию сегодня)
End If


cDateTimeFirst = cDateCalc & " " & cTimeFirst  ' время начала расчета К
cDateTimeLast = cDateCalc & " " & cTimeLast  ' время, на которое считаем К и строим графики
'---------------------------
If cTimeFirstCalc = "" Then
    If cDateCalc = datepart_yyyy & "." & datepart_m & "." & datepart_d Then
        ' если считаем за сегодня, то отнимаем PeriodMinutes от текущего времени
        datepart_h = DatePart("h", DateAdd("n", -PeriodMinutes, Now))
        datepart_n = DatePart("n", DateAdd("n", -PeriodMinutes, Now))
        
        If Len(datepart_h) = 1 Then
            datepart_h = "0" & datepart_h
        End If
        
        If Len(datepart_n) = 1 Then
            datepart_n = "0" & datepart_n
        End If
        
        cDateTimeFirstCalc = cDateCalc & " " & datepart_h & ":" & datepart_n  ' время начала расчета общих показателей
    Else
        ' если считаем не за сегодня, то ставим cTimeLastCalc
        cDateTimeFirstCalc = cDateCalc & " " & cTimeLastCalc
    End If
Else
    cDateTimeFirstCalc = cDateCalc & " " & cTimeFirstCalc ' время начала расчета общих показателей
End If
'---------------------------
cDateTimeLastCalc = cDateCalc & " " & cTimeLastCalc  ' время окончания расчета общих показателей





' название валюты в NT
If DataSourceId = 2 Then 'NT (5-минутки склеены из 1-минуток)
    SQLString = " select NTName from ntCurrency where idn = " & CurrencyId_current
    Set rstTemp5 = DB.OpenRecordset(SQLString)
    rstTemp5.MoveLast
    CurrencyNTName_current = rstTemp5.Fields("NTName").Value ' 6E
    rstTemp5.Close
    tblDataCurrent = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId
End If

If DataSourceId = 3 Then 'Quik
    tblDataCurrent = "QuikImport"
End If



    'SourceFileNameCurrentRealTime = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_RealTime.txt"
    'SourceFileNameCurrent = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId & ".txt"
    
    arrDataHistory_cn_filled = 0
    tblDataHistory_cn_previous = ""



End Sub





Sub CopySourceFile()
' делаем копию исходного файла с текущими данными, чтобы избежать блокировки файла в NT
Dim i As Long
Dim SourceTableNameTxt As String
Dim SourceTableNameAccess As String
Dim SQLString As String

    If DataSourceId = 2 Then 'NT
        
        
        If cntSourceFiles = 1 Then ' NT7
            SourceFileNameCurrentRealTime = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_RealTime.txt"
            SourceFileNameCurrent = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId & ".txt"
            
            If Dir(SourceFileNameCurrent, 16) <> "" Then ' файл SourceFileNameCurrent уже существует
                If FileSystem.FileDateTime(SourceFileNameCurrentRealTime) <> FileSystem.FileDateTime(SourceFileNameCurrent) Then ' файл SourceFileNameCurrent устарел
                    Call WriteLog("удаляем копию исходного файла")
                    Kill SourceFileNameCurrent ' удаляем копию исходного файла
                    Call WriteLog("копируем исходный файл")
                    FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent 'копируем исходный файл
                    Call WriteLog("копирование исходного файла завершено")
                End If
            Else ' файл SourceFileNameCurrent не существует
                Call WriteLog("копируем исходный файл")
                FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent 'копируем исходный файл
                Call WriteLog("копирование исходного файла завершено")
            End If
        End If
        
        If cntSourceFiles > 1 Then ' NT8
        
            For i = 1 To cntSourceFiles
        
                SourceFileNameCurrentRealTime = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_RealTime_" & i & ".txt"
                SourceFileNameCurrent = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_" & i & "_id" & MdbFileId & ".txt"
        
                If Dir(SourceFileNameCurrent, 16) <> "" Then ' файл SourceFileNameCurrent уже существует
                    If FileSystem.FileDateTime(SourceFileNameCurrentRealTime) <> FileSystem.FileDateTime(SourceFileNameCurrent) Then ' файл SourceFileNameCurrent устарел
                        Call WriteLog("удаляем копию исходного файла")
                        Kill SourceFileNameCurrent ' удаляем копию исходного файла
                        Call WriteLog("копируем исходный файл")
                        FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent 'копируем исходный файл
                        Call WriteLog("копирование исходного файла завершено")
                    End If
                Else ' файл SourceFileNameCurrent не существует
                    Call WriteLog("копируем исходный файл")
                    FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent 'копируем исходный файл
                    Call WriteLog("копирование исходного файла завершено")
                End If
            
            Next i
            
            
    
            ' перекидываем данные из текстовых файлов в таблицу Access
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_1_id" & MdbFileId
            SourceTableNameAccess = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId
            
            SQLString = "insert into " & SourceTableNameAccess & "(cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime) "
            SQLString = SQLString & "select cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime from " & SourceTableNameTxt
            SQLString = SQLString & " order by cdatetime "
        
            Call ClearTable(SourceTableNameAccess)
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
            
            ' добавляем ABVMini
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_2_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.ABVMini = t2.ABVMini "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
    
            ' добавляем BSV
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_3_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.BSV = t2.BSV "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
            
            ' добавляем BSVMini
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_4_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.BSVMini = t2.BSVMini "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
        
        End If
        

        
        
    End If





End Sub

Sub CopySourceFile_cn()
' делаем копию исходного файла с текущими данными, чтобы избежать блокировки файла в NT
Dim i As Long
Dim SourceTableNameTxt As String
Dim SourceTableNameAccess As String
Dim SQLString As String

    If DataSourceId = 2 Then 'NT
    
    
        If cntSourceFiles = 1 Then ' NT7
            SourceFileNameCurrentRealTime_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_RealTime.txt"
            SourceFileNameCurrent_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId & ".txt"
            
            If Dir(SourceFileNameCurrent, 16) <> "" Then ' файл SourceFileNameCurrent уже существует
                If FileSystem.FileDateTime(SourceFileNameCurrentRealTime_cn) <> FileSystem.FileDateTime(SourceFileNameCurrent_cn) Then ' файл SourceFileNameCurrent устарел
                    Call WriteLog("удаляем копию исходного файла")
                    Kill SourceFileNameCurrent_cn ' удаляем копию исходного файла
                    Call WriteLog("копируем исходный файл")
                    FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn 'копируем исходный файл
                    Call WriteLog("копирование исходного файла завершено")
                End If
            Else ' файл SourceFileNameCurrent не существует
                Call WriteLog("копируем исходный файл")
                FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn 'копируем исходный файл
                Call WriteLog("копирование исходного файла завершено")
            End If
        End If
    
    
    
        If cntSourceFiles > 1 Then ' NT8
        
            For i = 1 To cntSourceFiles
        
                SourceFileNameCurrentRealTime_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_RealTime_" & i & ".txt"
                SourceFileNameCurrent_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_" & i & "_id" & MdbFileId & ".txt"
        
                If Dir(SourceFileNameCurrent_cn, 16) <> "" Then ' файл SourceFileNameCurrent_cn уже существует
                    If FileSystem.FileDateTime(SourceFileNameCurrentRealTime_cn) <> FileSystem.FileDateTime(SourceFileNameCurrent_cn) Then ' файл SourceFileNameCurrent_cn устарел
                        Call WriteLog("удаляем копию исходного файла _cn")
                        Kill SourceFileNameCurrent_cn ' удаляем копию исходного файла _cn
                        Call WriteLog("копируем исходный файл _cn")
                        FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn 'копируем исходный файл
                        Call WriteLog("копирование исходного файла _cn завершено")
                    End If
                Else ' файл SourceFileNameCurrent_cn не существует
                    Call WriteLog("копируем исходный файл _cn")
                    FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn 'копируем исходный файл
                    Call WriteLog("копирование исходного файла _cn завершено")
                End If
            
            Next i
            
    
            ' перекидываем данные из текстовых файлов в таблицу Access
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_1_id" & MdbFileId
            SourceTableNameAccess = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId
            
            SQLString = "insert into " & SourceTableNameAccess & "(cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime) "
            SQLString = SQLString & "select cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime from " & SourceTableNameTxt
            SQLString = SQLString & " order by cdatetime "
        
            Call ClearTable(SourceTableNameAccess)
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
            
            ' добавляем ABVMini
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_2_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.ABVMini = t2.ABVMini "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
    
            ' добавляем BSV
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_3_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.BSV = t2.BSV "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
            
            ' добавляем BSVMini
            If IsTable("tblTemp") Then
                SQLString = " drop table tblTemp "
                Application.SetOption "Confirm Action Queries", False
                DoCmd.RunSQL SQLString
            End If
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_4_id" & MdbFileId
            SQLString = " SELECT * INTO tblTemp FROM " & SourceTableNameTxt
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
    
            SQLString = "             update " & SourceTableNameAccess & " as t "
            SQLString = SQLString & " left outer join tblTemp AS t2 on t2.cdateold=t.cdate and t2.ctimeold=t.ctime "
            SQLString = SQLString & " set t.BSVMini = t2.BSVMini "
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
        End If
    
    
        
    End If
        
End Sub


