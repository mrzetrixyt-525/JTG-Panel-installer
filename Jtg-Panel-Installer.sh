#!/usr/bin/env bash
# ==============================================================================
# 🚀 JTG PANEL PRO ENGINE — V3.0 (ENTERPRISE EDITION)
# ------------------------------------------------------------------------------
# Core Architecture   : Jishnu
# System Styling      : MrZetrix
# Target Environment  : Ubuntu / Debian (Node.js 20.x Ecosystem)
# ==============================================================================

# ------------------------------------------------------------------------------
# ⚙️ SYSTEM CONFIGURATION & SAFETY FLAGS
# ------------------------------------------------------------------------------
set -o pipefail
export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# 🎨 HIGH-CONTRAST PRO COLOR PALETTE
# ------------------------------------------------------------------------------
VIOLET='\033[38;5;135m'      # Primary borders and branding
SAPPHIRE='\033[38;5;33m'     # Secondary highlights
CYAN='\033[38;5;51m'         # Input prompts and arrows
NEON_GREEN='\033[38;5;46m'   # Success indicators
GOLD='\033[38;5;220m'        # Warnings and setup prompts
BLOOD_RED='\033[38;5;196m'   # Critical errors and destructive actions
DARK_GRAY='\033[38;5;238m'   # Subtle dividers
LIGHT_GRAY='\033[38;5;248m'  # Standard text
WHITE='\033[38;5;255m'       # Emphasized text
BOLD='\033[1m'               # Bold formatting
DIM='\033[2m'                # Faded text for background info
NC='\033[0m'                 # Reset color to terminal default

# ------------------------------------------------------------------------------
# 📦 GLOBAL VARIABLES
# ------------------------------------------------------------------------------
PANEL_VERSION="V3.0-PRO"
PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"
APP_NAME="jtg-panel"

# 🛡️ Cursor Safety Trap
trap 'tput cnorm 2>/dev/null; echo -e "\n${BLOOD_RED}Session interrupted. Exiting safely.${NC}"; exit' INT TERM EXIT

# ==============================================================================
# 🛠️ UTILITY FUNCTIONS
# ==============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

spinner() {
    local pid=$1
    local delay=0.06
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis 2>/dev/null 
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r ${VIOLET}[%c]${NC} ${CYAN}Executing runtime background process...${NC}" "$spinstr"
        spinstr=${temp}${spinstr%"$temp"}
        sleep "$delay"
    done
    
    printf "\r\033[K"
    tput cnorm 2>/dev/null
}

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

get_sys_info() {
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
        [ -z "$OS_NAME" ] && OS_NAME=$(grep -E '^NAME=' /etc/os-release | cut -d '=' -f2- | tr -d '"')
    else
        OS_NAME="Linux Server Environment"
    fi
    [ -z "$OS_NAME" ] && OS_NAME="Unknown Linux"
    
    UPTIME_VAL=$(uptime -p 2>/dev/null | sed 's/^up //')
    [ -z "$UPTIME_VAL" ] && UPTIME_VAL="N/A"

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

    if command_exists cloudflared; then
        if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
            CF_VAL="${NEON_GREEN}TUNNELING${NC}"
        else
            CF_VAL="${GOLD}STANDBY${NC}"
        fi
    else
        CF_VAL="${BLOOD_RED}MISSING${NC}"
    fi
}

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
    echo -e "${VIOLET}│${NC}${BOLD}${WHITE}              JTG PANEL V3 Installer              ${NC}\033[52G${VIOLET}│${NC}"
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
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[1]${NC} Install JTG Panel V3\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[2]${NC} Update Panel & Packages\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[3]${NC} Panel Power Control (Start/Stop/Restart)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[4]${NC} Cloudflare Tunnel Manager\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${NEON_GREEN}[5]${NC} Administrator Operations\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${VIOLET}│${NC} ${GOLD}[A]${NC} Environment Setup (VPS Prep & Node.js)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${GOLD}[B]${NC} Smart Repair (DPKG, Lock & Cache Fix)\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}│${NC} ${BLOOD_RED}[C]${NC} Uninstall Panel System\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}"
    echo -e " ${DARK_GRAY}[0] Exit Terminal${NC}\n"
}

# ==============================================================================
# 🚀 CORE EXECUTION MODULES
# ==============================================================================

install_panel() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}DEPLOYING JTG PANEL ${PANEL_VERSION}${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

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

    echo -e "\n ${CYAN}➔${NC} Fetching and building NPM packages..."
    npm install >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Dependencies compiled successfully."

    echo -e "\n ${GOLD}➔ Admin Credentials Configuration Required:${NC}"
    echo -e "  ${DIM}(Follow prompts below to register your administrator account)${NC}\n"
    npm run createuser
    echo -e "  [${NEON_GREEN}✔${NC}] Admin profile generated.\n"

    echo -e " ${CYAN}➔${NC} Compiling production assets..."
    npm run build >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Assets compiled."

    echo -e "\n ${CYAN}➔${NC} Launching background application instance using PM2..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1
    echo -e "  [${NEON_GREEN}✔${NC}] Application cluster is live and saved.\n"

    cd .. 2>/dev/null || true
    echo -e " ${NEON_GREEN}${BOLD}★ DEPLOYMENT SUCCESSFUL! JTG PANEL ${PANEL_VERSION} IS OPERATIONAL ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return to the dashboard menu...${NC}"
    read -r
}

admin_operations() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}ADMINISTRATOR PROFILE MANAGER${NC}\033[52G${VIOLET}│${NC}"
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

    echo -e "\n ${NEON_GREEN}${BOLD}★ Admin authorization complete! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

cloudflare_manager() {
    while true; do
        draw_header
        echo -e " ${VIOLET}╭── CLOUDFLARE ZERO TRUST TUNNEL ──────────────────╮${NC}"
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
                echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}CONNECT CLOUDFLARE TUNNEL${NC}\033[52G${VIOLET}│${NC}"
                echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"
                
                if ! command_exists cloudflared; then
                    echo -e " ${CYAN}➔${NC} Downloading cloudflared architecture binary..."
                    install_cloudflared_binary & spinner $!
                    if ! command_exists cloudflared; then
                        echo -e "  [${BLOOD_RED}✘${NC}] Failed to download Cloudflare binary binary!"
                        sleep 2
                        continue
                    fi
                    echo -e "  [${NEON_GREEN}✔${NC}] Binary installed successfully.\n"
                fi

                echo -e " ${GOLD}Paste your Cloudflare Tunnel Token below:${NC}"
                echo -e " ${DIM}(Found in Cloudflare Zero Trust > Networks > Tunnels)${NC}\n"
                echo -ne " ${CYAN}➔ Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "\n  ${BLOOD_RED}[Error] Token cannot be blank. Operation cancelled.${NC}"
                    sleep 2
                    continue
                fi

                echo -e "\n ${CYAN}➔${NC} Terminating stale tunnel daemons..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sleep 0.8

                echo -e " ${CYAN}➔${NC} Registering token service..."
                (sudo cloudflared service install "$cf_token" >/dev/null 2>&1) & spinner $!

                echo -e " ${CYAN}➔${NC} Starting background tunnel daemon..."
                sudo systemctl daemon-reload >/dev/null 2>&1
                sudo systemctl enable --now cloudflared >/dev/null 2>&1
                sleep 1.2

                if systemctl is-active --quiet cloudflared 2>/dev/null || pgrep -x cloudflared >/dev/null 2>&1; then
                    echo -e "\n ${NEON_GREEN}${BOLD}★ Cloudflare Tunnel is Active and Secured! ★${NC}"
                else
                    echo -e "\n ${BLOOD_RED}${BOLD}✘ Tunnel activation failed. Verify your token.${NC}"
                fi
                echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            2)
                echo -e "\n ${CYAN}➔${NC} Removing Cloudflare Service..."
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sudo apt-get remove --purge -y cloudflared >/dev/null 2>&1 & spinner $!
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
        echo -e " ${VIOLET}╭── POWER CONTROL SYSTEM ──────────────────────────╮${NC}"
        echo -e " ${VIOLET}│${NC} ${NEON_GREEN}[1]${NC} Start Panel Instance\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC} ${GOLD}[2]${NC} Restart Panel Instance\033[53G${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC} ${BLOOD_RED}[3]${NC} Stop Panel Instance\033[53G${VIOLET}│${NC}"
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
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}PREPARING ENVIRONMENT (SETUP A)${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e " ${CYAN}➔${NC} Updating APT indices..."
    sudo apt-get update -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Repositories synced."

    echo -e "\n ${CYAN}➔${NC} Upgrading environment binaries..."
    sudo apt-get upgrade -y >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Packages updated."

    echo -e "\n ${CYAN}➔${NC} Installing system build tools (Git, Curl, Build-Essential)..."
    sudo apt-get install -y git curl build-essential >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Build packages installed."

    echo -e "\n ${CYAN}➔${NC} Provisioning Node.js 20.x runtime engine..."
    ( curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1 && sudo apt-get install -y nodejs >/dev/null 2>&1 ) & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Node.js $(node -v 2>/dev/null) ready."

    echo -e "\n ${CYAN}➔${NC} Installing PM2 runtime process manager..."
    sudo npm install -g pm2 >/dev/null 2>&1 & spinner $!
    echo -e "  [${NEON_GREEN}✔${NC}] Global PM2 ready.\n"

    echo -e " ${NEON_GREEN}${BOLD}★ System Prep Finished Successfully! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

run_setup_2() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}DEEP REPAIR & UNLOCK (SETUP B)${NC}\033[52G${VIOLET}│${NC}"
    echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${NC}\n"

    echo -e " ${CYAN}➔${NC} Releasing APT/DPKG process lockfiles..."
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a >/dev/null 2>&1
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

    echo -e " ${NEON_GREEN}${BOLD}★ System Repaired and Cleaned! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

update_manual() {
    clear
    echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${VIOLET}│${NC} ${BOLD}${WHITE}SYSTEM UPDATE ENGINE${NC}\033[52G${VIOLET}│${NC}"
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

    echo -e " ${NEON_GREEN}${BOLD}★ System Update Completed! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

uninstall_panel() {
    clear
    echo -e "${BLOOD_RED}╭──────────────────────────────────────────────────╮${NC}"
    echo -e "${BLOOD_RED}│${NC} ${BOLD}${WHITE}SYSTEM PURGE WARNING${NC}\033[52G${BLOOD_RED}│${NC}"
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
            echo -e "\n ${NEON_GREEN}${BOLD}★ System Purge Complete! ★${NC}"
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
            echo -e "\n ${NEON_GREEN}Goodbye!${NC}\n"
            tput cnorm 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n ${BLOOD_RED}Unrecognized command option.${NC}"
            sleep 1
            ;;
    esac
done
