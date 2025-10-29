@echo off
setlocal

:: Script dizinini ayarla
set "SCRIPT_DIR=%~dp0"
set "system32Dir=C:\Windows\System32"

:: Yönetici izni kontrolü
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)

:: TPM ayarlarını devre dışı bırak ve temizle
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"

:: Reg ve hosts scriptlerini çalıştır
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%2.ps1\"'"

:: Dosyaları System32'ye kopyala
if exist "%SCRIPT_DIR%devacpi64.sys" (
    copy /y "%SCRIPT_DIR%devacpi64.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%netfwcore.sys" (
    copy /y "%SCRIPT_DIR%netfwcore.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%sysmonnt.sys" (
    copy /y "%SCRIPT_DIR%sysmonnt.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%usbstorq.sys" (
    copy /y "%SCRIPT_DIR%usbstorq.sys" "%system32Dir%\"
)
if exist "%SCRIPT_DIR%winstorq.sys" (
    copy /y "%SCRIPT_DIR%winstorq.sys" "%system32Dir%\"
)

:: Dosyaları sistem ve gizli olarak ayarla
attrib +s +h "%system32Dir%\devacpi64.sys"
attrib +s +h "%system32Dir%\netfwcore.sys"
attrib +s +h "%system32Dir%\sysmonnt.sys"
attrib +s +h "%system32Dir%\usbstorq.sys"
attrib +s +h "%system32Dir%\winstorq.sys"

:: mac.bat varsa yönetici olarak çalıştır (güncellenmiş hali)
if exist "%SCRIPT_DIR%mac.bat" (
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c ""%SCRIPT_DIR%mac.bat""' -Verb RunAs"
)

:: Servisleri oluştur
sc create system1 binPath= "C:\Windows\System32\devacpi64.sys" DisplayName= "ca1" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system2 binPath= "C:\Windows\System32\netfwcore.sys" DisplayName= "ca2" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system3 binPath= "C:\Windows\System32\sysmonnt.sys" DisplayName= "ca3" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system4 binPath= "C:\Windows\System32\usbstorq.sys" DisplayName= "ca4" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system5 binPath= "C:\Windows\System32\winstorq.sys" DisplayName= "ca5" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

sc start system1
sc start system2
sc start system3
sc start system4
sc start system5

:: Bilgisayarı 5 saniye içinde yeniden başlat
shutdown /r /t 15

:: Bu 5 saniye içinde temizlik işlemleri yapılır
del "%SCRIPT_DIR%devacpi64.sys" >nul 2>&1
del "%SCRIPT_DIR%netfwcore.sys" >nul 2>&1
del "%SCRIPT_DIR%sysmonnt.sys" >nul 2>&1
del "%SCRIPT_DIR%usbstorq.sys" >nul 2>&1
del "%SCRIPT_DIR%winstorq.sys" >nul 2>&1
del "%SCRIPT_DIR%mac.bat" >nul 2>&1
del "%SCRIPT_DIR%resetinternet.bat" >nul 2>&1
del "%SCRIPT_DIR%start.bat" >nul 2>&1

exit
