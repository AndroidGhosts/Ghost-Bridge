#!/bin/bash

# --- Ghost-Bridge v2.5 (Ultimate Dashboard) ---
G='\033[1;32m'; R='\033[1;31m'; C='\033[1;36m'; Y='\033[1;33m'; W='\033[1;37m'; NC='\033[0m'

# [1] وظيفة فحص المتطلبات (تثبيت تلقائي)
check_deps() {
    echo -e "${Y}[*] Checking System Dependencies...${NC}"
    pkg update -y
    # هنا يتم تثبيت أدوات النظام
    DEPENDENCIES=(python git cloudflared psmisc openssl)
    for tool in "${DEPENDENCIES[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${R}[!] Installing $tool...${NC}"
            pkg install $tool -y
        fi
    done
    
    # هنا يتم تثبيت مكتبات بايثون
    if ! python -c "import cryptography" &> /dev/null; then
        echo -e "${Y}[*] Installing Cryptography library (PIP)...${NC}"
        pip install cryptography
    fi
}

# [2] تنفيذ الفحص "فوراً" عند فتح السكربت
check_deps

# [3] وظيفة تشغيل الجسر
launch_bridge() {
    clear
    RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
    echo -e "${C}┌──────────────────────────────────────────┐${NC}"
    echo -e "${C}│${G}      👻 GHOST-BRIDGE SECURE SESSION 👻   ${C}│${NC}"
    echo -e "${C}├──────────────────────────────────────────┤${NC}"
    echo -e "${C}│${Y}  PORT:     ${W}$RANDOM_PORT                  ${C}│${NC}"
    echo -e "${C}│${Y}  ENCRYPTION:${G} AES-256 GCM                ${C}│${NC}"
    echo -e "${C}│${Y}  TUNNEL:   ${G} Cloudflare (Active)          ${C}│${NC}"
    echo -e "${C}└──────────────────────────────────────────┘${NC}"
    
    pkill -f cloudflared; pkill -f proxy.py
    cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
    TUNNEL_PID=$!
    
    echo -e "${Y}[*] Starting Tunnel... (Wait 5s)${NC}"
    sleep 5
    echo -e "${G}[+] Ghost-Bridge is LIVE! Set Psiphon to port $RANDOM_PORT${NC}"
    
    python proxy.py $RANDOM_PORT
    kill $TUNNEL_PID
    pkill -f proxy.py
}

# [4] القائمة الرئيسية التفاعلية
while true; do
    echo -e "${C}==========================================${NC}"
    echo -e "${G}      👻 GHOST-BRIDGE MAIN MENU 👻       ${NC}"
    echo -e "${C}==========================================${NC}"
    echo -e "${Y}1)${NC} Start Ghost-Bridge (Encrypted)"
    echo -e "${Y}2)${NC} Update Tool from GitHub"
    echo -e "${Y}3)${NC} Clean Cache & Logs"
    echo -e "${Y}4)${NC} Exit"
    echo -e "${C}------------------------------------------${NC}"
    read -p "Select [1-4]: " opt

    case $opt in
        1) launch_bridge ;;
        2) git pull origin main && chmod +x ghost.sh && echo -e "${G}Updated!${NC}" && sleep 2 ;;
        3) rm -rf ~/.cache && echo -e "${G}Logs Cleaned!${NC}" && sleep 2 ;;
        4) exit 0 ;;
        *) echo -e "${R}Invalid Option!${NC}"; sleep 1 ;;
    esac
done
