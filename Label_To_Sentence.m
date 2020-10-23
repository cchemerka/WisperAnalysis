%% Bad channels for 01 13 136 

%Path = 'C:\Users\Colleen\Documents\Sentences\Sentences\'
Path = 'F:\Sentences\';
filename = [Path,'80Trials_SentenceMix.txt']; 
fileID = fopen(filename,'r');
fclose(fileID);
SentenceMixed = readtable(filename,'ReadVariableNames', false)
SentenceMixed = table2cell(SentenceMixed);

Trial = 1

EventName = string({Events.label}');
EventNr_2 = strip(EventName, 'left','E');
EventNr = []
for i = 1:length(EventNr_2)
   if contains(EventNr_2(i),'_')
       tmp = split(EventNr_2(i),'_');
       EventNr_2(i) = tmp(1)
   end
   EventNr(i) = str2num(EventNr_2(i));
end
EventNr = EventNr'

idx = length(EventName);
SentenceTrial = string([]);

tr = 1
for ii = 2 : 3 : idx-1
    SentenceNr = EventNr(ii)
    SentenceTrial(tr) = string(SentenceMixed(SentenceNr,1))
    tr = tr+1
end 

SentenceTrial = SentenceTrial'

disp(['Save Sentences'])
save('-v7.3',[Path,'Sentence_Mixed_Trial',num2str(Trial),'.txt'],'SentenceTrial');
%clear SentenceTrial

    
    