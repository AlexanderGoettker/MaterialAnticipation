function [xpos ypos xdeg ydeg events saccade pupil Bad_Trial] = load_eye(Name,t,sub);
% Function to load the raw eye data and convert them into deg

global datapath conv Figures Connector BlinkError % Get the global data
Bad_Trial = 0;
%% Load the respective trial

file = load([datapath,Name,Connector,'trial',num2str(t)]);

%% Check which eye is the relevant one

if file.trial(1,2)==-32768 % Check where you find the default value of the EyeLink
    xpos = file.trial(:,5);
    ypos = file.trial(:,6);
elseif file.trial(1,5) ==-32768
    xpos = file.trial(:,2);
    ypos = file.trial(:,3);
elseif file.trial(1,2)~=-32768 & file.trial(1,5)~=-32768 % If you have data from both eyes
    xpos = mean([file.trial(:,2) file.trial(:,5)],2); % Average their estimate
    ypos = mean([file.trial(:,3) file.trial(:,6)],2);
end


xdeg= (xpos-conv.pix_x/2).*conv.ppd_x; % Convert into degree
ydeg= (ypos-conv.pix_y/2).*conv.ppd_y.*-1; % Convert into degree and inverse them

xpos= (xpos-((conv.pix_x-sub.HorPix))/2); % Align them with the image
ypos= (ypos-((conv.pix_y-sub.VerPix))/2); % Aligm them with the image


%% Get other things from the file

% Events code when things happened Initialize the trial, Presentation of
% the static frame, start of the video, end of the video, end of the trial
events = find(file.trial(:,4) == 1) ;

saccades_raw = find(file.trial(:,7) == 1);  % These are the timepoints of all saccades
blinks_raw = find(file.trial(:,9) == 1); % Raw data for blinks
blinks = [];
pupil =  file.trial(:,8); % Pupil size


%% Detect saccade and blink on & offsets based on saccades_raw

number = find(diff(saccades_raw)> 1);

if isempty(number)
    saccade = [min(saccades_raw) max(saccades_raw)];
else
    for aa = 1:length(number)+1
        if aa == 1 % If it the first saccade
            saccade(aa,:) = [saccades_raw(1) saccades_raw(number(aa))];
        elseif aa == length(number)+1 % If it is the last saccade
            saccade(aa,:) = [saccades_raw(number(aa-1)+1) saccades_raw(end)];
            
        else
            saccade(aa,:) = [saccades_raw(number(aa-1)+1) saccades_raw(number(aa))];
        end
    end
end



%% Lineraly interpolate blinks

%%%% Find blink onsets and offsets from blinks_raw

number = find(diff(blinks_raw)> 1);
if ~isempty(blinks_raw)
    if isempty(number)
        
        blinks = [min(blinks_raw) max(blinks_raw)];
    else
        for aa = 1:length(number)+1
            if aa == 1 % If it the first saccade
                blinks(aa,:) = [blinks_raw(1) blinks_raw(number(aa))];
            elseif aa == length(number)+1 % If it is the last saccade
                blinks(aa,:) = [blinks_raw(number(aa-1)+1) blinks_raw(end)];
                
            else
                blinks(aa,:) = [blinks_raw(number(aa-1)+1) blinks_raw(number(aa))];
            end
        end
    end
end


%% Lineraly interpolate blinks
if ~isempty(blinks_raw)
    
    if ~isempty(blinks)
        for aa = 1: size(blinks,1)
            
            if blinks(aa,1)-25 < 1
                xpos(blinks(aa,1):blinks(aa,2))= linspace(xpos(blinks(aa,2)+1),xpos(blinks(aa,2)+1),blinks(aa,2)-blinks(aa,1)+1);
                ypos(blinks(aa,1):blinks(aa,2))= linspace(xpos(blinks(aa,2)+1),ypos(blinks(aa,2)+1),blinks(aa,2)-blinks(aa,1)+1);
                xdeg(blinks(aa,1):blinks(aa,2))= linspace(xdeg(blinks(aa,2)+1),xdeg(blinks(aa,2)+1),blinks(aa,2)-blinks(aa,1)+1);
                ydeg(blinks(aa,1):blinks(aa,2))= linspace(ydeg(blinks(aa,2)+1),ydeg(blinks(aa,2)+1),blinks(aa,2)-blinks(aa,1)+1);
                
            elseif blinks(aa,2)-blinks(aa,1) > 500
                Bad_Trial = 1;
                BlinkError = BlinkError+1;
                break
            elseif blinks(aa,2)+25 >= length(xpos)
                xpos(blinks(aa,1):blinks(aa,2))= linspace(xpos(blinks(aa,1)-1),xpos(blinks(aa,1)-1),blinks(aa,2)-blinks(aa,1)+1);
                ypos(blinks(aa,1):blinks(aa,2))= linspace(xpos(blinks(aa,1)-1),xpos(blinks(aa,1)-1),blinks(aa,2)-blinks(aa,1)+1);
                xdeg(blinks(aa,1):blinks(aa,2))= linspace(xdeg(blinks(aa,1)-1),xdeg(blinks(aa,1)-1),blinks(aa,2)-blinks(aa,1)+1);
                ydeg(blinks(aa,1):blinks(aa,2))= linspace(ydeg(blinks(aa,1)-1),ydeg(blinks(aa,1)-1),blinks(aa,2)-blinks(aa,1)+1);
                
            else
                xpos(blinks(aa,1)-25:blinks(aa,2)+25)= linspace(xpos(blinks(aa,1)-25),xpos(blinks(aa,2)+25),blinks(aa,2)-blinks(aa,1)+51);
                ypos(blinks(aa,1)-25:blinks(aa,2)+25)= linspace(ypos(blinks(aa,1)-25),ypos(blinks(aa,2)+25),blinks(aa,2)-blinks(aa,1)+51);
                xdeg(blinks(aa,1)-25:blinks(aa,2)+25)= linspace(xdeg(blinks(aa,1)-25),xdeg(blinks(aa,2)+25),blinks(aa,2)-blinks(aa,1)+51);
                ydeg(blinks(aa,1)-25:blinks(aa,2)+25)= linspace(ydeg(blinks(aa,1)-25),ydeg(blinks(aa,2)+25),blinks(aa,2)-blinks(aa,1)+51);
                
            end
        end
    else
        if max(blinks_raw)+25 > length(xpos)
            
            xpos(min(blinks_raw):max(blinks_raw))= linspace(xpos(min(blinks_raw)-1),xpos(min(blinks_raw)-1),max(blinks_raw)-min(blinks_raw)+1);
            ypos(min(blinks_raw):max(blinks_raw))= linspace(ypos(min(blinks_raw)-1),ypos(min(blinks_raw)-1),max(blinks_raw)-min(blinks_raw)+1);
            xdeg(min(blinks_raw):max(blinks_raw))= linspace(xdeg(min(blinks_raw)-1),xdeg(min(blinks_raw)-1),max(blinks_raw)-min(blinks_raw)+1);
            ydeg(min(blinks_raw):max(blinks_raw))= linspace(ydeg(min(blinks_raw)-1),ydeg(min(blinks_raw)-1),max(blinks_raw)-min(blinks_raw)+1);
            
        elseif  max(blinks_raw) - min(blinks_raw) > 500
            Bad_Trial = 1;
            BlinkError = BlinkError+1;
            
            
        elseif min(blinks_raw) -25 < 1
            xpos(min(blinks_raw):max(blinks_raw))= linspace(xpos(max(blinks_raw)+1),xpos(max(blinks_raw)+1),max(blinks_raw)-min(blinks_raw)+1);
            ypos(min(blinks_raw):max(blinks_raw))= linspace(ypos(max(blinks_raw)+1),ypos(max(blinks_raw)+1),max(blinks_raw)-min(blinks_raw)+1);
            xdeg(min(blinks_raw):max(blinks_raw))= linspace(xdeg(max(blinks_raw)+1),xdeg(max(blinks_raw)+1),max(blinks_raw)-min(blinks_raw)+1);
            ydeg(min(blinks_raw):max(blinks_raw))= linspace(ydeg(max(blinks_raw)+1),ydeg(max(blinks_raw)+1),max(blinks_raw)-min(blinks_raw)+1);
            
        else
            xpos(min(blinks_raw)-25:max(blinks_raw)+25)= linspace(xpos(min(blinks_raw)-25),xpos(max(blinks_raw)+25),max(blinks_raw)-min(blinks_raw)+51);
            ypos(min(blinks_raw)-25:max(blinks_raw)+25)= linspace(ypos(min(blinks_raw)-25),ypos(max(blinks_raw)+25),max(blinks_raw)-min(blinks_raw)+51);
            xdeg(min(blinks_raw)-25:max(blinks_raw)+25)= linspace(xdeg(min(blinks_raw)-25),xdeg(max(blinks_raw)+25),max(blinks_raw)-min(blinks_raw)+51);
            ydeg(min(blinks_raw)-25:max(blinks_raw)+25)= linspace(ydeg(min(blinks_raw)-25),ydeg(max(blinks_raw)+25),max(blinks_raw)-min(blinks_raw)+51);
            
        end
    end
end

%% Check whether there are still NaNs in the positions

if ~isempty(find(isnan(xpos)))    
    Blinks_Add = find(isnan(xpos));
    if isempty(find(diff(Blinks_Add)>1))
        if max(Blinks_Add)+25 < length(xpos) & min(Blinks_Add)-25>0
        xpos(min(Blinks_Add)-25:max(Blinks_Add)+25)= linspace(xpos(min(Blinks_Add)-25),xpos(max(Blinks_Add)+25),max(Blinks_Add)-min(Blinks_Add)+51);
        ypos(min(Blinks_Add)-25:max(Blinks_Add)+25)= linspace(ypos(min(Blinks_Add)-25),ypos(max(Blinks_Add)+25),max(Blinks_Add)-min(Blinks_Add)+51);
        xdeg(min(Blinks_Add)-25:max(Blinks_Add)+25)= linspace(xdeg(min(Blinks_Add)-25),xdeg(max(Blinks_Add)+25),max(Blinks_Add)-min(Blinks_Add)+51);
        ydeg(min(Blinks_Add)-25:max(Blinks_Add)+25)= linspace(ydeg(min(Blinks_Add)-25),ydeg(max(Blinks_Add)+25),max(Blinks_Add)-min(Blinks_Add)+51);
        end
    end    
end
