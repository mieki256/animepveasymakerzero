#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 03:32:16 +0900>
#
# DXRuby + WIN32OLE �̏�ԂŃt�H���_�I���_�C�A���O���J���Ă݂�e�X�g
#
# DXRuby 1.5.1dev �ł̓G���[���������邪�A1.5.2dev �Ȃ��薳���B

require 'dxruby'
require 'win32ole'

fnt = Font.new(12)
dpath = ""

Window.loop do
  break if Input.keyPush?(K_ESCAPE)
  
  if Input.keyPush?(K_Z)
    app =  WIN32OLE.new('Shell.Application')
    path = app.BrowseForFolder(0, "�t�H���_��I�����Ă�������", 0)
    if path
      begin
        dpath = path.Items.Item.path
      rescue
        # "�f�X�N�g�b�v"����I�������ƃG���[�ɂȂ�̂ŗ�O������
        dpath = "?"
      end
    else
      dpath = "cancel"
    end
  end
  
  Window.drawFont(16, 16, "Z�L�[ : �t�H���_�I���_�C�A���O���J��", fnt)
  Window.drawFont(16, 64, "[#{dpath}]", fnt)
end

