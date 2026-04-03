#!/bin/bash

# --- Ghost-Bridge v2.6 (Ultimate Fast Dashboard) ---
G='\033[1;32m'; R='\033[1;31m'; C='\033[1;36m'; Y='\033[1;33m'; W='\033[1;37m'; NC='\033[0m'

# [1] وظيفة فحص وتثبيت المتطلبات تلقائياً
check_deps() {
    echo -e "${Y}[*] Checking System Dependencies...${NC}"
    pkg update -y
    # الأدوات الأساسية فقط لضمان السرعة وعدم الخطأ
    DEPENDENCIES=(python git cloudflared psmisc)
    for tool in "${DEPENDENCIES[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${R}[!] Installing $tool...${NC}"
            pkg install $tool -y
        else
            echo -e "${G}[V] $tool is ready.${NC}"
        fi
    done
}

# [2] وظيفة تشغيل الجسر والنفق
launch_bridge() {
    clear
    # توليد منفذ عشوائي جديد في كل مرة
    RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
    
    echo -e "${C}┌──────────────────────────────────────────┐${NC}"
    echo -e "${C}│${G}      👻 GHOST-BRIDGE FAST SESSION 👻     ${C}│${NC}"
    echo -e "${C}├──────────────────────────────────────────┤${NC}"
    echo -e "${C}│${Y}  PORT:     ${W}$RANDOM_PORT                  ${C}│${NC}"
    echo -e "${C}│${Y}  MODE:     ${G}Direct Bridge (No Enc)        ${C}│${NC}"
    echo -e "${C}│${Y}  TUNNEL:   ${G}Cloudflare Tunnel             ${C}│${NC}"
    echo -e "${C}└──────────────────────────────────────────┘${NC}"
    
    # تنظيف أي عمليات سابقة
    pkill -f cloudflared; pkill -f proxy.py
    
    # تشغيل نفق كليود فلير
    echo -e "${Y}[*] Opening Tunnel...${NC}"
    cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
    TUNNEL_PID=$!
    
    sleep 5
    echo -e "${G}[+] Connection Established!${NC}"
    echo -e "${C}[!] Set Psiphon Proxy Port to: ${W}$RANDOM_PORT${NC}"
    echo -e "${R}[!] Press Ctrl+C to Stop and Exit${NC}\n"
    
    # تشغيل محرك بايثون
    python proxy.py $RANDOM_PORT
    
    # تنظيف عند الإغلاق
    kill $TUNNEL_PID
    pkill -f proxy.py
}

# [3] القائمة الرئيسية
while true; do
    clear
    echo -e "${C}==========================================${NC}"
    echo -e "${G}      👻 GHOST-BRIDGE MAIN MENU 👻       ${NC}"
    echo -e "${C}==========================================${NC}"
    echo -e "${Y}1)${NC} Start Ghost-Bridge (Fast Mode)"
    echo -e "${Y}2)${NC} Update Tool from GitHub"
    echo -e "${Y}3)${NC} Clean System Cache"
    echo -e "${Y}4)${NC} Exit"
    echo -e "${C}------------------------------------------${NC}"
    read -p "Select [1-4]: " opt

    case $opt in
        1) check_deps && launch_bridge ;;
        2) git pull origin main && chmod +x ghost.sh && echo -e "${G}Updated!${NC}" && sleep 2 ;;
        3) rm -rf ~/.cache && echo -e "${G}Cache Cleaned!${NC}" && sleep 2 ;;
        4) exit 0 ;;
        *) echo -e "${R}Invalid Option!${NC}"; sleep 1 ;;
    esac
done
