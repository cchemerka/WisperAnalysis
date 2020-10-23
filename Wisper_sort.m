
function [Events]=Wisper_sort(RD_Whipser01_1)

Events = RD_Whipser01_1.Events;

last_Event = Events(length(Events));
trials = length(Events)-1;
j = 1;

for i = 1:trials
    if length(Events(i).times) == 2
        tmp = Events(i);
        
        Events(i).epochs = tmp.epochs(1);
        Events(i).times = tmp.times(1);
        Events(i).channels = tmp.channels(1);
        Events(i).notes = tmp.notes(1);
        
        Events(trials+j).label = [tmp.label, '_2'];
        Events(trials+j).color = tmp.color;
        Events(trials+j).epochs = tmp.epochs(2);
        Events(trials+j).times = tmp.times(2);
        Events(trials+j).reactTimes = tmp.reactTimes;
        Events(trials+j).select = tmp.select;
        Events(trials+j).channels = tmp.channels(2);
        Events(trials+j).notes = tmp.notes(2);
        
        j = j+1;             
    end
end

trials_new = length(Events);

for k = 1:trials_new
    if (length(Events(k).times)) == 80
        tmp = Events(k);
        
        for m = 1:80
            Events(trials_new+m).label = [tmp.label, '_', num2str(m)];
            Events(trials_new+m).color = tmp.color;
            Events(trials_new+m).epochs = tmp.epochs(m);
            Events(trials_new+m).times = tmp.times(m);
            Events(trials_new+m).reactTimes = tmp.reactTimes;
            Events(trials_new+m).select = tmp.select;
            Events(trials_new+m).channels = tmp.channels(m);
            Events(trials_new+m).notes = tmp.notes(m);
        end
        %Events(k) = [];
        Events(k).times = 273.5710 + 3;  %otherwise rhythm (to get onsets) gets disturbed
    end
end

Events(length(Events)+1) = last_Event;


[~,index] = sortrows([Events.times].'); Events = Events(index); clear index

clear i j k m last_Event tmp trials_new trials

end