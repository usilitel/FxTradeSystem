Attribute VB_Name = "mCorr"
'Option Compare Database
Option Explicit

Sub CountCorr_cn()

' � ����� ���������� ��������� n-�� ������� � ������������ ��� ������ �

Dim SQLString As String
Dim SQLString2 As String
Dim i As Long
Dim j As Long
Dim j2 As Long
Dim j3 As Long
Dim cntRowsTemp As Long
Dim counterDaysAgo As Integer
Dim CurrentDayCntBars As Integer

' ���������� ��������� ���� �������� ��� ������� ParamsIdentifyer
SQLString = " select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '" & ParamsIdentifyer & "' and WeightCORR <> 0 order by idn"
Set rstPeriodsParameters = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
rstPeriodsParameters.MoveLast
cntRowsTemp = rstPeriodsParameters.RecordCount
rstPeriodsParameters.MoveFirst
    
    For i = 1 To cntRowsTemp

        ' ����������� ���������� n-�� �������
            PeriodMinutes_cn = rstPeriodsParameters.Fields("PeriodMinutes").Value ' ������ ������ � �������, �� �������� ���� ������� �
            
            FieldNumCurrent_cn = rstPeriodsParameters.Fields("FieldNumCurrent").Value ' ����� ������� (������� � 0) � ������� tblDataCurrent, �� �������� ������� �
            FieldNumHistory_cn = rstPeriodsParameters.Fields("FieldNumHistory").Value ' ����� ������� (������� � 0) � ������� � ��������, �� �������� ������� �
                
            idAlgorithmCalcCorr_cn = rstPeriodsParameters.Fields("idAlgorithmCalcCorr").Value ' �������� ������� �: 1 - �������, 2 - ���������� (CalcCorrelationEasy)
            
            ' ��������� ��� ����������� �������� ����� ������� �
            'cTimeLast_cn = rstPeriodsParameters.Fields("cTimeLast").Value ' �����, �� ������� ������� � (���� �� �������, �� ����� ntSettingsFilesParameters_cn.cTimeLast)
            If ((IsNull(rstPeriodsParameters.Fields("cTimeLast").Value)) Or (rstPeriodsParameters.Fields("cTimeLast").Value = "")) Then
                cTimeLast_cn = cTimeLast
            Else
                cTimeLast_cn = rstPeriodsParameters.Fields("cTimeLast").Value
            End If
            cntDaysAgoLast_cn = rstPeriodsParameters.Fields("cntDaysAgoLast").Value ' ���������� ���� ����� �� ���� ntSettingsFilesParameters_cn.cDateTimeCalc
                
            ' ��������� ��� ����������� ��������� ����� ������� �
            'cTimeFirst_cn = rstPeriodsParameters.Fields("cTimeFirst").Value ' �����, ������� � �������� ������� � (���� �� �������, �� ����� ntSettingsFilesParameters_cn.cTimeFirst)
            If ((IsNull(rstPeriodsParameters.Fields("cTimeFirst").Value)) Or (rstPeriodsParameters.Fields("cTimeFirst").Value = "")) Then
                cTimeFirst_cn = cTimeFirst
            Else
                cTimeFirst_cn = rstPeriodsParameters.Fields("cTimeFirst").Value
            End If
            cntDaysAgoFirst_cn = rstPeriodsParameters.Fields("cntDaysAgoFirst").Value ' ���������� ���� ����� �� �������� ����� ������� �
        
        
            WeightCORR_cn = rstPeriodsParameters.Fields("WeightCORR").Value / WeightCORR_cn_sum ' ��� � �� ������� ������� � ����� �
        
            MAPeriod_cn = rstPeriodsParameters.Fields("MAPeriod").Value ' ������ MA (�� ������� ������� �)
            
        
            IsCalcCclosePosition_cn = rstPeriodsParameters.Fields("IsCalcCclosePosition").Value ' 1 - ������� CclosePosition, 0 - �� �������
            vCclosePositionDelta_cn = rstPeriodsParameters.Fields("vCclosePositionDelta").Value ' ���������� ���������� ��������� cclose � ��������� ��� ������� �
            
            'CntBarsMinLimit_cn = rstPeriodsParameters.Fields("CntBarsMinLimit").Value ' ����������� ���������� �����, ������� ����� ���� � ��������� ���
            If ((IsNull(rstPeriodsParameters.Fields("CntBarsMinLimit").Value)) Or (rstPeriodsParameters.Fields("CntBarsMinLimit").Value = "")) Then
                CntBarsMinLimit_cn = CntBarsMinLimit
            Else
                CntBarsMinLimit_cn = rstPeriodsParameters.Fields("CntBarsMinLimit").Value
            End If
            
            
            
            
            'DeltaCcloseRangeMaxLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value ' ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
            If ((IsNull(rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value)) Or (rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value = "")) Then
                DeltaCcloseRangeMaxLimit_cn = DeltaCcloseRangeMaxLimit
            Else
                DeltaCcloseRangeMaxLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMaxLimit").Value
            End If
            
            'DeltaCcloseRangeMinLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value ' ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
            If ((IsNull(rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value)) Or (rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value = "")) Then
                DeltaCcloseRangeMinLimit_cn = DeltaCcloseRangeMinLimit
            Else
                DeltaCcloseRangeMinLimit_cn = rstPeriodsParameters.Fields("DeltaCcloseRangeMinLimit").Value
            End If
            
            'IsCalcCorrOnlyForSameTime_cn = rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value ' 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
            If ((IsNull(rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value)) Or (rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value = "")) Then
                IsCalcCorrOnlyForSameTime_cn = IsCalcCorrOnlyForSameTime
            Else
                IsCalcCorrOnlyForSameTime_cn = rstPeriodsParameters.Fields("IsCalcCorrOnlyForSameTime").Value
            End If
            
            'DeltaMinutesCalcCorr_cn = rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value ' ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
            If ((IsNull(rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value)) Or (rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value = "")) Then
                DeltaMinutesCalcCorr_cn = DeltaMinutesCalcCorr
            Else
                DeltaMinutesCalcCorr_cn = rstPeriodsParameters.Fields("DeltaMinutesCalcCorr").Value
            End If
            
            
            
            
            
            
            
            
            
            
            
            ' cntBarsCalcCorr_cn ������ ����� cntBarsCalcCorr
            ' !!! ���� ������ - �� ���� ��������� ������������ ������� � !!!
            cntBarsCalcCorr_cn = cntBarsCalcCorr
            'If ((IsNull(rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value)) or (rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value="")) Then
            '    cntBarsCalcCorr_cn = cntBarsCalcCorr
            'Else
            '    cntBarsCalcCorr_cn = rstPeriodsParameters.Fields("cntBarsCalcCorr_cn").Value ' ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)
            'End If
            
        
        
        
        
        
        
        
        
        
        
        ' ���������� �������� ������� � ������������� ������� ��� n-�� �������
        tblDataHistory_cn = "ntPeriodsDataCCLOSE_" & CurrencyId_history & "_" & DataSourceId & "_" & PeriodMinutes_cn & "_1_1"
        
        ' ���������� �������� ������� � �������� ������� ��� n-�� �������
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

        ' ���������� ������� ������� ������
        
        ' 1. ���������� �������� ���� ������� ������
        cDateCalcLast_cn = cDateCalc

        ' ���� cntDaysAgoLast_cn > 0, �� ������ �������� ������� ������� ������
        If cntDaysAgoLast_cn > 0 Then
            ' �������� ���� � ����������� ����� ������ ��� CntBarsMinLimit_cn
            SQLString2 = " select cdate, count(cdate) as cntBars from " & tblDataCurrent_cn & " group by cdate having  count(cdate) > " & CntBarsMinLimit_cn & " order by cdate "
                
            Set rstTemp = DB.OpenRecordset(SQLString2, dbOpenDynaset, dbSeeChanges)
            rstTemp.MoveLast
            counterDaysAgo = 0
            
            Do While Not rstTemp.BOF
                ' ����������� ������� ���������� ���� �����
                If rstTemp.Fields("cdate").Value < cDateCalc And counterDaysAgo > 0 Then
                    counterDaysAgo = counterDaysAgo + 1
                End If
                
                ' �� ������ ���������� ��� �������� ������ ���� �����
                If rstTemp.Fields("cdate").Value < cDateCalc And counterDaysAgo = 0 Then
                    counterDaysAgo = 1
                End If
                
                ' ����� ������ ����
                If counterDaysAgo = cntDaysAgoLast_cn Then
                    'MsgBox rstTemp.Fields("cdate").Value
                    cDateCalcLast_cn = rstTemp.Fields("cdate").Value
                End If
                
                rstTemp.MovePrevious
            Loop
            rstTemp.Close
        End If
        
        cDateTimeLast_cn = cDateCalcLast_cn & " " & cTimeLast_cn  ' ����� ��������� ������� �


        
        
        
        ' 2. ���������� ��������� ���� ������� ������
        cDateCalcFirst_cn = cDateCalcLast_cn

        ' ���� cntDaysAgoFirst_cn > 0, �� ������ ��������� ������� ������� ������
        If cntDaysAgoFirst_cn > 0 Then
            ' �������� ���� � ����������� ����� ������ ��� CntBarsMinLimit_cn
                
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
                ' ����������� ������� ���������� ���� �����
                If rstTemp.Fields("cdate").Value < cDateCalcLast_cn And counterDaysAgo > 0 Then
                    counterDaysAgo = counterDaysAgo + 1
                End If
                
                ' �� ������ ���������� ��� �������� ������ ���� �����
                If rstTemp.Fields("cdate").Value < cDateCalcLast_cn And counterDaysAgo = 0 Then
                    counterDaysAgo = 1
                End If
                
                ' ����� ������ ����
                If counterDaysAgo = cntDaysAgoFirst_cn Then
                    'MsgBox rstTemp.Fields("cdate").Value
                    cDateCalcFirst_cn = rstTemp.Fields("cdate").Value
                End If
                rstTemp.MovePrevious
            Loop
            rstTemp.Close
        End If
        
        cDateTimeFirst_cn = cDateCalcFirst_cn & " " & cTimeFirst_cn  ' ����� ������ ������� �





                
        
        
        
        ' ����� ������� ��� n-�� ������� (���� ��� �� �����)
        'If Not ((arrDataHistory_cn_filled = 1) And (tblDataHistory_cn_previous = tblDataHistory_cn)) Then
            Call FillArrDataHistory_cn
        'End If
        
        
        ' ����� ������� ������ ��� n-�� �������
        Call FillArrDataCurrent_cn



        ' ������� � ��� n-�� �������
        'Call WriteLog("-- ������ CalcCorrelation_" & UBound(arrDataHistoryCompare) & "_" & UBound(arrCclose_cn) & "_" & UBound(arrCorr_cn) & "_" & UBound(arrCclose) & "_" & DeltaCcloseRangeMinLimit_cn & "_" & DeltaCcloseRangeMaxLimit_cn)
        Call CalcCorrelation(arrDataHistoryCompare, arrCclose_cn, arrCorr_cn, arrCclose, DeltaCcloseRangeMinLimit_cn, DeltaCcloseRangeMaxLimit_cn)
        'Call WriteLog("-- CalcCorrelation ���������")
        ' ������ ������������ � ���������� � ������� arrCorr_cn


'-----------------------
        
        ' �������� ������������ � �� ������ ���������� ����
        If cntDaysAgoLast_cn > 0 Then
        
            CcorrCurrentDayMax = -10
            cDateLastStep = ""
            CurrentDayCntBars = 0
            j2 = 0
            
        ' ������� ������������ ������������ � �� ����
            For j = 1 To cntDataHistoryRows_cn ' ���� �� ������� �������
            
                If j = 1 Then
                    ' ���������� ������� ����
                    cDateLastStep = arrCdate(j - 1)
                End If
            
            
            'If arrCdate(j - 1) >= "2014.12.06" Then
            '    j2 = j2
            'End If
            
                ' ���� ������� �� ��������� ���� - �� �������� CcorrCurrentDayMax (������������ � �� ������� ����)
                If arrCdate(j - 1) <> cDateLastStep And CurrentDayCntBars > CntBarsMinLimit_cn Then
                    ' ���������� ������������ �������� � �� ����
                    arrCorrMaxForDates_cn(0, j2) = cDateLastStep ' ����
                    arrCorrMaxForDates_cn(1, j2) = CcorrCurrentDayMax ' ������������ �
                    j2 = j2 + 1
                
                    CcorrCurrentDayMax = -10
                    CurrentDayCntBars = 0
                    
                End If
                
                ' ��������� CcorrCurrentDayMax (������������ � �� ������� ����)
                If arrCorr_cn(j - 1) > CcorrCurrentDayMax Then
                    CcorrCurrentDayMax = arrCorr_cn(j - 1)
                End If
                
                If j2 >= cntDaysAgoLast_cn Then
                    arrCorr_cn(j - 1) = arrCorrMaxForDates_cn(1, j2 - cntDaysAgoLast_cn)
                End If
                
                ' ���������� ������� ����
                cDateLastStep = arrCdate(j - 1)
                
                ' ����������� ������� ����� � ���
                CurrentDayCntBars = CurrentDayCntBars + 1
            Next j
            ' ������ � ������� arrCorrMaxForDates_cn ���������� ������������ � �� ����
            
                'Call ClearTable("ttemp3")
                'Call WriteArr3ToTable(arrCorrMaxForDates_cn, "ttemp3", "f2", "f1", 2000)
            
            
            'j2 = 0
            'Do While arrCorrMaxForDates_cn(1, j2) <> -100
                
            '    j2 = j2 + 1
            'Loop
            
            
        End If

'------------------------------





        ' ��������� � �� ������� ������� � � �� ���� ���������� ��������
        ' ���� ��������� ������, �� �������� �������������� �, ��������� � �������� �������, �� ������ ��������� �
        If cntDataHistoryRows = cntDataHistoryRows_cn Then
            For j = 1 To cntDataHistoryRows
                arrCORRTotal(j - 1) = arrCORRTotal(j - 1) + arrCorr_cn(j - 1) * WeightCORR_cn
            Next j
        End If
        
        ' ���� ��������� ������, �� �������� �������������� �, �� ��������� � �������� �������, �� ���������� �
        If cntDataHistoryRows > cntDataHistoryRows_cn Then
            j3 = 0
            For j = 1 To cntDataHistoryRows_cn
                Do While arrCdateTime(j3) <= arrCdateTime_cn(j - 1)
                    arrCORRTotal(j3) = arrCORRTotal(j3) + arrCorr_cn(j - 1) * WeightCORR_cn
                    j3 = j3 + 1
                Loop
            Next j
        End If
        
        ' ���� ��������� ������, �� �������� �������������� �, �� ��������� � �������� �������, �� ���������� �
'        If cntDataHistoryRows < cntDataHistoryRows_cn Then
'            j3 = 0
'            On Error GoTo err1 ' ���� cntDataHistoryRows < cntDataHistoryRows_cn, �� �� ��������� ����� ����� ��������� ������ (����� �� ������� �������)
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


Call WriteLog("����� � ��������� (�������� ������ arrCORRTotal)") ' ����� ���

' ����� ���
Call WriteLog("������ ����������")

    QuickSortNonRecursive3 arrCORRTotal, arrIDNSorted 'Rng   '���������� ����������

Call WriteLog("����� ����������") ' ����� ���


' ��������� ������� tCorrResults �� SQL Server
Call ClearTable(tCorrResultsBufer)



' ������� ��������� ������� � Access
Call WriteArr2ToTable(arrIDNSorted, arrCORRTotal, tCorrResultsBufer, "IDN", "ccorr", cntRowsCorr)
Call WriteLog("������� " & tCorrResultsBufer & " ��������� ")

' ��������� ����� ������� ��� ��������
If isLogTables = 1 Then
    SQLString = "insert into " & tCorrResultsBufer & "_log" & " (cinfo) "
    SQLString = SQLString & " select " & """" & cDateTimeFirst & "; cDateTimeLast=" & cDateTimeLast & "; CurrentBarTimeInMinutes=" & CurrentBarTimeInMinutes & "; DeltaMinutesCalcCorr=" & DeltaMinutesCalcCorr_cn & "; PeriodMinutes=" & PeriodMinutes & "; cntDataCurrentRows=" & cntDataCurrentRows & "; " & CStr(Now) & """"
    Application.SetOption "Confirm Action Queries", False
    DoCmd.RunSQL SQLString
    
    Call WriteArr2ToTable(arrIDNSorted, arrCORRTotal, tCorrResultsBufer & "_log", "IDN", "ccorr", cntRowsCorr) ' ����������� �������� ������ arrCORRTotal (������ �� ������, ������� ������ � ������� tCorrResultsBufer)
    Call WriteLog("������� " & tCorrResultsBufer & "_log" & " ���������; cDateTimeLast = " & cDateTimeLast)
End If

' ����� ������������� ��� ������� ������� �� Access �� SQL Server (��� ������� ��������)
SQLString = "delete from " & tCorrResults & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
DB.Execute SQLString, dbSeeChanges + dbFailOnError

SQLString = "insert into " & tCorrResults & " (idn, ccorr, ParamsIdentifyer) "
SQLString = SQLString & " select idn, ccorr, '" & ParamsIdentifyer & "' from " & tCorrResultsBufer
SQLString = SQLString & " order by idn "
    
'Call ClearTableMSSQL(tCorrResults)
Application.SetOption "Confirm Action Queries", False
DoCmd.RunSQL SQLString

Call WriteLog("������� " & tCorrResults & " �� SQL Server ��������� (1)")


' ��������� ������������ �������������� ������
' ������� tCorrResults �� SQL Server ������ ���� ��� ���������
' ��������� ������� tCorrResultsReport �� SQL Server
'Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & DeltaMinutesCalcCorr & ",'" & ParamsIdentifyer & "'")
Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "' ,'" & ParamsIdentifyer & "'") ' �� ��������� �� DeltaMinutesCalcCorr, �.�. ��� �������� ������ ������ ������
Call WriteLog("����� exec " & pCorrResultsReport)







End Sub




Sub CountAverageValues()

Dim SQLString As String

    

    ' ������������ ����� ���������� (��������� ������� ntAverageValuesResults)
    Call WriteLog("��������� ��������� ntpCorrResultsAverageValues �� MSSQL")
    'SQLString = "exec ntpCorrResultsAverageValues " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes_cn & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "', " & cntBarsCalcCorr & ", '" & ctime_CalcAverageValuesWithNextDay & "', " & CntBarsMinLimit
    SQLString = "exec ntpCorrResultsAverageValuesParamRanges " & " '" & ParamsIdentifyer & "' "
    'Debug.Print SQLString
    Call ExecProcedureMSSQL(SQLString)
    Call WriteLog("��������� ntpCorrResultsAverageValues �� MSSQL ���������")


End Sub


Public Sub PearsonCorrelationPrepare(ByRef arrHistory() As Double, _
                                     ByRef arrCurrent() As Double, _
                                     ByVal n As Long)
' ��������������� ������ ����������� ��� ����������� ������� �

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
' ������ � ��� ������� ��������
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

' arrHistoryOld - ��������� ������� ������� (�� ���������� ���� �� ��� ������)
' arrHistoryNew - ����� ������� �������

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
' ������ �:
' ������� ���� �� ������� arrHistoryAll � ������� � � �������� arrCurrentCompare

'�������� ����������:
'arrHistoryCompare() - ������-���� � ������������� ������� (�� ������� ������� �)
'arrCurrentCompare() - ������ � �������� ������� (�� ������� ������� �)
'arrCorrelationValues() - ������, � ������� ���������� ������������ �������� �
'arrHistoryAll() - ������ �� ����� ������������� ������� (�� ���� ������� ������-����)
'DeltaRangeMinLimit - ���������� ���������� ������� ����� �������� � ������������� ������� (0 - �� ��������� ��� �������)
'DeltaRangeMaxLimit - ����������� ���������� ������� ����� �������� � ������������� ������� (0 - �� ��������� ��� �������)

Dim SQLString As String
Dim i As Long
Dim j As Long
Dim CurrentRange As Single
Dim HistoryRange As Single
'Dim ArrValueFirst As Double




' ��������������� ������ �����������
Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataCurrentRows)



For i = 1 To (cntDataCurrentRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i




' ������� � ��� ������� ��������
For i = 1 To 1 ' ���� �� ������� �������
  For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
    
    'ArrValueFirst = 0
    '' ��� ������� � �� ABV/ABVMini �������� ������ ������� (�����  ����� ����������/������������)
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

' ������� � ��� ���� �����
If IsCalcCorrOnlyForSameTime_cn = 0 Then
    For i = 2 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' ���� �� ������� �������
      For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
        arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
        
        'ArrValueFirst = 0
        '' ��� ������� � �� ABV/ABVMini �������� ������ ������� (�����  ����� ����������/������������)
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




' ������� � ������ ��� �����, ������� �� ������� � ��������
If IsCalcCorrOnlyForSameTime_cn = 1 Then


    ' ���� ����� DeltaRangeMinLimit ��� DeltaRangeMaxLimit, �� ��������� �������� ������� ������
    If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
        CurrentRange = fMaxValue(arrCurrentCompare) - fMinValue(arrCurrentCompare)
    End If



    For i = 2 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' ���� �� ������� �������
      
      'arrCcloseTimeInMinutes (i + cntDataCurrentRows - 2) - ����� ���������� ������������� ����
      'CurrentBarTimeInMinutes - ����� �������� ���� (� ������� � ������ ���)
      'arrCcloseTimeInMinutes() - ������ � �������� ������������ ����� (� ������� � ������ ���)
      'arrCorrelationValues(i - 1 + cntDataCurrentRows - 2) - �������� �, ������������ �� ���������� ����
      
      'If i = 272 Then
      '  i = i
      'End If
      
      iNum = i
      

      
      ' ���� ����� ���������� ������������� ���� �������� � �������������� ����������, �� ��������� ������ ��� ��������� � ������� � (���� ����������� ���� ������ ��� ��� ���������������� �������)
      If ((((arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) >= (CurrentBarTimeInMinutes - DeltaMinutesCalcCorr_cn - PeriodMinutes_cn)) And (arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) <= (CurrentBarTimeInMinutes + DeltaMinutesCalcCorr_cn)))) _
            And _
          (arrCdate(i + cntDataCurrentRows - 2) < cdate_current)) Then ' � ���� ���������� ������������� ���� ������ ��� ���� �������� ����
            For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
                arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
                
                'ArrValueFirst = 0
                '' ��� ������� � �� ABV/ABVMini �������� ������ ������� (�����  ����� ����������/������������)
                'If ((DataSourceId = 2) And (FieldNumHistory_cn = 2 Or FieldNumHistory_cn = 3)) Then
                '    If j = 1 Then
                '        'ArrValueFirst = arrHistoryCompare(j - 1)
                '        ArrValueFirst = fMinValue(arrHistoryCompare) - 1
                '    End If
                '    arrHistoryCompare(j - 1) = arrHistoryCompare(j - 1) - ArrValueFirst '+ 1000000
                'End If
                
            Next j
            
            ' ���� ����� DeltaRangeMinLimit ��� DeltaRangeMaxLimit, �� ��������� �������� ������������ ������
            If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
                HistoryRange = fMaxValue(arrHistoryCompare) - fMinValue(arrHistoryCompare)
            End If
            
            ' ���� �������� ������������ ������ ��������� �����, �� ������ � = 0
            If ((DeltaRangeMinLimit > 0) And (HistoryRange < CurrentRange * DeltaRangeMinLimit)) Or ((DeltaRangeMaxLimit > 0) And (HistoryRange > CurrentRange * DeltaRangeMaxLimit)) Then
                arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
            Else
                ' ����� ���������� ������ �
                ' ���� � ��������� ��� ������� �������� �� ��������������� ����������, �� ������� � ������ (����� ���������� ������ ��� ����������)

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
            '���� ����� ���������� ������������� ���� �� �������� � �������������� ����������, �� ������ � = 0
            arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
      End If
    Next i
    
'Call ClearTable("ttemp3_") ' 1000000
'Call WriteArr2ToTable(arrIDNSorted, arrCorrelationValues, "ttemp3_", "f1", "f2") ' 1000000


    
    
End If


End Sub





Sub CalcCorrelationPreviousDay_old(ByRef arrHistoryCompare() As Double, ByRef arrCurrentCompare() As Double, arrCorrelationValues() As Variant, arrHistoryAll() As Variant, DeltaRangeMinLimit As Single, DeltaRangeMaxLimit As Single)
' ������ � �� ���������� ����:
' ������� ���� �� ������� arrHistoryAll � ������� � � �������� arrCurrentCompare

'�������� ����������:
'arrHistoryCompare() - ������-���� � ������������� ������� (�� ������� ������� �)
'arrCurrentCompare() - ������ � �������� ������� (�� ������� ������� �)
'arrCorrelationValues() - ������, � ������� ���������� ������������ �������� �
'arrHistoryAll() - ������ �� ����� ������������� ������� (�� ���� ������� ������-����)
'DeltaRangeMinLimit - ���������� ���������� ������� ����� �������� � ������������� ������� (0 - �� ��������� ��� �������)
'DeltaRangeMaxLimit - ����������� ���������� ������� ����� �������� � ������������� ������� (0 - �� ��������� ��� �������)

Dim SQLString As String
Dim i As Long
Dim j As Long
Dim CurrentRange As Single
Dim HistoryRange As Single

' ��������������� ������ �����������
Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)



For i = 1 To (cntDataPreviousDayRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i

' ������� � ��� ������� ��������
For i = 1 To 1 ' ���� �� ������� �������
  For j = 1 To cntDataPreviousDayRows ' ���� �� ��������� �������
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
  Next j
  arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
  'arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = 0

'------------------------
        'SQLString = "insert into ttemp(idn, f1) values(" & arrABVIDN(i - 1) & "," & Replace(arrCorrelationValues(i - 1), ",", ".") & ")"
        'DoCmd.RunSQL SQLString
'------------------------

Next i




    ' ���� ����� DeltaRangeMinLimit ��� DeltaRangeMaxLimit, �� ��������� �������� ������� ������
    If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
        CurrentRange = fMaxValue(arrCurrentCompare) - fMinValue(arrCurrentCompare)
    End If



    For i = 2 To (cntDataHistoryRows - cntDataPreviousDayRows + 1) ' ���� �� ������� �������
      
      'arrCcloseTimeInMinutes_cn (i + cntDataPreviousDayRows - 2) - ����� ���������� ������������� ����
      'CurrentBarTimeInMinutes - ����� �������� ���� (� ������� � ������ ���)
      'arrCcloseTimeInMinutes_cn() - ������ � �������� ������������ ����� (� ������� � ������ ���)
      'arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 2) - �������� �, ������������ �� ���������� ����
      
      ' ���� ����� ���������� ������������� ���� �������� � �������������� ����������, �� ��������� ������ ��� ��������� � ������� � (���� ����������� ���� ������ ��� ��� ���������������� �������)
      'If ((arrCcloseTimeInMinutes_cn(i + cntDataPreviousDayRows - 2) >= (cTimeInMinutesPreviousDayLast - cTimeInMinutesPreviousDayFirst - PeriodMinutes)) And (arrCcloseTimeInMinutes_cn(i + cntDataPreviousDayRows - 2) <= (24 * 60))) Then
      ' ���� ���� ���������� ������������� ���� ��������� � ����� ������� ������������� ����, �� ��������� ������ ��� ��������� � ������� � (���� ����������� ���� ������ ��� ��� ���������������� �������)
       If arrCdate(i + cntDataPreviousDayRows - 2) = arrCdate(i - 1) Then
            
            For j = 1 To cntDataPreviousDayRows ' ���� �� ��������� �������
                arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
            Next j
            
            ' ���� ����� DeltaRangeMinLimit ��� DeltaRangeMaxLimit, �� ��������� �������� ������������ ������
            If DeltaRangeMinLimit > 0 Or DeltaRangeMaxLimit > 0 Then
                HistoryRange = fMaxValue(arrHistoryCompare) - fMinValue(arrHistoryCompare)
            End If
            
            ' ���� �������� ������������ ������ ��������� �����, �� ������ � = 0
            If ((DeltaRangeMinLimit > 0) And (HistoryRange < CurrentRange * DeltaRangeMinLimit)) Or ((DeltaRangeMaxLimit > 0) And (HistoryRange > CurrentRange * DeltaRangeMaxLimit)) Then
                arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = 0
            Else
                ' ����� ���������� ������ �
                ' ���� � ��������� ��� ������� �������� �� ��������������� ����������, �� ������� � ������ (����� ���������� ������ ��� ����������)
                If arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 2) = 0 Then
                    Call PearsonCorrelationPrepare(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
                    arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationFirst(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows)
                Else
                    arrCorrelationValues(i - 1 + cntDataPreviousDayRows - 1) = PearsonCorrelationAll(arrHistoryCompare, arrCurrentCompare, cntDataPreviousDayRows, arrHistoryAll(i - 2), arrHistoryCompare(j - 2))
                End If
            End If
          
      Else
            '���� ����� ���������� ������������� ���� �� �������� � �������������� ����������, �� ������ � = 0
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
    


    ' ������ ��������� ������������ �������� � �� ������� ���� �� ���� ��������� ����
    For i = 1 To cntDataHistoryRows ' ���� �� ������� �������
        ' ���� ������� �� ��������� ���� - �� �������� CcorrCurrentDayMax (������������ � �� ������� ����)
        If arrCdate(i - 1) <> cDateLastStep And CurrentDayCntBars > CurrentDayCntBarsMinLimit Then
            CcorrPreviousDayMax = CcorrCurrentDayMax
            CcorrCurrentDayMax = 0
            CurrentDayCntBars = 0
            
            ' ���������� ������� ����
            cDateLastStep = arrCdate(i - 1)
        End If
        
        ' ��������� CcorrCurrentDayMax (������������ � �� ������� ����)
        If arrCorrelationValues(i - 1) > CcorrCurrentDayMax Then
            CcorrCurrentDayMax = arrCorrelationValues(i - 1)
        End If
        
        ' ��������� � � �������� ��� �� �������
        arrCorrelationValues(i - 1) = CcorrPreviousDayMax
        
        ' ����������� ������� ����� � ���
        CurrentDayCntBars = CurrentDayCntBars + 1
    Next i
    
    'Call ClearTable("ttemp3")
    'Call WriteArr2ToTable(arrIDNSorted, arrCorrelationValues, "ttemp3", "f1", "f2")
    


End Sub


