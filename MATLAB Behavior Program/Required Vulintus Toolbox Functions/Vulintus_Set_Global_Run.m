function Vulintus_Set_Global_Run(~,~,run_val)

%
%Vulintus_Set_Global_Run.m - Vulintus, Inc.
%
%   VULINTUS_SET_GLOBAL_RUN declares a global variable "run" and then sets
%   the value of that variable. The global "run" variable is used thoughout
%   Vulintus behavior programs to control monitoring loops and transistions
%   between program functions.
%   
%   UPDATE LOG:
%   11/30/2021 - Drew Sloan - Function first create to fix issues with code
%       directly evaluated from uibutton ButtonPushedFcn callbacks.
%

global run;                                                                 %Declare a global run variable.
run = run_val;                                                              %Set the run variable to the specified value.
fprintf(1,'global run = %1.1f\n',run);                                      %Print the value of the global run variable to the command line.