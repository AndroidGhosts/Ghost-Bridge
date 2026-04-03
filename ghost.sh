#!/bin/bash

# ==========================================
# Project: Ghost-Bridge v1.0
# Created by: AndroidGhosts Team
# Description: Auto-Installer & Launcher
# ==========================================

# تعريف الألوان لواجهة المستخدم
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}      👻 GHOST-BRIDGE INSTALLER 👻       ${NC}"
echo -e "${CYAN}==========================================${NC}"

# 1. فحص وتثبيت المتطلبات الأساسية تلقائياً
echo -e "${YELLOW}[*] Checking system dependencies...${NC}"

DEPENDENCIES=(python git cloudflared psmisc)

for tool in "${DEPENDENCIES[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}[!] $tool is missing. Installing now...${NC}"
        pkg install $tool -y
    else
        echo -e "${GREEN}[V] $tool is already installed.${NC}"
    fi
done

echo -e "${GREEN}[+] Environment is ready!${NC}"
echo "------------------------------------------"

# 2. تنظيف العمليات القديمة والمنافذ المشغولة
echo -e "${YELLOW}[*] Cleaning up background processes...${NC}"
fuser -k 8080/tcp > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
sleep 2

# 3. تشغيل نفق كليود فلير في الخلفية
echo -e "${CYAN}[*] Opening Cloudflare Tunnel (tcp://8080)...${NC}"
# ملاحظة: يتم حفظ السجلات في ملف صامت لعدم إزعاج المستخدم
cloudflared tunnel --url tcp://localhost:8080 > /dev/null 2>&1 &
TUNNEL_PID=$!

# الانتظار لضمان استقرار النفق
echo -e "${YELLOW}[*] Waiting for tunnel to stabilize (5s)...${NC}"
sleep 5

# 4. تشغيل البروكسي (الجسر البرمجي)
if [ -f "proxy.py" ]; then
    echo -e "${GREEN}[+] SUCCESS: Ghost-Bridge is ACTIVE!${NC}"
    echo -e "${YELLOW}[!] Settings for Psiphon:${NC}"
    echo -e "    Host: ${WHITE}127.0.0.1${NC}"
    echo -e "    Port: ${WHITE}8080${NC}"
    echo -e "${RED}[!] Press Ctrl+C to STOP and Exit.${NC}"
    echo "------------------------------------------"
    
    # تشغيل سكريبت البايثون
    python proxy.py
else
    echo -e "${RED}[ERROR] proxy.py NOT FOUND in this directory!${NC}"
    echo -e "${YELLOW}[*] Shutting down tunnel...${NC}"
    kill $TUNNEL_PID
    exit 1
fi

# وظيفة لتنظيف العمليات عند الخروج بـ Ctrl+C
finish() {
    echo -e "${RED}\n[*] Stopping Ghost-Bridge services...${NC}"
    kill $TUNNEL_PID
    pkill -f proxy.py
    echo -e "${GREEN}[V] Done. Goodbye!${NC}"
    exit
}

trap finish SIGINT SIGTERM
