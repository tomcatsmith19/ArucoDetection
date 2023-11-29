function handles = StimBehavior_Create_Session_Plots(handles, session)

%
%StimBehavior_Create_Session_Plots.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_CREATE_SESSION_PLOTS initializes all of the GUI plots
%   at the start of a StimBehavior task behavioral session.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Create_Session_Plots.m.
%

if ~all(ishandle([handles.diagram.carousel.disc,...
        handles.diagram.pellet_receiver]))                                  %If the disc and pellet receivers diagrams aren't initialized.
    handles = StimBehavior_Create_Sensor_Diagrams(handles);                 %Call the function to create them.
end
if ~ishandle(handles.force_plot)                                            %If the force plot isn't yet initialized...
    handles = StimBehavior_Create_Force_Plot(handles);                      %Call the function to create it.
end
if ~isfield(handles,'psych_plots') || ...
        ~all(ishandle(handles.psych_plots.bar.h(:))) || ....
        ~all(ishandle(handles.psych_plots.hist.h(:)))                       %If the psychometric plots aren't initiliazed...
    handles.psych_plots = ...
        StimBehavior_Initialize_Psychometric_Plot(handles);                 %Create the psychometric plots.
end
StimBehavior_Update_Psychometric_Plot(handles.psych_plots,...
    session.counts,[]);                                                     %Update the psychometric plots with the current and historical performance. 