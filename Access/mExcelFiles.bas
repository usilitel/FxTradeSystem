Attribute VB_Name = "mExcelFiles"
Option Explicit

Sub ExportSQLToText(SQLString As String, ExportFileName As String, Optional delim As String, Optional FileMode As Integer, Optional cntInserts As Integer)
' FileMode: 0 - ������� ���� ��� ������, 1 - ������� ���� ��� ����������
' cntInserts: ������� ��� ������ ������
    Dim f, rst As Object
    Dim strTmp As String
    Dim i As Long
    
    
    Set rst = CreateObject("ADODB.recordset")
    'Debug.Print (SQLString)
    
    
    i = 0
str1:
    i = i + 1 ' ����������� ������� ������
    
    On Error GoTo -1 ' ���������� ������� ������������ ������
    On Error GoTo str1
    
    If i > 100 Then ' ���������� ���������� ������
        On Error GoTo 0 ' ��������� ���������� ������
    End If
    
    rst.Open SQLString, CurrentProject.Connection ' � ���� ������ ����� ���������� ������
    
    
    
    
    On Error GoTo errend
    f = FreeFile
    If IsMissing(delim) Or Len(delim & "") = 0 Then delim = ","
    If IsMissing(FileMode) Then FileMode = 0
    If IsMissing(cntInserts) Then cntInserts = 1
    
    If FileMode = 0 Then
        Open ExportFileName For Output As #f
    End If
    If FileMode = 1 Then
        Open ExportFileName For Append As #f
    End If

    'strTmp = rst.GetString(, , delim, vbCrLf)
    strTmp = rst.GetString(, , delim)
    
    For i = 1 To cntInserts
        Print #f, strTmp
    Next i
    
errNo:
    Close #f
    rst.Close
    Set rst = Nothing
    Exit Sub
errend:
    Select Case Err.Number
        Case 76 '�������� ����
            MsgBox "�������� ����" & vbCrLf _
            & "������ �� ����� ��������. ��������� ���� � ����� ������"
            Resume errNo
        Case Else
            MsgBox "������: " & Err & " " & Err.Description & vbCrLf _
            & "������ �� ����� ��������"
            Resume errNo
    End Select
 
End Sub








Sub ExportToTxt()
' ��������� ������������ �������������� ������ � ��������� �����
' ������� tCorrResultsPeriodsData �� SQL Server ������ ���� ��� ���������

Dim i As Long
Dim idnFirst As Long
Dim idnLast As Long
Dim SQLString As String
Dim rstTemp03 As DAO.Recordset
Dim cntDataCurrentChart As Long


' ������� ������� ForexChartsHistoryData
'Shell "cmd /c rd /S/Q " & CurrPathAccess & "\ForexChartsHistoryData"
' ������� ������� ForexChartsHistoryData
'MkDir (CurrPathAccess & "\ForexChartsHistoryData")

'strExcelFileExport = CurrPathAccess + "\ForexChartsHistoryData.xls"

' ������������ ������ � Excel
'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport




' ��������� ������ ������ ������ � ��������� ������� � ������������� ���������
Call ClearTable("ntCorrResultsPeriodsDataLocal_DataChart")

' ���������� ������� (��������� ���� idn ����� ���������� � 1)
SQLString = "ALTER TABLE ntCorrResultsPeriodsDataLocal_DataChart  ALTER COLUMN idn counter(1,1) "
DoCmd.RunSQL SQLString

SQLString = "insert into ntCorrResultsPeriodsDataLocal_DataChart (idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, BSV, BSVMini) "
SQLString = SQLString & " select idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, BSV, BSVMini "
SQLString = SQLString & " from ntCorrResultsPeriodsData_DataChart "
SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
SQLString = SQLString & " order by idn "
DoCmd.RunSQL SQLString
' ������ � ������� ntCorrResultsPeriodsDataLocal_DataChart ������ ��� ������������ ������ ��� ��������



' ��������� ������ ������ ������ � ��������� ������� � ������������� ���������
Call ClearTable("ntCorrResultsPeriodsDataLocal_DataTotal")

' ���������� ������� (��������� ���� idn ����� ���������� � 1)
SQLString = "ALTER TABLE ntCorrResultsPeriodsDataLocal_DataTotal  ALTER COLUMN idn counter(1,1) "
DoCmd.RunSQL SQLString

SQLString = "insert into ntCorrResultsPeriodsDataLocal_DataTotal (cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced) "
SQLString = SQLString & " select cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced "
SQLString = SQLString & " from ntCorrResultsPeriodsData_DataTotal "
SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
SQLString = SQLString & " order by idn "
DoCmd.RunSQL SQLString
' ������ � ������� ntCorrResultsPeriodsDataLocal_DataTotal ������ ��� ������������ ������ ��� ��������


' SQLString = "insert into ntCorrResultsPeriodsDataLocal (idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, ParamsIdentifyer) "








' ������������ ������������ ������
If (IsExportToTxtHistory = 1) Then
    For i = 1 To pCountCharts
            strTxtFileExport = CurrPathAccess + "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & i & ".txt"
            'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport
            
            idnFirst = (pbarsTotal * (i - 1)) + 1
            idnLast = idnFirst + pbarsTotal - 1
            
            
            'If ((DataSourceId = 1) Or (IsInverse = 0)) Then
            '    SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, nz(ABMmPosition0,0), nz(ABMmPosition1,0) " & _
            '                " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
            '                " ORDER BY idn "
            'End If
            
           ' If (((DataSourceId = 2) Or (DataSourceId = 3)) And (IsInverse = 1)) Then
           '     SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, Volume, -ABV, -ABVMini, nz(-ABMmPosition0,0), nz(-ABMmPosition1,0) " & _
           '                 " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
           '                 " ORDER BY idn "
           ' End If
            
            
            If ((DataSourceId = 2) And (IsInverse = 0)) Then
                SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, 0 as ABMmPosition0, 0 as ABMmPosition1, nz(BSV,0), nz(BSVMini,0) " & _
                            " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
                            " ORDER BY idn "
            End If
            
            If ((DataSourceId = 2) And (IsInverse = 1)) Then
                SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, Volume, -ABV, -ABVMini, 0 as ABMmPosition0, 0 as ABMmPosition1 " & _
                            " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
                            " ORDER BY idn "
            End If
            
            
            
            If ((DataSourceId = 3) And (IsInverse = 0)) Then
                SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, nz(ABMmPosition0,0), nz(ABMmPosition1,0) " & _
                            " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
                            " ORDER BY idn "
            End If
            
            If ((DataSourceId = 3) And (IsInverse = 1)) Then
                SQLString = " SELECT idn, idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, Volume, -ABV, -ABVMini, nz(-ABMmPosition0,0), nz(-ABMmPosition1,0) " & _
                            " FROM [ntCorrResultsPeriodsDataLocal_DataChart] where idn >= " & idnFirst & " and idn <= " & idnLast & _
                            " ORDER BY idn "
            End If
            
            
            
            
            
            
            
            
            'Debug.Print (SQLString)
            
            
            Call ExportSQLToText(SQLString, strTxtFileExport, ";", 0, 1)
            
            
            ' ������������ ����� ����������
            strTxtFileExport = CurrPathAccess + "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryDataTotal" & i & ".txt"
                
            SQLString = " SELECT cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced " & _
                        " FROM [ntCorrResultsPeriodsDataLocal_DataTotal] where idn = " & i
    
            Call ExportSQLToText(SQLString, strTxtFileExport, ";", 0, 1)
    
    Next i
End If



' ������������ ������� ������
If (IsExportToTxtCurrent = 1) Then
    strTxtFileExport = CurrPathAccess + "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & i & ".txt"
    'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport

    If DataSourceId = 1 Then
        SQLString = "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       " 0 as Volume, 0 as ABV, 0 as ABVMini, 0 as ABMmPosition0, 0 as ABMmPosition1 " & _
                       " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
    If ((DataSourceId = 2) And (IsInverse = 0)) Then
      SQLString = "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       "  nz(Volume,0), nz(ABV,0), nz(ABVMini,0), nz(ABMmPosition0,0), nz(ABMmPosition1,0), " & _
                       "  nz(CcorrMax,0), nz(CcorrAvg,0),  " & _
                       "  nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(ClowMin_AtOnce_Avg,0), " & _
                       "  nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(BSV,0), nz(BSVMini,0) " & _
                       " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
'                       "  Mid(cdate,9,2) & '.' & Mid(cdate,6,2) & '.' & Mid(cdate,1,4) & ' ' & ctime " ' dd.mm.yyyy hh:mi

    If ((DataSourceId = 3) And (IsInverse = 0)) Then
      SQLString = "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       "  nz(Volume,0), nz(ABV,0), nz(ccntOpenPos,0), nz(countbuy,0), nz(countsell,0), " & _
                       "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                       "  nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(avgBuyOrder,0), nz(avgSellOrder,0), nz(ccntOpenPos,0) as ccntOpenPos2, " & _
                       "  nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0) " & _
                       " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
    If ((DataSourceId = 2) And (IsInverse = 1)) Then
      SQLString = "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, " & _
                       "  nz(Volume,0), nz(-ABV,0), nz(-ABVMini,0), nz(-ABMmPosition0,0), nz(-ABMmPosition1,0), " & _
                       "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                       "  nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(ChighMax_AtOnce_Avg,0), " & _
                       "  nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0) " & _
                       " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    If ((DataSourceId = 3) And (IsInverse = 1)) Then
      SQLString = "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, " & _
                       "  nz(Volume,0), nz(-ABV,0), nz(-ccntOpenPos,0) as ccntOpenPos, nz(-countbuy,0), nz(-countsell,0), " & _
                       "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                       "  nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(avgSellOrder,0), nz(avgBuyOrder,0), nz(ccntOpenPos,0), " & _
                       "  nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0) " & _
                       " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
    Call ExportSQLToText(SQLString, strTxtFileExport, ";", 0, 1)
    
    
    
    ' ������� ���������� ����� � ����� � �������� �������
    Set rstTemp03 = DB.OpenRecordset(SQLString, dbOpenDynaset, dbSeeChanges)
    rstTemp03.MoveLast
    cntDataCurrentChart = rstTemp03.RecordCount
    rstTemp03.Close
      
      
      
      
    ' ������������ ���� � �������� ������� (����� ��������� ������ (pbarsTotal - cntDataCurrentChart) ���)
    If (pbarsTotal - cntDataCurrentChart) > 0 Then
        If DataSourceId = 1 Then
            SQLString = "SELECT top 1 idn, 0 as idnData, cdate, ctime, cdatetime, cclose, cclose, cclose, cclose, " & _
                           " 0 as Volume, 0 as ABV, 0 as ABVMini, 0 as ABMmPosition0, 0 as ABMmPosition1 " & _
                           " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn desc"
        End If
        
        If ((DataSourceId = 2) And (IsInverse = 0)) Then
          SQLString = "SELECT top 1 idn, 0 as idnData, cdate, ctime, cdatetime, cclose, cclose, cclose, cclose, " & _
                           " Volume, ABV, ABVMini, nz(ABMmPosition0,0), nz(ABMmPosition1,0), " & _
                           " nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                           " nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(ClowMin_AtOnce_Avg,0), " & _
                           " nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(BSV,0), nz(BSVMini,0) " & _
                           " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn desc"
        End If
        If ((DataSourceId = 3) And (IsInverse = 0)) Then
          SQLString = "SELECT top 1 idn, 0 as idnData, cdate, ctime, cdatetime, cclose, cclose, cclose, cclose, " & _
                           "  nz(Volume,0), nz(ABV,0), nz(ccntOpenPos,0), nz(countbuy,0), nz(countsell,0), " & _
                           "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                           "  nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(avgBuyOrder,0), nz(avgSellOrder,0), nz(ccntOpenPos,0) as ccntOpenPos2, " & _
                           "  nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0) " & _
                           " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn desc"
        End If
        
        If ((DataSourceId = 2) And (IsInverse = 1)) Then
          SQLString = "SELECT top 1 idn, 0 as idnData, cdate, ctime, cdatetime, -cclose, -cclose, -cclose, -cclose, " & _
                           " Volume, -ABV, -ABVMini, -ABMmPosition0, -ABMmPosition1, " & _
                           "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                           "  nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(ChighMax_AtOnce_Avg,0), " & _
                           "  nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0) " & _
                           " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn desc"
        End If
        If ((DataSourceId = 3) And (IsInverse = 1)) Then
          SQLString = "SELECT top 1 idn, 0 as idnData, cdate, ctime, cdatetime, -cclose, -cclose, -cclose, -cclose, " & _
                           "  nz(Volume,0), nz(-ABV,0), nz(-ccntOpenPos,0) as ccntOpenPos, nz(-countbuy,0), nz(-countsell,0), " & _
                           "  nz(CcorrMax,0), nz(CcorrAvg,0), " & _
                           "  nz(TakeProfit_isOk_Daily_down_AvgCnt,0), nz(TakeProfit_isOk_Daily_up_AvgCnt,0), nz(TakeProfit_isOk_Daily_down_PrcBars,0), nz(TakeProfit_isOk_Daily_up_PrcBars,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt,0), nz(ClowMin_Daily_Avg,0), nz(ChighMax_Daily_Avg,0), nz(ClowMin_AtOnce_Avg,0), nz(ChighMax_AtOnce_Avg,0), nz(avgSellOrder,0), nz(avgBuyOrder,0), nz(ccntOpenPos,0), " & _
                           "  nz(TakeProfit_isOk_Daily_down_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_up_AvgCnt_nd,0), nz(TakeProfit_isOk_Daily_down_PrcBars_nd,0), nz(TakeProfit_isOk_Daily_up_PrcBars_nd,0), nz(TakeProfit_isOk_AtOnce_down_AvgCnt_nd,0), nz(TakeProfit_isOk_AtOnce_up_AvgCnt_nd,0), nz(ClowMin_Daily_Avg_nd,0), nz(ChighMax_Daily_Avg_nd,0), nz(ClowMin_AtOnce_Avg_nd,0), nz(ChighMax_AtOnce_Avg_nd,0) " & _
                           " FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn desc"
        End If
        
        Call ExportSQLToText(SQLString, strTxtFileExport, ";", 1, (pbarsTotal - cntDataCurrentChart))
    End If
    
    

End If



Call WriteLog("����� �������� � txt")

End Sub

Sub OpenExcel_old_delete()
' ��������� ���� � ���������, ������ ����� �� ��������
' If ((IsOpenExcelCurrent = 1) Or (IsOpenExcelHistory = 1)) Then
    
    Dim objExcel As Object
    
    CurrPathAccess = CurrentProject.Path
    
    ExcelFileNameHistory = "ForexChartsHistory" & pbarsTotal & ".xls"
    ExcelFileNameCurrent = "ForexChartsCurrent" & pbarsTotal & ".xls"

' ��������� ���� � ������� ��������
If (IsOpenExcelCurrent = 1) Then
    Set objExcel = CreateObject("Excel.application")
    objExcel.Workbooks.Open FileName:=CurrPathAccess + "\" + ExcelFileNameCurrent, UpdateLinks:=3 '0
    Call WriteLog(ExcelFileNameCurrent & " ������")
    'objExcel.Run "'C:\Users\max\AppData\Roaming\Microsoft\Excel\XLSTART\PERSONAL.XLS'!ChangeScalesAllFiles" ', oSheet
    objExcel.Run "ChangeScalesAllFiles" ', oSheet
    Call WriteLog(ExcelFileNameCurrent & ".ChangeScalesAllFiles ��������")
    objExcel.Visible = True '���������
    Set objExcel = Nothing
    Call WriteLog(ExcelFileNameCurrent & " ������ � �����������")
End If
    
' ��������� ���� � ������������� ���������
If (IsOpenExcelHistory = 1) Then
    Set objExcel = CreateObject("Excel.application")
    objExcel.Workbooks.Open FileName:=CurrPathAccess + "\" + ExcelFileNameHistory, UpdateLinks:=3 '0
    Call WriteLog(ExcelFileNameHistory & " ������")
    'objExcel.Run "'C:\Users\max\AppData\Roaming\Microsoft\Excel\XLSTART\PERSONAL.XLS'!ChangeScalesAllFiles" ', oSheet
    objExcel.Run "ChangeScalesAllFiles" ', oSheet
    Call WriteLog(ExcelFileNameHistory & ".ChangeScalesAllFiles ��������")
    objExcel.Visible = True '���������
    Set objExcel = Nothing
    Call WriteLog(ExcelFileNameHistory & " ������ � �����������")
End If


End Sub


Public Function IsWorkBookOpen(wbPath As String) As Boolean
'
On Error Resume Next

Open wbPath For Input Lock Read As #1
Close #1
IsWorkBookOpen = Err.Number <> 0

End Function


Sub ProcessExcelCharts()

'Set DB = Access.CurrentDb
'IsOpenExcelCurrent = 1
'IsOpenExcelHistory = 1
'pbarsTotal = 1400
    
    'CurrPathAccess = CurrentProject.Path
    ExcelFileNameCurrent = CurrPathAccess & "\ForexChartsCurrent_" & ParamsIdentifyer & ".xls"
    ExcelFileNameHistory = CurrPathAccess & "\ForexChartsHistory_" & ParamsIdentifyer & ".xls"
    
    If (IsOpenExcelCurrent = 1) Then
        Call OpenUpdateExcelChart(ExcelFileNameCurrent)
    End If

    If (IsOpenExcelHistory = 1) Then
        Call OpenUpdateExcelChart(ExcelFileNameHistory)
    End If

End Sub


Sub OpenExcelChart(wbPath As String)

Dim objExcel As Object

        Set objExcel = CreateObject("Excel.application")
        objExcel.Workbooks.Open FileName:=wbPath, UpdateLinks:=3 '0
        Call WriteLog(wbPath & " ������")
        
        objExcel.Run "ChangeScalesAllFiles", pExcelWindowState ', oSheet
        objExcel.Visible = True '���������
        
        Call WriteLog(wbPath & ".ChangeScalesAllFiles ��������")
        'objExcel.WindowState = xlMaximized
        'objExcel.WindowState = xlMinimized
        'objExcel.ActiveWindow.WindowState = xlMaximized
        Set objExcel = Nothing
        Call WriteLog(wbPath & " ������ � �����������")

End Sub

Sub OpenUpdateExcelChart(wbPath As String)
' ���������/��������� ������ Excel
    
    Dim objExcel As Object
    'Dim str1 As String
    Dim i As Integer
    Dim ActiveWorkbookName As String
    Dim DataFileName As String
    
    If IsWorkBookOpen(wbPath) = False Then
        ' ���� �� ������, ���������, ��������� ������ � ������ ����� ��������
        Call OpenExcelChart(wbPath)
    Else
        ' ���� ��� ������, ��������� � ��������� � ����������� ������
        Set objExcel = GetObject(wbPath).Application
        objExcel.ActiveWorkbook.Close savechanges:=False
        objExcel.Quit
        Set objExcel = Nothing
        Call OpenExcelChart(wbPath)
    
        ' ���� ��� ������, ��������� ������ � ������ ����� ��������
        '   str1 = objExcel.ActiveWorkbook.Name
        '   objExcel.ActiveWorkbook.UpdateLink Name:=CurrPathAccess & "\ForexChartsHistoryData\ForexChartsHistoryData41.xls", Type:=xlExcelLinks
        '   objExcel.ActiveWorkbook.UpdateLink (objExcel.ActiveWorkbook.LinkSources(xlOLELinks))
        
        ' ��������� ����� � ��������� ����� ������ (����� �� ������ ��������)
        'If InStr(1, objExcel.ActiveWorkbook.Name, "Current", vbTextCompare) > 0 Then
        '    objExcel.ActiveWorkbook.UpdateLink Name:=CurrPathAccess & "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & pCountCharts + 1 & ".xls", Type:=xlExcelLinks
        'Else
            '   objExcel.ActiveWorkbook.UpdateLink (objExcel.ActiveWorkbook.LinkSources(xlOLELinks))
        '    For i = 1 To objExcel.ActiveWorkbook.Sheets.Count
        '        ActiveWorkbookName = objExcel.ActiveWorkbook.Name
        '        DataFileName = CurrPathAccess & "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & i & ".xls"
        '        objExcel.ActiveWorkbook.UpdateLink Name:=DataFileName, Type:=xlExcelLinks
        '    Next i
        'End If
        
        'Call WriteLog(wbPath & ": ������ ���������")
        'objExcel.Run "ChangeScalesAllFiles" ', oSheet
        'Call WriteLog(wbPath & ".ChangeScalesAllFiles ��������")
        'Set objExcel = Nothing
    End If

End Sub

Sub ExportToExcel()
' ��������� ������������ �������������� ������ � Excel
' ������� tCorrResultsPeriodsData �� SQL Server ������ ���� ��� ���������

Dim i As Long
Dim idnFirst As Long
Dim idnLast As Long
Dim SQLString As String

' ������� ������� ForexChartsHistoryData
'Shell "cmd /c rd /S/Q " & CurrPathAccess & "\ForexChartsHistoryData"
' ������� ������� ForexChartsHistoryData
'MkDir (CurrPathAccess & "\ForexChartsHistoryData")

'strExcelFileExport = CurrPathAccess + "\ForexChartsHistoryData.xls"

' ������������ ������ � Excel
'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport




' ��������� ������ ������ ������ � ��������� ������� � ������������� ���������
Call ClearTable("ntCorrResultsPeriodsDataLocal")

' ���������� ������� (��������� ���� idn ����� ���������� � 1)
SQLString = "ALTER TABLE ntCorrResultsPeriodsDataLocal  ALTER COLUMN idn counter(1,1) "
DoCmd.RunSQL SQLString

SQLString = "insert into ntCorrResultsPeriodsDataLocal (idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, ParamsIdentifyer) "
SQLString = SQLString & " select idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, ParamsIdentifyer "
SQLString = SQLString & " from ntCorrResultsPeriodsData "
SQLString = SQLString & " where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
SQLString = SQLString & " order by idn "
DoCmd.RunSQL SQLString
' ������ � ������� ntCorrResultsPeriodsDataLocal ������ ��� ������������ ������ ��� ��������



' ������������ ������������ ������
For i = 1 To pCountCharts
    If (IsExportToExcelHistory = 1) Then
            strExcelFileExport = CurrPathAccess + "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & i & ".xls"
            'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport
            
            idnFirst = (pbarsTotal * (i - 1)) + 1
            idnLast = idnFirst + pbarsTotal - 1
            
            If ((DataSourceId = 1) Or (IsInverse = 0)) Then
              DB.Execute " SELECT idn, idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1 " & _
                         " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "]" & _
                         " FROM [ntCorrResultsPeriodsDataLocal] where idn >= " & idnFirst & " and idn <= " & idnLast
            End If
            
            If (((DataSourceId = 2) Or (DataSourceId = 3)) And (IsInverse = 1)) Then
              DB.Execute " SELECT idn, idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, ccorrResult, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, -ABV, -ABVMini, -ABMmPosition0, -ABMmPosition1 " & _
                         " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "]" & _
                         " FROM [ntCorrResultsPeriodsDataLocal] where idn >= " & idnFirst & " and idn <= " & idnLast
            End If
        
    End If
Next i



' ������������ ������� ������
If (IsExportToExcelCurrent = 1) Then
    strExcelFileExport = CurrPathAccess + "\ForexChartsHistoryData_" & ParamsIdentifyer & "\ForexChartsHistoryData" & i & ".xls"
    'If Dir(strExcelFileExport) <> "" Then Kill strExcelFileExport

    If DataSourceId = 1 Then
      DB.Execute "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       " 0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, 0 as Volume, 0 as ABV, 0 as ABVMini, 0 as ABMmPosition0, 0 as ABMmPosition1 " & _
                       " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "] FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
    If ((DataSourceId = 2) And (IsInverse = 0)) Then
      DB.Execute "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       " 0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, " & _
                       " CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg " & _
                       " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "] FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    If ((DataSourceId = 3) And (IsInverse = 0)) Then
      DB.Execute "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, copen, chigh, clow, cclose, " & _
                       " 0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, Volume, ABV, ccntOpenPos, countbuy, countsell, " & _
                       " CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, avgBuyOrder, avgSellOrder, ccntOpenPos as ccntOpenPos2 " & _
                       " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "] FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    
    If ((DataSourceId = 2) And (IsInverse = 1)) Then
      DB.Execute "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, " & _
                       " 0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, Volume, -ABV, -ABVMini, -ABMmPosition0, -ABMmPosition1, " & _
                       " CcorrMax, CcorrAvg, -TakeProfit_isOk_Daily_up_AvgCnt, -TakeProfit_isOk_Daily_down_AvgCnt, -TakeProfit_isOk_Daily_up_PrcBars, -TakeProfit_isOk_Daily_down_PrcBars, -TakeProfit_isOk_AtOnce_up_AvgCnt, -TakeProfit_isOk_AtOnce_down_AvgCnt, -ChighMax_Daily_Avg, -ClowMin_Daily_Avg, -ChighMax_AtOnce_Avg, -ClowMin_AtOnce_Avg " & _
                       " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "] FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    If ((DataSourceId = 3) And (IsInverse = 1)) Then
      DB.Execute "SELECT idn, 0 as idnData, cdate, ctime, cdatetime, -copen, -chigh, -clow, -cclose, " & _
                       " 0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, Volume, -ABV, -ccntOpenPos as ccntOpenPos, -countbuy, -countsell, " & _
                       " CcorrMax, CcorrAvg, -TakeProfit_isOk_Daily_up_AvgCnt, -TakeProfit_isOk_Daily_down_AvgCnt, -TakeProfit_isOk_Daily_up_PrcBars, -TakeProfit_isOk_Daily_down_PrcBars, -TakeProfit_isOk_AtOnce_up_AvgCnt, -TakeProfit_isOk_AtOnce_down_AvgCnt, -ChighMax_Daily_Avg, -ClowMin_Daily_Avg, -ChighMax_AtOnce_Avg, -ClowMin_AtOnce_Avg, -avgBuyOrder, -avgSellOrder, ccntOpenPos " & _
                       " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 1 & "] FROM [" & tblDataCurrentChartMSSQL & "] where ParamsIdentifyer = '" & ParamsIdentifyer & "' order by idn"
    End If
    '                   " INTO [Excel 8.0;DATABASE=" & strExcelFileExport & "].[����" & 100 & "] FROM [" & tblDataCurrentChart & "] order by idn"
End If



Call WriteLog("����� �������� � Excel")

End Sub




Sub CloseExcel_old_delete()
' ��������� �������� Excel
Dim objExcel As Excel.Application 'Object
    On Error GoTo ErrorHandler
    Call WriteLog("--1-- (CloseExcel)")
    Set objExcel = GetObject(, "Excel.Application")
    'MsgBox objExcel.ActiveWorkbook.Name
    'MsgBox objExcel.Workbooks.Count
    Call WriteLog("--" & objExcel.ActiveWorkbook.Name & "--")

    If (Left(objExcel.ActiveWorkbook.Name, 11) = "ForexCharts") Then
        objExcel.ActiveWorkbook.Close savechanges:=False
        objExcel.Quit
    End If
    
    'MsgBox objExcel.ActiveWorkbook.Name
    
ErrorHandler:
    Set objExcel = Nothing
    'MsgBox 1
End Sub








Sub ClearDataFolder()
' ������� ������� ForexChartsHistoryData

Dim FolderPath As String
Dim ������������������ As Long
Dim FSO
Dim sFileName As String, sNewFileName As String

    CurrPathAccess = CurrentProject.Path
    FolderPath = CurrPathAccess & "\ForexChartsHistoryDataOld\"
    
    ' ������� ������� ForexChartsHistoryDataOld
    If Dir(FolderPath, vbDirectory) = "" Then '��������� ���� �� ����� "ForexChartsHistoryDataOld"
       MkDir (FolderPath)
    End If
    
' ��������� ���������� ��������
    Set FSO = CreateObject("Scripting.FileSystemObject")
'    �������������������������������������� = FSO.GetFolder(FolderPath).Files.Count
    ������������������ = FSO.GetFolder(FolderPath).SubFolders.Count
    

' ��������������� � ���������� ������� � �������
    sFileName = CurrPathAccess & "\ForexChartsHistoryData_" & ParamsIdentifyer & "\"    '��� ��������� �����
    sNewFileName = CurrPathAccess & "\ForexChartsHistoryDataOld\ForexChartsHistoryData_" & ParamsIdentifyer & "_" & ������������������ & "\"    '��� ����� ��� �����������. ����������(� ������ ������ ���� D) ������ ������������
    If Dir(sFileName, 16) = "" Then GoTo MakeDirHistoryData 'MsgBox "��� ������ �����", vbCritical, "������" ': Exit Sub
 
    Name sFileName As sNewFileName '���������� ����
    'MsgBox "���� ���������", vbInformation, "www.excel-vba.ru"
    
    
    
' ������� ������� ForexChartsHistoryDataOld
MakeDirHistoryData:
    MkDir (sFileName)

    

End Sub



