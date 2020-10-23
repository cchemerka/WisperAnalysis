%% Wavelet using matlab cwt function
function [waveletDataAllTrialsPower]=wavelet_cwt_new3(Data,H)
%function [waveletDataAllTrialsPower,waveletDataAllTrialsComplex]=wavelet_cwt(Data,H)


%load('A:\Blinks_and_saccades_phase_synchrony\ECG_data_for_correction\BD_all_ecg_stuff_remote\Data_BD_blink\NEWEST_BD_blink_new_onset_new.mat')
%load('A:\Blinks_and_saccades_phase_synchrony\ECG_data_for_correction\BD_all_ecg_stuff_remote\070209aa_0091_1_CAR_filt0.2_3_CAR_CAR.hdr.mat')

%load('F:\Markus_stuff\BD_all_ecg_stuff_remote\Data_BD_blink\NEWEST_BD_blink_new_onset_new.mat')
%load('F:\Markus_stuff\BD_all_ecg_stuff_remote\070209aa_0091_1_CAR_filt0.2_3_CAR_CAR.hdr.mat')



nfrq=H.sf/2;                                       % maximum frequency for wavelet analysis, e.g. Nyquist frequency
ntime=size(Data,1);                                % timelength of trials in sample points, e.g. +-1.5sec =~ 3073
nTrial=size(Data,2);                               % number of trials
%nChannel=H.noc;                                   % number of channels to be analysed
%baseline=1272:1480;                               % baseline period in sample points
scales = centfrq('cmor20-0.25',10)*H.sf./(1:nfrq);     % scales for wavelet resulting in pseudo frequency resolution of 1Hz
%waveletDataAllTrialsComplex(size(Data,2),nfrq,ntime)=zeros; % preallocate wavelet data all trials complex values: trials*frq*time
waveletDataAllTrialsPower(size(Data,2),nfrq,ntime)=zeros; % preallocate wavelet data all trials power values: trials*frq*time

%pValue(nfrq,ntime)=zeros;                          % preallocate pValue: frq*time




for trial=1:nTrial;
    %disp(['computing trial nr ',num2str(trial)])
    dataOnChannelTrial=Data(:,trial);
    waveletData= cwt(dataOnChannelTrial,scales,'cmor20-0.25');
    %waveletDataAllTrialsComplex(trial,:,:)=waveletData;
    waveletDataAllTrialsPower(trial,:,:)=abs(waveletData).^2;
end

% save('-v7.3',['F:\waveletDataAllTrialsComplex.mat'],'waveletDataAllTrialsComplex'); %save complex data e.g. for phase locking analysis

% calculate baseline corrected power

%waveletDataMedianPower=squeeze(median(waveletDataAllTrialsPower,1));         %calculate median power for baseline correction
%waveletDataAllTrialsPowerBased=waveletDataAllTrialsPower./repmat(median(waveletDataMedianPower(:,baseline),2)',[size(waveletDataAllTrialsPower,1),1,size(waveletDataAllTrialsPower,3)]);  %baseline correction
%waveletDataMedianPowerBased(:,:)=median(waveletDataAllTrialsPowerBased,1);   %calculate median power of baseline corrected data

%significance test for baseline corrected power

%     for frq=1:nfrq;
%          disp(['computing frequency ',num2str(nfrq),'Hz'])
%         for time=1:ntime;
%             pValue(frq,time)=signtest(squeeze(waveletDataAllTrialsPowerBased(:,frq,time)),1);
%         end
%     end
%
%save('-v7.3',['F:\waveletDataMedianPowerBased_and_pValue.mat'],'waveletDataMedianPowerBased','pValue');  %save median power of baseline corrected data and pValue
end
