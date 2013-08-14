#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 02:57:55 +0900>
#
# AnimePvEasyMaker
# 曲とタイミングを合わせたPV簡易作成ツール
#
# Ayame を使っているため、Ruby 1.9.x が必要。
#
# 0.0.1  2013/08/02  とりあえずそこそこ完成
#
# License :  Public domain
#

require 'rubygems'
require 'dxruby'
require_relative 'ayame'
require_relative 'config'
require_relative 'seq'
require_relative 'mnote'
require_relative 'laps'
require_relative 'select'
require_relative 'recseq'

# ステップ定義
STEP_TITLE = 0
STEP_ABOUT = 1
STEP_BGMSEL = 2
STEP_IMGSEL = 3
STEP_MENU = 4
STEP_RECTITLE = 5
STEP_RECTHELP = 6
STEP_EXPORTTITLE = 7
STEP_CFG = 8
STEP_RECMODE = 9
STEP_PLAYMODE = 10
STEP_EXPORTMODE = 11

# ボタン種類
CBTN = BornButton::CBTN
BBTN = BornButton::BBTN
STIL = BornButton::STIL

# タイトル画面用ボタン表示テーブル
TITLE_BTN_LIST = [
                  # ButtonKind, kind, keycode, imagefile, strnum, x, y
                  [STIL, -1, nil, 'titlelogo.png', '', 0.5, 0.166],
                  [BBTN, 0, K_C, 'start_btn2.png', '', 0.5, 0.6],
                  [BBTN, 1, K_Z, 'config_btn.png', '', 1.0, 1.0],
                 ]

# つかいかた画面用ボタン表示テーブル
HOWTOUSE_BTN_LIST = [
                     [STIL, -1, nil, 'what_logo.png', '', 0.5, 0.0],
                     [STIL, -1, nil, 'what_text.png', '', 0.5, 0.20],
                     [STIL, -1, nil, 'what_illust.png', '', 0.5, 0.444],
                     [STIL, -1, nil, 'what_info.png', '', 0.0, 1.0],
                     [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
                     [BBTN, 1, K_C, 'what_next_btn.png', '', 1.0, 1.0],
                    ]

# 記録開始直前の操作画面説明表示用テーブル
HOWTOUSE2_BTN_LIST = [
                      [STIL, -1, nil, 'howtouse_3.png', '', 0.5, 0.5],
                      [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
                     ]

def main_job
  fnt = Font.new(12, 'ＭＳ ゴシック')

  cfg = Conf.instance
  scrw, scrh = cfg.get_screen_size

  Window.resize(scrw, scrh)
  Window.caption = Conf::APPLI_TITLE
  Window.bgcolor = Conf::BGCOL_DEF
  Window.loadIcon(cfg.get_appli_icon_path)
  Window.fps = cfg.get_fps
  Window.frameskip = true

  step = 0
  count = 0
  err = ""
  se = nil
  mnotes = nil
  lap = nil
  rec = nil
  scene = []
  init_step = 0
  se_use_ayame = true

  Window.loop do
    if init_step >= 0
      # 初期化処理
      Window.drawFont(8, 8, "初期化中 ... ", fnt , :color => [0,0,0])
      case init_step
      when 0..3
        init_step += 1
      when 4
        fn = cfg.get_res_dir + 'clickse.wav'
        if se_use_ayame
          se = Ayame.new(fn)
          se.predecode
        else
          se = Sound.new(fn)
        end
        mnotes = MusicNotes.new(cfg)
        lap = Laps.new(cfg)
        
        # 各シーンの処理を行うインスタンスを確保
        scene.push(SeqScene.new(cfg, lap, TITLE_BTN_LIST, STEP_TITLE, 0, scrh))
        scene.push(SeqScene.new(cfg, lap, HOWTOUSE_BTN_LIST, STEP_ABOUT, 0, scrh))
        scene.push(MusicSelect.new(cfg, lap, STEP_BGMSEL, 0, scrh))
        scene.push(ImagesSelect.new(cfg, lap, STEP_IMGSEL, 0, scrh))
        scene.push(MenuSeq.new(cfg, lap, STEP_MENU, 0, scrh))
        scene.push(RecTitle.new(cfg, lap, STEP_RECTITLE, 0, scrh))
        scene.push(SeqScene.new(cfg, lap, HOWTOUSE2_BTN_LIST, STEP_RECTHELP, 0, scrh))
        scene.push(ExportTitle.new(cfg, lap, STEP_EXPORTTITLE, 0, scrh))
        scene.push(ConfigSeq.new(cfg, lap, STEP_CFG, scrw, 0))
        rec = RecSeq.new(cfg, lap)
        init_step += 1
      when 5
        step = STEP_TITLE
        scene[STEP_TITLE].framein
        init_step = -1
      end
      
      next
    end
    
    break if Input.keyPush?(K_ESCAPE) # ESCキーで終了

    unless err == ""
      # エラーメッセージ表示
      Window.bgcolor = [0,0,0]
      err.split(/\n/).each_with_index do |s, i|
        Window.drawFont(16, 16 + i * 16, s, fnt, :color => [255,255,255])
      end
      next
    end
    
    case step
    when STEP_TITLE..STEP_CFG
      # 各種選択画面
      
      mnotes.draw # 背景の音符を描画

      ret = -1
      scene.each_with_index do |sc,i|
        fg = (sc.step_kind == step)? true : false
        r = sc.update(fg)
        ret = r if fg
      end
      
      case step
      when STEP_TITLE
        # タイトル画面
        case ret
        when -1
          # 何もしない
        when 0
          # 使い方説明画面へ移行
          step = STEP_ABOUT
          scene[STEP_TITLE].frameout_up
          scene[STEP_ABOUT].framein
        when 1
          # 設定画面へ移行
          step = STEP_CFG
          scene[STEP_TITLE].frameout_left
          scene[STEP_CFG].framein
        end
        
        str = Window.real_fps.to_s + " FPS / Ruby " + RUBY_VERSION
        Window.drawFont(16, scrh - 14, str, cfg.font12, :color => [0,0,0])

      when STEP_ABOUT
        # 使い方説明画面
        case ret
        when -1
          # 何もしない
        when 0
          # タイトル画面へ移行
          step = STEP_TITLE
          scene[STEP_TITLE].framein
          scene[STEP_ABOUT].frameout_down
        when 1
          # 曲選択画面へ移行
          step = STEP_BGMSEL
          scene[STEP_ABOUT].frameout_up
          scene[STEP_BGMSEL].framein
        end

      when STEP_BGMSEL
        # 曲選択画面
        case ret
        when -1
          # 何もしない
        when 0
          # 画像選択画面へ移行
          step = STEP_IMGSEL
          scene[STEP_BGMSEL].frameout_up
          scene[STEP_IMGSEL].framein
          unless rec.load_bgm
            path = cfg.get_value('soundfile')
            err = "Error : Can't load BGM.\n #{path}"
          end
          
        when 1
          # 使い方説明画面へ移行
          step = STEP_ABOUT
          scene[STEP_ABOUT].framein
          scene[STEP_BGMSEL].frameout_down
        end
        
      when STEP_IMGSEL
        # 入力画像フォルダ選択画面
        case ret
        when -1
          # 何もしない
        when 0
          # メニュー画面へ移行
          step = STEP_MENU
          scene[STEP_IMGSEL].frameout_up
          scene[STEP_MENU].framein
        when 1
          # 曲選択画面へ移行
          step = STEP_BGMSEL
          scene[STEP_BGMSEL].framein
          scene[STEP_IMGSEL].frameout_down
        end
        
      when STEP_MENU
        # メニュー画面
        case ret
        when -1
          # 何もしない
        when 0
          # 記録開始画面へ移行
          step = STEP_RECTITLE
          cfg.clear_playmode
          cfg.clear_outmode
          scene[STEP_MENU].frameout_up
          scene[STEP_RECTITLE].framein
          lap.get_log
        when 1
          # 再生モードへ移行
          step = STEP_PLAYMODE
          cfg.set_playmode
          cfg.clear_outmode
          lap.get_log
          rec.init_work
        when 2
          # 連番画像出力モードへ移行
          step = STEP_EXPORTTITLE
          cfg.clear_playmode
          cfg.set_outmode
          scene[STEP_MENU].frameout_up
          scene[STEP_EXPORTTITLE].framein
          lap.get_log
        when 3
          # 設定画面へ移行
          step = STEP_CFG
          scene[STEP_MENU].frameout_left
          scene[STEP_CFG].framein
          scene[STEP_CFG].chg_value = false
        when 4
          # 画像選択画面へ戻る
          step = STEP_IMGSEL
          scene[STEP_IMGSEL].framein
          scene[STEP_MENU].frameout_down
        end
        
      when STEP_RECTITLE
        # 記録開始画面
        case ret
        when -1
          # 何もしない
        when 0
          # 記録画面へ進む
          step = STEP_RECMODE
          rec.init_work
        when 1
          # メニュー画面へ戻る
          step = STEP_MENU
          scene[STEP_MENU].framein
          scene[STEP_RECTITLE].frameout_down
        when 2
          # 操作説明画面へ進む
          step = STEP_RECTHELP
          scene[STEP_RECTITLE].frameout_up
          scene[STEP_RECTHELP].framein
        end

      when STEP_RECTHELP
        # 記録開始直前の操作説明画面
        if ret == 0
          # 記録開始画面へ戻る
          step = STEP_RECTITLE
          scene[STEP_RECTITLE].framein
          scene[STEP_RECTHELP].frameout_down
        end
        
      when STEP_EXPORTTITLE
        # 連番画像出力モード開始画面
        case ret
        when -1
          # 何もしない
        when 0
          # 出力モードへ移行
          cfg.clear_playmode
          cfg.set_outmode
          step = STEP_EXPORTMODE
          rec.init_work
        when 1
          # メニュー画面へ移行
          step = STEP_MENU
          cfg.clear_playmode
          cfg.clear_outmode
          scene[STEP_MENU].framein
          scene[STEP_EXPORTTITLE].frameout_down
        end

      when STEP_CFG
        # 設定画面
        if ret == 0
          # タイトル画面へ移行
          step = STEP_TITLE
          scene[STEP_TITLE].framein
          scene[STEP_CFG].frameout_right
        end
      end

      # 各シーンの描画
      scene.each { |sc| sc.draw }
      
    when STEP_RECMODE
      # 記録画面
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_RECTITLE
      end
      
    when STEP_PLAYMODE
      # 再生モード
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_MENU
        cfg.clear_playmode
        cfg.clear_outmode
      end
      
    when STEP_EXPORTMODE
      # 連番画像出力モード
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_EXPORTTITLE
        cfg.clear_playmode
        cfg.clear_outmode
      end
    end
    
    # SE再生処理
    if cfg.click_se_req
      if se_use_ayame
        se.play(1,0)
      else
        se.play
      end
      cfg.click_se_req = false
    end
    
    count += 1
    Ayame.update
  end

  if se_use_ayame
    se.stop(0)
    se.dispose
  else
    se.dispose
  end
end

main_job
exit
