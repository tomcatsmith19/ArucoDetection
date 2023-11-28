function trial = StimBehavior_Create_Trial_Plot(handles, session, trial)

%
%StimBehavior_Create_Trial_Plot.m - Vulintus, Inc.
%
%   This function creates a diagram of the current trial on the 
%   psychophysical plot axes for the tactile discrimination task.
%   
%   UPDATE LOG:
%   10/06/2021 - Drew Sloan - Function first implemented, adapted from
%       LED_Detection_Task_Create_Trial_Plot.m.
%

% cla(handles.psych_ax);                                                      %Create the psychophysical plot axes.
% hold(handles.psych_ax, 'on');                                               %Hold the axes for multiple plots.
% x_limits = [-0.05, 1.05]*trial.dur;                                         %Calculate x-axis bounds.           
% set(handles.psych_ax,'xlim',x_limits,'ylim',[-0.1,1.1]);                    %Set the x- and y-axis limits.
% 
% ipi = trial.vib_ipi/1000;                                                   %Convert the inter-pulse interval to seconds.
% pulse_dur = trial.vib_dur/1000;                                             %Convert the pulse duration to seconds.
% y = [0 1 1 0 0];                                                            %Create y-coordinates for a box showing the hit window.
% x = trial.hold_time + handles.hitwin*[0 0 1 1 0];                           %Calculate x-coordinates for a box showing the hit window.
% fill(x,y,[0.75 0.75 0.75],...
%         'edgecolor',[0.75 0.75 0.75],...
%         'linewidth',2,...
%         'parent',handles.psych_ax);                                         %Create a filled rectangle for each pulse.
% for i = 1:trial.vib_n                                                       %Step through each pulse.
%     x = ipi*(i-1) + pulse_dur*[0 0 1 1 0];                                  %Create x-coordinates to show the pulse.
%     fh = fill(x,0.9*y,[0 0 0.5],...
%         'edgecolor','none',...
%         'parent',handles.psych_ax);                                         %Create a filled rectangle for each pulse.
%     if strcmpi(handles.task_mode,'burst')                                   %If the task is in burst mode...
%         set(fh,'ydata',0.1*y);                                              %Make the pulse shorter.
%     end
%     if i >= trial.gap_start && i <= trial.gap_stop                          %If this is the gap pulse...
%         if trial.catch == 1                                                 %If this is a catch trial...
%             set(fh,'facecolor',[0 0.5 0],...
%                 'edgecolor',[0 0.5 0]);                                     %Color the pulse red.
%         else                                                                %Otherwise...
%             set(fh,'facecolor',[0 0.5 0],...
%                 'edgecolor',[0 0.5 0],...
%                 'ydata',0.1*y);                                             %Color the pulse green.
%             if strcmpi(handles.task_mode,'burst')                           %If the task is in burst mode...
%                 set(fh,'ydata',0.9*y);                                      %Make the pulse taller.
%             end
%         end       
%     end    
% end
% line([0,0],[-0.1,1.1],...
%     'linestyle','--',...
%     'color','k',...
%     'parent',handles.psych_ax);                                             %Plot a line showing the trial start.
% line(x_limits,[0,0],...
%     'linestyle','-',...
%     'linewidth',2,...
%     'color','k',...
%     'parent',handles.psych_ax);                                             %Plot a line across the plot at zero.
% text(0,1.1,sprintf(' Trial #%1.0f',session.trial_num),...
%     'horizontalalignment','left',...
%     'verticalalignment','top',...
%     'fontweight','bold',...
%     'fontsize',10,...
%     'parent',handles.psych_ax);                                             %Label the plot.
% 
% trial.prog_line = line([0,0],[-0.1,1.1],...
%     'linestyle',':',...
%     'color','k',...
%     'linewidth',2,...
%     'parent',handles.psych_ax);                                             %Create a line to show the current time.

% str = sprintf(['%s - Starting Trial #%1.0f, '...
%     '%s, '...
%     'target feeder = %s, '...
%     'min. touch time = %1.2f s...'],...
%     datestr(trial.start_time,13),...
%     session.trial_num,...
%     trial.pad_label,...
%     trial.target_feeder,...
%     trial.hold_time);                                                       %Create a text string.
% Replace_Msg(handles.msgbox,str);                                            %Show the text string on the messagebox.