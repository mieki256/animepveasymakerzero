#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 11:46:01 +0900>
#
# �A�j����ޒ�`�p�N���X

require 'dxruby'
require 'csv'
require 'pp'

class AnimeKind
  # �󂯕t����Q�[���p�b�h�{�^���̈ꗗ
  PAD_LIST = {
    P_BUTTON0 => "fix",
    P_BUTTON1 => "fadeout",
    P_BUTTON2 => "zoomup",
  }

  # �L�[������Ɠ��̓L�[�R�[�h�̑Ή�
  KEY_SYM_LIST = {
    'a' => K_A,
    'b' => K_B,
    'c' => K_C,
    'd' => K_D,
    'e' => K_E,
    'f' => K_F,
    'g' => K_G,
    'h' => K_H,
    'i' => K_I,
    'j' => K_J,
    'k' => K_K,
    'l' => K_L,
    'm' => K_M,
    'n' => K_N,
    'o' => K_O,
    'p' => K_P,
    'q' => K_Q,
    'r' => K_R,
    's' => K_S,
    't' => K_T,
    'u' => K_U,
    'v' => K_V,
    'w' => K_W,
    'x' => K_X,
    'y' => K_Y,
    'z' => K_Z,
    'up' => K_UP,
    'down' => K_DOWN,
    'left' => K_LEFT,
    'right' => K_RIGHT,
    'bs' => K_BACKSPACE,
    'del' => K_DELETE,
  }

  KeyTbl = Struct.new("KeyTbl", :key, :keycode, :mode, :about, :col)

  # �󂯕t����L�[�ꗗ�������ꂽcsv�t�@�C����ǂݍ���Ńe�[�u���𐶐�
  def AnimeKind.load_key_table(curdir)
    tbl = Array.new
    fpath = curdir + '/animekind.csv'
    reader = CSV.open(fpath, "r")
    header = reader.take(1)[0]
    reader.each do |row|
      key, mode, about, r, g, b = row
      col = [255, r.to_i, g.to_i, b.to_i]
      if key != nil
        keycode = (KEY_SYM_LIST.has_key?(key))? KEY_SYM_LIST[key] : nil
        tbl.push(KeyTbl.new(key, keycode, mode, about, col))
      else
        tbl.push(KeyTbl.new("", nil, mode, about, col))
      end
    end

    if false
      tbl.each { |t| p t }
      exit
    end
    
    return tbl
  end
  
  # ���͂��󂯕t����L�[�����̈ꗗ��z��Ƃ��Ď擾
  def AnimeKind.get_enable_key_list(tbl)
    keys = Array.new
    tbl.each do |t|
      keys.push(t.key) if t.key != ""
    end
    keys.push('bs')
    keys.push('del')
    return keys
  end

  # �e�L�[�̐��������������n�b�V�����擾
  def AnimeKind.get_key_about_dic(tbl)
    about_dic = Hash.new
    tbl.each do |t|
      about_dic[t.key] = t.about if t.key != ""
    end
    about_dic['bs'] = "RETRY"
    about_dic['del'] = "LOG DEL"
    return about_dic
  end

  # �e�L�[�̃A�j����ޑΉ��n�b�V�����擾
  # [ {'z' => 'zoomup'}, {'f' => 'fadeout'} ] �̌`
  def AnimeKind.get_key_mode_dic(tbl)
    modes = Hash.new
    tbl.each do |t|
      modes[t.key] = t.mode if t.key != ""
    end
    modes['bs'] = nil
    modes['del'] = nil
    return modes
  end

  # ���̓L�[�R�[�h�ꗗ���n�b�V���Ƃ��Ď擾
  # [{K_P => 'p'}, {K_B => 'b'} ] �̌`
  def AnimeKind.get_keycodes(tbl)
    keycodes = Hash.new
    tbl.each do |t|
      keycodes[t.keycode] = t.key if t.keycode != nil
    end
    return keycodes
  end
  
end

# ����e�X�g�p
if $0 == __FILE__
  curdir = File.expand_path(File.dirname(__FILE__))
  tbl = AnimeKind.load_key_table(curdir)
  # pp AnimeKind.get_enable_key_list(tbl)
  # pp AnimeKind.get_key_about_dic(tbl)
  pp AnimeKind.get_key_mode_dic(tbl)
end

