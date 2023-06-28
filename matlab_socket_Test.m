clear all

% Create a tcpip object to connect to the python script
t = tcpip('127.0.0.1', 9999);

% Reset variables every trial
distraction = [];
dataToSend = 0;
dataReceived = 0;
 
try
    % Open the connection to python
    fopen(t);

    for numOfTrials = 1:5
        disp('Starting new trial...');
        pause(2);
        
        % simulate 6 second trials
        tic
        while toc <=6
            % Send flag value to python (1 = start looking, 0 = stop looking)
            dataToSend = 1;
            
            try
                % Write the data to the server
                fwrite(t, dataToSend);
            catch
                disp('Cannot send starting data to python script...');
            end
        
            try
                % Read the data from the server
                dataReceived = str2double(fscanf(t));
                
                if dataReceived == 0
                    disp('Animal was not distracted...');

                    % Send flag value to python (1 = start looking, 0 = stop looking)
                    dataToSend = 0;
                    
                    % Update distraction log for every trial
                    distraction(1,numOfTrials) = 0;
                    
                    try
                        % Write the data to the server
                        fwrite(t, dataToSend);
                    catch
                        disp('Cannot send stopping data to python script...');
                    end

                    break;
                else
                    %disp('Animal was distracted...');

                    % Update distraction log for every trial
                    distraction(1,numOfTrials) = 1;
                end
            catch
                disp('No data received from python script...');
            end
        end
    end

    % Close the connection
    fclose(t);
catch
    disp('Cannot open connection to python script...');
end