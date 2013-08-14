#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 14:39:04 +0900>
#
# FPS計算のテスト用
#
# utime で求めたフレーム数と、
# DXRubyのメインループで求めたフレーム数を表示して
# ずれがでてくるかどうかを確認する。
#
# 5分間動かすと総フレーム数を出力する。

require 'dxruby'

# デスクトップ解像度を設定(ウインドウ表示位置を指定する際に使う)
YOUR_DESKTOP_WIDTH = 1920
YOUR_DESKTOP_HEIGHT = 1080
FPSV = 24

def get_utime
  ct = Time.now
  return (ct.tv_sec * 1000000) + ct.usec
end

def get_frame(st, fpsv)
  return (get_utime - st) * fpsv / 1000000
end

def get_time_value(cnt, fpsv)
  f = cnt % fpsv
  cnt -= f
  s = cnt / fpsv
  m = s / 60
  h = m / 60
  m %= 60
  s %= 60
  return h, m, s, f
end

def main
  count = 0
  font = Font.new(36, 'ＭＳ ゴシック')
  Window.fps = FPSV
  Window.x = YOUR_DESKTOP_WIDTH - 640 -64
  Window.y = YOUR_DESKTOP_HEIGHT - 480 -128

  st = get_utime
  
  Window.loop do
    break if Input.keyPush?(K_ESCAPE)
    st = get_utime if Input.keyPush?(K_S)
    cnt = get_frame(st, FPSV)
    h, m, s, f = get_time_value(cnt, FPSV)
    x, y = 16, 120
    Window.drawFont(x, y,
                    format("utime  %02d:%02d:%02d + %02d", h, m, s, f),
                    font)
    
    h, m, s, f = get_time_value(count, FPSV)
    y += font.size + 16
    Window.drawFont(x, y,
                    format("DXRuby %02d:%02d:%02d + %02d", h, m, s, f),
                    font)

    if count >= 5 * 60 * FPSV
      # n分経過したので終了
      puts "DXRuby frame count = #{count}"
      puts "usec   frame count = " + get_frame(st, FPSV).to_s
      break
    end
    count += 1
  end
  
end

main
