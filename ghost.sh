#!/bin/bash

# --- Ghost-Bridge v2.9 (Silent & Zero-Update) ---
G='\033[1;32m'; R='\033[1;31m'; C='\033[1;36m'; Y='\033[1;33m'; W='\033[1;37m'; NC='\033[0m'

# [1] فحص صامت للملفات بدون أي اتصال بالإنترنت
check_runtime() {
    # التأكد من وجود الأدوات الأساسية في المسار
    for tool in python git cloudflared pkill; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${R}[!] Error: $tool is missing. Please install it manually.${NC}"
            exit 1
        fi
    done
}

# [2] تشغيل الجسر فوراً
launch_bridge() {
    clear
    RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
    echo -e "${C}┌──────────────────────────────────────────┐${NC}"
    echo -e "${C}│${G}      👻 GHOST-BRIDGE SILENT MODE 👻      ${C}│${NC}"
    echo -e "${C}├──────────────────────────────────────────┤${NC}"
    echo -e "${C}│${Y}  PORT:     ${W}$RANDOM_PORT                  ${C}│${NC}"
    echo -e "${C}│${Y}  NETWORK:  ${G}Direct Connection             ${C}│${NC}"
    echo -e "${C}└──────────────────────────────────────────┘${NC}"
    
    # تنظيف العمليات بصمت
    pkill -f cloudflared > /dev/null 2>&1
    pkill -f proxy.py > /dev/null 2>&1
    
    # تشغيل النفق بصمت مطبق
    cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
    TUNNEL_PID=$!
    
    sleep 2
    echo -e "${G}[+] Ghost-Bridge is LIVE!${NC}"
    echo -e "${C}[!] Set Psiphon Port to: ${W}$RANDOM_PORT${NC}"
    echo -e "${R}[!] Ctrl+C to Exit${NC}\n"
    
    python proxy.py $RANDOM_PORT
    kill $TUNNEL_PID > /dev/null 2>&1
}

# [3] القائمة الرئيسية
while true; do
    clear
    echo -e "${C}==========================================${NC}"
    echo -e "${G}      👻 GHOST-BRIDGE MAIN MENU 👻       ${NC}"
    echo -e "${C}==========================================${NC}"
    echo -e "${Y}1)${NC} Start Ghost-Bridge (No Updates)"
    echo -e "${Y}2)${NC} Pull Updates from GitHub"
    echo -e "${Y}3)${NC} Exit"
    echo -e "${C}------------------------------------------${NC}"
    read -p "Select [1-3]: " opt

    case $opt in
        1) check_runtime && launch_bridge ;;
        2) git pull origin main && chmod +x ghost.sh && echo -e "${G}Updated!${NC}" && sleep 1 ;;
        3) exit 0 ;;
        *) echo -e "${R}Invalid!${NC}"; sleep 1 ;;
    esac
done
