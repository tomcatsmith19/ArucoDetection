% Create a tcpip object
t = tcpip('127.0.0.1', 9999);

% Open the connection
fopen(t);

for i = 1:100
    % Read the data from the server
    data = fscanf(t);

    % Print the received data
    disp(data);
end

% Close the connection
fclose(t);