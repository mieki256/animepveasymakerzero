#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/01 17:04:45 +0900>
#
# ���b�Z�[�W�\���E�C���h�E�p�N���X

class MessageWindow
  NMLWDW = 1
  ERRWDW = 2
  
  def initialize(cfg)
    @scrw, @scrh = cfg.get_screen_size
    @msgimg = []
    resdir = cfg.get_res_dir
    @msgimg.push(Image.load(resdir + 'msgbg_normal.png'))
    @msgimg.push(Image.load(resdir + 'msgbg_error.png'))
    @msg_kind = 0
    @msg = nil
    @msg_timer = 0
    @fnt = Font.new(12, '�l�r �S�V�b�N')
  end

  # ���b�Z�[�W�\����ݒ�
  def set_msg(str, sec, fpsv, kind)
    @msg_kind = kind
    @msg = str.split("\n")
    @msg_timer = (sec * fpsv).to_i
  end

  # ���b�Z�[�W�\���^�C�}�[���X�V
  def update
    if @msg_kind > 0
      # ���b�Z�[�W�\����
      @msg_timer -= 1
      if @msg_timer <= 0
        @msg = nil
        @msg_kind = 0
      end
      return true
    end
    return false
  end

  # ���b�Z�[�W�`��
  def draw
    draw_msg(@msg, @msg_kind) if @msg_kind > 0
  end

  # ���b�Z�[�W�`�������
  def draw_msg(str, kind)
    # ���b�Z�[�W�g��`��
    img = @msgimg[kind - 1]
    x = (@scrw - img.width) / 2
    y = (@scrh - img.height) / 2
    Window.draw(x, y, img, 10)

    # ���b�Z�[�W�������`��
    x += 8
    y += 16
    str.each do |s|
      Window.drawFont(x, y, s, @fnt, :color => [0,0,0], :z => 11)
      y += (@fnt.size + 6)
    end
  end
end
