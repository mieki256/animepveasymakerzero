#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 08:13:21 +0900>
#
# �X�N���[�����x�����߂鏈���ɂ��Ă̎����X�N���v�g
#
# I�L�[ : �摜�ύX
# �J�[�\���L�[ : �X�N���[��������ύX
# P�L�[ : �|�[�Y�؂�ւ�
# N�L�[ : �|�[�Y���Ȃ玟�̃t���[����
# B�L�[ : �����Ă�Ԃ̓|�[�Y��Ԃ�����

require 'dxruby'

class Scroll
  def initialize
    @indir = 'sampledata/test_image/'
    @imgfiles = [
                 'small_xy_320x180.png',
                 'small_x_450x450.png',
                 'small_y_720x320.png',
                 'large_x_only_800x360.png',
                 'large_y_only_640x450.png',
                 '800x450_16_9.png',
                ]
    @imgcnt = 0
    @img = Image.load(@indir + @imgfiles[@imgcnt])
    @fnt = Font.new(12)
    @x = 0.0
    @y = 0.0
    @x_spd = 0.0
    @y_spd = 0.0
    @count = 0
    @scrw = 640
    @scrh = 360
    @fpsv = 24
    @pause_mode = false
    @pause_enable = false
    @direct = "right"
  end

  attr_accessor :scrw, :scrh, :fpsv

  # === �����\���ʒu�ƃX�N���[�����x��ݒ肷��
  #
  # x, y       ::   ���݂̏����ʒu
  # scale ::        ���ɋ��߂��g��k����
  # w, h ::         �摜�T�C�Y  
  # scrw, scrh ::   ��ʃT�C�Y
  # spdx, spdy ::   x, y �̑��x (-n or +n)
  # d ::            ���t���[���ňړ����邩
  def Scroll.get_spd(x, y, scale, w, h, scrw, scrh, spdx, spdy, d)
    x_spd = 0.0
    y_spd = 0.0
    x = x.to_f
    y = y.to_f
    scale = scale.to_f
    
    fpsv = @fpsv.to_f
    w = w.to_f
    h = h.to_f
    sw = scrw.to_f
    sh = scrh.to_f
    
    if d == 0
      # ���̐؂�ւ����܂ł̃t���[�������F��
      # �ݒ�̂��悤���Ȃ�
    elsif d < 0
      # ���̐؂�ւ����܂ł̃t���[�������s��
      # �Œ�l�ŏ����ʒu�Ƒ��x�����߂�
      x_spd = spdx
      y_spd = spdy
      xd = (x_spd * 3.0 * fpsv).to_f / 2.0 
      yd = (y_spd * 3.0 * fpsv).to_f / 2.0 
      x -= xd
      y -= yd
      if scale < 1.0
        scale = 1.0
      elsif scale > 1.0
        scale += 0.5
      end
    else
      # ���̐؂�ւ����܂ł̃t���[�����͊m�肵�Ă���
      # ���x�����߂邱�Ƃ��\
      
      flip_fg = (spdy != 0)? true : false
      if flip_fg
        x, y = y, x
        w, h = h, w
        sw, sh = sh, sw
        spdx, spdy = spdy, spdx
      end

      # x�����̃X�N���[���Ɖ��肵�Čv�Z
      if w > sw
        # �X�N���[����������ɂ��Ă͉摜����ʂ��傫��
        if h >= sh
          # �X�N���[�����Ȃ������̉摜�T�C�Y���\���������Ă�
          scale = 1.0
          dist = (w - sw) / 2.0
          dist *= -1 if spdx < 0
          tgt = x + dist
          x -= dist
          x_spd = (tgt - x).to_f / d.to_f
        else
          # �X�N���[�����Ȃ������̉摜�T�C�Y����ʂ�菬����
          scale = sh / h # �኱�g�傷��
          dist = (w * scale - sw) / 2.0
          dist *= -1 if spdx < 0
          tgt = x + dist
          x -= dist
          x_spd = (tgt - x).to_f / d.to_f
        end
      else
        # �c�����ɉ摜����ʂ�菬����
        scale = [(sw / w), (sh / h)].max
        scale += 0.5
        dist = (w * scale - sw) / 2.0
        dist *= -1 if spdx < 0
        tgt = x + dist
        x -= dist
        x_spd = (tgt - x).to_f / d.to_f
      end

      if flip_fg
        x, y = y, x
        x_spd, y_spd = y_spd, x_spd
      end
    end

    return x, y, x_spd, y_spd, scale
  end

  #
  # === �e�X�g����p�̍X�V�`�揈��
  #
  def update_and_draw
    if Input.keyPush?(K_P)
      @pause_mode = !(@pause_mode)
      @pause_enable = @pause_mode
    end

    if @pause_mode
      @pause_enable = !(Input.keyPush?(K_N))
      @pause_enable = false if Input.keyDown?(K_B)
    end

    unless @pause_enable
      # �J�[�\���L�[�ɂ��X�N���[�������ύX
      key_list = {
        K_LEFT => "left",
        K_RIGHT => "right",
        K_UP => "up",
        K_DOWN => "down",
      }
      key_list.each do |key, value|
        if Input.keyPush?(key)
          @direct = value
          @count = 0
        end
      end

      # �摜�ύX
      if Input.keyPush?(K_I)
        @imgcnt = (@imgcnt + 1) % @imgfiles.length
        @img = Image.load(@indir + @imgfiles[@imgcnt])
        @count = 0
      end
      
      d_frame = (@fpsv * 2).to_i
      if @count % d_frame == 0
        w = @img.width.to_f
        h = @img.height.to_f
        sw = @scrw.to_f
        sh = @scrh.to_f
        @x = (sw - w) / 2.0
        @y = (sh - h) / 2.0
        @scale = 1.0
        @x_spd, @y_spd = 0, 0
        @scale = @scale_tgt = [(sw / w), (sh / h)].max
        
        spd = 2.0
        
        # ���x�Z�o
        spdx, spdy = 0, 0
        case @direct
        when "up"
          spdx, spdy = 0, -spd
        when "down"
          spdx, spdy = 0, spd
        when "left"
          spdx, spdy = -spd, 0
        when "right"
          spdx, spdy = spd, 0
        end
        @x, @y, @x_spd, @y_spd, @scale = Scroll.get_spd(@x, @y, @scale,
                                                        w, h, sw, sh,
                                                        spdx, spdy,
                                                        d_frame)
      end
    end

    Window.drawScale(@x, @y, @img, @scale, @scale)
    lst = [
           "I : �摜�ύX",
           "�������� : �����ύX",
           "P : �|�[�Y",
           "N : ���̃t���[����(�|�[�Y���̂�)",
           "B : �����Ă�Ԃ̓|�[�Y����(�|�[�Y���̂�)",
          ]
    x = 16
    y = 16
    lst.each do |s|
      Window.drawFont(x, y, s, @fnt)
      y += 16
    end

    unless @pause_enable
      @x += @x_spd
      @y += @y_spd
      @count += 1
    end
  end

end

if $0 == __FILE__
  scl = Scroll.new
  Window.fps = scl.fpsv
  Window.width, Window.height = scl.scrw, scl.scrh
  
  Window.loop do
    break if Input.keyPush?(K_ESCAPE)
    scl.update_and_draw
  end
end


