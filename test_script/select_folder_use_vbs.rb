#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 18:44:28 +0900>
#
# DXRubyを使ったスクリプト中から、
# WSH(.vbs)でフォルダ選択ダイアログを開き、結果を受け取ってみる
#
# 以前は、cscript.exe を呼び、標準出力経由で結果を受け取っていたが、
# それだとコマンドプロンプトが開いてしまって鬱陶しいので、
# wscript.exe を呼び、かつ、クリップボード経由で受け取るようにしてみた。

require 'rubygems'
require 'dxruby'
require 'win32/clipboard'
include Win32

fpath = ENV['OCRA_EXECUTABLE'] || $0
cdir = File.dirname(File.expand_path(fpath))
fnt = Font.new(12)
folder = ""
cnt = 0

Window.loop do
  break if Input.keyPush?(K_ESCAPE)
  
  if Input.keyPush?(K_Z)
    title = "フォルダを選択してください (・ωｰ)～☆"
    wsh_fname = File.join(cdir, "select_open_folder.vbs")
    %x[wscript "#{wsh_fname}" "#{title}"] # WSH呼び出し

    # クリップボードにフォルダパスが入っているはず
    folder = Clipboard.data
    puts folder
    
    folder.chomp! # 返ってきた文字列には改行も含まれているので除去 
    folder = "" if folder =~ /^::/ # 特殊フォルダを選択された際の対策
  end

  l = [
       "#{cnt}",
       "Zキー : フォルダ選択ダイアログを開く",
       "ESC  : 終了",
       "[#{folder}]",
      ]
  x, y = 16, 16
  l.each do |s|
    Window.drawFont(x, y, s, fnt)
    y += fnt.size + 8
  end
  cnt += 1
end


