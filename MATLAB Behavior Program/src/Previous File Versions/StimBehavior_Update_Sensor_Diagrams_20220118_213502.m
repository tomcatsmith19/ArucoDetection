function StimBehavior_Update_Sensor_Diagrams(handles,status,varargin)

%
%StimBehavior_Update_Sensor_Diagrams.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_UPDATE_SENSOR_DIAGRAMS updates the displays that show
%   the status of interaction sensors on the tactile carousel and
%   left/right pellet receivers in the StimBehavior task.
%   
%   UPDATE LOG:
%   11/30/2021 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Update_Sensor_Diagrams.m
%

if nargin > 2                                                               %If a variable input argument was passed...
    
end

handles.diagram.carousel.disc.FaceColor = ...
    [(0.75 + 0.25*status(1)) 0.75 0.75];                                    %Update the carousel diagram face color.
set(handles.diagram.pellet_receiver(1),'FaceColor',...
    [(0.75 + 0.25*status(2)) 0.75 0.75]);                                   %Update the left pellet receiver face color.
set(handles.diagram.pellet_receiver(2),'FaceColor',...
    [(0.75 + 0.25*status(3)) 0.75 0.75]);                                   %Update the right pellet receiver face color. 