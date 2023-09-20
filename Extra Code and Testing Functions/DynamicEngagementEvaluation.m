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

% Combine data from columns A and C into a single column
CombinedData = sort([Sheet3DataA; Sheet3DataC]);

% Sort the combined data from smallest to largest
trialTimeData = sort(CombinedData);
AllSessionData(:, 2) = trialTimeData(:, 1);

% Step 4: Bin the rows in segments of 5 minutes
binSize = 5; % Minutes per bin
maxTime = max(AllSessionData(:, 2));
numBins = ceil(maxTime / binSize);

% Initialize variables to store the current bin's start and end times
binStart = 0;
binEnd = binSize;

for i = 1:numBins
    % Filter rows within the current bin
    binRows = AllSessionData(:, 2) >= binStart & AllSessionData(:, 2) < binEnd;
    
    % Calculate the probability of 0's within the bin
    binData = AllSessionData(binRows, 1);
    numZeros = sum(binData == 0);
    numTwos = sum(binData == 2);
    ProbabilityOfEngagement_5min_Bins(i) = numZeros / (numZeros + numTwos) * 100;
    
    % Update bin start and end times for the next iteration
    binStart = binEnd;
    binEnd = binStart + binSize;
end

% Initialize ColorAssignment array
ColorAssignment = strings(size(AllSessionData, 1), 1);

% Assign "green" to indices with 0s and "red" to indices with 2s
ColorAssignment(AllSessionData(:, 1) == 0) = '#B3E48E';
ColorAssignment(AllSessionData(:, 1) == 2) = '#E07F80';

% Find the maximum time in AllSessionData column 2
maxTime = max(AllSessionData(:, 2));

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
        rectangle('Position', [currentTime, 0, time - currentTime, 1], 'FaceColor', currentColor, 'EdgeColor', 'none');
        
        % Update the current time and color
        currentTime = time;
        currentColor = color;
    end
end

% Plot the last rectangle with no border
rectangle('Position', [currentTime, 0, maxTime - currentTime, 1], 'FaceColor', currentColor, 'EdgeColor', 'none');

% Define the threshold for 50%
threshold = 50;

% Initialize a variable to store the time point where percentage drops below 50%
timePointBelowThreshold = 0;

% Find the time point where percentage drops below 50%
for i = 1:numBins
    if ProbabilityOfEngagement_5min_Bins(i) < threshold
        timePointBelowThreshold = (i - 1) * binSize; % Use the start time of the bin
        break;
    end
end

% Add a thick blue vertical line at the time point below 50%
if timePointBelowThreshold > 0
    hold on; % Allow multiple plot objects in the same figure
    plot([timePointBelowThreshold, timePointBelowThreshold], [0, 1], 'b', 'LineWidth', 2);
    hold off; % Release hold for further plotting
end

% Set x-axis limits and labels
xlim([0, maxTime]);
xlabel('Time (minutes)');

% Remove y-axis labels, tick marks, and values
set(gca, 'YTick', []);
set(gca, 'YTickLabel', []);

% Set the title
title('Transitions Between Engaged and Distracted');

% Display the plot
grid on;