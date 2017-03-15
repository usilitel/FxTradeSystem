Attribute VB_Name = "smsc_api"
' SMSC.RU API (www.smsc.ru) ������ 1.0 (10.01.2011)

Public Const SMSC_DEBUG As Byte = 0         ' ���� �������
Public Const SMSC_CHARSET As String = "utf-8"    ' ��������� ��������� (utf-8 ��� koi8-r), �� ��������� ������������ windows-1251

Public SMSC_LOGIN As String                 ' ����� �������
Public SMSC_PASSWORD As String              ' ������ ������� ��� MD5-��� ������ � ������ ��������
Public SMSC_HTTPS As Byte                   ' ������������ HTTPS ��������

Public Const SMTP_SERVER As String = "smtp.mail.ru"        ' ����� SMTP �������
Public Const SMTP_USERNAME As String = "<smtp_user_name>"  ' ����� �� SMTP �������
Public Const SMTP_PASSWORD As String = "<smtp_password>"   ' ������ �� SMTP �������
Public Const SMTP_FROM As String = "smtp_user_name@mail.ru" ' e-mail ����� �����������

Public CONNECT_MODE As Byte         ' ����� ���������� � ����������: 0 - ������, 1 - Proxy, 2 - ��������� �� Internet Exporer
Public PROXY_SERVER As String       ' ����� Proxy-�������
Public PROXY_PORT As Integer        ' ���� Proxy-�������
Public PROXY_AUTORIZATION As Byte   ' ���� ������������� ����������� �� Proxy-�������
Public PROXY_USERNAME As String     ' ����� �� Proxy-�������
Public PROXY_PASSWORD As String     ' ������ �� Proxy-�������

Public Connection As Object


Sub sendSMS(strBody As String)
    SMSC_LOGIN = ""******" ' ����� �������
    SMSC_PASSWORD = ""******" ' ������ ������� ��� MD5-��� ������ � ������ ��������

    Call SMSC_Initialize
    Call send_SMS("+79535775047", strBody)
End Sub


Public Function test1()
    SMSC_LOGIN = ""******" ' ����� �������
    SMSC_PASSWORD = "******" ' ������ ������� ��� MD5-��� ������ � ������ ��������

    Call SMSC_Initialize
    Call send_SMS("+79535775047", "1_5")
End Function


' ����� � ����������
'
' ���������:
'   PauseTime - ����� ����� � ��������
'
Private Sub Sleep(PauseTime As Integer)

    Start = Timer
    Do While Timer < Start + PauseTime
        DoEvents
    Loop
    
End Sub


Public Function URLEncode(ByVal Str As String) As String

    Dim Ret

    Ret = ""
    CharStr = " !""@�#;%:?*().,/$^&\+"
    
    Str = Trim(Str)
    For i = 1 To Len(Str)
        
        S = Mid(Str, i, 1)
        SymCode = Asc(S)
        
        ' ������� �� UNICODE � ASCII
        If ((SymCode > 1039) And (SymCode < 1104)) Then
            SymCode = SymCode - 848
        ElseIf SymCode = 8470 Then
            SymCode = 185
        ElseIf SymCode = 1105 Then
            SymCode = 184
        ElseIf SymCode = 1025 Then
            SymCode = 168
        End If
   
        fl_replace = 0
        If InStr(1, CharStr, S, vbBinaryCompare) > 0 Then
            Ret = Ret & "%" & Hex(Int(SymCode / 16)) & Hex(Int(SymCode Mod 16))
            fl_replace = 1
        End If

        If (SymCode <= 127) And (fl_replace = 0) Then
            Ret = Ret & S
        ElseIf fl_replace = 0 Then
            Ret = Ret + "%" + Hex(Int(SymCode / 16)) & Hex(Int(SymCode Mod 16))
        End If
    
    Next i

    URLEncode = Ret

End Function

' ������� ������ URL.
'
Private Function SMSC_Read_URL(URL As String, Params As String) As String

    Dim Ret As String
    
    On Error GoTo 0
    Connection.Open "POST", Trim(URL), 0
    Connection.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    Connection.Send Trim(Params)
    Ret = Connection.ResponseText()
    If Err.Number <> 0 Then
        MsgBox "�� ������� �������� ������ � �������!", , "������"
        SMSC_Read_URL = ""
        Exit Function
    End If
    
    SMSC_Read_URL = Ret

End Function

' ������� ������ �������. ��������� URL � ������ 3 ������� ������.
'
Private Function SMSC_Send_Cmd(Cmd As String, Optional Arg As String = "")
    
    Dim URL As String, Params As String, Ret As String
        
    URL = IIf(SMSC_HTTPS, "https", "http") & "://smsc.ru/sys/" & Cmd & ".php"
    Params = "login=" & SMSC_LOGIN & "&psw=" & SMSC_PASSWORD & "&fmt=1" _
            & IIf(SMSC_CHARSET = "", "", "&charset=" + SMSC_CHARSET) & "&" & Arg
    
    i = 0
    Do
        If i Then Sleep (2)
        If i = 2 Then URL = Replace(URL, "://smsc.ru/", "://www2.smsc.ru/")
        Ret = SMSC_Read_URL(URL, Params)
        i = i + 1
    Loop While (IsEmpty(Ret) And i < 3)

    If IsEmpty(Ret) Then
        If SMSC_DEBUG Then MsgBox "������ ������ ������: " & URL, , "������"
        Ret = ","  ' ��������� �����
    End If

    SMSC_Send_Cmd = Split(Ret, ",", -1, vbTextCompare)

End Function

' ������� ��������� �������
'
' ��� ����������
'
' ���������� ������ � ���� ������ ��� CVErr(N_������) � ������ ������
'
Public Function Get_Balance()

    Dim m
    
    m = SMSC_Send_Cmd("balance")  ' (balance) ��� (0, -error)

    If UBound(m) = 0 Then
        Get_Balance = m(0)
    Else
        Get_Balance = CVErr(-m(1))
    End If

End Function

' ������� �������� SMS
'
' ������������ ���������:
'
' Phones - ������ ��������� ����� ������� ��� ����� � �������
' Message - ������������ ���������
'
' �������������� ���������:
'
' Translit - ���������� ��� ��� � �������� (1 ��� 0)
' Time - ����������� ����� �������� � ���� ������ (DDMMYYhhmm, h1-h2, 0ts, +m)
' Id - ������������� ���������
' Format - ������ ��������� (0 - ������� sms, 1 - flash-sms, 2 - wap-push, 3 - hlr, 4 - bin, 5 - bin-hex, 6 - ping-sms)
' Sender - ��� ����������� (Sender ID)
' Query - �������������� ���������
'
' ���������� ������ (<id>, <���������� sms>, <���������>, <������>) � ������ �������� ��������
' ���� ������ (<id>, -<��� ������>) � ������ ������
'
Public Function send_SMS(Phones As String, Message As String, Optional Translit = 0, Optional Time = 0, Optional Id = 0, Optional Format = 0, Optional sender = "", Optional Query = "")
    
    Dim Formats As Variant
    Dim m
    
    Formats = Array("flash=1", "push=1", "hlr=1", "bin=1", "bin=2", "ping=1")
    FormatStr = ""
    If (Format > 0) Then
        FormatStr = Formats(Format - 1)
    End If
  
    m = SMSC_Send_Cmd("send", "cost=3&phones=" & URLEncode(Phones) & "&mes=" & Message _
                    & "&translit=" & Translit & "&id=" & Id & IIf(Format > 0, "&" & FormatStr, "") _
                    & IIf(sender = "", "", "&sender=" & URLEncode(sender)) _
                    & "&charset=" & SMSC_CHARSET & IIf(Time = "", "", "&time=" & URLEncode(Time)) _
                    & IIf(Query = "", "", "&" & Query))

    ' (id, cnt, cost, balance) ��� (id, -error)

    send_SMS = m
    
End Function


' ������� ��������� ��������� SMS
'
' ������������ ���������:
'
' Phones - ������ ��������� ����� ������� ��� ����� � �������
' Message - ������������ ���������
'
' �������������� ���������:
'
' Translit - ���������� ��� ��� � �������� (1 ��� 0)
' Sender - ��� ����������� (Sender ID)
' Query - �������������� ���������
'
' ���������� ������ (<���������>, <���������� sms>) ���� ������ (0, -<��� ������>) � ������ ������
'
Public Function Get_SMS_Cost(Phones As String, Message As String, Optional Translit = 0, Optional sender = "", Optional Query = "")

    Dim m
    
    m = SMSC_Send_Cmd("send", "cost=1&phones=" & URLEncode(Phones) & "&mes=" & Message & IIf(sender = "", "", "&sender=" & URLEncode(sender)) _
                    & "&translit=" & Translit & IIf(Query = "", "", "&" & Query))


    '(cost, cnt) ��� (0, -error)

    Get_SMS_Cost = m

End Function

' ������� �������� ������� ������������� SMS
'
' Id - ID c��������
' Phone - ����� ��������
'
' ���������� ������
' ��� ������������� SMS (<������>, <����� ���������>, <��� ������ sms>)
' ��� HLR-������� (<������>, <����� ���������>, <��� ������ sms>, <��� ������ �����������>, <��� ��������� ��������>,
' <�������� ������ �����������>, <�������� ��������� ��������>, <�������� ����������� ������>, <�������� ������������ ���������>,
' <��� IMSI SIM-�����>, <����� ������-������>)
' ���� ������ (0, -<��� ������>) � ������ ������
'
Public Function Get_Status(Id, Phone)

    Dim m

    m = SMSC_Send_Cmd("status", "phone=" & URLEncode(Phone) & "&id=" & Id)

    ' (status, time, err) ��� (0, -error)

    Get_Status = m
    
End Function

' ������������� �����������
'
Public Function SMSC_Initialize()

    On Error GoTo 0
    Set Connection = CreateObject("WinHttp.WinHttpRequest.5.1")
    Connection.Option 9, 80
    
    If Err.Number = 440 Or Err.Number = 432 Then
       MsgBox "�� ������� ������� ������ ""WinHttp.WinHttpRequest.5.1""!" & Chr(13) & "��������� ������� ��������� ���������� ""WinHttp.dll""", , "������"
       Err.Clear
    End If

End Function
