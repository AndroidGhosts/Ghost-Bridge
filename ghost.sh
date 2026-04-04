#!/bin/bash

# --- Ghost-Bridge v3.0 (Pro Dashboard) ---
G='\033[1;32m'; R='\033[1;31m'; C='\033[1;36m'; Y='\033[1;33m'; W='\033[1;37m'; NC='\033[0m'

launch_bridge() {
    clear
    RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
    echo -e "${C}┌──────────────────────────────────────────┐${NC}"
    echo -e "${C}│${G}      👻 GHOST-BRIDGE MONITOR PRO 👻      ${C}│${NC}"
    echo -e "${C}├──────────────────────────────────────────┤${NC}"
    echo -e "${C}│${Y}  PORT:     ${W}$RANDOM_PORT                  ${C}│${NC}"
    echo -e "${C}│${Y}  STATUS:   ${G}Monitoring Active             ${C}│${NC}"
    echo -e "${C}└──────────────────────────────────────────┘${NC}"
    
    pkill -f cloudflared; pkill -f proxy.py
    cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
    
    echo -e "${G}[+] Bridge is Ready! Connect Psiphon to $RANDOM_PORT${NC}"
    echo -e "${Y}[!] Real-time Traffic Monitor:${NC}"
    
    # تشغيل بايثون (سيقوم هو بطباعة السرعة في السطر الأخير)
    python proxy.py $RANDOM_PORT
}

# القائمة (مختصرة للسرعة)
while true; do
    clear
    echo -e "${G}1) Start Ghost-Bridge${NC} | ${Y}2) Update${NC} | ${R}3) Exit${NC}"
    read -p "Select: " opt
    case $opt in
        1) launch_bridge ;;
        2) git pull origin main && chmod +x ghost.sh && ./ghost.sh ;;
        3) exit 0 ;;
    esac
done
