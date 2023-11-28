function serial_codes = StimBehavior_Load_Serial_Codes

%StimBehavior_Load_Serial_Codes.m - Vulintus, Inc., 2022
%
%   STIMBEHAVIOR_LOAD_SERIAL_CODES synchronizes the serial communication
%   codes between the MATLAB scrips and the Arduino-based firmware for the
%   StimBehavior task. This file is currently manually updated, but will be
%   configured for programmatic synchronization in a future update.
%
%   UPDATE LOG:
%   02/03/2022 - Drew Sloan - Function first created, adapted from
%       Load_LED_Detection_Task_Serial_Codes.m.
%

serial_codes = [];

serial_codes.SKETCH_VERIFY = 1;                                             %Serial command to return the sketch ID.
serial_codes.GET_SKETCH_VER = 2;                                            %Serial command to return the sketch version.
serial_codes.STREAM_ENABLE = 3;                                             %Serial command to enable/disable streaming.
serial_codes.TRIGGER_FEEDER = 4;                                            %Serial command for triggering the feeder.
serial_codes.STOP_FEED = 5;                                                 %Serial command for stopping a feeder trigger.
serial_codes.SET_FEED_TRIG_DUR = 6;                                         %Serial command for setting the feeder trigger duration.
serial_codes.RETURN_FEED_TRIG_DUR = 7;                                      %Serial command for returing the current feeder trigger duration.
serial_codes.PLAY_TONE = 8;                                                 %Serial command for starting a one-shot tone.
serial_codes.STOP_TONE = 9;                                                 %Serial command for stopping a currently-playing tone.
serial_codes.SET_TONE_INDEX = 10;                                           %Serial command for setting the current tone index.
serial_codes.RETURN_TONE_INDEX = 11;                                        %Serial command for returing the current tone index.
serial_codes.SET_TONE_FREQ = 12;                                            %Serial command for setting the current tone frequency.
serial_codes.RETURN_TONE_FREQ = 13;                                         %Serial command for returning the current tone frequency.
serial_codes.SET_TONE_DUR = 14;                                             %Serial command for setting the current tone duration.
serial_codes.RETURN_TONE_DUR = 15;                                          %Serial command for returning the current tone duration.
serial_codes.RETURN_NOSEPOKE = 26;                                          %Serial command for returning the current nosepoke status.
serial_codes.SAVE_1BYTE_EEPROM = 27;                                        %Serial command for saving 1 byte into EEPROM.
serial_codes.READ_1BYTE_EEPROM = 28;                                        %Serial command for reading 1 byte from EEPROM.
serial_codes.SAVE_2BYTES_EEPROM = 29;                                       %Serial command for saving 2 bytes into EEPROM.
serial_codes.READ_2BYTES_EEPROM = 30;                                       %Serial command for reading 2 bytes from EEPROM.
serial_codes.SAVE_4BYTES_EEPROM = 31;                                       %Serial command for saving 4 bytes into EEPROM.
serial_codes.READ_4BYTES_EEPROM = 32;                                       %Serial command for reading 4 bytes from EEPROM.

serial_codes.EEPROM_BOOTH_NUM = 0;                                          %Set the EEPROM address for the booth number.