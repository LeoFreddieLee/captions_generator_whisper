@echo off
setlocal

:: 检查是否提供了输入文件
if "%~1"=="" (
    echo 需要提供输入视频文件名称
    exit /b 1
)

:: 设定输入文件名、临时文件名和输出文件名
set input_video=%~1
set temp_audio=audio.wav
set temp_srt=audio.srt
set output_video=temp_output.mp4

:: 提取音频
ffmpeg -i "%input_video%" -vn -acodec pcm_s16le -ar 16000 -ac 1 "%temp_audio%"
if errorlevel 1 (
    echo 提取音频失败
    exit /b 1
)

:: 使用 Whisper 进行语音转文字
whisper.exe "%temp_audio%" --model medium
if errorlevel 1 (
    echo Whisper 转换失败
    exit /b 1
)

:: 合并字幕回视频，输出到临时文件
ffmpeg -i "%input_video%" -i "%temp_srt%" -c copy -c:s mov_text "%output_video%"
if errorlevel 1 (
    echo 合并字幕失败
    exit /b 1
)

:: 删除临时文件
del "%temp_audio%"
del "%temp_srt%"

:: 用临时文件替换原文件
move /Y "%output_video%" "%input_video%"
if errorlevel 1 (
    echo 替换原视频文件失败
    exit /b 1
)

echo 处理完成，已替换原文件。
