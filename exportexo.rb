#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 12:10:53 +0900>
#
# exoファイルエクスポート処理

require_relative 'config'
require_relative 'laps'
require_relative 'anime'

# ----------------------------------------
#
# === exoファイルに出力する情報を記録・計算するクラス
#
# 以下は、2013/07/27現在のexoファイル内記述についてのメモ
#
# ==== x,y,z,拡大率等について。
# * 変化が無い場合は、値のみの記述になる。
# * 直線移動時は、[開始値, 終了値, 1] の記述になる。
# * 加減速移動時は、[開始値, 終了値, 0x?7] になる模様。
#   最後の値は、
#   * 0x27なら減速のみ。
#   * 0x47なら加速のみ。
#   * 0x67 なら加速減速。
# おそらく以下のような割り振り。
# (0as0 0111)B
#   ||
#   |+-- 減速フラグ
#   +--- 加速フラグ
#
class ExoBlock
  def initialize(num, startfrm, endfrm, mode, imgfn, scrw, scrh)
    @num = num
    @mode = mode
    @scrw, @scrh = scrw, scrh
    @imgfn = imgfn
    @start_frame = startfrm
    @end_frame = endfrm
  end

  # モードに応じて素材番号をいくつ消費するかを返す
  def get_add_num
    ret = 1
    case @mode
    when "f.i", "f.o", "w.i", "w.o"
      ret = 2
    end
    return ret
  end

  # パラメータが変化していく場合のテキストを文字列で返す
  def get_array_s(s, v)
    l = Array.new
    l.push(sprintf("%.2f", v[0]))
    l.push(sprintf("%.2f", v[1]))
    l.push(sprintf("%d", v[2]))
    return "#{s}=" + l.join(",")
  end

  # exoファイル内に出力すべきテキストを返す
  def get_text
    if @mode == "end"
      return ""
    end

    # 画像ロード
    fg = true
    begin
      begin
        img = Image.load(@imgfn)
      rescue
        fg = true
        sleep(0.5)
      else
        fg = false
      end
    end while fg
    fn = @imgfn.gsub(/\//, "\\")
    
    l = ["[#{@num}]",
         "start=#{@start_frame}", "end=#{@end_frame}",
         "layer=1", "overlay=1", "camera=1",
         "[#{@num}.0]",
         "_name=画像ファイル", "file=#{fn}" ]

    w, h = img.width, img.height
    
    # 拡大縮小率を決定
    sx = @scrw.to_f / w.to_f
    sy = @scrh.to_f / h.to_f
    scale = ([sx, sy].max) * 100.0

    # その他お決まりの文字列を設定
    alpha_str = "透明度=0.0"
    rot_str = "回転=0.0"
    blend_str = "blend=0"

    case @mode
    when "fix"
      # 固定
      l += ["[#{@num}.1]",
            "_name=標準描画", "X=0.0", "Y=0.0", "Z=0.0",
            "拡大率=#{scale}", alpha_str, rot_str, blend_str]

    when "end"
      # 最終フレーム
      
    when "up", "down"
      # y方向スクロール
      if scale < 100.0
        # 画像のほうが画面サイズより大きい
        d = (h - @scrh) / 2.0
        tscale = "100.00"
      else
        # 画像のほうが画面サイズより小さい
        new_scale = scale + 50
        d = ((h * new_scale / 100.0) - @scrh) / 2.0
        tscale = sprintf("%.2f", new_scale)
      end
      v = (@mode == "up")? [d,-d,1] : [-d,d,1]
      l += ["[#{@num}.1]",
            "_name=標準描画", "X=0.0", get_array_s("Y", v), "Z=0.0",
            "拡大率=#{tscale}", alpha_str, rot_str, blend_str]
      
    when "left", "right"
      # x方向スクロール
      if scale < 100.0
        d = (w - @scrw) / 2.0
        tscale = "100.00"
      else
        new_scale = scale + 50
        d = ((w * new_scale / 100.0) - @scrw) / 2.0
        tscale = sprintf("%.2f", new_scale)
      end
      v = (@mode == "left")? [d,-d,1] : [-d,d,1]
      l += ["[#{@num}.1]",
            "_name=標準描画", get_array_s("X", v), "Y=0.0", "Z=0.0",
            "拡大率=#{tscale}", alpha_str, rot_str, blend_str]
    
    when "t.u", "t.b"
      # トラックアップ (拡大)、トラックバック (縮小)
      if @mode == "t.u"
        if scale < 100.0
          tgt = 100.0
        else
          tgt = scale + 50.0
        end
      else
        tgt = scale
        if scale < 100.0
          scale = 100.0
        else
          scale = scale + 50.0
        end
      end
      tscale = [scale, tgt, 1]
      l += ["[#{@num}.1]",
            "_name=標準描画", "X=0.0", "Y=0.0", "Z=0.0",
            get_array_s("拡大率", tscale),
            alpha_str, rot_str, blend_str]
      
    when "t.u2", "t.b2"
      # トラックアップ (拡大)、トラックバック (縮小)
      if @mode == "t.u"
        if scale < 100.0
          tgt = 100.0
        else
          tgt = scale + 50.0
        end
      else
        tgt = scale
        if scale < 100.0
          scale = 100.0
        else
          scale = scale + 50.0
        end
      end
      tscale = [scale, tgt, 0x27]
      l += ["[#{@num}.1]",
            "_name=標準描画", "X=0.0", "Y=0.0", "Z=0.0",
            get_array_s("拡大率", tscale),
            alpha_str, rot_str, blend_str]
      
    when "f.o"
      # フェードアウト (通常の明るさ → 真っ黒)
      l += get_fade_text(@num, 'out', '000000', scale)
      
    when "f.i"
      # フェードイン (真っ黒 → 通常の明るさ)
      l += get_fade_text(@num, 'in', '000000', scale)
      
    when "w.o"
      # ホワイトアウト (通常の明るさ → 真っ白)
      l += get_fade_text(@num, 'out', 'ffffff', scale)
      
    when "w.i"
      # ホワイトイン (真っ白 → 通常の明るさ)
      l += get_fade_text(@num, 'in', 'ffffff', scale)
    end
    
    return l.join("\n") + "\n"
  end
  
  # === フェードアウト・イン、ホワイトフェードアウト・イン用の文字列を返す
  def get_fade_text(num, mode, color_str, scale)
    alpha_str = (mode == 'out')? "100.0,0.0,1" : "0.0,100.0,1"
    num_s = num + 1
    l = [ "[#{@num}.1]",
          "_name=標準描画",
          "X=0.0", "Y=0.0", "Z=0.0",
          "拡大率=#{scale}",
          "透明度=0.0", "回転=0.0", "blend=0",
          
          "[#{num_s}]",
          "start=#{@start_frame}", "end=#{@end_frame}",
          "layer=2",
          "overlay=1", "camera=1",
          
          "[#{num_s}.0]",
          "_name=図形", "サイズ=100", "縦横比=0.0",
          "ライン幅=4000", "type=0",
          "color=#{color_str}",
          "name=",
          
          "[#{num_s}.1]",
          "_name=標準描画", "X=0.0", "Y=0.0", "Z=0.0", "拡大率=100.00",
          "透明度=#{alpha_str}",
          "回転=0.00", "blend=0" ]
    
    return l
  end

  # === 黒ベタ用の文字列を返す
  def get_black_only(num)
    lines = <<EOS
[#{num}.0]
_name=図形
サイズ=100
縦横比=0.0
ライン幅=4000
type=0
color=000000
name=
[#{num}.1]
_name=標準描画
X=0.0
Y=0.0
Z=0.0
拡大率=100.00
透明度=0.0
回転=0.00
blend=0
EOS
    return lines.split(/\n/)
  end
  
  # === サウンド指定用のテキストを返す
  def ExoBlock.get_text_sound_exo(cnt)
    lines = <<EOS
[#{cnt}]
start=1
end=6
layer=3
overlay=1
audio=1
[#{cnt}.0]
_name=音声ファイル
再生位置=0.00
再生速度=100.0
ループ再生=0
動画ファイルと連携=1
file=
[#{cnt}.1]
_name=標準再生
音量=100.0
左右=0.0
EOS
    return lines
  end
  
  # === exoのヘッダ文字列相当を返す
  def ExoBlock.get_exo_header(scrw, scrh, fps, lastframe)
    
    lines = <<EOS
[exedit]
width=#{scrw}
height=#{scrh}
rate=#{fps}
scale=1
length=#{lastframe}
audio_rate=44100
audio_ch=2
EOS
    
    return lines
  end

end

# ----------------------------------------
#
# === exoファイルを出力
#
class ExportExo
  
  # exoファイルを出力
  def ExportExo.export_exo_file(fn, cfg, lap)
    outstr = ""
    @anime = Anime.new(cfg)
    @anime.set_framelist(lap.get_frame_list)
    
    s = ExoBlock.get_exo_header(cfg.get_value('screenwidth'),
                                cfg.get_value('screenheight'),
                                cfg.get_fps,
                                @anime.last_frame)
    outstr += s
    
    exb = @anime.get_next_exoblock(0, lap.laps[0], 0)
    outstr += exb.get_text
    
    @frame = 0
    while @frame <= @anime.last_frame
      if (lap.lap_exist?(@frame) and @frame > 0)
        mode = lap.get_mode(@frame)
        unless mode == "end"
          exb = @anime.get_next_exoblock(1, mode, @frame)
          outstr += exb.get_text
        end
      end
      @frame += 1
    end
    outstr += @anime.get_last_exo_block

    f = File.open(fn, "w")
    f.write(outstr)
    f.close
  end
end

if $0 == __FILE__

  kind = "ExportExo"
  # kind = "ExoBlock"

  case kind
  when "ExportExo"
    # ExportExo の動作テスト
    cfg = Conf.instance
    lap = Laps.new(cfg)
    lap.get_log
    outfn = "output/_log.exo"
    
    if cfg.imgdt.load_init(cfg.get_value('imgdir'))
      puts "画像を読み込み中 ... "
      r = ""
      begin
        r = cfg.imgdt.load_img
        # puts "load : #{r}"
      end until r == "loadok"
      
      puts "exoを出力中 ... "
      ExportExo.export_exo_file(outfn, cfg, lap)
      puts "output #{outfn}"
    else
      puts "image data load init failure."
    end
    
  when "ExoBlock"
    # ExoBlockの動作テスト
    scrw, scrh = 640, 360
    puts ExoBlock.get_exo_header(scrw, scrh, 24, 200)
    
    dirname = "sampledata\\image2\\"
    dt = [
          [0, 1, 15, "fix", "001.jpg", scrw, scrh],
          [1, 16, 29, "up", "002.jpg", scrw, scrh],
          [1, 16, 29, "down", "002.jpg", scrw, scrh],
          [1, 16, 29, "left", "002.jpg", scrw, scrh],
          [1, 16, 29, "right", "002.jpg", scrw, scrh],
          [1, 16, 29, "t.u", "002.jpg", scrw, scrh],
          [1, 16, 29, "t.b", "003.jpg", scrw, scrh],
          [1, 16, 29, "f.o", "003.jpg", scrw, scrh],
          [1, 16, 29, "f.i", "003.jpg", scrw, scrh],
          [1, 16, 29, "w.o", "003.jpg", scrw, scrh],
          [1, 16, 29, "w.i", "003.jpg", scrw, scrh],
         ]

    dt.each do |d|
      num, sfrm, efrm, mode, fn, sw, sh = d
      fn = dirname + fn
      exb = ExoBlock.new(num, sfrm, efrm, mode, fn, sw, sh)
      puts exb.get_text
    end
  end
  
end


