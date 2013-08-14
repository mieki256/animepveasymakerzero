#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 11:43:31 +0900>
#
# キーボード画像生成用クラス

require 'dxruby'
require_relative 'bitmapfont'
require_relative 'animekind'

class KeyboardImage
  # キーの描画位置
  KEY_LINE = 40
  KEY_POS_LIST2 = [
                   [0, "1234567890-^", 0, 0], # 文字列を1文字ずつ分割して描画
                   [1, "bs", 365 + 16, 0], # 1文字ずつ個別に描画
                   [1, "del", 398 + 16, 0],
                   [0, "qwertyuiop@[", 8, KEY_LINE * 1],
                   [0, "asdfghjkl;:]", 16, KEY_LINE * 2],
                   [1, "up", 426 - 28, KEY_LINE * 2],
                   [0, "zxcvbnm,./", 24, KEY_LINE * 3],
                   [1, "left", 398 - 28, KEY_LINE * 3],
                   [1, "down", 426 - 28, KEY_LINE * 3],
                   [1, "right", 454 - 28, KEY_LINE * 3],
                  ]

  # テスト用：有効なキーの一覧
  TEST_KEY_LIST = [['z',     'ZOOM UP', K_Z        ],
                   ['x',     'FADEOUT', K_X        ],
                   ['f',     'FADEOUT', K_F        ],
                   ['c',     'FIX',     K_C        ],
                   ['b',     'ZOOM BK', K_B        ],
                   ['w',     'PAN D',   K_W        ],
                   ['a',     'PAN R',   K_A        ],
                   ['s',     'PAN U',   K_S        ],
                   ['d',     'PAN L',   K_D        ],
                   ['up',    'PAN D',   K_UP       ],
                   ['left',  'PAN R',   K_LEFT     ],
                   ['down',  'PAN U',   K_DOWN     ],
                   ['right', 'PAN L',   K_RIGHT    ],
                   ['bs',    'RETRY',   K_BACKSPACE],
                   ['del',   'LOG DEL', K_DELETE   ],
                  ]

  #
  # キーマップ画像を生成するメソッド
  #
  # key_list :: 有効なキーの一覧を文字列の配列で渡す.
  # about_list :: 各キーに対する説明文字列をハッシュで渡す.
  # resdir :: 画像リソースが入っているディレクトリ (最後に'/'が有る状態)
  #
  # 返り値:: 生成した Image , 各キーの中心座標を記憶したハッシュ
  #
  def KeyboardImage.make_image(key_list, about_list, resdir)
    img = Image.new(640, 480, [64, 0, 0, 0])
    pos_dic = Hash.new
    about_atari = Struct.new("About", :x, :y, :w, :h)
    atari = Array.new
    
    # キー内を描画するフォントを指定
    fnt_key = Font.new(16, 'ＭＳ ゴシック')

    # ビットマップフォントを用意
    bmpfnt = BitmapFont.new(resdir)
    fontkind = 0
    afw = bmpfnt.get_font_width(fontkind)
    afh = bmpfnt.get_font_height(fontkind)

    # 描画位置と描画文字列を配列にまとめる
    pos_list = []
    w = 28
    KEY_POS_LIST2.each do |dt|
      datakind, str, x, y = dt
      if datakind == 0
        # まとめて登録
        str.split(//).each do |ch|
          pos_list.push([ch, x, y])
          x += w
        end
      else
        # 1キーずつ登録
        pos_list.push([str, x, y])
      end
    end

    xmax = 0
    ymax = 0

    # 描画色の定義
    fgcol_enable = [255, 255, 255]
    fgcol_disable = [96, 96, 96]
    fgcol_gray = [160, 160, 160]
    fgcol_gray2 = [128, 128, 128]
    bdcol = [64, 64, 64]

    line_down_fg = false
    rep_str = {
      'left' => '←',
      'right' => '→',
      'up' => '↑',
      'down' => '↓'
    }

    # Imageに描画していく
    pos_list.each_with_index do |dt, i|
      str, x, y = dt
      key_use = key_list.include?(str)
      
      strlen = str.length
      draw_str = str
      if rep_str.has_key?(str)
        draw_str = rep_str[str]
        strlen = draw_str.length * 2
      end
      fwidth = strlen * 8

      x += 8
      y += 4
      
      # キーの枠の座標を決定
      bw = fwidth + 7
      bh = 20
      x1 = x + bw
      y1 = y + bh
      xmax = (x1 + 1) if xmax < (x1 + 1)
      ymax = (y1 + 1) if ymax < (y1 + 1)

      # キーの中心位置を記憶
      cx = x + (bw / 2) + 1
      cy = y + (bh / 2) + 1
      pos_dic[str] = [cx, cy]

      # キーの文字を描画
      fx = x + 4
      fy = y + 3
      if key_use
        # 有効なキーとして描画
        img.box(x - 1, y - 1, x1 + 1, y1 + 1, bdcol)
        img.box(x, y, x1, y1, fgcol_gray)
        
        img.drawFontEx(fx, fy, draw_str.upcase, fnt_key,
                       :color => fgcol_enable, :edge => true,
                       :edge_width => 1, :edge_color => bdcol,
                       :edge_level => 4)
      else
        # 無効なキーとして描画
        img.box(x, y, x1, y1, fgcol_gray2)
        img.drawFontEx(fx, fy, draw_str.upcase, fnt_key,
                       :color => fgcol_disable, :edge => false)
      end

      if about_list.has_key?(str)
        # 説明文字列が存在するので描画
        about_str = about_list[str]
        w = about_str.length * afw
        h = afh
        x = ((x + x1) / 2) - (w/2)
        y = y1 + 2
        
        # 他の説明文字列と重なってないか調べる
        fg = false
        atari.each do |dt|
          next if (dt.x + dt.w < x or x + w < dt.x)
          next if (dt.y + dt.h < y or y + h < dt.y)
          fg = true
        end
        y += (afh + 1) if fg
        bmpfnt.drawFont(x, y, img, about_str, fontkind)
        atari.push(about_atari.new(x, y, w + 4, h))
        
        x2 = x + w
        y2 = y + h
        xmax = x2 if x2 > xmax
        ymax = y2 if y2 > ymax
        
        line_down_fg = !line_down_fg
      end
    end

    return img.slice(0, 0, xmax + 8, ymax + 8), pos_dic
  end

  # テスト用：有効なキーの一覧を配列で返す
  # ["z", "x", "c"] といった形。
  def KeyboardImage.get_enable_list
    lst = Array.new
    TEST_KEY_LIST.each { |dt| lst.push(dt[0]) }
    return lst
  end

  # テスト用：キーの説明文字列一覧をハッシュで返す
  # {"z" => "zoom", "x" => "fix"} といった形。
  def KeyboardImage.get_about_dic
    a = Hash.new
    TEST_KEY_LIST.each { |dt| a[dt[0]] = dt[1] }
    return a
  end

  # テスト用：キー入力用のハッシュを返す
  # {K_Z => "z", K_DELETE => "delete"} といった形。
  def KeyboardImage.get_input_dic
    a = Hash.new
    TEST_KEY_LIST.each { |dt| a[dt[2]] = dt[0] }
    return a
  end

end

# 動作テスト用
if $0 == __FILE__
  curdir = File.expand_path(File.dirname(__FILE__))
  resdir = curdir + '/res/' # テスト
  
  sw,sh = 640, 360
  Window.resize(sw, sh)

  # キーを押した際の表示マークを作成
  onimg = Image.new(20, 20).circleFill(10,10,10,[255,0,0])
  
  misaki_disp = false
  if misaki_disp
    # 美咲ゴシックフォントを一時インストール
    Font.install(resdir + "misaki_gothic_emb.ttf")
    fnt_mini = Font.new(8, '美咲ゴシック')
  end

  # キーボード画像作成
  if false
    enables = KeyboardImage.get_enable_list
    abouts = KeyboardImage.get_about_dic
    img, pos_dic = KeyboardImage.make_image(enables, abouts, resdir)
    inp = KeyboardImage.get_input_dic
  else
    tbl = AnimeKind.load_key_table(curdir)
    enables = AnimeKind.get_enable_key_list(tbl)
    abouts = AnimeKind.get_key_about_dic(tbl)
    img, pos_dic = KeyboardImage.make_image(enables, abouts, resdir)
    inp = AnimeKind.get_keycodes(tbl)
  end
  
  test_str = ["abcdefg hijklmn",
              "opqrstu vwxyz",
              "ABCDEFG HIJKLMN",
              "OPQRSTU VWXYZ",
              "新しい朝が来た 希望の朝だ",
             ]

  test_bgcol = [
                [0,0,0],
                [0,0,255],
                [255,0,0],
                [255,0,255],
                [0,255,0],
                [0,255,255],
                [255,255,0],
                [255,255,255]
               ]
  
  alpha = 0
  mx, my = 0
  bgcol_num = 1
  
  Window.loop do
    Window.bgcolor = test_bgcol[bgcol_num]
    break if Input.keyPush?(K_ESCAPE)

    if misaki_disp
      # MISAKIフォント(ビットマップ埋め込みタイプ)でテスト描画
      # 注意点:
      # Window.drawFont() は描画できるが Image.drawFont() は描画できない。
      x = 16
      y = 16
      test_str.each do |s|
        Window.drawFont(x, y, s, fnt_mini)
        y += 8
      end
    end

    # キーボードイメージを描画
    x = sw - img.width - 16
    y = sh - img.height - 16
    bx = x
    by = y
    Window.draw(x, y, img)

    # キーが押されたかチェック
    inp.each_key do |key|
      if Input.keyPush?(key)
        keykind = inp[key]
        mx, my = pos_dic[keykind]
        mx += bx - (onimg.width / 2)
        my += by - (onimg.height / 2)
        alpha = 255
      end
    end

    # 押されたキーの位置にマークを描画
    if alpha > 0
      Window.drawAlpha(mx, my, onimg, alpha)
      alpha -= 8
    end

    if Input.keyPush?(K_C)
      bgcol_num = (bgcol_num + 1) % test_bgcol.length
    end
  end
end

