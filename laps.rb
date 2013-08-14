#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 08:40:48 +0900>
#
# キー押しタイミング記録用

require 'dxruby'

class Laps
  def initialize(cfg)
    @cfg = cfg
    @fpsv = @cfg.get_fps
    @laps_change = false
    @laps = Hash.new
    log_init
  end

  attr_accessor :laps

  # フレーム数を「00:00:00+00」形式の文字列にして返す
  def get_time_string(value)
    frm = value % @fpsv
    sec = value / @fpsv
    s0 = sec % 60
    s1 = (sec / 60) % 60
    s2 = (sec / (60*60)) % 60
    return sprintf("%02d:%02d:%02d+%02d", s2, s1, s0, frm)
  end

  # 時間を記録
  def save_lap(frame, mode)
    @laps[frame] = mode
    @laps_change = true
    # puts "laps change : #{frame}"
  end

  # 指定フレームで記録されてなければ時間を記録
  def save_lap_not_overwrite(frame, mode)
    unless @laps.has_key?(frame)
      save_lap(frame, mode)
      return true
    else
      return false
    end
  end

  # 記録が変更されたか否かを返す
  def laps_changed?
    return @laps_change
  end

  # 記録変更フラグをクリア
  def clear_changed
    @laps_change = false
  end

  # フレーム値だけを並べた配列を取得
  def get_frame_list
    return @laps.keys.sort
  end

  # 指定フレームで記録されたモード値があるか否かを返す
  def lap_exist?(frame)
    return @laps.has_key?(frame)
  end
  
  # 指定フレームで記録されたモード値を取得
  def get_mode(frame)
    return @laps[frame]
  end

  # 指定フレームの記録を消去
  def delete_lap(frame)
    @laps.delete(frame)
    @laps_change = true
  end
  
  # 内部記録を初期化
  def log_init
    @laps = Hash.new()
    @laps[0] = "fix"
  end

  # ログファイルが存在してるかどうかを返す
  def log_exist?
    return File.exist?(@cfg.get_log_path)
  end
  
  # ログファイル読み込み
  def get_log
    ofn = @cfg.get_log_path
    lst = Hash.new
    if File.exist?(ofn)
      file = open(ofn)
      while l = file.gets do
        # 「00:00:00+00,表示種類,画像番号」をフレーム数に変換
        l.chomp!
        v = l.split(/[:,+]/)
        frm = ((v[0].to_i * 60 * 60) + (v[1].to_i * 60) + (v[2].to_i)) * @fpsv
        frm += v[3].to_i
        lst[frm] = v[4]
      end
      file.close
      
      lst[0] = "fix" unless lst.has_key?(0)
      @laps = lst
      clear_changed
      return true
    else
      return false
    end
  end

  # ログファイル書き出し
  def out_log
    ofn = @cfg.get_log_path
    lst = @laps.keys.sort
    fo = File.open(ofn, "w")
    lst.each_with_index do |e, i|
      str = sprintf("%s,%s,,# imgnum=%d", get_time_string(e), @laps[e], i+1)
      fo.puts(str)
    end
    fo.close
    clear_changed
    return true
  end

  # ログファイル消去
  def delete_log
    ofn = @cfg.get_log_path
    if File.exist?(ofn)
      begin
        File.delete(ofn)
      rescue
        return false
      else
        return true
      end
    else
      return true
    end
  end
  
end
