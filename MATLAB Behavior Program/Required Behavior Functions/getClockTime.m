% function to get the exact real world time and return the total number of
% seconds for that timestamp
function totalSeconds = getClockTime()
    x = clock;
    hours = x(4)*3600;
    minutes = x(5)*60;
    seconds = x(6);
    totalSeconds = hours + minutes + seconds;
end

