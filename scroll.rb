#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 08:13:21 +0900>
#
# スクロール速度を求める処理についての実験スクリプト
#
# Iキー : 画像変更
# カーソルキー : スクロール方向を変更
# Pキー : ポーズ切り替え
# Nキー : ポーズ中なら次のフレームへ
# Bキー : 押してる間はポーズ状態を解除

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

  # === 初期表示位置とスクロール速度を設定する
  #
  # x, y       ::   現在の初期位置
  # scale ::        既に求めた拡大縮小率
  # w, h ::         画像サイズ  
  # scrw, scrh ::   画面サイズ
  # spdx, spdy ::   x, y の速度 (-n or +n)
  # d ::            何フレームで移動するか
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
      # 次の切り替え時までのフレーム数が皆無
      # 設定のしようがない
    elsif d < 0
      # 次の切り替え時までのフレーム数が不明
      # 固定値で初期位置と速度を決める
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
      # 次の切り替え時までのフレーム数は確定している
      # 速度を求めることが可能
      
      flip_fg = (spdy != 0)? true : false
      if flip_fg
        x, y = y, x
        w, h = h, w
        sw, sh = sh, sw
        spdx, spdy = spdy, spdx
      end

      # x方向のスクロールと仮定して計算
      if w > sw
        # スクロールする方向については画像が画面より大きい
        if h >= sh
          # スクロールしない方向の画像サイズも十分満たしてる
          scale = 1.0
          dist = (w - sw) / 2.0
          dist *= -1 if spdx < 0
          tgt = x + dist
          x -= dist
          x_spd = (tgt - x).to_f / d.to_f
        else
          # スクロールしない方向の画像サイズが画面より小さい
          scale = sh / h # 若干拡大する
          dist = (w * scale - sw) / 2.0
          dist *= -1 if spdx < 0
          tgt = x + dist
          x -= dist
          x_spd = (tgt - x).to_f / d.to_f
        end
      else
        # 縦横共に画像が画面より小さい
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
  # === テスト動作用の更新描画処理
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
      # カーソルキーによるスクロール方向変更
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

      # 画像変更
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
        
        # 速度算出
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
           "I : 画像変更",
           "↑↓←→ : 方向変更",
           "P : ポーズ",
           "N : 次のフレームへ(ポーズ中のみ)",
           "B : 押してる間はポーズ解除(ポーズ中のみ)",
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


