#!/bin/bash

# --- Ghost-Bridge v1.1 (Random Port Edition) ---

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}[*] Initializing Ghost-Bridge...${NC}"

# 1. توليد منفذ عشوائي متاح
RANDOM_PORT=$(shuf -i 2000-9999 -n 1)
echo -e "${YELLOW}[*] Generated Random Port: ${GREEN}$RANDOM_PORT${NC}"

# 2. تنظيف أي عملية قديمة (احتياطاً)
pkill -f cloudflared > /dev/null 2>&1
pkill -f proxy.py > /dev/null 2>&1

# 3. تشغيل نفق كليود فلير بالمنفذ الجديد
echo -e "${CYAN}[*] Starting Cloudflare Tunnel on port $RANDOM_PORT...${NC}"
cloudflared tunnel --url tcp://localhost:$RANDOM_PORT > /dev/null 2>&1 &
TUNNEL_PID=$!

sleep 4

# 4. تشغيل البروكسي وتمرير المنفذ له
if [ -f "proxy.py" ]; then
    # نمرر رقم المنفذ العشوائي كمتغير للبايثون
    python proxy.py $RANDOM_PORT
else
    echo -e "${RED}[!] proxy.py not found!${NC}"
    kill $TUNNEL_PID
    exit 1
fi

trap "kill $TUNNEL_PID; pkill -f proxy.py; exit" SIGINT SIGTERM
