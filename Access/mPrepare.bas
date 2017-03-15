Attribute VB_Name = "mPrepare"
'Option Compare Database
Option Explicit


Sub FillArrDataHistory_new(tblDataHistoryName As String)
' ���������� ArrDataHistory (������ ������ 1 ���)

Dim SQLString As String

    cntDataHistoryRows = DCount("*", tblDataHistoryName)

    SQLString = " select * from " & tblDataHistory & " order by idn"

    Set rstTemp = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    Erase arrDataHistory
    arrDataHistory = rstTemp.GetRows(cntDataHistoryRows)
    rstTemp.Close
    
    
End Sub


Sub FillArrCorrTotal(tblDataHistoryName As String)
' ����������� ������� � ����� �

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
' ����� ������� ��� n-�� �������

Dim i As Long
Dim SQLString As String
'Dim arrCcloseMin, arrCcloseMin As Double



    ' ���� ����� ������ ��������������� �� ������� (��� �������), �� ��������� ������:
    ' ������ ������ � ������� ������-�� ���������� (�������� �� ������ ������)
    ' ������� ����� ��������� ������ �� ������ ���������������� ������
    

    ' ����� ������� ��� n-�� ������� (���� ��� �� �����)
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
        
        
        ' ���� ������� � �� ABV/ABVMini, �� �������� �������� �������
        
        
        
    
        ' ���� ��������� ������, �� �������� �������������� �, �� ��������� � �������� �������, �� ��������� ������ arrCdateTime (����������� ��� �������� �)
        If cntDataHistoryRows <> cntDataHistoryRows_cn Then
            Erase arrCdateTime
            Erase arrCdateTime_cn
            
            ReDim arrCdateTime(0 To (cntDataHistoryRows - 1))
            ReDim arrCdateTime_cn(0 To (cntDataHistoryRows_cn - 1))
            
            For i = 1 To cntDataHistoryRows
                ' �������� CdateTime �� ������������ ������ (��� �������)
                arrCdateTime(i - 1) = arrDataHistory(5, i - 1) & " " & Replace(Space(2 - Len(arrDataHistory(4, i - 1) \ 60)), " ", "0") & (arrDataHistory(4, i - 1) \ 60) & ":" & Replace(Space(2 - Len(arrDataHistory(4, i - 1) Mod 60)), " ", "0") & (arrDataHistory(4, i - 1) Mod 60)
            Next i
            
            For i = 1 To cntDataHistoryRows_cn
                ' �������� CdateTime �� ������������ ������ (��� n-�� ������� �)
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
        Call CalcMAasVariant(arrCclose(), MAPeriod_cn) ' ��������� ��
    End If
        

    
    arrDataHistory_cn_filled = 1 ' 1 - ������������ ������� ��� ������� _cn ���������
    tblDataHistory_cn_previous = tblDataHistory_cn ' ���������� �������� ������������ �������
    
    
    
End Sub




Sub FillArrDataCurrent_cn()
' ����� ������� ������ ��� n-�� �������

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
'        ' ��� ������� � �� ABV/ABVMini �������� ������ ������� (�����  ����� ����������/������������)
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
            'CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(12, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(12, i - 1), 4, 2)) ' ����� �������� ���� (� ������� � ������ ���)
            If DataSourceId = 2 Then
                CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(12, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(12, i - 1), 4, 2)) ' ����� �������� ���� (� ������� � ������ ���)
            End If
            If DataSourceId = 3 Then
                CurrentBarTimeInMinutes = (Left(arrDataCurrent_cn(2, i - 1), 2) * 60 + Mid(arrDataCurrent_cn(2, i - 1), 4, 2)) ' ����� �������� ���� (� ������� � ������ ���)
            End If
        End If
    Next i
    
    Call MakeArrayPlusAsDouble(arrCclose_cn)

    If MAPeriod_cn > 1 Then
        Call CalcMAasDouble(arrCclose_cn(), MAPeriod_cn) ' ��������� ��
    End If
    
    'Call ClearTable("t1")
    'Call WriteArrToTable(arrCclose_cn, "t1", "c1")
    
    
    
End Sub



Sub FillArrDataHistory_old(tblDataHistoryName As String, idValue As Integer)
' �������������� ���������� �������� � ������������� �������
'idValue - ����� �������� �� tblDataHistoryName ������� � ������:
'1 - cclose
'2 - ABV
'3 - ABVMini


Dim i As Long

' tblDataHistoryName = "ntPeriodsDataCCLOSE_1_2_5_1_1"

    'StartTime = GetTickCount    '���������� ��������� �����

'Set DB = Access.CurrentDb

Call WriteLog("--------------------------")
Call WriteLog("������ ���������� �������� (idValue = " & idValue & ")")


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



      
      



' ����� �������
Set rstTemp = DB.OpenRecordset(tblDataHistoryName)
' !!! ������: ������ ������ � ������� ������-�� ���������� (�������� �� ������ ������)
'     ����� ��������� ������ �� ������ ���������������� ������
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
    Call CalcMAasVariant(arrCclose(), MACclosePeriod) ' ��������� ��(Cclose)
End If


If WeightCORRABV <> 0 Or WeightCORREasyABV <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrABV(i - 1) = arrDataHistory(2, i - 1)
      arrABVIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MAABVPeriod > 1 Then
        Call CalcMAasVariant(arrABV(), MAABVPeriod) ' ��������� ��(ABV)
    End If
End If

If WeightCORRABVMini <> 0 Or WeightCORREasyABVMini <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrABVMini(i - 1) = arrDataHistory(3, i - 1)
      arrABVMiniIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i

    If MAABVMiniPeriod > 1 Then
        Call CalcMAasVariant(arrABVMini(), MAABVMiniPeriod) ' ��������� ��(ABVMini)
    End If
End If

' ��������� ��(Volume) � ���������� � ������
If WeightCORRMAVolume <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrMAVolume(i - 1) = arrDataHistory(6, i - 1)
      arrMAVolumeIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MAVolumePeriod > 1 Then
        Call CalcMAasVariant(arrMAVolume(), MAVolumePeriod) ' ��������� ��(Volume)
    End If
End If


If IsCalcCorrOnlyForSameTime = 1 Or WeightCORRPreviousDay <> 0 Then
    For i = 1 To cntDataHistoryRows
      arrCcloseTimeInMinutes(i - 1) = arrDataHistory(4, i - 1)
    Next i
End If


' ��������� ������ cclose �� ���������� ���� (��� ������� � �� ���������� ����)
If WeightCORRPreviousDay <> 0 Then
    For i = 1 To cntDataHistoryRows
        arrPreviousDay(i - 1) = arrDataHistory(1, i - 1) '.Value
        arrPreviousDayIDN(i - 1) = arrDataHistory(0, i - 1)
        
        arrCdate(i - 1) = arrDataHistory(5, i - 1) '.Value
        arrCdateIDN(i - 1) = arrDataHistory(0, i - 1)
    Next i
    
    If MACclosePreviousDayPeriod > 1 Then
        Call CalcMAasVariant(arrPreviousDay(), MACclosePreviousDayPeriod) ' ��������� ��(Cclose �� ���������� ����)
    End If
    
End If





    'TotalTime = GetTickCount - StartTime    '��������� ����������� �����
    'MsgBox "��������� �������: " & TotalTime & " ��", , ""

' ������� arrDataHistory, arrCCLOSE, arrIDN ���������
'MsgBox LBound(arrCCLOSE)

Call WriteLog("����� ���������� �������� (idValue = " & idValue & ")")

End Sub


Public Sub CalcMAasVariant(ArrayValues() As Variant, MAPeriod As Integer)
' ��������� ��������� MA � �������� MAPeriod �� ������� ArrayValues � ���������� �������� MA �� ����� ��������� �������
' !!! ������� ��������� � ���������� CalcMAasDouble !!!

' ArrayValues() - ���������� ������ � �������, �� ������� ����� ��������� ��
'                 ��������� ��������� ������ ���������� � 0
' MAPeriod - ������ ��
    
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

    ' ��������� ������ �������� MA
    MAValue = 0
    For i = 1 To MAPeriod
      MAValue = MAValue + ArrayValues(i - 1)
      ArrayMAValues(i - 1) = MAValue * (MAPeriod / i) ' �������� �� ��� ��� �������������
    Next i

    ' ��������� ���� ��������� ������ ArrayMAValues
    For i = (MAPeriod + 1) To (ub + 1)
      ValueFirst = ArrayValues(i - MAPeriod - 1) ' �������, ������� ����� ������� �� MAValue
      ValueNext = ArrayValues(i - 1) ' �������, ������� ����� �������� � MAValue
      MAValue = MAValue - ValueFirst + ValueNext
      ArrayMAValues(i - 1) = MAValue
    Next i

    ' ������������ ������ ArrayMAValues � �������� ������ ArrayValues
    For i = lb To ub
      ArrayValues(i) = ArrayMAValues(i)
    Next i
    
    Erase ArrayMAValues

End Sub

Public Sub CalcMAasDouble(ArrayValues() As Double, MAPeriod As Integer)
' ��������� ��������� MA � �������� MAPeriod �� ������� ArrayValues � ���������� �������� MA �� ����� ��������� �������
' !!! ������� ��������� � ���������� CalcMAasVariant !!!

' ArrayValues() - ���������� ������ � �������, �� ������� ����� ��������� ��
'                 ��������� ��������� ������ ���������� � 0
' MAPeriod - ������ ��
    
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

    ' ��������� ������ �������� MA
    MAValue = 0
    For i = 1 To MAPeriod
      MAValue = MAValue + ArrayValues(i - 1)
      ArrayMAValues(i - 1) = MAValue * (MAPeriod / i) ' �������� �� ��� ��� �������������
    Next i

    ' ��������� ���� ��������� ������ ArrayMAValues
    For i = (MAPeriod + 1) To (ub + 1)
      ValueFirst = ArrayValues(i - MAPeriod - 1) ' �������, ������� ����� ������� �� MAValue
      ValueNext = ArrayValues(i - 1) ' �������, ������� ����� �������� � MAValue
      MAValue = MAValue - ValueFirst + ValueNext
      ArrayMAValues(i - 1) = MAValue
    Next i

    ' ������������ ������ ArrayMAValues � �������� ������ ArrayValues
    For i = lb To ub
      ArrayValues(i) = ArrayMAValues(i)
    Next i
    
    Erase ArrayMAValues

End Sub


Sub FillTablesDataCurrent(FillTblDataCurrentMSSQL As Integer, pCntBarsCalcCorr As Integer)
' ���������� ������ � �������� �������
' ��������� ����� ���:
' 1) ��������� �������������� �����������
' 2) ���������� � �� �������������� �����������


' FillTblDataCurrentMSSQL: 1 - ��������� tblDataCurrentMSSQL, 0 - �� ���������


Dim i As Long
Dim SQLString As String
Dim ABV_total As Single
Dim SourceTableName As String

    'StartTime = GetTickCount    '���������� ��������� �����

Call WriteLog("-----������ ���������� ������ � �������� �������")



' ������������ ������ ������ ������� ������ � �������� �������
If DataSourceId = 1 Then
    'MT
    SQLString = "insert into " & tblDataCurrentBufer & "(cdate, ctime, cdatetime, copen, chigh, clow, cclose) "
    SQLString = SQLString & "select cdate, ctime, cdate + "" "" + ctime, copen, chigh, clow, cclose from " & tblDataCurrent
    SQLString = SQLString & " where (cdate+"" "" +ctime) >= """ & cDateTimeFirst & """"
    SQLString = SQLString & "   and (cdate+"" "" +ctime) <= """ & cDateTimeLast & """"
End If



If DataSourceId = 3 Then
    'Quik
    ' ������������ ������� ������ � �������� ������� (����� ������ ���������� ������)
    SQLString = "insert into " & tblDataCurrentDDEBufer & "(cdatetime, cdate, ctime, copen, chigh, clow, cclose, cvolume, sumspros, sumpredl, countbuy, countsell, cntOpenPos) "
    SQLString = SQLString & "select cdatetime, date, time, open, high, low, close, volume, sumspros, sumpredl, countbuy, countsell, cntOpenPos from " & tblDataCurrentDDE

    Call ClearTable(tblDataCurrentDDEBufer)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("������� " & tblDataCurrentDDEBufer & " ���������")


    '��������� ABV � ������ ����������
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
    
    Call WriteLog("������� " & tblDataCurrent & " ���������")



    ' ������� ��������� ������ (�.�. � QUIK ��� - ������� ���)
    Set rstTemp3 = DB.OpenRecordset(tblDataCurrent)
    rstTemp3.MoveLast
    rstTemp3.Delete
    rstTemp3.Close
    Call WriteLog("��������� ������ � ������� " & tblDataCurrent & " �������")


    '��������� ABV
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
    
    
    Call WriteLog("ABV � ������� " & tblDataCurrent & " ��������")
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
    
    Call WriteLog("������ ���������� " & tblDataCurrentBufer)
    
    Call ClearTable(tblDataCurrentBufer)
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteLog("����� ���������� " & tblDataCurrentBufer)
    
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
    
    Call WriteLog("������� ntImport_log ���������; cDateTimeLast = " & cDateTimeLast)

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
    
    Call WriteLog("������� " & tblDataCurrentBufer & "_log" & " ���������; cDateTimeLast = " & cDateTimeLast)

End If
    
' ��������� ����� ������� ��� ��������
'If isLogTables = 1 Then
    
'End If

' ��������� � �������� ������� ������ ������ ������
'SQLString = "delete from " & tblDataCurrentBufer
'SQLString = SQLString & " where (cdate+"" "" +ctime) < """ & cDateTimeFirst & """"
'SQLString = SQLString & "    or (cdate+"" "" +ctime) > """ & cDateTimeLast & """"
'Application.SetOption "Confirm Action Queries", False
'DoCmd.RunSQL SQLString

cntDataCurrentRows = DCount("*", tblDataCurrentBufer)


If FillTblDataCurrentMSSQL = 1 Then
    ' ������������ ������� ������ �� SQL Server
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
        ' ��������� ��� �� ������ ���������� �� MSSQL
    
        SQLString = " select count(*) as cntrecords from " & tblDataCurrentBufer
        Set rstTemp3 = DB.OpenRecordset(SQLString)
        i = rstTemp3.Fields(0)
        rstTemp3.Close
        Call WriteLog("(7) ���������� ������� � tblDataCurrentBufer = " & i)
        
        SQLString = " select count(*) as cntrecords from " & tblDataCurrentMSSQL & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
        Set rstTemp3 = DB.OpenRecordset(SQLString)
        i = rstTemp3.Fields(0)
        rstTemp3.Close
        Call WriteLog("(8) ���������� ������� � tblDataCurrentMSSQL = " & i)
    End If
    '-----------------------------
    
    
End If


Call WriteLog("-----����� ���������� ������ � �������� �������")



End Sub

Public Function IsTable(NameTable As String) As Boolean
   Dim i As Integer
   IsTable = False
   For i = 0 To CurrentDb.TableDefs.Count - 1
      If CurrentDb.TableDefs(i).Name = NameTable Then IsTable = True
   Next i
End Function

Sub ChangeCDateTimeFirstToReal()
' ������ cDateTimeFirst �� �������� (������ ���� ������� ����� � ����������)
Dim SQLString As String
Dim rstTemp02 As DAO.Recordset

    SQLString = "SELECT TOP 1 cdate + "" "" +  ctime as cDateTimeFirst from " & tblDataCurrentBufer & " ORDER BY idn "
    Set rstTemp02 = DB.OpenRecordset(SQLString)
    rstTemp02.MoveLast
    cDateTimeFirst = rstTemp02.Fields("cDateTimeFirst").Value
    rstTemp02.Close

End Sub


Function fnCntDataCurrentBufer() As Integer
' ������� ���������� ����� � ������� � �������� �������
Dim SQLString As String
Dim rstTemp02 As DAO.Recordset

    SQLString = "SELECT count(*) as cntBars from " & tblDataCurrentBufer
    Set rstTemp02 = DB.OpenRecordset(SQLString)
    fnCntDataCurrentBufer = rstTemp02.Fields("cntBars").Value
    rstTemp02.Close

End Function




Sub FillChartCurrent()
' ��������� ������� � ������� ��������

Dim i As Long
Dim SQLString As String

' ������������ ��� ������� ������ � ������� ��� �������
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


' ������� ������������ idn � ������ ��� ������� ������
SQLString = " select max(idn) as idnmax from " & tblDataCurrentChart
SQLString = SQLString & " where cdatetime <= """ & cDateTimeLast & """"

Set rstTemp = DB.OpenRecordset(SQLString)
i = rstTemp.Fields(0)
rstTemp.Close

' ��������� � ������� ��� ������� ������ ������ ������
SQLString = "delete from " & tblDataCurrentChart & " where ((idn > " & i + pbarsTotal - pbarsBefore & ") or (idn <= " & i - pbarsBefore & "))"
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString





' ��������� ������� � ������� �������� �� MSSQL
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

' � ������� � ������� �������� �� MSSQL ��������� ����� ����������
SQLString = "exec ntpImportCurrentChartAverageValues '" & cDateTimeFirst & "', '" & cDateTimeFirstCalc & "', '" & cDateTimeLastCalc & "', " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "'" & ", " & cntDaysPreviousShowABV & ", " & cntBarsCalcCorr
'Debug.Print SQLString
Call ExecProcedureMSSQL(SQLString)




' ������ ������� � ������ ���
SQLString = "             update " & tblDataCurrentChart & " t1 "
SQLString = SQLString & " left outer join " & tblDataCurrentChart & " t2 on t2.idn = t1.idn-1 "
SQLString = SQLString & " set t1.chigh = t1.copen*(1+2.0/1000), t1.clow = t1.copen*(1-2.0/1000) "
SQLString = SQLString & " WHERE ((Left(t1.ctime,3)=""00:"")) and  ((Left(t2.ctime,3)<>""00:"")) "
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString



End Sub
Sub WriteLog(textlog As String)

'Set db = Access.CurrentDb

    TotalTime = GetTickCount - StartTime    '��������� ����������� �����
    'MsgBox "��������� �������: " & TotalTime & " ��", , ""
    
' ����� ���
Set rstTemp = DB.OpenRecordset("tlog")
rstTemp.AddNew
rstTemp("ctext") = textlog & " (��������� �������: " & TotalTime & " ��)"
rstTemp.Update
rstTemp.Close




    
    
End Sub




Sub DefineParametersFromFileName()
' ��������� ����� �������� ���������� �� ����� �����

Set DB = Access.CurrentDb

Dim SQLString As String
Dim datepart_yyyy, datepart_m, datepart_d, datepart_h, datepart_n As String

CurrDBName = CurrentProject.Name
'MsgBox CurrDBName


MdbFileId = Mid(Mid(CurrDBName, 1, Len(CurrDBName) - 4), Len(CurrDBName) - 4, 1) ' MdbFileId = ��������� ������ � ����� mdb-�����
'MsgBox MdbFileId

SQLString = " select * from ntSettingsFilesParameters_cn where dbFileName = '" & CurrDBName & "'"
Set rstTemp5 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
rstTemp5.MoveFirst

    DataSourceId = rstTemp5.Fields("DataSourceId").Value ' 1 - MT, 2 - NT, 3 - Quik
    CurrencyId_current = rstTemp5.Fields("CurrencyId_current").Value ' CurrencyId ������ ������� ������ (1 - EURUSD, 2 - AUDUSD, 3 - NZDUSD, 4 - GBPUSD, 5 - USDCAD)
    CurrencyId_history = rstTemp5.Fields("CurrencyId_history").Value ' Currenc yId ������ ������������ ������ (� �������� ����������)
    PeriodMinutes = rstTemp5.Fields("PeriodMinutes").Value ' ������ ������ � �������
    IsCalcCalendar = rstTemp5.Fields("IsCalcCalendar").Value ' 1 - ���� ������� � ���������, 0 - ������� ������ �
    ParamsIdentifyer = rstTemp5.Fields("ParamsIdentifyer").Value

    ' ������ �������� ������� ������
    If IsNull(rstTemp5.Fields("cDateCalc").Value) Then
        cDateCalc = "" ' ����� = �������
    Else
        cDateCalc = rstTemp5.Fields("cDateCalc").Value ' ����� = �������
    End If
    
    cTimeFirst = rstTemp5.Fields("cTimeFirst").Value ' ����� ������ ������� �
    cTimeLast = rstTemp5.Fields("cTimeLast").Value ' �����, �� ������� ������� � � ������ �������
    
    If IsNull(rstTemp5.Fields("cTimeFirstCalc").Value) Then
        cTimeFirstCalc = "" ' ����� = ������
    Else
        cTimeFirstCalc = rstTemp5.Fields("cTimeFirstCalc").Value
    End If
    
    'cTimeLastCalc = rstTemp5.Fields("cTimeLastCalc").Value  ' ����� ��������� ������� ����� �����������
    cTimeLastCalc = rstTemp5.Fields("cTimeLast").Value  ' ����� ��������� ������� ����� �����������

    ' ��������� ��� ������� ����� ����������� �� ������� ���������
    cntCharts = rstTemp5.Fields("cntCharts").Value ' ���������� ������� ��������, ������� ����� ��� �������
    StopLoss = rstTemp5.Fields("StopLoss").Value ' StopLoss � �������
    TakeProfit = rstTemp5.Fields("TakeProfit").Value ' TakeProfit � �������
    OnePoint = rstTemp5.Fields("OnePoint").Value ' �������� ������ ������ � ����
    
    ' ������ ������ ��� �������
    TakeProfit_isOk_AtOnce_AvgCnt_delta_alert = rstTemp5.Fields("TakeProfit_isOk_AtOnce_AvgCnt_delta_alert").Value ' ����������� ������� ����� TakeProfit_isOk_AtOnce_up_AvgCnt � TakeProfit_isOk_AtOnce_down_AvgCnt, ��� ������� ��������� ����� (������� ��������)
    TakeProfit_isOk_AtOnce_AvgCnt_limit_alert = rstTemp5.Fields("TakeProfit_isOk_AtOnce_AvgCnt_limit_alert").Value ' ����������� �������� TakeProfit_isOk_AtOnce_up_AvgCnt ��� TakeProfit_isOk_AtOnce_down_AvgCnt, ��� ������� ��������� ����� (������� ��������)
    CPoints_AtOnce_Avg_delta_alert = rstTemp5.Fields("CPoints_AtOnce_Avg_delta_alert").Value ' ����������� ������� ����� ChighMax_AtOnce_Avg � ClowMin_AtOnce_Avg, ��� ������� ��������� ����� (���-�� �������)
    CPoints_AtOnce_Avg_limit_alert = rstTemp5.Fields("CPoints_AtOnce_Avg_limit_alert").Value ' ����������� �������� ChighMax_AtOnce_Avg ��� ClowMin_AtOnce_Avg, ��� ������� ��������� ����� (���-�� �������)
    
    cntDaysPreviousShowABV = rstTemp5.Fields("cntDaysPreviousShowABV").Value ' ���������� ���������� ����, �� ������� ���������� ABV �� ������� (1 - ���������� ������ �� ������� ����)
    
    isLogTables = rstTemp5.Fields("isLogTables").Value  ' 1 - ���������� �������, 2 - ���������� ������ ntImport_log, 0 - �� ���������� �������

    IsExportToExcelCurrent = rstTemp5.Fields("IsExportToExcelCurrent").Value ' 1 - �������������� ������� ������ � Excel, 0 - �� ��������������
    IsOpenExcelCurrent = rstTemp5.Fields("IsOpenExcelCurrent").Value ' 1 - ������� Excel ��� ������ ������� ��������, 0 - �� ��������� (���� ���������� ���������� ��������)
    IsExportToExcelHistory = rstTemp5.Fields("IsExportToExcelHistory").Value ' 1 - �������������� ������������ ������ � Excel, 0 - �� ��������������
    IsOpenExcelHistory = rstTemp5.Fields("IsOpenExcelHistory").Value ' 1 - ������� Excel ��� ������ ������������ ��������, 0 - �� ��������� (���� ���������� ���������� ��������)
    
    strCalendarNewsName = rstTemp5.Fields("strCalendarNewsName").Value ' ����� ���������� � ���������
    strCalendarCountryName = rstTemp5.Fields("strCalendarCountryName").Value ' ������, �� ������� ������� ���������� � ��������� United States  Eur* Canada Japan
    PeriodMultiplicatorForCalendar = rstTemp5.Fields("PeriodMultiplicatorForCalendar").Value ' ��������� �������, ������� ����� ��� ������ ������� � ���������
    isCalcAverageValuesInPercents = rstTemp5.Fields("isCalcAverageValuesInPercents").Value ' 1 - ������� ����������� �������� � ��������� �� ����, 0 - ������� � �������
    
    
    pCountCharts = rstTemp5.Fields("pCountCharts").Value ' ���������� �������� � ��������
    pbarsBefore = rstTemp5.Fields("pbarsBefore").Value '+ 700 ' ���������� ����� �� ������� � �������� �� ������� � 8200
    pbarsTotal = rstTemp5.Fields("pbarsTotal").Value '+ 1200 ' ���������� ����� �� ������� � �������� ����� 9000
    cntRowsCorr = rstTemp5.Fields("cntRowsCorr").Value ' ���������� ������ ����� � ������������ ��������� �, ������� ����� ��� ����������� �������
    
    IsInverse = rstTemp5.Fields("IsInverse").Value ' 0 - ������ ���� ������ (EURUSD), 1 - �������� (USDCAD)
    SortBack = rstTemp5.Fields("SortBack").Value ' 0 - ���������� � � ������ �������, 1 - � ��������
    
    pExcelWindowState = rstTemp5.Fields("pExcelWindowState").Value ' 1 = ������������� ���� Excel, 2 = ����������� ����, 3 = ������ �� ������, 4 = �����������, �� ��� ����������� ������ �������������

    isSendEmailOnAlert = rstTemp5.Fields("isSendEmailOnAlert").Value ' 1 - �������� email ��� ������
    isSendSmsOnAlert = rstTemp5.Fields("isSendSmsOnAlert").Value ' 1 - �������� sms ��� ������
    isCountAverageValuesWithNextDay = rstTemp5.Fields("isCountAverageValuesWithNextDay").Value ' 1 - ������������ ����� ���������� (������������ ������, �����/����) � ������ ���������� ���, 0 - ������������ ����� ���������� ������ � �������� �������� ���

    SourceFilePath = rstTemp5.Fields("SourceFilePath").Value
    
    ctime_CalcAverageValuesWithNextDay = rstTemp5.Fields("ctime_CalcAverageValuesWithNextDay").Value ' �����, ������� � �������� ������������ ����� ���������� � ������ ���������� ��������� ���
    CntBarsMinLimit = rstTemp5.Fields("CntBarsMinLimit").Value ' ����������� ���������� �����, ������� ����� ���� � �������� ��� (����� ��� ���������� ���������� ��������� ���)
    
    
    If ((IsNull(rstTemp5.Fields("cntBarsCalcCorr").Value)) Or (rstTemp5.Fields("cntBarsCalcCorr").Value = "")) Then
        cntBarsCalcCorr = 0
    Else
        cntBarsCalcCorr = rstTemp5.Fields("cntBarsCalcCorr").Value ' ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)
    End If
    
    
    
    
    
    
    DeltaCcloseRangeMaxLimit = rstTemp5.Fields("DeltaCcloseRangeMaxLimit").Value ' ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
    DeltaCcloseRangeMinLimit = rstTemp5.Fields("DeltaCcloseRangeMinLimit").Value ' ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
    IsCalcCorrOnlyForSameTime = rstTemp5.Fields("IsCalcCorrOnlyForSameTime").Value ' 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
    DeltaMinutesCalcCorr = rstTemp5.Fields("DeltaMinutesCalcCorr").Value ' ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
    CalcCorrParamsId = rstTemp5.Fields("CalcCorrParamsId").Value ' ������������� ���������� ������� �
    
    
    If IsNull(rstTemp5.Fields("cntCharts_last").Value) Then
        isCalcCorr1 = 0 ' 1 = ������� �, 0 = �� ������� � (�.�. ��� ��������� �� ������� ParamsIdentifyer)
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
    
    is_makeDeals_RealTrade = rstTemp5.Fields("is_makeDeals_RealTrade").Value ' 1 - ��������� ������
    
    cntSourceFiles = rstTemp5.Fields("cntSourceFiles").Value ' ���������� �������� ��������� ������
    

rstTemp5.Close





' ������� ����� ����� �
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
    
    cDateCalc = datepart_yyyy & "." & datepart_m & "." & datepart_d ' ����, �� ������� ������� � (�� ��������� �������)
End If


cDateTimeFirst = cDateCalc & " " & cTimeFirst  ' ����� ������ ������� �
cDateTimeLast = cDateCalc & " " & cTimeLast  ' �����, �� ������� ������� � � ������ �������
'---------------------------
If cTimeFirstCalc = "" Then
    If cDateCalc = datepart_yyyy & "." & datepart_m & "." & datepart_d Then
        ' ���� ������� �� �������, �� �������� PeriodMinutes �� �������� �������
        datepart_h = DatePart("h", DateAdd("n", -PeriodMinutes, Now))
        datepart_n = DatePart("n", DateAdd("n", -PeriodMinutes, Now))
        
        If Len(datepart_h) = 1 Then
            datepart_h = "0" & datepart_h
        End If
        
        If Len(datepart_n) = 1 Then
            datepart_n = "0" & datepart_n
        End If
        
        cDateTimeFirstCalc = cDateCalc & " " & datepart_h & ":" & datepart_n  ' ����� ������ ������� ����� �����������
    Else
        ' ���� ������� �� �� �������, �� ������ cTimeLastCalc
        cDateTimeFirstCalc = cDateCalc & " " & cTimeLastCalc
    End If
Else
    cDateTimeFirstCalc = cDateCalc & " " & cTimeFirstCalc ' ����� ������ ������� ����� �����������
End If
'---------------------------
cDateTimeLastCalc = cDateCalc & " " & cTimeLastCalc  ' ����� ��������� ������� ����� �����������





' �������� ������ � NT
If DataSourceId = 2 Then 'NT (5-������� ������� �� 1-�������)
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
' ������ ����� ��������� ����� � �������� �������, ����� �������� ���������� ����� � NT
Dim i As Long
Dim SourceTableNameTxt As String
Dim SourceTableNameAccess As String
Dim SQLString As String

    If DataSourceId = 2 Then 'NT
        
        
        If cntSourceFiles = 1 Then ' NT7
            SourceFileNameCurrentRealTime = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_RealTime.txt"
            SourceFileNameCurrent = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId & ".txt"
            
            If Dir(SourceFileNameCurrent, 16) <> "" Then ' ���� SourceFileNameCurrent ��� ����������
                If FileSystem.FileDateTime(SourceFileNameCurrentRealTime) <> FileSystem.FileDateTime(SourceFileNameCurrent) Then ' ���� SourceFileNameCurrent �������
                    Call WriteLog("������� ����� ��������� �����")
                    Kill SourceFileNameCurrent ' ������� ����� ��������� �����
                    Call WriteLog("�������� �������� ����")
                    FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent '�������� �������� ����
                    Call WriteLog("����������� ��������� ����� ���������")
                End If
            Else ' ���� SourceFileNameCurrent �� ����������
                Call WriteLog("�������� �������� ����")
                FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent '�������� �������� ����
                Call WriteLog("����������� ��������� ����� ���������")
            End If
        End If
        
        If cntSourceFiles > 1 Then ' NT8
        
            For i = 1 To cntSourceFiles
        
                SourceFileNameCurrentRealTime = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_RealTime_" & i & ".txt"
                SourceFileNameCurrent = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_" & i & "_id" & MdbFileId & ".txt"
        
                If Dir(SourceFileNameCurrent, 16) <> "" Then ' ���� SourceFileNameCurrent ��� ����������
                    If FileSystem.FileDateTime(SourceFileNameCurrentRealTime) <> FileSystem.FileDateTime(SourceFileNameCurrent) Then ' ���� SourceFileNameCurrent �������
                        Call WriteLog("������� ����� ��������� �����")
                        Kill SourceFileNameCurrent ' ������� ����� ��������� �����
                        Call WriteLog("�������� �������� ����")
                        FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent '�������� �������� ����
                        Call WriteLog("����������� ��������� ����� ���������")
                    End If
                Else ' ���� SourceFileNameCurrent �� ����������
                    Call WriteLog("�������� �������� ����")
                    FileCopy SourceFileNameCurrentRealTime, SourceFileNameCurrent '�������� �������� ����
                    Call WriteLog("����������� ��������� ����� ���������")
                End If
            
            Next i
            
            
    
            ' ������������ ������ �� ��������� ������ � ������� Access
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_1_id" & MdbFileId
            SourceTableNameAccess = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes & "_id" & MdbFileId
            
            SQLString = "insert into " & SourceTableNameAccess & "(cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime) "
            SQLString = SQLString & "select cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime from " & SourceTableNameTxt
            SQLString = SQLString & " order by cdatetime "
        
            Call ClearTable(SourceTableNameAccess)
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
            
            ' ��������� ABVMini
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
        
    
            ' ��������� BSV
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
            
            ' ��������� BSVMini
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
' ������ ����� ��������� ����� � �������� �������, ����� �������� ���������� ����� � NT
Dim i As Long
Dim SourceTableNameTxt As String
Dim SourceTableNameAccess As String
Dim SQLString As String

    If DataSourceId = 2 Then 'NT
    
    
        If cntSourceFiles = 1 Then ' NT7
            SourceFileNameCurrentRealTime_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_RealTime.txt"
            SourceFileNameCurrent_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId & ".txt"
            
            If Dir(SourceFileNameCurrent, 16) <> "" Then ' ���� SourceFileNameCurrent ��� ����������
                If FileSystem.FileDateTime(SourceFileNameCurrentRealTime_cn) <> FileSystem.FileDateTime(SourceFileNameCurrent_cn) Then ' ���� SourceFileNameCurrent �������
                    Call WriteLog("������� ����� ��������� �����")
                    Kill SourceFileNameCurrent_cn ' ������� ����� ��������� �����
                    Call WriteLog("�������� �������� ����")
                    FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn '�������� �������� ����
                    Call WriteLog("����������� ��������� ����� ���������")
                End If
            Else ' ���� SourceFileNameCurrent �� ����������
                Call WriteLog("�������� �������� ����")
                FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn '�������� �������� ����
                Call WriteLog("����������� ��������� ����� ���������")
            End If
        End If
    
    
    
        If cntSourceFiles > 1 Then ' NT8
        
            For i = 1 To cntSourceFiles
        
                SourceFileNameCurrentRealTime_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_RealTime_" & i & ".txt"
                SourceFileNameCurrent_cn = SourceFilePath & "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_" & i & "_id" & MdbFileId & ".txt"
        
                If Dir(SourceFileNameCurrent_cn, 16) <> "" Then ' ���� SourceFileNameCurrent_cn ��� ����������
                    If FileSystem.FileDateTime(SourceFileNameCurrentRealTime_cn) <> FileSystem.FileDateTime(SourceFileNameCurrent_cn) Then ' ���� SourceFileNameCurrent_cn �������
                        Call WriteLog("������� ����� ��������� ����� _cn")
                        Kill SourceFileNameCurrent_cn ' ������� ����� ��������� ����� _cn
                        Call WriteLog("�������� �������� ���� _cn")
                        FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn '�������� �������� ����
                        Call WriteLog("����������� ��������� ����� _cn ���������")
                    End If
                Else ' ���� SourceFileNameCurrent_cn �� ����������
                    Call WriteLog("�������� �������� ���� _cn")
                    FileCopy SourceFileNameCurrentRealTime_cn, SourceFileNameCurrent_cn '�������� �������� ����
                    Call WriteLog("����������� ��������� ����� _cn ���������")
                End If
            
            Next i
            
    
            ' ������������ ������ �� ��������� ������ � ������� Access
            
            SourceTableNameTxt = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_1_id" & MdbFileId
            SourceTableNameAccess = "ntImport_" & CurrencyNTName_current & "_Minute_" & PeriodMinutes_cn & "_id" & MdbFileId
            
            SQLString = "insert into " & SourceTableNameAccess & "(cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime) "
            SQLString = SQLString & "select cdateold, ctimeold, copen, chigh, clow, cclose, Volume, ABV, cdate, ctime, cdatetime from " & SourceTableNameTxt
            SQLString = SQLString & " order by cdatetime "
        
            Call ClearTable(SourceTableNameAccess)
            Application.SetOption "Confirm Action Queries", False
            DoCmd.RunSQL SQLString
        
            
            ' ��������� ABVMini
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
        
    
            ' ��������� BSV
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
            
            ' ��������� BSVMini
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


