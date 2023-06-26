import socket

def start_server():
    # create a socket object
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # get local machine name
    host = '127.0.0.1' #socket.gethostname()

    port = 9999

    # bind to the port
    serversocket.bind((host, port))

    # queue up to 5 requests
    serversocket.listen(5)

    while True:
        # establish a connection
        clientsocket, addr = serversocket.accept()

        print("Got a connection from %s" % str(addr))

        # your function call, it should return a string
        msg = 'your function output here' + "\r\n"

        clientsocket.send(msg.encode('ascii'))

        clientsocket.close()

start_server()