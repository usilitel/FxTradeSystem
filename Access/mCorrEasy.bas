Attribute VB_Name = "mCorrEasy"
'Option Compare Database
Option Explicit



Public Sub CorrelationEasyPrepare(ByRef arrCurrentCompare() As Double, ByRef arrCurrentCompareRanges() As Double)
' ��������������� ������ ����������� ��� ����������� ������� �Easy
' ��������� ���������� � ������� arrCurrentCompare � ��������� �� � ������ arrCurrentCompareRanges
  
Dim i As Long
Dim SQLString As String


' ��������� ����������� � ������������ cclose �� ������� ������
vCcloseMin = fMinValue(arrCurrentCompare)
vCcloseMax = fMaxValue(arrCurrentCompare)

' ��������� ������ arrDataCurrentCompareEasyRanges (������ �� ���������� ���������� �� ������� ������)
For i = 1 To cntDataCurrentRows
  arrCurrentCompareRanges(i - 1) = (arrCurrentCompare(i - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
Next i


' �������� (������ ������� � �������)
'Call ClearTable("_test1")
'Application.SetOption "Confirm Action Queries", False
'For i = 1 To cntDataCurrentRows
'  arrDataCurrentCompareEasyRanges(i - 1) = (arrDataCurrentCompare(i - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
'  SQLString = "insert into _test1(cdate, ctime, cclose, crange) select """ & arrDataCurrentAll(1, i - 1) & """, """ & arrDataCurrentAll(2, i - 1) & """, """ & arrDataCurrentCompare(i - 1) & """, """ & arrDataCurrentCompareEasyRanges(i - 1) & """"
'  DoCmd.RunSQL SQLString
'Next i

End Sub




'Call CalcCorrelationEasy(arrDataHistoryCompareEasy, arrDataHistoryCompareEasyRanges, arrDataCurrentCompareEasy, arrDataCurrentCompareEasyRanges, arrCORREasy, arrCclose)


Sub CalcCorrelationEasy(ByRef arrHistoryCompare() As Double, ByRef arrHistoryCompareRanges() As Double, ByRef arrCurrentCompare() As Double, ByRef arrCurrentCompareRanges() As Double, arrCorrelationValues() As Variant, arrHistoryAll() As Variant)
' ������ �Easy:
' ������� ���� �� ������� arrHistoryAll � ������� �Easy � �������� arrCurrentCompareRanges


'�������� ����������:
'arrHistoryCompare() - ������-���� � ������������� ������� (�������������� � ���������)
'arrHistoryCompareRanges() - ������-���� � ������������� ������� �� ����������� (�� ������� ������� �) (�������������� � ���������)
'arrCurrentCompare() - ������ � �������� ������� (������ ���� ��������)
'arrCurrentCompareRanges() - ������ � �������� ������� �� ����������� (�� ������� ������� �) (�������������� � ���������)
'arrCorrelationValues() - ������, � ������� ���������� ������������ �������� � (�������������� � ���������)
'arrHistoryAll() - ������ �� ����� ������������� ������� (�� ���� ������� ������-����) (������ ���� ��������)



Dim SQLString As String
Dim i As Long
Dim j As Long

Call WriteLog("--1--")

' ��������������� ������ �����������
Call CorrelationEasyPrepare(arrCurrentCompare(), arrCurrentCompareRanges())

Call WriteLog("--2--")

For i = 1 To (cntDataCurrentRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i

' ������� �Easy ��� ������� ��������
For i = 1 To 1 ' ���� �� ������� �������
  For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
  Next j
  
  ' ��������� ���������� � ������� arrHistoryCompare � ��������� �� � ������ arrHistoryCompareRanges:
  ' ��������� ����������� � ������������ cclose � ����
  vCcloseMin = fMinValue(arrHistoryCompare)
  vCcloseMax = fMaxValue(arrHistoryCompare)
  ' ��������� ������ arrHistoryCompareRanges (������ �� ���������� ���������� �� ������������ ������)
  For j = 1 To cntDataCurrentRows
    If vCcloseMax = vCcloseMin Then
      arrHistoryCompareRanges(j - 1) = 0
    Else
      arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
    End If
  Next j
  
  arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)

'------------------------
        'SQLString = "insert into ttemp(idn, f1) values(" & arrABVIDN(i - 1) & "," & Replace(arrCorrelationValues(i - 1), ",", ".") & ")"
        'DoCmd.RunSQL SQLString
'------------------------

Next i

Call WriteLog("--3--")



' ������� �Easy ��� ���� �����
If IsCalcCorrOnlyForSameTime_cn = 0 Then

    For i = 2 To (cntDataHistoryRows - cntDataCurrentRows + 1) ' ���� �� ������� �������
      For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
        arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
      Next j
      
      ' ��������� ���������� � ������� arrHistoryCompare � ��������� �� � ������ arrHistoryCompareRanges:
      ' ��������� �����������/������������ cclose � ����:
      If arrHistoryAll(i - 2) = vCcloseMin Then ' ���� ��������� ������� ������� ��� �����������, �� ������������� ����������� �������
        vCcloseMin = fMinValue(arrHistoryCompare)
      End If
      
      If arrHistoryAll(i - 2) = vCcloseMax Then ' ���� ��������� ������� ������� ��� ������������, �� ������������� ������������ �������
        vCcloseMax = fMaxValue(arrHistoryCompare)
      End If
      
      If arrHistoryCompare(j - 2) < vCcloseMin Then ' ���� ����� ������� ������� ������ ������������, �� ��������� ����������� �������
        vCcloseMin = arrHistoryCompare(j - 2)
      End If
      
      If arrHistoryCompare(j - 2) > vCcloseMax Then ' ���� ����� ������� ������� ������ �������������, �� ��������� ������������ �������
        vCcloseMax = arrHistoryCompare(j - 2)
      End If
    
      ' ��������� ������ arrHistoryCompareRanges (������ �� ���������� ���������� �� ������������ ������)
      For j = 1 To cntDataCurrentRows
        If vCcloseMax = vCcloseMin Then
          arrHistoryCompareRanges(j - 1) = 0
        Else
          arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
        End If
      Next j
      
      arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
    
    Next i
End If



' ������� � ������ ��� �����, ������� �� ������� � ��������
If IsCalcCorrOnlyForSameTime_cn = 1 Then
    For i = 2 To (cntDataHistoryRows - cntDataCurrentRows + 1) ' ���� �� ������� �������
        
        ' ���� ����� ���������� ������������� ���� �������� � �������������� ����������, �� ��������� ������ ��� ��������� � ������� � (���� ����������� ���� ������ ��� ��� ���������������� �������)
        If ((arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) >= (CurrentBarTimeInMinutes - DeltaMinutesCalcCorr_cn - PeriodMinutes_cn)) And (arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) <= (CurrentBarTimeInMinutes + DeltaMinutesCalcCorr_cn))) Then
                For j = 1 To cntDataCurrentRows ' ���� �� ��������� �������
                    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
                Next j
              
                ' ���� � ��������� ��� ������� �������� �� ��������������� ����������, �� ������� � ������ (����� ���������� ������ ��� ����������)
                If arrCorrelationValues(i - 1 + cntDataCurrentRows - 2) = 0 Then
                    'Call CorrelationEasyPrepare(arrCurrentCompare(), arrCurrentCompareRanges())
                    
                    ' ��������� ���������� � ������� arrHistoryCompare � ��������� �� � ������ arrHistoryCompareRanges:
                    ' ��������� ����������� � ������������ cclose � ����
                    vCcloseMin = fMinValue(arrHistoryCompare)
                    vCcloseMax = fMaxValue(arrHistoryCompare)
                    ' ��������� ������ arrHistoryCompareRanges (������ �� ���������� ���������� �� ������������ ������)
                    For j = 1 To cntDataCurrentRows
                      If vCcloseMax = vCcloseMin Then
                        arrHistoryCompareRanges(j - 1) = 0
                      Else
                        arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
                      End If
                    Next j
                    
                    arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
                Else
                    ' ��������� ���������� � ������� arrHistoryCompare � ��������� �� � ������ arrHistoryCompareRanges:
                    ' ��������� �����������/������������ cclose � ����:
                    If arrHistoryAll(i - 2) = vCcloseMin Then ' ���� ��������� ������� ������� ��� �����������, �� ������������� ����������� �������
                        vCcloseMin = fMinValue(arrHistoryCompare)
                    End If
                      
                    If arrHistoryAll(i - 2) = vCcloseMax Then ' ���� ��������� ������� ������� ��� ������������, �� ������������� ������������ �������
                        vCcloseMax = fMaxValue(arrHistoryCompare)
                    End If
                      
                    If arrHistoryCompare(j - 2) < vCcloseMin Then ' ���� ����� ������� ������� ������ ������������, �� ��������� ����������� �������
                        vCcloseMin = arrHistoryCompare(j - 2)
                    End If
                      
                    If arrHistoryCompare(j - 2) > vCcloseMax Then ' ���� ����� ������� ������� ������ �������������, �� ��������� ������������ �������
                        vCcloseMax = arrHistoryCompare(j - 2)
                    End If
                    
                      ' ��������� ������ arrHistoryCompareRanges (������ �� ���������� ���������� �� ������������ ������)
                    For j = 1 To cntDataCurrentRows
                        If vCcloseMax = vCcloseMin Then
                            arrHistoryCompareRanges(j - 1) = 0
                        Else
                            arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
                        End If
                    Next j
                      
                        arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
                    End If
        Else
              '���� ����� ���������� ������������� ���� �� �������� � �������������� ����������, �� ������ � = 0
              arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
        End If
    Next i

End If

    Call WriteLog("--4--")
End Sub


Public Function CorrelationEasyAll(ByRef arrHistoryRanges() As Double, _
                                   ByRef arrCurrentRanges() As Double, _
                                   ByVal n As Long) _
                                   As Double

'������ KEasy ����� ��������� arrHistoryRanges � arrCurrentRanges

Dim i As Long

CorrelationEasyAll = 1

For i = 1 To n
  CorrelationEasyAll = CorrelationEasyAll - (Abs(arrHistoryRanges(i - 1) - arrCurrentRanges(i - 1)) / n)
Next i

'CorrelationEasyAll = CorrelationEasyAll / n

End Function



