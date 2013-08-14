#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/01 20:54:22 +0900>
#
# 各シーンの基準クラス

require 'dxruby'
require_relative 'msgwdw'
require_relative 'laps'

# ----------------------------------------
#
# === 各シーン用の基本となるクラス
#
class SeqScene
  def initialize(cfg, lap, btnlist, step_kind, x, y)
    @cfg = cfg
    @lap = lap
    @step_kind = step_kind
    @scrw, @scrh = @cfg.get_screen_size
    @btns = BornButton::make(btnlist, @scrw, @scrh, @cfg.get_res_dir)
    @tgtofsx = @ofsx = x
    @tgtofsy = @ofsy = y
    @substep = 2
    @msg = MessageWindow.new(cfg)
  end

  attr_accessor :step_kind
  
  # === 座標更新処理、ボタンクリック処理
  def update(chkmouse)
    # 目標座標までの移動処理
    if @substep == 0
      dx = @tgtofsx - @ofsx
      dy = @tgtofsy - @ofsy
      if dx.abs < 1.0 and dy.abs < 1.0
        @ofsx = @tgtofsx
        @ofsy = @tgtofsy
        @substep = (@tgtofsx == 0 and @tgtofsy == 0)? 1 : 2
      else
        spd = 0.4
        @ofsx += dx * spd
        @ofsy += dy * spd
      end
      return -1
    end

    ret = BornButton::all_update(@btns, chkmouse)
    unless @msg.update
      # 押されたボタンに対応した処理を行う
      if ret != -1
        @cfg.click_se_req = true
      end
      return update_sub(ret)
    end
    return -1
  end

  # === 押されたボタンに対応する処理
  #
  # 継承したクラス側で処理内容を記述する
  def update_sub(kind)
    return kind
  end
  
  # === 描画処理
  def draw
    unless @substep == 2
      BornButton::all_draw(@btns, @ofsx, @ofsy)
      @msg.draw
    end
  end

  # === メッセージ描画を指定
  def set_msg(str, kind)
    @msg.set_msg(str, 2.5, @cfg.get_fps, kind)
  end
  
  # === フレームアウトするアニメを指示
  def frameout_down
    @tgtofsx = 0
    @tgtofsy = @scrh
    @substep = 0
  end
  
  def frameout_up
    @tgtofsx = 0
    @tgtofsy = -@scrh
    @substep = 0
  end
  
  def frameout_left
    @tgtofsx = -@scrw
    @tgtofsy = 0
    @substep = 0
  end
  
  def frameout_right
    @tgtofsx = @scrw
    @tgtofsy = 0
    @substep = 0
  end
  
  # === フレームインするアニメを指示
  def framein
    @tgtofsx = 0
    @tgtofsy = 0
    @substep = 0
    @msg_kind = 0
  end
  
end

# ----------------------------------------
#
# === 丸ボタン用クラス
#
class CircleButton
  def initialize(x, y, img, kind, keycode, img2)
    @x, @y = x, y
    @kind, @keycode = kind , keycode
    @img = img
    @img2 = img2
    @w = @img.width
    @h = @img.height
    @scale_def = (@w + 6.0) / @w.to_f
    @onmouse = false
  end

  # 座標更新処理
  def update(chkmouse)
    @onmouse = false
    if chkmouse and @kind >= 0
      # マウスカーソルが上にある状態かチェック
      mx = Input.mousePosX
      my = Input.mousePosY
      r = @w / 2
      dx = @x - mx
      dy = @y - my
      if dx * dx + dy * dy < r * r
        @onmouse = true
        return @kind if Input.mousePush?(M_LBUTTON)
      end

      if @keycode
        return @kind if Input.keyPush?(@keycode)
      end
    end
    return -1
  end

  # 描画処理
  def draw(ofsx, ofsy)
    x = @x - (@w / 2) + ofsx
    y = @y - (@h / 2) + ofsy
    if @img2
      # ボタンの上に位置する文字列画像を描画
      sx = @x - (@img2.width / 2) + ofsx
      sy = y - @img2.height - 8
      # Window.drawAlpha(sx, sy, @img2, 128)
      Window.draw(sx, sy, @img2)
    end
    scale = (@onmouse)? @scale_def : 1.0
    Window.drawScale(x, y, @img, scale, scale)
  end
end

# ----------------------------------------
#
# === 四角ボタン用クラス
#
class BoxButton
  def initialize(x, y, img, kind, keycode)
    @x, @y = x, y
    @kind, @keycode = kind, keycode
    @img = img
    @w = @img.width
    @h = @img.height
    @hw = @w / 2
    @hh = @h / 2
    @onmouse = false
  end

  # 座標更新処理
  def update(chkmouse)
    @onmouse = false
    if chkmouse and @kind >= 0
      # マウスカーソルが上にある状態かチェックする
      mx = Input.mousePosX
      my = Input.mousePosY
      x0 = @x - @hw
      y0 = @y - @hh
      x1 = @x + @hw
      y1 = @y + @hh
      if x0 <= mx and mx <= x1 and y0 <= my and my <= y1
        @onmouse = true
        # マウスボタンも押されてたら種類を返す
        return @kind if Input.mousePush?(M_LBUTTON)
      end
      
      # キーが押されたかチェックする
      if @keycode
        return @kind if Input.keyPush?(@keycode)
      end
    end
    return -1
  end

  # 描画処理
  def draw(ox, oy)
    x = @x - @hw + ox
    y = @y - @hh + oy
    Window.draw(x, y, @img)

    if @onmouse
      col = [255, 255, 255, 255]
      x1, y1 = x - 2, y - 2
      x2, y2 = x + @img.width + 1, y + @img.height + 1
      4.times do |i|
        Window.drawLine(x1, y1, x2, y1, col)
        Window.drawLine(x1, y2, x2, y2, col)
        Window.drawLine(x1, y1 + 1, x1, y2, col)
        Window.drawLine(x2, y1, x2, y2 + 1, col)
        x1 -= 1
        y1 -= 1
        x2 += 1
        y2 += 1
        col[0] -= 48
      end
    end
  end
end

# ----------------------------------------
#
# === 静止画像表示用クラス
#
class StillImage
  def initialize(x, y, img)
    @x, @y, @img = x, y, img
  end

  def update(chkmouse)
    return -1
  end

  def draw(ox, oy)
    x = @x - (@img.width / 2) + ox
    y = @y - (@img.height / 2) + oy
    Window.draw(x, y, @img)
  end
end

# ----------------------------------------
#
# === ボタン管理用クラス
#
class BornButton
  CBTN = 0
  BBTN = 1
  STIL = 2
  DEF_SCRW = 512.0
  DEF_SCRH = 288.0

  #
  # === 与えられた配列データに従い、ボタンを発生させる
  #
  def BornButton.make(lst, scrw, scrh, resdir)
    btns = []
    lst.each_with_index do |dt, i|
      btnkind, kind, keycode = dt[0], dt[1], dt[2]
      imgfn, txtfn, xd, yd = dt[3], dt[4], dt[5], dt[6]
      
      img = Image.load(resdir + imgfn)
      x, y = BornButton.get_pos(xd, yd, img.width, img.height, scrw, scrh)
      if btnkind == CBTN
        img2 = (txtfn != nil and txtfn != '')? Image.load(resdir + txtfn) : nil
        btns.push(CircleButton.new(x, y, img, kind, keycode, img2))
      elsif btnkind == BBTN
        btns.push(BoxButton.new(x, y, img, kind, keycode))
      else
        btns.push(StillImage.new(x, y, img))
      end
    end
    return btns
  end

  #
  # === 全ボタンに対して、カーソルが乗ったか、ボタンが押されたかをチェック
  #
  def BornButton.all_update(lst, chkmouse)
    ret = -1
    lst.each do |t|
      kind = t.update(chkmouse)
      ret = kind if (kind >= 0 and ret < 0)
    end
    return ret
  end

  #
  # === 全ボタンを描画
  #
  def BornButton.all_draw(lst, ox, oy)
    lst.each { |t| t.draw(ox, oy) }
  end

  #
  # === 表示座標を求める
  #
  # x,y :: x,yの指定値。
  #        2.0未満の時は画面に対する割合。
  #        2.0以上の時はデフォルト画面幅前提のピクセル値。
  # w,h :: 表示したい何かのサイズ
  # scrw,scrh :: 現在のウインドウサイズ
  #
  def BornButton.get_pos(x, y, w, h, scrw, scrh)
    rx, ry = 0, 0
    if x <= 0
      rx = (w / 2) + 8
    elsif x == 1.0
      rx = scrw - (w / 2) - 8
    elsif x >= 2.0
      # ピクセル値を直接指定している場合
      rx = scrw * x.to_f / DEF_SCRW
    else
      rx = scrw * x
    end

    if y <= 0
      ry = (h / 2) + 8
    elsif y == 0.05
      ry = (h / 2) + 16
    elsif y == 1.0
      ry = scrh - (h / 2) - 8
    elsif y == 1.1
      ry = scrh - (h / 2) - 4
    elsif y >= 2.0
      # ピクセル値を直接指定している場合
      ry = scrh * y.to_f / DEF_SCRH
    else
      ry = scrh * y
    end

    return rx.to_i, ry.to_i
  end
end

