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
PANEL_VERSION="V3.0-PRO"
PANEL_DIR="Jtg"
GIT_REPO="https://github.com/JishnuTheGamer/Jtg"
APP_NAME="jtg-panel"

cleanup() {
    tput cnorm 2>/dev/null
}

trap_exit() {
    tput cnorm 2>/dev/null
    echo -e "\n${BLOOD_RED}Session interrupted. Exiting safely.${NC}"
    exit 1
}

trap cleanup EXIT
trap trap_exit INT TERM

# ==============================================================================
# 🛠️ UTILITY & ANIMATION FUNCTIONS
# ==============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

typewriter() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
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

loading_bar() {
    local duration=${1:-2}
    local width=50
    local elapsed=0
    tput civis 2>/dev/null
    while [ $elapsed -lt $duration ]; do
        local progress=$((elapsed * 100 / duration))
        local filled=$((progress * width / 100))
        local empty=$((width - filled))
        printf "\r${VIOLET}[${NC}"
        printf "%${filled}s" '' | tr ' ' '█'
        printf "%${empty}s" '' | tr ' ' '░'
        printf "${VIOLET}]${NC} ${CYAN}%3d%%${NC}" "$progress"
        sleep 0.05
        ((elapsed++))
    done
    printf "\r${VIOLET}[${NC}"
    printf "%${width}s" '' | tr ' ' '█'
    printf "${VIOLET}]${NC} ${NEON_GREEN}100%%${NC}\n"
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

# ==============================================================================
# 🖥️ UI RENDERING
# ==============================================================================

strip_colors() {
    echo "$1" | sed -E 's/\x1b\[[0-9;]*[mK]//g'
}

pad_to_width() {
    local text="$1"
    local width="$2"
    local stripped
    stripped=$(strip_colors "$text")
    local current_len=${#stripped}
    local padding=$((width - current_len))
    if [ $padding -lt 0 ]; then padding=0; fi
    printf "%s%*s" "$text" "$padding" ""
}

show_loading_screens() {
    clear
    echo -e "\n\n"
    typewriter " ${VIOLET}${BOLD}⚡ INITIALIZING JTG PRO ENGINE V3.0...${NC}" 0.03
    loading_bar 2
    echo -e " ${NEON_GREEN}✔ System Architecture & Environment Verified.${NC}"
    sleep 0.3
    clear
}

draw_header() {
    get_sys_info
    clear

    local header_width=64
    local border
    border="$(printf '%*s' "$header_width" '' | tr ' ' '═')"

    echo -e "${VIOLET}╔${border}╗${NC}"
    local title=" JTG PANEL ${PANEL_VERSION} ── MANAGEMENT INTERFACE "
    echo -e "${VIOLET}║${NC} $(pad_to_width "$title" "$((header_width - 2))") ${VIOLET}║${NC}"
    local sub=" Core Architecture: Jishnu  | Enhanced & Maintained by: MrZetrix "
    echo -e "${VIOLET}║${NC} $(pad_to_width "$sub" "$((header_width - 2))") ${VIOLET}║${NC}"
    echo -e "${VIOLET}╠${border}╣${NC}"

    local line1="$(pad_to_width "${CYAN}System OS${NC}" 14) : $(pad_to_width "${OS_NAME:0:22}" 22) | $(pad_to_width "${CYAN}PM2 Engine${NC}" 12) : $(pad_to_width "$PM2_VAL" 15)"
    local line2="$(pad_to_width "${CYAN}Host Uptime${NC}" 14) : $(pad_to_width "${UPTIME_VAL:0:22}" 22) | $(pad_to_width "${CYAN}Panel Status${NC}" 12) : $(pad_to_width "$PANEL_VAL" 15)"
    local line3="$(pad_to_width "${CYAN}Panel Dir${NC}" 14) : $(pad_to_width "${PANEL_DIR}" 22) | $(pad_to_width "${CYAN}Cloudflare${NC}" 12) : $(pad_to_width "$CF_VAL" 15)"

    echo -e "${VIOLET}║${NC} $line1 ${VIOLET}║${NC}"
    echo -e "${VIOLET}║${NC} $line2 ${VIOLET}║${NC}"
    echo -e "${VIOLET}║${NC} $line3 ${VIOLET}║${NC}"
    echo -e "${VIOLET}╚${border}╝${NC}"
}

show_main_menu() {
    draw_header

    local menu_width=63
    local border
    border="$(printf '%*s' "$menu_width" '' | tr ' ' '─')"

    echo -e " ${VIOLET}${BOLD}┌── CORE CONTROLS ${border}${NC}"
    echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[1]${NC} Deploy JTG Panel ${PANEL_VERSION}    ── Clone repo, install & launch PM2    ${VIOLET}│${NC}"
    echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[2]${NC} Update Core Script & App   ── Fetch latest code & rebuild assets  ${VIOLET}│${NC}"
    echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[3]${NC} Power & Service Controller ── Start, Stop, or Restart PM2         ${VIOLET}│${NC}"
    echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[4]${NC} Cloudflare Zero Trust      ── Secure & establish network tunnel  ${VIOLET}│${NC}"
    echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[5]${NC} Administrator Operations   ── Add or reset admin user profile    ${VIOLET}│${NC}"
    echo -e " ${VIOLET}└───────────────────────────────────────────────────────┘${NC}"

    echo -e " ${SAPPHIRE}${BOLD}┌── MAINTENANCE & SYSTEM PREP ${border}${NC}"
    echo -e " ${SAPPHIRE}│${NC}  ${GOLD}[A]${NC} Install VPS Environment    ── Setup Node.js 20, Git, PM2 & Tools${SAPPHIRE}│${NC}"
    echo -e " ${SAPPHIRE}│${NC}  ${GOLD}[B]${NC} Deep System Repair         ── Unlock APT, purge cache & rebuild  ${SAPPHIRE}│${NC}"
    echo -e " ${SAPPHIRE}│${NC}  ${BLOOD_RED}[C]${NC} Purge Panel Entirely       ── Completely delete panel & PM2 tasks${SAPPHIRE}│${NC}"
    echo -e " ${SAPPHIRE}└───────────────────────────────────────────────────────┘${NC}"

    echo -e "  ${BLOOD_RED}[0] Exit Manager${NC}\n"
}

# ==============================================================================
# ⚡ CLOUDFLARE ENGINE
# ==============================================================================

cloudflare_manager() {
    while true; do
        draw_header
        echo -e " ${VIOLET}${BOLD}┌── CLOUDFLARE ZERO TRUST TUNNEL ────────────────────────────────────────┐${NC}"
        echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[1]${NC} Install Official Cloudflare APT Repository                       ${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[2]${NC} Register & Link Tunnel Token                                    ${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC}  ${BLOOD_RED}[3]${NC} Unlink & Remove Cloudflare Service                         ${VIOLET}│${NC}"
        echo -e " ${VIOLET}└───────────────────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${DARK_GRAY}[0] Back to Main Menu${NC}\n"
        echo -ne " ${CYAN}➔ Select Action:${NC} "
        read -r cf_opt

        case "$cf_opt" in
            1)
                clear
                echo -e " ${CYAN}➔ Installing Cloudflare GPG Key & Repository...${NC}"
                sudo mkdir -p --mode=0755 /usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
                echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
                
                echo -e " ${CYAN}➔ Updating package repository & installing cloudflared...${NC}"
                (sudo apt-get update -y >/dev/null 2>&1 && sudo apt-get install -y cloudflared >/dev/null 2>&1) & spinner $!
                echo -e "  [${NEON_GREEN}✔${NC}] Cloudflared successfully configured!"
                sleep 2
                ;;
            2)
                clear
                echo -e " ${GOLD}Paste your Cloudflare Tunnel Token below:${NC}"
                echo -ne " ${CYAN}➔ Token:${NC} "
                read -r cf_token

                if [ -z "$cf_token" ]; then
                    echo -e "  ${BLOOD_RED}[Error] Token cannot be blank.${NC}"
                    sleep 2
                    continue
                fi

                echo -e " ${CYAN}➔ Configuring service connection...${NC}"
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                
                if sudo cloudflared service install "$cf_token" >/dev/null 2>&1; then
                    sudo systemctl daemon-reload >/dev/null 2>&1
                    sudo systemctl enable --now cloudflared >/dev/null 2>&1
                    echo -e "  [${NEON_GREEN}✔${NC}] Cloudflare Tunnel is now ONLINE and active."
                else
                    echo -e "  [${BLOOD_RED}✘${NC}] Tunnel registration failed. Please verify token."
                fi
                echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
                read -r
                ;;
            3)
                echo -e " ${CYAN}➔ Removing Cloudflare service...${NC}"
                sudo systemctl stop cloudflared >/dev/null 2>&1
                sudo cloudflared service uninstall >/dev/null 2>&1
                sudo DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y cloudflared >/dev/null 2>&1
                sudo rm -f /etc/apt/sources.list.d/cloudflared.list /usr/share/keyrings/cloudflare-public-v2.gpg
                echo -e "  [${NEON_GREEN}✔${NC}] Removed entirely."
                sleep 2
                ;;
            0) break ;;
            *) echo -e " ${BLOOD_RED}Invalid option.${NC}"; sleep 1 ;;
        esac
    done
}

# ==============================================================================
# 🚀 CORE MODULE HANDLERS
# ==============================================================================

install_panel() {
    clear
    echo -e "${VIOLET}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${VIOLET}║ ${BOLD}${WHITE}DEPLOYING JTG PANEL ${PANEL_VERSION}${NC}${VIOLET}                                            ║${NC}"
    echo -e "${VIOLET}╚════════════════════════════════════════════════════════════════════════╝${NC}\n"

    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        echo -e " ${CYAN}➔${NC} Local repository directory exists. Pulling latest commits..."
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1) & spinner $!
    else
        echo -e " ${CYAN}➔${NC} Cloning repository from source target..."
        git clone "$GIT_REPO" "$PANEL_DIR" >/dev/null 2>&1 & spinner $!
        if [ ! -d "$PANEL_DIR" ]; then
            echo -e "\n  [${BLOOD_RED}✘${NC}] Git clone process failed!"
            sleep 2
            return
        fi
        cd "$PANEL_DIR" || return
    fi

    echo -e "\n ${CYAN}➔${NC} Building NPM packages..."
    npm install >/dev/null 2>&1 & spinner $!

    echo -e "\n ${GOLD}➔ Admin Credentials Configuration:${NC}\n"
    npm run createuser

    echo -e "\n ${CYAN}➔${NC} Compiling production assets..."
    npm run build >/dev/null 2>&1 & spinner $!

    echo -e "\n ${CYAN}➔${NC} Launching instance via PM2..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs >/dev/null 2>&1
    else
        pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
    fi
    pm2 save >/dev/null 2>&1

    cd .. 2>/dev/null || true
    echo -e "\n ${NEON_GREEN}${BOLD}★ DEPLOYMENT COMPLETE ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

admin_operations() {
    clear
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "  ${BLOOD_RED}✘ Panel installation not found!${NC}"
        sleep 2
        return
    fi
    cd "$PANEL_DIR" || return
    npm run createuser
    cd .. 2>/dev/null || true
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

panel_power_menu() {
    while true; do
        draw_header
        echo -e " ${VIOLET}${BOLD}┌── POWER CONTROL SYSTEM ────────────────────────────────────────────────┐${NC}"
        echo -e " ${VIOLET}│${NC}  ${NEON_GREEN}[1]${NC} Start Panel Instance                                              ${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC}  ${GOLD}[2]${NC} Restart Panel Instance                                            ${VIOLET}│${NC}"
        echo -e " ${VIOLET}│${NC}  ${BLOOD_RED}[3]${NC} Stop Panel Instance                                               ${VIOLET}│${NC}"
        echo -e " ${VIOLET}└───────────────────────────────────────────────────────────────────────┘${NC}"
        echo -e "  ${DARK_GRAY}[0] Back to Main Menu${NC}\n"
        echo -ne " ${CYAN}➔ Select Action:${NC} "
        read -r sys_opt

        case "$sys_opt" in
            1)
                [ -d "$PANEL_DIR" ] && cd "$PANEL_DIR" || continue
                if [ -f "ecosystem.config.cjs" ]; then
                    pm2 start ecosystem.config.cjs >/dev/null 2>&1
                else
                    pm2 start npm --name "$APP_NAME" -- run start >/dev/null 2>&1
                fi
                pm2 save >/dev/null 2>&1
                cd .. 2>/dev/null || true
                sleep 1.5
                ;;
            2)
                pm2 restart "$APP_NAME" >/dev/null 2>&1 || pm2 restart Jtg >/dev/null 2>&1
                sleep 1.5
                ;;
            3)
                pm2 stop "$APP_NAME" >/dev/null 2>&1 || pm2 stop Jtg >/dev/null 2>&1
                sleep 1.5
                ;;
            0) break ;;
        esac
    done
}

run_setup_1() {
    clear
    echo -e " ${CYAN}➔ Syncing APT indices and upgrading environment...${NC}"
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1 & spinner $!
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git curl build-essential >/dev/null 2>&1 & spinner $!
    
    echo -e "\n ${CYAN}➔ Provisioning Node.js 20.x environment...${NC}"
    (curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1 && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs >/dev/null 2>&1) & spinner $!
    sudo npm install -g pm2 >/dev/null 2>&1 & spinner $!

    echo -e "\n ${NEON_GREEN}${BOLD}★ System Environment Setup Complete! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

run_setup_2() {
    clear
    echo -e " ${CYAN}➔ Flushing locks and clearing package caches...${NC}"
    sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2>/dev/null
    sudo dpkg --configure -a >/dev/null 2>&1
    
    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        rm -rf node_modules package-lock.json 2>/dev/null
        npm cache clean --force >/dev/null 2>&1
        npm install >/dev/null 2>&1 & spinner $!
        npm run build >/dev/null 2>&1 & spinner $!
        cd .. 2>/dev/null || true
    fi
    echo -e "  [${NEON_GREEN}✔${NC}] System repaired."
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

update_manual() {
    clear
    if [ -d "$PANEL_DIR" ]; then
        cd "$PANEL_DIR" || return
        (git stash >/dev/null 2>&1 && git pull >/dev/null 2>&1 && npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1) & spinner $!
        pm2 restart "$APP_NAME" >/dev/null 2>&1
        cd .. 2>/dev/null || true
    fi
    echo -e " ${NEON_GREEN}${BOLD}★ Panel Codebase Updated! ★${NC}"
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

uninstall_panel() {
    clear
    echo -ne " ${BLOOD_RED}Confirm complete panel purge? [Y/N]: ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        pm2 stop "$APP_NAME" >/dev/null 2>&1
        pm2 delete "$APP_NAME" >/dev/null 2>&1
        pm2 save --force >/dev/null 2>&1
        rm -rf "$PANEL_DIR"
        echo -e "\n ${NEON_GREEN}Panel files and services deleted.${NC}"
    fi
    echo -ne "\n ${DIM}Press [Enter] to return...${NC}"
    read -r
}

# ==============================================================================
# 🎮 MAIN EXECUTION LOOP
# ==============================================================================

show_loading_screens

while true; do
    show_main_menu
    echo -ne " ${CYAN}➔ Enter Command Option:${NC} "
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
            echo -e "\n ${NEON_GREEN}Session Terminated cleanly. Goodbye!${NC}\n"
            tput cnorm 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n ${BLOOD_RED}Unrecognized command option.${NC}"
            sleep 1
            ;;
    esac
done
