%does stimulation on channel 1 (stimulator 1) using predefined rectangular pulse

err = PS_InitAllStim
[NStim, err] = PS_GetNStim
[NChan, err] = PS_GetNChannels(1)

err = PS_SetMonitorChannel(1, 10)
err = PS_SetRepetitions(1, 10, 0)
err = PS_LoadChannel(1,10)
err = PS_StartStimChannel(1,10)

input('Press Return to Stop');
err = PS_StopStimChannel(1,10);
err = PS_CloseStim(1)
