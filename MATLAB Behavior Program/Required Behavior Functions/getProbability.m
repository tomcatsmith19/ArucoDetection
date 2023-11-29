function prob = getProbability(percent)

percent = string(percent);

switch true
    case (strcmpi(percent,'16.7')==1)
        prob = [1 1 1 1 1 2]; % 16.7% chance of silent trial
    case (strcmpi(percent,'28.6')==1)
        prob = [1 1 1 1 1 2 2]; % 28.6% chance of silent trial
    case (strcmpi(percent,'33.3')==1)
        prob = [1 1 1 1 2 2]; % 33.3% chance of silent trial
    case (strcmpi(percent,'40')==1)
        prob = [1 1 1 2 2]; % 40.0% chance of silent trial
    case (strcmpi(percent,'50')==1)
        prob = [1 1 2 2]; % 50.0% chance of silent trial
    case (strcmpi(percent,'75')==1)
        prob = [1 2 2 2]; % 75.0% chance of silent trial
    case (strcmpi(percent,'90')==1)
        prob = [1 2 2 2 2 2 2 2 2 2]; % 90.0% chance of silent trial
    otherwise
        disp("Error with propability... check function");
end

end