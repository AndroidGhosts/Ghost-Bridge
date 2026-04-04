import socket
import threading
import sys
import time

# --- Ghost-Bridge v3.0 (Traffic Monitor Edition) ---

# متغيرات عالمية لحساب السرعة
total_upload = 0
total_download = 0

def format_speed(size):
    # تحويل الحجم إلى كيلوبايت أو ميجابايت لسهولة القراءة
    if size < 1024: return f"{size:.2f} B/s"
    elif size < 1024**2: return f"{size/1024:.2f} KB/s"
    else: return f"{size/1024**2:.2f} MB/s"

def monitor_ui():
    global total_upload, total_download
    while True:
        # حساب السرعة الحالية (تقريبياً كل ثانية)
        up = total_upload
        down = total_download
        # تصفير العداد للثانية القادمة
        total_upload = 0
        total_download = 0
        
        # طباعة السرعة في سطر واحد متجدد (Overwriting line)
        sys.stdout.write(f"\r\033[1;36m[▲ UP]: \033[1;32m{format_speed(up)} \033[1;36m| [▼ DOWN]: \033[1;32m{format_speed(down)}  \033[0m")
        sys.stdout.flush()
        time.sleep(1)

def handle_bridge(src, dst, is_upload):
    global total_upload, total_download
    try:
        while True:
            chunk = src.recv(8192)
            if not chunk: break
            if is_upload: total_upload += len(chunk)
            else: total_download += len(chunk)
            dst.sendall(chunk)
    except: pass

def handle_client(client_socket):
    try:
        data = client_socket.recv(8192)
        if not data: return
        request = data.decode('utf-8', errors='ignore')
        lines = request.split('\n')
        if len(lines) > 0 and lines[0].startswith('CONNECT'):
            host_port = lines[0].split()[1].split(':')
            host = host_port[0]
            port = int(host_port[1]) if len(host_port) > 1 else 443
            
            remote_socket = socket.create_connection((host, port), timeout=10)
            client_socket.send(b"HTTP/1.1 200 Connection Established\r\n\r\n")
            
            threading.Thread(target=handle_bridge, args=(client_socket, remote_socket, True), daemon=True).start()
            threading.Thread(target=handle_bridge, args=(remote_socket, client_socket, False), daemon=True).start()
    except: pass

def start_proxy(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', port))
    server.listen(100)
    
    # تشغيل شاشة المراقبة في خيط منفصل
    threading.Thread(target=monitor_ui, daemon=True).start()
    
    while True:
        conn, _ = server.accept()
        threading.Thread(target=handle_client, args=(conn,), daemon=True).start()

if __name__ == "__main__":
    p = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    start_proxy(p)
