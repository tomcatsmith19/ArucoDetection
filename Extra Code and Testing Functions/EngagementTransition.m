% Prompt the user to select an Excel file
[filename, filepath] = uigetfile('*.xlsx', 'Select an Excel file');
if isequal(filename, 0)
    % User canceled file selection
    disp('File selection canceled.');
    return;
end

% Create the full file path
fullFilePath = fullfile(filepath, filename);

% Load the Excel file
try
    AllSessionData = xlsread(fullFilePath, 'Sheet2', 'C2:C1048576'); % Adjust the range as needed
    disp('Data loaded successfully.');
catch
    disp('Error loading data from the Excel file.');
end

% Initialize variables
SegmentDurations = []; % Initialize the array to store segment durations
currentSegment = AllSessionData(1); % Initialize the current segment
currentTrials = 1; % Initialize the number of trials
currentColor = 'g'; % Initialize the color

% Iterate through AllSessionData to identify consecutive segments
for i = 2:length(AllSessionData)
    if AllSessionData(i) == currentSegment
        % The segment continues, increment the number of trials
        currentTrials = currentTrials + 1;
    else
        % Transition to a new segment
        if currentSegment == 0
            currentColor = 'g'; % Set color to green for consecutive 0's
        elseif currentSegment == 2
            currentColor = 'r'; % Set color to red for consecutive 2's
        end
        
        SegmentDurations = [SegmentDurations, struct('trials', currentTrials, 'color', currentColor)];
        currentSegment = AllSessionData(i);
        currentTrials = 1; % Reset the number of trials
    end
end

% Add the duration of the last segment
if currentSegment == 0
    currentColor = 'g'; % Set color to green for consecutive 0's
elseif currentSegment == 2
    currentColor = 'r'; % Set color to red for consecutive 2's
end
SegmentDurations = [SegmentDurations, struct('trials', currentTrials, 'color', currentColor)];

% Calculate the total number of trials
totalTrials = sum([SegmentDurations.trials]);

% Create a figure for the plot
figure;

% Initialize the start trial number
startTrial = 1;

% Iterate through the trial segments and plot rectangles
for i = 1:length(SegmentDurations)
    % Get the number of trials and color for the current segment
    trials = SegmentDurations(i).trials;
    color = SegmentDurations(i).color;
    
    % Calculate the end trial number for the current segment
    endTrial = startTrial + trials - 1;
    
    % Plot a rectangle for the trial segment with the corresponding color
    rectangle('Position', [startTrial, 0, trials, 0.5], 'FaceColor', color);
    
    % Update the start trial number for the next segment
    startTrial = endTrial + 1;
    
    % Hold on to overlay rectangles
    hold on;
end

% Set axis limits based on the total number of trials
xlim([1, totalTrials]);

% Set axis labels and title
xlabel('Trial Number');
title('Transitions Between Engaged and Distracted');

% Remove y-axis ticks and labels
yticks([]);

% Hold off to end the overlay
hold off;
