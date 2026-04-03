#!/bin/bash

# --- Ghost-Bridge Auto-Launcher ---
# Created by: AndroidGhosts Team
# Version: 1.0
# ----------------------------------

# ألوان للجمالية في الترمكس
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}[*] Starting Ghost-Bridge Environment...${NC}"

# 1. تنظيف المنافذ المشغولة لضمان عدم حدوث خطأ Address already in use
echo -e "${CYAN}[*] Cleaning up port 8080...${NC}"
fuser -k 8080/tcp > /dev/null 2>&1
sleep 1

# 2. تشغيل نفق كليود فلير في الخلفية وتوجيه المخرجات لملف سجل
echo -e "${CYAN}[*] Launching Cloudflare Tunnel (In Background)...${NC}"
cloudflared tunnel --url tcp://localhost:8080 > tunnel.log 2>&1 &

# حفظ رقم العملية للنفق لإغلاقه لاحقاً إذا لزم الأمر
TUNNEL_PID=$!

# 3. الانتظار قليلاً للتأكد من استقرار النفق
echo -e "${CYAN}[*] Waiting for tunnel stabilization (5s)...${NC}"
sleep 5

# 4. التأكد من وجود ملف البروكسي قبل التشغيل
if [ -f "proxy.py" ]; then
    echo -e "${GREEN}[+] Tunnel is READY!${NC}"
    echo -e "${GREEN}[+] Ghost-Bridge Bridge is ACTIVE on port 8080${NC}"
    echo -e "${CYAN}[!] Instruction: Set Psiphon Proxy to 127.0.0.1:8080${NC}"
    echo -e "${RED}[!] Press Ctrl+C to stop all services.${NC}"
    echo "------------------------------------------"
    
    # تشغيل سكريبت البايثون (الجسر)
    python proxy.py
else
    echo -e "${RED}[-][Error] proxy.py not found! Please make sure it's in the same folder.${NC}"
    kill $TUNNEL_PID
    exit 1
fi

# تنظيف العمليات عند الخروج (Ctrl+C)
trap "echo -e '${RED}\n[*] Shutting down...${NC}'; kill $TUNNEL_PID; exit" SIGINT SIGTERM

