#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
#
# DXRuby Sound �� Ayame �̓������p�e�X�g
#
# Z�L�[��Sound���AX�L�[��Ayame����wav��炷�B
#
# * DXRuby 1.5.1dev �́ASound �� Ayame �𗼕��g���ƃX�N���v�g���I�����Ȃ��Ȃ�B
#   �������ASound �ɂ��� dispose ����ΏI������悤�ɂȂ�B
# * DXRuby 1.5.2dev �Ȃ���͏o�Ȃ��B

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

# se.dispose # ���̍s�����Ȃ��ƃX�N���v�g���I�����Ă���Ȃ�

