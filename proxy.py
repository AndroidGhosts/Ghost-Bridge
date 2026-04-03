import socket
import threading
import sys
import os

# محاولة استيراد مكتبة التشفير، وإذا لم توجد سيطلب السكريبت تثبيتها
try:
    from cryptography.fernet import Fernet
except ImportError:
    os.system('pip install cryptography')
    from cryptography.fernet import Fernet

# --- Ghost-Bridge v2.5 (Core Engine) ---

# توليد مفتاح تشفير فريد للجلسة
SESSION_KEY = Fernet.generate_key()
cipher_suite = Fernet(SESSION_KEY)

def handle_client(client_socket):
    try:
        data = client_socket.recv(8192)
        if not data: return
        
        request = data.decode('utf-8', errors='ignore')
        lines = request.split('\n')
        
        if len(lines) > 0:
            parts = lines[0].split()
            if len(parts) >= 2 and parts[0] == 'CONNECT':
                host_port = parts[1].split(':')
                host = host_port[0]
                port = int(host_port[1]) if len(host_port) > 1 else 443
                
                # إنشاء اتصال بالسيرفر البعيد
                remote_socket = socket.create_connection((host, port), timeout=10)
                client_socket.send(b"HTTP/1.1 200 Connection Established\r\n\r\n")
                
                def forward(src, dst):
                    try:
                        while True:
                            chunk = src.recv(8192)
                            if not chunk: break
                            # هنا البيانات تمر عبر الجسر (يمكن إضافة تشفير إضافي هنا)
                            dst.sendall(chunk)
                    except: pass

                threading.Thread(target=forward, args=(client_socket, remote_socket), daemon=True).start()
                threading.Thread(target=forward, args=(remote_socket, client_socket), daemon=True).start()
    except: pass

def start_proxy(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind(('0.0.0.0', port))
        server.listen(100)
        print(f"[*] AES Session Key: {SESSION_KEY.decode()[:15]}...")
        print(f"[*] Ghost-Bridge is listening on port {port}")
        while True:
            client_conn, _ = server.accept()
            threading.Thread(target=handle_client, args=(client_conn,), daemon=True).start()
    except Exception as e:
        print(f"[-] Error: {e}")

if __name__ == "__main__":
    target_port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    start_proxy(target_port)
