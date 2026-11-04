%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis for Material Anticipation experiment
% Written by Alexander Goettker
% 2026

% Note that this is the analysis code for the Online Perceptual Task.
% The data can be found at https://osf.io/e39hp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the data
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

%% load the data
Datapath = 'C:\Users\Alexander Goettker\Dropbox\MaterialAnticipation\Data\OnlineData\';
data = importonlinetfile([Datapath,'online_data.csv']);

% Define the subjects
Subjects = unique(data.par);


for subject = 1:length(Subjects) % loop through subjects

    comb = find(data.par == Subjects(subject)); % Find the relevant trials

    % Check the condition
    con = data.congruency(comb(1));
    if con == 'congruent'
        ConditionSub(subject) = 1;
    elseif con == 'incongruent'
        ConditionSub(subject) = 2;
    end
    trialnr = data.trial(comb);
    Correct = data.correct(comb);

    % Do the same analysis as for the eyes
    Old_Time=trialnr; % Normalize the length
    New_Time =linspace(1,length(trialnr),100);
    Corr_Time(subject,:) = movmean_asy(interp1(Old_Time,Correct,New_Time),7);
    Corr_Early(subject) = Corr_Time(subject,1); 

end


%% Now create a first version of the plot

Colormap_exp = [59 100 33; 200 50 53; 180 180 180]./255; % Colormap same as for the original experiment 

for exp = 1:2 % For both conditions 

    % Find the releavant subjects 
    comb = find(ConditionSub==exp);    
    
    % Create the respetive figure
    figure(4)
    hold on;
    shadedErrorBar([1:100],nanmean(Corr_Time(comb,:)),nanstd(Corr_Time(comb,:))/sqrt(length(comb)),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot([1:100],squeeze(nanmean(Corr_Time(comb,:))),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
    ylabel('Prop Classified')
    xlabel('Time of Block')
    plot([1 100],[0.5 0.5],'k--')
    ylim([0.3 1])

    %% Look at the average Data 
    
    if exp == 1         
    Consistent_Late = squeeze(nanmean(Corr_Time(comb,90:100),2));
    Mat = [Consistent_Late ones(length(comb),1)]; 
    else 
        Inconsistent_Late = squeeze(nanmean(Corr_Time(comb,90:100),2));
        Mat = [Mat; Inconsistent_Late ones(length(comb),1)*exp]; 
     keyboard
        T = array2table(Mat);
        T.Properties.VariableNames = {'Decoding','Group'};
        writetable(T,'LateDecodingOnline')
        keyboard
    end
    
    % Do the fitting of the learning curve
    optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
    for NN = 1:50 % Select random starting values, so you dont land in a local minima
        Start_Strategic = randn(1);
        Start_Gradual = randn(1);
        Asymptote = randn(1);
        Values = nanmean(Corr_Time(comb,:));     
        [popt Val] = fminsearchbnd(@difference_function,[Start_Strategic Start_Gradual Asymptote],[-1 -1 0.1],[0 1 1], optionsMinsearch,Values,[0:99]);
        %         hold on;
        %         plot([1:100],LearningCurve(popt,[1:100]))

        if NN == 1
            p_best = popt;
            Error = Val;
        end
        if Val < Error
            p_best = popt;
        end
    end

    metrics.LearningParam(exp,:) = p_best;
    hold on;
    plot([1:100],LearningCurve(p_best,[0:99]),'--','Color',Colormap_exp(exp,:))

    
    %% Use a bootstrap estimate to compare the parameter fits
       
    if exp < 3
        for MM =1 :100
            % Pick a random sample of subjects
            Sample = randsample([1:length(comb)],20);
            Values = nanmean(Corr_Time(comb(Sample),:));     
            
            optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
            for NN = 1:50 % Select random starting values, so you dont land in a local minima

                Start_Strategic = randn(1);
                Start_Gradual = randn(1);
                Asymptote = randn(1);
                [popt Val] = fminsearchbnd(@difference_function,[Start_Strategic Start_Gradual Asymptote],[-1 -1 0.1],[-0.1 2 1], optionsMinsearch,Values,[0:99]);
                %         hold on;
                %         plot([1:100],LearningCurve(popt,[1:100]))

                if NN == 1
                    p_best = popt;
                    Error = Val;
                end
                if Val < Error
                    p_best = popt;
                end
            end

            metrics.FitParam(exp,MM,:) = p_best;

        end % Bootstrapping loop
    end

    figure(5)
    subplot(1,2,1)
    hold on;    
    if exp == 1 
    errorbar(exp,nanmean(Corr_Early(comb)),nanstd(Corr_Early(comb))/sqrt(length(comb))*2,'s','Color',Colormap_exp(exp,:),'MarkerFaceColor',Colormap_exp(exp,:),'MarkerSize',12)
    else
    errorbar(exp,nanmean(Corr_Early(comb)),nanstd(Corr_Early(comb))/sqrt(length(comb))*2,'o','Color',Colormap_exp(exp,:),'MarkerFaceColor',Colormap_exp(exp,:),'MarkerSize',12)
    end
    set(gca,'XTick',[]);
%     set(gca,'XTickLabels',Labels)
    ylabel('Prop Correct Trial 1')
    xlim([0.5 2.5])
    plot([0.5 3.5],[0.5 0.5],'k--')
    ylim([0 1])
    set(gca,'XTick',[])

end % For the two experiments 

disp(['Asmyptote Consistent: ', num2str(median(squeeze(metrics.FitParam(1,:,3)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(1,:,3)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(1,:,3)),97.5))])
disp(['Asmyptote Inconsistent: ', num2str(median(squeeze(metrics.FitParam(2,:,3)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(2,:,3)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(2,:,3)),97.5))])



