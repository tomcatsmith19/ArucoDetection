a = arduino("COM5", "Uno");

for i = 1:3
    % white LED for 5 seconds (run with app initialization)
    %for brightness = 1:-0.7:0
        writePWMDutyCycle(a,'D5',0.3); % dim the LED
        writePWMDutyCycle(a,'D6',0.4);
        writePWMDutyCycle(a,'D9',0.4);
    
        pause(5);
   % end

    % red LED for 5 seconds (turn on for x amount with timeout)
    writeDigitalPin(a,'D5',0);
    %writeDigitalPin(a,'D6',0);
    writeDigitalPin(a,'D9',0);
    pause(5);
end

% clear at the end of the behavior with the stop button
clear a
