clear all;
clc;

prompt = "How long was the behavioral session (minutes): ";
totalSessionTime = input(prompt);

% Step 1: Select an excel file
[file, path] = uigetfile('*.xlsx', 'Select an Excel file');
if isequal(file,0)
    disp('User canceled the file selection');
    return;
end
excelFile = fullfile(path, file);

% Step 2: Open the excel file and extract data from Sheet2 Column C
data = xlsread(excelFile, 'Sheet2', 'C:C');
AllSessionData(:, 1) = data;

% Step 3: Combine and sort data from Sheet3 Columns A and C
% Load data from Sheet3 for combining and sorting
Sheet3DataA = xlsread(excelFile, 'Sheet3', 'A:A'); % Load data from column A
Sheet3DataC = xlsread(excelFile, 'Sheet3', 'C:C'); % Load data from column C
Sheet3DataE = xlsread(excelFile, 'Sheet3', 'E:E'); % Load data from column E

% Combine data from columns A and C into a single column
CombinedData = sort([Sheet3DataA; Sheet3DataC]);

% Combine data from column E now
CombinedData = sort([CombinedData; Sheet3DataE]);

% Sort the combined data from smallest to largest
trialTimeData = sort(CombinedData);
AllSessionData(:, 2) = trialTimeData(:, 1);

% Calculate the forward-moving rolling probabilities with a 5-minute window
binSize = 5; % Minutes per bin
maxTime = max(AllSessionData(:, 2));
timePoints = 0:maxTime; % Generate time points for the entire session

% Initialize ColorAssignment array
ColorAssignment = strings(size(AllSessionData, 1), 1);

% Assign "green" to indices with 0s and "red" to indices with 2s
ColorAssignment(AllSessionData(:, 1) == 0) = '#B9DBF4';
ColorAssignment(AllSessionData(:, 1) == 2) = '#E07F80';

% Initialize arrays to store rolling probabilities
RollingProbabilities = zeros(size(timePoints));

for i = 1:length(timePoints)
    windowStart = max(0, timePoints(i) - binSize); % Adjust for the back-heavy plot
    windowEnd = timePoints(i);
    
    % Filter rows within the current rolling window
    windowRows = AllSessionData(:, 2) >= windowStart & AllSessionData(:, 2) < windowEnd;
    
    % Calculate the probability of 0's within the rolling window
    windowData = AllSessionData(windowRows, 1);
    numZeros = sum(windowData == 0);
    numTwos = sum(windowData == 2);

    if (numZeros + numTwos) > 0
        RollingProbabilities(i) = 100-mean(windowData/2)*100;
    elseif windowEnd == 0
        RollingProbabilities(i) = 100; % Set to 100 for first value, since no data in the window yet
    else
    end
end

if maxTime < totalSessionTime
     dt = abs(AllSessionData(end,2)-AllSessionData(end-1,2));
     AllSessionData(end,1) = 2;
     AllSessionData = [AllSessionData; [2, maxTime+dt]; [2, totalSessionTime]];
     RollingProbabilities = [RollingProbabilities,0,0];
     ColorAssignment = [ColorAssignment; '#E07F80'; '#E07F80'];
     temp = timePoints(end);
     timePoints = [timePoints, temp+1, round(totalSessionTime)];

end

% Create a figure
figure;

% Define the initial time and color
currentTime = 0;
currentColor = ColorAssignment(1);

% Loop through AllSessionData and ColorAssignment
for i = 1:size(AllSessionData, 1)
    % Get the time and color for the current data point
    time = AllSessionData(i, 2);
    color = ColorAssignment(i);
    
    % If the color is the same as the previous value, extend the rectangle
    if strcmp(color, currentColor)
        continue;
    else
        % Plot a rectangle with the previous color and no border
        rectangle('Position', [currentTime, 0, time - currentTime, 100], 'FaceColor', currentColor, 'EdgeColor', 'none');
        
        % Update the current time and color
        currentTime = time;
        currentColor = color;
    end
end

% Plot the last rectangle with no border
rectangle('Position', [currentTime, 0, max(maxTime,totalSessionTime) - currentTime, 100], 'FaceColor', currentColor, 'EdgeColor', 'none');

% Define the threshold for 50%
threshold = 50;

% Find the time point where percentage drops below 50%
timePointBelowThreshold = timePoints(find(RollingProbabilities < threshold, 1, 'first'));

% Add a thick blue vertical line at the time point below 50%
if ~isnan(timePointBelowThreshold)
    hold on; % Allow multiple plot objects in the same figure
    plot([timePointBelowThreshold, timePointBelowThreshold], [0, 100], 'b', 'LineWidth', 4);
    hold off; % Release hold for further plotting
end

% Set x-axis limits and labels
xlim([0, max(maxTime,totalSessionTime)]);
xlabel('Time (minutes)');

% Set y-axis limits and label
ylim([0, 100]);
ylabel('Probability of Engagement (%)');

% Set the title
title('Back-Heavy Rectangular Kernel Convolution: Transitions Between Engagement and Distraction');

% Display the plot
grid on;

% Plot the forward-moving solid black line for rolling probabilities (reversed on x-axis)
hold on;
plot(timePoints, RollingProbabilities, 'k', 'LineWidth', 2); % Reverse the x-axis
hold off;

disp(RollingProbabilities);
