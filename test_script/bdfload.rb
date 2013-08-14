#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 14:46:59 +0900>
#
# BDF�t�H���g�� Ruby/SDL ���g���ēǂݍ���ŕ`�悵�Ă݂�e�X�g
#
# * S�L�[�ŉ摜�Ƃ��ĕۑ�
# * ESC�ŏI��
# * Ruby/SDL���g�p
#
# * ASCII������ bdf2bmp �ŏo�͂����ق���������������Ȃ��B
#   bdf2bmp -s0 -c16 hoge.bdf hoge.bmp �Ƃ��B
#   * -s0 �̓X�y�[�V���O��0�ɂ���w��B
#   * -c16 �́A1�s��16�����`�悷��w��B

require 'sdl' 

# �`�悷��t�H���g���
fontkind = 0

# ���p�J�i���o�͂��邩�ۂ�
hankana_on = true

# �t�H���g��ނ̒�`
FG_KANJI = true # ������`��
FG_ASCII = false # ASCII������`��
fname_list = [
              # BDF�t�H���g�t�@�C����, bmp�ۑ��t�@�C����, �t�H���g����, �c��, �������ۂ�
              ['mplus_j10r.bdf', 'mplus_j10r.bmp', 10, 11, FG_KANJI],
              ['shnmk12.bdf', 'shnmk12.bmp', 12, 12, FG_KANJI],
              ['shnm6x12r.bdf', 'shnm6x12r.bmp', 6, 12, FG_ASCII],
             ]

bdf_fname, save_fname, fw, fh, kanji = fname_list[fontkind]

if kanji
  x_num, y_num = 94, 94
else
  x_num, y_num = 16, 16
end

fimgw = fw * x_num
fimgh = fh * y_num

scrw, scrh = 640, 480
SDL.init( SDL::INIT_VIDEO ) 
screen = SDL.setVideoMode( scrw, scrh, 32, SDL::SWSURFACE )

# �t�H���g��`�悷��Surface�𐶐�
fontimg = SDL::Surface.new(SDL::SWSURFACE, fimgw, fimgh, 32, 0, 0, 0, 0)

jis_enable = false

# BDF�t�H���g�ǂݍ���
font = SDL::Kanji.open(bdf_fname, fh)

# �G���R�[�f�B���O���w��
unless jis_enable
  # SJIS
  font.set_coding_system(SDL::Kanji::SJIS)
else
  # JIS
  font.set_coding_system(SDL::Kanji::JIS)
end

# �`�悷�镶�������X�g�A�b�v
codelist = []
if kanji
  # ����
  unless jis_enable
    # SJIS
    for u in 0x81..0x9f do
      for l in 0x40..0xfc do
        next if l == 0x7f
        code = (u << 8) + l
        s = sprintf("%c", code)
        codelist.push(s)
      end
    end
    for u in 0xe0..0xef do
      for l in 0x40..0xfc do
        next if l == 0x7f
        code = (u << 8) + l
        s = sprintf("%c", code)
        codelist.push(s)
      end
    end
  else
    #JIS (��肭�����Ȃ��c)
    for u in 0x21..0x7e do
      for l in 0x21..0x7e do
        code = [u, l]
        s = code.pack("C*")
        codelist.push(s)
      end
    end
  end
else
  # ASCII
  for u in 0x00..0x7f
    codelist.push(u.chr)
  end
  if hankana_on
    # ���p�J�i���o��
    for u in 0x80..0xff
      if 0xa1 <= u and u <= 0xdf
        codelist.push(u.chr)
      else
        codelist.push(' ')
      end
    end
  end
end

# Surface�Ƀt�H���g��`��
codelist.each_with_index do |s, i|
  x = (i % x_num) * fw
  y = (i / y_num) * fh
  font.put(fontimg, s, x, y, 255, 255, 255)
end

interval = 1.0 / 60
save_fg = false
dispx, dispy = 0, 0

# ���C�����[�v
loop do
  loop_start = SDL.getTicks / 1000.0
  while event = SDL::Event2.poll
    case event
    when SDL::Event2::Quit
      exit
    when SDL::Event2::KeyDown
      if event.sym == SDL::Key::S
        # Surface���摜�Ƃ��ĕۑ�
        unless save_fg
          fontimg.saveBMP(save_fname)
          save_fg = true
        end
      elsif event.sym == SDL::Key::ESCAPE
        exit
      end
    end
  end

  # �}�E�X�J�[�\�����W�̈ʒu�ɉ����ăX�N���[��
  mx, my, lb, mb, rb = SDL::Mouse.state
  spd = 0.3
  if mx < scrw * 0.3
    dispx += ((scrw * 0.3) - mx) * spd
    if dispx > 0
      dispx = 0
    end
  end
  if mx > scrw * 0.7
    dispx -= (mx - (scrw * 0.7)) * spd
    fiw = fimgw - scrw
    if dispx < -fiw
      dispx = -fiw
    end
  end
  if my < scrh * 0.3
    dispy += ((scrh * 0.3) - my) * spd
    if dispy > 0
      dispy = 0
    end
  end
  if my > scrh * 0.7
    dispy -= (my - (scrh * 0.7)) * spd
    fih = fimgh - scrh
    if dispy < -fih
      dispy = -fih
    end
  end

  # �`��
  screen.fillRect( 0, 0, scrw, scrh, [ 0, 0, 0 ] )
  screen.put(fontimg, dispx, dispy)
  screen.updateRect( 0, 0, 0, 0 )

  loop_end = SDL.getTicks / 1000.0
  if loop_end - loop_start < interval
    sleep interval - (loop_end - loop_start)
  end
  
end
