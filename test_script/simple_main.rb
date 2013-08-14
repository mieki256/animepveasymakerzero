#!ruby -Ks
#
# DXRubyメインループの最もシンプルな例

require "dxruby"
# require "win32ole"

cdir = File.dirname(File.expand_path($0))
fn = File.expand_path("titlelogo.png", cdir + "/../res")
puts fn
img = Image.load(fn)
x, y = 0, 0

Window.loop do
  break if Input.keyPush?(K_ESCAPE)
  Window.draw(x, y, img)
  x += 1
  y += 1
end

