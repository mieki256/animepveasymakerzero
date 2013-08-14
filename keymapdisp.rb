#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 17:58:09 +0900>
#
# キーボード画像表示用クラス

require 'dxruby'
require_relative 'anime'
require_relative 'animekind'
require_relative 'keyboardimage'

class KeymapDisp
  def initialize(cfg)
    @cfg = cfg
    @scrw, @scrh = @cfg.get_screen_size
    @resdir = @cfg.get_res_dir

    # 画像読み込み
    @keyonimg = Image.load(@resdir + 'key_on.png')
    @keyoneffectimg = Image.load(@resdir + 'key_on_effect.png')

    # 受け付けるキーの一覧等を取得
    @tbl = @cfg.get_key_tbl
    @enable_keys = AnimeKind.get_enable_key_list(@tbl)
    @keys_about = AnimeKind.get_key_about_dic(@tbl)
    @keys_mode = AnimeKind.get_key_mode_dic(@tbl)

    # キーボード画像生成
    @keyimg, @key_pos = KeyboardImage.make_image(@enable_keys, @keys_about, @resdir)
    @base_x = @scrw - @keyimg.width - 10
    @base_y = @scrh - @keyimg.height - 20
    
    init_work
  end

  # ワーク初期化
  def init_work
    @pushkey = ""
    @push_enable = false
    @push_x = 0
    @push_y = 0
    @push_alpha = 255
    @push_scale = 1.0
    @push_scale2 = 1.0
  end
  
  # 押されたキーを記憶
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

  # 表示キーボードをマウスボタンでクリックされたか調べる
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
          # マウスポインタがキー表示の上にある
          if Input.mousePush?(M_LBUTTON)
            # マウスボタンが押されてる
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

    # 押されたキーが分かるようにマークを描画
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

