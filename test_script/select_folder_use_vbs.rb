#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 18:44:28 +0900>
#
# DXRuby���g�����X�N���v�g������A
# WSH(.vbs)�Ńt�H���_�I���_�C�A���O���J���A���ʂ��󂯎���Ă݂�
#
# �ȑO�́Acscript.exe ���ĂсA�W���o�͌o�R�Ō��ʂ��󂯎���Ă������A
# ���ꂾ�ƃR�}���h�v�����v�g���J���Ă��܂��ğT�������̂ŁA
# wscript.exe ���ĂсA���A�N���b�v�{�[�h�o�R�Ŏ󂯎��悤�ɂ��Ă݂��B

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
    title = "�t�H���_��I�����Ă������� (�E�ְ)�`��"
    wsh_fname = File.join(cdir, "select_open_folder.vbs")
    %x[wscript "#{wsh_fname}" "#{title}"] # WSH�Ăяo��

    # �N���b�v�{�[�h�Ƀt�H���_�p�X�������Ă���͂�
    folder = Clipboard.data
    puts folder
    
    folder.chomp! # �Ԃ��Ă���������ɂ͉��s���܂܂�Ă���̂ŏ��� 
    folder = "" if folder =~ /^::/ # ����t�H���_��I�����ꂽ�ۂ̑΍�
  end

  l = [
       "#{cnt}",
       "Z�L�[ : �t�H���_�I���_�C�A���O���J��",
       "ESC  : �I��",
       "[#{folder}]",
      ]
  x, y = 16, 16
  l.each do |s|
    Window.drawFont(x, y, s, fnt)
    y += fnt.size + 8
  end
  cnt += 1
end


