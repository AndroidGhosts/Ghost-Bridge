#!/bin/bash

# ==========================================
# Project: Ghost-Bridge v1.1
# Created by: AndroidGhosts Team
# Features: Auto-Update, Auto-Install, Random Port
# ==========================================

# الألوان للتنسيق
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}      👻 GHOST-BRIDGE AUTO-SETUP 👻      ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. تحديث النظام (pkg update & upgrade)
echo -e "${YELLOW}[*] Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y

# 2. قائمة الأدوات المطلوبة
DEPENDENCIES=(python git cloudflared psmisc)

echo -e "${YELLOW}[*] Checking and installing dependencies...${NC}"

for tool in "${DEPENDENCIES[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}[!] $tool is missing. Installing...${NC}"
        pkg install $tool -y
    else
        echo -e "${GREEN}[V] $tool is already installed.${NC}"
    fi
done

echo -e "${GREEN}[+] System is ready!${NC}"
echo "------------------------------------------"

# 3. توليد منفذ عشوائي بين 2000 و 9999
RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
echo -e "${YELLOW}[*] Generated Dynamic Port: ${GREEN}$RANDOM_PORT${NC}"

# 4. تنظيف العمليات القديمة لضمان عدم التداخل
pkill -f cloudflared > /dev/null 2>&1
pkill -f proxy.py > /dev/null 2>&1
fuser -k $RANDOM_PORT/tcp > /dev/null 2>&1
sleep 1

# 5. تشغيل نفق كليود فلير بالمنفذ العشوائي
echo -e "${CYAN}[*] Starting Cloudflare Tunnel on port $RANDOM_PORT...${NC}"
cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
TUNNEL_PID=$!

# الانتظار للتأكد من استقرار النفق
sleep 5

# 6. تشغيل البروكسي (proxy.py) وتمرير المنفذ له
if [ -f "proxy.py" ]; then
    echo -e "${GREEN}[+] Ghost-Bridge is ACTIVE!${NC}"
    echo -e "${CYAN}[!] Important: Set Psiphon Proxy to:${NC}"
    echo -e "    Host: ${WHITE}127.0.0.1${NC}"
    echo -e "    Port: ${WHITE}$RANDOM_PORT${NC}"
    echo "------------------------------------------"
    python proxy.py $RANDOM_PORT
else
    echo -e "${RED}[ERROR] proxy.py not found! Please check your files.${NC}"
    kill $TUNNEL_PID
    exit 1
fi

# وظيفة الإغلاق النظيف
finish() {
    echo -e "${RED}\n[*] Stopping Ghost-Bridge...${NC}"
    kill $TUNNEL_PID
    pkill -f proxy.py
    exit
}

trap finish SIGINT SIGTERM
