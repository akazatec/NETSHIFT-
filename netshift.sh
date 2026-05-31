#!/bin/bash

## NetShift - IP Changer Tool
## Made by akazatec

BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

if [ -t 1 ]; then
    ncolors=$(tput colors 2>/dev/null)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        NC='\033[0m'
        CYAN='\033[38;5;51m'
        GREEN='\033[38;5;46m'
        PINK='\033[38;5;198m'
        YELLOW='\033[38;5;226m'
        ORANGE='\033[38;5;208m'
        PURPLE='\033[38;5;165m'
        BOLD='\033[1m'
        DIM='\033[2m'
        FLASH='\033[5m'
        BG_BLACK='\033[40m'
    else
        NC='' CYAN='' GREEN='' PINK='' YELLOW=''
        ORANGE='' PURPLE='' BOLD='' DIM='' FLASH='' BG_BLACK=''
    fi
else
    NC='' CYAN='' GREEN='' PINK='' YELLOW=''
    ORANGE='' PURPLE='' BOLD='' DIM='' FLASH='' BG_BLACK=''
fi

__version__=1.0

banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ███╗   ██╗███████╗████████╗███████╗██╗  ██╗██╗███████╗████████╗"
    echo "  ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝"
    echo "  ██╔██╗ ██║█████╗     ██║   ███████╗███████║██║█████╗     ██║   "
    echo "  ██║╚██╗██║██╔══╝     ██║   ╚════██║██╔══██║██║██╔══╝     ██║   "
    echo "  ██║ ╚████║███████╗   ██║   ███████║██║  ██║██║██║        ██║   "
    echo "  ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝  "
    echo -e "${NC}"
    echo -e "${YELLOW}${BOLD}        ⚡ LOCAL IP MODIFIER TOOL ⚡${NC}"
    echo -e "${GREEN}${BOLD}              [ VERSION ${__version__} ]${NC}"
    echo -e "${PURPLE}              [ Made by akazatec ]${NC}\n"
}

loading_bar() {
    local msg=$1
    echo -e "\n${CYAN}[>] ${BOLD}${msg}${NC}"
    for i in {1..20}; do
        bars=$(printf "%${i}s" | tr ' ' '█')
        spaces=$(printf "%$((20-i))s" | tr ' ' '░')
        perc=$((i * 5))
        echo -ne "\r${PURPLE}[${GREEN}${bars}${CYAN}${spaces}${PURPLE}] ${YELLOW}${perc}%${NC}"
        sleep 0.05
    done
    echo -e "\n${GREEN}${BOLD}[✓] DONE${NC}\n"
}

check_dependencies() {
    clear && banner
    echo -e "${CYAN}[*] Checking dependencies...${NC}"
    if ! command -v ifconfig > /dev/null; then
        echo -e "${PINK}[!] ${BOLD}net-tools not found. Installing...${NC}"
        if [[ $(uname -o) == "Android" ]]; then
            pkg install net-tools -y
        elif command -v apt-get > /dev/null; then
            sudo apt-get install net-tools -y
        fi
    fi
    echo -e "${GREEN}[✓] ${BOLD}All dependencies satisfied!${NC}"
    sleep 1
}

check_network() {
    banner
    loading_bar "CHECKING NETWORK CONNECTION"
    timeout 3s curl -fIs "https://github.com" > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] ${BOLD}NETWORK: CONNECTED${NC}"
    else
        echo -e "${PINK}[!] ${BOLD}NETWORK: OFFLINE MODE${NC}"
    fi
    sleep 1
}

main_menu() {
    banner
    echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║  ${CYAN}${BOLD}TOOL   : ${GREEN}NetShift IP Changer${NC}${PURPLE}           ║${NC}"
    echo -e "${PURPLE}║  ${CYAN}${BOLD}AUTHOR : ${GREEN}akazatec${NC}${PURPLE}                      ║${NC}"
    echo -e "${PURPLE}║  ${PINK}${BOLD}[ FOR EDUCATIONAL PURPOSES ONLY ]${NC}${PURPLE}       ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}\n"

    store=""

    echo -e "${YELLOW}${BOLD}[>] SCANNING NETWORK INTERFACES...${NC}\n"
    sleep 0.5

    check_iface() {
        iface=$1
        echo -ne "${CYAN}[*] Checking ${iface}...${NC}"
        ifconfig "$iface" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            ip_addr=$(ifconfig "$iface" | awk '/inet / {print $2}')
            if [ -n "$ip_addr" ]; then
                echo -e "\r${GREEN}[✓] ${BOLD}${iface^^} → ${YELLOW}${ip_addr}${NC}        "
                store="$iface"
            else
                echo -e "\r${ORANGE}[!] ${iface} — No IPv4 assigned${NC}        "
            fi
        else
            echo -e "\r${DIM}[×] ${iface} not available${NC}        "
        fi
    }

    check_iface "wlan0"
    sleep 0.2
    check_iface "eth0"
    sleep 0.2
    check_iface "wlo1"
    sleep 0.2
    check_iface "usb0"
    sleep 0.2

    if [ -z "$store" ]; then
        echo -e "\n${PINK}${BOLD}[!] NO ACTIVE INTERFACE FOUND. EXITING...${NC}"
        exit 1
    fi

    echo -e "\n${CYAN}${BOLD}[🌐] ACTIVE INTERFACE: ${GREEN}${store}${NC}\n"
    echo -e "${PURPLE}┌──[${GREEN}akazatec${CYAN}㉿${GREEN}NetShift${PURPLE}]-[${PINK}~${PURPLE}]${NC}"
    echo -ne "${PURPLE}└─${GREEN}\$ ${NC}"
    read -r new_ip

    if [[ ! $new_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${PINK}[!] ${BOLD}INVALID IP FORMAT! Example: 192.168.1.100${NC}"
        sleep 2
        main_menu
        return
    fi

    loading_bar "APPLYING IP CHANGE"
    sudo ifconfig $store $new_ip

    echo -e "${GREEN}${BOLD}[✓] IP SUCCESSFULLY CHANGED!${NC}\n"
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
    ifconfig "$store" | grep -E 'inet|netmask|broadcast' | while read -r line; do
        echo -e "${CYAN}  $line${NC}"
    done
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"

    echo -e "\n${YELLOW}[i] SYSTEM INFO:${NC}"
    echo -e "${GREEN}  • OS      : ${CYAN}$(uname -s) $(uname -r)${NC}"
    echo -e "${GREEN}  • Arch    : ${CYAN}$(uname -m)${NC}"
    echo -e "${GREEN}  • Time    : ${CYAN}$(date)${NC}"
}

# Run
check_dependencies
check_network
main_menu

## Tool by akazatec
