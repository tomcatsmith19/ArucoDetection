function StimBehavior_Main_Loop(fig)

%
%StimBehavior_Main_Loop.m - Vulintus, Inc.
%
%   StimBehavior_MAIN_LOOP switches between the various loops of the 
%   StimBehavior task program based on the value of the run variable. This 
%   loop is necessary because the global run variable can only be used to 
%   modify a running loop if the function calling it has fully executed.
%
%   Run States:
%       - run = 0 >> Close program.
%       - run = 1 >> Idle mode.
%           - run = 1.1 >> Select stage (change idle mode parameters).
%           - run = 1.2 >> Re-initialize idle plot varibles.
%           - run = 1.3 >> Manual feed.
%           - run = 1.4 >> Reset Baseline.
%           - run = 1.5 >> Launch a webcam preview.
%           - run = 1.6 >> Select subject.
%       - run = 2 >> Behavior session.
%           - run = 2.1 >> Pause session.
%           - run = 2.2 >> Manual feed.
%           - run = 2.3 >> Launch a webcam preview.
%           - run = 2.4 >> Reset Baseline.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Main_Loop.m.
%

global run                                                                  %Create the global run variable.

while run ~= 0                                                              %Loop until the user closes the program.
    switch run                                                              %Switch between the various run states.
        
        case 1                                                              %Run state 1 = Idle Mode.
            StimBehavior_Idle(fig);                                         %Call the idle loop.  
            
        case 2                                                              %Run state 2 = Behavior Session.
            StimBehavior_Behavior_Loop(fig);                                %Call the behavioral session loop.
            
    end        
end

Vulintus_Behavior_Close(fig);                                               %Call the function to close the behavior program.