Attribute VB_Name = "msort"
'Option Compare Database

Option Explicit
'http://www.vbnet.ru/forum/show.aspx?id=90781&page=1



Private Type QuickStack
'��� ��� QuickSort
    Low As Long
    High As Long
End Type






Private Sub Swap(a As Variant, b As Variant)
'Swap ��� QuickSort
Dim Tmp As Variant
    Tmp = a: a = b: b = Tmp
End Sub




Public Sub QuickSortNonRecursive3(SortArray() As Variant, SortArrayId() As Variant)

'SortArray() - ���������� ������ � �������, ������� ����� �������������
'SortArrayId() - ���������� ������ � IDN ������, ������� ����� �������������.
'                ���� ������ ����������� � ������������ � ������ ��������

Dim i As Long, j As Long, lb As Long, ub As Long
Dim stack() As QuickStack, stackpos As Long
Dim ppos As Long, pivot As Variant, swp As Variant
    
    ReDim stack(1 To 64)
    stackpos = 1

    stack(1).Low = LBound(SortArray)
    stack(1).High = UBound(SortArray)
    Do
        '����� ������� lb � ub �������� ������� �� �����.
        lb = stack(stackpos).Low
        ub = stack(stackpos).High
        stackpos = stackpos - 1
        Do
            '��� 1. ���������� �� �������� pivot
            ppos = (lb + ub) \ 2
            i = lb: j = ub: pivot = SortArray(ppos)
            Do
                While SortArray(i) < pivot: i = i + 1: Wend
                While pivot < SortArray(j): j = j - 1: Wend
                If i <= j Then
                    swp = SortArray(i): SortArray(i) = SortArray(j): SortArray(j) = swp
                    swp = SortArrayId(i): SortArrayId(i) = SortArrayId(j): SortArrayId(j) = swp
                    i = i + 1
                    j = j - 1
                End If
            Loop While i <= j

            '������ ��������� i ��������� �� ������ ������� ����������,
            'j - �� ����� ������ lb ? j ? i ? ub.
            '�������� ������, ����� ��������� i ��� j ������� �� ������� �������
            '���� 2, 3. ���������� ������� ����� � ���� � ������� lb,ub

            If i < ppos Then    '������ ����� ������
                If i < ub Then
                    stackpos = stackpos + 1
                    If stackpos > UBound(stack) Then ReDim Preserve stack(1 To UBound(stack) + 32)
                    stack(stackpos).Low = i
                    stack(stackpos).High = ub
                End If
                ub = j    '��������� �������� ���������� ����� �������� � ����� ������
            Else
                If j > lb Then
                    stackpos = stackpos + 1
                    If stackpos > UBound(stack) Then ReDim Preserve stack(1 To UBound(stack) + 32)
                    stack(stackpos).Low = lb
                    stack(stackpos).High = j
                End If
                lb = i
            End If
        Loop While lb < ub
    Loop While stackpos
End Sub



