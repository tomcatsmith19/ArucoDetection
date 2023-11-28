% add all necessary files to path folder
addpath(genpath('src'));
addpath(genpath('Required Vulintus Toolbox Functions'));

ctrl = Connect_StimBehavior_Controller;

ctrl.set_tone_dur(500);
ctrl.set_tone_freq(6000);
ctrl.play_tone(1);
ctrl.feed();
nosepoke_vals = [0,0,0,0,0,0];

while nosepoke_vals(1) ~= 1
     nosepoke_vals = bitget(ctrl.get_nosepoke(),1:6);
end

ctrl.feed();

%clear ctrl;