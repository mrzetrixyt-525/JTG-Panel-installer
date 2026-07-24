#!/usr/bin/env bash

# =========================================================
# JTP Panel - Advanced Terminal UI Script (Max Premium Edition)
# Made by: Jishnu | Edit by: MrZetrix
# Panel Name: JTP Panel
# =========================================================

set -o pipefail

# ---------------------------------------------------------
# Premium Color Palette & Styling
# ---------------------------------------------------------
GREEN='\033[38;5;46m'
CYAN='\033[38;5;51m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
MAGENTA='\033[38;5;213m'
BLUE='\033[38;5;33m'
WHITE='\033[38;5;255m'
GRAY='\033[38;5;240m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"

# ---------------------------------------------------------
# Premium Smooth Spinner
# ---------------------------------------------------------
spinner() {
    local pid=$1
    local delay=0.08
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}%c${NC}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ---------------------------------------------------------
# Dynamic Status & System Info
# ---------------------------------------------------------
get_sys_info() {
    # OS Detection
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E "^NAME=" /etc/os-release | cut -d '"' -f 2)
    else
        OS_NAME="Linux"
    fi

    # Uptime
    UPTIME_VAL=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")

    # PM2 & Panel Status
    if command -v pm2 &> /dev/null; then
        PM2_VAL="${GREEN}Online${NC}"
        # Strictly check if ecosystem.config.cjs or JTP-Panel is running and online
        if pm2 jlist 2>/dev/null | grep -q '\"pm2_env\":{\"status\":\"online\"' && pm2 list 2>/dev/null | grep -qE "Jtg|ecosystem|JTP-Panel"; then
            PANEL_VAL="${GREEN}● Running${NC}"
        else
            PANEL_VAL="${RED}● Stopped${NC}"
        fi
    else
        PM2_VAL="${RED}Offline${NC}"
        PANEL_VAL="${GRAY}Not Installed${NC}"
    fi

    # Cloudflare Status
    if command -v cloudflared &> /dev/null; then
        if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x "cloudflared" > /dev/null; then
            CF_VAL="${GREEN}● Active${NC}"
        else
            CF_VAL="${YELLOW}● Installed (Offline)${NC}"
        fi
    else
        CF_VAL="${RED}● Not Installed${NC}"
    fi
}

# ---------------------------------------------------------
# Premium Loading Screens
# ---------------------------------------------------------
show_loading_screens() {
    clear
    echo -e "\n\n"
    echo -e "      ${CYAN}${BOLD}INITIALIZING SYSTEM...${NC}"
    echo -e "      ${GRAY}────────────────────────${NC}"
    echo -ne "      ["
    for i in {1..20}; do
        echo -ne "${BLUE}▰${NC}"
        sleep 0.03
    done
    echo -e "${GRAY}]${NC}"
    echo -e "      ${GREEN}Modules Loaded Successfully.${NC}"
    sleep 0.5

    clear
    echo -e "\n"
    echo -e "      ${MAGENTA}${BOLD}ESTABLISHING SECURE CONNECTION${NC}"
    echo -e "      ${GRAY}──────────────────────────────${NC}"
    echo -e "\n      ${CYAN}╭──────────────────────────────────────╮${NC}"
    echo -e "      ${CYAN}│      ${BOLD}${WHITE}JTP PANEL INSTALLER v3.0${NC}${CYAN}        │${NC}"
    echo -e "      ${CYAN}╰──────────────────────────────────────╯${NC}"
    echo -e "         ${DIM}Made by: Jishnu | Edit: MrZetrix${NC}"
    sleep 1
}

# ---------------------------------------------------------
# Premium Main Menu
# ---------------------------------------------------------
show_main_menu() {
    get_sys_info
    clear
    echo -e "\n${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│               ${BOLD}${WHITE}JTP CONTROL CENTER${NC}${CYAN}                 │${NC}"
    echo -e "${CYAN}│        ${DIM}Made by jishnu • Edit by MrZetrix${NC}${CYAN}         │${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} OS: ${WHITE}${OS_NAME:0:15}${NC} | Uptime: ${WHITE}${UPTIME_VAL:0:15}${NC}"
    echo -e "${CYAN}│${NC} Panel: ${PANEL_VAL}  ${CYAN}│${NC} PM2: ${PM2_VAL}  ${CYAN}│${NC} CF: ${CF_VAL}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[i]${NC}   Install JTP Panel                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[ii]${NC}  Update Panel & Packages                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[iii]${NC} Uninstall Panel System                 ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[iv]${NC}  Panel Power Control (Start/Stop)       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[v]${NC}   Cloudflare Secure Tunnels              ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[a]${NC} Setup 1 ${DIM}(New VPS Prep & Node.js)${NC}       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[b]${NC} Setup 2 ${DIM}(Smart Fix, DPKG & Unlock)${NC}     ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
    echo -e "  ${RED}[0] Exit Terminal${NC}\n"
}

# ---------------------------------------------------------
# Install Panel
# ---------------------------------------------------------
install_panel() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│           ${BOLD}${WHITE}JTP INSTALLATION${NC}${CYAN}             │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"
    
    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        echo -ne " ${CYAN}➔${NC} Pulling latest updates... "
        (git stash &>/dev/null && git pull &>/dev/null) & spinner $!
        echo -e "[${GREEN}✓${NC}]"
    else
        echo -ne " ${CYAN}➔${NC} Cloning core repository... "
        git clone "$GIT_REPO" "$PANEL_DIR" &>/dev/null & spinner $!
        cd "$PANEL_DIR" || return
        echo -e "[${GREEN}✓${NC}]"
    fi
    
    echo -ne " ${CYAN}➔${NC} Installing NPM dependencies... "
    npm install &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]\n"

    echo -e " ${YELLOW}➔ Admin Setup Required:${NC}"
    echo -e " ${DIM}(Passwords will be hidden as you type)${NC}"
    npm run createuser
    echo -e "\n ${CYAN}➔${NC} User profile secured. [${GREEN}✓${NC}]\n"

    echo -ne " ${CYAN}➔${NC} Building Panel Assets... "
    npm run build &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Booting Panel... "
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs &>/dev/null
    else
        pm2 start npm --name "JTP-Panel" -- run start &>/dev/null
    fi
    pm2 save &>/dev/null
    echo -e "[${GREEN}✓${NC}]\n"

    echo -e " ${GREEN}${BOLD}★ Installation Complete! ★${NC}"
    echo -e " ${DIM}Press [Enter] to return...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Uninstall Panel
# ---------------------------------------------------------
uninstall_panel() {
    clear
    echo -e "${RED}╭────────────────────────────────────────╮${NC}"
    echo -e "${RED}│            ${BOLD}${WHITE}SYSTEM PURGE${NC}${RED}                │${NC}"
    echo -e "${RED}╰────────────────────────────────────────╯${NC}\n"
    
    echo -ne " ${YELLOW}⚠ Are you absolutely sure? [Y/N]: ${NC}"
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -ne " ${CYAN}➔${NC} Terminating processes... "
        if command -v pm2 &> /dev/null; then
            pm2 delete all &>/dev/null
            pm2 save --force &>/dev/null
        fi
        echo -e "[${GREEN}✓${NC}]"
        
        echo -ne " ${CYAN}➔${NC} Deleting panel data... "
        rm -rf "$PANEL_DIR"
        echo -e "[${GREEN}✓${NC}]"
        echo -e "\n ${GREEN}Purge complete.${NC}"
    else
        echo -e "\n ${GRAY}Operation aborted.${NC}"
    fi
    echo -e "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ---------------------------------------------------------
# Setup 1 (System Prep)
# ---------------------------------------------------------
run_setup_1() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│          ${BOLD}${WHITE}ENVIRONMENT SETUP 1${NC}${CYAN}           │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"

    echo -ne " ${CYAN}➔${NC} Updating APT repositories... "
    sudo apt-get update -y &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Upgrading system packages... "
    sudo apt-get upgrade -y &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Installing Git & Curl... "
    sudo apt-get install -y git curl &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Installing Node.js 20.x... "
    (curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &>/dev/null && sudo apt-get install -y nodejs &>/dev/null) & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Installing Global PM2... "
    sudo npm install -g pm2 &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]\n"

    echo -e " ${GREEN}Environment Prep Complete.${NC}"
    echo -e " ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ---------------------------------------------------------
# Setup 2 (Smart Fix & Data-Safe Unlock)
# ---------------------------------------------------------
run_setup_2() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│         ${BOLD}${WHITE}SMART REPAIR & UNLOCK${NC}${CYAN}          │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"
    echo -e " ${DIM}Safely fixing dpkg, apt, and npm locks without data loss...${NC}\n"

    echo -ne " ${CYAN}➔${NC} Fixing dpkg/apt locks... "
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a &>/dev/null
    echo -e "[${GREEN}✓${NC}]"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "\n ${RED}Panel not found. Install first (Option i).${NC}"
        echo -e " ${DIM}Press [Enter] to return...${NC}"; read -r; return
    fi

    cd "$PANEL_DIR" || return

    echo -ne " ${CYAN}➔${NC} Clearing corrupted NPM caches... "
    rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null
    rm -rf node_modules 2>/dev/null
    npm cache clean --force &>/dev/null
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Reinstalling clean dependencies... "
    npm install &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Rebuilding Panel... "
    npm run build &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]"

    echo -ne " ${CYAN}➔${NC} Restarting Panel Service... "
    pm2 restart all &>/dev/null || pm2 start ecosystem.config.cjs &>/dev/null
    pm2 save &>/dev/null
    echo -e "[${GREEN}✓${NC}]\n"

    echo -e " ${GREEN}${BOLD}★ System Repaired and Optimized! ★${NC}"
    echo -e " ${DIM}Press [Enter] to return...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# System Panel Control
# ---------------------------------------------------------
panel_system_menu() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│          ${BOLD}${WHITE}PANEL POWER CONTROL${NC}${CYAN}           │${NC}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${NC}"
        echo -e " Current Status: ${PANEL_VAL}\n"
        echo -e "  ${GREEN}1${NC} | Start Panel"
        echo -e "  ${YELLOW}2${NC} | Restart Panel"
        echo -e "  ${RED}3${NC} | Stop Panel"
        echo -e "  ${GRAY}0${NC} | Back to Main Menu\n"
        
        echo -ne " ${CYAN}➔${NC} Select: "
        read -r sys_opt

        case $sys_opt in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e " ${RED}Panel not installed!${NC}"; sleep 1; continue
                fi
                cd "$PANEL_DIR" || continue
                pm2 start ecosystem.config.cjs &>/dev/null || pm2 start npm --name "JTP-Panel" -- run start &>/dev/null
                pm2 save &>/dev/null
                cd .. 2>/dev/null || true
                echo -e " ${GREEN}Panel Started!${NC}"; sleep 1
                ;;
            2)
                pm2 restart all &>/dev/null
                echo -e " ${GREEN}Panel Restarted!${NC}"; sleep 1
                ;;
            3)
                pm2 stop all &>/dev/null
                echo -e " ${RED}Panel Stopped!${NC}"; sleep 1
                ;;
            0) break ;;
            *) echo -e " ${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# Cloudflare Zone (Updated with Tunnel Token Setup)
# ---------------------------------------------------------
cloudflare_zone() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│            ${BOLD}${WHITE}CLOUDFLARE ZONE${NC}${CYAN}             │${NC}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${NC}"
        echo -e " Service Status: ${CF_VAL}\n"
        echo -e "  ${GREEN}1${NC} | Install Cloudflared"
        echo -e "  ${YELLOW}2${NC} | Setup & Connect Cloudflare Tunnel (Token)"
        echo -e "  ${RED}3${NC} | Uninstall Cloudflared"
        echo -e "  ${GRAY}0${NC} | Back to Main Menu\n"
        
        echo -ne " ${CYAN}➔${NC} Select: "
        read -r cf_opt

        case $cf_opt in
            1)
                echo -ne "\n ${CYAN}➔${NC} Installing Cloudflare... "
                (sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null && echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main" | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null && sudo apt-get update -y &>/dev/null && sudo apt-get install -y cloudflared &>/dev/null) & spinner $!
                echo -e "[${GREEN}✓${NC}]"
                sleep 1
                ;;
            2)
                clear
                echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
                echo -e "${CYAN}│        ${BOLD}${WHITE}CLOUDFLARE TUNNEL SETUP${NC}${CYAN}        │${NC}"
                echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"
                echo -e " ${YELLOW}Please paste your Cloudflare tunnel token below:${NC}"
                echo -e " ${DIM}(Get this token from your Cloudflare Zero Trust dashboard)${NC}\n"
                echo -ne " ${CYAN}➔ Tunnel Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "\n ${RED}Token cannot be empty!${NC}"
                    sleep 15
                    continue
                fi

                echo -ne "\n ${CYAN}➔${NC} Installing cloudflare tunnel service... "
                sudo cloudflared service install "$cf_token" &>/dev/null & spinner $!
                echo -e "[${GREEN}✓${NC}]"

                echo -ne " ${CYAN}➔${NC} Starting cloudflared service... "
                sudo systemctl start cloudflared &>/dev/null
                sudo systemctl enable cloudflared &>/dev/null
                echo -e "[${GREEN}✓${NC}]\n"

                echo -e " ${GREEN}${BOLD}★ Cloudflare Tunnel Successfully Connected! ★${NC}"
                echo -e " ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            3)
                echo -ne "\n ${CYAN}➔${NC} Uninstalling Cloudflare... "
                sudo systemctl stop cloudflared &>/dev/null
                sudo cloudflared service uninstall &>/dev/null
                sudo apt-get remove --purge -y cloudflared &>/dev/null & spinner $!
                echo -e "[${GREEN}✓${NC}]"
                sleep 1
                ;;
            0) break ;;
            *) echo -e " ${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# Update Panel
# ---------------------------------------------------------
update_manual() {
    clear
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e " ${RED}JTP Panel not found!${NC}"; sleep 1; return
    fi
    
    cd "$PANEL_DIR" || return
    echo -ne " ${CYAN}➔${NC} Syncing Repository... "
    (git stash &>/dev/null && git pull &>/dev/null) & spinner $!
    echo -e "[${GREEN}✓${NC}]"
    
    echo -ne " ${CYAN}➔${NC} Rebuilding System... "
    (npm install &>/dev/null && npm run build &>/dev/null) & spinner $!
    echo -e "[${GREEN}✓${NC}]"
    
    echo -ne " ${CYAN}➔${NC} Rebooting Panel... "
    pm2 restart all &>/dev/null & spinner $!
    echo -e "[${GREEN}✓${NC}]\n"
    
    echo -e " ${GREEN}Update Complete!${NC}"
    sleep 1
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Main Execution Loop
# ---------------------------------------------------------
show_loading_screens

while true; do
    show_main_menu
    echo -ne "  ${CYAN}➔${NC} Enter Command: "
    read -r user_choice

    case $user_choice in
        i|I) install_panel ;;
        ii|II) update_manual ;;
        iii|III) uninstall_panel ;;
        iv|IV) panel_system_menu ;;
        v|V) cloudflare_zone ;;
        a|A) run_setup_1 ;;
        b|B) run_setup_2 ;;
        0) echo -e "\n ${GREEN}System shutdown gracefully. Goodbye!${NC}\n"; exit 0 ;;
        *) echo -e " ${RED}Command unrecognized.${NC}"; sleep 1 ;;
    esac
done
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
