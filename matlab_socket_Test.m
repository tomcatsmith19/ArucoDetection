% Create a tcpip object
t = tcpip('127.0.0.1', 9999);

% Open the connection
fopen(t);

while 1
    try
        % Read the data from the server
        data = fscanf(t);

        % Print the received data
        disp(data);
    catch
        disp('no data')
    end
end

% Close the connection
fclose(t);