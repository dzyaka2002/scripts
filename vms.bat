@echo off
sc config MpsSvc start= auto >nul
sc start mpssvc >nul
cls
chcp 65001 1>nul
echo Добро пожаловать! Этот скрипт позволяет создавать виртуальные машины в VirtualBox. Я уже вижу, как вы плачете от счастья.
echo:
echo - Если вы работаете на Windows 10, дополнительных действий не требуется.
echo - Если вы работаете на Windows 11, необходимо запустить скрипт от имени Администратора.
echo - При работе с Windows 7 возможны сбои.
echo - Если вы работаете на Windows 7, необходимо в командной строке правой кнопкой щелкнуть по верхней части окна, выбрать "Свойства", поле "Шрифт", выбрать Lucida Console и нажать ОК.
echo:
echo Если после импорта и/или создания ВМ с архитектурой x86_64 машина не запускается, выдавая ошибку, следует проверить: включена ли поддержка аппаратной виртуализации в BIOS/UEFI.
echo Для входа в BIOS/UEFI при запуске нажать клавиши F2/Delete (в зависимости от модели компьютера сочетания могут быть иными).
echo Далее перейти в настройки BIOS/UEFI, найти пункты, которые могут называться VT-d, VT-x, VMX, VMM, IOMMU, Vanderpool, AMD-V, Intel Virtualization, и проверить - пункты должны быть включены.

rem f2 - загрузки
(set p="%VBOX_MSI_INSTALL_PATH%vboxmanage.exe")1>nul  2>&1
set f2=%USERPROFILE%\downloads

rem проверка, есть ли vibox
set v="a"
if not exist %p% echo VirtualBox не установлен. & set /p v= Скачать стабильную версию 6.1.44?(y/n):
if %v% NEQ "a" (if "%v%"=="y" (goto v1)) & if "%v%" NEQ "y" exit

cd %VBOX_MSI_INSTALL_PATH%
chcp 1251>nul
rem в переменную f1 добавляется значение каталога по умолчанию для vbox
for /F "delims=^\,: tokens=1*" %%i in ('vboxmanage list systemproperties ^| find "folder"') do set f1="%%j"
for /F "tokens=*" %%i in (%f1%) do set f1=%%i
chcp 65001>nul
rem проверка версии vibox
for /F "delims=_: tokens=2" %%i in ('vboxmanage list systemproperties ^| find "API"') do set vb="%%i"
for /F "tokens=*" %%i in (%vb%) do set verv="%%i"
if %verv%=="7" echo Скрипт не поддерживает версию 7 VirtualBox. & set /p v= Скачать стабильную версию 6.1.44?(y/n):
if %v% NEQ "a" (if "%v%"=="y" (goto v1)) & if "%v%" NEQ "y" exit

:l0 
echo:                
echo Каталог по умолчанию для ВМ - %f1%
echo Действия:
echo 0. Переопределить каталог для хранения виртуальных машин. 
echo 1. Создать шаблон ВМ для Windows_64 ОС - только настройки и пустой диск. 
echo 2. Создать шаблон ВМ для Ubuntu_64 ОС - только настройки и пустой диск.
echo 3. Скачать и импортировать готовую ВМ.
echo 4. Скачать стабильную версию VirtualBox 6.1.44.
echo 5. Завершить работу скрипта.
set /p i1=Выберите нужный вариант (введите цифру 0,1,2,3,4 или 5):
cls
if %i1%==0 goto s0
if %i1%==1 goto l1
if %i1%==2 goto l2
if %i1%==3 goto l3
if %i1%==4 goto v1
if %i1%==5 exit
echo Неверный вариант, следует выбрать другой. & goto l0

:s0
rem cмена каталога
echo Каталог по умолчанию не может быть корневым, не может оканчиваться на "\", не может содержать символы *№@ и т.д.
echo Примеры корректных путей: c:\vms, c:\administrator\virtualbox.
set /p f3=Задайте полный путь до каталога для ВМ, не используйте пробелы в пути и названия на русском языке (Если Вас устраивает каталог %f1%, введите y):

rem убрать кавычки из пути
setlocal EnableDelayedExpansion
set f3=!f3:"=!
setlocal DisableDelayedExpansion
if "%f3%"=="y" goto l0

rem проверка, чтобы папка - не корень
for /F "delims=:^\ tokens=1,2" %%i in ("%f3%") do if "%%j"=="" goto s0
rem проверка, чтобы не было спец-символов в пути
for /F "delims=^/!@#№$;^^%%?&*()+={}[]|'<>,~` tokens=1" %%i in ("%f3%") do if "%%i" NEQ "%f3%" goto s0
rem отброс последнего слэша
if "%f3:~-1%"=="\" set "f3=%f3:~0,-1%"
if not exist "%f3%" mkdir "%f3%"
if not exist "%f3%" echo Не удалось задать каталог. Недостаточно прав или имеется иная проблема. & goto s0
(%p% setproperty machinefolder "%f3%")1>nul  2>&1
if %ERRORLEVEL% NEQ 0 echo Не удалось задать каталог. Недостаточно прав или имеется иная проблема. & goto s0
set f1=%f3%
goto l0

:v1
rem скачивание virtualbox
cls
if not exist "%f2%\wget.exe" echo Скачивание дополнительной утилиты wget в папку "Загрузки". & pause & bitsadmin /transfer myDownloadJob /download "https://eternallybored.org/misc/wget/1.21.4/64/wget.exe" %f2%\wget.exe
echo Идет процесс скачивания VirtualBox...Чтобы прервать процесс, нажмите Ctrl + C или закройте окно консоли.
"%f2%\wget.exe" -O "%f2%\1.tmp" "https://download.virtualbox.org/virtualbox/6.1.44/VirtualBox-6.1.44-156814-Win.exe" -q --show-progress
cd %f2%
type 1.tmp >VirtualBox-6.1.44-156814-Win.exe
del 1.tmp

rem скачивание пакета расширений
echo Загрузка пакета расширений.
"%f2%\wget.exe" -O "%f2%\1.tmp" "https://download.virtualbox.org/virtualbox/6.1.44/Oracle_VM_VirtualBox_Extension_Pack-6.1.44.vbox-extpack" -q --show-progress
type 1.tmp >Oracle_VM_VirtualBox_Extension_Pack-6.1.44.vbox-extpack
del 1.tmp

rem вывод результата + выход из программы
echo Дистрибутив VirtualBox.exe и пакет расширений c названием extension_pack находятся в папке "Загрузки". Их можно найти с помощью поиска.
echo Удалите другую версию, если VirtualBox был уже инсталлирован.
echo Установите VirtualBox c пакетом расширений (в VirtualBox пункт "Файл"-^>"Настройки"-^>"Плагины"), ПЕРЕЗАГРУЗИТЕ компьютер и запустите скрипт заново.
pause
exit

:l1
rem регистрация вм windows
set /p i2=Придумайте имя для виртуальной машины:
if exist "%f1%\%i2%" echo Такая виртуальная машина уже существует, придумайте другое название. & goto l1
(%p% createvm --name "%i2%" --basefolder="%f1%" --ostype Windows10_64 --register)1>nul  2>&1
cls
goto l5


:l2
rem регистрация вм linux
set /p i2=Придумайте имя для виртуальной машины:
if exist "%f1%\%i2%" echo Такая виртуальная машина уже существует, придумайте другое название. & goto l2 
(%p% createvm --name "%i2%" --basefolder="%f1%" --ostype Ubuntu_64 --register)1>nul  2>&1
cls
goto l6

:l3
rem скачивание wget, если его нет в папке загрузки
if exist %f2%\wget.exe goto l4
echo Скачивание дополнительной утилиты wget в папку "Загрузки".
pause
if not exist %f2%\wget.exe bitsadmin /transfer myDownloadJob /download  "https://eternallybored.org/misc/wget/1.21.4/64/wget.exe" %f2%\wget.exe
pause
:l4
echo Операционные системы:
echo 1. Ubuntu 14 Server, размер образа - 0.5 Гб.
echo 2. Ubuntu 18 Desktop, размер образа -  2.3 Гб.
echo 3. Ubuntu 22 Desktop, размер образа -  3.7 Гб. 
echo 4. Windows XP x86, размер образа -  1.1 Гб. 
echo 5. Windows 7 x86, размер образа -  2.8 Гб.
echo 6. Windows 7 x64, размер образа -  7 Гб.
echo 7. Windows 10, размер образа -  5.5 Гб.
echo 8. Windows 2008 R2 Server, размер образа -  5.5 Гб.
echo 9. Windows 2022 Server, размер образа -  4.4 Гб.
echo 10. Windows 11, размер образа - 7 Гб.
echo 11. Windows 10 урезанная версия, размер образа - 3.5 Гб.
echo 12. Завершить работу скрипта.
set /p var=Выберите необходимую ОС (введите нужную цифру 1/2/3/4/5/6/7/8/9/10/11/12):
if %var%==1 set l="https://www.googleapis.com/drive/v3/files/1hRMXIrCUrThimSLwX30YUo01cjLuI_20/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" & set si=454969856 & set ovan=u14
if %var%==2 set l="https://www.googleapis.com/drive/v3/files/1RUFFDBiwgouZgRmZgdQGfRyNBOQnewzb/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" & set si=2501635584 & set ovan=u18
if %var%==3 set l="https://www.googleapis.com/drive/v3/files/12ihmMhK3AjeyeTqyLegewQhiExlk18kL/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" & set si=3952673792 & set ovan=u22
if %var%==4 set l="https://www.googleapis.com/drive/v3/files/1_3G6x2OZLKipZh6vV5J7mX1kPfFeo0Ib/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" & set si=1187202560 & set ovan=xp
if %var%==5 set l="https://www.googleapis.com/drive/v3/files/15_T9Sl_yG4CWVbJMRpmEmLf4LrAubnW2/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" & set si=3067866112 & set ovan=w7
if %var%==6 set l="https://www.googleapis.com/drive/v3/files/1aHW3LOE1g1y75lyVmmC1CWwP3PqWNTdb/?key=AIzaSyAt0u3A64Tl3_WCL4L_ihGY22p67RCI4wQ&alt=media" & set si=7471829504 & set ovan=w7f
if %var%==7 set l="https://www.googleapis.com/drive/v3/files/1CQM5tyz59cO6O1Nldui2KAhUD1JvOl-9/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" & set si=6003269632 & set ovan=w10
if %var%==8 set l="https://www.googleapis.com/drive/v3/files/1fTR6yQTjFLhfCb94hU7cUS1K3AAl4hxD/?key=AIzaSyCgtpLK0tle6L4ijI7PUtq35Xki1FGnaks&alt=media" & set si=5930994688 & set ovan=w2k8
if %var%==9 set l="https://www.googleapis.com/drive/v3/files/1Q2R1S67p2sj_scScERfj4e5SHNWHpKdD/?key=AIzaSyCgtpLK0tle6L4ijI7PUtq35Xki1FGnaks&alt=media" & set si=4712663040 & set ovan=2k22
if %var%==10 set l="https://www.googleapis.com/drive/v3/files/1ut6zencqNDPLJKm8HF82k93e37_Pgz1U/?key=AIzaSyAjS2du8B7ASFy_56T3T4pc5lRy-l7oaI8&alt=media" & set si=7443925504 & set ovan=w11
if %var%==11 set l="https://www.googleapis.com/drive/v3/files/1SA9QJmx67trz-E_Sirh_Fe7Vu71SXd-N/?key=AIzaSyAt0u3A64Tl3_WCL4L_ihGY22p67RCI4wQ&alt=media" & set si=3799419392 & set ovan=w10c
if %var%==12 exit

rem проверка того, что введен верный вариант
if %var%==1 goto next 
if %var%==2 goto next
if %var%==3 goto next
if %var%==4 goto next
if %var%==5 goto next
if %var%==6 goto next
if %var%==7 goto next
if %var%==8 goto next
if %var%==9 goto next
if %var%==10 goto next
if %var%==11 goto next
exit

:next
cls
set c=Образ уже есть в папке Загрузки. Идет процесс импортирования виртуальной машины в VirtualBox - дождитесь сообщения о завершении операции. Операция может занять несколько минут.
set c2=Идет процесс скачивания образа в папку Загрузки. Пожалуйста, подождите... Чтобы прервать процесс, нажмите Ctrl + C или закройте окно консоли.
for %%i in ("%f2%\%ovan%.ova") do (if %%~zi==%si% echo %c% & (%p% import "%f2%\%ovan%.ova" --options importtovdi)1>nul | find "0%" & goto l4.1)
echo %c2%
"%f2%\wget.exe" -O "%f2%\%ovan%.ova" %l% -q --show-progress 
if %ERRORLEVEL% NEQ 0 echo Загрузить образ не удалось. & goto l4
echo Идет процесс импортирования виртуальной машины в VirtualBox - дождитесь сообщения о завершении операции. Операция может занять несколько минут.
(%p% import "%f2%\%ovan%.ova" --options importtovdi)1>nul | find "0%"
:l4.1
if exist "%f1%\%ovan%*" echo Операция успешно завершена! ВМ создана. По умолчанию в Windows системах используется имя пользователя Администратор без пароля; в Linux системах - a1 и root, пароли 1.
if not exist "%f1%\%ovan%*" echo Операция не удалась. Проверьте размер свободного места на диске.
goto l0

:l5
rem настройка параметров для вм windows + создание диска                                                                 
(%p% modifyvm "%i2%" --memory 2048 --draganddrop=bidirectional --audio none --clipboard-mode=bidirectional --boot1=disk --boot2=dvd --boot3=none --boot4=none --vram=128  --graphicscontroller=vboxsvga --usbohci=on --nic2=intnet --mouse=usbtablet
%p% sharedfolder add "%i2%" --name="ROOT" --hostpath="%SystemDrive%" --automount  
rem create the VDI and attach sata controller
%p% createmedium --filename="%f1%\%i2%\%i2%.vdi" --size 50000 --variant Standard --format VDI
%p% storagectl "%i2%" --name "SATA Controller" --add sata --controller IntelAHCI --portcount 2 --hostiocache=on 
%p% storageattach "%i2%" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "%f1%\%i2%\%i2%.vdi")1>nul  2>&1
if exist "%f1%\%i2%" echo Операция успешно завершена! ВМ создана!
if not exist "%f1%\%i2%" echo Не удалось создать ВМ.
goto l0

:l6
rem настройка параметров для вм linux + создание диска 
(%p% modifyvm "%i2%" --memory 2048 --draganddrop=bidirectional --audio none --clipboard-mode=bidirectional --boot1=disk --boot2=dvd --boot3=none --boot4=none --vram=128  --graphicscontroller=vmsvga --usbohci=on --nic2=intnet --mouse=usbtablet
%p% sharedfolder add "%i2%" --name="ROOT" --hostpath="%SystemDrive%" --automount  
rem create the VDI and attach sata controller
%p% createmedium --filename="%f1%\%i2%\%i2%.vdi" --size 50000 --variant Standard --format VDI
%p% storagectl "%i2%" --name "SATA Controller" --add sata --controller IntelAHCI --portcount 2 --hostiocache=on 
%p% storageattach "%i2%" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "%f1%\%i2%\%i2%.vdi")1>nul  2>&1
if exist "%f1%\%i2%" echo Операция успешно завершена! ВМ создана!
if not exist "%f1%\%i2%" echo Не удалось создать ВМ.
goto l0
                                             
