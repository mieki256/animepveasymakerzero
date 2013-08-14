#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/14 23:08:56 +0900>
#
# 曲選択、入力画像フォルダ選択、記録スタート選択画面

require 'rubygems'
require 'dxruby'
require_relative 'msgwdw'
require_relative 'laps'
require_relative 'seq'
require_relative 'config'
require_relative 'exportexo'
require_relative 'folderselect'

# ----------------------------------------
#
# === 曲選択画面用
#
class MusicSelect < SeqScene
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  CENTER_Y = 0.597
  CENTER_Y_D = 0.222
  BTN_LIST = [
              [CBTN, 4, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
              [STIL, -1, nil, 'selectmusic_logo.png', '', 0.5, 0.0],
              [BBTN, 1, K_C, 'selectmusic_custom.png', '', 0.5, CENTER_Y - CENTER_Y_D],
              [BBTN, 2, K_A, 'selectmusic_sample1.png', '', 0.5, CENTER_Y],
              [BBTN, 3, K_B, 'selectmusic_sample2.png', '', 0.5, CENTER_Y + CENTER_Y_D],
             ]
  NMLWDW = MessageWindow::NMLWDW
  ERRWDW = MessageWindow::ERRWDW
  SAMPLE_MUSIC = ['sampledata/sample1.mp3', 'sampledata/sample2.mp3']
  
  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
    @step_ss = 0
  end

  def set_path(path)
    path = File.expand_path(path)
    if @cfg.check_sound_exist?(path)
      @cfg.set_value('soundfile', path)
      @cfg.write_config
      return true
    end
    set_msg("指定ファイルが見つかりません。\n \n Not Found #{path}", ERRWDW)
    return false
  end

  def update_sub(ret)
    case @step_ss
    when 0
      case ret
      when 1
        # 曲選択ボタンが押された
        @step_ss = 1
      when 2..3
        # サンプル曲その1、その2
        path = @cfg.get_current_dir + '/' + SAMPLE_MUSIC[ret - 2]
        return (set_path(path))? 0 : -1
      when 4
        # 戻る
        return 1
      end
    when 1
      # 曲を選択
      path = Window.openFilename(Conf::SNDEXT, "曲を選択")
      @step_ss = 0
      if path
        @step_ss = 2 if set_path(path)
      end
    when 2
      # 曲選択終了
      @step_ss = 0
      return 0
    end
    
    return -1
  end

  def framein
    super
    @step_ss = 0
  end
end

# ----------------------------------------
#
# === 入力画像フォルダ選択画面用
#
class ImagesSelect < SeqScene
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  CENTER_Y = 0.597
  CENTER_Y_D = 0.222
  BTN_LIST = [
              [STIL, -1, nil, 'selectimages_logo.png', '', 0.5, 0.0],
              # [STIL, -1, nil, 'selectimages_logo2.png', '', 0.5, 0.0],
              [CBTN, 4, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
              [BBTN, 1, K_C, 'selectimages_custom.png', '', 0.5, CENTER_Y - CENTER_Y_D],
              [BBTN, 2, K_A, 'selectimages_sample1.png', '', 0.5, CENTER_Y],
              [BBTN, 3, K_B, 'selectimages_sample2.png', '', 0.5, CENTER_Y + CENTER_Y_D],
             ]
  NMLWDW = MessageWindow::NMLWDW
  ERRWDW = MessageWindow::ERRWDW
  
  SAMPLE_IMGDIR = ['sampledata/image1', 'sampledata/image2']
  
  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
    @step_ss = 0
    @imgdt = @cfg.imgdt
    @bar = LoadingBar.new(@scrw, @scrh, @cfg.get_res_dir)
  end

  # 画像フォルダ設定を記録
  def set_imgdir(path)
    path = File.expand_path(path)
    if @cfg.check_images_exist?(path)
      # 画像ファイル群が存在する
      @cfg.set_value('imgdir', File.expand_path(path))
      @cfg.write_config
      return true
    end
    set_msg("指定フォルダ内に画像が見つかりません。\n \n Not found images in #{path}", ERRWDW)
    return false
  end
  
  def update_sub(ret)
    case @step_ss
    when 0
      # ボタン選択中
      case ret
      when 1
        # フォルダ選択ボタンが押された
        @step_ss = 4
      when 2..3
        # サンプル画像群その1、その2
        path = @cfg.get_current_dir + '/' + SAMPLE_IMGDIR[ret - 2]
        @step_ss = 1 if set_imgdir(path)
      when 4
        # 戻るボタンが押された
        return 1
      end
    when 1
      # 画像ロード初期化
      @bar.init_work
      @imgdt.load_init(@cfg.get_value('imgdir'))
      @bar.set_info("", @imgdt.get_img_num, @imgdt.get_img_num_max)
      @step_ss = 2
    when 2
      # 画像ロード中
      r = @imgdt.load_img
      if r == "notfound"
        # 画像が見つからない
        @step_ss = 0
      elsif r == "loadok"
        # 最後の画像まで読み込んだ
        @step_ss = 3
      else
        # 1ファイル読み込んだ
        @bar.set_info(r, @imgdt.get_img_num, @imgdt.get_img_num_max)
      end
    when 3
      # 画像ロード終了
      @bar.set_info("", @imgdt.get_img_num, @imgdt.get_img_num_max)
      @step_ss = 0
      return 0
    when 4
      # 任意の画像フォルダを選択
      path = FolderSelect.get_dirpath(0, @cfg.get_current_dir, @cfg.app)
      @step_ss = 0
      if path
        @step_ss = 1 if set_imgdir(path)
      end
    end
    return -1
  end

  def draw
    super
    @bar.draw # ロードした画像ファイル名を表示
  end
  
  def framein
    super
    @step_ss = 0
    @bar.init_work
  end
end

# ----------------------------------------
#
# === メニュー選択画面用
#
class MenuSeq < SeqScene
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  BTN_LIST = [
              [STIL, -1, nil, 'mes_select1.png', '', 0.5, 0.0],
              [STIL, -1, nil, 'area_base1.png', '', 0.5, 1.0],
              [CBTN, 4, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
              [BBTN, 0, K_R, 'btn_rec.png', '', 0.5, 0.319],
              [BBTN, 1, K_P, 'btn_play.png', '', 0.5 - 0.227, 0.597],
              [BBTN, 2, K_E, 'btn_export.png', '', 0.5 + 0.227, 0.597],
             ]
  
  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
  end

  def draw
    super
    unless @substep == 2
      fnt = @cfg.font12
      bx = (@scrw / 2) - (512 / 2) + @ofsx
      by = @scrh - 40 + @ofsy
      x = bx + 4
      y = by - (fnt.size * 3 + 5 * 2) / 2
      l = [
           "曲  : " + @cfg.get_value('soundfile'),
           "画像: " + @cfg.get_value('imgdir'),
           "ログ: " + @cfg.get_log_path,
          ]
      l.each do |s|
        Window.drawFont(x, y, s, fnt, :color => [0, 0, 0])
        y += fnt.size + 5
      end
    end
  end
end

# ----------------------------------------
#
# === 記録スタート時の画面用クラス
#
class RecTitle < SeqScene
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  BTN_LIST = [
              # ButtonKind, kind, keycode, imagefile, strnum, x, y
              # [STIL, -1, nil, 'btn_base1.png', '', 0.5, 0.55],
              [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
              [BBTN, 1, K_C, 'start_btn2.png', '', 0.5, 0.181],
              [BBTN, 2, K_H, 'howtouse_2_goto.png', '', 0.5, 0.431],
              [BBTN, 3, K_L, 'btn_load.png', '', 0.125, 1.0],
              [BBTN, 4, K_S, 'btn_save.png', '', 0.375, 1.0],
              [BBTN, 5, K_E, 'btn_edit.png', '', 0.625, 1.0],
              [BBTN, 6, K_R, 'btn_erase.png', '', 0.875, 1.0],
             ]
  NMLWDW = MessageWindow::NMLWDW
  ERRWDW = MessageWindow::ERRWDW
  
  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
  end

  def update_sub(ret)
    ofn = @cfg.get_log_path
    case ret
    when 0
      # 前の画面へ戻る
      return 1
    when 1
      # 先の画面へ進む
      @cfg.clear_outmode # 画像出力を無効化
      @cfg.clear_playmode # 再生モードを無効化
      return 0
    when 2
      # 操作説明画面へ進む
      return 2
    when 3
      # ログファイル読み込み
      if @lap.log_exist?
        if @lap.get_log
          set_msg("ログを読み込みました。\nread\n#{ofn}", NMLWDW)
        else
          set_msg("ログ読み込みに失敗しました。\nread failure.\n#{ofn}", ERRWDW)
        end
      else
        set_msg("ログがありません。\nnot found\n#{ofn}", ERRWDW)
      end
    when 4
      # ログファイル保存
      if @lap.out_log
        set_msg("ログを保存しました。\nsave\n#{ofn}", NMLWDW)
      else
        set_msg("ログ保存に失敗しました。\nsave failure.\n#{ofn}", ERRWDW)
      end
    when 5
      # ログファイル編集。メモ帳を起動
      ofn_win32 = ofn.gsub(/\//, '\\')
      Thread.start{ system("notepad \"#{ofn_win32}\"") }
    when 6
      # ログ消去
      @lap.log_init # 内部ログ初期化
      del_success = true
      if @lap.log_exist?
        del_success = @lap.delete_log
      end
      if del_success
        if @lap.out_log
          set_msg("ログを消去しました。\nclear and save\n#{ofn}", NMLWDW)
        else
          set_msg("ログ消去失敗\nsave failure.\n#{ofn}", ERRWDW)
        end
      else
        set_msg("ログファイル削除に失敗\ndelete failure.\n#{ofn}", ERRWDW)
      end
    end
    return -1
  end
end

# ----------------------------------------
#
# === exportモード時のスタート画面用クラス
#
class ExportTitle < SeqScene
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  PERX1 = 0.156
  PERY1 = 0.597
  PERY2 = 0.847
  BTN_LIST = [
              # ButtonKind, kind, keycode, imagefile, strnum, x, y
              [STIL, -1, nil, 'export_logo.png', '', 0.5, 0.0],
              [STIL, -1, nil, 'export_path_bg.png', '', 0.5, PERY2],
              [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
              [BBTN, 2, K_E, 'export_exo_btn.png', '', 0.5, 0.292],
              [BBTN, 3, K_LEFT, 'fmt_dec_btn.png', '', PERX1 - 0.086, PERY1],
              [BBTN, 4, K_RIGHT, 'fmt_inc_btn.png', '', PERX1 + 0.086, PERY1],
              [BBTN, 5, K_S, 'export_folder_select.png', '', 0.453, PERY1],
              [BBTN, 1, K_I, 'export_start_btn.png', '', 0.813, PERY1],
             ]
  NMLWDW = MessageWindow::NMLWDW
  
  SAVEEXT = [["exo(*.exo)","*.exo"],["all(*.*)","*.*"]]
  
  SS_SELFILE = 1
  SS_EXOSTART = 2
  SS_EXOSAVE = 3
  SS_EXOWAIT = 4
  SS_EXOEND = 5
  SS_SELDIR = 6

  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
    @fmtimgs = Image.loadTiles(@cfg.get_res_dir + 'fmt_str.png', 1, 3)
    @step_ss = 0
    @msg_str = ""
    @exo_filename = ""
    @counter = 0
  end

  def update_sub(ret)
    case @step_ss
    when 0
      # ボタン選択中
      return button_select_job(ret)
    when SS_SELFILE
      # ファイル保存ダイアログを開く
      path = Window.saveFilename(SAVEEXT, "exoファイル名を指定")
      if path
        @exo_filename = File.expand_path(path)
        @exo_filename += ".exo" unless @exo_filename =~ /\.exo$/i
        @step_ss += 1
      else
        @step_ss = 0
      end
    when SS_EXOSTART
      # exoファイル出力開始
      @msg_str = ["exoファイルを出力中です", "少々お待ちください"]
      @step_ss += 1
    when SS_EXOSAVE
      # exoファイル出力中
      ExportExo.export_exo_file(@exo_filename, @cfg, @lap)
      @counter = @cfg.get_fps / 3
      @step_ss += 1
    when SS_EXOWAIT
      # 少し待つ
      @counter -= 1
      @step_ss += 1 if @counter < 0
    when SS_EXOEND
      # exoファイル出力終了
      str = "exoファイルを出力しました\nOutput\n#{@exo_filename}"
      set_msg(str, NMLWDW, 4)
      @step_ss = 0
    when SS_SELDIR
      # 出力フォルダを選択
      path = FolderSelect.get_dirpath(1, @cfg.get_current_dir, @cfg.app)
      if path
        @cfg.set_value('outdir', File.expand_path(path))
        @cfg.write_config
      end
      @step_ss = 0
    end
    return -1
  end

  # ボタン選択中の処理
  def button_select_job(ret)
    case ret
    when 0
      # 前の画面へ戻る
      return 1
    when 1
      # 先の画面へ進む
      @cfg.write_config
      return 0
    when 2
      # exoファイルを出力開始
      @step_ss = SS_SELFILE
    when 3
      # 出力画像フォーマットを変更・デクリメント
      @cfg.dec_outmode
    when 4
      # 出力画像フォーマットを変更・インクリメント
      @cfg.inc_outmode
    when 5
      # 出力フォルダ選択
      @step_ss = SS_SELDIR
    end
    return -1
  end
  
  def draw
    super

    # 出力フォルダ名を描画
    odir = @cfg.get_value('outdir')
    fnt = @cfg.font12
    l = [
         "出力フォルダ",
         odir,
         "※ FFmpegがあれば、連番画像出力後 img2avi.bat 実行で動画が作れます。",
        ]
    if @cfg.screenshot_save?
      l.push("※ 出力中は他ウインドウを重ねないでください。一緒に書き出されてしまいます。")
    else
      l.push("")
    end
    
    x = (@scrw / 2 - (512/2) + 4) + @ofsx
    y = (@scrh * PERY2).to_i + @ofsy
    y -= ((fnt.size * l.length + 2 * (l.length - 1)) / 2)
    l.each do |s|
      Window.drawFont(x, y, s, fnt, :color => [0,0,0])
      y += fnt.size + 2
    end

    # 出力フォーマットを描画
    fmtimg = @fmtimgs[@cfg.get_outmode_index]
    x = (@scrw * PERX1) - (fmtimg.width / 2) + @ofsx
    y = (@scrh * PERY1).to_i - (fmtimg.height / 2) + @ofsy
    Window.draw(x, y, fmtimg)

    # exoファイル出力中ならメッセージを描画
    @msg.draw_msg(@msg_str, NMLWDW) if @step_ss == SS_EXOSAVE
  end

  def set_msg(str, kind, sec)
    @msg.set_msg(str, sec, @cfg.get_fps, kind)
  end
  
  def framein
    super
    @step_ss = 0
  end
end


# ----------------------------------------
#
# === 設定画面用クラス
#
class ConfigSeq < SeqScene
  SAVEEXT = [["txt(*.txt)","*.txt"],["all(*.*)","*.*"]]
  CBTN = BornButton::CBTN
  BBTN = BornButton::BBTN
  STIL = BornButton::STIL
  
  PATH_BG_W = 512
  PATH_BG_H = 48
  PATH_BG_Y = 72
  
  SIZE_BG_X, SIZE_BG_Y = 16, 104 # 左上の座標
  FPS_BG_X, FPS_BG_Y = 168, 104 # 左上の座標
  
  BTN_LIST = [
              [STIL, -1, nil, 'config_path_bg.png', '', 0.5, PATH_BG_Y],
              [STIL, -1, nil, 'config_logo.png', '', 0.5, 0.0],
              [STIL, -1, nil, 'config_info.png', '', 1.0, 1.0],
              [BBTN, 1, nil, 'config_chg_path.png', '', 400, 116],
              [BBTN, 3, nil, 'config_chg_savemode.png', '', 400, 148],
              [BBTN, 2, nil, 'config_reset_btn.png', '', 1.0, 236],
              [CBTN, 4, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
             ]
  NMLWDW = MessageWindow::NMLWDW
  ERRWDW = MessageWindow::ERRWDW
  
  def initialize(cfg, lap, step_kind, x, y)
    super(cfg, lap, BTN_LIST, step_kind, x, y)
    resdir = @cfg.get_res_dir
    @sizebgimg = Image.load(resdir + 'config_size_bg.png')
    @fpsbgimg = Image.load(resdir + 'config_fps_bg.png')

    # ウインドウサイズ一覧情報(画像込)を作成
    @size_list = Array.new
    @sizedt = Struct.new("SizeDt", :sw, :sh, :x, :y, :w, :h, :str, :img, :onmouse)
    fnt = @cfg.font10
    spcw = 16
    x, y = BornButton.get_pos(SIZE_BG_X, SIZE_BG_Y, 0, 0, @scrw, @scrh)
    x += spcw
    y += 24 + 2 + 16
    w = @sizebgimg.width - (spcw * 2)
    h = fnt.size + (1 * 2)
    Conf::SCR_SIZE.each do |d|
      sw, sh = d
      s = get_aspect_str(sw, sh)
      img = Image.new(w, h, [255, 46, 204, 113])
      img.drawFont(6, 1, s, fnt, [0,0,0])
      dt = @sizedt.new(sw, sh, x, y, w, h, s, img, false)
      @size_list.push(dt)
      y += h + 3
    end

    # fps一覧情報を作成
    @fps_list = Array.new
    @fpsdt = Struct.new("FpsDt", :fps, :x, :y, :w, :h, :str, :img, :onmouse)
    fnt = @cfg.font10
    spcw = 16
    x, y = BornButton.get_pos(FPS_BG_X, FPS_BG_Y, 0, 0, @scrw, @scrh)
    x += spcw
    y += 24 + 2 + 16
    w = @fpsbgimg.width - (spcw * 2)
    h = fnt.size + (1 * 2)
    Conf::FPS_LIST.each do |fps|
      s = "#{fps} FPS"
      img = Image.new(w, h, [255, 52, 152, 219])
      img.drawFont(6, 1, s, fnt, [0,0,0])
      dt = @fpsdt.new(fps, x, y, w, h, s, img, false)
      @fps_list.push(dt)
      y += h + 3
    end
    
    @step_ss = 0
  end

  # アスペクト比も含むウインドウサイズ文字列を返す
  def get_aspect_str(w, h)
    astr = ""
    a = w.to_f / h.to_f
    if a == (16.0 / 9.0)
      astr = "(16:9)"
    elsif a == (4.0 / 3.0)
      astr = "(4:3)"
    end
    return "#{w}x#{h}#{astr}"
  end
  
  def set_path(path)
    path = File.expand_path(path)
    @cfg.set_log_path(path)
    return true
  end

  def update_sub(ret)
    case @step_ss
    when 0
      # ボタン選択中
      case ret
      when 1
        # ログファイル選択ボタンが押された
        @step_ss = 1
      when 2
        # 設定初期化ボタンが押された
        @cfg.init_config_default
        @cfg.write_config
        s = "設定を初期化しました。\n"
        s += "プログラムを再起動すると反映されます。"
        set_msg(s, NMLWDW)
      when 3
        # 書き出し方法切り替えボタンが押された
        @cfg.change_screenshot_savemode
        @cfg.write_config
        s = "連番画像の書き出し方法を変更しました。\n"
        s += "プログラムを再起動すると反映されます。"
        set_msg(s, NMLWDW)
      when 4
        # 戻る
        return 0
      else
        sw, sh = check_on_mouse_size_list
        if sw != 0 and sh != 0
          # ウインドウサイズ変更ボタンを押された
          @cfg.set_screen_size(sw, sh)
          astr = get_aspect_str(sw, sh)
          s = "画面サイズを #{astr} に変更しました\n"
          s += "プログラムを再起動すると反映されます。"
          set_msg(s, NMLWDW)
        else
          fpsv = check_on_mouse_fps_list
          if fpsv != 0
            # FPS変更ボタンを押された
            @cfg.set_fps(fpsv)
            Window.fps = fpsv
            s = "フレームレートを #{fpsv} FPSに変更しました\n"
            s += "プログラムを再起動すると反映されます。"
            set_msg(s, NMLWDW)
          end
        end
      end
    when 1
      # ログファイルを選択
      path = Window.saveFilename(SAVEEXT, "ログファイル名を指定")
      set_path(path) if path
      @step_ss = 0
    when 2
      # ログファイル選択終了
      @step_ss = 0
    end
    return -1
  end

  # マウスがウインドウサイズ変更ボタンの上に乗っているかチェック
  def check_on_mouse_size_list
    mx = Input.mousePosX
    my = Input.mousePosY
    sw, sh = 0, 0
    @size_list.each do |d|
      if d.x < mx and mx < d.x + d.w and d.y < my and my < d.y + d.h
        d.onmouse = true
        if Input.mousePush?(M_LBUTTON)
          sw, sh = d.sw, d.sh
          @cfg.click_se_req = true
        end
      else
        d.onmouse = false
      end
    end
    return sw, sh
  end

  # マウスがFPS変更ボタンの上に乗っているかチェック
  def check_on_mouse_fps_list
    mx = Input.mousePosX
    my = Input.mousePosY
    fpsv = 0
    @fps_list.each do |d|
      if d.x < mx and mx < d.x + d.w and d.y < my and my < d.y + d.h
        d.onmouse = true
        if Input.mousePush?(M_LBUTTON)
          fpsv = d.fps
          @cfg.click_se_req = true
        end
      else
        d.onmouse = false
      end
    end
    return fpsv
  end

  # マウスが乗っているかの情報をクリア
  def clear_onmouse
    @size_list.each { |d| d.onmouse = false }
    @fps_list.each { |d| d.onmouse = false }
  end

  def draw
    super
    unless @substep == 2
      fnt = @cfg.font12
      bcol = [0,0,0]
      wcol = [255, 255, 255]
      
      # ログファイルパス表示部分
      logfile = @cfg.get_log_path
      x, y = BornButton.get_pos(0.5, PATH_BG_Y, PATH_BG_W, PATH_BG_H, @scrw, @scrh)
      x += @ofsx + 4 - (PATH_BG_W / 2)
      y += @ofsy + 4 - (PATH_BG_H / 2)
      str = "ログファイルの場所\n"
      str += "#{logfile}\n"
      str += "連番画像書き出し処理 : "
      if @cfg.screenshot_save?
        str += "画面に描画 + スクリーンショット保存"
      else
        str += "内部で生成 + イメージ保存"
      end
      str.split(/\n/).each do |s|
        Window.drawFont(x, y, s, fnt, :color => bcol)
        y += fnt.size + 3
      end

      # 画面サイズ表示部分
      bx, by = BornButton.get_pos(SIZE_BG_X, SIZE_BG_Y, 0, 0, @scrw, @scrh)
      bx += @ofsx
      by += @ofsy
      Window.draw(bx, by, @sizebgimg)

      s = "現在: " + get_aspect_str(@scrw, @scrh)
      x = bx + (@sizebgimg.width - fnt.getWidth(s)) / 2
      y = by + 24 + 2
      Window.drawFont(x, y, s, fnt, :color => wcol)

      @size_list.each do |d|
        x = d.x + @ofsx
        y = d.y + @ofsy
        Window.draw(x, y, d.img)
        draw_border(x, y, d.img) if d.onmouse
      end

      # FPS表示部分
      bx, by = BornButton.get_pos(FPS_BG_X, FPS_BG_Y, 0, 0, @scrw, @scrh)
      bx += @ofsx
      by += @ofsy
      Window.draw(bx, by, @fpsbgimg)
      
      s = sprintf("現在: %d FPS", @cfg.get_fps)
      x = bx + (@fpsbgimg.width - fnt.getWidth(s)) / 2
      y = by + 24 + 2
      Window.drawFont(x, y, s, fnt, :color => wcol)
      
      @fps_list.each do |d|
        x = d.x + @ofsx
        y = d.y + @ofsy
        Window.draw(x, y, d.img)
        draw_border(x, y, d.img) if d.onmouse
      end
    end
  end

  # 小ボタンの周りに枠を描画
  def draw_border(x, y, img)
    x0 = x - 1
    y0 = y - 1
    x1 = x + img.width
    y1 = y + img.height
    col = [255, 255, 255, 255]
    Window.drawLine(x0, y0, x1, y0, col)
    Window.drawLine(x0, y1, x1, y1, col)
    Window.drawLine(x0, y0, x0, y1, col)
    Window.drawLine(x1, y0, x1, y1 + 1, col)
  end
  
  def framein
    super
    clear_onmouse
    @step_ss = 0
  end
  
end

# ----------------------------------------
#
# === ローディングバー用
#
class LoadingBar
  def initialize(scrw, scrh, resdir)
    @scrw, @scrh = scrw, scrh
    @msgbgimg = Image.load(resdir + 'msgbg_normal.png')
    @font = Font.new(12, 'ＭＳ ゴシック')

    # ローディングバーの下地用 Image を生成
    @bar_w = @msgbgimg.width - (16 * 2)
    @bar_h = 16
    @barbgimg = Image.new(@bar_w, @bar_h)
    x1, y1 = 0, 0
    x2, y2 = @bar_w - 1, @bar_h - 1
    bdcol = [52, 73, 94]
    fillcol = [149, 165, 166]
    col3 = [41, 128, 185]
    w = 3
    @barbgimg.boxFill(x1, y1, x2, y2, bdcol)
    @barbgimg.boxFill(x1 + w, y1 + w, x2 - w, y2 - w, fillcol)

    # バー用の Image を生成
    @barimg = Image.new(@bar_w - w * 2, @bar_h - w * 2, col3)
    
    init_work
  end

  # ワーク初期化
  def init_work
    @fpath = ""
    @imgnum = 0
    @imgmax = 0
  end

  # === 描画用に必要な情報を設定
  #
  # str :: パス文字列
  # imgnum :: 現在読み込んだファイル数
  # imgmax :: 全ファイル数
  def set_info(str, imgnum, imgmax)
    @fpath = str
    @imgnum = imgnum
    @imgmax = imgmax
    @imgnum = @imgmax if @imgnum > @imgmax
  end

  # === 描画
  def draw
    return if @fpath == ""

    bx = (@scrw - @msgbgimg.width) / 2
    by = (@scrh - @msgbgimg.height) / 2
    Window.draw(bx, by, @msgbgimg)

    x = bx + 8
    y = by + 16
    col = [0,0,0]
    Window.drawFont(x, y, "画像読み込み中", @font, :color => col)
    y += 20

    if @fpath.index("load failure.") == 0
      # ロードに失敗している場合
      l = @fpath.split("\n")
      fn = l[1]
      bname = File.basename(fn)
      dname = File.dirname(fn)
      lst = [dname, bname + " --- Load Failure. Retry"]
    else
      # ロードに成功している場合
      bname = File.basename(@fpath)
      dname = File.dirname(@fpath)
      lst = [dname, bname]
    end
    lst.each do |s|
      Window.drawFont(x, y, s, @font, :color => col)
      y += @font.size + 2
    end

    x = bx + 16
    y = by + @msgbgimg.height - @barbgimg.height - 16
    Window.draw(x, y, @barbgimg)

    w = 3
    x += w
    y += w
    scalex = @imgnum.to_f / @imgmax.to_f 
    Window.drawScale(x, y, @barimg, scalex, 1.0, 0, 0)
  end
end

# 動作テスト用
if $0 == __FILE__

  # ローディングバーの表示テスト
  if true
    sw, sh = 640, 360
    bar = LoadingBar.new(sw, sh, './res/') # テスト
    Window.resize(sw, sh)
    Window.fps = 10
    Window.bgcolor = [241, 196, 15]
    lst = Array.new
    20.times { |n| lst.push(sprintf("%08d.png", n)) }
    count = 0
    Window.loop do
      break if Input.keyPush?(K_ESCAPE)
      bar.set_info(lst[count], count, lst.length)
      bar.draw
      count += 1
      count = 0 if count >= lst.length
    end
  end
end


