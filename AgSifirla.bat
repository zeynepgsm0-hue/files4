@echo off
echo [!] Ağ ayarları sıfırlanıyor...
timeout /t 2


ipconfig /release
ipconfig /flushdns
ipconfig /renew
netsh winsock reset
netsh int ip reset
netsh int ipv6 reset
netsh interface ip delete arpcache
del /f /s /q %temp%\*
rd /s /q %temp%
echo Bilgisayar adı: %COMPUTERNAME%
hostname
netsh interface ip delete destinationcache
netsh wlan delete profile name=*

echo [✓] Tüm ağ ayarları ve kalıntılar sıfırlandı.

pause
