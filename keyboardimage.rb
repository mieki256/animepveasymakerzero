#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 11:43:31 +0900>
#
# �L�[�{�[�h�摜�����p�N���X

require 'dxruby'
require_relative 'bitmapfont'
require_relative 'animekind'

class KeyboardImage
  # �L�[�̕`��ʒu
  KEY_LINE = 40
  KEY_POS_LIST2 = [
                   [0, "1234567890-^", 0, 0], # �������1�������������ĕ`��
                   [1, "bs", 365 + 16, 0], # 1�������ʂɕ`��
                   [1, "del", 398 + 16, 0],
                   [0, "qwertyuiop@[", 8, KEY_LINE * 1],
                   [0, "asdfghjkl;:]", 16, KEY_LINE * 2],
                   [1, "up", 426 - 28, KEY_LINE * 2],
                   [0, "zxcvbnm,./", 24, KEY_LINE * 3],
                   [1, "left", 398 - 28, KEY_LINE * 3],
                   [1, "down", 426 - 28, KEY_LINE * 3],
                   [1, "right", 454 - 28, KEY_LINE * 3],
                  ]

  # �e�X�g�p�F�L���ȃL�[�̈ꗗ
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
  # �L�[�}�b�v�摜�𐶐����郁�\�b�h
  #
  # key_list :: �L���ȃL�[�̈ꗗ�𕶎���̔z��œn��.
  # about_list :: �e�L�[�ɑ΂��������������n�b�V���œn��.
  # resdir :: �摜���\�[�X�������Ă���f�B���N�g�� (�Ō��'/'���L����)
  #
  # �Ԃ�l:: �������� Image , �e�L�[�̒��S���W���L�������n�b�V��
  #
  def KeyboardImage.make_image(key_list, about_list, resdir)
    img = Image.new(640, 480, [64, 0, 0, 0])
    pos_dic = Hash.new
    about_atari = Struct.new("About", :x, :y, :w, :h)
    atari = Array.new
    
    # �L�[����`�悷��t�H���g���w��
    fnt_key = Font.new(16, '�l�r �S�V�b�N')

    # �r�b�g�}�b�v�t�H���g��p��
    bmpfnt = BitmapFont.new(resdir)
    fontkind = 0
    afw = bmpfnt.get_font_width(fontkind)
    afh = bmpfnt.get_font_height(fontkind)

    # �`��ʒu�ƕ`�敶�����z��ɂ܂Ƃ߂�
    pos_list = []
    w = 28
    KEY_POS_LIST2.each do |dt|
      datakind, str, x, y = dt
      if datakind == 0
        # �܂Ƃ߂ēo�^
        str.split(//).each do |ch|
          pos_list.push([ch, x, y])
          x += w
        end
      else
        # 1�L�[���o�^
        pos_list.push([str, x, y])
      end
    end

    xmax = 0
    ymax = 0

    # �`��F�̒�`
    fgcol_enable = [255, 255, 255]
    fgcol_disable = [96, 96, 96]
    fgcol_gray = [160, 160, 160]
    fgcol_gray2 = [128, 128, 128]
    bdcol = [64, 64, 64]

    line_down_fg = false
    rep_str = {
      'left' => '��',
      'right' => '��',
      'up' => '��',
      'down' => '��'
    }

    # Image�ɕ`�悵�Ă���
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
      
      # �L�[�̘g�̍��W������
      bw = fwidth + 7
      bh = 20
      x1 = x + bw
      y1 = y + bh
      xmax = (x1 + 1) if xmax < (x1 + 1)
      ymax = (y1 + 1) if ymax < (y1 + 1)

      # �L�[�̒��S�ʒu���L��
      cx = x + (bw / 2) + 1
      cy = y + (bh / 2) + 1
      pos_dic[str] = [cx, cy]

      # �L�[�̕�����`��
      fx = x + 4
      fy = y + 3
      if key_use
        # �L���ȃL�[�Ƃ��ĕ`��
        img.box(x - 1, y - 1, x1 + 1, y1 + 1, bdcol)
        img.box(x, y, x1, y1, fgcol_gray)
        
        img.drawFontEx(fx, fy, draw_str.upcase, fnt_key,
                       :color => fgcol_enable, :edge => true,
                       :edge_width => 1, :edge_color => bdcol,
                       :edge_level => 4)
      else
        # �����ȃL�[�Ƃ��ĕ`��
        img.box(x, y, x1, y1, fgcol_gray2)
        img.drawFontEx(fx, fy, draw_str.upcase, fnt_key,
                       :color => fgcol_disable, :edge => false)
      end

      if about_list.has_key?(str)
        # ���������񂪑��݂���̂ŕ`��
        about_str = about_list[str]
        w = about_str.length * afw
        h = afh
        x = ((x + x1) / 2) - (w/2)
        y = y1 + 2
        
        # ���̐���������Əd�Ȃ��ĂȂ������ׂ�
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

  # �e�X�g�p�F�L���ȃL�[�̈ꗗ��z��ŕԂ�
  # ["z", "x", "c"] �Ƃ������`�B
  def KeyboardImage.get_enable_list
    lst = Array.new
    TEST_KEY_LIST.each { |dt| lst.push(dt[0]) }
    return lst
  end

  # �e�X�g�p�F�L�[�̐���������ꗗ���n�b�V���ŕԂ�
  # {"z" => "zoom", "x" => "fix"} �Ƃ������`�B
  def KeyboardImage.get_about_dic
    a = Hash.new
    TEST_KEY_LIST.each { |dt| a[dt[0]] = dt[1] }
    return a
  end

  # �e�X�g�p�F�L�[���͗p�̃n�b�V����Ԃ�
  # {K_Z => "z", K_DELETE => "delete"} �Ƃ������`�B
  def KeyboardImage.get_input_dic
    a = Hash.new
    TEST_KEY_LIST.each { |dt| a[dt[2]] = dt[0] }
    return a
  end

end

# ����e�X�g�p
if $0 == __FILE__
  curdir = File.expand_path(File.dirname(__FILE__))
  resdir = curdir + '/res/' # �e�X�g
  
  sw,sh = 640, 360
  Window.resize(sw, sh)

  # �L�[���������ۂ̕\���}�[�N���쐬
  onimg = Image.new(20, 20).circleFill(10,10,10,[255,0,0])
  
  misaki_disp = false
  if misaki_disp
    # ����S�V�b�N�t�H���g���ꎞ�C���X�g�[��
    Font.install(resdir + "misaki_gothic_emb.ttf")
    fnt_mini = Font.new(8, '����S�V�b�N')
  end

  # �L�[�{�[�h�摜�쐬
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
              "�V������������ ��]�̒���",
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
      # MISAKI�t�H���g(�r�b�g�}�b�v���ߍ��݃^�C�v)�Ńe�X�g�`��
      # ���ӓ_:
      # Window.drawFont() �͕`��ł��邪 Image.drawFont() �͕`��ł��Ȃ��B
      x = 16
      y = 16
      test_str.each do |s|
        Window.drawFont(x, y, s, fnt_mini)
        y += 8
      end
    end

    # �L�[�{�[�h�C���[�W��`��
    x = sw - img.width - 16
    y = sh - img.height - 16
    bx = x
    by = y
    Window.draw(x, y, img)

    # �L�[�������ꂽ���`�F�b�N
    inp.each_key do |key|
      if Input.keyPush?(key)
        keykind = inp[key]
        mx, my = pos_dic[keykind]
        mx += bx - (onimg.width / 2)
        my += by - (onimg.height / 2)
        alpha = 255
      end
    end

    # �����ꂽ�L�[�̈ʒu�Ƀ}�[�N��`��
    if alpha > 0
      Window.drawAlpha(mx, my, onimg, alpha)
      alpha -= 8
    end

    if Input.keyPush?(K_C)
      bgcol_num = (bgcol_num + 1) % test_bgcol.length
    end
  end
end

