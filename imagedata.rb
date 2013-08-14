#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 16:54:26 +0900>
#
# �摜�Ǘ��p�N���X

require 'dxruby'

class ImageData
  def initialize
    @imgs = Array.new
    @imgfiles = Array.new
    @load_count = 0
    @imgdir = ""
  end

  attr_accessor :imgs, :load_count

  # �摜���������z��Q��Ԃ�
  def get_img_list
    return @imgs
  end

  # �摜�t�@�C������Ԃ�
  def get_img_num_max
    return @imgfiles.length
  end

  # �摜�t�@�C���ꗗ��Ԃ�
  def get_img_files
    return @imgfiles
  end

  # �ǂݍ��ݏI�����摜����Ԃ�
  def get_img_num
    return @load_count
  end
  
  # �摜�t�@�C���ǂݍ��ݏ����O�̃��[�N������
  #
  # ==== Args
  # _imgdir_ :: �摜�t�H���_�̃p�X
  #
  # ==== Return
  # _true_ :: �摜�͑��݂���B
  # _false_ :: �摜�͑��݂��Ȃ��B
  def load_init(imgdir)
    @imgdir = imgdir
    
    # ���ɉ摜���ǂݍ��ݍς݂������������Ă���
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

  # 1�t�@�C�����摜�ǂݍ���
  #
  # ==== Return
  # _'notfound'_ :: �摜�͑��݂��Ȃ��B
  # _'loadok'_ :: �S�摜��ǂݍ��ݏI����
  # _��L�ȊO_ :: �ǂݍ��񂾉摜�t�@�C���̃p�X
  def load_img
    return "notfound" if @imgfiles.length <= 0
    return "loadok" if @load_count >= @imgfiles.length

    fn = @imgfiles[@load_count]

    begin
      # �摜���[�h
      img = Image.load(fn)
    rescue
      # �摜���[�h�Ɏ��s����
      return "load failure.\n" + fn
    else
      # �摜���[�h�ɐ�������
      @imgs.push(img)
      @load_count += 1
    end
    return fn
  end
end
