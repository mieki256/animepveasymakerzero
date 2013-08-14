#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
#
# DXRuby Sound と Ayame の同時利用テスト
#
# ZキーでSound側、XキーでAyame側のwavを鳴らす。
#
# * DXRuby 1.5.1dev は、Sound と Ayame を両方使うとスクリプトが終了しなくなる。
#   しかし、Sound について dispose すれば終了するようになる。
# * DXRuby 1.5.2dev なら問題は出ない。

require 'dxruby'
require_relative 'ayame'

se = Sound.new("se1.wav")
se2 = Ayame.new("se2.wav")
se2.predecode

fnt = Font.new(26)
mes = ["Z : Sound#play", "X : Ayame#play"]

Window.loop do
	break if Input.keyPush?(K_ESCAPE)
	
  se.play if Input.keyPush?(K_Z)
	se2.play(1,0) if Input.keyPush?(K_X)
	
  x, y = 16, 16
  mes.each do |s|
    Window.drawFont(x, y, s, fnt)
    y += fnt.size + 8
  end
end

# se.dispose # この行を入れないとスクリプトが終了してくれない

