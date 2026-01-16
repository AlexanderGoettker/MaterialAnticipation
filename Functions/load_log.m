function [sub] = load_log(sub,exp,subj,block,exper,subject)

% Function to load relevant data from the log file for each of the blocks

global datapath Number_of_Trials  % Number of Trials per Block

sub.name=['e',(exp),'v',(subj),'b',(block)]; % File and folder name
file = load([datapath,sub.name,'/',sub.name,'.log']); 

%% Save important variables 

% To be able to analyze everything together, and since experiment 3 is shorter, add NaNs... 
if strcmp(exp,'3') 
    sub.material(exper,subject,str2num(block),:)  = [file(:,5);nan(Number_of_Trials-length(file(:,5)),1)];
    sub.video(exper,subject,str2num(block),:) = [file(:,6);nan(Number_of_Trials-length(file(:,5)),1)];
    sub.timing(exper,subject,str2num(block),:) = [file(:,7);nan(Number_of_Trials-length(file(:,7)),1)];
    sub.hit(exper,subject,str2num(block),:) = [file(:,8);nan(Number_of_Trials-length(file(:,8)),1)];
else
sub.material(exper,subject,str2num(block),:) = file(:,5); % Material: 1 plastic, 2 metallic 
sub.video(exper,subject,str2num(block),:) = file(:,6); % Variation of the Material: 1-5
sub.timing(exper,subject,str2num(block),:) = file(:,7); % When do participants hit the space bar
sub.hit(exper,subject,str2num(block),:) = file(:,8); % Are they inside the hit zone, yes or no
end

% These are the dimensions of the presented video
sub.HorPix = 1920*1.5;
sub.VerPix = 1080*1.5;
sub.trialnumber(exper,subject,str2num(block),:) = [1:Number_of_Trials]; % Trial Number

end

