#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/01 17:04:45 +0900>
#
# メッセージ表示ウインドウ用クラス

class MessageWindow
  NMLWDW = 1
  ERRWDW = 2
  
  def initialize(cfg)
    @scrw, @scrh = cfg.get_screen_size
    @msgimg = []
    resdir = cfg.get_res_dir
    @msgimg.push(Image.load(resdir + 'msgbg_normal.png'))
    @msgimg.push(Image.load(resdir + 'msgbg_error.png'))
    @msg_kind = 0
    @msg = nil
    @msg_timer = 0
    @fnt = Font.new(12, 'ＭＳ ゴシック')
  end

  # メッセージ表示を設定
  def set_msg(str, sec, fpsv, kind)
    @msg_kind = kind
    @msg = str.split("\n")
    @msg_timer = (sec * fpsv).to_i
  end

  # メッセージ表示タイマーを更新
  def update
    if @msg_kind > 0
      # メッセージ表示中
      @msg_timer -= 1
      if @msg_timer <= 0
        @msg = nil
        @msg_kind = 0
      end
      return true
    end
    return false
  end

  # メッセージ描画
  def draw
    draw_msg(@msg, @msg_kind) if @msg_kind > 0
  end

  # メッセージ描画実処理
  def draw_msg(str, kind)
    # メッセージ枠を描画
    img = @msgimg[kind - 1]
    x = (@scrw - img.width) / 2
    y = (@scrh - img.height) / 2
    Window.draw(x, y, img, 10)

    # メッセージ文字列を描画
    x += 8
    y += 16
    str.each do |s|
      Window.drawFont(x, y, s, @fnt, :color => [0,0,0], :z => 11)
      y += (@fnt.size + 6)
    end
  end
end
