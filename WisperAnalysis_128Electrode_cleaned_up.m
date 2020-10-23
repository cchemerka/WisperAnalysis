%load('C:\Users\Colleen\Documents\brainstorm_db\Protocol01\data\Whisper01\Ch_Whisper01_1.mat')
%load('G:\EEG Analyse\Whisper01\RD_Whisper01_1.mat')

%Path = 'C:\Users\Colleen\Documents\WisperAnalysis\';
%Path = '\\tsclient\C\Users\wendlinr\Documents\Wisper\'


%% Settings:
clear
Path = 'C:\Users\Markus.Eiger\Desktop\Wisper\';
Channel_info = importdata([Path,'Ch_Whisper01_1.mat']);
RD_Whipser01_1 = importdata([Path,'RD_Whisper01_1.mat']);
load([Path,'128_Electrode_Pos_for_subplot.mat'])

H.sf = 10000; % sampling frequency
baseline_start = 2 %in sec
baseline_end = 3 %in sec



START_ONSET = 3 * H.sf;
END_OFFSET = 5 * H.sf;
STEPSIZE = 3; %every 3rd event is trigger onset








%%

baseline = baseline_start*H.sf:baseline_end*H.sf;
clear baseline_start baseline_end


[Events]=Wisper_sort(RD_Whipser01_1);%Import sorted events for Trigger onsets

idx = length(Events);
Channel_size  = length(Channel_info.Channel);
Channel_aaa = Channel_info.Channel(1,:);
Channel_names = string({Channel_aaa.Name}');

clear Channel_info


Trial = 1;
EEG_cutout = [];

% high pass filter
[B,A] = butter(2,0.0004,'high');
for chan=1:Channel_size;
     EEG_filt(chan,:)= filtfilt(B,A,RD_Whipser01_1.F(chan,:)); 
end


% cutting out the trials
tr = 1;
for ii = 2:STEPSIZE:idx
        StartPoints = round(Events(ii).times*H.sf); %from sec to ms
        %EEG_cutout(tr,:,:) = RD_Whipser01_1.F(1:20,StartPoints-START_ONSET:StartPoints+END_OFFSET);
        EEG_cutout(tr,:,:) = EEG_filt(:,StartPoints-START_ONSET:StartPoints+END_OFFSET);
        tr = tr + 1;
end 

clear idx ii tr
clear RD_Whipser01_1 EEG_filt


%cutting out non eeg channels
Channel_aaa(73) = [];
Channel_aaa(33:40) = [];
Channel_names(73) = [];
Channel_names(33:40) = [];
EEG_cutout(:,73,:) = [];
EEG_cutout(:,33:40,:) = [];
Channel_size = 128;


%comm.avg

%EEG_cutout_CAR(:,:,:) = EEG_cutout(:,:,:) - repmat(mean(EEG_cutout(:,:,:),2),[1,size(EEG_cutout,2),1]);




%calculate Potential and save


% baseline calculation
EEG_based_all = EEG_cutout_CAR - repmat(median(EEG_cutout_CAR(:,:,baseline),3),[1,1,size(EEG_cutout_CAR,3)]);

% median over trials
EEG_all_av_based(:,:) = squeeze(median(EEG_based_all,1));

disp(['Save Potential'])
save('-v7.3',[Path,'Potentials_Trial',num2str(Trial),'.mat'],'EEG_all_av_based');


%% Wavelet10k

 for channel = 1:Channel_size
        disp(['computing wavelet data from channel Nr ',num2str(channel),' out of ',num2str(size(EEG_cutout,2))])
        Channel_Data = squeeze(EEG_cutout(:,channel,:));
        [waveletDataAllTrialsPower] = wavelet_cwt_new3(Channel_Data',H);
        
        % baseline correction and averaging of wavelet (up to 50Hz)
        EEG_thinking_wavelet(:,:,:) = waveletDataAllTrialsPower(:,1:50,:);
        EEG_based(:,:,:) = EEG_thinking_wavelet./repmat(median(EEG_thinking_wavelet(:,:,baseline),3),[1,1,size(EEG_thinking_wavelet,3)]);
        EEG_based_averaged(channel,:,:) = squeeze(median(EEG_based(:,:,:),1));
        clear Channel_Data waveletDataAllTrialsPower EEG_thinking_wavelet EEG_based
 end
 
 %clear EEG_cutout

 disp(['Save Wavelet of Trial ',  num2str(Trial)])
 save('-v7.3',[Path,'Wisper_wavelet_averaged_and_based_Trial',num2str(Trial),'.mat'],'EEG_based_averaged');
 
 
 
 %%
 
% Wavelet for downsampled data

EEG_cutout_ds=EEG_cutout(:,:,1:20:end);
H.sf=500;
baseline_ds = 1000:1500;

 for channel = 1:Channel_size
        disp(['computing wavelet data from channel Nr ',num2str(channel),' out of ',num2str(size(EEG_cutout,2))])
        Channel_Data = squeeze(EEG_cutout_ds(:,channel,:));
        [waveletDataAllTrialsPower] = wavelet_cwt_new3(Channel_Data',H);
        
        % baseline correction and averaging of wavelet (up to 250Hz)
        EEG_thinking_wavelet(:,:,:) = waveletDataAllTrialsPower(:,1:250,:);
        EEG_based(:,:,:) = EEG_thinking_wavelet./repmat(median(EEG_thinking_wavelet(:,:,baseline_ds),3),[1,1,size(EEG_thinking_wavelet,3)]);
        EEG_based_averaged(channel,:,:) = squeeze(median(EEG_based(:,:,:),1));
        clear Channel_Data waveletDataAllTrialsPower EEG_thinking_wavelet EEG_based
 end
 
 %clear EEG_cutout

 %disp(['Save Wavelet of Trial ',  num2str(Trial)])
 disp(['Save Wavelet'])
 save('-v7.3',[Path,'Wisper_wavelet_averaged_and_based_Trial_ds_500',num2str(Trial),'.mat'],'EEG_based_averaged');
 


 
%% figures potential

figure
h0 = title(['Trial',num2str(Trial)]);



for channel=1:size(Channel_names,1)
    
    pos = [0.5 + Coord(channel,1) 0.5 + Coord(channel,2) 0.03 0.03];      
    subplot('Position',pos)
    hold on
    h = plot(squeeze(EEG_all_av_based(channel,:)));
    set(h,'ButtonDownFcn','call_copy');
    axis tight
    set(gca,'YDir','normal')
    set(gca,'YTickLabel',[-3:1:3])
    set(gca,'YTick',[-3:1:3])
    set(gca,'XTick',(10000:10000:75000))
    set(gca,'XTickLabel',[0:13])
    set(gca,'ylim',[-10*10^-6 10*10^-6]);
    set(gca,'xlim',[10000 70000]);
    hold on
    %h1=vline(5000,'k-'); set(h1,'linewidth',2)
    %hold on
    title(['Channel ',Channel_names(channel,:)])      
end 

%% Figures wavelet

figure
h0 = title(['Trial ',num2str(Trial)]);
    
    for channel=1:size(Channel_names,1)
       
        pos = [0.95*(0.5 + Coord(channel,1)) 0.95*(0.5 + Coord(channel,2)) 0.035 0.035];
        subplot('Position',pos)
        hold on
        h = imagesc(squeeze(EEG_based_averaged(channel,:,:)));
        set(h,'ButtonDownFcn','call_copy');
        axis tight
        set(gca,'YDir','normal')
        set(gca,'CLim',[0.5 1.5])
        set(gca,'YTickLabel',[0:10:50])
        set(gca,'YTick',[0:10:50])
        set(gca,'XTick',(1:10000:130000))
        set(gca,'XTickLabel',[0:13])
        set(gca,'ylim',[1 50]);
       % h1=vline(5000,'w-'); set(h1,'linewidth',1) 
        title(['Channel ',Channel_names(channel,:)])
    end

%% Figures wavelet downsampled

figure
h0 = title(['Trial ',num2str(Trial)]);
    
    for channel=1:size(Channel_names,1)
       
        pos = [0.95*(0.5 + Coord(channel,1)) 0.95*(0.5 + Coord(channel,2)) 0.035 0.035];
        subplot('Position',pos)
        hold on
        h = imagesc(squeeze(EEG_based_averaged(channel,:,:)));
        set(h,'ButtonDownFcn','call_copy');
        axis tight
        set(gca,'YDir','normal')
        set(gca,'CLim',[0.5 1.5])
        set(gca,'YTickLabel',[0:25:250])
        set(gca,'YTick',[0:25:250])
        set(gca,'XTick',(500:500:3500))
        set(gca,'XTickLabel',[0:6])
        set(gca,'ylim',[1 250]);
        set(gca,'xlim',[500 3500]);
       % h1=vline(5000,'w-'); set(h1,'linewidth',1) 
        title(['Channel ',Channel_names(channel,:)])
    end