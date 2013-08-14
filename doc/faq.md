Title: Anime PV Easy Maker ZERO の FAQ
CSS: style.css

Anime PV Easy Maker ZERO のFAQ
==============================

2013/08/04 0.01 初版

- - - -

{toc:..h2}

- - - - 

Q. どんな場面で使えるソフトなの？
---------------------------------

A.

    「カッコイイ曲できちゃった！」
    ↓
    「動画にしてアプしたい！」
    ↓
    「でも動画作るの ('A`)マンドクセ」

そんなとき、役に立つかもしれません。曲に合わせて、音ゲーノリでキーボードを叩くだけで、動画が作れます。


Q. ただのスライドショー作成ソフトに見えるけど、どこが違うの？
-------------------------------------------------------------

A. 画像が変わるタイミングを、「ノリ」「自分のリズム」で決めていける点が大きな違いです。

ざっくり言えば…

* スライドショー作成ソフトは、画像が主役で、曲は脇役。時間の精度は荒いが、几帳面。
* このソフトは、曲が主役で、画像が脇役。ノリ重視だけど、いいかげん。

そんな感じです。

### もう少し補足

フツーのスライドショー作成ソフトは、えてして以下のような制限があります。

* 一定時間でしか、画像切り替えができない。
* 切替タイミングを、秒単位でしか指定できない。
* タイムライン上でバーの長さや位置を変える等、音とは一切関係なく、目視だけで調整を要求される。

その点、このソフトは、感覚的に ―― 曲を聴きながら、「今だ！ このタイミングで、ポン、ポン、ポポポン」とリズムに乗ってタイミングの指定ができます。

逆に…

* 機械的に、きっちり正確に、寸分の狂いもなく、タイミングを指定していく。
* どのタイミングで、どの画像を表示するか指定する。

といったことは苦手です。…もっとも、そのあたりは、[AviUtl+拡張編集プラグイン][aviutl] と組み合わせて使うことで、ある程度解決できるでしょう。


Q. 画像がたくさん必要になるけど、どうやって用意したらいいの？
-------------------------------------------------------------

A1. ケータイやスマホで写真を撮りまくりましょう。例えば、「電信柱」「コンビニ看板」「信号機」「交通標識」を撮って使えば、たちまち某アニメ監督の作品っぽく(以下自粛)

A2. フリー写真素材サイトを利用させてもらうのも手です。

* [PAKUTASO/ぱくたそ-WEB制作向けの無料写真素材/商用可](http://www.pakutaso.com/)
* [写真素材 足成【フリーフォト、無料写真素材サイト】](http://www.ashinari.com/)
* [【商用利用も可】人物写真も豊富な無料（フリー）写真素材集のまとめ - NAVER まとめ](http://matome.naver.jp/odai/2130321456284869901)

全くの余談ですが、個人的には PAKUTASO さんで公開されてる
[大川竜弥](http://www.pakutaso.com/topics/model/ookawa/) さん、
[OZPA](http://www.pakutaso.com/topics/model/ozpa/) さんの写真推しです。
どんな使い方ができるかという点では、レベルの高さが尋常じゃないです。なんだかよくわからない挑戦状を叩きつけられている気がします。＜褒めてます。

A3. もちろん、絵が描ける人なら、自分で描くのが手っ取り早いです。大判で描いて、トリミングしたり、フィルタをかけたり、色を変えれば、1枚のイラストから画像を数枚作ることもできるはず。


Q. 画像は何枚まで読み込める？
-----------------------------

A. お使いのPCスペックによりますので…実際試してみて、動いたらOKということで。


Q. 画像サイズはどのくらいが適切？
---------------------------------

A. 画像サイズは、ウインドウサイズと同じか、もしくは、一回り大きいぐらいがバランスがとれていて良いのではないかと。例えば、ウインドウサイズが640x360なら、640x360～800x450ぐらいが良さそうです。

ちなみに、同梱のサンプル画像は、800x450の画像サイズで統一してあります。(初期ウインドウサイズは 640x360。)


Q. ウインドウサイズが小さすぎる。大きくしたい。
-----------------------------------------------

A. タイトル画面右下のボタンを押せば、設定画面に入れます。好きなサイズを選んで、プログラムを再起動してください。次回の起動から、選んだサイズで動作します。

ただし、大きいウインドウサイズは、PCスペックが高くないと動作が厳しいでしょう。


Q. できた動画のタイミングが微妙にずれてる気がする。
---------------------------------------------------

A. exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で読み込み・動画に変換しましょう。曲の開始タイミングをフレーム単位で調整すれば、大体は一致すると思います。


Q. 一部タイミングがずれちゃった。修正できないの？
-------------------------------------------------

A. いくつか方法があります。

* exoファイルを書き出して、AviUtl + 拡張編集プラグインで読み込み、ずれたところだけ調整する。
* 記録中に Deleteキーを押して、ずれてしまったところだけ記録を消去。また再生を繰り返し、記録を追加する。
* 記録ファイルをテキストエディタで開いて、「秒数＋フレーム数」の値を書き換えて調整する。
    * 「ログ閲覧/編集」ボタンを押せば、メモ帳で開いて修正できます。
    * 修正後、「ログ読み込み」で反映させられます。


Q. 連番画像の書き出しがとにかく遅い。我慢できない。
---------------------------------------------------

A. exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で読み込み・動画に変換しましょう。圧倒的に早く、しかも、動画ファイルを直接出力できますので、わざわざ連番画像を作らなくて済みます。


Q. 連番画像書き出し中、他のウインドウを重ねるなというのは厳しい。
-----------------------------------------------------------------

A. 設定で、「内部生成＋イメージ保存」に切り替えれば、他のウインドウを重ねても問題ない書き出し方法に変わります。

ただし、「内部生成＋イメージ保存」は、書き出し時間が数倍に増える上、時々謎の強制終了をしてしまうのでオススメできません。

書き出し時のアレコレに不満がある場合は、exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で動画にすることをオススメします。


Q. 静止画像だけではなく、動画ファイルも表示したい。
---------------------------------------------------

A. exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で読み込み・動画に変換しましょう。AviUtlなら、各カットに動画ファイルを指定することもできます。


Q. スクロールがガクガクしてる。もっと滑らかにならない？
-------------------------------------------------------

A. exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で読み込み・動画に変換しましょう。AviUtlなら1ドット未満のスクロールもできるので、滑らかな動きになります。

このソフトは、DXRubyという2Dゲーム制作用のライブラリを使っているので、描画は圧倒的に速いものの、ドット単位でしか位置を決められません。そのあたりの問題は AviUtl を利用して解決していただければと。


Q. 一部のアニメが AviUtl上で再現されない。
------------------------------------------

A. AviUtl上で再現するための指定が分かりませんでした。ゴメンナサイ。今後の課題です。


Q. アニメ種類が少ない。もっと増やせない？
-----------------------------------------

A. exoファイルを書き出して、[AviUtl+拡張編集プラグイン][aviutl] で読み込み・動画に変換しましょう。自由自在に画像を動かせますし、ぼかしや色調補正等のフィルタ処理も使えます。

あるいは、プログラムを改造して種類を増やしていただいても全然OKです。以下の3つのファイルを修正すれば、種類を追加できます。

* anime.rb
* animekind.csv
* exportexo.rb


Q. FFmpegがあれば連番画像から動画が作れるそうだけど、FFmpegってどこにあるの？
-----------------------------------------------------------------------------

A. 2013/08/03の時点では、以下のページで入手できるようです。

* [Zeranoe FFmpeg - Builds](http://ffmpeg.zeranoe.com/builds/)

ダウンロード後、解凍して、ffmpeg.exe を、img2avi.bat のあるフォルダにコピーすれば準備OKです。

後は、連番画像出力後に、img2avi.bat を実行して、「avi」か「mp4」と入力するだけで、動画が生成されます。


Q. プログラムを改造したいけど、何が必要？
-----------------------------------------

A. Ruby 1.9.x + DXRuby がインストールされた環境が必要です。

* [RubyInstaller for Windows](http://rubyinstaller.org/)
* [Project DXRuby](http://dxruby.sourceforge.jp/)
* [DXRuby プロジェクトWiki - ファイル置き場](http://dxruby.sourceforge.jp/cgi-bin/hiki.cgi?%A5%D5%A5%A1%A5%A4%A5%EB%C3%D6%A4%AD%BE%EC)


Q. 改造版を配布したいけど、どうやってexe化するの？
--------------------------------------------------

A. [Ocra](http://ocra.rubyforge.org/) を使えば、Rubyスクリプトをexe化できます。Ocra については、以下のページが参考になるでしょう。

* [Ruby入門: Ocraで実行ファイルを作成 梶山 喜一郎](http://monge.tec.fukuoka-u.ac.jp/Ruby19x/compile_Ocra_01.html)

Ocra がインストールされている環境なら、同梱の mkexe.bat で exe化ができます。


Q. プログラムの起動が遅い。
---------------------------

A. プログラムの展開に時間がかかっているのかもしれません。Ruby 1.9.x + DXRuby が導入されている環境なら、main.rb を実行してもOKです。展開処理がされない分、起動が早くなるかもしれません。


Q. 記録時のキー割り当てを変更したい。
-------------------------------------

A. animekind.csv を修正すれば、キーの割り当てを変更することができます。


  [aviutl]: http://spring-fragrance.mints.ne.jp/aviutl/ "AviUtl+拡張編集プラグイン"

