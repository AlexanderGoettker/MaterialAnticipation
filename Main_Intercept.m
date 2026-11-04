%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis for Material Anticipation experiment
% Written by Alexander Goettker
% 2026

% Note that this is the analysis code for the Incerception Task.
% The analysis code for the Perceptual Task can be fount at Main_Percept
% The data can be found at https://osf.io/e39hp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

% Set the rng randomizer to ensure that you produce the same results
rng("default")

%% Define Pathway
addpath(genpath('../Analysis_Clean'))

%% Set default values for plotting
set (0,'DefaultAxesFontSize',13)
set (0,'DefaultLineMarkerSize',8)
set (0,'DefaultAxesLineWidth',1.2)
warning off

%% Things you want to analyze
% Enter the subjects you want to analyze
Subject = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30'};

% Experiment 1: Consistent, Experiment 2: Inconsistent, Experiment 3: Mask
Experiment = {'1','2','3'};
Block = {'1'};

%% Initialize some variables
global datapath stimpath conv resultpath Connector Figures Figures_Avg Number_of_Trials resultfiles Blink_Error Processing_Error

metrics = struct;
metrics_split = struct;
sub = struct;

% Add the order of the subjects
metrics.Order = ones(length(Subject),1);
metrics.Order(11:25) = 2; % Subjects 1-10 completed exp 1 first, subjects 11-25 exp 2

Number_of_Trials = 70; % Number of Trials per Block
Figures = 0; % If you want to visualize the raw data
Figures_Avg = 1; % If you want to visualize the average results

% Variables to count reasons for excluded trials
Blink_Error = 0;
Processing_Error = 0;

%% Define basic concepts of the setup

% Define the datapaths
if ismac
    datapath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Data/Intercept/';
    stimpath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Stimuli/';
    resultpath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Results/';
    resultfiles = '/Users/alexandergottker/Dropbox/MaterialAnticipation/ResultFiles/';
    Connector = '/';
else
    datapath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Data\Intercept\';
    stimpath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Stimuli\';
    resultpath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Results\';
    resultfiles = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\ResultFiles\';
    Connector = '\';
end

% Function to get the fundamentals of the setup and pixel to degree
% conversions
conv = setup(3840,2160,32,60,70,1000,30);

%% Get the subjective rating data from the perceptual Analysis script
load('RatingsperSubject.mat')
metrics.Ratings = Ratings;
metrics.Correct = Correct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now loop through the data
for subject = 1:length(Subject) % loop through the subjects
    for exp = 1: length(Experiment) % Per Experimental condition
        for block = 1: length(Block) % Per Block
            
            disp(['This is Subject ',Subject{subject}, ', Experiment ', Experiment{exp}, ', Block ', Block{block}]);
            
            %% load the respective log file to get information about the individual trials
            sub = load_log(sub,Experiment{exp},Subject{subject},Block{block},exp,subject);
            
            %% Now go through the individual trials
            disp('Loop through the Trials...')
            for t = 1:Number_of_Trials
                
                if strcmp(Experiment{exp},'3') & t> 40 % Because the Mask condition has less trials, label them as Bad
                    sub.Bad_Trial(exp,subject,block,t)=1;
                else
                    
                    %% Load and prepare the eye movement data
                    [xpix, ypix, xpos_raw, ypos_raw, events, saccade, pupil, sub.Bad_Trial(exp,subject,block,t)] = load_eye(sub.name,t,sub); % Load & Process the eye movement data
                    
                    [xpos, ypos, xvel, yvel, vel, sub.Bad_Trial(exp,subject,block,t)] = compute_vel(xpos_raw,ypos_raw, sub.Bad_Trial(exp,subject,block,t));  % Compute the velocity and filter the traces
                    
                    %% Get the Target Information
                    [xtar ytar Img sub] = get_target(Experiment{exp},sub.material(exp,subject,block,t),sub.video(exp,subject,block,t),sub);
                    
                    %% If you want to visualize the raw data
                    if Figures
                        figure;
                        imshow(Img)
                        hold on;
                        plot(xpix(events(3):events(4)),ypix(events(3):events(4)),'r-','LineWidth',3)                
                    end                    

                    
                    %% Compute some eye movement metrics
                    if sub.Bad_Trial(exp,subject,block,t) == 0                        
                        % Look at the eye position across time
                        [sub.VerVek(:,exp,subject,block,t) sub.VerVekTar(:,exp,subject,block,t) sub.VerPos(exp,subject,block,t) ...
                            sub.HorVek(:,exp,subject,block,t) sub.HorVekTar(:,exp,subject,block,t) sub.HorPos(exp,subject,block,t) sub.Timing] = alignVek(xpos,ypos,events,sub,xtar,ytar);
                        
                        [sub.VerVekAll(:,exp,subject,block,t) sub.VerVekTarAll(:,exp,subject,block,t) ...
                            sub.HorVekAll(:,exp,subject,block,t) sub.HorVekTarAll(:,exp,subject,block,t)] = OverallVek(xpos,ypos,events,sub,xtar,ytar);


                        % Compute when people look at the water relative to
                        % when the ball is reaching that point
                        sub.WaterLook(exp,subject,block,t) = WaterLook(xpos,ypos,events,sub,xtar,ytar,0); 

                    end


                    
                    %% For illustration of the data, you can use this function to create videos of a single trial
                    
                    % Create_Videos(xpix, ypix,events, sub.material(exp,subject,t), sub.video(exp,subject,t),Experiment{exp},Subject{subject},t,0)
                    
                    if t == 0.5*  Number_of_Trials
                        disp('...half way done...')
                    end
                end
                
            end % End of trial
            disp('...done...')
            
        end % End of block
        
        %% After completing one condition, look how many trials needed to be excluded
        if exp ==3
            disp(['You have found ', num2str(length(find(sub.Bad_Trial(exp,subject,:)== 1))-30), ' Bad Trials' ])
            metrics.BadTrialsSub(exp,subject) =(length(find(sub.Bad_Trial(exp,subject,:)== 1))-30)/(Number_of_Trials-30);
        else
            disp(['You have found ', num2str(length(find(sub.Bad_Trial(exp,subject,:)== 1))), ' Bad Trials' ])
            metrics.BadTrialsSub(exp,subject) =length(find(sub.Bad_Trial(exp,subject,:)== 1))/Number_of_Trials;
        end
    end % End of Exp
    
    %% If you have all data for all conditions from one subject, look at the average behavior
    metrics = compute_Average_intercept(metrics,sub,exp,subject);
    
end % End of Exp

save('Data_all_Intercept')

keyboard
%% Look at the overall valid trials
Bad_Trials = length(find(sub.Bad_Trial(:)== 1))-(30*length(Subject)); % All Bad Trials that were labelled
All_Trials = length(sub.Bad_Trial(:))-(30*length(Subject)); % All possible Trials
PropTrials = 1-(Bad_Trials/All_Trials); % Proportion of valid Trials in Analysis

%% Create figures for the manuscript

% Plot the base trajectories
metrics = CreateFigures_Trajectories(metrics,sub);

% Decoding over time within a trial
metrics = CreateFigures_Decoding(metrics,sub);

% Linking perceptual reports and eye movements
metrics = CreateFigures_PerceptIntercept(metrics,sub);

%Learning over time
metrics = CreateFigures_Learning(metrics,sub);

% Create some figures where you use cross_decoding
metrics = CreateFigures_CrossDecoding(metrics,sub); 


%% Get some summary statistics
GetStats(metrics)
