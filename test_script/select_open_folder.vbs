' �t�H���_�I���_�C�A���O���J���āA�I�����ꂽ�t�H���_�p�X��Ԃ� VBScript
' ���ʕ�������N���b�v�{�[�h�ɓ���Ă���I������B

Option Explicit
On Error Resume Next

Dim oParam, oShell, oFolder, s, dirname, objIe

Set oParam = WScript.Arguments
If oParam.Length > 0 Then
    s = oParam(0)
Else
    s = "�t�H���_��I�����Ă�������"
End If
dirname = "::"

Set oShell = WScript.CreateObject("Shell.Application")
If Err.Number = 0 Then
    Set oFolder = oShell.BrowseForFolder(0, s, 0)
    If Not oFolder Is Nothing Then
        ' �t�H���_�I�������ꂽ�ꍇ
        dirname = oFolder.Items.Item.Path
    Else
        ' �L�����Z�����ꂽ�ꍇ
        dirname = "::cancel"
    End If
Else
    ' �G���[�����������ꍇ
    ' WScript.Echo "�G���[�F" & Err.Description
    dirname = "::error"
End If

' ���ʂ��o��
' WScript.Echo dirname

' ���ʂ��N���b�v�{�[�h�ɃR�s�[
Const OLECMDID_COPY = 12
Const OLECMDID_SELECTALL = 17
Const OLECMDEXECOPT_DODEFAULT = 0
Set objIe = CreateObject("InternetExplorer.Application")
' objIe.Visible = true
objIe.Navigate "about:blank"
Do While objIe.Busy
    WScript.Sleep 100
Loop

objIe.Document.Body.InnerText = dirname
objIe.ExecWB OLECMDID_SELECTALL, OLECMDEXECOPT_DODEFAULT
objIe.ExecWB OLECMDID_COPY, OLECMDEXECOPT_DODEFAULT
Do While objIe.Busy
    WScript.Sleep 100
Loop
objIe.Quit

Set objIe = Nothing

Set dirname = Nothing
Set s = Nothing
Set oFolder = Nothing
Set oShell = Nothing
Set oParam = Nothing

