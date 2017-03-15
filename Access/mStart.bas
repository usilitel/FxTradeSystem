Attribute VB_Name = "mStart"
Option Explicit


Sub ProcStart3()
' ��������� ������ �� ������ ���

' ����� ��������:
' 1) � ����������� ������� ntSettingsFilesParameters �� ������� �� ���������:
'    IsExportToExcelCurrent=0, IsOpenExcelCurrent=0, IsExportToExcelHistory=0, IsOpenExcelHistory=0
'    cDateTimeFirst, cDateTimeLast, cDateTimeFirstCalc, cDateTimeLastCalc
' 2) ������� ����� ��������� ����� ��� ���� ���
' 3) ��������� ����� ������������ ������ �� ������������ � ��������
' 4) ���� �������� ������������� ������ ���������� � �� ����� ������� � �������� �������, �� ����� �������� ��������� ��� ������� �� ���������� ����� � Access (������ copy_source_table_current, ����� ����� �������� ��� ������� � �����).
'    ����� ������� ������� ����� ��� ������ (�� txt �����).
'    ����� (����� �������) ������� �������.
' 5) (��� �� �������) ������ ��������� IsExportToTxtCurrent = 0, IsExportToTxtHistory = 0 (���� ��������� ����� �� �����)


    Dim i As Long
    Dim SQLString As String
    
    On Error Resume Next ' �� ������ ���� ���� ��� ��������� (����� ������ �� ������� � �������)
    
    cDateTimeCalcAsDate = "2016.10.31" ' ������ ���� �� ������� ������ ������
    
    Set DB = Access.CurrentDb
    CurrDBName = CurrentProject.Name

    For i = 1 To 14 ' ���������� ���� ������ �� ������� ���� ������� ������
        cDateTimeCalc = Format(cDateTimeCalcAsDate, "yyyy.mm.dd") & " " '& "_"
        If Weekday(cDateTimeCalc, vbMonday) <> 6 And Weekday(cDateTimeCalc, vbMonday) <> 7 Then ' �� ������� � ����������� ������ �� ������
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
    
    ' ����� �������� ���������� �� ����� �����
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
    
    If (DataSourceId = 2) Or (DataSourceId = 3) Then '2 - NT (5-������� ������� �� 1-�������), 3 - Quik
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
    
    
    StartTime = GetTickCount    '���������� ��������� �����
    
    


'----------------------------

    If isCalcCorr1 = 1 Then ' 1 = ������� �, 0 = �� ������� � (�.�. ��� ��������� �� ������� ParamsIdentifyer)
    

    
        
        Call CopySourceFile ' ������ ����� ��������� ����� � �������� �������, ����� �������� ���������� ����� � NT
        
        CurrPathAccess = CurrentProject.Path
        
        
        
        ' ���������� ArrDataHistory (������ ������ 1 ���)
        Call FillArrDataHistory_new(tblDataHistory)
        
        
        
    
        
        
        
        ' ���� cTimeFirstCalc ��� �����, �� ���������� ���� � ��������������� ������ ����������� � ������� � �� ���� ����� � �����
        If cTimeFirstCalc <> "" Then
            ' �������� ������� ������, �� ������� �� ���������� ����� ���������� (��������� ������� ntImportCurrent_NoAverageValues)
            Call FillTablesDataCurrent(1, 0)
            
            

            ' ���� ������� � ������� ������� ������ (��� ������ �� ������� ����), �� ���������� ���������� ���������
            If fnCntDataCurrentBufer = 0 Then
                SQLString = "insert into nt_rt_log (log_message, cdatetime_log) select '" & ParamsIdentifyer & ": � ������� � ��������� ������� ��� ������� �� ������� ����', getdate()"
                Call ExecProcedureMSSQL(SQLString)
                GoTo exitProc
            End If
            
            
            
            Call ChangeCDateTimeFirstToReal
            Call WriteLog("��������� ��������� ntpSearchAverageValues �� MSSQL")
            SQLString = "exec ntpSearchAverageValues '" & cDateTimeFirst & "', '" & cDateTimeFirstCalc & "', '" & cDateTimeLastCalc & "', " & cntCharts & ", " & StopLoss & ", " & TakeProfit & ", " & Replace(OnePoint, ",", ".") & ", " & CurrencyId_current & ", " & CurrencyId_history & ", " & DataSourceId & ", " & PeriodMinutes & ", " & isCalcAverageValuesInPercents & ", '" & ParamsIdentifyer & "'" & ", " & cntBarsCalcCorr & ", " & DeltaCcloseRangeMaxLimit & ", " & DeltaCcloseRangeMinLimit & ", " & IsCalcCorrOnlyForSameTime & ", " & DeltaMinutesCalcCorr & ", '" & CalcCorrParamsId & "' "
            'Debug.Print (SQLString)
            Call ExecProcedureMSSQL(SQLString)
            Call WriteLog("��������� ntpSearchAverageValues �� MSSQL ���������")
            
            Call WriteLog("(5) SQLString = " & SQLString)
            Call WriteLog("(6) cDateTimeFirst = " & cDateTimeFirst)
            
            
            ' ���������� � �������� ������� ������� ������, �� ������� ����� ���������� ����� ����������
            SQLString = "             select idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer "
            SQLString = SQLString & " from  " & tblDataCurrentNoAverageValuesMSSQL
            SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
            SQLString = SQLString & " order by idn "
            

            
            Set rstTemp2 = DB.OpenRecordset(SQLString)
            'MsgBox DCount("*", tblDataCurrentNoAverageValuesMSSQL)
            'If DCount("*", tblDataCurrentNoAverageValuesMSSQL) > 0 Then
            'If rstTemp2.RecordCount > 0 Then
            If Not (rstTemp2.EOF And rstTemp2.BOF) Then ' ���� ��������� �� ������ (���� �������������� ����������)
                rstTemp2.MoveLast
                cDateTimeLastTemp = rstTemp2.Fields("cdate_last").Value & " " & rstTemp2.Fields("ctime_last").Value ' �� ���������� cDateTimeLast ������ � ����� �� ������, ������� ���� ������ �����
                Do While Not rstTemp2.BOF
                    cDateTimeLast = rstTemp2.Fields("cdate_last").Value & " " & rstTemp2.Fields("ctime_last").Value
                    cTimeLast = rstTemp2.Fields("ctime_last").Value
                    Call WriteLog("-- ������ �������(1) (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    If cDateTimeLast = cDateTimeLastTemp Then GoTo next_i ' cDateTimeLast ����������, ��������� �� �����
                    ' ��������� � ������� � �������� ������� ������ ������ ������
                    Call WriteLog("-- ������ ������� (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    
                    Call FillArrCorrTotal(tblDataHistory) ' ����������� ������� � ����� �
                    Call FillTablesDataCurrent(1, cntBarsCalcCorr)
                    Call ChangeCDateTimeFirstToReal
                    Call WriteLog("-- ������ CountCorr_cn") ' ������� � (���� - ����������� ������� ntCorrResults (5000 ������������ �) -> ntCorrResultsReport (20 ����� � ������������ �))
                    Call CountCorr_cn
                    Call WriteLog("-- CountCorr_cn ���������")
                    Call CountAverageValues ' ������� ����� ���������� (���� - ����������� ������� ntAverageValuesResults (����� ����������))
                    
                    Call WriteLog("-- ����� ������� (cDateTimeFirst = [" & cDateTimeFirst & "], cDateTimeLast = [" & cDateTimeLast & "])")
                    
next_i:
                    rstTemp2.MovePrevious
                Loop
            End If
            rstTemp2.Close
        End If
        
        
    
        Call DefineParametersFromFileName ' ������ ����� �������� ���������� �� ����� �����
        Call FillArrCorrTotal(tblDataHistory) ' ����������� ������� � ����� �
        Call FillTablesDataCurrent(1, cntBarsCalcCorr)
        Call ChangeCDateTimeFirstToReal
        Call WriteLog("-- ������ CountCorr_cn") ' ������� � (���� - ����������� ������� ntCorrResults (5000 ������������ �) -> ntCorrResultsReport (20 ����� � ������������ �))
        Call CountCorr_cn
        Call WriteLog("-- CountCorr_cn ���������")
        Call CountAverageValues ' ������� ����� ���������� (���� - ����������� ������� ntAverageValuesResults (����� ����������))
    
    
    
    
    
    
        If IsCalcCalendar = 1 Then
            Call CalcCalendarIdnData ' �������� ������ �� �������� ���������
        End If
        
    
    
   
   
   
   End If
'----------------------------
   
   
   
    ' ��������� ������� tCorrResultsPeriodsData �� SQL Server (���� - ����������� ������� ntCorrResultsPeriodsData (20 �������� � ��������))
    SQLString = "exec " & pCorrResultsPeriodsData & " " & pCountCharts & "," & pbarsBefore & "," & pbarsTotal & "," & 10000 & ",'" & ParamsIdentifyer & "'" & "," & cntBarsCalcCorr
    Call ExecProcedureMSSQL(SQLString) ' �� ��������� �� DeltaMinutesCalcCorr, �.�. ��� �������� ������ ������ ������
    
    
    Call WriteLog("����� exec " & pCorrResultsPeriodsData)
    
    
    Call FillChartCurrent ' ��������� ������� � ������� ��������
    
    
    'Call CheckAlerts ' ��������� ������� ������
    
    
    If (is_makeDeals_RealTrade = 1) Then
        Call CheckAlerts_RealTrade
    End If
    
    
    
    
    
    ' ������� ������� ForexChartsHistoryData
    'If ((IsExportToExcel = 1) Or (IsOpenExcel = 1)) Then
    'If ((IsExportToExcelCurrent = 1) Or (IsExportToExcelHistory = 1) Or (IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
    If ((IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
        Call ClearDataFolder
        Call WriteLog("��������� ClearDataFolder ���������")
    End If
    
    
    'If ((IsExportToExcelCurrent = 1) Or (IsExportToExcelHistory = 1)) Then
    '    Call ExportToExcel
    'End If
    
    If ((IsExportToTxtCurrent = 1) Or (IsExportToTxtHistory = 1)) Then
        Call ExportToTxt
    End If
    
    
    
    
    
    'Call OpenExcel
    '��������� ���� � ���������, ������ ����� �� ��������
    Call ProcessExcelCharts
    
    
    
    ' �������� ������ ��������
    Beep
    
    
    
    
        TotalTime = GetTickCount - StartTime    '��������� ����������� �����
        'MsgBox "��������� �������: " & TotalTime & " ��", , ""
    
exitProc:
    
    '�������:
    
    ' -- 1 --
    '���������  -   ABV
    '���������� -   ��� DataSourceId = 2 (NT):   ABVMini
    '           -   ��� DataSourceId = 3 (Quik): ccntOpenPos (���������� �������� �������)
    ' -- 2 --
    '���������  -   CcorrMax real NULL, -- ������������ �������� �
    '���������� -   CcorrAvg real NULL, -- ������� �������� �
    '�������    -   TakeProfit_isOk_Daily_up_AvgCnt real NULL, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
    '�����      -   TakeProfit_isOk_Daily_down_AvgCnt real NULL, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
    ' -- 2_nd --
    '�������    -   TakeProfit_isOk_Daily_up_AvgCnt real NULL, -- ���-�� ������������ TakeProfit �� ����� ���������� ��� ����� (������� ��������)
    '�����      -   TakeProfit_isOk_Daily_down_AvgCnt real NULL, -- ���-�� ������������ TakeProfit �� ����� ���������� ��� ���� (������� ��������)
    
    ' -- 3 --
    '���������  -   TakeProfit_isOk_Daily_up_PrcBars real NULL, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
    '���������� -   TakeProfit_isOk_Daily_down_PrcBars real NULL, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
    '�������    -   TakeProfit_isOk_AtOnce_up_AvgCnt real NULL, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
    '�����      -   TakeProfit_isOk_AtOnce_down_AvgCnt real NULL, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
    ' -- 3_nd --
    '���������  -   TakeProfit_isOk_Daily_up_PrcBars real NULL, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���������� ���) (������� �������� �� ���� ���������)
    '���������� -   TakeProfit_isOk_Daily_down_PrcBars real NULL, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���������� ���) (������� �������� �� ���� ���������)
    '�������    -   TakeProfit_isOk_AtOnce_up_AvgCnt real NULL, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������) � ������ ���������� ���
    '�����      -   TakeProfit_isOk_AtOnce_down_AvgCnt real NULL, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������) � ������ ���������� ���
    
    ' -- 4 --
    '���������  -   ChighMax_Daily_Avg real NULL, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
    '���������� -   ClowMin_Daily_Avg real NULL, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
    '�������    -   ChighMax_AtOnce_Avg real NULL, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
    '�����      -   ClowMin_AtOnce_Avg real NULL, -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
    ' -- 4_nd --
    '���������  -   ChighMax_Daily_Avg real NULL, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ���������� ��� (���-�� �������)
    '���������� -   ClowMin_Daily_Avg real NULL, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ���������� ��� (���-�� �������)
    '�������    -   ChighMax_AtOnce_Avg real NULL, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������) � ������ ���������� ���
    '�����      -   ClowMin_AtOnce_Avg real NULL, -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������) � ������ ���������� ���
    
    ' -- 5 -- (������ ��� DataSourceId = 3 (Quik))
    '���������  -   countbuy -- ���������� ������ �� �������
    '���������� -   countsell -- ���������� ������ �� �������
    '�������    -   avgBuyOrder -- ������� ������ ������ �� ������� ( = ��������� ����� / ���������� ������ �� �������)
    '�����      -   avgSellOrder -- ������� ������ ������ �� ������� ( = ��������� ����������� / ���������� ������ �� �������)



End Sub



Sub CheckAlerts_RealTrade()

Dim strSubject As String

    'Dim SQLString As String
    
    'Call ExecProcedureMSSQL("exec ntp_rt_CheckAlerts @activation_ParamsIdentifyer = '" & ParamsIdentifyer & "'")
    
    Call ExecProcedureMSSQL_ntp_rt_CheckAlerts(ParamsIdentifyer)
    ' �������� AlertStrBody
    
    If AlertStrBody <> "" Then ' ���� ������ ���������
        'MsgBox AlertStrBody
        
        ' �������� email
        If isSendEmailOnAlert = 1 Then
            strSubject = ParamsIdentifyer & " " & CurrencyNTName_current & " " & cDateTimeLast
            'Call GenerateAlertStrBody(1)
            Call send_Email(strSubject, AlertStrBody)
        End If
        
        ' �������� SMS
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
    
    ' ��������� ������� ������
    Call WriteLog("������ �������� ������� ������")
    
    'Set rstTemp2 = DB.OpenRecordset(tblDataCurrentChartMSSQL, dbOpenDynaset, dbSeeChanges)
    SQLString = "             select * "
    SQLString = SQLString & " from  " & tblDataCurrentChartMSSQL
    SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
    SQLString = SQLString & " order by idn "
    
    Set rstTemp2 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    rstTemp2.MoveLast
    CountCurrentChartMSSQL = rstTemp2.RecordCount
    
    ' ���� � ��������� ������ ��� ������ ��� ��������, �� ������������ ������� ����� �� ��� ���, ���� �� ������ ��������� ��������
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
    
    ' ����� ����� ���������� � ������ ���������� ���
    TakeProfit_isOk_AtOnce_up_AvgCnt_nd = rstTemp2.Fields("TakeProfit_isOk_AtOnce_up_AvgCnt_nd").Value
    TakeProfit_isOk_AtOnce_down_AvgCnt_nd = rstTemp2.Fields("TakeProfit_isOk_AtOnce_down_AvgCnt_nd").Value
    ChighMax_AtOnce_Avg_nd = rstTemp2.Fields("ChighMax_AtOnce_Avg_nd").Value
    ClowMin_AtOnce_Avg_nd = rstTemp2.Fields("ClowMin_AtOnce_Avg_nd").Value
    
    rstTemp2.Close
    
     
    
    ' ���� ���� �� ���� ������� ���������, �� �������� �����
    'If (Abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt) >= TakeProfit_isOk_AtOnce_AvgCnt_delta_alert) _
    'Or (TakeProfit_isOk_AtOnce_up_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert Or TakeProfit_isOk_AtOnce_down_AvgCnt >= TakeProfit_isOk_AtOnce_AvgCnt_limit_alert) _
    'Or (Abs(ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) >= CPoints_AtOnce_Avg_delta_alert) _
    'Or (ChighMax_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert Or ClowMin_AtOnce_Avg >= CPoints_AtOnce_Avg_limit_alert) Then
    ' ���� ��� ������� ���������, �� �������� �����
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
        'Call WriteLog("������ �����")
        
        ' �������� email
        If isSendEmailOnAlert = 1 Then
            strSubject = ParamsIdentifyer & " " & CurrencyNTName_current & " " & cDateTimeLast
            Call GenerateAlertStrBody(1)
            Call send_Email(strSubject, AlertStrBody)
        End If
        
        ' �������� SMS
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
        
    Call WriteLog("�������� ������� ������ ���������")


End Sub


Sub GenerateAlertStrBody(idDestination As Integer)
' ���������� ����� ���������
' idDestination: 1 - ��������� �� email, 2 - ��������� �� sms

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
            
            
            
            ' ������� ����� ���������� � ������ ���������� ���
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
' ������ �������� ������� ArrName � ���� TableColName ������� TableName

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
' ������ �������� ���������� ������� ArrName � ���� TableColName1 � TableColName2 ������� TableName

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
' ������ �������� �������� ArrName1 � ArrName2 � ���� TableColName1 � TableColName2 ������� TableName
' ����� cntRows � ����� �������

Dim i As Long
Dim cntRowsTotal As Long

cntRowsTotal = UBound(ArrName1) + 1 ' ���-�� ����� � �������

If cntrows = 0 Then
  cntrows = cntRowsTotal
End If

Set rstTemp = DB.OpenRecordset(TableName, dbOpenDynaset, dbSeeChanges)
For i = 1 To cntrows
  rstTemp.AddNew
  
  If SortBack = 0 Then  ' 0 - ���������� � � ������ �������
    rstTemp(TableColName1) = ArrName1(cntRowsTotal - i)
    rstTemp(TableColName2) = ArrName2(cntRowsTotal - i)
  End If
  If SortBack = 1 Then  ' 1 - ���������� � � �������� �������
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

' ������� �������
Dim sql As String
sql = "delete from " & TableName
DB.Execute sql

End Sub

Sub ClearTableMSSQL(TableName As String)


' ������� �������
Dim sql As String
sql = "delete from " & TableName

 DB.Execute sql, dbSeeChanges + dbFailOnError

End Sub













Function Evalu(ByVal S As String) As String
Evalu = Evaluate(S)
End Function







