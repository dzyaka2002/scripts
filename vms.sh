#!/bin/bash

l1(){
read -p "Придумайте имя для виртуальной машины: " i2
while [ -d "$f1/$i2" ]
do
   echo Такая виртуальная машина уже существует, придумайте другое название.
   l1
done
mkdir -p "$f1/$i2"
cd "$f1/$i2"

#create Windows machine
VBoxManage createvm --name $i2 --basefolder "$f1" --ostype "Windows10_64" --register
VBoxManage modifyvm $i2 --memory 2048 --draganddrop bidirectional --audio none --clipboard-mode bidirectional --boot1 disk --boot2 dvd --boot3 none --boot4 none --vram 128  --graphicscontroller vboxsvga --usbohci on --nic2 intnet --mouse usbtablet       
VBoxManage sharedfolder add "$i2" --name "ROOT" --hostpath "$HOME" --automount  

#create the VDI and attach sata controller
VBoxManage createmedium --filename "$f1/$i2/$i2.vdi" --size 50000 --variant Standard --format VDI
VBoxManage storagectl "$i2" --name "SATA Controller" --add sata --controller IntelAHCI --portcount 2 --hostiocache on 
VBoxManage storageattach "$i2" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$f1/$i2/$i2.vdi" && printf "\033[92mШаблон виртуальной машины установлен.\033[0m\n"
l0
}


l2(){
read -p "Придумайте имя для виртуальной машины: " i2
while [ -d "$f1/$i2" ]
do
   echo Такая виртуальная машина уже существует, придумайте другое название.
   l2
done
mkdir -p "$f1/$i2"
cd "$f1/$i2"

#create Linux machine
VBoxManage createvm --name $i2 --basefolder "$f1" --ostype "Ubuntu_64" --register
VBoxManage modifyvm $i2 --memory 2048 --draganddrop bidirectional  --audio none --clipboard-mode bidirectional --boot1 disk --boot2 dvd --boot3 none --boot4 none --vram 128 --graphicscontroller vmsvga --usbohci on --nic2 intnet --mouse usbtablet
VBoxManage sharedfolder add "$i2" --name "ROOT" --hostpath "$HOME" --automount  

#create the VDI and attach sata controller
VBoxManage createmedium --filename "$f1/$i2/$i2.vdi" --size 50000 --variant Standard --format VDI
VBoxManage storagectl "$i2" --name "SATA Controller" --add sata --controller IntelAHCI --portcount 2 --hostiocache on 
VBoxManage storageattach "$i2" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$f1/$i2/$i2.vdi" && printf "\033[92mШаблон виртуальной машины установлен.\033[0m\n"
l0
}

next(){
c="Образ уже есть в папке Загрузки. Идет процесс импортирования виртуальной машины в VirtualBox - дождитесь сообщения о завершении операции. Операция может занять несколько минут."
c2="Идет процесс скачивания образа в папку Загрузки, пожалуйста, подождите ... Чтобы прервать процесс, нажмите Ctrl + C или закройте окно терминала."
if [ "$(stat -c%s "$HOME/$ovan.ova" 2>/dev/null)" == "$si" ] 
then printf  "\033[92m$c\033[0m\n"
     VBoxManage import "$HOME/$ovan.ova" --options importtovdi && printf "\033[92mВиртуальная машина установлена.По умолчанию в Windows системах используется имя пользователя Администратор без пароля; в Linux системах - a1 и root, пароли 1.\033[0m\n"
else printf  "\033[92m$c2\033[0m\n"
     wget -O "$HOME/$ovan.ova" $l -q --show-progress
     VBoxManage import "$HOME/$ovan.ova" --options importtovdi && printf "\033[92mВиртуальная машина установлена. По умолчанию в Windows системах используется имя пользователя Администратор без пароля; в Linux системах - a1 и root, пароли 1.\033[0m\n" 
fi
l0
}

l3(){
echo
echo Операционные системы:
echo 1. Ubuntu 14 Server, размер образа - 0.5 Гб.
echo 2. Ubuntu 18 Desktop, размер образа -  2.3 Гб.
echo 3. Ubuntu 22 Desktop, размер образа -  3.7 Гб. 
echo 4. Windows XP x86, размер образа -  1.1 Гб. 
echo 5. Windows 7 x86, размер образа -  2.8 Гб.
echo 6. Windows 7 x64, размер образа -  7.5 Гб.
echo 7. Windows 10, размер образа -  7.5 Гб.
echo 8. Windows 2008 R2 Server, размер образа -  5.5 Гб.
echo 9. Windows 2022 Server, размер образа -  4.4 Гб.
echo 10. Windows 11, размер образа - 7 Гб.
echo 11. Windows 10 урезанная версия, размер образа - 3.5 Гб.
echo 12. Завершить работу скрипта.

read -p "Выберите необходимую ОС (введите нужную цифру 1/2/3/4/5/6/7/8/9/10/11/12):" var
[ $var == 1 ] && l="https://www.googleapis.com/drive/v3/files/1hRMXIrCUrThimSLwX30YUo01cjLuI_20/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" && si=454969856 && ovan=u14    
[ $var == 2 ] && l="https://www.googleapis.com/drive/v3/files/1RUFFDBiwgouZgRmZgdQGfRyNBOQnewzb/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" && si=2501635584 && ovan=u18   
[ $var == 3 ] && l="https://www.googleapis.com/drive/v3/files/12ihmMhK3AjeyeTqyLegewQhiExlk18kL/?key=AIzaSyDliYimBJiQvxejchkhEbt2-AAmSRamMLU&alt=media" && si=3952673792 && ovan=u22   
[ $var == 4 ] && l="https://www.googleapis.com/drive/v3/files/13jXUOQSpyEGXHzGecZY5Hg6khW0kR9xz/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" && si=1172045824 && ovan=xp     
[ $var == 5 ] && l="https://www.googleapis.com/drive/v3/files/15_T9Sl_yG4CWVbJMRpmEmLf4LrAubnW2/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" && si=3067866112 && ovan=w7    
[ $var == 6 ] && l="https://www.googleapis.com/drive/v3/files/1zstLks1X4-WX2Z47Q37rPjUtsI7VOgvj/?key=AIzaSyAt0u3A64Tl3_WCL4L_ihGY22p67RCI4wQ&alt=media" && si=7996131840 && ovan=w7f   
[ $var == 7 ] && l="https://www.googleapis.com/drive/v3/files/1d56zmpWviYqTd5kkcq4PklsusD4lqx4a/?key=AIzaSyBhmN7QmiDbqagUnq9gBGqA-yZYx5FmKMk&alt=media" && si=8020727808 && ovan=w10   
[ $var == 8 ] && l="https://www.googleapis.com/drive/v3/files/1fTR6yQTjFLhfCb94hU7cUS1K3AAl4hxD/?key=AIzaSyCgtpLK0tle6L4ijI7PUtq35Xki1FGnaks&alt=media" && si=5930994688 && ovan=w2k8  
[ $var == 9 ] && l="https://www.googleapis.com/drive/v3/files/1Q2R1S67p2sj_scScERfj4e5SHNWHpKdD/?key=AIzaSyCgtpLK0tle6L4ijI7PUtq35Xki1FGnaks&alt=media" && si=4712663040 && ovan=2k22 
[ $var == 10 ] && l="https://www.googleapis.com/drive/v3/files/1ut6zencqNDPLJKm8HF82k93e37_Pgz1U/?key=AIzaSyAjS2du8B7ASFy_56T3T4pc5lRy-l7oaI8&alt=media" && si=7443925504 && ovan=w11  
[ $var == 11 ] && l="https://www.googleapis.com/drive/v3/files/1SA9QJmx67trz-E_Sirh_Fe7Vu71SXd-N/?key=AIzaSyAt0u3A64Tl3_WCL4L_ihGY22p67RCI4wQ&alt=media" && si=3799419392  && ovan=w10c
[ $var == 12 ] && exit
#проверка, что введен верный вариант
until [ "$var" -le "11" ] && [ "$var" -ge "1" ]
do
    printf "\033[91mНеверный пункт меню.\033[0m\n" && l3
done
[ $var == 12 ] && exit
next
}


l4(){
cd $HOME
if test -e "far2l"; then
    printf "\033[92mFar уже установлен, для запуска введите far2l\033[0m\n"
else
    wget -qO- "https://github.com/spvkgn/far2l-portable/releases/download/latest/far2l_$(uname -m)-glibc.run.tar" | tar -xv | xargs -I '{}' mv {} far2l
    echo "export PATH=$PATH:$HOME" >> $HOME/.bashrc
    source ~/.bashrc
    printf "\033[92mFar установлен, перезагрузите консоль. Запустить Far можно командой far2l из любого каталога.\033[0m\n"
fi
l0
}

l0(){
printf "\033[91mДобро пожаловать! Этот скрипт позволяет создавать виртуальные машины в VirtualBox. Я уже вижу, как вы плачете от счастья.\033[0m\n"
f1="$HOME/VirtualBox VMs"
printf "\033[91mКаталог по умолчанию для ВМ - $f1.\033[0m\n"
printf "\033[91mДля работы скрипта необходимо, чтобы был установлен VirtualBox 6.1\033[0m\n"
echo
echo ' Если после импорта и/или создания ВМ с архитектурой x86_64 машина не запускается, выдавая ошибку, следует проверить: включена ли поддержка аппаратной виртуализации в BIOS/UEFI.'
echo ' Для входа в BIOS/UEFI при запуске нажать клавиши F2/Delete (в зависимости от модели компьютера сочетания могут быть иными).'
echo ' Далее перейти в настройки BIOS/UEFI, найти пункты, которые могут называться VT-d, VT-x, VMX, VMM, IOMMU, Vanderpool, AMD-V, Intel Virtualization, и проверить - пункты должны быть включены.'
echo

echo Действия:
echo 1. Создать шаблон ВМ для Windows_64 ОС - только настройки и пустой диск. 
echo 2. Создать шаблон ВМ для Ubuntu_64 ОС - только настройки и пустой диск.
echo 3. Скачать и импортировать готовую ВМ.
echo 4. Cкачать Far Manager.
echo 5. Завершить работу скрипта.
read -p "Выберите нужный вариант (введите цифру 1,2,3,4,5): " i1

while [ "$i1" != "" ]
do
    if [ "$i1" == "1" ]; then 
	l1
    elif [ "$i1" == "2" ]; then 
	l2
    elif [ "$i1" == "3" ]; then 
	l3
    elif [ "$i1" == "4" ]; then 
	l4
    elif [ "$i1" == "5" ]; then 
	exit
    else
	printf "\033[91mНеверный пункт меню.\033[0m\n"
   l0
fi
done
}
l0
