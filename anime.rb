#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 23:43:16 +0900>
#
# �A�j���\���p�N���X
#
# �A�j����ނ�ǉ�����ꍇ�́A�ȉ��̃t�@�C����ҏW�E�C������B
#
# * anime.rb
# * animekind.csv
# * exportexo.rb

require 'dxruby'
require_relative 'scroll'

class Anime
  
  def initialize(cfg)
    @cfg = cfg
    @scrw, @scrh = @cfg.get_screen_size
    @fpsv = @cfg.get_fps
    @whiteimg = Image.new(@scrw, @scrh, [255, 255, 255, 255])
    @blackimg = Image.new(@scrw, @scrh, [255, 0, 0, 0])
    init_work
  end

  # === ���[�N������
  def init_work
    @mode = ""
    @img_cnt = 0
    @img = nil
    @x = 0
    @y = 0
    @x_spd = 0
    @y_spd = 0
    @scale = 1.0
    @scale_tgt = 1.0
    @scale_spd = 0.0
    @fade_spd_now = 8
    @alpha = 255.0
    @framelist = Array.new
    @last_frame = 0 # �ŏI�t���[���l
    @imgs = @cfg.imgdt.get_img_list
    @imgfiles = @cfg.imgdt.get_img_files
    @scene_num = 0
  end

  attr_accessor :last_frame
  
  # === �t���[���l�������������z���ݒ�
  def set_framelist(lst)
    @framelist = lst
    @last_frame = @framelist[@framelist.length - 1]
  end
  
  # === �t���[���l�������������z���Ԃ�
  def get_framelist
    return @framelist
  end

  # === ���摜�؂�ւ��t���[���܂ł̃t���[�������擾����
  #
  # �Ԃ�l :: ���摜�؂�ւ��t���[���܂ł̃t���[����
  #          -1�Ȃ玟�̉摜�؂�ւ��t���[���͋L�^�ɂȂ�
  def get_next_frame_relative(now_frm)
    @framelist.each { |n|
      return (n - now_frm) if n > now_frm
    }
    return -1
  end

  # === exo�o�͗p�̏���Ԃ�
  #
  # �����́Aset_next_image() �Ɠ���
  def get_next_exoblock(add, mode, frm)
    nummax = @imgfiles.length
    @img_cnt = (@img_cnt + add) % nummax
    imgfn = @imgfiles[@img_cnt]
    # puts "length = #{nummax} , img_cnt = #{@img_cnt} , #{imgfn}"
    
    startfrm = frm + 1
    endfrm = startfrm + get_next_frame_relative(frm) - 1
    exb = ExoBlock.new(@scene_num,
                       startfrm, endfrm, mode,
                       imgfn, @scrw, @scrh)
    @scene_num += exb.get_add_num
    return exb
  end

  # === exo�̃T�E���h�����L�q�e�L�X�g��Ԃ�
  #
  # �Ԃ�l :: exo�̃T�E���h�����L�q������
  def get_last_exo_block
    return ExoBlock.get_text_sound_exo(@scene_num)
  end
  
  # === ���摜�\����ݒ�
  #
  # add ::  �摜�������i�߂邩
  # mode :: �A�j�����
  # frm ::  ���݃t���[��
  def set_next_image(add, mode, frm)
    @mode = mode
    @img_cnt = (@img_cnt + add) % @imgs.length
    @img = @imgs[@img_cnt]
    w = @img.width.to_f
    h = @img.height.to_f
    sw = @scrw.to_f
    sh = @scrh.to_f
    @x = (sw - w) / 2.0
    @y = (sh - h) / 2.0
    @scale = 1.0
    @alpha = 255.0
    spd = 1.0
    @x_spd, @y_spd = 0, 0
    @scale = @scale_tgt = [(sw / w), (sh / h)].max
    @scale_spd = 0.0
    d = get_next_frame_relative(frm) # ���̐؂�ւ��܂ł̃t���[�����𓾂�
    
    case @mode
    when "up", "down", "left", "right"
      # PAN�B�X�N���[�����x������
      dir_dic = {
        "up" => [0, -1],
        "down" => [0, 1],
        "left" => [-1, 0],
        "right" => [1, 0]
      }
      spdx, spdy = spd * dir_dic[@mode][0], spd * dir_dic[@mode][1] 
      @x, @y, @x_spd, @y_spd, @scale = Scroll.get_spd(@x, @y, @scale, w, h,
                                                      sw, sh, spdx, spdy, d)

    when "t.u", "t.u2"
      # �g���b�N�A�b�v�B�Y�[���C������B
      @scale_tgt = (@scale < 1.0)? 1.0 : (@scale + 0.5)
      if @mode == "t.u"
        d = 3.0 * @fpsv if d < 0
        @scale_spd = (@scale_tgt - @scale) / d.to_f
      end

    when "t.b", "t.b2"
      # �g���b�N�o�b�N�B�Y�[���A�E�g����B
      @scale = (@scale < 1.0)? 1.0 : (@scale + 0.5)
      if @mode == "t.b"
        d = 3.0 * @fpsv if d < 0
        @scale_spd = (@scale_tgt - @scale) / d.to_f
      end
      
    when "f.o", "w.o"
      # �t�F�[�h�A�E�g���x������
      @fade_spd_now = (d < 0)? 8 : (255.0 / d.to_f)
      @alpha = 0.0
      
    when "f.i", "w.i"
      # �t�F�[�h�C�����x������
      @fade_spd_now = (d < 0)? 8 : (255.0 / (d.to_f / 2))
      @alpha = 255.0
      
    end
  end

  # === �摜��`��
  def draw
    case @mode
    when "fix"
      # �Œ�
      Window.drawScale(@x, @y, @img, @scale, @scale)

    when "up", "down", "left", "right"
      # PAN�B�㉺���E�ɃX�N���[��
      Window.drawScale(@x, @y, @img, @scale, @scale)
      
    when "t.u", "t.u2", "t.b", "t.b2"
      # track up , track back
      Window.drawScale(@x, @y, @img, @scale, @scale) if @scale > 0.0
      
    when "f.o", "w.o"
      # fade out , white out
      Window.drawScale(@x, @y, @img, @scale, @scale)
      Window.drawAlpha(0, 0, (@mode == "f.o")? @blackimg : @whiteimg, @alpha)
      
    when "f.i", "w.i"
      # fade in , white in
      Window.drawScale(@x, @y, @img, @scale, @scale)
      Window.drawAlpha(0, 0, (@mode == "f.i")? @blackimg : @whiteimg, @alpha)
    end

    update_pos
  end

  # === RenderTarget�ɕ`��
  def draw_rendertarget(render)
    render.draw(0, 0, @blackimg) # ���x�^�œh���ăN���A
    case @mode
    when "fix"
      render.drawScale(@x, @y, @img, @scale, @scale)
    when "up", "down", "left", "right"
      render.drawScale(@x, @y, @img, @scale, @scale)
    when "t.u", "t.u2", "t.b", "t.b2"
      render.drawScale(@x, @y, @img, @scale, @scale) if @scale > 0.0
    when "f.o", "w.o"
      render.drawScale(@x, @y, @img, @scale, @scale)
      render.drawAlpha(0, 0, (@mode == "f.o")? @blackimg : @whiteimg, @alpha)
    when "f.i", "w.i"
      render.drawScale(@x, @y, @img, @scale, @scale)
      render.drawAlpha(0, 0, (@mode == "f.i")? @blackimg : @whiteimg, @alpha)
    end
    render.update
  end
  
  # ���W�l���̑����X�V
  def update_pos
    case @mode
    when "up", "down", "left", "right"
      # PAN�B�㉺���E�ɃX�N���[��
      @x += @x_spd
      @y += @y_spd
      
    when "t.u", "t.b"
      # track up , track back
      if @scale > 0.0 then
        @scale += @scale_spd
      end
      
    when "t.u2", "t.b2"
      # track up , track back
      if @scale > 0.0 then
        @scale += (@scale_tgt - @scale) / 3.5
      end
      
    when "f.o", "w.o"
      # fade out , white out
      if @alpha < 255
        @alpha += @fade_spd_now
        @alpha = 255 if @alpha >= 255
      end
      
    when "f.i", "w.i"
      # fade in , white in
      if @alpha > 0.0
        @alpha -= @fade_spd_now
        @alpha = 0 if @alpha <= 0
      end
    end
  end
  
end
