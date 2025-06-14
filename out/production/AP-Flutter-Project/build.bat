@echo off
setlocal

rem مسیر libs و کلاس‌پس
set CP=.;backend\libs\gson-2.8.9.jar

rem ایجاد یک فایل موقت برای لیست فایل‌ها
set SOURCES=source_files.txt

rem اگر فایل قبلی بود پاکش کن
if exist %SOURCES% del %SOURCES%

rem پیدا کردن تمام فایل‌های java و نوشتن توی فایل
for /r %%f in (*.java) do (
    echo %%f >> %SOURCES%
)

rem حالا کامپایل با استفاده از فایل لیست شده
javac -cp %CP% @%SOURCES%

rem حذف فایل موقت
del %SOURCES%

echo.
echo ----------------------
echo Compilation complete!
pause
