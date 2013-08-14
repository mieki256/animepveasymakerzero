#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/05 14:41:15 +0900>
#
# �t�H���_�I���_�C�A���O���J��

require 'rubygems'
require 'dxruby'
require 'win32ole'
require 'win32/clipboard'
include Win32

# ----------------------------------------
#
# �C�ӂ̃t�H���_��I��
#
class FolderSelect
  # �����g���ăt�H���_�I���_�C�A���O���J����
  USE_WIN32OLE = true # WIN32OLE���g��
  USE_WSH = false # WSH���g��

  def FolderSelect.get_app
    if USE_WIN32OLE
      return WIN32OLE.new('Shell.Application')
    end
    return nil
  end
  
  def FolderSelect.get_dirpath(kind, cdir, app)
    title = ""
    extlist = nil
    case kind
    when 0
      extlist = Conf::IMGEXT
      if USE_WIN32OLE
        # WIN32OLE���g���ăt�H���_�I���_�C�A���O���J���ꍇ
        title = "�摜�t�H���_��I�����Ă�������"
      elsif USE_WSH
        # WSH���g���ăt�H���_�I���_�C�A���O���J���ꍇ
        title = "�摜�t�H���_��I�����Ă�������"
      else
        # DXRuby�̃t�@�C���I���_�C�A���O���g���ꍇ
        title = "�摜�t�@�C�����ǂꂩ1�I��ł�������"
      end
    when 1
      extlist = Conf::OUTDIREXT
      if USE_WIN32OLE
        title = "�o�̓t�H���_��I��"
      elsif USE_WSH
        title = "�o�̓t�H���_��I��"
      else
        title = "�o�̓t�H���_���̃t�@�C�����ǂꂩ1�I��ł�������"
      end
    end
    
    if USE_WIN32OLE
      # WIN32OLE���g���ăt�H���_�I���_�C�A���O���J���ꍇ
      path = app.BrowseForFolder(0, title, 0)
      dpath = nil
      if path
        # ����ȃt�H���_���w�肳�ꂽ�ꍇ�͗�O���������Ă��܂��̂ŁA
        # ���̍ۂ̓L�����Z���{�^���������ꂽ���̂Ƃ��Ĉ���
        begin
          dir_path = path.Items.Item.path
          return dir_path
        rescue
          dpath = nil
        end
      else
        dpath = nil
      end
      return dpath
    elsif USE_WSH
      # WSH�ŊJ���ꍇ
      wsh_fname = File.join(cdir, "select_open_folder.vbs")
      system("wscript.exe \"#{wsh_fname}\" \"#{title}\"") # WSH�Ăяo��

      # �N���b�v�{�[�h�Ƀt�H���_�p�X�������Ă���͂�
      dir_path = Clipboard.data
      dir_path.chomp! # �Ԃ��Ă���������ɂ͉��s���܂܂�Ă���̂ŏ���
      dir_path = "" if dir_path =~ /^::/ # ����t�H���_��I�����ꂽ�ۂ̑΍�
      return (dir_path == "")? nil : dir_path
    else
      # DXRuby�̃t�@�C���I���_�C�A���O�łǂ��ɂ���p����ꍇ
      path = Window.openFilename(extlist, title)
      if path
        dir_path = File.dirname(File.expand_path(path))
        return dir_path
      end
      return nil
    end
  end
end


