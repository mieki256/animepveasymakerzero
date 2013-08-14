#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 08:40:48 +0900>
#
# �L�[�����^�C�~���O�L�^�p

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

  # �t���[�������u00:00:00+00�v�`���̕�����ɂ��ĕԂ�
  def get_time_string(value)
    frm = value % @fpsv
    sec = value / @fpsv
    s0 = sec % 60
    s1 = (sec / 60) % 60
    s2 = (sec / (60*60)) % 60
    return sprintf("%02d:%02d:%02d+%02d", s2, s1, s0, frm)
  end

  # ���Ԃ��L�^
  def save_lap(frame, mode)
    @laps[frame] = mode
    @laps_change = true
    # puts "laps change : #{frame}"
  end

  # �w��t���[���ŋL�^����ĂȂ���Ύ��Ԃ��L�^
  def save_lap_not_overwrite(frame, mode)
    unless @laps.has_key?(frame)
      save_lap(frame, mode)
      return true
    else
      return false
    end
  end

  # �L�^���ύX���ꂽ���ۂ���Ԃ�
  def laps_changed?
    return @laps_change
  end

  # �L�^�ύX�t���O���N���A
  def clear_changed
    @laps_change = false
  end

  # �t���[���l��������ׂ��z����擾
  def get_frame_list
    return @laps.keys.sort
  end

  # �w��t���[���ŋL�^���ꂽ���[�h�l�����邩�ۂ���Ԃ�
  def lap_exist?(frame)
    return @laps.has_key?(frame)
  end
  
  # �w��t���[���ŋL�^���ꂽ���[�h�l���擾
  def get_mode(frame)
    return @laps[frame]
  end

  # �w��t���[���̋L�^������
  def delete_lap(frame)
    @laps.delete(frame)
    @laps_change = true
  end
  
  # �����L�^��������
  def log_init
    @laps = Hash.new()
    @laps[0] = "fix"
  end

  # ���O�t�@�C�������݂��Ă邩�ǂ�����Ԃ�
  def log_exist?
    return File.exist?(@cfg.get_log_path)
  end
  
  # ���O�t�@�C���ǂݍ���
  def get_log
    ofn = @cfg.get_log_path
    lst = Hash.new
    if File.exist?(ofn)
      file = open(ofn)
      while l = file.gets do
        # �u00:00:00+00,�\�����,�摜�ԍ��v���t���[�����ɕϊ�
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

  # ���O�t�@�C�������o��
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

  # ���O�t�@�C������
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
