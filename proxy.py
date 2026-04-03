import socket
import threading
import sys

# --- Ghost-Bridge v2.7 (High-Speed Engine) ---

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
                
                remote_socket = socket.create_connection((host, port), timeout=10)
                client_socket.send(b"HTTP/1.1 200 Connection Established\r\n\r\n")
                
                def forward(src, dst):
                    try:
                        while True:
                            chunk = src.recv(8192)
                            if not chunk: break
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
        print(f"[*] Ghost-Bridge Engine: ACTIVE")
        while True:
            client_conn, _ = server.accept()
            threading.Thread(target=handle_client, args=(client_conn,), daemon=True).start()
    except Exception as e:
        print(f"[-] Error: {e}")

if __name__ == "__main__":
    target_port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    start_proxy(target_port)
