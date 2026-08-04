#!/usr/bin/env bash
# =========================================================
# JTP Panel - Advanced Terminal UI Script (Premium Edition)
# Made by: Jishnu | Edit by: MrZetrix
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
NC='\033[0m'

PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"

# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Premium smooth braille spinner (No lag/glitch)
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis # Hide cursor
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN} [%c] Working...${NC}" "$spinstr"
        spinstr=${temp}${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\r\033[K" # Clear line
    tput cnorm # Show cursor
}

get_pm2_status() {
    local target_names=("Jtg" "JTP-Panel" "ecosystem")
    local name status
    if ! command_exists pm2; then
        echo "not_installed"
        return
    fi
    while IFS= read -r line; do
        for t in "${target_names[@]}"; do
            if [[ "$line" == *"\"name\":\"$t\""* ]]; then
                if [[ "$line" == *"\"status\":\"online\""* ]]; then
                    echo "online"
                    return
                elif [[ "$line" == *"\"status\":\"stopped\""* ]]; then
                    echo "stopped"
                    return
                elif [[ "$line" == *"\"status\":\"errored\""* ]]; then
                    echo "errored"
                    return
                fi
            fi
        done
    done < <(pm2 jlist 2>/dev/null)
    echo "not_found"
}

# ---------------------------------------------------------
# Dynamic Status & System Info
# ---------------------------------------------------------
get_sys_info() {
    local os_name uptime_val pm2_status
    if [ -f /etc/os-release ]; then
        os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
        [ -z "$os_name" ] && os_name=$(grep -E '^NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
    else
        os_name="Linux"
    fi
    [ -z "$os_name" ] && os_name="Unknown"
    
    uptime_val=$(uptime -p 2>/dev/null | sed 's/^up //')
    [ -z "$uptime_val" ] && uptime_val="N/A"
    
    if command_exists pm2; then
        PM2_VAL="${GREEN}Online${NC}"
        pm2_status=$(get_pm2_status)
        case "$pm2_status" in
            online) PANEL_VAL="${GREEN}● Running${NC}" ;;
            stopped|errored) PANEL_VAL="${RED}● Stopped${NC}" ;;
            not_found) PANEL_VAL="${GRAY}● Not Found${NC}" ;;
            *) PANEL_VAL="${GRAY}● Unknown${NC}" ;;
        esac
    else
        PM2_VAL="${RED}Offline${NC}"
        PANEL_VAL="${GRAY}Not Installed${NC}"
    fi

    if command_exists cloudflared; then
        if command_exists systemctl && systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
            CF_VAL="${GREEN}● Active${NC}"
        else
            CF_VAL="${YELLOW}● Installed (Offline)${NC}"
        fi
    else
        CF_VAL="${RED}● Not Installed${NC}"
    fi

    OS_NAME="$os_name"
    UPTIME_VAL="$uptime_val"
}

# ---------------------------------------------------------
# Premium Loading Screens
# ---------------------------------------------------------
show_loading_screens() {
    clear
    echo -e "\n\n"
    echo -e " ${CYAN}${BOLD}INITIALIZING SYSTEM CORE...${NC}"
    echo -e " ${GRAY}────────────────────────────────────────${NC}"
    echo -ne " ["
    for i in {1..30}; do
        echo -ne "${BLUE}█${NC}"
        sleep 0.02
    done
    echo -e "${GRAY}]${NC}"
    echo -e " ${GREEN}Modules Loaded Successfully.${NC}"
    sleep 0.5
    
    clear
    echo -e "\n"
    echo -e " ${MAGENTA}${BOLD}ESTABLISHING SECURE CONNECTION${NC}"
    echo -e " ${GRAY}────────────────────────────────────────${NC}"
    echo -e "\n ${CYAN}╭──────────────────────────────────────╮${NC}"
    echo -e " ${CYAN}│   ${BOLD}${WHITE}JTP PANEL INSTALLER v3.0${NC}${CYAN}         │${NC}"
    echo -e " ${CYAN}╰──────────────────────────────────────╯${NC}"
    echo -e "   ${DIM}Made by: Jishnu | Edit: MrZetrix${NC}"
    sleep 1
}

# ---------------------------------------------------------
# Premium Main Menu
# ---------------------------------------------------------
show_main_menu() {
    get_sys_info
    clear
    echo -e "\n${CYAN}╭──────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}            JTP CONTROL CENTER               ${NC}${CYAN}│${NC}"
    echo -e "${CYAN}│ ${DIM}      Made by jishnu • Edit by MrZetrix      ${NC}${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} OS: %-15s | Uptime: %-13s ${CYAN}│${NC}\n" "${WHITE}${OS_NAME:0:15}${NC}" "${WHITE}${UPTIME_VAL:0:13}${NC}"
    printf "${CYAN}│${NC} Panel: %-23s ${CYAN}│${NC} PM2: %-12s ${CYAN}│${NC}\n" "${PANEL_VAL}" "${PM2_VAL}"
    printf "${CYAN}│${NC} CF Tunnel: %-32s ${CYAN}│${NC}\n" "${CF_VAL}"
    echo -e "${CYAN}├──────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[1]${NC} Install JTP Panel                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[2]${NC} Update Panel & Packages                  ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[3]${NC} Panel Power Control (Start/Stop)         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[4]${NC} Cloudflare Secure Tunnels                ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}[A]${NC} Setup 1 ${DIM}(New VPS Prep & Node.js)${NC}         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}[B]${NC} Setup 2 ${DIM}(Smart Fix, DPKG & Unlock)${NC}       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${RED}[C]${NC} Uninstall Panel System                   ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    echo -e "${RED}[0] Exit Terminal${NC}\n"
}

# ---------------------------------------------------------
# Install Panel
# ---------------------------------------------------------
install_panel() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│       ${BOLD}${WHITE}JTP INSTALLATION WIZARD${NC}${CYAN}          │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"

    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || { echo -e "${RED}[Error] Could not enter panel directory!${NC}"; sleep 2; return; }
        echo -e "${CYAN}➔${NC} Pulling latest updates..."
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
        echo -e "[${GREEN}✓${NC}] Update Pulled."
    else
        echo -e "${CYAN}➔${NC} Cloning core repository..."
        git clone "$GIT_REPO" "$PANEL_DIR" >/dev/null 2>&1 & spinner $!
        if [ ! -d "$PANEL_DIR" ]; then
            echo -e "\n${RED}[Error] Repository clone failed!${NC}"
            sleep 2
            return
        fi
        cd "$PANEL_DIR" || return
        echo -e "[${GREEN}✓${NC}] Repository Cloned."
    fi

    echo -e "\n${CYAN}➔${NC} Installing NPM dependencies..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Dependencies Installed.\n"

    echo -e "${YELLOW}➔ Admin Setup Required:${NC}"
    echo -e "${DIM}(Passwords will be hidden as you type)${NC}"
    npm run createuser
    echo -e "\n${CYAN}➔${NC} User profile secured. [${GREEN}✓${NC}]\n"

    echo -e "${CYAN}➔${NC} Building Panel Assets..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Assets Built."

    echo -e "\n${CYAN}➔${NC} Booting Panel..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "JTP-Panel" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1
    echo -e "[${GREEN}✓${NC}] Panel Online.\n"

    echo -e " ${GREEN}${BOLD}★ Installation Complete! ★${NC}"
    echo -ne "\n${DIM}Press [Enter] to return to the menu...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Uninstall Panel
# ---------------------------------------------------------
uninstall_panel() {
    clear
    echo -e "${RED}╭────────────────────────────────────────╮${NC}"
    echo -e "${RED}│             ${BOLD}${WHITE}SYSTEM PURGE${NC}${RED}               │${NC}"
    echo -e "${RED}╰────────────────────────────────────────╯${NC}\n"
    
    echo -e " ${YELLOW}⚠️ WARNING: This will completely delete the JTP Panel and all its data!${NC}"
    echo -ne " Are you absolutely sure you want to continue? [y/N]: "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${CYAN}➔${NC} Terminating active processes..."
        if command_exists pm2; then
            pm2 delete all >/dev/null 2>&1
            pm2 save --force >/dev/null 2>&1
        fi
        echo -e "[${GREEN}✓${NC}] Processes Terminated."

        echo -e "\n${CYAN}➔${NC} Deleting panel data and directories..."
        rm -rf "$PANEL_DIR"
        echo -e "[${GREEN}✓${NC}] Data Wiped."

        echo -e "\n ${GREEN}★ Purge completely successful. ★${NC}"
    elif [[ "$confirm" =~ ^[Nn]$ ]] || [[ -z "$confirm" ]]; then
        echo -e "\n${GREEN}Operation safely aborted.${NC}"
    else
        echo -e "\n${RED}Invalid input. Operation aborted.${NC}"
    fi

    echo -ne "\n${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ---------------------------------------------------------
# Setup 1 (System Prep)
# ---------------------------------------------------------
run_setup_1() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│         ${BOLD}${WHITE}ENVIRONMENT SETUP 1${NC}${CYAN}            │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"

    echo -e "${CYAN}➔${NC} Updating APT repositories..."
    sudo apt-get update -y >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Repositories Updated."

    echo -e "\n${CYAN}➔${NC} Upgrading system packages..."
    sudo apt-get upgrade -y >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Packages Upgraded."

    echo -e "\n${CYAN}➔${NC} Installing Git & Curl..."
    sudo apt-get install -y git curl >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Tools Installed."

    echo -e "\n${CYAN}➔${NC} Installing Node.js 20.x..."
    ( curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1 && sudo apt-get install -y nodejs >/dev/null 2>&1 ) & spinner $!
    echo -e "[${GREEN}✓${NC}] Node.js Ready."

    echo -e "\n${CYAN}➔${NC} Installing Global PM2..."
    sudo npm install -g pm2 >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] PM2 Installed.\n"

    echo -e "${GREEN}★ Environment Prep Complete! ★${NC}"
    echo -ne "\n${DIM}Press [Enter] to return...${NC}"
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
    
    echo -e "${DIM}Safely fixing dpkg, apt, and npm locks without data loss...${NC}\n"

    echo -e "${CYAN}➔${NC} Fixing dpkg/apt system locks..."
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a >/dev/null 2>&1
    echo -e "[${GREEN}✓${NC}] Locks Cleared."

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "\n${RED}Panel directory not found. Please install the panel first (Option 1).${NC}"
        echo -ne "\n${DIM}Press [Enter] to return...${NC}"
        read -r
        return
    fi
    cd "$PANEL_DIR" || return

    echo -e "\n${CYAN}➔${NC} Clearing corrupted NPM caches..."
    rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null
    rm -rf node_modules 2>/dev/null
    npm cache clean --force >/dev/null 2>&1
    echo -e "[${GREEN}✓${NC}] Cache Cleared."

    echo -e "\n${CYAN}➔${NC} Reinstalling clean dependencies..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Dependencies Restored."

    echo -e "\n${CYAN}➔${NC} Rebuilding Panel..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "[${GREEN}✓${NC}] Panel Rebuilt."

    echo -e "\n${CYAN}➔${NC} Restarting Panel Service..."
    if command_exists pm2; then
        pm2 restart all >/dev/null 2>&1 || pm2 start ecosystem.config.cjs >/dev/null 2>&1
        pm2 save >/dev/null 2>&1
    fi
    echo -e "[${GREEN}✓${NC}] Services Online.\n"

    echo -e "${GREEN}${BOLD}★ System Repaired and Optimized! ★${NC}"
    echo -ne "\n${DIM}Press [Enter] to return...${NC}"
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
        
        echo -e " ${GREEN}[1]${NC} Start Panel"
        echo -e " ${YELLOW}[2]${NC} Restart Panel"
        echo -e " ${RED}[3]${NC} Stop Panel"
        echo -e " ${GRAY}[0]${NC} Back to Main Menu\n"
        
        echo -ne " ${CYAN}➔${NC} Select: "
        read -r sys_opt
        
        case "$sys_opt" in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e "\n${RED}Panel not installed!${NC}"
                    sleep 2
                    continue
                fi
                cd "$PANEL_DIR" || continue
                if [ -f "ecosystem.config.cjs" ]; then
                    pm2 start ecosystem.config.cjs >/dev/null 2>&1
                else
                    pm2 start npm --name "JTP-Panel" -- run start >/dev/null 2>&1
                fi
                pm2 save >/dev/null 2>&1
                cd .. 2>/dev/null || true
                echo -e "\n${GREEN}★ Panel Started Successfully!${NC}"
                sleep 2
                ;;
            2)
                if command_exists pm2; then
                    pm2 restart all >/dev/null 2>&1
                    echo -e "\n${GREEN}★ Panel Restarted Successfully!${NC}"
                else
                    echo -e "\n${RED}PM2 is not installed!${NC}"
                fi
                sleep 2
                ;;
            3)
                if command_exists pm2; then
                    pm2 stop all >/dev/null 2>&1
                    echo -e "\n${RED}★ Panel Stopped!${NC}"
                else
                    echo -e "\n${RED}PM2 is not installed!${NC}"
                fi
                sleep 2
                ;;
            0) break ;;
            *) echo -e "\n${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# Cloudflare Zone (Seamless Integration)
# ---------------------------------------------------------
cloudflare_zone() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│             ${BOLD}${WHITE}CLOUDFLARE ZONE${NC}${CYAN}            │${NC}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${NC}"
        echo -e " Service Status: ${CF_VAL}\n"
        
        echo -e " ${GREEN}[1]${NC} Install & Setup Cloudflare Tunnel"
        echo -e " ${RED}[2]${NC} Uninstall Cloudflare Tunnel"
        echo -e " ${GRAY}[0]${NC} Back to Main Menu\n"
        
        echo -ne " ${CYAN}➔${NC} Select: "
        read -r cf_opt
        
        case "$cf_opt" in
            1)
                clear
                echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
                echo -e "${CYAN}│       ${BOLD}${WHITE}CLOUDFLARE TUNNEL SETUP${NC}${CYAN}          │${NC}"
                echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"
                
                # Check if installed, if not install it directly
                if ! command_exists cloudflared; then
                    echo -e "${CYAN}➔${NC} Cloudflared not found. Installing now..."
                    (
                        sudo mkdir -p /etc/apt/keyrings &&
                        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null &&
                        echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main" | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null &&
                        sudo apt-get update -y >/dev/null 2>&1 &&
                        sudo apt-get install -y cloudflared >/dev/null 2>&1
                    ) & spinner $!
                    echo -e "[${GREEN}✓${NC}] Cloudflare core installed successfully.\n"
                fi

                echo -e "${YELLOW}Please provide your Cloudflare tunnel token.${NC}"
                echo -e "${DIM}(You can get this token from your Cloudflare Zero Trust dashboard)${NC}\n"
                
                echo -ne "${CYAN}➔ Tunnel Token:${NC} "
                read -r cf_token
                
                if [ -z "$cf_token" ]; then
                    echo -e "\n${RED}Error: Token cannot be empty. Setup aborted!${NC}"
                    sleep 2
                    continue
                fi

                echo -e "\n${CYAN}➔${NC} Authenticating and linking tunnel..."
                sudo cloudflared service install "$cf_token" >/dev/null 2>&1 & spinner $!
                echo -e "[${GREEN}✓${NC}] Tunnel linked."
                
                echo -e "\n${CYAN}➔${NC} Booting Cloudflare service..."
                sudo systemctl start cloudflared >/dev/null 2>&1
                sudo systemctl enable cloudflared >/dev/null 2>&1
                echo -e "[${GREEN}✓${NC}] Service Active.\n"
                
                echo -e " ${GREEN}${BOLD}★ Cloudflare Tunnel is Successfully Connected! ★${NC}"
                echo -ne "\n${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            2)
                echo -e "\n${CYAN}➔${NC} Stopping Cloudflare service..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                echo -e "[${GREEN}✓${NC}] Stopped."

                echo -e "\n${CYAN}➔${NC} Removing tunnel configurations..."
                sudo cloudflared service uninstall >/dev/null 2>&1
                sudo apt-get remove --purge -y cloudflared >/dev/null 2>&1 & spinner $!
                echo -e "[${GREEN}✓${NC}] Uninstalled completely.\n"
                
                echo -ne "${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            0) break ;;
            *) echo -e "\n${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------
# Update Panel
# ---------------------------------------------------------
update_manual() {
    clear
    echo -e "${CYAN}╭────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│             ${BOLD}${WHITE}SYSTEM UPDATE${NC}${CYAN}              │${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}Error: JTP Panel directory not found! Install it first.${NC}"
        sleep 2
        return
    fi
    
    cd "$PANEL_DIR" || return
    
    echo -e "${CYAN}➔${NC} Syncing with master repository..."
    (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
    echo -e "[${GREEN}✓${NC}] Synced."

    echo -e "\n${CYAN}➔${NC} Rebuilding System Dependencies..."
    (npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1) & spinner $!
    echo -e "[${GREEN}✓${NC}] System Rebuilt."

    echo -e "\n${CYAN}➔${NC} Rebooting Panel Services..."
    if command_exists pm2; then
        pm2 restart all >/dev/null 2>&1
    fi
    echo -e "[${GREEN}✓${NC}] Services Rebooted.\n"

    echo -e "${GREEN}${BOLD}★ Update Successfully Completed! ★${NC}"
    echo -ne "\n${DIM}Press [Enter] to return...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

# ---------------------------------------------------------
# Main Execution Loop
# ---------------------------------------------------------
show_loading_screens
while true; do
    show_main_menu
    echo -ne " ${CYAN}➔${NC} Enter Command: "
    read -r user_choice
    case "$user_choice" in
        1) install_panel ;;
        2) update_manual ;;
        3) panel_system_menu ;;
        4) cloudflare_zone ;;
        A|a) run_setup_1 ;;
        B|b) run_setup_2 ;;
        C|c) uninstall_panel ;;
        0) 
            echo -e "\n ${GREEN}System shutdown gracefully. Goodbye!${NC}\n"
            exit 0 
            ;;
        *) 
            echo -e "\n${RED}Command unrecognized. Please try again.${NC}"
            sleep 1 
            ;;
    esac
done
