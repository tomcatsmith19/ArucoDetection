% MATLAB TCP/IP Server Script

import java.net.ServerSocket
import java.io.*

server_socket = ServerSocket(9998);  % Create server on port
fprintf(1, 'Waiting for Python to connect on port %d\n', server_socket.getLocalPort);
client_socket = server_socket.accept;  % Wait for client to connect

% Get Input and Output Streams
input_stream   = client_socket.getInputStream;
d_input_stream = DataInputStream(input_stream);
output_stream   = client_socket.getOutputStream;
d_output_stream = DataOutputStream(output_stream);

% Send some data to Python client
data_to_send = 42;
d_output_stream.writeUTF(num2str(data_to_send));  % Convert number to string to send

% Read data from Python client
data_received = str2double(d_input_stream.readUTF());
fprintf(1, 'Received from Python: %d\n', data_received);

% Clean up
input_stream.close;
d_input_stream.close;
client_socket.close;
server_socket.close;
