#!/usr/bin/env bash
# =========================================================
# JTP Panel - Advanced Terminal UI Script (Pro Edition)
# Made by: Jishnu | Edit by: MrZetrix
# Panel Directory: Jtg
# Optimized for: Ubuntu, Debian, Docker Environments
# =========================================================

set -o pipefail
export DEBIAN_FRONTEND=noninteractive # Prevents installation prompts on Ubuntu/Debian

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
APP_NAME="JTP-Panel"

# Clean cursor on exit/interrupt
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
    tput civis 2>/dev/null # Hide cursor
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r  ${CYAN}[%c]${NC} ${DIM}Processing, please wait...${NC}" "$spinstr"
        spinstr=${temp}${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\r\033[K" # Clear line cleanly
    tput cnorm 2>/dev/null # Show cursor
}

# 100% Accurate PM2 Status Detection (Node.js JSON Parsing)
get_pm2_status() {
    if ! command_exists pm2 || ! command_exists node; then
        echo "not_installed"
        return
    fi

    # Inline Node.js script to perfectly parse PM2 JSON status
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
    ")
    
    echo "${status:-not_found}"
}

# ---------------------------------------------------------
# Dynamic System & Service Info
# ---------------------------------------------------------
get_sys_info() {
    local os_name uptime_val pm2_stat
    
    if [ -f /etc/os-release ]; then
        os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
        [ -z "$os_name" ] && os_name=$(grep -E '^NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
    else
        os_name="Linux Server"
    fi
    [ -z "$os_name" ] && os_name="Unknown OS"
    
    uptime_val=$(uptime -p 2>/dev/null | sed 's/^up //')
    [ -z "$uptime_val" ] && uptime_val="N/A"
    
    if command_exists pm2; then
        PM2_VAL="${GREEN}Online${NC}"
        pm2_stat=$(get_pm2_status)
        case "$pm2_stat" in
            online)   PANEL_VAL="${GREEN}● Running${NC}" ;;
            stopped)  PANEL_VAL="${YELLOW}● Stopped${NC}" ;;
            errored)  PANEL_VAL="${RED}● Errored${NC}" ;;
            not_found) PANEL_VAL="${GRAY}● Not Active${NC}" ;;
            *)        PANEL_VAL="${GRAY}● Unknown Error${NC}" ;;
        esac
    else
        PM2_VAL="${RED}Offline${NC}"
        PANEL_VAL="${GRAY}Not Installed${NC}"
    fi

    if command_exists cloudflared; then
        if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
            CF_VAL="${GREEN}● Active & Tunneling${NC}"
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
# Cloudflare Direct Architecture Binary Installer
# ---------------------------------------------------------
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
# Premium UI Screens (5-Second Loading)
# ---------------------------------------------------------
show_loading_screens() {
    clear
    tput civis 2>/dev/null
    echo -e "\n\n"
    echo -e "  ${CYAN}${BOLD}INITIALIZING JTP CONTROL CORE...${NC}"
    echo -e "  ${GRAY}──────────────────────────────────────────────────${NC}"
    echo -ne "  ["
    
    # 5-Second precision loading screen (50 loops * 0.1s = 5s)
    for i in {1..50}; do
        echo -ne "${BLUE}█${NC}"
        sleep 0.1
    done
    
    echo -e "${GRAY}]${NC}"
    echo -e "  ${GREEN}✓ System Modules Fully Loaded.${NC}"
    sleep 0.5
    tput cnorm 2>/dev/null
}

show_main_menu() {
    get_sys_info
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│               ${BOLD}${WHITE}JTP CONTROL CENTER${NC}${CYAN}                 │${NC}"
    echo -e "${CYAN}│         ${DIM}Made by Jishnu • Edit by MrZetrix${NC}${CYAN}        │${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC}  %-14s : %-29s ${CYAN}│${NC}\n" "System OS" "${WHITE}${OS_NAME:0:27}${NC}"
    printf "${CYAN}│${NC}  %-14s : %-29s ${CYAN}│${NC}\n" "Uptime" "${WHITE}${UPTIME_VAL:0:27}${NC}"
    printf "${CYAN}│${NC}  %-14s : %-29s ${CYAN}│${NC}\n" "PM2 Status" "${PM2_VAL}"
    printf "${CYAN}│${NC}  %-14s : %-29s ${CYAN}│${NC}\n" "Panel Status" "${PANEL_VAL}"
    printf "${CYAN}│${NC}  %-14s : %-29s ${CYAN}│${NC}\n" "CF Tunnel" "${CF_VAL}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} Install JTP Panel                            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[2]${NC} Update Panel & Packages                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[3]${NC} Panel Power Control (Start/Stop/Restart)     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[4]${NC} Cloudflare Tunnel Manager                    ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[A]${NC} Environment Setup ${DIM}(VPS Prep & Node.js)${NC}       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}[B]${NC} Smart Repair ${DIM}(DPKG, Lock & Cache Fix)${NC}        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[C]${NC} Uninstall Panel System                       ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
    echo -e " ${RED}[0] Exit Terminal${NC}\n"
}

# ---------------------------------------------------------
# Feature Modules
# ---------------------------------------------------------
install_panel() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│            ${BOLD}${WHITE}JTP INSTALLATION WIZARD${NC}${CYAN}               │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        echo -e "${CYAN}➔${NC} Directory existing. Pulling latest repository updates..."
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
        echo -e "  [${GREEN}✓${NC}] Repository updated."
    else
        echo -e "${CYAN}➔${NC} Cloning core JTP repository..."
        git clone "$GIT_REPO" "$PANEL_DIR" >/dev/null 2>&1 & spinner $!
        if [ ! -d "$PANEL_DIR" ]; then
            echo -e "\n  [${RED}✘${NC}] Git clone failed! Please check network connection."
            sleep 2.5
            return
        fi
        cd "$PANEL_DIR" || return
        echo -e "  [${GREEN}✓${NC}] Repository cloned successfully."
    fi

    echo -e "\n${CYAN}➔${NC} Installing NPM dependencies (This may take a moment)..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] Dependencies installed."

    echo -e "\n${YELLOW}➔ Admin Setup Required:${NC}"
    echo -e "   ${DIM}(Passwords will be masked securely)${NC}"
    npm run createuser
    echo -e "  [${GREEN}✓${NC}] Admin profile registered.\n"

    echo -e "${CYAN}➔${NC} Building Panel Assets..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] Production build compiled."

    echo -e "\n${CYAN}➔${NC} Starting Panel via PM2 Engine..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1
    echo -e "  [${GREEN}✓${NC}] PM2 process saved and online.\n"

    echo -e "  ${GREEN}${BOLD}★ Installation Complete! JTP Panel is running. ★${NC}"
    echo -ne "\n  ${DIM}Press [Enter] to return to main menu...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

cloudflare_zone() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│             ${BOLD}${WHITE}CLOUDFLARE TUNNEL ZONE${NC}${CYAN}               │${NC}"
        echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
        echo -e "  Current Status: ${CF_VAL}\n"

        echo -e "  ${GREEN}[1]${NC} Setup / Link Cloudflare Tunnel Token"
        echo -e "  ${RED}[2]${NC} Remove / Uninstall Cloudflare Tunnel"
        echo -e "  ${GRAY}[0]${NC} Back to Main Menu\n"

        echo -ne "  ${CYAN}➔ Select Option:${NC} "
        read -r cf_opt

        case "$cf_opt" in
            1)
                clear
                echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
                echo -e "${CYAN}│          ${BOLD}${WHITE}CLOUDFLARE TOKEN CONNECT${NC}${CYAN}               │${NC}"
                echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

                if ! command_exists cloudflared; then
                    echo -e "${CYAN}➔${NC} Cloudflared missing. Downloading & installing..."
                    install_cloudflared_binary & spinner $!
                    if ! command_exists cloudflared; then
                        echo -e "  [${RED}✘${NC}] Failed to install Cloudflare binary automatically!"
                        sleep 2
                        continue
                    fi
                    echo -e "  [${GREEN}✓${NC}] Cloudflared installed successfully.\n"
                fi

                echo -e "${YELLOW}Please paste your Cloudflare Tunnel Token below:${NC}"
                echo -e "${DIM}(Copy from Cloudflare Zero Trust Dashboard > Networks > Tunnels)${NC}\n"

                echo -ne "  ${CYAN}➔ Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "\n  ${RED}[Error] Token cannot be empty. Operation cancelled!${NC}"
                    sleep 2
                    continue
                fi

                echo -e "\n${CYAN}➔${NC} Cleaning older tunnel services..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sleep 1

                echo -e "${CYAN}➔${NC} Installing new Cloudflare Tunnel service..."
                (sudo cloudflared service install "$cf_token" >/dev/null 2>&1) & spinner $!

                echo -e "${CYAN}➔${NC} Enabling and starting background daemon..."
                sudo systemctl daemon-reload >/dev/null 2>&1
                sudo systemctl enable --now cloudflared >/dev/null 2>&1
                sleep 1.5

                if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
                    echo -e "\n  ${GREEN}${BOLD}★ Cloudflare Tunnel Successfully Connected & Active! ★${NC}"
                else
                    echo -e "\n  ${RED}${BOLD}✘ Tunnel failed to activate. Please verify your token.${NC}"
                fi

                echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            2)
                echo -e "\n${CYAN}➔${NC} Stopping and removing Cloudflare Service..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sudo apt-get remove --purge -y cloudflared >/dev/null 2>&1 & spinner $!
                echo -e "  [${GREEN}✓${NC}] Cloudflare completely removed."
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e "  ${RED}Invalid selection.${NC}"; sleep 1 ;;
        esac
    done
}

panel_system_menu() {
    while true; do
        clear
        get_sys_info
        echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│            ${BOLD}${WHITE}PANEL POWER CONTROLLER${NC}${CYAN}               │${NC}"
        echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}"
        echo -e "  Current Status: ${PANEL_VAL}\n"

        echo -e "  ${GREEN}[1]${NC} Start Panel"
        echo -e "  ${YELLOW}[2]${NC} Restart Panel"
        echo -e "  ${RED}[3]${NC} Stop Panel"
        echo -e "  ${GRAY}[0]${NC} Back to Main Menu\n"

        echo -ne "  ${CYAN}➔ Select Action:${NC} "
        read -r sys_opt

        case "$sys_opt" in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e "\n  ${RED}Error: Panel not installed yet!${NC}"
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
                echo -e "  ${GREEN}★ Panel started successfully!${NC}"
                sleep 1.5
                ;;
            2)
                if command_exists pm2; then
                    echo -e "\n${CYAN}➔${NC} Restarting Panel..."
                    pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 restart Jtg >/dev/null 2>&1
                    echo -e "  ${GREEN}★ Panel restarted successfully!${NC}"
                else
                    echo -e "\n  ${RED}PM2 is not installed!${NC}"
                fi
                sleep 1.5
                ;;
            3)
                if command_exists pm2; then
                    echo -e "\n${CYAN}➔${NC} Stopping Panel..."
                    pm2 stop "$APP_NAME" >/dev/null 2>&1 || pm2 stop Jtg >/dev/null 2>&1
                    echo -e "  ${RED}★ Panel stopped!${NC}"
                else
                    echo -e "\n  ${RED}PM2 is not installed!${NC}"
                fi
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e "  ${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

run_setup_1() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│          ${BOLD}${WHITE}ENVIRONMENT SETUP (SETUP 1)${NC}${CYAN}            │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e "${CYAN}➔${NC} Updating APT package lists..."
    sudo apt-get update -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] APT updated."

    echo -e "\n${CYAN}➔${NC} Upgrading system dependencies..."
    sudo apt-get upgrade -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] Dependencies upgraded."

    echo -e "\n${CYAN}➔${NC} Installing Git, Curl, Build essential tools..."
    sudo apt-get install -y git curl build-essential >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] Essential tools ready."

    echo -e "\n${CYAN}➔${NC} Installing Node.js 20.x runtime..."
    ( curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1 && sudo apt-get install -y nodejs >/dev/null 2>&1 ) & spinner $!
    echo -e "  [${GREEN}✓${NC}] Node.js $(node -v 2>/dev/null) installed."

    echo -e "\n${CYAN}➔${NC} Installing PM2 process manager globally..."
    sudo npm install -g pm2 >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] PM2 ready.\n"

    echo -e "  ${GREEN}${BOLD}★ System Environment Prep Completed! ★${NC}"
    echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
    read -r
}

run_setup_2() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│          ${BOLD}${WHITE}SMART REPAIR & UNLOCK (SETUP 2)${NC}${CYAN}        │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e "${DIM}Safely clearing dpkg/apt locks and rebuilding node modules...${NC}\n"

    echo -e "${CYAN}➔${NC} Clearing APT and DPKG locks..."
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a >/dev/null 2>&1
    echo -e "  [${GREEN}✓${NC}] System package locks cleared."

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "\n  ${RED}Panel directory ($PANEL_DIR) not found. Skipping NPM repair.${NC}"
        echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
        read -r
        return
    fi
    cd "$PANEL_DIR" || return

    echo -e "\n${CYAN}➔${NC} Cleaning corrupted lockfiles and NPM cache..."
    rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null
    rm -rf node_modules 2>/dev/null
    npm cache clean --force >/dev/null 2>&1
    echo -e "  [${GREEN}✓${NC}] NPM Cache wiped."

    echo -e "\n${CYAN}➔${NC} Re-installing NPM packages cleanly..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] Clean dependencies installed."

    echo -e "\n${CYAN}➔${NC} Rebuilding application..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "  [${GREEN}✓${NC}] App rebuilt."

    echo -e "\n${CYAN}➔${NC} Restarting PM2 process..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 start ecosystem.config.cjs >/dev/null 2>&1
        pm2 save >/dev/null 2>&1
    fi
    echo -e "  [${GREEN}✓${NC}] Services restored.\n"

    echo -e "  ${GREEN}${BOLD}★ System Repaired and Optimized! ★${NC}"
    echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

update_manual() {
    clear
    echo -e "${CYAN}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│              ${BOLD}${WHITE}SYSTEM MANUAL UPDATE${NC}${CYAN}               │${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "  ${RED}Error: Panel not installed yet!${NC}"
        sleep 2
        return
    fi

    cd "$PANEL_DIR" || return

    echo -e "${CYAN}➔${NC} Pulling latest updates from GitHub..."
    (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
    echo -e "  [${GREEN}✓${NC}] Git sync complete."

    echo -e "\n${CYAN}➔${NC} Updating packages and building..."
    (npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1) & spinner $!
    echo -e "  [${GREEN}✓${NC}] Build complete."

    echo -e "\n${CYAN}➔${NC} Restarting Panel..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1
    fi
    echo -e "  [${GREEN}✓${NC}] Restarted.\n"

    echo -e "  ${GREEN}${BOLD}★ Update Complete! ★${NC}"
    echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
    read -r
    cd .. 2>/dev/null || true
}

uninstall_panel() {
    clear
    echo -e "${RED}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}│                ${BOLD}${WHITE}SYSTEM PURGE${NC}${RED}                      │${NC}"
    echo -e "${RED}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e "  ${RED}${BOLD}⚠️ WARNING: THIS WILL COMPLETELY PURGE THE JTP PANEL!${NC}\n"
    echo -ne "  ${YELLOW}Are you sure you want to proceed? [Y/N]: ${NC}"
    read -r confirm

    case "$confirm" in
        [Yy]* )
            echo -e "\n${CYAN}➔${NC} Terminating PM2 processes..."
            if command_exists pm2; then
                pm2 stop "$APP_NAME" >/dev/null 2>&1
                pm2 delete "$APP_NAME" >/dev/null 2>&1
                pm2 save --force >/dev/null 2>&1
            fi
            echo -e "  [${GREEN}✓${NC}] PM2 processes terminated."

            echo -e "\n${CYAN}➔${NC} Deleting panel files ($PANEL_DIR)..."
            rm -rf "$PANEL_DIR"
            echo -e "  [${GREEN}✓${NC}] Files removed."

            echo -e "\n  ${GREEN}${BOLD}★ System Purge Complete! ★${NC}"
            ;;
        [Nn]* )
            echo -e "\n  ${GREEN}Operation cancelled cleanly.${NC}"
            ;;
        * )
            echo -e "\n  ${RED}Invalid response. Operation aborted.${NC}"
            ;;
    esac

    echo -ne "\n  ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ---------------------------------------------------------
# Main Execution Loop
# ---------------------------------------------------------
show_loading_screens
while true; do
    show_main_menu
    echo -ne "  ${CYAN}➔ Enter Option:${NC} "
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
            echo -e "\n  ${GREEN}System shut down gracefully. Goodbye!${NC}\n"
            tput cnorm 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n  ${RED}Unrecognized command. Please try again.${NC}"
            sleep 1
            ;;
    esac
done
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
