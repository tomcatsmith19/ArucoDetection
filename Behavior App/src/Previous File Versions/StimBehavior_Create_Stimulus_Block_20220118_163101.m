function stim_block = StimBehavior_Create_Stimulus_Block(handles)

%
%StimBehavior_Create_Stimulus_Block.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_CREATE_STIMULUS_BLOCK creates a new randomized block of 
%    stimuli for testing in the StimBehavior task.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Create_Stimulus_Block.m.
%



i = vertcat(handles.l_stim_i,handles.r_stim_i,handles.c_stim_i);            %Concatenate all of the active stimulus indices.
stim_block = [i, 'R'*ones(size(i))];                                        %Create a stimulus block with two columns (stimulus index and target feeder).
for i = 1:size(stim_block,1)                                                %Step through each row of the stimulus block.
    if any(stim_block(i,1) == handles.l_stim_i)                             %If the stimulus is a left-hand stimulus...
        stim_block(i,2) = 'L';                                              %Mark it with as a left-feeder stimulus.
    elseif any(stim_block(i,1) == handles.c_stim_i)                         %If the stimulus is a catch stimulus...
        stim_block(i,2) = 'C';                                              %Mark it as a catch trial..
    end
end
i = randperm(size(stim_block,1));                                           %Create random indices for the block.
stim_block = stim_block(i,:);                                               %Randomize the stimulus block.