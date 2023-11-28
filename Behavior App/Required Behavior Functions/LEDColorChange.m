function LEDColorChange(LED, color)

% if you want white LEDs
if strcmpi(color,'w')==1
    % Turn on white LEDs
    writePWMDutyCycle(LED,'D5',0.3); % blue
    writePWMDutyCycle(LED,'D9',1); % red
    writePWMDutyCycle(LED,'D6',0.4); % green
% if you want red LEDs
elseif strcmpi(color,'r')==1
    % Turn on red LEDs
    writeDigitalPin(LED,'D5',0); % blue
    writeDigitalPin(LED,'D9',1); % red
    writeDigitalPin(LED,'D6',0); % green
% if you want green LEDs
elseif strcmpi(color,'g')==1
    % Turn on green LEDs
    writeDigitalPin(LED,'D5',0); % blue
    writeDigitalPin(LED,'D9',0); % red
    writeDigitalPin(LED,'D6',1); % green    
% broken
else
    % Error has occurred
    disp('An error has occurred with the LEDs...');
end

end