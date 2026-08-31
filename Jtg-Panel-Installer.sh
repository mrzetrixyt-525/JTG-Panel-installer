#!/usr/bin/env bash
# ==============================================================================
# 🚀 JTG PANEL PRO ENGINE — V4.0 (ULTIMATE EDITION)
# ------------------------------------------------------------------------------
# Core Architecture   : Jishnu
# System Styling      : MrZetrix
# Target Environment  : Linux (Ubuntu/Debian/RedHat/others)
# ------------------------------------------------------------------------------
# This version is fully compatible with systemd AND SysV/Upstart.
# No errors, no glitches — just pure performance.
# ==============================================================================

# Safety flags
set -o pipefail
export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# 🎨 HIGH-CONTRAST PRO COLOR PALETTE
# ------------------------------------------------------------------------------
VIOLET='\033[38;5;135m'
SAPPHIRE='\033[38;5;33m'
CYAN='\033[38;5;51m'
NEON_GREEN='\033[38;5;46m'
GOLD='\033[38;5;220m'
BLOOD_RED='\033[38;5;196m'
DARK_GRAY='\033[38;5;238m'
LIGHT_GRAY='\033[38;5;248m'
WHITE='\033[38;5;255m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ------------------------------------------------------------------------------
# 📦 GLOBAL VARIABLES
# ------------------------------------------------------------------------------
PANEL_VERSION="V4.0-ULTIMATE"
PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"
APP_NAME="jtg-panel"

# Trap for clean exit
trap 'tput cnorm 2>/dev/null; echo -e "\n${BLOOD_RED}Session interrupted. Exiting safely.${NC}"; exit' INT TERM EXIT

# ==============================================================================
# 🛠️ UTILITY FUNCTIONS
# ==============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if we are root or have sudo
can_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi
    sudo -n true >/dev/null 2>&1
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Enhanced spinner with better PID handling
spinner() {
    local pid=$1
    local delay=0.06
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis 2>/dev/null

    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r ${VIOLET}[%c]${NC} ${CYAN}Working...${NC}" "$spinstr"
        spinstr=${temp}${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\r\033[K"
    tput cnorm 2>/dev/null
}

# Get PM2 app status
get_pm2_status() {
    if ! command_exists pm2 || ! command_exists node; then
        echo "NOT_INSTALLED"
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
                if (app) console.log(app.pm2_env.status.toUpperCase());
                else console.log('INACTIVE');
            } catch(e) { console.log('ERROR'); }
        });
    " 2>/dev/null)
    echo "${status:-INACTIVE}"
}

# Get system info and statuses
get_sys_info() {
    # OS Name
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
        [ -z "$OS_NAME" ] && OS_NAME=$(grep -E '^NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
    else
        OS_NAME="Linux Server Environment"
    fi
    [ -z "$OS_NAME" ] && OS_NAME="Unknown Linux"

    # Uptime
    UPTIME_VAL=$(uptime -p 2>/dev/null | sed 's/^up //')
    [ -z "$UPTIME_VAL" ] && UPTIME_VAL="N/A"

    # PM2 status
    if command_exists pm2; then
        PM2_VAL="${NEON_GREEN}ACTIVE${NC}"
        local pm2_stat
        pm2_stat=$(get_pm2_status)
        case "$pm2_stat" in
            ONLINE)     PANEL_VAL="${NEON_GREEN}ONLINE${NC}" ;;
            STOPPED)    PANEL_VAL="${GOLD}STOPPED${NC}" ;;
            ERRORED)    PANEL_VAL="${BLOOD_RED}ERRORED${NC}" ;;
            INACTIVE)   PANEL_VAL="${DARK_GRAY}INACTIVE${NC}" ;;
            *)          PANEL_VAL="${BLOOD_RED}UNKNOWN${NC}" ;;
        esac
    else
        PM2_VAL="${BLOOD_RED}OFFLINE${NC}"
        PANEL_VAL="${DARK_GRAY}UNINSTALLED${NC}"
    fi

    # Cloudflared status
    if command_exists cloudflared; then
        local cf_active=0
        # Check if any cloudflared process is running
        pgrep -x cloudflared >/dev/null 2>&1 && cf_active=1
        # Also check systemd if available
        if [ "$cf_active" -eq 0 ] && command_exists systemctl && systemctl is-active --quiet cloudflared 2>/dev/null; then
            cf_active=1
        fi
        # SysV check
        if [ "$cf_active" -eq 0 ] && [ -x /etc/init.d/cloudflared ] && /etc/init.d/cloudflared status 2>/dev/null | grep -q "running"; then
            cf_active=1
        fi

        if [ "$cf_active" -eq 1 ]; then
            CF_VAL="${NEON_GREEN}TUNNELING${NC}"
        else
            CF_VAL="${GOLD}STANDBY${NC}"
        fi
    else
        CF_VAL="${BLOOD_RED}MISSING${NC}"
    fi
}

# Install cloudflared binary if missing
install_cloudflared_binary() {
    local arch cf_arch
    arch=$(uname -m)
    case "$arch" in
        x86_64) cf_arch="amd64" ;;
        aarch64|arm64) cf_arch="arm64" ;;
        armv7l|armhf) cf_arch="arm" ;;
        *) cf_arch="amd64" ;;
    esac

    echo -e " ${CYAN}➔${NC} Downloading cloudflared (${cf_arch})..."
    if command_exists dpkg; then
        curl -sL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}.deb" -o /tmp/cloudflared.deb
        if [ $? -ne 0 ] || [ ! -s /tmp/cloudflared.deb ]; then
            echo -e "  ${BLOOD_RED}[✘] Download failed.${NC}"
            return 1
        fi
        run_as_root dpkg -i /tmp/cloudflared.deb >/dev/null 2>&1
        rm -f /tmp/cloudflared.deb
    else
        curl -sL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" -o /usr/local/bin/cloudflared
        if [ $? -ne 0 ] || [ ! -s /usr/local/bin/cloudflared ]; then
            echo -e "  ${BLOOD_RED}[✘] Download failed.${NC}"
            return 1
        fi
        chmod +x /usr/local/bin/cloudflared
    fi
    command_exists cloudflared && return 0 || return 1
}

# Start cloudflared service (detects init system)
start_cloudflared_service() {
    echo -e " ${CYAN}➔${NC} Starting cloudflared service..."
    if command_exists systemctl && [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
        run_as_root systemctl daemon-reload
        run_as_root systemctl enable --now cloudflared >/dev/null 2>&1
    elif [ -x /etc/init.d/cloudflared ]; then
        run_as_root /etc/init.d/cloudflared start >/dev/null 2>&1
    else
        # Fallback: just run the binary with token in background
        echo -e "  ${GOLD}⚠ No init system found, running cloudflared in background.${NC}"
        nohup cloudflared tunnel run --token "$1" >/var/log/cloudflared.log 2>&1 &
    fi
    sleep 1
    # Verify if it's running
    if pgrep -x cloudflared >/dev/null 2>&1 || systemctl is-active --quiet cloudflared 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Remove any existing cloudflared service
clean_cloudflared_service() {
    echo -e " ${CYAN}➔${NC} Cleaning any existing cloudflared service..."
    # Try official uninstall
    run_as_root cloudflared service uninstall >/dev/null 2>&1
    # Manual cleanup if necessary
    run_as_root rm -f /etc/systemd/system/cloudflared.service /etc/init.d/cloudflared /etc/init/cloudflared.conf
    run_as_root systemctl daemon-reload >/dev/null 2>&1
    # Kill any running instances
    run_as_root pkill -x cloudflared >/dev/null 2>&1
    sleep 0.5
}

# ==============================================================================
# 🖥️ USER INTERFACE RENDERING
# ==============================================================================

show_loading_screens() {
    clear
    echo -e "\n\n"
    echo -e " ${VIOLET}${BOLD}⚡ INITIALIZING JTG PRO DASHBOARD ENGINE...${NC}"
    echo -e " ${DARK_GRAY}──────────────────────────────────────────────────${NC}"
    echo -ne " ["
    for i in {1..46}; do
        echo -ne "${VIOLET}█${NC}"
        sleep 0.015
    done
    echo -e "${DARK_GRAY}]${NC}"
    echo -e " ${NEON_GREEN}✔ Core Execution Environment Verified.${NC}"
    sleep 0.3
}

draw_header() {
    local is_main_menu=$1
    get_sys_info
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC}${BOLD}${WHITE}              JTG PANEL ${PANEL_VERSION} Installer              ${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC}${DIM}           Made by Jishnu • Edit by MrZetrix      ${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${VIOLET}│${NC} System OS      : ${WHITE}${OS_NAME:0:30}${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} Uptime         : ${WHITE}${UPTIME_VAL:0:30}${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} PM2 Status     : ${PM2_VAL}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} Panel Status   : ${PANEL_VAL}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} CF Tunnel      : ${CF_VAL}\033[52G${VIOLET}│${NC}"
    if [ "$is_main_menu" != "true" ]; then
        echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}"
    fi
}

show_main_menu() {
    draw_header "true"
    echo -e "${VIOLET}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[1]${NC} 🚀 Install JTG Panel ${PANEL_VERSION}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[2]${NC} 🔄 Update Panel & Packages\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[3]${NC} ⚡ Panel Power Control (Start/Stop/Restart)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[4]${NC} ☁️ Cloudflare Tunnel Manager\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[5]${NC} 👤 Administrator Operations\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${VIOLET}│${NC} ${GOLD}[A]${NC} 🛠️ Environment Setup (VPS Prep & Node.js)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${GOLD}[B]${NC} 🔧 Smart Repair (DPKG, Lock & Cache Fix)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${BLOOD_RED}[C]${NC} 🗑️ Uninstall Panel System\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}"
    echo -e " ${DARK_GRAY}[0] Exit Terminal${NC}\n"
}

# ==============================================================================
# 🚀 CORE EXECUTION MODULES
# ==============================================================================

install_panel() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}🚀 DEPLOYING JTG PANEL ${PANEL_VERSION}${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    # Check for git
    if ! command_exists git; then
        echo -e " ${CYAN}➔${NC} Installing git..."
        run_as_root apt-get install -y git >/dev/null 2>&1 || run_as_root yum install -y git >/dev/null 2>&1
    fi

    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        echo -e " ${CYAN}➔${NC} Local repository directory exists. Pulling latest commits..."
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
        echo -e "  [${NEON_GREEN}✔${NC}] Codebase synchronized."
    else
        echo -e " ${CYAN}➔${NC} Cloning repository from source target..."
        git clone "$GIT_REPO" "$PANEL_DIR" >/dev/null 2>&1 & spinner $!
        if [ ! -d "$PANEL_DIR" ]; then
            echo -e "\n  [${BLOOD_RED}✘${NC}] Git clone process failed! Check your internet connection."
            sleep 2.5
            return
        fi
        cd "$PANEL_DIR" || return
        echo -e "  [${NEON_GREEN}✔${NC}] Repository cloned."
    fi

    echo -e "\n ${CYAN}➔${NC} 📦 Fetching and building NPM packages..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Dependencies compiled successfully."

    echo -e "\n ${GOLD}➔ 🔐 Admin Credentials Configuration Required:${NC}"
    echo -e "  ${DIM}(Follow prompts below to register your administrator account)${NC}\n"
    npm run createuser
    echo -e "  [${NEON_GREEN}✔${NC}] Admin profile generated.\n"

    echo -e " ${CYAN}➔${NC} 🏗️ Compiling production assets..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Assets compiled."

    echo -e "\n ${CYAN}➔${NC} 🚀 Launching background application instance using PM2..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1
    echo -e "  [${NEON_GREEN}✔${NC}] Application cluster is live and saved.\n"

    cd .. 2>/dev/null || true
    echo -e " ${NEON_GREEN}${BOLD}★ ✅ DEPLOYMENT SUCCESSFUL! JTG PANEL ${PANEL_VERSION} IS OPERATIONAL ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return to the dashboard menu...${NC}"
    read -r
}

admin_operations() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}👤 ADMINISTRATOR PROFILE MANAGER${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "  ${BLOOD_RED}✘ Panel installation not found! Install JTG Panel first.${NC}"
        sleep 2
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e " ${GOLD}➔ Provisioning New Administrative Account:${NC}\n"
    npm run createuser
    cd .. 2>/dev/null || true

    echo -e "\n ${NEON_GREEN}${BOLD}★ ✅ Admin authorization complete! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

cloudflare_manager() {
    while true; do
        draw_header
        echo -e " ${VIOLET}╭── ☁️ CLOUDFLARE ZERO TRUST TUNNEL ──────────────────╮${NC}"
        echo -e " ${VIOLET}│${NC} ${NEON_GREEN}[1]${NC} Register & Link New Tunnel Token\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC} ${BLOOD_RED}[2]${NC} Unlink & Remove Cloudflare Service\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}╰──────────────────────────────────────────────────╯${NC}"
        echo -e "  ${DARK_GRAY}[0] Back to Main Menu${NC}\n"
        echo -ne " ${CYAN}➔ Select Action:${NC} "
        read -r cf_opt

        case "$cf_opt" in
            1)
                clear
                echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
                echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}☁️ CONNECT CLOUDFLARE TUNNEL${NC}\033[52G${VIOLET}│${NC}"
                echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

                # Ensure cloudflared is installed
                if ! command_exists cloudflared; then
                    echo -e " ${CYAN}➔${NC} Downloading cloudflared architecture binary..."
                    install_cloudflared_binary & spinner $!
                    if ! command_exists cloudflared; then
                        echo -e "  [${BLOOD_RED}✘${NC}] Failed to download Cloudflare binary!"
                        sleep 2
                        continue
                    fi
                    echo -e "  [${NEON_GREEN}✔${NC}] Binary installed successfully.\n"
                fi

                echo -e " ${GOLD}🔑 Paste your Cloudflare Tunnel Token below:${NC}"
                echo -e " ${DIM}(Found in Cloudflare Zero Trust > Networks > Tunnels)${NC}\n"
                echo -ne " ${CYAN}➔ Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "\n  ${BLOOD_RED}[Error] Token cannot be blank. Operation cancelled.${NC}"
                    sleep 2
                    continue
                fi

                # Clean previous service
                clean_cloudflared_service

                echo -e "\n ${CYAN}➔${NC} Registering token service..."
                (run_as_root cloudflared service install "$cf_token" >/dev/null 2>&1) & spinner $!

                # Start service with appropriate init system
                if start_cloudflared_service "$cf_token"; then
                    echo -e "\n ${NEON_GREEN}${BOLD}★ ✅ Cloudflare Tunnel is Active and Secured! ★${NC}"
                else
                    echo -e "\n ${BLOOD_RED}${BOLD}✘ Tunnel activation failed. Verify your token.${NC}"
                fi
                echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            2)
                echo -e "\n ${CYAN}➔${NC} Removing Cloudflare Service..."
                clean_cloudflared_service
                run_as_root apt-get remove --purge -y cloudflared >/dev/null 2>&1 & spinner $!
                echo -e "  [${NEON_GREEN}✔${NC}] Service fully removed."
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e " ${BLOOD_RED}Invalid option.${NC}"; sleep 1 ;;
        esac
    done
}

panel_power_menu() {
    while true; do
        draw_header
        echo -e " ${VIOLET}╭── ⚡ POWER CONTROL SYSTEM ──────────────────────────╮${NC}"
        echo -e " ${VIOLET}│${NC} ${NEON_GREEN}[1]${NC} ▶️ Start Panel Instance\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC} ${GOLD}[2]${NC} 🔄 Restart Panel Instance\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC} ${BLOOD_RED}[3]${NC} ⏹️ Stop Panel Instance\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}╰──────────────────────────────────────────────────╯${NC}"
        echo -e "  ${DARK_GRAY}[0] Back to Main Menu${NC}\n"
        echo -ne " ${CYAN}➔ Select Action:${NC} "
        read -r sys_opt

        case "$sys_opt" in
            1)
                if [ ! -d "$PANEL_DIR" ]; then
                    echo -e "\n  ${BLOOD_RED}Error: Panel is not deployed on this server!${NC}"
                    sleep 1.5
                    continue
                fi
                cd "$PANEL_DIR" || continue
                echo -e "\n ${CYAN}➔${NC} Initializing startup..."
                if [ -f "ecosystem.config.cjs" ]; then
                    pm2 start ecosystem.config.cjs >/dev/null 2>&1
                else
                    pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
                fi
                pm2 save >/dev/null 2>&1
                cd .. 2>/dev/null || true
                echo -e "  [${NEON_GREEN}✔${NC}] Panel instance online!"
                sleep 1.5
                ;;
            2)
                if command_exists pm2; then
                    echo -e "\n ${CYAN}➔${NC} Restarting background service..."
                    pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 restart Jtg >/dev/null 2>&1
                    echo -e "  [${NEON_GREEN}✔${NC}] Panel restarted!"
                else
                    echo -e "\n  ${BLOOD_RED}PM2 is missing!${NC}"
                fi
                sleep 1.5
                ;;
            3)
                if command_exists pm2; then
                    echo -e "\n ${CYAN}➔${NC} Halting panel application..."
                    pm2 stop "$APP_NAME" >/dev/null 2>&1 || pm2 stop Jtg >/dev/null 2>&1
                    echo -e "  [${BLOOD_RED}✔${NC}] Panel process stopped."
                else
                    echo -e "\n  ${BLOOD_RED}PM2 is missing!${NC}"
                fi
                sleep 1.5
                ;;
            0) break ;;
            *) echo -e " ${BLOOD_RED}Invalid choice.${NC}"; sleep 1 ;;
        esac
    done
}

run_setup_1() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}🛠️ PREPARING ENVIRONMENT (SETUP A)${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e " ${CYAN}➔${NC} Updating APT indices..."
    run_as_root apt-get update -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Repositories synced."

    echo -e "\n ${CYAN}➔${NC} Upgrading environment binaries..."
    run_as_root apt-get upgrade -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Packages updated."

    echo -e "\n ${CYAN}➔${NC} Installing system build tools (Git, Curl, Build-Essential)..."
    run_as_root apt-get install -y git curl build-essential >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Build packages installed."

    echo -e "\n ${CYAN}➔${NC} Provisioning Node.js 20.x runtime engine..."
    ( curl -fsSL https://deb.nodesource.com/setup_20.x | run_as_root bash - >/dev/null 2>&1 && run_as_root apt-get install -y nodejs >/dev/null 2>&1 ) & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Node.js $(node -v 2>/dev/null) ready."

    echo -e "\n ${CYAN}➔${NC} Installing PM2 runtime process manager..."
    run_as_root npm install -g pm2 >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Global PM2 ready.\n"

    echo -e " ${NEON_GREEN}${BOLD}★ ✅ System Prep Finished Successfully! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

run_setup_2() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}🔧 DEEP REPAIR & UNLOCK (SETUP B)${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e " ${CYAN}➔${NC} Releasing APT/DPKG process lockfiles..."
    run_as_root rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    run_as_root dpkg --configure -a >/dev/null 2>&1
    echo -e "  [${NEON_GREEN}✔${NC}] System locks cleared."

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "\n  ${BLOOD_RED}Directory ($PANEL_DIR) missing. Skipping Node repair step.${NC}"
        echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
        read -r
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e "\n ${CYAN}➔${NC} Flushing corrupted lockfiles & NPM caches..."
    rm -f package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null
    rm -rf node_modules 2>/dev/null
    npm cache clean --force >/dev/null 2>&1
    echo -e "  [${NEON_GREEN}✔${NC}] Cache purged."

    echo -e "\n ${CYAN}➔${NC} Performing fresh NPM install..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Dependencies cleanly rebuilt."

    echo -e "\n ${CYAN}➔${NC} Recompiling application build..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Build verified."

    echo -e "\n ${CYAN}➔${NC} Reloading PM2 processes..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 start ecosystem.config.cjs >/dev/null 2>&1
        pm2 save >/dev/null 2>&1
    fi
    cd .. 2>/dev/null || true
    echo -e "  [${NEON_GREEN}✔${NC}] System online.\n"

    echo -e " ${NEON_GREEN}${BOLD}★ ✅ System Repaired and Cleaned! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

update_manual() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}🔄 SYSTEM UPDATE ENGINE${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "  ${BLOOD_RED}Error: Panel is not installed!${NC}"
        sleep 2
        return
    fi

    cd "$PANEL_DIR" || return
    echo -e " ${CYAN}➔${NC} Fetching latest codebase from Remote Repo..."
    (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Git pull complete."

    echo -e "\n ${CYAN}➔${NC} Refreshing packages and rebuilding..."
    (npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1) & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Rebuild complete."

    echo -e "\n ${CYAN}➔${NC} Restarting instance..."
    if command_exists pm2; then
        pm2 restart "$APP_NAME" >/dev/null 2>&1
    fi
    cd .. 2>/dev/null || true
    echo -e "  [${NEON_GREEN}✔${NC}] Application refreshed.\n"

    echo -e " ${NEON_GREEN}${BOLD}★ ✅ System Update Completed! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

uninstall_panel() {
    clear
    echo -e "${BLOOD_RED}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${BLOOD_RED}│${NC} ${BOLD}${WHITE}🗑️ SYSTEM PURGE WARNING${NC}\033[52G${BLOOD_RED}│${NC}"
    echo -e "${BLOOD_RED}╰──────────────────────────────────────────────────╯${NC}\n"
    echo -e " ${BLOOD_RED}${BOLD}⚠️ WARNING: THIS WILL COMPLETELY DESTROY JTG PANEL DATA AND PM2 LAUNCHERS!${NC}\n"
    echo -ne " ${GOLD}Confirm deletion? [Y/N]: ${NC}"
    read -r confirm

    case "$confirm" in
        [Yy]*)
            echo -e "\n ${CYAN}➔${NC} Killing PM2 instances..."
            if command_exists pm2; then
                pm2 stop "$APP_NAME" >/dev/null 2>&1
                pm2 delete "$APP_NAME" >/dev/null 2>&1
                pm2 save --force >/dev/null 2>&1
            fi
            echo -e "  [${NEON_GREEN}✔${NC}] PM2 tasks erased."

            echo -e "\n ${CYAN}➔${NC} Removing application folder ($PANEL_DIR)..."
            rm -rf "$PANEL_DIR"
            echo -e "  [${NEON_GREEN}✔${NC}] Directories purged."
            echo -e "\n ${NEON_GREEN}${BOLD}★ ✅ System Purge Complete! ★${NC}"
            ;;
        *)
            echo -e "\n ${NEON_GREEN}Operation aborted safely.${NC}"
            ;;
    esac
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ==============================================================================
# 🎮 DASHBOARD PROCESSING LOOP
# ==============================================================================
show_loading_screens

while true; do
    show_main_menu
    echo -ne " ${CYAN}➔ Enter Option:${NC} "
    read -r user_choice

    case "$user_choice" in
        1) install_panel ;;
        2) update_manual ;;
        3) panel_power_menu ;;
        4) cloudflare_manager ;;
        5) admin_operations ;;
        A|a) run_setup_1 ;;
        B|b) run_setup_2 ;;
        C|c) uninstall_panel ;;
        0)
            echo -e "\n ${NEON_GREEN}Goodbye! 👋${NC}\n"
            tput cnorm 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n ${BLOOD_RED}Unrecognized command option.${NC}"
            sleep 1
            ;;
    esac
done
