#!/bin/bash

# --- Ghost-Bridge v2.8 (Instant Dashboard) ---
G='\033[1;32m'; R='\033[1;31m'; C='\033[1;36m'; Y='\033[1;33m'; W='\033[1;37m'; NC='\033[0m'

# [1] وظيفة الفحص الصامت (لا تظهر شيئاً إذا كان كل شيء جاهزاً)
check_deps() {
    DEPENDENCIES=(python git cloudflared psmisc)
    MISSING=()

    for tool in "${DEPENDENCIES[@]}"; do
        if ! command -v $tool &> /dev/null; then
            MISSING+=($tool)
        fi
    done

    # التثبيت المباشر فقط في حالة النقص
    if [ ${#MISSING[@]} -ne 0 ]; then
        echo -e "${Y}[*] Adding missing components: ${MISSING[*]}${NC}"
        pkg install "${MISSING[@]}" -y || (pkg update -y && pkg install "${MISSING[@]}" -y)
    fi
}

# [2] وظيفة تشغيل الجسر والنفق
launch_bridge() {
    clear
    RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
    echo -e "${C}┌──────────────────────────────────────────┐${NC}"
    echo -e "${C}│${G}      👻 GHOST-BRIDGE INSTANT SESSION 👻  ${C}│${NC}"
    echo -e "${C}├──────────────────────────────────────────┤${NC}"
    echo -e "${C}│${Y}  PORT:     ${W}$RANDOM_PORT                  ${C}│${NC}"
    echo -e "${C}│${Y}  STATUS:   ${G}Live & Direct                 ${C}│${NC}"
    echo -e "${C}└──────────────────────────────────────────┘${NC}"
    
    # تنظيف العمليات القديمة بسرعة
    pkill -f cloudflared; pkill -f proxy.py
    
    # تشغيل النفق (صامت)
    cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
    TUNNEL_PID=$!
    
    sleep 2
    echo -e "${G}[+] Ready! Set Psiphon Port to: ${W}$RANDOM_PORT${NC}"
    echo -e "${R}[!] Press Ctrl+C to Stop${NC}\n"
    
    # تشغيل البروكسي
    python proxy.py $RANDOM_PORT
    
    kill $TUNNEL_PID
    pkill -f proxy.py
}

# [3] القائمة الرئيسية
while true; do
    clear
    echo -e "${C}==========================================${NC}"
    echo -e "${G}      👻 GHOST-BRIDGE CONTROL PANEL 👻    ${NC}"
    echo -e "${C}==========================================${NC}"
    echo -e "${Y}1)${NC} Start Ghost-Bridge (Instant)"
    echo -e "${Y}2)${NC} Update Tool from GitHub"
    echo -e "${Y}3)${NC} Clean Cache"
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
