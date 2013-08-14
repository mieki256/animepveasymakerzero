#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 11:41:51 +0900>
#
# ビットマップフォント描画用クラス
# 美咲フォント、k12x10フォント、5x5フォントなどをDXRubyで使用してみる
#
# 8×8ドット日本語フォント「美咲フォント」
# http://www.geocities.jp/littlimi/misaki.htm
#
# k12x10 font
# http://z.apps.atjp.jp/k12x10/
#
# 5x5フォント - 2006-08-14 - 兼雑記
# http://d.hatena.ne.jp/shinichiro_h/20060814#1155567183
#
# M+ FONTS
# http://mplus-fonts.sourceforge.jp/
#
# 東雲フォント
# http://openlab.ring.gr.jp/efont/shinonome/
#
# bdf2bmp
# http://hp.vector.co.jp/authors/VA013241/font/bdf2bmp.html

require 'dxruby'
require 'benchmark'

class BitmapFont
  # 全てのフォントを使うか否か
  ALL_USE = false
  
  # ビットマップフォントの画像種類を定義
  FontDt = Struct.new("FontImg", :kind, :filename, :imgw, :imgh, :fontw, :fonth)
  KD_ASCII = 0
  KD_KANJI = 1

  # フォントリストは、ASCII文字と漢字の2つずつ列挙する
  FNT_LIST = [
              # ASCII/kanji=0/1 , filename, width, height, font-width, font-height
              
              # kind 0
              # 5x5フォント
              FontDt::new(KD_ASCII, '5x5_ascii.png', 96, 96, 6, 6),
              FontDt::new(KD_KANJI, '', 96, 96, 6, 6),
             ]
  
  FNT_LIST2 = [
              # kind 1
              # M+フォント
              FontDt::new(KD_ASCII, 'mplus_f10r_6x13.png', 96, 182, 6, 13),
              FontDt::new(KD_KANJI, 'mplus_j10r_10x11.png', 940, 1034, 10, 11),

              # kind 2
              # 美咲フォント
              FontDt::new(KD_ASCII, 'misaki_4x8_jisx0201.png', 64, 128, 4, 8),
              FontDt::new(KD_KANJI, 'misaki_gothic.png', 752, 752, 8, 8),
              
              # kind 3
              # k12x10フォント
              FontDt::new(KD_ASCII, 'k12x10_ascii.png', 96, 160, 6, 10),
              FontDt::new(KD_KANJI, 'k12x10_kanji.png', 1128, 940, 12, 10),
              
              # kind 4
              # 東雲フォント 12x12
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
          # 漢字
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

  # Imageに文字列を描画する
  def drawFont(x, y, img, str, fontkind)
    str.split("").each do |s|
      code = s.bytes.to_a[0]
      if (0x81 <= code and code <= 0x9f) or (0xe0 <= code and 0xfc)
        # SJIS漢字
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

  # フォントの横幅を取得
  def get_font_width(fontkind)
    return @ascii_imgs[fontkind][0x20].width
  end
  
  # フォントの縦幅を取得
  def get_font_height(fontkind)
    return @ascii_imgs[fontkind][0x20].height
  end

  # フォント画像に境界線を1ドット追加する
  # 引数は、フォント種類, フォントのドット色([a,r,g,b]), 境界線色([a,r,g,b])
  #
  # ※ めちゃくちゃ処理時間がかかる・待たされるので注意
  #
  def add_border(fontkind, fgcol, bdcol)
    aimgs = @ascii_imgs[fontkind]
    add_border_one2(aimgs, fgcol, bdcol) if aimgs != nil
    
    kimgs = @kanji_imgs[fontkind]
    add_border_one2(kimgs, fgcol, bdcol) if kimgs != nil
  end

  # フォント画像に対して境界線を追加する(1ドットずつ調べてつけていく方法)
  def add_border_one(imgs, fgcol, bdcol)
    a = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    imgs.each do |img|
      imgw = img.width
      imgh = img.height
      imgh.times do |y|
        imgw.times do |x|
          if img.compare(x, y, fgcol)
            # ドットがある
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
  
  # フォント画像に対して境界線を追加する(上下左右にずらして何度か描画する方法)
  def add_border_one2(imgs, fgcol, bdcol)
    # a = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [1, -1], [-1, 1], [1, 1]]
    a = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    imgs.each do |img|
      imgw = img.width
      imgh = img.height
      timg = Image.new(imgw, imgh)
      bimg = img.clone
      
      # 境界線色で描かれたフォント画像を生成
      imgh.times do |y|
        imgw.times do |x|
          bimg[x, y] = bdcol if bimg.compare(x, y, fgcol)
        end
      end
      
      # 位置をずらして描画
      a.each do |v|
        timg.draw(v[0], v[1], bimg)
      end
      timg.draw(0, 0, img)

      # 上書き
      img.draw(0, 0, timg)
    end
  end
  
end

# 動作テスト用
if $0 == __FILE__
  t = BitmapFont.new('./res/') # テスト
  
  sw, sh = 640, 360
  Window.resize(sw, sh)
  Window.bgcolor = [0, 220, 128]
  img = Image.new(sw -  32, sh - 32, [64, 0, 0, 0])
  
  puts Benchmark::CAPTION
  puts Benchmark.measure {
    # 境界線の追加テスト
    t.add_border(1, [255, 255, 255, 255], [255, 0, 0, 0])
  }
  
  strlist = [
             "01234567890-^\\ qwertyuiop QWERTYUIOP@[",
             "asdfghjkl ASDFGHJKL;:] zxcvbnm ZXCVBNM,./",
             "ZOOM UP  PAN DOWN  PAN UP  FIX  LOG DEL  RETRY",
             "記録消去 やり直し あいうえお 新しい朝が来た 希望の朝だ",
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

