#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 03:32:16 +0900>
#
# DXRuby + WIN32OLE の状態でフォルダ選択ダイアログを開いてみるテスト
#
# DXRuby 1.5.1dev ではエラーが発生するが、1.5.2dev なら問題無し。

require 'dxruby'
require 'win32ole'

fnt = Font.new(12)
dpath = ""

Window.loop do
  break if Input.keyPush?(K_ESCAPE)
  
  if Input.keyPush?(K_Z)
    app =  WIN32OLE.new('Shell.Application')
    path = app.BrowseForFolder(0, "フォルダを選択してください", 0)
    if path
      begin
        dpath = path.Items.Item.path
      rescue
        # "デスクトップ"等を選択されるとエラーになるので例外処理に
        dpath = "?"
      end
    else
      dpath = "cancel"
    end
  end
  
  Window.drawFont(16, 16, "Zキー : フォルダ選択ダイアログを開く", fnt)
  Window.drawFont(16, 64, "[#{dpath}]", fnt)
end

