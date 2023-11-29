function handles = StimBehavior_Default_Config(handles)

%
%StimBehavior_Default_Config.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_DEFAULT_CONFIG loads the default configuration settings 
%   for the StimBehavior task.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Task_Default_Config.m.
%

handles.stage_mode = 2;                                                     %Set the default stage selection mode to 2 (1 = local TSV file, 2 = Google Spreadsheet).
handles.stage_url = ['https://docs.google.com/spreadsheets/d/e/2PACX-1v'...
    'Qusnqe1NSFKUlqpTIin846wkaIwTm6ZXesUmhU9ZzewIUbMchND-t2C0aCNuN5Ox4j'...
    'I30t1YkRCcAu/pub?gid=0&single=true&output=tsv'];                       %Set the google spreadsheet address.
handles.stage_edit_url = ['https://docs.google.com/spreadsheets/d/1oAdB'...
    'S_VpaoiSZUWCzM44ZjdnsxqIE-lvSOmZDiaqZNg/'];                            %Set the google spreadsheet edit URL.
handles.disc_urls = {['https://docs.google.com/spreadsheets/d/e/2PACX-1'...
    'vQusnqe1NSFKUlqpTIin846wkaIwTm6ZXesUmhU9ZzewIUbMchND-t2C0aCNuN5Ox4'...
    'jI30t1YkRCcAu/pub?gid=344386055&single=true&output=tsv']};             %Set the disc definition spreadsheet addresses.

handles.datapath = 'C:\Vulintus Data\StimBehavior Task\';                   %Set the primary local data path for saving data files.
handles.subject = [];                                                       %Create a field to hold the rat's name.
handles.debounce = 0;                                                       %Don't debounce the signal by default.
handles.ir_thresh = 1023/2;                                                 %Set the default infrared beam threshold.
handles.enable_error_reporting = 1;                                         %Enable automatic error reports by default.
handles.err_rcpt = 'drew@vulintus.com';                                     %Automatically send any error reports to Drew Sloan.

% handles = StimBehavior_Load_Disc_Definitions(handles);                      %Load the text disc definitions.

handles.booth_number = 1;                                                   %Set the booth number.