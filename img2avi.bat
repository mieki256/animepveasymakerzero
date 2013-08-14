@echo off
call img2avi_def.bat

echo FFmpegを使用して、avi(MJPEG)、または、mp4(libx264)を生成します。
set /p INP="出力形式の選択： avi または mp4 のどちらかを入力してください >"

if "%INP%"=="mp4" goto MP4_OUT
if "%INP%"=="avi" goto AVI_OUT

echo avi , mp4 のどちらを入力されたか分かりませんでした。
echo 処理を中断します。
goto END

:AVI_OUT
echo avi を出力します
@echo on
ffmpeg -y -r %FPSV% -i %INIMAGE% -i %INMUSIC% -vcodec mjpeg -qscale 0 %OUTAVI%
@echo off
echo.
echo ----------------------------------------
echo.
echo %OUTAVI% を出力しました
echo.
goto END

:MP4_OUT
echo mp4 を出力します
@echo on
@rem mp3 や ogg を wav として書き出す。
ffmpeg -y -i %INMUSIC% %TMPWAV%

@rem 2パスでエンコード
@rem ffmpeg -y -r %FPSV% -i %INIMAGE% -i %TMPWAV% -vcodec libx264 -b 500k -acodec libvo_aacenc -ar 44100 -ab 128k %OUTMP4%
ffmpeg -y -r %FPSV% -i %INIMAGE% -vcodec libx264 -b 500k -pass 1 -passlogfile %PASSLOG% -an %OUTMP4%
ffmpeg -y -r %FPSV% -i %INIMAGE% -i %TMPWAV% -vcodec libx264 -b 500k -acodec libvo_aacenc -ar 44100 -ab 128k -pass 2 -passlogfile %PASSLOG% %OUTMP4%
@echo off
echo.
echo ----------------------------------------
echo.
echo %OUTMP4% を出力しました
echo.

:END
@pause
