a = arduino("COM5", "Uno");

writeDigitalPin(a,'D11',1);
writeDigitalPin(a,'D11',0);
pause(2);

writeDigitalPin(a,'D11',1);
writeDigitalPin(a,'D11',0);
pause(2);

writeDigitalPin(a,'D11',1);
writeDigitalPin(a,'D11',0);
pause(2);

% clear at the end of the behavior with the stop button
clear a
