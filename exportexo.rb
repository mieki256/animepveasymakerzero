#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 12:10:53 +0900>
#
# exo�t�@�C���G�N�X�|�[�g����

require_relative 'config'
require_relative 'laps'
require_relative 'anime'

# ----------------------------------------
#
# === exo�t�@�C���ɏo�͂�������L�^�E�v�Z����N���X
#
# �ȉ��́A2013/07/27���݂�exo�t�@�C�����L�q�ɂ��Ẵ���
#
# ==== x,y,z,�g�嗦���ɂ��āB
# * �ω��������ꍇ�́A�l�݂̂̋L�q�ɂȂ�B
# * �����ړ����́A[�J�n�l, �I���l, 1] �̋L�q�ɂȂ�B
# * �������ړ����́A[�J�n�l, �I���l, 0x?7] �ɂȂ�͗l�B
#   �Ō�̒l�́A
#   * 0x27�Ȃ猸���̂݁B
#   * 0x47�Ȃ�����̂݁B
#   * 0x67 �Ȃ���������B
# �����炭�ȉ��̂悤�Ȋ���U��B
# (0as0 0111)B
#   ||
#   |+-- �����t���O
#   +--- �����t���O
#
class ExoBlock
  def initialize(num, startfrm, endfrm, mode, imgfn, scrw, scrh)
    @num = num
    @mode = mode
    @scrw, @scrh = scrw, scrh
    @imgfn = imgfn
    @start_frame = startfrm
    @end_frame = endfrm
  end

  # ���[�h�ɉ����đf�ޔԍ�����������邩��Ԃ�
  def get_add_num
    ret = 1
    case @mode
    when "f.i", "f.o", "w.i", "w.o"
      ret = 2
    end
    return ret
  end

  # �p�����[�^���ω����Ă����ꍇ�̃e�L�X�g�𕶎���ŕԂ�
  def get_array_s(s, v)
    l = Array.new
    l.push(sprintf("%.2f", v[0]))
    l.push(sprintf("%.2f", v[1]))
    l.push(sprintf("%d", v[2]))
    return "#{s}=" + l.join(",")
  end

  # exo�t�@�C�����ɏo�͂��ׂ��e�L�X�g��Ԃ�
  def get_text
    if @mode == "end"
      return ""
    end

    # �摜���[�h
    fg = true
    begin
      begin
        img = Image.load(@imgfn)
      rescue
        fg = true
        sleep(0.5)
      else
        fg = false
      end
    end while fg
    fn = @imgfn.gsub(/\//, "\\")
    
    l = ["[#{@num}]",
         "start=#{@start_frame}", "end=#{@end_frame}",
         "layer=1", "overlay=1", "camera=1",
         "[#{@num}.0]",
         "_name=�摜�t�@�C��", "file=#{fn}" ]

    w, h = img.width, img.height
    
    # �g��k����������
    sx = @scrw.to_f / w.to_f
    sy = @scrh.to_f / h.to_f
    scale = ([sx, sy].max) * 100.0

    # ���̑������܂�̕������ݒ�
    alpha_str = "�����x=0.0"
    rot_str = "��]=0.0"
    blend_str = "blend=0"

    case @mode
    when "fix"
      # �Œ�
      l += ["[#{@num}.1]",
            "_name=�W���`��", "X=0.0", "Y=0.0", "Z=0.0",
            "�g�嗦=#{scale}", alpha_str, rot_str, blend_str]

    when "end"
      # �ŏI�t���[��
      
    when "up", "down"
      # y�����X�N���[��
      if scale < 100.0
        # �摜�̂ق�����ʃT�C�Y���傫��
        d = (h - @scrh) / 2.0
        tscale = "100.00"
      else
        # �摜�̂ق�����ʃT�C�Y��菬����
        new_scale = scale + 50
        d = ((h * new_scale / 100.0) - @scrh) / 2.0
        tscale = sprintf("%.2f", new_scale)
      end
      v = (@mode == "up")? [d,-d,1] : [-d,d,1]
      l += ["[#{@num}.1]",
            "_name=�W���`��", "X=0.0", get_array_s("Y", v), "Z=0.0",
            "�g�嗦=#{tscale}", alpha_str, rot_str, blend_str]
      
    when "left", "right"
      # x�����X�N���[��
      if scale < 100.0
        d = (w - @scrw) / 2.0
        tscale = "100.00"
      else
        new_scale = scale + 50
        d = ((w * new_scale / 100.0) - @scrw) / 2.0
        tscale = sprintf("%.2f", new_scale)
      end
      v = (@mode == "left")? [d,-d,1] : [-d,d,1]
      l += ["[#{@num}.1]",
            "_name=�W���`��", get_array_s("X", v), "Y=0.0", "Z=0.0",
            "�g�嗦=#{tscale}", alpha_str, rot_str, blend_str]
    
    when "t.u", "t.b"
      # �g���b�N�A�b�v (�g��)�A�g���b�N�o�b�N (�k��)
      if @mode == "t.u"
        if scale < 100.0
          tgt = 100.0
        else
          tgt = scale + 50.0
        end
      else
        tgt = scale
        if scale < 100.0
          scale = 100.0
        else
          scale = scale + 50.0
        end
      end
      tscale = [scale, tgt, 1]
      l += ["[#{@num}.1]",
            "_name=�W���`��", "X=0.0", "Y=0.0", "Z=0.0",
            get_array_s("�g�嗦", tscale),
            alpha_str, rot_str, blend_str]
      
    when "t.u2", "t.b2"
      # �g���b�N�A�b�v (�g��)�A�g���b�N�o�b�N (�k��)
      if @mode == "t.u"
        if scale < 100.0
          tgt = 100.0
        else
          tgt = scale + 50.0
        end
      else
        tgt = scale
        if scale < 100.0
          scale = 100.0
        else
          scale = scale + 50.0
        end
      end
      tscale = [scale, tgt, 0x27]
      l += ["[#{@num}.1]",
            "_name=�W���`��", "X=0.0", "Y=0.0", "Z=0.0",
            get_array_s("�g�嗦", tscale),
            alpha_str, rot_str, blend_str]
      
    when "f.o"
      # �t�F�[�h�A�E�g (�ʏ�̖��邳 �� �^����)
      l += get_fade_text(@num, 'out', '000000', scale)
      
    when "f.i"
      # �t�F�[�h�C�� (�^���� �� �ʏ�̖��邳)
      l += get_fade_text(@num, 'in', '000000', scale)
      
    when "w.o"
      # �z���C�g�A�E�g (�ʏ�̖��邳 �� �^����)
      l += get_fade_text(@num, 'out', 'ffffff', scale)
      
    when "w.i"
      # �z���C�g�C�� (�^���� �� �ʏ�̖��邳)
      l += get_fade_text(@num, 'in', 'ffffff', scale)
    end
    
    return l.join("\n") + "\n"
  end
  
  # === �t�F�[�h�A�E�g�E�C���A�z���C�g�t�F�[�h�A�E�g�E�C���p�̕������Ԃ�
  def get_fade_text(num, mode, color_str, scale)
    alpha_str = (mode == 'out')? "100.0,0.0,1" : "0.0,100.0,1"
    num_s = num + 1
    l = [ "[#{@num}.1]",
          "_name=�W���`��",
          "X=0.0", "Y=0.0", "Z=0.0",
          "�g�嗦=#{scale}",
          "�����x=0.0", "��]=0.0", "blend=0",
          
          "[#{num_s}]",
          "start=#{@start_frame}", "end=#{@end_frame}",
          "layer=2",
          "overlay=1", "camera=1",
          
          "[#{num_s}.0]",
          "_name=�}�`", "�T�C�Y=100", "�c����=0.0",
          "���C����=4000", "type=0",
          "color=#{color_str}",
          "name=",
          
          "[#{num_s}.1]",
          "_name=�W���`��", "X=0.0", "Y=0.0", "Z=0.0", "�g�嗦=100.00",
          "�����x=#{alpha_str}",
          "��]=0.00", "blend=0" ]
    
    return l
  end

  # === ���x�^�p�̕������Ԃ�
  def get_black_only(num)
    lines = <<EOS
[#{num}.0]
_name=�}�`
�T�C�Y=100
�c����=0.0
���C����=4000
type=0
color=000000
name=
[#{num}.1]
_name=�W���`��
X=0.0
Y=0.0
Z=0.0
�g�嗦=100.00
�����x=0.0
��]=0.00
blend=0
EOS
    return lines.split(/\n/)
  end
  
  # === �T�E���h�w��p�̃e�L�X�g��Ԃ�
  def ExoBlock.get_text_sound_exo(cnt)
    lines = <<EOS
[#{cnt}]
start=1
end=6
layer=3
overlay=1
audio=1
[#{cnt}.0]
_name=�����t�@�C��
�Đ��ʒu=0.00
�Đ����x=100.0
���[�v�Đ�=0
����t�@�C���ƘA�g=1
file=
[#{cnt}.1]
_name=�W���Đ�
����=100.0
���E=0.0
EOS
    return lines
  end
  
  # === exo�̃w�b�_�����񑊓���Ԃ�
  def ExoBlock.get_exo_header(scrw, scrh, fps, lastframe)
    
    lines = <<EOS
[exedit]
width=#{scrw}
height=#{scrh}
rate=#{fps}
scale=1
length=#{lastframe}
audio_rate=44100
audio_ch=2
EOS
    
    return lines
  end

end

# ----------------------------------------
#
# === exo�t�@�C�����o��
#
class ExportExo
  
  # exo�t�@�C�����o��
  def ExportExo.export_exo_file(fn, cfg, lap)
    outstr = ""
    @anime = Anime.new(cfg)
    @anime.set_framelist(lap.get_frame_list)
    
    s = ExoBlock.get_exo_header(cfg.get_value('screenwidth'),
                                cfg.get_value('screenheight'),
                                cfg.get_fps,
                                @anime.last_frame)
    outstr += s
    
    exb = @anime.get_next_exoblock(0, lap.laps[0], 0)
    outstr += exb.get_text
    
    @frame = 0
    while @frame <= @anime.last_frame
      if (lap.lap_exist?(@frame) and @frame > 0)
        mode = lap.get_mode(@frame)
        unless mode == "end"
          exb = @anime.get_next_exoblock(1, mode, @frame)
          outstr += exb.get_text
        end
      end
      @frame += 1
    end
    outstr += @anime.get_last_exo_block

    f = File.open(fn, "w")
    f.write(outstr)
    f.close
  end
end

if $0 == __FILE__

  kind = "ExportExo"
  # kind = "ExoBlock"

  case kind
  when "ExportExo"
    # ExportExo �̓���e�X�g
    cfg = Conf.instance
    lap = Laps.new(cfg)
    lap.get_log
    outfn = "output/_log.exo"
    
    if cfg.imgdt.load_init(cfg.get_value('imgdir'))
      puts "�摜��ǂݍ��ݒ� ... "
      r = ""
      begin
        r = cfg.imgdt.load_img
        # puts "load : #{r}"
      end until r == "loadok"
      
      puts "exo���o�͒� ... "
      ExportExo.export_exo_file(outfn, cfg, lap)
      puts "output #{outfn}"
    else
      puts "image data load init failure."
    end
    
  when "ExoBlock"
    # ExoBlock�̓���e�X�g
    scrw, scrh = 640, 360
    puts ExoBlock.get_exo_header(scrw, scrh, 24, 200)
    
    dirname = "sampledata\\image2\\"
    dt = [
          [0, 1, 15, "fix", "001.jpg", scrw, scrh],
          [1, 16, 29, "up", "002.jpg", scrw, scrh],
          [1, 16, 29, "down", "002.jpg", scrw, scrh],
          [1, 16, 29, "left", "002.jpg", scrw, scrh],
          [1, 16, 29, "right", "002.jpg", scrw, scrh],
          [1, 16, 29, "t.u", "002.jpg", scrw, scrh],
          [1, 16, 29, "t.b", "003.jpg", scrw, scrh],
          [1, 16, 29, "f.o", "003.jpg", scrw, scrh],
          [1, 16, 29, "f.i", "003.jpg", scrw, scrh],
          [1, 16, 29, "w.o", "003.jpg", scrw, scrh],
          [1, 16, 29, "w.i", "003.jpg", scrw, scrh],
         ]

    dt.each do |d|
      num, sfrm, efrm, mode, fn, sw, sh = d
      fn = dirname + fn
      exb = ExoBlock.new(num, sfrm, efrm, mode, fn, sw, sh)
      puts exb.get_text
    end
  end
  
end


