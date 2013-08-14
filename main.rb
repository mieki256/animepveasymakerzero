#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/04 02:57:55 +0900>
#
# AnimePvEasyMaker
# �Ȃƃ^�C�~���O�����킹��PV�ȈՍ쐬�c�[��
#
# Ayame ���g���Ă��邽�߁ARuby 1.9.x ���K�v�B
#
# 0.0.1  2013/08/02  �Ƃ肠����������������
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

# �X�e�b�v��`
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

# �{�^�����
CBTN = BornButton::CBTN
BBTN = BornButton::BBTN
STIL = BornButton::STIL

# �^�C�g����ʗp�{�^���\���e�[�u��
TITLE_BTN_LIST = [
                  # ButtonKind, kind, keycode, imagefile, strnum, x, y
                  [STIL, -1, nil, 'titlelogo.png', '', 0.5, 0.166],
                  [BBTN, 0, K_C, 'start_btn2.png', '', 0.5, 0.6],
                  [BBTN, 1, K_Z, 'config_btn.png', '', 1.0, 1.0],
                 ]

# ����������ʗp�{�^���\���e�[�u��
HOWTOUSE_BTN_LIST = [
                     [STIL, -1, nil, 'what_logo.png', '', 0.5, 0.0],
                     [STIL, -1, nil, 'what_text.png', '', 0.5, 0.20],
                     [STIL, -1, nil, 'what_illust.png', '', 0.5, 0.444],
                     [STIL, -1, nil, 'what_info.png', '', 0.0, 1.0],
                     [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
                     [BBTN, 1, K_C, 'what_next_btn.png', '', 1.0, 1.0],
                    ]

# �L�^�J�n���O�̑����ʐ����\���p�e�[�u��
HOWTOUSE2_BTN_LIST = [
                      [STIL, -1, nil, 'howtouse_3.png', '', 0.5, 0.5],
                      [CBTN, 0, K_BACKSPACE, 'arrow_left.png', '', 0.0, 0.0],
                     ]

def main_job
  fnt = Font.new(12, '�l�r �S�V�b�N')

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
      # ����������
      Window.drawFont(8, 8, "�������� ... ", fnt , :color => [0,0,0])
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
        
        # �e�V�[���̏������s���C���X�^���X���m��
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
    
    break if Input.keyPush?(K_ESCAPE) # ESC�L�[�ŏI��

    unless err == ""
      # �G���[���b�Z�[�W�\��
      Window.bgcolor = [0,0,0]
      err.split(/\n/).each_with_index do |s, i|
        Window.drawFont(16, 16 + i * 16, s, fnt, :color => [255,255,255])
      end
      next
    end
    
    case step
    when STEP_TITLE..STEP_CFG
      # �e��I�����
      
      mnotes.draw # �w�i�̉�����`��

      ret = -1
      scene.each_with_index do |sc,i|
        fg = (sc.step_kind == step)? true : false
        r = sc.update(fg)
        ret = r if fg
      end
      
      case step
      when STEP_TITLE
        # �^�C�g�����
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �g����������ʂֈڍs
          step = STEP_ABOUT
          scene[STEP_TITLE].frameout_up
          scene[STEP_ABOUT].framein
        when 1
          # �ݒ��ʂֈڍs
          step = STEP_CFG
          scene[STEP_TITLE].frameout_left
          scene[STEP_CFG].framein
        end
        
        str = Window.real_fps.to_s + " FPS / Ruby " + RUBY_VERSION
        Window.drawFont(16, scrh - 14, str, cfg.font12, :color => [0,0,0])

      when STEP_ABOUT
        # �g�����������
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �^�C�g����ʂֈڍs
          step = STEP_TITLE
          scene[STEP_TITLE].framein
          scene[STEP_ABOUT].frameout_down
        when 1
          # �ȑI����ʂֈڍs
          step = STEP_BGMSEL
          scene[STEP_ABOUT].frameout_up
          scene[STEP_BGMSEL].framein
        end

      when STEP_BGMSEL
        # �ȑI�����
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �摜�I����ʂֈڍs
          step = STEP_IMGSEL
          scene[STEP_BGMSEL].frameout_up
          scene[STEP_IMGSEL].framein
          unless rec.load_bgm
            path = cfg.get_value('soundfile')
            err = "Error : Can't load BGM.\n #{path}"
          end
          
        when 1
          # �g����������ʂֈڍs
          step = STEP_ABOUT
          scene[STEP_ABOUT].framein
          scene[STEP_BGMSEL].frameout_down
        end
        
      when STEP_IMGSEL
        # ���͉摜�t�H���_�I�����
        case ret
        when -1
          # �������Ȃ�
        when 0
          # ���j���[��ʂֈڍs
          step = STEP_MENU
          scene[STEP_IMGSEL].frameout_up
          scene[STEP_MENU].framein
        when 1
          # �ȑI����ʂֈڍs
          step = STEP_BGMSEL
          scene[STEP_BGMSEL].framein
          scene[STEP_IMGSEL].frameout_down
        end
        
      when STEP_MENU
        # ���j���[���
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �L�^�J�n��ʂֈڍs
          step = STEP_RECTITLE
          cfg.clear_playmode
          cfg.clear_outmode
          scene[STEP_MENU].frameout_up
          scene[STEP_RECTITLE].framein
          lap.get_log
        when 1
          # �Đ����[�h�ֈڍs
          step = STEP_PLAYMODE
          cfg.set_playmode
          cfg.clear_outmode
          lap.get_log
          rec.init_work
        when 2
          # �A�ԉ摜�o�̓��[�h�ֈڍs
          step = STEP_EXPORTTITLE
          cfg.clear_playmode
          cfg.set_outmode
          scene[STEP_MENU].frameout_up
          scene[STEP_EXPORTTITLE].framein
          lap.get_log
        when 3
          # �ݒ��ʂֈڍs
          step = STEP_CFG
          scene[STEP_MENU].frameout_left
          scene[STEP_CFG].framein
          scene[STEP_CFG].chg_value = false
        when 4
          # �摜�I����ʂ֖߂�
          step = STEP_IMGSEL
          scene[STEP_IMGSEL].framein
          scene[STEP_MENU].frameout_down
        end
        
      when STEP_RECTITLE
        # �L�^�J�n���
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �L�^��ʂ֐i��
          step = STEP_RECMODE
          rec.init_work
        when 1
          # ���j���[��ʂ֖߂�
          step = STEP_MENU
          scene[STEP_MENU].framein
          scene[STEP_RECTITLE].frameout_down
        when 2
          # ���������ʂ֐i��
          step = STEP_RECTHELP
          scene[STEP_RECTITLE].frameout_up
          scene[STEP_RECTHELP].framein
        end

      when STEP_RECTHELP
        # �L�^�J�n���O�̑���������
        if ret == 0
          # �L�^�J�n��ʂ֖߂�
          step = STEP_RECTITLE
          scene[STEP_RECTITLE].framein
          scene[STEP_RECTHELP].frameout_down
        end
        
      when STEP_EXPORTTITLE
        # �A�ԉ摜�o�̓��[�h�J�n���
        case ret
        when -1
          # �������Ȃ�
        when 0
          # �o�̓��[�h�ֈڍs
          cfg.clear_playmode
          cfg.set_outmode
          step = STEP_EXPORTMODE
          rec.init_work
        when 1
          # ���j���[��ʂֈڍs
          step = STEP_MENU
          cfg.clear_playmode
          cfg.clear_outmode
          scene[STEP_MENU].framein
          scene[STEP_EXPORTTITLE].frameout_down
        end

      when STEP_CFG
        # �ݒ���
        if ret == 0
          # �^�C�g����ʂֈڍs
          step = STEP_TITLE
          scene[STEP_TITLE].framein
          scene[STEP_CFG].frameout_right
        end
      end

      # �e�V�[���̕`��
      scene.each { |sc| sc.draw }
      
    when STEP_RECMODE
      # �L�^���
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_RECTITLE
      end
      
    when STEP_PLAYMODE
      # �Đ����[�h
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_MENU
        cfg.clear_playmode
        cfg.clear_outmode
      end
      
    when STEP_EXPORTMODE
      # �A�ԉ摜�o�̓��[�h
      if rec.update_and_draw >= 0
        Window.bgcolor = cfg.bgcol_def
        step = STEP_EXPORTTITLE
        cfg.clear_playmode
        cfg.clear_outmode
      end
    end
    
    # SE�Đ�����
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
