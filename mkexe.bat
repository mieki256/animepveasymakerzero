@echo Ocraを使ってexeファイルを作成します。
@pause
@rem ocra --icon res\appli_icon.ico --output anipvmaker.exe --windows main.rb
@rem ocra --icon res\appli_icon.ico --output anipvmaker.exe main.rb
ocra --icon res\appli_icon.ico --output anipvmaker.exe --windows main.rb
