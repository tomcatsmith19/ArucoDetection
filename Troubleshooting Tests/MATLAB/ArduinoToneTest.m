% add all necessary files to path folder
addpath(genpath('src'));
addpath(genpath('Required Vulintus Toolbox Functions'));

ctrl = Connect_StimBehavior_Controller;

x = 0;
for i = 1:100
    ctrl.set_tone_dur(500);
    ctrl.set_tone_freq(6000-x);
    ctrl.play_tone(1);
    disp(6000-x);
    pause(1);
    x = x + 100;
end

ctrl.set_tone_dur(500);
ctrl.set_tone_freq(6000);
ctrl.play_tone(1);


% pause(3)