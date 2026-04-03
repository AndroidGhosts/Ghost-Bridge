import socket
import threading
import sys

# --- Ghost-Bridge Core Proxy ---
# Developed by: AndroidGhosts Team
# Purpose: Handles HTTP CONNECT method for Psiphon over Cloudflare Tunnel
# -------------------------------

def handle_client(client_socket):
    try:
        # Receive the initial request from Psiphon
        request = client_socket.recv(8192).decode('utf-8', errors='ignore')
        if not request:
            return
        
        # Parse the request line (e.g., CONNECT google.com:443 HTTP/1.1)
        first_line = request.split('\n')[0]
        parts = first_line.split()
        
        if len(parts) < 2:
            return
            
        method = parts[0]
        url = parts[1]

        # Psiphon uses CONNECT to establish a secure tunnel
        if method == 'CONNECT':
            try:
                host, port = url.split(':')
                print(f"[+] Ghost-Bridge: Tunneling to {host}:{port}")
                
                # Establish connection to the destination
                remote_socket = socket.create_connection((host, int(port)), timeout=10)
                
                # Tell Psiphon the bridge is ready
                client_socket.send(b"HTTP/1.1 200 Connection Established\r\n\r\n")
                
                # Bidirectional data transfer (The Bridge)
                def forward(src, dst):
                    try:
                        while True:
                            data = src.recv(8192)
                            if not data:
                                break
                            dst.sendall(data)
                    except:
                        pass

                # Start two threads for full-duplex communication
                t1 = threading.Thread(target=forward, args=(client_socket, remote_socket), daemon=True)
                t2 = threading.Thread(target=forward, args=(remote_socket, client_socket), daemon=True)
                t1.start()
                t2.start()
                
            except Exception as e:
                print(f"[-] Connection Error: {e}")
                client_socket.send(b"HTTP/1.1 502 Bad Gateway\r\n\r\n")
        else:
            # For non-CONNECT requests, return 501 (Simple HTTP not supported)
            client_socket.send(b"HTTP/1.1 501 Not Implemented\r\n\r\n")

    except Exception as e:
        pass # Silently handle disconnects

def start_proxy(port=8080):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server.bind(('0.0.0.0', port))
        server.listen(100)
        print(f"[*] Ghost-Bridge Proxy started on port {port}")
        print("[!] Waiting for Psiphon connections...")
        
        while True:
            client_conn, addr = server.accept()
            client_thread = threading.Thread(target=handle_client, args=(client_conn,), daemon=True)
            client_thread.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down Ghost-Bridge...")
        sys.exit(0)
    except Exception as e:
        print(f"[-] Critical Server Error: {e}")

if __name__ == "__main__":
    start_proxy()
