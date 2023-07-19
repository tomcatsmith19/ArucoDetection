import java.net.ServerSocket
import java.io.*
server_socket = ServerSocket(9999);
fprintf(1, 'Waiting for Python to connect on port %d\n', server_socket.getLocalPort);
client_socket = server_socket.accept;
input_stream   = client_socket.getInputStream;
d_input_stream = DataInputStream(input_stream);
output_stream   = client_socket.getOutputStream;
d_output_stream = DataOutputStream(output_stream);

LED = arduino("COM4", "ProMini328_5V");
writePWMDutyCycle(LED,'D5',0.3); % blue
writePWMDutyCycle(LED,'D9',1); % red
writePWMDutyCycle(LED,'D6',0.4); % green

for numOfTrials = 1:3
        disp('Starting new trial...');
        
        data_to_send = 6;
        d_output_stream.writeUTF(num2str(data_to_send));
        
        tic
        while toc <= 6
        end

        data_received = str2double(d_input_stream.readUTF());
        disp(data_received);
        if data_received == 0
            disp("Animal was not distracted...");
        else
            disp("Animal was distracted...");
        end
end

data_to_send = -1;
d_output_stream.writeUTF(num2str(data_to_send));

input_stream.close;
d_input_stream.close;
client_socket.close;
server_socket.close;

clear LED;
