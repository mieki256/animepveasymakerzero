#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
#
# DXRuby で openFilename() 等の実行後、
# マウスクリックが検出不可になる症状のテスト
#
# 画面の上中下をクリックすると、openFilename()その他が呼べる。
# DXRuby 1.5.2dev では、
# 最初の1回はマウスクリックを受け付けるものの、
# 一度 openFilename() 等を呼ぶと、次からは受け付けなくなる。

require 'dxruby'
require 'win32ole'

fnt = Font.new(12)
fpath, dpath = "", ""

Window.loop do
  Window.bgcolor = [0, 0, 0]
  break if Input.keyPush?(K_ESCAPE)
  if Input.mousePush?(M_LBUTTON)
    my = Input.mousePosY
    if my < Window.height / 3
      Window.bgcolor = [255, 0, 0] # 背景色を赤に
    elsif my < Window.height * 2 / 3
      path = Window.openFilename([["ALL Files (*.*)", "*.*"]], "ファイル選択")
      fpath = (path != nil)? path : "cancel"
    else
      app = WIN32OLE.new('Shell.Application')
      path = app.BrowseForFolder(0, "フォルダ選択", 0)
      if path
        begin
          dpath = path.Items.Item.path
        rescue
          dpath = "?"
        end
      else
        dpath = "cancel"
      end
    end
  end
  l = ["上側でクリック : 画面フラッシュ",
       "真ん中でクリック : Window.openFilename() : [#{fpath}]",
       "下側でクリック : WIN32OLE + ダイアログ : [#{dpath}]"]
  x, y = 16, 16
  l.each do |s|
    Window.drawFont(x, y, s, fnt)
    y += fnt.size + 16
  end
  x0, x1 = 0, Window.width
  y = Window.height / 3
  Window.drawLine(x0, y, x1, y, C_WHITE)
  y = Window.height * 2 / 3
  Window.drawLine(x0, y, x1, y, C_WHITE)
end

