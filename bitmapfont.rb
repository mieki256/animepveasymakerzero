#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 11:41:51 +0900>
#
# �r�b�g�}�b�v�t�H���g�`��p�N���X
# ����t�H���g�Ak12x10�t�H���g�A5x5�t�H���g�Ȃǂ�DXRuby�Ŏg�p���Ă݂�
#
# 8�~8�h�b�g���{��t�H���g�u����t�H���g�v
# http://www.geocities.jp/littlimi/misaki.htm
#
# k12x10 font
# http://z.apps.atjp.jp/k12x10/
#
# 5x5�t�H���g - 2006-08-14 - ���G�L
# http://d.hatena.ne.jp/shinichiro_h/20060814#1155567183
#
# M+ FONTS
# http://mplus-fonts.sourceforge.jp/
#
# ���_�t�H���g
# http://openlab.ring.gr.jp/efont/shinonome/
#
# bdf2bmp
# http://hp.vector.co.jp/authors/VA013241/font/bdf2bmp.html

require 'dxruby'
require 'benchmark'

class BitmapFont
  # �S�Ẵt�H���g���g�����ۂ�
  ALL_USE = false
  
  # �r�b�g�}�b�v�t�H���g�̉摜��ނ��`
  FontDt = Struct.new("FontImg", :kind, :filename, :imgw, :imgh, :fontw, :fonth)
  KD_ASCII = 0
  KD_KANJI = 1

  # �t�H���g���X�g�́AASCII�����Ɗ�����2���񋓂���
  FNT_LIST = [
              # ASCII/kanji=0/1 , filename, width, height, font-width, font-height
              
              # kind 0
              # 5x5�t�H���g
              FontDt::new(KD_ASCII, '5x5_ascii.png', 96, 96, 6, 6),
              FontDt::new(KD_KANJI, '', 96, 96, 6, 6),
             ]
  
  FNT_LIST2 = [
              # kind 1
              # M+�t�H���g
              FontDt::new(KD_ASCII, 'mplus_f10r_6x13.png', 96, 182, 6, 13),
              FontDt::new(KD_KANJI, 'mplus_j10r_10x11.png', 940, 1034, 10, 11),

              # kind 2
              # ����t�H���g
              FontDt::new(KD_ASCII, 'misaki_4x8_jisx0201.png', 64, 128, 4, 8),
              FontDt::new(KD_KANJI, 'misaki_gothic.png', 752, 752, 8, 8),
              
              # kind 3
              # k12x10�t�H���g
              FontDt::new(KD_ASCII, 'k12x10_ascii.png', 96, 160, 6, 10),
              FontDt::new(KD_KANJI, 'k12x10_kanji.png', 1128, 940, 12, 10),
              
              # kind 4
              # ���_�t�H���g 12x12
              FontDt::new(KD_ASCII, 'shnm6x12r.png', 96, 192, 6, 12),
              FontDt::new(KD_KANJI, 'shnmk12_12x12.png', 1128, 1128, 12, 12),
             ]
  
  def initialize(resdir)
    @ascii_imgs = Array.new
    @kanji_imgs = Array.new

    @font_list = FNT_LIST
    @font_list += FNT_LIST2 if ALL_USE
    
    @font_list.each do |d|
      if d.filename != ''
        fn = resdir + d.filename
        imgs = Image.loadTiles(fn, d.imgw / d.fontw, d.imgh / d.fonth)
        if d.kind == 0
          # ASCII
          @ascii_imgs.push(imgs)
        else
          # ����
          @kanji_imgs.push(imgs)
        end
      else
        if d.kind == 0
          @ascii_imgs.push(nil)
        else
          @kanji_imgs.push(nil)
        end
      end
    end
  end

  attr_accessor :font_list

  # Image�ɕ������`�悷��
  def drawFont(x, y, img, str, fontkind)
    str.split("").each do |s|
      code = s.bytes.to_a[0]
      if (0x81 <= code and code <= 0x9f) or (0xe0 <= code and 0xfc)
        # SJIS����
        code_l = s.bytes.to_a[1]
        seq = ((code <= 0x9f)? (code - 0x81) : (code - 0xc1)) * 0xbc
        seq += ((code_l <= 0x7e)? (code_l - 0x40) : (code_l - 0x41))
        # ku = seq / 94
        # ten = seq % 94
        fontimg = @kanji_imgs[fontkind]
        if fontimg
          img.draw(x, y, fontimg[seq])
          x += fontimg[seq].width
        end
      else
        # ASCII
        fontimg = @ascii_imgs[fontkind]
        if fontimg
          img.draw(x, y, fontimg[code])
          x += fontimg[code].width
        end
      end
    end
  end

  # �t�H���g�̉������擾
  def get_font_width(fontkind)
    return @ascii_imgs[fontkind][0x20].width
  end
  
  # �t�H���g�̏c�����擾
  def get_font_height(fontkind)
    return @ascii_imgs[fontkind][0x20].height
  end

  # �t�H���g�摜�ɋ��E����1�h�b�g�ǉ�����
  # �����́A�t�H���g���, �t�H���g�̃h�b�g�F([a,r,g,b]), ���E���F([a,r,g,b])
  #
  # �� �߂��Ⴍ���Ꮘ�����Ԃ�������E�҂������̂Œ���
  #
  def add_border(fontkind, fgcol, bdcol)
    aimgs = @ascii_imgs[fontkind]
    add_border_one2(aimgs, fgcol, bdcol) if aimgs != nil
    
    kimgs = @kanji_imgs[fontkind]
    add_border_one2(kimgs, fgcol, bdcol) if kimgs != nil
  end

  # �t�H���g�摜�ɑ΂��ċ��E����ǉ�����(1�h�b�g�����ׂĂ��Ă������@)
  def add_border_one(imgs, fgcol, bdcol)
    a = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    imgs.each do |img|
      imgw = img.width
      imgh = img.height
      imgh.times do |y|
        imgw.times do |x|
          if img.compare(x, y, fgcol)
            # �h�b�g������
            a.each do |v|
              tx = x + v[0]
              next if (tx < 0 or imgw <= tx)
              ty = y + v[1]
              next if (ty < 0 or imgh <= ty)
              img[tx, ty] = bdcol unless img.compare(tx, ty, fgcol)
            end
          end
        end
      end
    end
  end
  
  # �t�H���g�摜�ɑ΂��ċ��E����ǉ�����(�㉺���E�ɂ��炵�ĉ��x���`�悷����@)
  def add_border_one2(imgs, fgcol, bdcol)
    # a = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [1, -1], [-1, 1], [1, 1]]
    a = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    imgs.each do |img|
      imgw = img.width
      imgh = img.height
      timg = Image.new(imgw, imgh)
      bimg = img.clone
      
      # ���E���F�ŕ`���ꂽ�t�H���g�摜�𐶐�
      imgh.times do |y|
        imgw.times do |x|
          bimg[x, y] = bdcol if bimg.compare(x, y, fgcol)
        end
      end
      
      # �ʒu�����炵�ĕ`��
      a.each do |v|
        timg.draw(v[0], v[1], bimg)
      end
      timg.draw(0, 0, img)

      # �㏑��
      img.draw(0, 0, timg)
    end
  end
  
end

# ����e�X�g�p
if $0 == __FILE__
  t = BitmapFont.new('./res/') # �e�X�g
  
  sw, sh = 640, 360
  Window.resize(sw, sh)
  Window.bgcolor = [0, 220, 128]
  img = Image.new(sw -  32, sh - 32, [64, 0, 0, 0])
  
  puts Benchmark::CAPTION
  puts Benchmark.measure {
    # ���E���̒ǉ��e�X�g
    t.add_border(1, [255, 255, 255, 255], [255, 0, 0, 0])
  }
  
  strlist = [
             "01234567890-^\\ qwertyuiop QWERTYUIOP@[",
             "asdfghjkl ASDFGHJKL;:] zxcvbnm ZXCVBNM,./",
             "ZOOM UP  PAN DOWN  PAN UP  FIX  LOG DEL  RETRY",
             "�L�^���� ��蒼�� ���������� �V������������ ��]�̒���",
             "",
            ]
  x, y = 0, 0
  (t.font_list.length / 2).times do |fontkind|
    h = t.get_font_height(fontkind)
    strlist.each do |s|
      t.drawFont(x, y, img, s, fontkind)
      y += h
    end
  end
  
  Window.loop do
    break if Input.keyPush?(K_ESCAPE)
    Window.draw(16, 16, img)
  end
end

