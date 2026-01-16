%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis for Material Anticipation experiment
% Written by Alexander Goettker
% 2026

% Note that this is the analysis code for the Perceptual Task. 
% The analysis code for the Interception Task can be fount at Main_Intercept
% The data can be found at https://osf.io/e39hp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

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
% Experiment and Block are fixed here as 1
Experiment = {'1'};
Block = {'1'};

%% Initialize some variables
global datapath stimpath conv resultpath Connector Figures Figures_Avg Number_of_Trials resultfiles

metrics = struct;
metrics_split = struct;
sub = struct;

Number_of_Trials = 50; % Number of Trials per Block
Figures = 0;
Figures_Avg = 1;

%% Define basic concepts of the setup

% Define the datapaths
if ismac
    datapath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Data/Percept/';
    stimpath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Stimuli/';
    resultpath = '/Users/alexandergottker/Dropbox/MaterialAnticipation/Results/';
    resultfiles = '/Users/alexandergottker/Dropbox/MaterialAnticipation/ResultFiles/';
    Connector = '/';
else
    datapath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Data\Percept\';
    stimpath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Stimuli\';
    resultpath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Results\';
    resultfiles = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\ResultFiles\';
    Connector = '\';
end

% Function to get the fundamentals of the setup and pixel to degree
% conversions 
conv = setup(3840,2160,32,60,70,1000,30);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now loop through the data
for subject = 1:length(Subject) % loop through the subjects
    for exp = 1: length(Experiment) % Per Experimental condition
        for block = 1: length(Block) % Per Block

            disp(['This is Subject ',Subject{subject}, ', Experiment ', Experiment{exp}, ', Block ', Block{block}]);

            %% load the respective log file to get the perceptual ratings per stimulus
            sub = load_log_percept(sub,Experiment{exp},Subject{subject},Block{block},exp,subject);
           
        end % End of block       
    end % End of Exp

    %% Compute averages across trials per subject
    metrics = compute_Average_percept(metrics,sub,exp,subject);

end % End of Exp


%% Create some figures across subjects

CreateFiguresPercept(metrics,sub)

%% Save the values so you can use them for the intercept task
Ratings = squeeze(metrics.response); 
Correct = squeeze(metrics.correct); 
save('RatingsperSubject','Ratings','Correct')

