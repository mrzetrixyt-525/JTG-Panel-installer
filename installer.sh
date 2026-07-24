#!/usr/bin/env bash

# =========================================================
# JTP Panel - Advanced Terminal UI Script (Input Fixed)
# Made by: Jishnu | Edit by: MrZetrix
# Panel Name: JTP Panel
# =========================================================

set -o pipefail

# Color Codes & Styling
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"

# Advanced Spinner Function for smooth UI
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# System Info Detection
get_sys_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
    else
        OS_NAME="Linux"
    fi

    UPTIME_VAL=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")

    if command -v pm2 &> /dev/null; then
        PM2_VAL="${GREEN}Installed${NC}"
        if pm2 list 2>/dev/null | grep -qE "Jtg|ecosystem|JTP-Panel"; then
            PANEL_VAL="${GREEN}Started${NC}"
        else
            PANEL_VAL="${YELLOW}N/A${NC}"
        fi
    else
        PM2_VAL="${RED}N/A${NC}"
        PANEL_VAL="${YELLOW}N/A${NC}"
    fi
}

# ---------------------------------------------------------
# Loading Screens
# ---------------------------------------------------------
show_loading_screens() {
    clear
    echo -e "${CYAN}${BOLD}Fanst loading Screen${NC}"
    echo -e "${CYAN}--------------------${NC}"
    echo -n "["
    for i in {1..14}; do
        echo -ne "${GREEN}█${NC}"
        sleep 0.04
    done
    echo "]"
    echo -e "${GREEN}loaded...${NC}"
    sleep 0.8

    clear
    echo -e "${MAGENTA}${BOLD}Second loading Screen${NC}"
    echo -e "${MAGENTA}---------------------${NC}"
    echo -e "       ${YELLOW}opening...${NC}"
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│              ${GREEN}${BOLD}INSTALLER${NC}${CYAN}                 │${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    echo -e " Made by: jishnu | Edit by MrZetrix"
    sleep 1.2
}

# ---------------------------------------------------------
# Main Menu
# ---------------------------------------------------------
show_main_menu() {
    get_sys_info
    clear
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│               ${BOLD}JTP Panel${NC}${CYAN}                │${NC}"
    echo -e "${CYAN}│    Made by jishnu • Edit by MrZetrix   │${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    echo -e " Panel: ${PANEL_VAL}  PM2: ${PM2_VAL}  OS: ${CYAN}${OS_NAME}${NC}  UPT: ${YELLOW}${UPTIME_VAL}${NC}"
    echo -e "${CYAN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[i]${NC}   Install Panel                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[ii]${NC}  Update Pacge's and Update Panel                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[iii]${NC} Uninstall Panel                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[iv]${NC}  Start Panel                                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[v]${NC}   Cloudflare Setup                                  ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────┘${NC}"
    echo -e "${CYAN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[a]${NC} Setup 1 (any vps, update Pacge's + Install Node...) ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[b]${NC} Setup 2 (For Ready To Exsit)                        ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────┘${NC}"
    echo -e "${RED}[0] Exit${NC}\n"
}

# ---------------------------------------------------------
# Install Panel (FIXED INPUT PROMPTS)
# ---------------------------------------------------------
install_panel() {
    clear
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│             ${BOLD}JTP Installer${NC}${CYAN}              │${NC}"
    echo -e "${CYAN}│    Made by jishnu | Edit by mrzetrix   │${NC}"
    echo -e "${CYAN}│     (Alwas install latest update)      │${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    
    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || { echo -e "${RED}[Error] Directory failed!${NC}"; sleep 2; return; }
        echo -ne "➔ Pulling latest update... "
        (git stash &>/dev/null && git pull &>/dev/null) & spinner $!
        echo -e "[${GREEN}✓${NC}]"
    else
        echo -ne "➔ Cloning Repository... "
        git clone "$GIT_REPO" "$PANEL_DIR" &>/dev/null & spinner $!
        cd "$PANEL_DIR" || { echo -e "\n${RED}[Error] Clone failed!${NC}"; sleep 2; return; }
        echo -e "[${GREEN}✓${NC}]"
    fi
    
    get_sys_info
    echo -e "[Info] OS {${OS_NAME}} / Updateing System's ➔ done. [${GREEN}✓${NC}]"
    
    echo -ne "➔ Installing NPM Packages... "
    npm install &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]\n"

    # ========= FIXED AREA: INTERACTIVE PROMPT =========
    echo -e "${YELLOW}➔ Creating Admin User (Please follow prompts):${NC}"
    # Running normally so the Node script can ask for Email, User, and Pass interactively
    npm run createuser
    echo -e "➔ User Setup ➔ done. [${GREEN}✓${NC}]\n"
    # ==================================================

    echo -ne "➔ Building Panel... "
    npm run build &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs &>/dev/null
    else
        pm2 start npm --name "JTP-Panel" -- run start &>/dev/null
    fi
    pm2 save &>/dev/null

    echo -e "[Info] Instaling Panel ➔ done [${GREEN}✓${NC}]\n"
    echo -e "             ${GREEN}${BOLD}ENjoy!!${NC}"
    echo -e "          Thaks for using...\n"
    echo -e "${YELLOW}• [Enter] Back to Installer...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Uninstall Panel
# ---------------------------------------------------------
uninstall_panel() {
    clear
    echo -e "${RED}┌────────────────────────────────────────┐${NC}"
    echo -e "${RED}│                ${BOLD}[Danger]${NC}${RED}                │${NC}"
    echo -e "${RED}│             JTP Unstalling             │${NC}"
    echo -e "${RED}│    Made by jishnu | Edit by MrZetrix   │${NC}"
    echo -e "${RED}└────────────────────────────────────────┘${NC}"
    
    echo -ne "➔ ⚠️ Make sure uninstall Panel? [Y/N]: "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if command -v pm2 &> /dev/null; then
            pm2 stop all &>/dev/null
            pm2 delete all &>/dev/null
            pm2 save --force &>/dev/null
        fi
        rm -rf "$PANEL_DIR"
        echo -e "\n[Info]: Panel uninstalled."
        echo -e "• Thaks for useing..."
    else
        echo -e "\n[Info]: Cancelled."
    fi
    echo -e "\n${YELLOW}[Enter] Back to Manu...${NC}"
    read -r
}

# ---------------------------------------------------------
# Setup 1 (System Prep)
# ---------------------------------------------------------
run_setup_1() {
    clear
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                ${BOLD}Setup 1${NC}${CYAN}                 │${NC}"
    echo -e "${CYAN}│               JTP Panel                │${NC}"
    echo -e "${CYAN}│    Made by jishnu | Edit by MrZetrix   │${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    echo -e "• Setup 1 is starting...\n"

    echo -n "• \ Install git ... "
    (sudo apt update -y &>/dev/null && sudo apt install -y git &>/dev/null) & spinner $!
    echo -e "[${GREEN}done${NC}]"

    echo -n "• \ Installing Node.js (Wait) "
    (curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &>/dev/null && sudo apt install -y nodejs &>/dev/null) & spinner $!
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• \ Installing PM2 "
    sudo npm install -g pm2 &>/dev/null & spinner $!
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• \ extra cloudflare "
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• ⬆ updating System's "
    sudo apt update -y &>/dev/null & spinner $!
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• ⬆ upgradeing \" "
    sudo apt upgrade -y &>/dev/null & spinner $!
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• Install curl ifconfig.me -----------> "
    curl -s ifconfig.me &>/dev/null & spinner $!
    echo -e "[${GREEN}done${NC}]"

    echo -e "\n• ${GREEN}Setup 1 is complite.${NC}\n"
    echo -e "${YELLOW}• Press [enter] to bake manu.${NC}"
    read -r
}

# ---------------------------------------------------------
# Cloudflare Zone
# ---------------------------------------------------------
cloudflare_zone() {
    while true; do
        clear
        echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│            ${BOLD}Cloudflare Zone${NC}${CYAN}             │${NC}"
        echo -e "${CYAN}│               JTP Panel                │${NC}"
        echo -e "${CYAN}│    made by jishnu | Edit by MrZetrix   │${NC}"
        echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
        
        if command -v cloudflared &>/dev/null; then
            CF_STATUS="${GREEN}Installed${NC}"
        else
            CF_STATUS="${RED}Not Installed${NC}"
        fi
        
        echo -e "Cloudflare: {${CF_STATUS}}"
        echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC} 1| install and auto setup               ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} 2| uninstall                            ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} 0| back                                 ${CYAN}│${NC}"
        echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
        echo -ne "Select: "
        read -r cf_opt

        case $cf_opt in
            1)
                echo -ne "\n${YELLOW}Installing Cloudflare... ${NC}"
                (sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null && echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main" | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null && sudo apt update -y &>/dev/null && sudo apt install -y cloudflared &>/dev/null) & spinner $!
                echo -e "\n${GREEN}Cloudflare installed successfully!${NC}"
                sleep 2
                ;;
            2)
                echo -ne "\n${YELLOW}Uninstalling... ${NC}"
                sudo apt remove --purge -y cloudflared &>/dev/null & spinner $!
                echo -e "\n${RED}Cloudflare uninstalled.${NC}"
                sleep 2
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# System Panel Control
# ---------------------------------------------------------
panel_system_menu() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                 ${BOLD}System${NC}${CYAN}                 │${NC}"
        echo -e "${CYAN}│               JTP Panel                │${NC}"
        echo -e "${CYAN}│    Made by jishnu | Edit by MrZetrix   │${NC}"
        echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
        echo -e "Panel start: {${PANEL_VAL}}"
        echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC} 1| Start Panel                          ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} 2| Restart Panel                        ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} 0| exist                                ${CYAN}│${NC}"
        echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
        echo -ne "Select: "
        read -r sys_opt

        case $sys_opt in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e "\n${RED}[Error] Install panel first!${NC}"; sleep 2; continue
                fi
                cd "$PANEL_DIR" || continue
                pm2 start ecosystem.config.cjs 2>/dev/null || pm2 start npm --name "JTP-Panel" -- run start &>/dev/null
                cd .. 2>/dev/null || true
                echo -e "\n${GREEN}Panel Started!${NC}"; sleep 1
                ;;
            2)
                pm2 restart all &>/dev/null
                echo -e "\n${GREEN}Panel Restarted!${NC}"; sleep 1
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# Setup 2
# ---------------------------------------------------------
run_setup_2() {
    clear
    echo -e "${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│              ${BOLD}Final setup${NC}${CYAN}               │${NC}"
    echo -e "${CYAN}│               JTP Panel                │${NC}"
    echo -e "${CYAN}│    Made by jishnu | Edit by MrZetrix   │${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    echo -e "• Setup 2 is starting..."
    echo -e "• Root acc. [Sudo] extra.\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}[Error] Please install the panel (Option [i]) first!${NC}"
        echo -e "${YELLOW}• [Enter] to back e main manu.${NC}"; read -r; return
    fi

    cd "$PANEL_DIR" || return

    echo -n "• Install Package's (Wait) "
    npm install &>/dev/null & spinner $!
    echo -e "[${GREEN}████████████${NC}]"

    echo -n "• ⬆ updateing -----------> "
    npm run build &>/dev/null & spinner $!
    echo -e "[${GREEN}done${NC}]"

    echo -n "• ⬆ upgradeing -----------> "
    (pm2 restart all 2>/dev/null || pm2 start ecosystem.config.cjs 2>/dev/null) & spinner $!
    pm2 save 2>/dev/null
    echo -e "[${GREEN}done${NC}]"

    echo -e "\n• ${GREEN}Final setup is complited.${NC}\n"
    echo -e "             ${GREEN}${BOLD}ENjoy!${NC}\n"
    echo -e "${YELLOW}• [Enter] to back e main manu.${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Update Panel
# ---------------------------------------------------------
update_manual() {
    clear
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}[Error] JTP Panel is not installed yet!${NC}"; sleep 2; return
    fi
    
    cd "$PANEL_DIR" || return
    echo -ne "${YELLOW}Updating Panel Files... ${NC}"
    (git stash &>/dev/null && git pull &>/dev/null) & spinner $!
    echo -e "[${GREEN}✓${NC}]"
    
    echo -ne "${YELLOW}Rebuilding Panel... ${NC}"
    (npm i &>/dev/null && npm run build &>/dev/null) & spinner $!
    echo -e "[${GREEN}✓${NC}]"
    
    echo -ne "${YELLOW}Restarting Services... ${NC}"
    pm2 restart all &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"
    
    echo -e "\n${GREEN}Update completed successfully!${NC}"
    sleep 2
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Main Execution Loop
# ---------------------------------------------------------
show_loading_screens

while true; do
    show_main_menu
    echo -ne "• Select (i-v, a-b, 0): "
    read -r user_choice

    case $user_choice in
        i|I) install_panel ;;
        ii|II) update_manual ;;
        iii|III) uninstall_panel ;;
        iv|IV) panel_system_menu ;;
        v|V) cloudflare_zone ;;
        a|A) run_setup_1 ;;
        b|B) run_setup_2 ;;
        0) echo -e "\n${GREEN}Exiting JTP Panel Installer. Bye!${NC}\n"; exit 0 ;;
        *) echo -e "${RED}Invalid input! Try again.${NC}"; sleep 1 ;;
    esac
done
