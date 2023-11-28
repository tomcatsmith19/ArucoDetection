function TriggerSolenoidAirPuff(Arduino)

% Open Solenoid Air Valve (Default is Closed)
writeDigitalPin(Arduino,'D11',1);

% Close Solenoid Air Valve (Does it automatically, but just in case...)
writeDigitalPin(Arduino,'D11',0);

end

