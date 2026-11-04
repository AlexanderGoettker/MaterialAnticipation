function [sub] = load_log(sub,exp,subj,block,exper,subject)

% Function to load relevant data from the log file for each of the blocks

global datapath Number_of_Trials  % Number of Trials per Block

sub.name=['e',(exp),'v',(subj),'b',(block)]; % File and folder name
file = load([datapath,sub.name,'/',sub.name,'.log']); 

%% Save important variables 

% Which material was shown on each trial, 1 is plastic, 2 is metallic
sub.material(exper,subject,str2num(block),:) = file(:,5); 

% Which variation was shown: 1-5
sub.video(exper,subject,str2num(block),:) = file(:,6); % Which variation of the video

% What is the response of the participant: 1 floating, 2 sinking
sub.response(exper,subject,str2num(block),:) = file(:,7); % What was the response of the particpant 

end