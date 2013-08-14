#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 17:58:09 +0900>
#
# �L�[�{�[�h�摜�\���p�N���X

require 'dxruby'
require_relative 'anime'
require_relative 'animekind'
require_relative 'keyboardimage'

class KeymapDisp
  def initialize(cfg)
    @cfg = cfg
    @scrw, @scrh = @cfg.get_screen_size
    @resdir = @cfg.get_res_dir

    # �摜�ǂݍ���
    @keyonimg = Image.load(@resdir + 'key_on.png')
    @keyoneffectimg = Image.load(@resdir + 'key_on_effect.png')

    # �󂯕t����L�[�̈ꗗ�����擾
    @tbl = @cfg.get_key_tbl
    @enable_keys = AnimeKind.get_enable_key_list(@tbl)
    @keys_about = AnimeKind.get_key_about_dic(@tbl)
    @keys_mode = AnimeKind.get_key_mode_dic(@tbl)

    # �L�[�{�[�h�摜����
    @keyimg, @key_pos = KeyboardImage.make_image(@enable_keys, @keys_about, @resdir)
    @base_x = @scrw - @keyimg.width - 10
    @base_y = @scrh - @keyimg.height - 20
    
    init_work
  end

  # ���[�N������
  def init_work
    @pushkey = ""
    @push_enable = false
    @push_x = 0
    @push_y = 0
    @push_alpha = 255
    @push_scale = 1.0
    @push_scale2 = 1.0
  end
  
  # �����ꂽ�L�[���L��
  def set_pushkey(ch)
    if @key_pos.has_key?(ch)
      x, y = @key_pos[ch]
      @push_enable = true
      @push_x = @base_x + x
      @push_y = @base_y + y
      @push_alpha = 192
      @push_scale = 0.5
      @push_scale2 = 0.1
    end
  end

  # �\���L�[�{�[�h���}�E�X�{�^���ŃN���b�N���ꂽ�����ׂ�
  def check_push_key_by_mouse
    mx = Input.mousePosX
    my = Input.mousePosY
    mode = ""
    
    @enable_keys.each do |ch|
      if @key_pos.has_key?(ch)
        x, y = @key_pos[ch]
        x += @base_x
        y += @base_y
        hw = 14
        hh = 14
        x0 = x - hw
        y0 = y - hh
        x1 = x + hw
        y1 = y + hh
        if x0 <= mx and mx <= x1 and y0 <= my and my <= y1
          # �}�E�X�|�C���^���L�[�\���̏�ɂ���
          if Input.mousePush?(M_LBUTTON)
            # �}�E�X�{�^����������Ă�
            mode = @keys_mode[ch] if @keys_mode[ch] != nil
            set_pushkey(ch)
          end
        end
      else
        puts "Err: [#{ch}] not define position."
      end
    end

    return mode
  end
  
  def draw
    Window.draw(@base_x, @base_y, @keyimg)

    # �����ꂽ�L�[��������悤�Ƀ}�[�N��`��
    if @push_enable
      x = @push_x - (@keyonimg.width / 2)
      y = @push_y - (@keyonimg.height / 2)
      sc = @push_scale
      Window.drawEx(x, y, @keyonimg,
                    :scalex => sc, :scaley => sc,
                    :alpha => @push_alpha)
      
      x = @push_x - (@keyoneffectimg.width / 2)
      y = @push_y - (@keyoneffectimg.height / 2)
      sc = @push_scale2
      Window.drawEx(x, y, @keyoneffectimg,
                    :scalex => sc, :scaley => sc,
                    :alpha => @push_alpha)
      
      @push_scale += 0.086
      @push_scale2 += (2.0 - @push_scale2) * 0.3
      @push_alpha -= 24
      if @push_alpha <= 0
        @push_enable = false
      end
    end
  end
end

