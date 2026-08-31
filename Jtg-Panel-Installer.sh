#!/usr/bin/env bash
# =========================================================
# JTG Panel V3 - Advanced Terminal UI Script (Pro Edition)
# Original Author: Jishnu | Edited by: MrZetrix
# Panel Directory: Jtg
# Optimized for: Ubuntu, Debian, Docker Environments
# =========================================================

set -o pipefail
export DEBIAN_FRONTEND=noninteractive

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

PANEL_VERSION="V3"
PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"
APP_NAME="jtg-panel"

# Universal Clean Trap
trap 'tput cnorm 2>/dev/null; exit' INT TERM EXIT

# ---------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ultra-Smooth Anti-Glitch Spinner
spinner() {
    local pid=$1
    local delay=0.08
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis 2>/dev/null
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r ${CYAN}[%c]${NC} ${DIM}Processing, please wait...${NC}" "$spinstr"
        spinstr=${temp}${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\r\033[K"
    tput cnorm 2>/dev/null
}

# Accurate PM2 Status Detection
get_pm2_status() {
    if ! command_exists pm2 || ! command_exists node; then
        echo "not_installed"
        return
    fi
    
    local status
    status=$(pm2 jlist 2>/dev/null | node -e "
        let data = '';
        process.stdin.on('data', chunk => data += chunk);
        process.stdin.on('end', () => {
            try {
                let json = JSON.parse(data);
                let app = json.find(x => x.name === '$APP_NAME' || x.name === 'Jtg' || x.name === 'ecosystem');
                if (app) console.log(app.pm2_env.status);
                else console.log('not_found');
            } catch(e) { console.log('error'); }
        });
    " 2>/dev/null)
    echo "${status:-not_found}"
}

# Dynamic System & Service Info Gathering
get_sys_info() {
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
        [ -z "$OS_NAME" ] && OS_NAME=$(grep -E '^NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
    else
        OS_NAME="Linux Server"
    fi
    [ -z "$OS_NAME" ] && OS_NAME="Unknown OS"
    
    UPTIME_VAL=$(uptime -p 2>/dev/null | sed 's/^up //')
    [ -z "$UPTIME_VAL" ] && UPTIME_VAL="N/A"

    if command_exists pm2; then
        PM2_VAL="Online"
        local pm2_stat
        pm2_stat=$(get_pm2_status)
        case "$pm2_stat" in
            online)    PANEL_VAL="● Running" ;;
            stopped)   PANEL_VAL="● Stopped" ;;
            errored)   PANEL_VAL="● Errored" ;;
            not_found) PANEL_VAL="● Not Active" ;;
            *)         PANEL_VAL="● Unknown Error" ;;
        esac
    else
        PM2_VAL="Offline"
        PANEL_VAL="Not Installed"
    fi

    if command_exists cloudflared; then
        if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
            CF_VAL="● Active & Tunneling"
        else
            CF_VAL="● Installed (Offline)"
        fi
    else
        CF_VAL="● Not Installed"
    fi
}

# Cloudflare Architecture Binary Installer
install_cloudflared_binary() {
    local arch cf_arch
    arch=$(uname -m)
    case "$arch" in
        x86_64) cf_arch="amd64" ;;
        aarch64|arm64) cf_arch="arm64" ;;
        armv7l|armhf) cf_arch="arm" ;;
        *) cf_arch="amd64" ;;
    esac

    if command_exists dpkg; then
        curl -sL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}.deb" -o /tmp/cloudflared.deb >/dev/null 2>&1
        sudo dpkg -i /tmp/cloudflared.deb >/dev/null 2>&1
        rm -f /tmp/cloudflared.deb
    else
        curl -sL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" -o /usr/local/bin/cloudflared >/dev/null 2>&1
        chmod +x /usr/local/bin/cloudflared
    fi
}

# ---------------------------------------------------------
# UI Screens
# ---------------------------------------------------------
show_loading_screens() {
    clear
    echo -e "\n\n"
    echo -e " ${CYAN}${BOLD}INITIALIZING JTG PANEL ${PANEL_VERSION}...${NC}"
    echo -e " ${GRAY}──────────────────────────────────────────────────${NC}"
    echo -ne " ["
    for i in {1..50}; do
        echo -ne "${BLUE}█${NC}"
        sleep 0.02
    done
    echo -e "${GRAY}]${NC}"
    echo -e " ${GREEN}✓ System Modules Fully Loaded.${NC}"
    sleep 0.4
}

show_main_menu() {
    get_sys_info
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}JTG PANEL ${PANEL_VERSION} Installer${NC}${CYAN}                            │${NC}"
    echo -e "${CYAN}│ ${DIM}Made by Jishnu • Edit by MrZetrix${NC}${CYAN}                │${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} %-14s : ${WHITE}%-29s${NC} ${CYAN}│${NC}\n" "System OS" "${OS_NAME:0:29}"
    printf "${CYAN}│${NC} %-14s : ${WHITE}%-29s${NC} ${CYAN}│${NC}\n" "Uptime" "${UPTIME_VAL:0:29}"
    
    # Colored dynamic statuses
    if [[ "$PM2_VAL" == "Online" ]]; then
        printf "${CYAN}│${NC} %-14s : ${GREEN}%-29s${NC} ${CYAN}│${NC}\n" "PM2 Status" "$PM2_VAL"
    else
        printf "${CYAN}│${NC} %-14s : ${RED}%-29s${NC} ${CYAN}│${NC}\n" "PM2 Status" "$PM2_VAL"
    fi

    if [[ "$PANEL_VAL" == *"Running"* ]]; then
        printf "${CYAN}│${NC} %-14s : ${GREEN}%-29s${NC} ${CYAN}│${NC}\n" "Panel Status" "$PANEL_VAL"
    elif [[ "$PANEL_VAL" == *"Stopped"* ]]; then
        printf "${CYAN}│${NC} %-14s : ${YELLOW}%-29s${NC} ${CYAN}│${NC}\n" "Panel Status" "$PANEL_VAL"
    else
        printf "${CYAN}│${NC} %-14s : ${GRAY}%-29s${NC} ${CYAN}│${NC}\n" "Panel Status" "$PANEL_VAL"
    fi

    if [[ "$CF_VAL" == *"Active"* ]]; then
        printf "${CYAN}│${NC} %-14s : ${GREEN}%-29s${NC} ${CYAN}│${NC}\n" "CF Tunnel" "$CF_VAL"
    else
        printf "${CYAN}│${NC} %-14s : ${RED}%-29s${NC} ${CYAN}│${NC}\n" "CF Tunnel" "$CF_VAL"
    fi

    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[1]${NC} Install JTG Panel ${PANEL_VERSION}                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[2]${NC} Update Panel & Packages                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[3]${NC} Panel Power Control (Start/Stop/Restart)    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[4]${NC} Cloudflare Tunnel Manager                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${MAGENTA}[5]${NC} Add / Create Admin User                     ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}[A]${NC} Environment Setup ${DIM}(VPS Prep & Node.js)${NC}      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}[B]${NC} Smart Repair ${DIM}(DPKG, Lock & Cache Fix)${NC}       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${RED}[C]${NC} Uninstall Panel System                      ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
    echo -e " ${RED}[0] Exit Terminal${NC}\n"
}

# ---------------------------------------------------------
# Feature Modules
# ---------------------------------------------------------
install_panel() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}JTG PANEL ${PANEL_VERSION} INSTALLATION${NC}${CYAN}                    │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        echo -e "${CYAN}➔${NC} Directory exists. Pulling latest repository updates..."
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
        echo -e " [${GREEN}✓${NC}] Repository updated."
    else
        echo -e "${CYAN}➔${NC} Cloning JTG Panel core repository..."
        git clone "$GIT_REPO" "$PANEL_DIR" >/dev/null 2>&1 & spinner $!
        if [ ! -d "$PANEL_DIR" ]; then
            echo -e "\n [${RED}✘${NC}] Git clone failed! Please check network connection."
            sleep 2.5
            return
        fi
        cd "$PANEL_DIR" || return
        echo -e " [${GREEN}✓${NC}] Repository cloned successfully."
    fi

    echo -e "\n${CYAN}➔${NC} Installing NPM dependencies..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Dependencies installed."

    echo -e "\n${YELLOW}➔ Admin Setup Required:${NC}"
    echo -e " ${DIM}(Follow prompts to configure primary admin user)${NC}"
    npm run createuser
    echo -e " [${GREEN}✓${NC}] Admin setup complete.\n"

    echo -e "${CYAN}➔${NC} Building Panel Assets..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Production build compiled."

    echo -e "\n${CYAN}➔${NC} Starting Panel via PM2 Engine..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1
    echo -e " [${GREEN}✓${NC}] PM2 process saved and online.\n"

    cd .. 2>/dev/null || true
    echo -e " ${GREEN}${BOLD}★ Installation Complete! JTG Panel ${PANEL_VERSION} is active. ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return to main menu...${NC}"
    read -r
}

add_admin_user() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}CREATE ADMIN USER${NC}${CYAN}                               │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e " ${RED}Error: Panel is not installed yet! Install it first.${NC}"
        sleep 2
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e "${YELLOW}➔ Creating New Admin User Account:${NC}\n"
    npm run createuser
    cd .. 2>/dev/null || true

    echo -e "\n ${GREEN}${BOLD}★ Admin User created/updated successfully! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

cloudflare_zone() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│ ${BOLD}${WHITE}CLOUDFLARE TUNNEL MANAGER${NC}${CYAN}                        │${NC}"
        echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
        echo -e " Current Status: ${CF_VAL}\n"
        echo -e " ${GREEN}[1]${NC} Setup / Link Cloudflare Tunnel Token"
        echo -e " ${RED}[2]${NC} Remove / Uninstall Cloudflare Tunnel"
        echo -e " ${GRAY}[0]${NC} Back to Main Menu\n"
        echo -ne " ${CYAN}➔ Select Option:${NC} "
        read -r cf_opt

        case "$cf_opt" in
            1)
                clear
                echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
                echo -e "${CYAN}│ ${BOLD}${WHITE}CLOUDFLARE TOKEN CONNECT${NC}${CYAN}                         │${NC}"
                echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"
                
                if ! command_exists cloudflared; then
                    echo -e "${CYAN}➔${NC} Downloading & installing cloudflared..."
                    install_cloudflared_binary & spinner $!
                    if ! command_exists cloudflared; then
                        echo -e " [${RED}✘${NC}] Failed to install Cloudflare binary!"
                        sleep 2
                        continue
                    fi
                    echo -e " [${GREEN}✓${NC}] Cloudflared installed successfully.\n"
                fi

                echo -e "${YELLOW}Please paste your Cloudflare Tunnel Token below:${NC}"
                echo -e "${DIM}(Dashboard > Zero Trust > Networks > Tunnels)${NC}\n"
                echo -ne " ${CYAN}➔ Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "\n ${RED}[Error] Token cannot be empty. Operation cancelled!${NC}"
                    sleep 2
                    continue
                fi

                echo -e "\n${CYAN}➔${NC} Cleaning old tunnel services..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sleep 1

                echo -e "${CYAN}➔${NC} Registering Cloudflare Tunnel service..."
                (sudo cloudflared service install "$cf_token" >/dev/null 2>&1) & spinner $!

                echo -e "${CYAN}➔${NC} Enabling and starting background service..."
                sudo systemctl daemon-reload >/dev/null 2>&1
                sudo systemctl enable --now cloudflared >/dev/null 2>&1
                sleep 1.5

                if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
                    echo -e "\n ${GREEN}${BOLD}★ Cloudflare Tunnel Active & Protected! ★${NC}"
                else
                    echo -e "\n ${RED}${BOLD}✘ Tunnel failed to activate. Verify your token.${NC}"
                fi
                echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            2)
                echo -e "\n${CYAN}➔${NC} Purging Cloudflare Tunnel Service..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sudo apt-get remove --purge -y cloudflared >/dev/null 2>&1 & spinner $!
                echo -e " [${GREEN}✓${NC}] Cloudflare completely removed."
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e " ${RED}Invalid selection.${NC}"; sleep 1 ;;
        esac
    done
}

panel_system_menu() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│ ${BOLD}${WHITE}PANEL POWER CONTROLLER${NC}${CYAN}                           │${NC}"
        echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
        echo -e " Current Status: ${PANEL_VAL}\n"
        echo -e " ${GREEN}[1]${NC} Start Panel"
        echo -e " ${YELLOW}[2]${NC} Restart Panel"
        echo -e " ${RED}[3]${NC} Stop Panel"
        echo -e " ${GRAY}[0]${NC} Back to Main Menu\n"
        echo -ne " ${CYAN}➔ Select Action:${NC} "
        read -r sys_opt

        case "$sys_opt" in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e "\n ${RED}Error: Panel not installed yet!${NC}"
                    sleep 1.5
                    continue
                fi
                cd "$PANEL_DIR" || continue
                echo -e "\n${CYAN}➔${NC} Starting Panel..."
                if [ -f "ecosystem.config.cjs" ]; then
                    pm2 start ecosystem.config.cjs >/dev/null 2>&1
                else
                    pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
                fi
                pm2 save >/dev/null 2>&1
                cd .. 2>/dev/null || true
                echo -e " ${GREEN}★ Panel started successfully!${NC}"
                sleep 1.5
                ;;
            2)
                if command_exists pm2; then
                    echo -e "\n${CYAN}➔${NC} Restarting Panel..."
                    pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 restart Jtg >/dev/null 2>&1
                    echo -e " ${GREEN}★ Panel restarted successfully!${NC}"
                else
                    echo -e "\n ${RED}PM2 is not installed!${NC}"
                fi
                sleep 1.5
                ;;
            3)
                if command_exists pm2; then
                    echo -e "\n${CYAN}➔${NC} Stopping Panel..."
                    pm2 stop "$APP_NAME" >/dev/null 2>&1 || pm2 stop Jtg >/dev/null 2>&1
                    echo -e " ${RED}★ Panel stopped!${NC}"
                else
                    echo -e "\n ${RED}PM2 is not installed!${NC}"
                fi
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e " ${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

run_setup_1() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}ENVIRONMENT SETUP (SETUP A)${NC}${CYAN}                      │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e "${CYAN}➔${NC} Updating APT package repositories..."
    sudo apt-get update -y >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Repositories updated."

    echo -e "\n${CYAN}➔${NC} Upgrading system core dependencies..."
    sudo apt-get upgrade -y >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Packages upgraded."

    echo -e "\n${CYAN}➔${NC} Installing Git, Curl, Build essential tools..."
    sudo apt-get install -y git curl build-essential >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Core packages ready."

    echo -e "\n${CYAN}➔${NC} Installing Node.js 20.x runtime engine..."
    ( curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1 && sudo apt-get install -y nodejs >/dev/null 2>&1 ) & spinner $!
    echo -e " [${GREEN}✓${NC}] Node.js $(node -v 2>/dev/null) installed."

    echo -e "\n${CYAN}➔${NC} Installing PM2 Process Manager globally..."
    sudo npm install -g pm2 >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] PM2 engine online.\n"

    echo -e " ${GREEN}${BOLD}★ VPS Environment Preparation Complete! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

run_setup_2() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}SMART REPAIR & UNLOCK (SETUP B)${NC}${CYAN}                  │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e "${CYAN}➔${NC} Clearing DPKG and APT package locks..."
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a >/dev/null 2>&1
    echo -e " [${GREEN}✓${NC}] Locks unlocked."

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "\n ${RED}Panel directory ($PANEL_DIR) not found. Skipping NPM repair.${NC}"
        echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
        read -r
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e "\n${CYAN}➔${NC} Purging corrupted modules & cache..."
    rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null
    rm -rf node_modules 2>/dev/null
    npm cache clean --force >/dev/null 2>&1
    echo -e " [${GREEN}✓${NC}] NPM cache wiped."

    echo -e "\n${CYAN}➔${NC} Rebuilding NPM dependencies cleanly..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] Clean dependencies installed."

    echo -e "\n${CYAN}➔${NC} Recompiling application..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e " [${GREEN}✓${NC}] App rebuilt."

    echo -e "\n${CYAN}➔${NC} Restarting PM2 process..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 start ecosystem.config.cjs >/dev/null 2>&1
        pm2 save >/dev/null 2>&1
    fi
    cd .. 2>/dev/null || true
    echo -e " [${GREEN}✓${NC}] Services restored.\n"

    echo -e " ${GREEN}${BOLD}★ System Successfully Repaired! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

update_manual() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${BOLD}${WHITE}SYSTEM MANUAL UPDATE${NC}${CYAN}                             │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e " ${RED}Error: Panel is not installed yet!${NC}"
        sleep 2
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e "${CYAN}➔${NC} Syncing repository with GitHub..."
    (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
    echo -e " [${GREEN}✓${NC}] Git sync complete."

    echo -e "\n${CYAN}➔${NC} Rebuilding packages..."
    (npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1) & spinner $!
    echo -e " [${GREEN}✓${NC}] Build updated."

    echo -e "\n${CYAN}➔${NC} Restarting Panel Engine..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1
    fi
    cd .. 2>/dev/null || true
    echo -e " [${GREEN}✓${NC}] Services restarted.\n"

    echo -e " ${GREEN}${BOLD}★ Update Complete! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

uninstall_panel() {
    clear
    echo -e "${RED}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}│ ${BOLD}${WHITE}SYSTEM PURGE${NC}${RED}                                     │${NC}"
    echo -e "${RED}╰──────────────────────────────────────────────────╯${NC}\n"
    echo -e " ${RED}${BOLD}⚠️ WARNING: THIS WILL COMPLETELY PURGE THE JTG PANEL!${NC}\n"
    echo -ne " ${YELLOW}Are you sure you want to proceed? [Y/N]: ${NC}"
    read -r confirm

    case "$confirm" in
        [Yy]*)
            echo -e "\n${CYAN}➔${NC} Terminating PM2 processes..."
            if command_exists pm2; then
                pm2 stop "$APP_NAME" >/dev/null 2>&1
                pm2 delete "$APP_NAME" >/dev/null 2>&1
                pm2 save --force >/dev/null 2>&1
            fi
            echo -e " [${GREEN}✓${NC}] PM2 processes terminated."

            echo -e "\n${CYAN}➔${NC} Removing panel files ($PANEL_DIR)..."
            rm -rf "$PANEL_DIR"
            echo -e " [${GREEN}✓${NC}] Panel files completely removed."
            echo -e "\n ${GREEN}${BOLD}★ System Purge Complete! ★${NC}"
            ;;
        [Nn]*)
            echo -e "\n ${GREEN}Operation cancelled.${NC}"
            ;;
        *)
            echo -e "\n ${RED}Invalid entry. Aborting operation.${NC}"
            ;;
    esac
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ---------------------------------------------------------
# Execution Flow
# ---------------------------------------------------------
show_loading_screens

while true; do
    show_main_menu
    echo -ne " ${CYAN}➔ Enter Option:${NC} "
    read -r user_choice

    case "$user_choice" in
        1) install_panel ;;
        2) update_manual ;;
        3) panel_system_menu ;;
        4) cloudflare_zone ;;
        5) add_admin_user ;;
        A|a) run_setup_1 ;;
        B|b) run_setup_2 ;;
        C|c) uninstall_panel ;;
        0)
            echo -e "\n ${GREEN}Exiting JTG Panel Terminal Interface. Goodbye!${NC}\n"
            tput cnorm 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n ${RED}Invalid option selected.${NC}"
            sleep 1
            ;;
    esac
done
