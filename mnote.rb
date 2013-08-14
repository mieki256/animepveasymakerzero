#!ruby
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 20:13:49 +0900>
#
# 音符オブジェクト用クラス

require 'dxruby'

class MusicNotes
  
  class MNote
    def initialize(sw, sh, y, img)
      @sw = sw
      @sh = sh
      @x = sw * rand()
      d = (y - 16.0) / (sh - 32.0)
      @by = y
      @yh = 3 + (20 * d)
      @dx = -2 - (5 * d)
      @img =img
      @ang = rand(360)
      @scale = 0.5 + (0.5 * d)
      @alpha = 64 + (192 * d)
    end

    def draw
      y = @by + @yh * Math.cos(@ang * Math::PI / 180.0)
      Window.drawEx(@x.to_i, y, @img,
                    :scalex => @scale,
                    :scaley => @scale,
                    :alpha => @alpha)
      @x += @dx
      if @x + @img.width < 0
        @x += @sw + @img.width
      end
      @ang = (@ang + 5) % 360
    end
  end

  def initialize(cfg)
    @scrw, @scrh = cfg.get_screen_size
    noteimg = Image.loadToArray(cfg.get_res_dir + 'mnote.png', 7, 1)
    @mnotes = []
    mnotesnum = 48
    lst = [0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 5, 6]
    mnotesnum.times do |i|
      y = 16 + (i * (@scrw - 32) / mnotesnum)
      rnum = lst[rand(lst.length).to_i]
      note = MNote.new(@scrw, @scrh, y, noteimg[rnum])
      @mnotes.push(note)
    end
  end

  def draw
    @mnotes.each {|spr| spr.draw}
  end

end


