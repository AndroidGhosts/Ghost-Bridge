import socket
import threading
import sys

# --- Ghost-Bridge Core Proxy (v1.1 - Dynamic Port) ---

def handle_client(client_socket):
    try:
        request = client_socket.recv(8192).decode('utf-8', errors='ignore')
        if not request: return
        
        first_line = request.split('\n')[0]
        parts = first_line.split()
        if len(parts) < 2: return
            
        method, url = parts[0], parts[1]

        if method == 'CONNECT':
            try:
                host, port = url.split(':')
                remote_socket = socket.create_connection((host, int(port)), timeout=10)
                client_socket.send(b"HTTP/1.1 200 Connection Established\r\n\r\n")
                
                def forward(src, dst):
                    try:
                        while True:
                            data = src.recv(8192)
                            if not data: break
                            dst.sendall(data)
                    except: pass

                threading.Thread(target=forward, args=(client_socket, remote_socket), daemon=True).start()
                threading.Thread(target=forward, args=(remote_socket, client_socket), daemon=True).start()
            except:
                client_socket.send(b"HTTP/1.1 502 Bad Gateway\r\n\r\n")
    except: pass

def start_proxy(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind(('0.0.0.0', port))
        server.listen(100)
        print(f"\n{'-'*40}")
        print(f"🚀 Ghost-Bridge ACTIVE on Port: {port}")
        print(f"🔗 Set Psiphon Proxy to: 127.0.0.1:{port}")
        print(f"{'-'*40}")
        
        while True:
            client_conn, _ = server.accept()
            threading.Thread(target=handle_client, args=(client_conn,), daemon=True).start()
    except Exception as e:
        print(f"[-] Error: {e}")

if __name__ == "__main__":
    # استقبال المنفذ من السكربت أو استخدام 8080 كافتراضي
    target_port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    start_proxy(target_port)
