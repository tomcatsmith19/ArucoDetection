import socket
import struct
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 9999))

while True:
    data_received = s.recv(1024)[2:].decode("utf-8")
    print("Data Received: ", data_received)

    if int(data_received) == 1:
        distraction = []
        start_time = time.time()
        
        while time.time()-start_time <= 6:
            distraction.append(0)
        
        if 0 in distraction:
            data_to_send = 0
            print("Not Distracted")
        else:
            data_to_send = 1
            print("Distracted")

        data_str = str(data_to_send)
        data_encoded = data_str.encode("utf-8")
        s.send(struct.pack('!h', len(data_encoded)))
        s.send(data_encoded)
        print("Data Sent: ", data_encoded)

    elif int(data_received) == 42:
        break

s.close()