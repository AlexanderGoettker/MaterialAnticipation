function [metrics] = compute_Average(metrics,sub,exp,subject)

global Figures_Avg resultpath
close all

% Define the colors and Labels for plotting
Colormap = [152 0 54; 113 112 110]./255;
Colormap_exp = [59 100 33; 200 50 53; 180 180 180]./255;
Shiftmap = [-0.2 0.2];
Labels = {'Consistent','Inconsistent','Masks'};
Materials = unique(sub.material(1,subject,:)); % Find all materials

for exp =1:3 % Loop through the conditions

    for mat = 1:length(Materials) % Loop through the different materials

        % Select the relevant trials
        comb = find(sub.Bad_Trial(exp,subject,:) == 0 & sub.material(exp,subject,:) == Materials(mat));

        % Get the averages for the eye and target position over time
        metrics.VerVek(:,exp,subject,mat) = nanmean(squeeze(sub.VerVek(:,exp,subject,comb)),2);
        metrics.VerVekStd(:,exp,subject,mat) = nanstd(squeeze(sub.VerVek(:,exp,subject,comb))');
        metrics.VerVekTar(:,exp,subject,mat) = nanmean(squeeze(sub.VerVekTar(:,exp,subject,comb)),2);

        % Average Vertical Eye Position
        metrics.VerImpar(exp,subject,mat) = nanmedian(squeeze(sub.VerPos(exp,subject,comb)))-sub.Water;

        % Average Performance
        metrics.Hit(exp,subject,mat) = nanmean(squeeze(sub.hit(exp,subject,comb)));


        % Split the Vertical position at water contat in additition per variation of the material
        for vid = 1:5
            comb = find(sub.Bad_Trial(exp,subject,:) == 0 & sub.material(exp,subject,:) == Materials(mat) & sub.video(exp,subject,:)== vid);
            metrics.VerImparMaterial(exp,subject,mat,vid) = nanmedian(squeeze(sub.VerPos(exp,subject,comb)))-sub.Water;
        end

        comb = find(sub.Bad_Trial(exp,subject,:) == 0 & sub.material(exp,subject,:) == Materials(mat));


        % Plot some basic figures to show the trajectory
        if Figures_Avg

            figure(1);
            subplot(1,3,exp)
            hold on;
            plot(squeeze(sub.VerVek(:,exp,subject,comb)),sub.Timing,'-','Color',Colormap(mat,:))
            plot([sub.Water sub.Water],[sub.Timing(1)  sub.Timing(end)], 'k--')
            ylabel('Time relative to Water Contact [ms]')
            xlabel('Vertical Eye Position [dva]')
            set(gca,'YDir','reverse')
            ylim([-400 800])
            xlim([-8 4])
            plot([-8 4],[0 0],'k-')

            figure(2);
            subplot(1,3,exp)
            hold on;
            plot(squeeze(metrics.VerVek(:,exp,subject,mat)),sub.Timing,'-','Color',Colormap(mat,:),'LineWidth',2)
            plot(squeeze(metrics.VerVek(:,exp,subject,mat))+squeeze(metrics.VerVekStd(:,exp,subject,mat)),sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
            plot(squeeze(metrics.VerVek(:,exp,subject,mat))-squeeze(metrics.VerVekStd(:,exp,subject,mat)),sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
            plot(squeeze(metrics.VerVekTar(:,exp,subject,mat)),sub.Timing,'--','Color','k','LineWidth',1)
            plot([sub.Water sub.Water],[sub.Timing(1)  sub.Timing(end)], 'k--')
            set(gca,'YDir','reverse')
            ylim([-400 800])
            xlim([-8 4])
            plot([-8 4],[0 0],'k-')
            title(Labels{exp})
            ylabel('Time relative to Water Contact [ms]')
            xlabel('Vertical Eye Position [dva]')


            figure(99)
            hold on;
            bar(exp+Shiftmap(mat),metrics.VerImpar(exp,subject,mat),0.4,'FaceColor',Colormap(mat,:));
            set(gca,'XTick',[1 2 3]);
            ylabel('Vertical Position at Water Contact')


        end


    end




    %% Compute the difference between plastic and metallic
    metrics.Diff_Impact(exp,subject)= squeeze(metrics.VerImpar(exp,subject,1))-squeeze(metrics.VerImpar(exp,subject,2));

    if exp ==2
        metrics.Diff_Impact(exp,subject) =   metrics.Diff_Impact(exp,subject)*-1;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
    % Now look at how well you can classify whether the target is
    % floating or sinking depending on the vertical eye position over time
    %%%%%%%%%%%%%%%%%%%%

    for aa = 1: length(sub.Timing) % For each time point in the vector

        comb = find(sub.Bad_Trial(exp,subject,:) == 0);

        % Get the basic trials info
        Trials= squeeze(sub.VerVek(aa,exp,subject,comb)); % for all trials get the vertical eye positions at that time
        Material= squeeze(sub.material(exp,subject,comb)); % look up which material it is
        Vek = [1:length(comb)];

        % Cross-Validation Training
        for NN =1:50

            sample_idx = randsample(Vek,floor(length(comb)*0.25)); % Select random 25% of all trials as test
            train_idx=  find(~ismember(Vek,sample_idx)); % use the rest for training

            % Sort them accordingly
            sample = Trials(sample_idx);
            Correct = Material(sample_idx);
            training = Trials(train_idx);
            group = Material(train_idx);

            class = classify(sample,training,group); % Classify them
            Corr(NN) = mean(class == Correct); % look at the proportion correct
        end

        Corr_Time(aa)= mean(Corr); % For each point time, your estimate is the average of the iterations
        clear Correct


    end

    %% Turn that into a single value by looking at the average performance
    check = find(sub.Timing> -50 & sub.Timing < 50);
    metrics.PropCorrect(exp,subject,:) = movmean(Corr_Time,10);
    metrics.PropCorrectContact(exp,subject) = median(metrics.PropCorrect(exp,subject,check));


    if Figures_Avg
        figure(3);
        hold on;
        plot(sub.Timing, squeeze(metrics.PropCorrect(exp,subject,:)),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
        hold on;
        plot([-400 800],[0.5 0.5],'k--')
        xlabel('Time from Water Contact [ms]')
        ylabel('Prop Correct Classified')

    end


    %% Try to Look at the decoding over time in the block

    metrics.CorrectTrials(exp,subject,:) = NaN(70,1); % For all max 70 trials per condition

    for NN = 1:50

        comb = find(sub.Bad_Trial(exp,subject,:) == 0);
        Vek = [1:length(comb)];
        train_idx=  randsample(Vek,floor(length(comb)*0.50));
        training = squeeze(sub.VerPos(exp,subject,comb(train_idx)));
        group = squeeze(sub.material(exp,subject,comb(train_idx)));


        bb = 1;
        for time = 1:length(comb)
            % Select the trials in order
            sample = squeeze(sub.VerPos(exp,subject,comb(time)));
            % Train the classifier

            class = classify(sample,training,group);
            % Check whether it is correct
            Check(NN,bb) = class == squeeze(sub.material(exp,subject,comb(time)));
            bb = bb+1;
        end

    end

    Correct = mean(Check);
    Correct_Time = movmean_asy(Correct,5);
    metrics.CorrectTrials(exp,subject,comb) = Correct_Time;
    metrics.CorrectEarly(exp,subject) = mean(Correct(1));
    metrics.CorrectLate(exp,subject) = mean(Correct(end));


    %     Old_Time=[1:length(Correct)]; % Normalize the length
    %     New_Time =linspace(1,length(Correct),100);
    %     metrics.CorrectNormTime(exp,subject,:) = movmean_asy(interp1(Old_Time,Correct,New_Time),7);
    %
    Old_Time=comb; % Normalize the length
    New_Time =linspace(1,length(Correct),100);
    metrics.CorrectNormTime(exp,subject,:) = movmean_asy(interp1(Old_Time,Correct,New_Time),7);
    

   optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
   for NN = 1:50 % Select random starting values, so you dont land in a local minima

        Start_Strategic = randn(1);
        Start_Gradual = randn(1);
        Asymptote = randn(1);
        Values = metrics.CorrectNormTime(exp,subject,:);
        [popt Val] = fminsearchbnd(@difference_function,[Start_Strategic Start_Gradual Asymptote],[-10 -100 0],[10 1000 1], optionsMinsearch,Values,[0:99]);
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
    
    metrics.LearningParamSubject(exp,subject,:) = p_best;    
   
    clear Check

end


%% Save the figures
if Figures_Avg
    figure(2)
    print([resultpath,'TrajectoriesSub',num2str(subject)],'-dtiff')

    figure(3)
    print([resultpath,'ClassificationSub',num2str(subject)],'-dtiff')

    figure(99)
    print([resultpath,'EffectSub',num2str(subject)],'-dtiff')

end



