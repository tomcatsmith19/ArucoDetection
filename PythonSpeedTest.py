# Python TCP/IP Client Script

import socket
import struct

# Connect to MATLAB server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 9998))  # Assuming the server is running on the same machine

# Receive data from MATLAB
data_received = s.recv(1024)[2:].decode("utf-8")  # Skip the first 2 bytes
print(f"Received from MATLAB: {data_received}")

if int(data_received) == 42:
    print("it worked")
else:
    print("it didnt")

# Send some data to MATLAB server
data_to_send = 42
data_str = str(data_to_send)
data_encoded = data_str.encode("utf-8")  # Convert number to string to send

# Write the length of the data_encoded first
s.send(struct.pack('!h', len(data_encoded)))
s.send(data_encoded)

# Clean up
s.close()
