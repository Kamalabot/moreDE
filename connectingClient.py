import socket

HOST = "127.0.0.1"
PORT = 65430
print('interpreted')
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    s.sendall(b"Hello, world")
    s.sendall(b"World has become brave new now")
    data = s.recv(1024)
    
print(f"Recieved {data}")