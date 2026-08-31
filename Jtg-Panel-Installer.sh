#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════════
#  CLOUDFLARED TUNNEL MANAGER – Non‑systemd / Container Safe
#  Supports Debian/Ubuntu (APT) • PM2 or nohup background mode
#  Animated, colourful, and 100% functional
# ═══════════════════════════════════════════════════════════════════

# ── Colour definitions ─────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'

VIOLET='\033[38;5;135m'
NEON_GREEN='\033[38;5;82m'
BLOOD_RED='\033[38;5;196m'
GOLD='\033[38;5;220m'
CYAN='\033[38;5;51m'
WHITE='\033[38;5;255m'
DARK_GRAY='\033[38;5;240m'

# ── Helper: check if a command exists ─────────────────────────────
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ── Animated spinner ──────────────────────────────────────────────
spinner() {
    local pid=$1
    local delay=0.1
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    while kill -0 "$pid" 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r  ${CYAN}%s${RESET} ${DIM}working...${RESET}" "$frame"
            sleep "$delay"
        done
    done
    printf "\r\033[K"  # clear line
    wait "$pid"
    return $?
}

# ── Pretty header ─────────────────────────────────────────────────
draw_header() {
    clear
    echo -e "${VIOLET}┌────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${VIOLET}│${RESET}  ${BOLD}${WHITE}CLOUDFLARED TUNNEL MANAGER${RESET}                         ${VIOLET}│${RESET}"
    echo -e "${VIOLET}│${RESET}  ${DIM}${GOLD}Zero Trust • Container Ready • Animated${RESET}          ${VIOLET}│${RESET}"
    echo -e "${VIOLET}└────────────────────────────────────────────────────────────┘${RESET}\n"
}

# ── Install cloudflared via official APT repo ─────────────────────
install_cloudflared_binary() {
    echo -e " ${CYAN}➔${RESET} ${BOLD}Configuring Cloudflare repository...${RESET}"

    # Create keyring directory (idempotent)
    sudo mkdir -p --mode=0755 /usr/share/keyrings >/dev/null 2>&1 || {
        echo -e "  ${BLOOD_RED}✘ Failed to create keyring directory${RESET}"
        return 1
    }

    # Download and install GPG key
    (curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | \
     sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null 2>&1) &
    spinner $! || {
        echo -e "  ${BLOOD_RED}✘ Failed to fetch Cloudflare GPG key${RESET}"
        return 1
    }

    # Add APT source list
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
        sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null 2>&1 || {
        echo -e "  ${BLOOD_RED}✘ Failed to add APT repository${RESET}"
        return 1
    }

    # Update package lists
    echo -e " ${CYAN}➔${RESET} ${BOLD}Updating APT package lists...${RESET}"
    (sudo apt-get update -y >/dev/null 2>&1) &
    spinner $! || {
        echo -e "  ${BLOOD_RED}✘ APT update failed${RESET}"
        return 1
    }

    # Install cloudflared
    echo -e " ${CYAN}➔${RESET} ${BOLD}Installing cloudflared binary...${RESET}"
    (sudo apt-get install -y cloudflared >/dev/null 2>&1) &
    spinner $! || {
        echo -e "  ${BLOOD_RED}✘ Installation failed${RESET}"
        return 1
    }

    echo -e "  ${NEON_GREEN}✔ cloudflared installed successfully${RESET}"
    return 0
}

# ── Stop any existing cloudflared process / service ───────────────
cleanup_previous_cloudflared() {
    echo -e " ${CYAN}➔${RESET} ${DIM}Stopping any existing cloudflared processes...${RESET}"

    # Try to stop via systemctl if available (best effort)
    if command_exists systemctl; then
        sudo systemctl stop cloudflared >/dev/null 2>&1
        sudo systemctl disable cloudflared >/dev/null 2>&1
    fi

    # Stop via SysV init script if present
    if [ -f /etc/init.d/cloudflared ]; then
        sudo /etc/init.d/cloudflared stop >/dev/null 2>&1
        sudo rm -f /etc/init.d/cloudflared >/dev/null 2>&1
    fi

    # Kill any remaining cloudflared processes (owned by current user or root)
    pkill -f "cloudflared tunnel" >/dev/null 2>&1
    sleep 1  # give processes time to terminate
}

# ── Main manager loop ─────────────────────────────────────────────
cloudflare_manager() {
    while true; do
        draw_header
        echo -e " ${VIOLET}╭── CLOUDFLARE ZERO TRUST TUNNEL ──────────────────╮${RESET}"
        echo -e " ${VIOLET}│${RESET} ${NEON_GREEN}[1]${RESET} Launch Tunnel via PM2/Background Daemon\033[53G${VIOLET}│${RESET}"
        echo -e " ${VIOLET}│${RESET} ${BLOOD_RED}[2]${RESET} Stop & Kill Active Tunnels\033[53G${VIOLET}│${RESET}"
        echo -e " ${VIOLET}╰──────────────────────────────────────────────────╯${RESET}"
        echo -e "  ${DARK_GRAY}[0] Back to Main Menu${RESET}\n"
        echo -ne " ${CYAN}➔ Select Action:${RESET} "
        read -r cf_opt

        case "$cf_opt" in
            1)
                clear
                echo -e "${VIOLET}╭──────────────────────────────────────────────────╮${RESET}"
                echo -e "${VIOLET}│${RESET} ${BOLD}${WHITE}CONNECT CLOUDFLARE TUNNEL${RESET}\033[52G${VIOLET}│${RESET}"
                echo -e "${VIOLET}╰──────────────────────────────────────────────────╯${RESET}\n"

                # Check for dependency
                if ! command_exists cloudflared; then
                    echo -e " ${CYAN}➔${RESET} Setting up official Cloudflare repository & installing binary..."
                    install_cloudflared_binary
                    if [ $? -ne 0 ]; then
                        echo -e "\n  ${BLOOD_RED}Failed to install Cloudflare. Aborting.${RESET}"
                        sleep 2
                        continue
                    fi
                fi

                # Cleanup any old service / process
                cleanup_previous_cloudflared

                # Get token from user
                echo -e " ${GOLD}Paste your Cloudflare Tunnel Token below:${RESET}"
                echo -e " ${DIM}(Supports raw token string or full 'sudo cloudflared...' command)${RESET}\n"
                echo -ne " ${CYAN}➔ Token:${RESET} "
                read -r cf_input

                if [ -z "$cf_input" ]; then
                    echo -e "\n  ${BLOOD_RED}[Error] Token cannot be blank. Operation cancelled.${RESET}"
                    sleep 2
                    continue
                fi

                # Extract token: last field of input (handles full command)
                cf_token=$(echo "$cf_input" | awk '{print $NF}')

                # Validate token length (basic check)
                if [ ${#cf_token} -lt 50 ]; then
                    echo -e "\n  ${BLOOD_RED}[Error] Token seems invalid (too short). Please check.${RESET}"
                    sleep 2
                    continue
                fi

                # Launch tunnel
                echo -e "\n ${CYAN}➔${RESET} ${BOLD}Starting Cloudflare tunnel...${RESET}"
                if command_exists pm2; then
                    # Use PM2 for process management
                    pm2 start cloudflared --name "jtg-tunnel" -- tunnel --no-autoupdate run --token "$cf_token" >/dev/null 2>&1
                    pm2 save >/dev/null 2>&1
                    sleep 1.5
                else
                    # Fallback: nohup background process
                    nohup cloudflared tunnel --no-autoupdate run --token "$cf_token" >/dev/null 2>&1 &
                    sleep 1.5
                fi

                # Verify
                if pgrep -x cloudflared >/dev/null 2>&1; then
                    echo -e "\n ${NEON_GREEN}${BOLD}★ Cloudflare Tunnel is Active and Running! ★${RESET}"
                else
                    echo -e "\n ${BLOOD_RED}${BOLD}✘ Tunnel failed to start. Check token or logs.${RESET}"
                    echo -e " ${DIM}Debug: sudo journalctl -u cloudflared -f (if using service) or check nohup output.${RESET}"
                fi
                echo -ne "\n ${DIM}Press [Enter] to return...${RESET}"
                read -r
                ;;
            2)
                echo -e "\n ${CYAN}➔${RESET} ${BOLD}Stopping Cloudflare Tunnel processes...${RESET}"
                if command_exists pm2; then
                    pm2 stop "jtg-tunnel" >/dev/null 2>&1
                    pm2 delete "jtg-tunnel" >/dev/null 2>&1
                    pm2 save >/dev/null 2>&1
                fi
                pkill -f "cloudflared tunnel" >/dev/null 2>&1
                echo -e "  ${NEON_GREEN}✔ Tunnel processes terminated.${RESET}"
                sleep 1.5
                ;;
            0)
                break
                ;;
            *)
                echo -e " ${BLOOD_RED}Invalid option.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# ── Entry point ───────────────────────────────────────────────────
cloudflare_manager
