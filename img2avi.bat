@echo off
call img2avi_def.bat

echo FFmpeg���g�p���āAavi(MJPEG)�A�܂��́Amp4(libx264)�𐶐����܂��B
set /p INP="�o�͌`���̑I���F avi �܂��� mp4 �̂ǂ��炩����͂��Ă������� >"

if "%INP%"=="mp4" goto MP4_OUT
if "%INP%"=="avi" goto AVI_OUT

echo avi , mp4 �̂ǂ������͂��ꂽ��������܂���ł����B
echo �����𒆒f���܂��B
goto END

:AVI_OUT
echo avi ���o�͂��܂�
@echo on
ffmpeg -y -r %FPSV% -i %INIMAGE% -i %INMUSIC% -vcodec mjpeg -qscale 0 %OUTAVI%
@echo off
echo.
echo ----------------------------------------
echo.
echo %OUTAVI% ���o�͂��܂���
echo.
goto END

:MP4_OUT
echo mp4 ���o�͂��܂�
@echo on
@rem mp3 �� ogg �� wav �Ƃ��ď����o���B
ffmpeg -y -i %INMUSIC% %TMPWAV%

@rem 2�p�X�ŃG���R�[�h
@rem ffmpeg -y -r %FPSV% -i %INIMAGE% -i %TMPWAV% -vcodec libx264 -b 500k -acodec libvo_aacenc -ar 44100 -ab 128k %OUTMP4%
ffmpeg -y -r %FPSV% -i %INIMAGE% -vcodec libx264 -b 500k -pass 1 -passlogfile %PASSLOG% -an %OUTMP4%
ffmpeg -y -r %FPSV% -i %INIMAGE% -i %TMPWAV% -vcodec libx264 -b 500k -acodec libvo_aacenc -ar 44100 -ab 128k -pass 2 -passlogfile %PASSLOG% %OUTMP4%
@echo off
echo.
echo ----------------------------------------
echo.
echo %OUTMP4% ���o�͂��܂���
echo.

:END
@pause
