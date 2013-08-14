#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/07/31 10:55:42 +0900>
#
# 5x5 �r�b�g�}�b�v�t�H���g�𐶐�����X�N���v�g
#
# 2006-08-14 - ���G�L
# http://d.hatena.ne.jp/shinichiro_h/20060814#1155567183
# �Ō��J����Ă���f�[�^���g���āApng�摜�t�@�C���Ƃ��ďo�͂���B
#
# * Ruby + DXRuby ���K�v
# * �\������S�L�[�������ƕۑ������B
# * ESC�ŏI��
# * 5x5�h�b�g�ŕ��ׂ�Ƌl�܂�߂���̂ŁA
#   1�h�b�g�Ԋu��������6x6�h�b�g�̃t�H���g�ɂ��Ă���B

require 'dxruby'

class BitmapFont5x5
  # 0x20-0x7f�܂ł̃f�[�^
  FONT_DATA = [
               0x00000000, 0x00401084, 0x0000014a, 0x00afabea, 0x01fa7cbf, 0x01111111,
               0x0126c8a2, 0x00000084, 0x00821088, 0x00221082, 0x015711d5, 0x00427c84,
               0x00220000, 0x00007c00, 0x00400000, 0x00111110, 0x00e9d72e, 0x00421084,
               0x01f2222e, 0x00e8b22e, 0x008fa54c, 0x01f87c3f, 0x00e8bc2e, 0x0042221f,
               0x00e8ba2e, 0x00e87a2e, 0x00020080, 0x00220080, 0x00820888, 0x000f83e0,
               0x00222082, 0x0042222e, 0x00ead72e, 0x011fc544, 0x00f8be2f, 0x00e8862e,
               0x00f8c62f, 0x01f0fc3f, 0x0010bc3f, 0x00e8e42e, 0x0118fe31, 0x00e2108e,
               0x00e8c210, 0x01149d31, 0x01f08421, 0x0118d771, 0x011cd671, 0x00e8c62e,
               0x0010be2f, 0x01ecc62e, 0x0114be2f, 0x00f8383e, 0x0042109f, 0x00e8c631,
               0x00454631, 0x00aad6b5, 0x01151151, 0x00421151, 0x01f1111f, 0x00e1084e,
               0x01041041, 0x00e4210e, 0x00000144, 0x01f00000, 0x00000082, 0x0164a4c0,
               0x00749c20, 0x00e085c0, 0x00e4b908, 0x0060bd26, 0x0042388c, 0x00c8724c,
               0x00a51842, 0x00420080, 0x00621004, 0x00a32842, 0x00421086, 0x015ab800,
               0x00949800, 0x0064a4c0, 0x0013a4c0, 0x008724c0, 0x00108da0, 0x0064104c,
               0x00c23880, 0x0164a520, 0x00452800, 0x00aad400, 0x00a22800, 0x00111140,
               0x00e221c0, 0x00c2088c, 0x00421084, 0x00622086, 0x000022a2
              ]

  # �t�H���g�摜�𐶐�
  def BitmapFont5x5.get_font_image
    w, h = 5, 5 # �����̏c����
    dw, dh = 1, 1 # �e�����̊Ԋu
    sw = (w + dw) * 16
    sh = (h + dh) * 16
    img = Image.new(sw, sh, [255, 0, 0, 0])
    code = 0x20
    FONT_DATA.each do |dt|
      x = (code % 16) * (w + dw)
      y = (code / 16) * (h + dh)
      d = dt
      h.times do |i|
        w.times do |j|
          xx = x + j
          yy = y + i
          img[xx, yy] = ((d & 1) == 1)? [255, 255, 255] : [0, 0, 0]
          d >>= 1
        end
      end
      code += 1
    end
    return img
  end
end

# ����e�X�g�p
if $0 == __FILE__
  fname = '5x5_ascii.png'
  img = BitmapFont5x5.get_font_image

  font = Font.new(12)
  mes = "S�L�[�������� png �ŕۑ����܂�"
  Window.resize(640, 480)
  Window.bgcolor = [0, 0, 255]
  Window.loop do
    break if Input.keyPush?(K_ESCAPE)
    if Input.keyPush?(K_S)
      img.save( fname, FORMAT_PNG )
      mes = "#{fname} ��ۑ����܂���"
    end
    Window.draw(0, 0, img)
    Window.drawFont(16, 400, mes, font)
  end
end
