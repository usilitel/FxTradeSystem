Attribute VB_Name = "mEmailSend"
'Option Compare Database
Option Explicit

Sub send_Email(strSubject As String, strBody As String)
' посылаем email
' strSubject - тема письма
' strBody - текст письма

    Dim iMsg As Object
    Dim iConf As Object
    'Dim strBody As String
    Dim Flds As Variant
    
    On Error Resume Next
    
    Set iMsg = CreateObject("CDO.Message")
    Set iConf = CreateObject("CDO.Configuration")
    iConf.Load -1
    Set Flds = iConf.Fields
    With Flds
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
    .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "usilitel@mail.ru"
    .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "Usilitel723200"
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.mail.ru"
    .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
    .Update
    End With
    'strBody = "1_5 eurusd 1 fx_alert2"
    With iMsg
    Set .Configuration = iConf
    '.To = "usilitel@mail.ru"
    .To = "usilitel00@gmail.com"
    .CC = ""
    .BCC = ""
    .from = "usilitel@mail.ru"
    .Subject = strSubject
    .TextBody = strBody
    .Send
    End With

End Sub


Sub send_email_test()
    Call send_Email("strSubject", "strBody")
End Sub
















Sub CDO_Mail_Small_Text_2()
Dim iMsg As Object
Dim iConf As Object
Dim strBody As String
Dim Flds As Variant
Set iMsg = CreateObject("CDO.Message")
Set iConf = CreateObject("CDO.Configuration")
iConf.Load -1
Set Flds = iConf.Fields
With Flds
.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoBasic
.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 2
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoAnonymous

.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "usilitel00@gmail.com"
.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "Usilitel7232"
.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "aspmx.l.google.com"
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp-relay.gmail.com"

.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
'.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587

.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2


'.Item("http://schemas.microsoft.com/cdo/configuration/urlgetlatestversion") = True


.Update
End With
strBody = "Поздравляем!!!! Ваше письмо успешно отправлено !!!!"
With iMsg
Set .Configuration = iConf
.To = "usilitel@gmail.com"
.CC = ""
.BCC = ""
.from = "usilitel00@gmail.com"
.Subject = "Попытка отправить письмо с помощью CDO"
.TextBody = strBody
.Send
End With
End Sub


Sub CDO_Mail_Small_Text_4()

'Содание объекта CDO
Dim objmes
Set objmes = CreateObject("CDO.Message")
 
'От кого и кому
Dim from
Dim whom
from = "usilitel00@gmail.com" 'адрес отправителя
whom = "usilitel00@mail.ru" 'адрес получателя
 
'Тема и текст сообщения
Dim theme
Dim text
theme = "subj"
text = "sended!"
 
'Конфигурация
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = from
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "Usilitel7232"
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
objmes.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
 
'Заполнение письма
objmes.from = from
objmes.To = whom
objmes.Subject = theme
objmes.TextBody = text
 
'Обновление данных и отправка письма
objmes.Configuration.Fields.Update
objmes.Send


End Sub


 
Sub testemail1()

Dim EmailSubject As String
Dim EmailBody As String

EmailSubject = "Sending Email by CDO"
EmailBody = "This is the body of a message sent via" & vbCrLf & _
        "a CDO.Message object using SMTP authentication ,with port 465."

Const EmailFrom = "usilitel00@gmail.com"
Const EmailFromName = "My Very Own Name"
Const EmailTo = "usilitel00@gmail.com"
Const SMTPServer = "smtp.gmail.com"
Const SMTPLogon = "usilitel00@gmail.com"
Const SMTPPassword = "Usilitel7232"
Const SMTPSSL = True
Const SMTPPort = 465

Const cdoSendUsingPickup = 1    'Send message using local SMTP service pickup directory.
Const cdoSendUsingPort = 2  'Send the message using SMTP over TCP/IP networking.

Const cdoAnonymous = 0  ' No authentication
Const cdoBasic = 1  ' BASIC clear text authentication
Const cdoNTLM = 2   ' NTLM, Microsoft proprietary authentication

' First, create the message

Set objMessage = CreateObject("CDO.Message")
objMessage.Subject = EmailSubject
objMessage.from = """" & EmailFromName & """ <" & EmailFrom & ">"
objMessage.To = EmailTo
objMessage.TextBody = EmailBody

' Second, configure the server

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/smtpserver") = SMTPServer

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoBasic

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/sendusername") = SMTPLogon

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/sendpassword") = SMTPPassword

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = SMTPPort

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = SMTPSSL

objMessage.Configuration.Fields.Item _
("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60

objMessage.Configuration.Fields.Update
'Now send the message!
On Error Resume Next
objMessage.Send

If Err.Number <> 0 Then
    MsgBox Err.Description, 16, "Error Sending Mail"
Else
    MsgBox "Mail was successfully sent !", 64, "Information"
End If


End Sub




Sub CDO_Mail_Small_Text_3()
Dim iMsg As Object
Dim iConf As Object
Dim strBody As String
Dim Flds As Variant
Set iMsg = CreateObject("CDO.Message")
Set iConf = CreateObject("CDO.Configuration")
iConf.Load -1
Set Flds = iConf.Fields
With Flds
.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "usilitel@mail.ru"
.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "Usilitel723200"
.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.mail.ru"
.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
.Update
End With
strBody = "1_5 eurusd 1 fx_alert2"
With iMsg
Set .Configuration = iConf
'.To = "usilitel@mail.ru"
.To = "usilitel00@gmail.com"
.CC = ""
.BCC = ""
.from = "usilitel@mail.ru"
.Subject = "1_5 eurusd 1 fx_alert4"
.TextBody = strBody
.Send
End With
End Sub

