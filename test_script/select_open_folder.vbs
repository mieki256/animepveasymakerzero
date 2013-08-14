' フォルダ選択ダイアログを開いて、選択されたフォルダパスを返す VBScript
' 結果文字列をクリップボードに入れてから終了する。

Option Explicit
On Error Resume Next

Dim oParam, oShell, oFolder, s, dirname, objIe

Set oParam = WScript.Arguments
If oParam.Length > 0 Then
    s = oParam(0)
Else
    s = "フォルダを選択してください"
End If
dirname = "::"

Set oShell = WScript.CreateObject("Shell.Application")
If Err.Number = 0 Then
    Set oFolder = oShell.BrowseForFolder(0, s, 0)
    If Not oFolder Is Nothing Then
        ' フォルダ選択がされた場合
        dirname = oFolder.Items.Item.Path
    Else
        ' キャンセルされた場合
        dirname = "::cancel"
    End If
Else
    ' エラーが発生した場合
    ' WScript.Echo "エラー：" & Err.Description
    dirname = "::error"
End If

' 結果を出力
' WScript.Echo dirname

' 結果をクリップボードにコピー
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

