#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/01 20:03:39 +0900>
#
# キーを押したタイミングで映像を切り替えていく処理

require 'dxruby'
require_relative 'ayame'
require_relative 'msgwdw'
require_relative 'anime'
require_relative 'animekind'
require_relative 'keymapdisp'

class RecSeq
  FG_COL = [255, 255, 255]  # 文字色
  BG_COL = [0, 0, 0]        # 背景色
  NMLWDW = MessageWindow::NMLWDW
  ERRWDW = MessageWindow::ERRWDW

  def initialize(cfg, lap)
    @cfg = cfg
    @lap = lap
    @fpsv = @cfg.get_fps
    @scrw, @scrh = @cfg.get_screen_size
    @err = Array.new
    @keytbl = @cfg.get_key_tbl
    @anime = Anime.new(@cfg)
    @cntdown = CountDown.new(@cfg)
    @keydisp = KeymapDisp.new(@cfg)
    @delmsgimg = Image.load(@cfg.get_res_dir + 'delmsg.png')
    @fnts = @cfg.font12
    @timeline = TimeLine.new(@cfg) # タイムラインもどきを生成
    @bgm = Bgm.new
    @msg = MessageWindow.new(@cfg)
    @render = nil
    init_work
  end
  
  # ワーク初期化
  def init_work
    @step = 0
    @nextstep = 0
    @wait_timer = 0
    @frame = 0
    @end_after_count = 0
    @start_utime = 0
    @retry_count = 0
    @tmp_cnt = 0
    @anime.init_work
    @keydisp.init_work
    @odir = @cfg.get_value('outdir')
    @ext = @cfg.get_outmode_ext
    @outfmt = @cfg.get_outmode_format
    @sshotsave = @cfg.screenshot_save?
    @compromise_fps = @fpsv
    @fps_cache = Array.new
  end

  # BGM読み込み
  def load_bgm
    @bgm.load(@cfg.get_value('soundfile'))
  end
  
  # 更新処理
  def update_and_draw

    unless @err.empty?
      # エラーメッセージがあるなら表示
      x, y = 16, 16
      @err.each do |s|
        Window.drawFont(x, y, s, @fnts, :color => FG_COL)
        y += @fnts.size + 8
      end
      return -1
    end
    
    # 通常処理
    
    case @step
    when 0
      # ワーク初期化、画像読み込み
      init_work

      Window.bgcolor = BG_COL
      Window.fps = @fpsv

      unless @cfg.outmode?
        # 連番画像出力モードではない
        Window.frameskip = true
        @cntdown.start_countdown
      else
        # 連番画像出力モード
        Window.frameskip = false
        @compromise_fps = @fpsv
        Window.fps = @compromise_fps
        unless @sshotsave
          if @render != nil
            @render.dispose unless @render.disposed?
          end
          @render = RenderTarget.new(@scrw, @scrh)
        end
        @tmp_cnt = 0
      end
      @step = 1

    when 1
      # カウントダウン画面を表示
      init_start = false
      unless @cfg.outmode?
        init_start = true if @cntdown.draw
      else
        init_start = true
      end
      
      if init_start
        # フレーム値だけを並べた配列を取得
        @anime.set_framelist(@lap.get_frame_list)
        @frame = 0
        @anime.set_next_image(0, @lap.laps[0], 0)
        @step = 2
      end

    when 2
      # 画像表示・時間記録画面

      if @cfg.outmode?
        # 連番画像出力モード実行中
        r = export_mode
        if r > 0
          unless @sshotsave
            @render.dispose unless @render.disposed?
            @render = nil
          end
          if r == 1
            set_msg("中断します", 1, NMLWDW, 5)
          elsif r == 2
            @cfg.output_ffmpeg_bat # ffmpeg用batファイルを出力
            set_msg("連番画像書き出しが終了しました", 2, NMLWDW, 5)
          else
            @err = ["原因不明のエラーが発生しました",
                    "処理を停止します"]
            set_msg("エラーが発生しました", 3, ERRWDW, 5)
          end
        end
      elsif @cfg.playmode?
        # 再生モード実行中
        r = play_mode
        if r == 1
          set_msg("中断します", 1, NMLWDW, 5)
        elsif r == 2
          set_msg("再生終了しました", 2, NMLWDW, 5)
        end
      else
        # 記録モード実行中
        ret = rec_mode
        if ret == 1
          # 途中終了が要求された
          set_msg("中断して開始画面に戻ります", 1, NMLWDW, 5)
        elsif ret == 2
          # 曲終了
          set_msg("曲が終了しました", 1, NMLWDW, 4)
        end
      end

    when 4
      # 記録したフレーム数をファイルとして出力
      if @lap.laps_changed?
        @lap.out_log
        ofn = @cfg.get_value('savefile')
        set_msg("ログ(記録)を\n#{ofn}\nに保存しました", 2, NMLWDW, 5)
      else
        set_msg("記録は変更されていません", 2, NMLWDW, 5)
      end

    when 5
      # 処理終了
      return 0

    when 7
      # メッセージを表示
      @msg.draw
      @step = @nextstep unless @msg.update
    end
    
    return -1
  end

  # メッセージ表示を設定
  def set_msg(str, sec, kind, nextstep)
    @msg.set_msg(str, sec, @fpsv, kind)
    @step = 7
    @nextstep = nextstep
  end

  # 「記録消去中」メッセージ画像を描画
  def draw_delete_message
    x = (@scrw - @delmsgimg.width) / 2
    y = (@scrh - @delmsgimg.height) / 2
    Window.draw(x, y, @delmsgimg)
  end

  # マイクロ秒単位で現在の時間を取得する
  def get_utime
    ct = Time.now
    return (ct.tv_sec * 1000000) + ct.tv_usec
  end

  # マイクロ秒を元にしてフレーム数を算出
  def get_frame_from_utime
    return ((get_utime - @start_utime) * @fpsv) / 1000000
  end
  
  # ----------------------------------------
  # 記録モード
  def rec_mode
    if @frame == 0
      # 0フレーム目なら、BGM再生開始・時間記録開始
      @bgm.play
      @start_utime = get_utime
    end

    if false
      # マイクロ秒を取得してフレーム数に変換する場合
      nowframe = get_frame_from_utime
    else
      # DXRubyのメインループでフレーム数をカウントする場合
      nowframe = @frame
    end
    
    # 消去キーを押してるか記録
    erase_enable = (Input.keyDown?(K_DELETE))? true : false

    # 既に記録済みのLAPと現在のフレーム数が一致したなら、画像を切り替える
    old_mode = ""
    if @lap.lap_exist?(nowframe) and nowframe > 0
      unless erase_enable
        old_mode = @lap.get_mode(nowframe)
        @anime.set_next_image(1, old_mode, nowframe)
      else
        @lap.delete_lap(nowframe) # 記録クリア
      end
    end

    if old_mode != "end"
      # 最終フレームに到達していない状態
      
      # ゲームパッド、キーボード、マウスボタンが押されたか調べる
      pushkey = ""
      mode = ""
      mode = @keydisp.check_push_key_by_mouse
      AnimeKind::PAD_LIST.each { |k,v| mode = v if Input.padPush?(k) }
      @keytbl.each do |t|
        if t.keycode and t.key != ""
          if Input.keyPush?(t.keycode)
            mode = t.mode
            pushkey = t.key
          end
        end
        
      end
      
      if mode != "" and old_mode != "end"
        # ボタンが押されていたので次画像を表示すべくカウンタを進める
        @lap.save_lap(nowframe, mode)
        @anime.set_next_image(1, mode, nowframe)
        @keydisp.set_pushkey(pushkey)
      end
    end

    # 画像描画
    @anime.draw

    # タイムラインもどきを描画
    @timeline.update(@lap.laps, nowframe)
    @timeline.draw(@lap.get_time_string(nowframe))

    # キーボード表示
    @keydisp.draw

    # 消去中なら消去を示す文字列を表示
    draw_delete_message if erase_enable

    if old_mode == "end"
      # 最終フレームに到達した
      return 2
    elsif Input.keyPush?(K_BACKSPACE) then
      # BSキーを押したら途中で終了
      @bgm.stop
      return 1
    elsif (@frame > (3 * @fpsv) and !(@bgm.playing?))
      # 曲が終了
      @bgm.stop
      
      # 最後のフレームを"end"として記録
      mode = "end"
      if @lap.save_lap_not_overwrite(nowframe, mode)
        @anime.set_next_image(1, mode, nowframe)
      end
      return 2
    end

    @frame += 1
    return 0
  end

  # ----------------------------------------
  # 再生モード
  def play_mode
    @bgm.play if @frame == 0
    
    if @lap.lap_exist?(@frame) and @frame > 0
      @anime.set_next_image(1, @lap.get_mode(@frame), @frame)
    end
    
    @anime.draw
    
    if Input.keyPush?(K_BACKSPACE)
      # BSキーを押したら途中で終了
      @bgm.stop
      return 1
    elsif (@frame > (3 * @fpsv) and !(@bgm.playing?))
      # 曲が終了
      @bgm.stop
      return 2
    end

    @frame += 1
    return 0
  end

  # ----------------------------------------
  # exportモード
  def export_mode
    @tmp_cnt += 1

    # FPSが全く間に合って無かったらFPSを落としていく
    rfps = Window.real_fps
    @fps_cache.push(rfps)
    if @fps_cache.length >= (@fpsv * 3)
      r = 0
      @fps_cache.each { |i| r += i }
      r = (r / @fps_cache.length).to_i
      @fps_cache.clear
      if @compromise_fps > r
        if r >= 5
          @compromise_fps = r - 2
        else
          @compromise_fps = 3
        end
        Window.fps = @compromise_fps
      elsif @compromise_fps + 3 < r
        @compromise_fps = r
        Window.fps = @compromise_fps
      end
    end
    
    endfg = (@frame >= @anime.last_frame)? true : false

    if @retry_count <= 0
      # 記録済みLAPと現在フレーム数が一致したら画像を切り替える
      if (@lap.lap_exist?(@frame) and @frame > 0)
        @anime.set_next_image(1, @lap.get_mode(@frame), @frame)
      end
    end

    unless endfg
      fn = sprintf("%s/%08d%s", @odir, @frame, @ext)
      if @sshotsave
        # 画面描画結果をスクリーンショットとして保存
        @anime.draw
        if @frame > 0 then
          Window.getScreenShot(fn, @outfmt)
        end
      else
        # RenderTargetに描画して保存
        if @retry_count <= 0 or @tmp_cnt % 3 == 0
          @render.dispose unless @render.disposed?
          @render = RenderTarget.new(@scrw, @scrh)
          @anime.draw_rendertarget(@render)
          if @frame > 0 then
            begin
              img = @render.toImage
              img.save(fn, @outfmt)
              img.dispose unless img.disposed?
            rescue
              # 保存に失敗
              @retry_count += 1
            else
              # 保存に成功
              @retry_count = 0
            end
            @anime.update_pos if @retry_count <= 0 # 座標更新
          end
          @render.dispose unless @render.disposed?
        end
      end
    end

    # 進行状況を描画
    s = sprintf("出力中 : %d / %d frame - %d / %d FPS",
                @frame, @anime.last_frame, rfps, @compromise_fps)
    Window.caption = s
    unless @sshotsave
      fnt = @cfg.font12
      s = (@retry_count <= 0)? "出力中" : "リトライ中"
      x = (@scrw - fnt.getWidth(s)) / 2
      by = (@scrh / 2)
      y = by - (fnt.size + 24)
      colv = (128 + 127 * Math.cos(@tmp_cnt * 20 * Math::PI / 180.0)).to_i
      colv = 0 if colv < 0
      colv = 255 if colv > 255
      Window.drawFont(x, y, s, fnt, :color => FG_COL, :alpha => colv)

      s = sprintf("%d / %d frame", @frame, @anime.last_frame)
      x = (@scrw - fnt.getWidth(s)) / 2
      y = by + 24
      Window.drawFont(x, y, s, fnt, :color => FG_COL)
    end

    retcode = 0
    if Input.keyPush?(K_BACKSPACE)
      # BSキーで強制終了可能
      retcode = 1
    elsif endfg
      retcode = 2
    elsif @retry_count > 0
      # リトライ中
      retcode = 3 if @retry_count > 30
    end

    if retcode > 0
      @cfg.clear_outmode
      Window.caption = Conf::APPLI_TITLE
      Window.frameskip = true
      Window.fps = @fpsv
      return retcode
    end
    
    @frame += 1 if @retry_count <= 0
    return 0
  end

end

# ----------------------------------------
#
# === タイムラインもどき用
#
class TimeLine
  BG_COL = [0, 0, 0]
  FG_COL = [255, 255, 255]
  SHADOW_PLOT_LIST = [[1,0], [-1,0], [0,1], [0,-1]]

  def initialize(cfg)
    @cfg = cfg
    @scrw, @scrh = @cfg.get_screen_size
    tbl = @cfg.get_key_tbl
    
    @col_list = Hash.new
    tbl.each { |t| @col_list[t.mode] = t.col }
    
    @fnts = Font.new(14, 'ＭＳ ゴシック', :weight => true)
    @tm_img_w = 16
    @tm_step = 6
    @baseimg = Image.new(@tm_img_w, @scrh)
    @tmimg = Image.new(@tm_img_w, @scrh)
    # @awimg = Image.new(@scrw, @scrh)

    # 下地画像を作成
    @baseimg.fill([192,0,0,0])
    @sx1 = 2
    @sx2 = @tm_img_w - @sx1 -1
    @yadd = @tm_step - 3
    2.step(@scrh -1, @tm_step) do |y|
      @baseimg.boxFill(@sx1, y, @sx2, y + @yadd, [255,192,192,192])
    end
  end

  # タイムライン画像を再作成
  def update(lst, cnt)
    @tmimg.fill([0,0,0,0])
    2.step(@scrh -1, @tm_step) do |y|
      if lst.has_key?(cnt)
        mode = lst[cnt]
        col = (@col_list.has_key?(mode))? @col_list[mode] : [255, 255, 0]
        @tmimg.boxFill(@sx1, y, @sx2, y + @yadd, col)
      end
      cnt += 1
    end
  end

  # 描画
  def draw(frame_str)
    # タイムライン画像を描画
    Window.draw( 8, 0, @baseimg)
    Window.draw( 8, 0, @tmimg)
    
    # フレーム数描画
    x = 8 + @tm_img_w + 8
    y = 2
    SHADOW_PLOT_LIST.each do |a|
      Window.drawFont(x+a[0], y+a[1], frame_str, @fnts, :color => BG_COL)
    end
    Window.drawFont(x, y, frame_str, @fnts, :color => FG_COL)

    # フレームレート、CPU負荷率を表示
    s = sprintf("FPS:%2d CPU:%3d%%", Window.real_fps.to_i, Window.getLoad)
    y = @scrh - 16
    SHADOW_PLOT_LIST.each do |a|
      Window.drawFont(x+a[0], y+a[1], s, @fnts, :color => BG_COL)
    end
    Window.drawFont(x, y, s, @fnts, :color => FG_COL)
  end
  
end

#
# === BGM再生停止処理用クラス
#
class Bgm
  def initialize
    @sound = nil
  end

  # BGM再生用の領域を解放
  def dispose
    if @sound
      @sound.stop(0)
      @sound.dispose
    end
  end
  
  # BGM再生開始
  def play
    @sound.play(1,0) if @sound
  end
  
  # BGM再生終了
  def stop
    @sound.stop(0) if @sound
  end
  
  # BGM再生中か否か
  def playing?
    return @sound.playing?
  end
  
  # BGMファイル読み込み
  def load(fname)
    dispose
    if File.exist?(fname)
      @sound = Ayame.new(fname)
      @sound.predecode
      return true
    end
    return false
  end
end

#
# === カウントダウン表示用クラス
#
class CountDown
  def initialize(cfg)
    @scrw, @scrh = cfg.get_screen_size
    @fpsv = cfg.get_fps
    @numimgs = Image.loadToArray(cfg.get_res_dir + 'number123.png', 3, 1)
    @chipimg = Image.new(8, 40, [255, 183, 200, 183])

    # BG画像生成
    @hsw = @scrw / 2
    @hsh = @scrh / 2
    bgcol = [255, 145, 138, 111]
    linecol = [255, 96, 96, 96]
    @bgimg = Image.new(@scrw, @scrh, bgcol)
    @bgimg.line(0, @hsh, @scrw, @hsh, linecol)
    @bgimg.line(@hsw, 0, @hsw, @scrh, linecol)
    r = @hsh - 24
    @bgimg.circleFill(@hsw, @hsh, r + 4, bgcol)
    @bgimg.circle(@hsw, @hsh, r, linecol)
    
    @count = 0
  end

  def start_countdown
    @count = 3 * @fpsv - 1
  end

  def draw
    Window.draw(0, 0, @bgimg)
    
    if @count >= 0
      n = @count / @fpsv
      cnt = @count % @fpsv

      # 残りフレーム数を描画
      ang_add = (360.0 / @fpsv)
      ang = 0
      dx = @chipimg.width / 2
      dy = @chipimg.height / 2
      r = @hsh - 12 - dy
      @fpsv.times do |i|
        rad = (ang - 90) * Math::PI / 180.0
        x = @hsw + r * Math.cos(rad) - dx
        y = @hsh + r * Math.sin(rad) - dy
        if i <= cnt
          Window.drawRot(x, y, @chipimg, ang)
        end
        ang += ang_add
      end

      # 数字を描画
      if n >= 0 and n < 3
        img = @numimgs[n]
        x = (@scrw - img.width) / 2
        y = (@scrh - img.height) / 2
        Window.draw(x, y, img)
      end

      @count -= 1
      return false if @count >= 0
    end
    return true
  end
end
