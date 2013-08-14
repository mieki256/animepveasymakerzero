#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/05 14:41:15 +0900>
#
# フォルダ選択ダイアログを開く

require 'rubygems'
require 'dxruby'
require 'win32ole'
require 'win32/clipboard'
include Win32

# ----------------------------------------
#
# 任意のフォルダを選択
#
class FolderSelect
  # 何を使ってフォルダ選択ダイアログを開くか
  USE_WIN32OLE = true # WIN32OLEを使う
  USE_WSH = false # WSHを使う

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
        # WIN32OLEを使ってフォルダ選択ダイアログを開く場合
        title = "画像フォルダを選択してください"
      elsif USE_WSH
        # WSHを使ってフォルダ選択ダイアログを開く場合
        title = "画像フォルダを選択してください"
      else
        # DXRubyのファイル選択ダイアログを使う場合
        title = "画像ファイルをどれか1つ選んでください"
      end
    when 1
      extlist = Conf::OUTDIREXT
      if USE_WIN32OLE
        title = "出力フォルダを選択"
      elsif USE_WSH
        title = "出力フォルダを選択"
      else
        title = "出力フォルダ内のファイルをどれか1つ選んでください"
      end
    end
    
    if USE_WIN32OLE
      # WIN32OLEを使ってフォルダ選択ダイアログを開く場合
      path = app.BrowseForFolder(0, title, 0)
      dpath = nil
      if path
        # 特殊なフォルダを指定された場合は例外が発生してしまうので、
        # その際はキャンセルボタンを押されたものとして扱う
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
      # WSHで開く場合
      wsh_fname = File.join(cdir, "select_open_folder.vbs")
      system("wscript.exe \"#{wsh_fname}\" \"#{title}\"") # WSH呼び出し

      # クリップボードにフォルダパスが入っているはず
      dir_path = Clipboard.data
      dir_path.chomp! # 返ってきた文字列には改行も含まれているので除去
      dir_path = "" if dir_path =~ /^::/ # 特殊フォルダを選択された際の対策
      return (dir_path == "")? nil : dir_path
    else
      # DXRubyのファイル選択ダイアログでどうにか代用する場合
      path = Window.openFilename(extlist, title)
      if path
        dir_path = File.dirname(File.expand_path(path))
        return dir_path
      end
      return nil
    end
  end
end


