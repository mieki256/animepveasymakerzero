#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 16:54:26 +0900>
#
# 画像管理用クラス

require 'dxruby'

class ImageData
  def initialize
    @imgs = Array.new
    @imgfiles = Array.new
    @load_count = 0
    @imgdir = ""
  end

  attr_accessor :imgs, :load_count

  # 画像が入った配列群を返す
  def get_img_list
    return @imgs
  end

  # 画像ファイル数を返す
  def get_img_num_max
    return @imgfiles.length
  end

  # 画像ファイル一覧を返す
  def get_img_files
    return @imgfiles
  end

  # 読み込み終えた画像数を返す
  def get_img_num
    return @load_count
  end
  
  # 画像ファイル読み込み処理前のワーク初期化
  #
  # ==== Args
  # _imgdir_ :: 画像フォルダのパス
  #
  # ==== Return
  # _true_ :: 画像は存在する。
  # _false_ :: 画像は存在しない。
  def load_init(imgdir)
    @imgdir = imgdir
    
    # 既に画像が読み込み済みだったら解放しておく
    unless @imgs.empty?
      @imgs.each do |img|
        img.dispose
        puts "failure image dispose." unless img.disposed?
      end
    end
    
    @imgs = Array.new

    @load_count = 0
    @imgfiles = Dir.glob(@imgdir + '/*.{jpg,png,bmp}').sort
    return (@imgfiles.length <= 0)? false : true
  end

  # 1ファイル分画像読み込み
  #
  # ==== Return
  # _'notfound'_ :: 画像は存在しない。
  # _'loadok'_ :: 全画像を読み込み終えた
  # _上記以外_ :: 読み込んだ画像ファイルのパス
  def load_img
    return "notfound" if @imgfiles.length <= 0
    return "loadok" if @load_count >= @imgfiles.length

    fn = @imgfiles[@load_count]

    begin
      # 画像ロード
      img = Image.load(fn)
    rescue
      # 画像ロードに失敗した
      return "load failure.\n" + fn
    else
      # 画像ロードに成功した
      @imgs.push(img)
      @load_count += 1
    end
    return fn
  end
end
