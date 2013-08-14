#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 20:25:04 +0900>
#
# �ݒ�t�@�C���֌W�̃N���X

require 'singleton'
require 'dxruby'
require 'win32ole'
require_relative 'ayame'
require_relative 'seq'
require_relative 'imagedata'
require_relative 'animekind'

# ----------------------------------------
#
# === �ݒ�t�@�C���Ǘ��p
#
# �O���[�o���ϐ�����
#
class Conf

  include Singleton

  VER_NUM = "0.0.1"
  APPLI_NAME = "Anime PV Easy Maker ZERO"
  APPLI_TITLE = APPLI_NAME + " " + VER_NUM
  APPLI_ICON = 'appli_icon.ico'

  # �ݒ�t�@�C����
  DEFAULT_INI = "_setting.txt"
  
  # �t�@�C����t�H���_�̏ꏊ�̏����l
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

  # ���l�Ƃ��Ĉ�������
  VALUE_KEY = ['screenwidth', 'screenheight', 'fps', 'seqimgoutmode', 'sshotsave']

  # �p�X�Ƃ��Ĉ�������
  PATH_KEY = ['soundfile', 'imgdir', 'savefile', 'outdir', 'definebat']
  
  # �T���v���t�@�C���̏ꏊ
  DEF_INI_NONE = {
    'sound' => 'sampledata/sample1.mp3',
    'image' => 'sampledata/image1',
  }

  # �ǂݍ��߂�T�E���h���(�t�@�C���I���_�C�A���O�g�p���ɗ��p)
  SNDEXT = [["ogg, wav, mp3", "*.ogg;*.wav;*.mp3"], ["all(*.*)", "*.*"]]

  # �ǂݍ��߂�摜���(�t�@�C���I���_�C�A���O�g�p���ɗ��p)
  IMGEXT = [["bmp, jpg, png", "*.bmp;*.jpg;*.png"], ["all(*.*)", "*.*"]]

  # �ǂݍ��߂�摜���(�t�@�C���I���_�C�A���O�g�p���ɗ��p)
  OUTDIREXT = [["all(*.*)", "*.*"]]

  # �A�ԉ摜�o�̓t�H�[�}�b�g�Bseqimgoutmode �ƑΉ�
  OutFmt = Struct.new("OutFmt", :ext, :fmt)
  OUT_FMT = [
             OutFmt.new('.bmp', FORMAT_BMP),
             OutFmt.new('.jpg', FORMAT_JPG),
             OutFmt.new('.png', FORMAT_PNG),
            ]

  BGCOL_DEF = [241, 196, 15] # �W���Ƃ��Ďg���w�i�F

  # ���p�ł���E�C���h�E�T�C�Y
  SCR_SIZE = [
              [512, 288],
              [512, 384],
              [640, 360],
              [640, 480],
              [800, 450],
              [800, 600],
              [1280, 720],
             ]

  # ���p�ł���FPS
  FPS_LIST = [ 24, 30 ]
  
  # ����������
  def initialize
    if (defined?(Ocra))
      # Ocra �ŃR���p�C�����Ȃ炱����ʂ�
      puts "Use Ocra"
    end
    fpath = ENV['OCRA_EXECUTABLE'] || $0 # Ocra�΍�
    
    @cdir = File.expand_path(File.dirname(fpath))
    @conf_fname = File.expand_path(@cdir + '/' + DEFAULT_INI)
    
    @key_tbl = AnimeKind.load_key_table(@cdir)
    @ini = Hash.new
    
    @bgcol_def = BGCOL_DEF
    @play_only_mode = false
    @outmode_enable = false
    @imgdt = ImageData.new
    @click_se_req = false
    
    @font10 = Font.new(10, '�l�r �S�V�b�N')
    @font12 = Font.new(12, '�l�r �S�V�b�N')

    @app = FolderSelect.get_app
    
    read_config
    conv_string_to_int
    check_file_exist
  end

  attr_accessor :ini, :bgcol_def, :imgdt, :click_se_req, :font10, :font12, :font_large, :font_large2, :app

  # �J�����g�t�H���_�̃p�X��Ԃ� (�Ō��'/'�͂��ĂȂ�)
  def get_current_dir
    return @cdir
  end
  
  # �ݒ�l��������
  def init_config_default
    DEF_INI.each_key do |key|
      v = DEF_INI[key]
      @ini[key] = (PATH_KEY.include?(key))? (@cdir + '/' + v) : v
    end
  end

  # ���l�����͂��̐ݒ�l�𐔒l�ɕϊ�
  def conv_string_to_int
    VALUE_KEY.each { |key| @ini[key] = @ini[key].to_i }
  end
  
  # �ݒ�t�@�C����ǂݍ���
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

  # �ݒ�t�@�C������������
  def write_config
    s = ""
    @ini.each_key { |key| s += sprintf("%s = %s\n", key, @ini[key].to_s) }
    f = File.open(@conf_fname, "w")
    f.write(s)
    f.close
  end

  # ���[�U���p�ӂ����t�@�C����������΃T���v���t�@�C���Q���g���悤�Ɏw��
  def check_file_exist
    unless check_sound_exist?(@ini['soundfile'])
      @ini['soundfile'] = @cdir + '/' + DEF_INI_NONE['sound']
    end
    
    unless check_images_exist?(@ini['imgdir'])
      @ini['imgdir'] = @cdir + '/' + DEF_INI_NONE['image']
    end
  end

  # �T�E���h�t�@�C�������݂��邩���ׂ�
  def check_sound_exist?(path)
    return File.exist?(path)
  end
  
  # �摜�t�@�C���Q�����݂��邩���ׂ�
  def check_images_exist?(imgdir)
    imgfiles = Dir.glob(imgdir + '/*.{jpg,png,bmp}').sort
    return (imgfiles.length == 0)? false : true
  end

  # �l��ύX
  def set_value(key, value)
    @ini[key] = value
  end

  # �l��ǂݎ��
  def get_value(key)
    return @ini[key]
  end

  # �A�ԉ摜�o�̓��[�h���ۂ���Ԃ�
  def outmode?
    return @outmode_enable
  end

  # �A�ԉ摜�o�̓��[�h�t���O�𖳌���
  def clear_outmode
    @outmode_enable = false
  end

  # �A�ԉ摜�o�̓��[�h�t���O��L����
  def set_outmode
    @outmode_enable = true
  end

  # �A�ԉ摜�o�͂̃C���f�b�N�X�l���擾
  def get_outmode_index
    return @ini['seqimgoutmode']
  end

  # �A�ԉ摜�o�͂̊g���q���擾
  def get_outmode_ext
    return OUT_FMT[@ini['seqimgoutmode']].ext
  end

  # �A�ԉ摜�o�͂̉摜�t�H�[�}�b�g���擾
  def get_outmode_format
    return OUT_FMT[@ini['seqimgoutmode']].fmt
  end

  # �A�ԉ摜�o�̓��[�h�l���C���N�������g
  def inc_outmode
    @ini['seqimgoutmode'] = (@ini['seqimgoutmode'] + 1) % OUT_FMT.length
    write_config
  end
  
  # �A�ԉ摜�o�̓��[�h�l���f�N�������g
  def dec_outmode
    nmax = OUT_FMT.length
    @ini['seqimgoutmode'] = (@ini['seqimgoutmode'] - 1 + nmax) % nmax
    write_config
  end
  
  # �Đ����[�h���ۂ���Ԃ�
  def playmode?
    return @play_only_mode
  end

  # �Đ����[�h�t���O�𖳌���
  def clear_playmode
    @play_only_mode = false
  end

  # �Đ����[�h�t���O��L����
  def set_playmode
    @play_only_mode = true
  end
  
  # fps�ݒ�l��Ԃ�
  def get_fps
    return @ini['fps']
  end
  
  # fps�l��ύX
  def set_fps(fpsv)
    @ini['fps'] = fpsv
    write_config
  end

  # ��ʃT�C�Y��Ԃ�
  def get_screen_size
    return @ini['screenwidth'].to_i, @ini['screenheight'].to_i
  end

  # ��ʃT�C�Y��ύX
  def set_screen_size(w, h)
    @ini['screenwidth'] = w
    @ini['screenheight'] = h
    write_config
  end
  
  # �󂯕t����L�[�{�[�h�̈ꗗ����Ԃ�
  def get_key_tbl
    return @key_tbl
  end

  # �A�ԉ摜�����o�����̏������@��ނ�Ԃ�
  #
  # true :: ��ʂɕ`��{�X�N���[���V���b�g�ۑ�
  # false :: ���������{�C���[�W�ۑ�
  def screenshot_save?
    return (@ini['sshotsave'] == 0)? false : true
  end

  # �A�ԉ摜�����o�����̏������@��؂�ւ���
  def change_screenshot_savemode
    @ini['sshotsave'] = (@ini['sshotsave'] == 0)? 1 : 0
  end
  
  # ���O�t�@�C��(�L�^�t�@�C��)�̃p�X��Ԃ�
  def get_log_path
    return @ini['savefile']
  end

  # ���O�t�@�C��(�L�^�t�@�C��)�̃p�X��ύX����
  def set_log_path(fpath)
    @ini['savefile'] = File.expand_path(fpath)
    write_config
  end

  # �摜���\�[�X�t�H���_�̃p�X��Ԃ� ('/'���Ō�ɂ�)
  def get_res_dir
    return get_current_dir + '/res/' # �S�t�@�C���͂��̃��\�[�X�p�X���g��
  end

  # �A�v���A�C�R���̃p�X��Ԃ�
  def get_appli_icon_path
    return get_res_dir + APPLI_ICON
  end
  
  # ffmpeg�p�̃o�b�`�t�@�C��(��`�����̂�)���o��
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

