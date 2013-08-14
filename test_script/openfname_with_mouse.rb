#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
#
# DXRuby �� openFilename() ���̎��s��A
# �}�E�X�N���b�N�����o�s�ɂȂ�Ǐ�̃e�X�g
#
# ��ʂ̏㒆�����N���b�N����ƁAopenFilename()���̑����Ăׂ�B
# DXRuby 1.5.2dev �ł́A
# �ŏ���1��̓}�E�X�N���b�N���󂯕t������̂́A
# ��x openFilename() �����ĂԂƁA������͎󂯕t���Ȃ��Ȃ�B

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
      Window.bgcolor = [255, 0, 0] # �w�i�F��Ԃ�
    elsif my < Window.height * 2 / 3
      path = Window.openFilename([["ALL Files (*.*)", "*.*"]], "�t�@�C���I��")
      fpath = (path != nil)? path : "cancel"
    else
      app = WIN32OLE.new('Shell.Application')
      path = app.BrowseForFolder(0, "�t�H���_�I��", 0)
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
  l = ["�㑤�ŃN���b�N : ��ʃt���b�V��",
       "�^�񒆂ŃN���b�N : Window.openFilename() : [#{fpath}]",
       "�����ŃN���b�N : WIN32OLE + �_�C�A���O : [#{dpath}]"]
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

