%% SETTINGS
patient = 'WISPER02';
% Add Path and load data
datapath = 'H:\AG Ball\RawData NeurOne\WISPER02';

path(path, datapath)

cd(datapath)
a = dir('*.mat');

for r = 1 : numel(a)
    WisperData = load([datapath,'\',a(r).name(1:end-4)]);
 

    EEG_cutout_CAR = WisperData.trial_dat;
    % Define variables important for baseline 

    sf = 10000; % sampling frequency
    dsf = 10; %downsampling factor
    
    H.sf = sf / dsf; %Struct needed for function wavelet_cwt_new3 --> downsamples frequency
    
    baseline_start = 0.5 %in sec
    baseline_end = 0.9 %in sec


    %% Analysis Start - Baseline 

    baseline = baseline_start*(sf/10):baseline_end*(sf/10);
    clear baseline_start baseline_end

    % baseline calculation

    EEG_based_all = EEG_cutout_CAR - repmat(median(EEG_cutout_CAR(:,:,baseline),3),[1,1,size(EEG_cutout_CAR,3)]);
    
    % median over trials
    EEG_all_av_based(:,:) = squeeze(median(EEG_based_all,1));

    disp(['Save Potential'])
    save('-v7.3',[datapath, '\', patient,'_avPotentials_Dataset',num2str(r),'.mat'],'EEG_all_av_based');
    
    %% Wavelet 

    for channel = 1 : size(WisperData.EEG_ses.chanlocs,2)
            disp(['computing wavelet data from channel Nr ',num2str(channel),' out of ',num2str(size(EEG_cutout_CAR,2))])
            Channel_Data = squeeze(EEG_cutout_CAR(:,channel,:));
            [waveletDataAllTrialsPower] = wavelet_cwt_new3(Channel_Data',H);

            % baseline correction and averaging of wavelet (up to 50Hz)
            EEG_WISPER_wavelet(:,:,:) = waveletDataAllTrialsPower(:,1:50,:);
            EEG_based(:,:,:) = EEG_WISPER_wavelet./repmat(median(EEG_WISPER_wavelet(:,:,baseline),3),[1,1,size(EEG_WISPER_wavelet,3)]);
            EEG_based_averaged(channel,:,:) = squeeze(median(EEG_based(:,:,:),1));

            clear Channel_Data waveletDataAllTrialsPower EEG_WISPER_wavelet EEG_based
     end

     clear EEG_cutout_CAR

     disp(['Save Wavelet of ' patient, ' Dataset ',  num2str(r)])
     save('-v7.3',[datapath,'\', patient, '_Wavelet_avANDba_Dataset',num2str(r),'.mat'],'EEG_based_averaged');

    %% Sort Channels form 128 to 64 
    
     for rr=1:numel(EEG_ses.chanlocs)

        L = EEG_ses.chanlocs(rr).labels;

        recorded(rr) = sum(strcmpi(L,Channels));

        disp([L,'    ',num2str(recorded(rr))])

     end

     test = Channels(find(recorded));
     test2 = Coord(find(recorded),:);
     
     %% figure potential

    figure
    h0 = title([patient,' - Potential averaged and based Dataset ',num2str(r)]);

    for channel=1 : size(WisperData.EEG_ses.chanlocs,2)

        pos = [0.5 + test2(channel,1) 0.5 + test2(channel,2) 0.03 0.03];      
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
        title(['Channel ',WisperData.EEG_ses.chanlocs(:,channel).labels])      
    end 

    %% Figures wavelet

    figure
    h0 = title([patient,' - Wavelet averaged and based Dataset ',num2str(r)]);

        for channel = 1:size(WisperData.EEG_ses.chanlocs,1)

            pos = [0.95*(0.5 + lay.pos(channel,1)) 0.95*(0.5 + lay.pos(channel,2)) 0.035 0.035];
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
            title(['Channel ',WisperData.EEG_ses.chanlocs(:,channel).labels])
        end
end
