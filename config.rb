#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 20:25:04 +0900>
#
# 設定ファイル関係のクラス

require 'singleton'
require 'dxruby'
require 'win32ole'
require_relative 'ayame'
require_relative 'seq'
require_relative 'imagedata'
require_relative 'animekind'

# ----------------------------------------
#
# === 設定ファイル管理用
#
# グローバル変数相当
#
class Conf

  include Singleton

  VER_NUM = "0.0.1"
  APPLI_NAME = "Anime PV Easy Maker ZERO"
  APPLI_TITLE = APPLI_NAME + " " + VER_NUM
  APPLI_ICON = 'appli_icon.ico'

  # 設定ファイル名
  DEFAULT_INI = "_setting.txt"
  
  # ファイルやフォルダの場所の初期値
  DEF_INI = {
    'screenwidth' => 640,
    'screenheight' => 360,
    'fps' => 24,
    'seqimgoutmode' => 0,
    'sshotsave' => 1,
    'soundfile' => 'sampledata/sample1.mp3',
    'imgdir' => 'sampledata/image1',
    'savefile' => '_log.txt',
    'outdir' => 'output',
    'definebat' => 'img2avi_def.bat',
  }

  # 数値として扱う項目
  VALUE_KEY = ['screenwidth', 'screenheight', 'fps', 'seqimgoutmode', 'sshotsave']

  # パスとして扱う項目
  PATH_KEY = ['soundfile', 'imgdir', 'savefile', 'outdir', 'definebat']
  
  # サンプルファイルの場所
  DEF_INI_NONE = {
    'sound' => 'sampledata/sample1.mp3',
    'image' => 'sampledata/image1',
  }

  # 読み込めるサウンド種類(ファイル選択ダイアログ使用時に利用)
  SNDEXT = [["ogg, wav, mp3", "*.ogg;*.wav;*.mp3"], ["all(*.*)", "*.*"]]

  # 読み込める画像種類(ファイル選択ダイアログ使用時に利用)
  IMGEXT = [["bmp, jpg, png", "*.bmp;*.jpg;*.png"], ["all(*.*)", "*.*"]]

  # 読み込める画像種類(ファイル選択ダイアログ使用時に利用)
  OUTDIREXT = [["all(*.*)", "*.*"]]

  # 連番画像出力フォーマット。seqimgoutmode と対応
  OutFmt = Struct.new("OutFmt", :ext, :fmt)
  OUT_FMT = [
             OutFmt.new('.bmp', FORMAT_BMP),
             OutFmt.new('.jpg', FORMAT_JPG),
             OutFmt.new('.png', FORMAT_PNG),
            ]

  BGCOL_DEF = [241, 196, 15] # 標準として使う背景色

  # 利用できるウインドウサイズ
  SCR_SIZE = [
              [512, 288],
              [512, 384],
              [640, 360],
              [640, 480],
              [800, 450],
              [800, 600],
              [1280, 720],
             ]

  # 利用できるFPS
  FPS_LIST = [ 24, 30 ]
  
  # 初期化処理
  def initialize
    if (defined?(Ocra))
      # Ocra でコンパイル中ならここを通る
      puts "Use Ocra"
    end
    fpath = ENV['OCRA_EXECUTABLE'] || $0 # Ocra対策
    
    @cdir = File.expand_path(File.dirname(fpath))
    @conf_fname = File.expand_path(@cdir + '/' + DEFAULT_INI)
    
    @key_tbl = AnimeKind.load_key_table(@cdir)
    @ini = Hash.new
    
    @bgcol_def = BGCOL_DEF
    @play_only_mode = false
    @outmode_enable = false
    @imgdt = ImageData.new
    @click_se_req = false
    
    @font10 = Font.new(10, 'ＭＳ ゴシック')
    @font12 = Font.new(12, 'ＭＳ ゴシック')

    @app = FolderSelect.get_app
    
    read_config
    conv_string_to_int
    check_file_exist
  end

  attr_accessor :ini, :bgcol_def, :imgdt, :click_se_req, :font10, :font12, :font_large, :font_large2, :app

  # カレントフォルダのパスを返す (最後に'/'はついてない)
  def get_current_dir
    return @cdir
  end
  
  # 設定値を初期化
  def init_config_default
    DEF_INI.each_key do |key|
      v = DEF_INI[key]
      @ini[key] = (PATH_KEY.include?(key))? (@cdir + '/' + v) : v
    end
  end

  # 数値を持つはずの設定値を数値に変換
  def conv_string_to_int
    VALUE_KEY.each { |key| @ini[key] = @ini[key].to_i }
  end
  
  # 設定ファイルを読み込み
  def read_config
    init_config_default
    if File.exist?(@conf_fname)
      f = File.open(@conf_fname)
      f.each_line do |l|
        l.chomp!
        if l =~ /^(.+) = (.+)$/
          @ini[$1] = $2
        end
      end
      f.close
      conv_string_to_int
      return true
    else
      write_config
      return false
    end
  end

  # 設定ファイルを書き込み
  def write_config
    s = ""
    @ini.each_key { |key| s += sprintf("%s = %s\n", key, @ini[key].to_s) }
    f = File.open(@conf_fname, "w")
    f.write(s)
    f.close
  end

  # ユーザが用意したファイルが無ければサンプルファイル群を使うように指定
  def check_file_exist
    unless check_sound_exist?(@ini['soundfile'])
      @ini['soundfile'] = @cdir + '/' + DEF_INI_NONE['sound']
    end
    
    unless check_images_exist?(@ini['imgdir'])
      @ini['imgdir'] = @cdir + '/' + DEF_INI_NONE['image']
    end
  end

  # サウンドファイルが存在するか調べる
  def check_sound_exist?(path)
    return File.exist?(path)
  end
  
  # 画像ファイル群が存在するか調べる
  def check_images_exist?(imgdir)
    imgfiles = Dir.glob(imgdir + '/*.{jpg,png,bmp}').sort
    return (imgfiles.length == 0)? false : true
  end

  # 値を変更
  def set_value(key, value)
    @ini[key] = value
  end

  # 値を読み取り
  def get_value(key)
    return @ini[key]
  end

  # 連番画像出力モードか否かを返す
  def outmode?
    return @outmode_enable
  end

  # 連番画像出力モードフラグを無効化
  def clear_outmode
    @outmode_enable = false
  end

  # 連番画像出力モードフラグを有効化
  def set_outmode
    @outmode_enable = true
  end

  # 連番画像出力のインデックス値を取得
  def get_outmode_index
    return @ini['seqimgoutmode']
  end

  # 連番画像出力の拡張子を取得
  def get_outmode_ext
    return OUT_FMT[@ini['seqimgoutmode']].ext
  end

  # 連番画像出力の画像フォーマットを取得
  def get_outmode_format
    return OUT_FMT[@ini['seqimgoutmode']].fmt
  end

  # 連番画像出力モード値をインクリメント
  def inc_outmode
    @ini['seqimgoutmode'] = (@ini['seqimgoutmode'] + 1) % OUT_FMT.length
    write_config
  end
  
  # 連番画像出力モード値をデクリメント
  def dec_outmode
    nmax = OUT_FMT.length
    @ini['seqimgoutmode'] = (@ini['seqimgoutmode'] - 1 + nmax) % nmax
    write_config
  end
  
  # 再生モードか否かを返す
  def playmode?
    return @play_only_mode
  end

  # 再生モードフラグを無効化
  def clear_playmode
    @play_only_mode = false
  end

  # 再生モードフラグを有効化
  def set_playmode
    @play_only_mode = true
  end
  
  # fps設定値を返す
  def get_fps
    return @ini['fps']
  end
  
  # fps値を変更
  def set_fps(fpsv)
    @ini['fps'] = fpsv
    write_config
  end

  # 画面サイズを返す
  def get_screen_size
    return @ini['screenwidth'].to_i, @ini['screenheight'].to_i
  end

  # 画面サイズを変更
  def set_screen_size(w, h)
    @ini['screenwidth'] = w
    @ini['screenheight'] = h
    write_config
  end
  
  # 受け付けるキーボードの一覧情報を返す
  def get_key_tbl
    return @key_tbl
  end

  # 連番画像書き出し時の処理方法種類を返す
  #
  # true :: 画面に描画＋スクリーンショット保存
  # false :: 内部生成＋イメージ保存
  def screenshot_save?
    return (@ini['sshotsave'] == 0)? false : true
  end

  # 連番画像書き出し時の処理方法を切り替える
  def change_screenshot_savemode
    @ini['sshotsave'] = (@ini['sshotsave'] == 0)? 1 : 0
  end
  
  # ログファイル(記録ファイル)のパスを返す
  def get_log_path
    return @ini['savefile']
  end

  # ログファイル(記録ファイル)のパスを変更する
  def set_log_path(fpath)
    @ini['savefile'] = File.expand_path(fpath)
    write_config
  end

  # 画像リソースフォルダのパスを返す ('/'が最後につく)
  def get_res_dir
    return get_current_dir + '/res/' # 全ファイルはこのリソースパスを使う
  end

  # アプリアイコンのパスを返す
  def get_appli_icon_path
    return get_res_dir + APPLI_ICON
  end
  
  # ffmpeg用のバッチファイル(定義部分のみ)を出力
  def output_ffmpeg_bat
    outfn = @ini['definebat']
    odir = @ini['outdir'].gsub("/", "\\")
    inmusic = @ini['soundfile'].gsub("/", "\\")
    ext = get_outmode_ext
    fpsv = @ini['fps']
    l = [
         "set OUTDIR=#{odir}",
         "set INMUSIC=\"#{inmusic}\"",
         "set INIMAGE=\"%OUTDIR%\\%%08d#{ext}\"",
         "set OUTAVI=\"%OUTDIR%\\output.avi\"",
         "set OUTMP4=\"%OUTDIR%\\output.mp4\"",
         "set TMPWAV=\"%OUTDIR%\\music.wav\"",
         "set PASSLOG=\".\\passlog\"",
         "set FPSV=#{fpsv}",
         "",
        ]
    f = File.open(outfn, 'w')
    f.write(l.join("\n"))
    f.close
  end
  
end

