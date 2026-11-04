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
        metrics.HorVek(:,exp,subject,mat) = nanmean(squeeze(sub.HorVek(:,exp,subject,comb)),2);
        metrics.HorVekAll(:,exp,subject,mat) = nanmean(squeeze(sub.HorVekAll(:,exp,subject,comb)),2);
        metrics.HorVekStd(:,exp,subject,mat) = nanstd(squeeze(sub.HorVek(:,exp,subject,comb))');
        metrics.HorVekTar(:,exp,subject,mat) = nanmean(squeeze(sub.HorVekTar(:,exp,subject,comb)),2);
        metrics.HorVekTarAll(:,exp,subject,mat) = nanmean(squeeze(sub.HorVekTarAll(:,exp,subject,comb)),2);

        metrics.VerVek(:,exp,subject,mat) = nanmean(squeeze(sub.VerVek(:,exp,subject,comb)),2);
        metrics.VerVekAll(:,exp,subject,mat) = nanmean(squeeze(sub.VerVekAll(:,exp,subject,comb)),2);
        metrics.VerVekStd(:,exp,subject,mat) = nanstd(squeeze(sub.VerVek(:,exp,subject,comb))');
        metrics.VerVekTar(:,exp,subject,mat) = nanmean(squeeze(sub.VerVekTar(:,exp,subject,comb)),2);
        metrics.VerVekTarAll(:,exp,subject,mat) = nanmean(squeeze(sub.VerVekTarAll(:,exp,subject,comb)),2);

        % Average Vertical Eye Position
        metrics.VerImpar(exp,subject,mat) = nanmedian(squeeze(sub.VerPos(exp,subject,comb)))-sub.Water;
        metrics.HorImpar(exp,subject,mat) = nanmedian(squeeze(sub.HorPos(exp,subject,comb)))-sub.Water;

        % Look at the time they looked at the water
        metrics.WaterLook(exp,subject,mat) = nanmean(sub.WaterLook(exp,subject,comb));
        metrics.WaterCheck(exp,subject,mat) = 1-(length(find(isnan(sub.WaterLook(exp,subject,comb))))/length(comb));


        % Average Performance

        % check whether they made some very premature button presses
        check = find(sub.timing(exp,subject,comb) >0);

        metrics.Hit(exp,subject,mat) = nanmean(squeeze(sub.hit(exp,subject,comb(check))));
        if exp == 1 | exp == 3
            if mat == 1
                metrics.Timing(exp,subject,mat) = nanmean(squeeze(sub.timing(exp,subject,comb(check))))-sub.ZoneFloat(1);
            else
                metrics.Timing(exp,subject,mat) = nanmean(squeeze(sub.timing(exp,subject,comb(check))))-sub.ZoneSink(1);
            end
        else
            if mat == 1
                metrics.Timing(exp,subject,mat) = nanmean(squeeze(sub.timing(exp,subject,comb(check))))-sub.ZoneSink(1);
            else
                metrics.Timing(exp,subject,mat) = nanmean(squeeze(sub.timing(exp,subject,comb(check))))-sub.ZoneFloat(1);
            end
        end


        % Split the Vertical position at water contat in additition per variation of the material
        for vid = 1:5
            comb = find(sub.Bad_Trial(exp,subject,:) == 0 & sub.material(exp,subject,:) == Materials(mat) & sub.video(exp,subject,:)== vid);
            metrics.VerImparMaterial(exp,subject,mat,vid) = nanmedian(squeeze(sub.VerPos(exp,subject,comb)))-sub.Water;
            metrics.HorImparMaterial(exp,subject,mat,vid) = nanmedian(squeeze(sub.HorPos(exp,subject,comb)));
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

            figure(3);
            subplot(1,3,exp)
            hold on;
            plot(squeeze(metrics.HorVek(:,exp,subject,mat)),sub.Timing,'-','Color',Colormap(mat,:),'LineWidth',2)
            plot(squeeze(metrics.HorVek(:,exp,subject,mat))+squeeze(metrics.HorVekStd(:,exp,subject,mat)),sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
            plot(squeeze(metrics.HorVek(:,exp,subject,mat))-squeeze(metrics.HorVekStd(:,exp,subject,mat)),sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
            plot(squeeze(metrics.HorVekTar(:,exp,subject,mat)),sub.Timing,'--','Color','k','LineWidth',1)
            plot([sub.Water sub.Water],[sub.Timing(1)  sub.Timing(end)], 'k--')
            ylim([-400 800])
            xlim([-8 4])
            plot([-8 4],[0 0],'k-')
            title(Labels{exp})
            ylabel('Time relative to Water Contact [ms]')
            xlabel('Horizonzal Eye Position [dva]')



            figure(99)
            hold on;
            bar(exp+Shiftmap(mat),metrics.VerImpar(exp,subject,mat),0.4,'FaceColor',Colormap(mat,:));
            set(gca,'XTick',[1 2 3]);
            ylabel('Vertical Position at Water Contact')

            figure(100)
            hold on;
            bar(exp+Shiftmap(mat),metrics.HorImpar(exp,subject,mat),0.4,'FaceColor',Colormap(mat,:));
            set(gca,'XTick',[1 2 3]);
            ylabel('Horizontal Position at Water Contact')


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
    % floating or sinking depending on the eye position over time
    %%%%%%%%%%%%%%%%%%%%

    for aa = 1: length(sub.Timing) % For each time point in the vector

        comb = find(sub.Bad_Trial(exp,subject,:) == 0);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% Do this based on horizontal and vertical eye position
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Get the basic trials info
        Trials= [squeeze(sub.VerVek(aa,exp,subject,comb)) squeeze(sub.HorVek(aa,exp,subject,comb))]; % for all trials get the vertical eye positions at that time
        Material= squeeze(sub.material(exp,subject,comb)); % look up which material it is
        Vek = [1:length(comb)];

        % Cross-Validation Training
        for NN =1:50
            % Randomply pick sample and training
            sample_idx = randsample(Vek,floor(length(comb)*0.25)); % Select random 25% of all trials as test
            train_idx=  find(~ismember(Vek,sample_idx)); % use the rest for training
            % Sort them accordingly
            sample = Trials(sample_idx,:);
            Correct = Material(sample_idx);
            training = Trials(train_idx,:);
            group = Material(train_idx);
            % Do the classification
            class = classify(sample,training,group); % Classify them
            Corr(NN) = mean(class == Correct); % look at the proportion correct
        end

        Corr_Time(aa)= mean(Corr); % For each point time, your estimate is the average of the iterations
        clear Correct


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% Do this based on vertical eye position
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Trials= [squeeze(sub.VerVek(aa,exp,subject,comb))]; % for all trials get the vertical eye positions at that time
        % Cross-Validation Training
        for NN =1:50
            % Randomply pick sample and training
            sample_idx = randsample(Vek,floor(length(comb)*0.25)); % Select random 25% of all trials as test
            train_idx=  find(~ismember(Vek,sample_idx)); % use the rest for training
            % Sort them accordingly
            sample = Trials(sample_idx);
            Correct = Material(sample_idx);
            training = Trials(train_idx);
            group = Material(train_idx);
            % Do the classification
            class = classify(sample,training,group); % Classify them
            Corr(NN) = mean(class == Correct); % look at the proportion correct
        end

        Corr_Time_Ver(aa)= mean(Corr); % For each point time, your estimate is the average of the iterations
        clear Correct

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% Do this based on horizontal eye position
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Trials= [squeeze(sub.HorVek(aa,exp,subject,comb))]; % for all trials get the vertical eye positions at that time
        % Cross-Validation Training
        for NN =1:50
            % Randomply pick sample and training
            sample_idx = randsample(Vek,floor(length(comb)*0.25)); % Select random 25% of all trials as test
            train_idx=  find(~ismember(Vek,sample_idx)); % use the rest for training
            % Sort them accordingly
            sample = Trials(sample_idx);
            Correct = Material(sample_idx);
            training = Trials(train_idx);
            group = Material(train_idx);
            % Do the classification
            class = classify(sample,training,group); % Classify them
            Corr(NN) = mean(class == Correct); % look at the proportion correct
        end

        Corr_Time_Hor(aa)= mean(Corr); % For each point time, your estimate is the average of the iterations
        clear Correct


    end

    %% Turn that into a single value by looking at the average performance
    check = find(sub.Timing> -50 & sub.Timing < 50);
    metrics.PropCorrect(exp,subject,:) = movmean(Corr_Time,10);
    metrics.PropCorrect_Ver(exp,subject,:) = movmean(Corr_Time_Ver,10);
    metrics.PropCorrect_Hor(exp,subject,:) = movmean(Corr_Time_Hor,10);

    metrics.PropCorrectContact(exp,subject) = median(metrics.PropCorrect(exp,subject,check));
    metrics.PropCorrectContactVer(exp,subject) = median(metrics.PropCorrect_Ver(exp,subject,check));
    metrics.PropCorrectContactHor(exp,subject) = median(metrics.PropCorrect_Hor(exp,subject,check));


    if Figures_Avg
        figure(4);
        subplot(1,3,1)
        hold on;
        plot(sub.Timing, squeeze(metrics.PropCorrect(exp,subject,:)),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
        hold on;
        plot([-400 800],[0.5 0.5],'k--')
        xlabel('Time from Water Contact [ms]')
        ylabel('Prop Correct Classified')
        subplot(1,3,2)
        hold on;
        plot(sub.Timing, squeeze(metrics.PropCorrect_Ver(exp,subject,:)),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
        hold on;
        plot([-400 800],[0.5 0.5],'k--')
        xlabel('Time from Water Contact [ms]')
        ylabel('Prop Correct Classified Ver')
        subplot(1,3,3)
        hold on;
        plot(sub.Timing, squeeze(metrics.PropCorrect_Hor(exp,subject,:)),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
        hold on;
        plot([-400 800],[0.5 0.5],'k--')
        xlabel('Time from Water Contact [ms]')
        ylabel('Prop Correct Classified Hor')

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Try to Look at the decoding over time in the block

    % Do it with a leave one-out classification
    
    comb = find(sub.Bad_Trial(exp,subject,:) == 0);
    Vek = [1:length(comb)];

    for NN = 1:50
        for aa = 1:length(Vek)
            train_poss= Vek(Vek~=aa);
            train_idx = randsample(train_poss,floor(length(train_poss)*0.50));
            training = [squeeze(sub.VerPos(exp,subject,comb(train_idx))) squeeze(sub.HorPos(exp,subject,comb(train_idx)))];
            group = squeeze(sub.material(exp,subject,comb(train_idx)));
            sample = [squeeze(sub.VerPos(exp,subject,comb(aa))) squeeze(sub.HorPos(exp,subject,comb(aa)))];
            class = classify(sample,training,group);
            Check_LeaveOut(NN,aa) = class == squeeze(sub.material(exp,subject,comb(aa)));
        end
    end


  
    Correct_LeaveOut = mean(Check_LeaveOut);
    Old_Time=comb; % Normalize the length
    New_Time =linspace(1,length(Correct_LeaveOut),100);
    metrics.CorrectNormTimeLeaveOut(exp,subject,:) = movmean_asy(interp1(Old_Time,Correct_LeaveOut,New_Time),7);
    metrics.CorrectEarlyLeaveOut(exp,subject) = mean(Correct_LeaveOut(1));
    metrics.CorrectLateLeaveOut(exp,subject) = mean(Correct_LeaveOut(end));

    clear Check_LeaveOut

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do a cross-decoding for the analysis: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% For the time course analysis

    for aa = 1: length(sub.Timing) % For each time point in the vector
        
        % For the consistent condition
        comb = find(sub.Bad_Trial(1,subject,:) == 0);
        % Get the basic trials info
        Trials_Cons= [squeeze(sub.VerVek(aa,1,subject,comb)) squeeze(sub.HorVek(aa,1,subject,comb))]; % for all trials get the vertical eye positions at that time
        Material_Cons= squeeze(sub.material(1,subject,comb)); % look up which material it is
        Vek_Cons = [1:length(comb)];

        % For the inconsistent condition
         comb = find(sub.Bad_Trial(1,subject,:) == 0);
        % Get the basic trials info
        Trials_Incons= [squeeze(sub.VerVek(aa,2,subject,comb)) squeeze(sub.HorVek(aa,2,subject,comb))]; % for all trials get the vertical eye positions at that time
        Material_Incons= squeeze(sub.material(2,subject,comb)); % look up which material it is
        Vek_Incons = [1:length(comb)];        
        

        % Cross-Validation Training
        for NN =1:50

            %% Train Inconsistent, Test Consistent 
            % Randomply pick sample and training
            train_idx = randsample(Vek_Incons,floor(length(comb)*0.75)); % Select random 75% of all trials as training
            sample_idx=  randsample(Vek_Cons,floor(length(comb)*0.25)); % use the rest for training
           
            % Sort them accordingly
            sample = Trials_Cons(sample_idx,:);
            Correct = Material_Cons(sample_idx);
            training = Trials_Incons(train_idx,:);
            group = Material_Incons(train_idx);
           
            % Do the classification
            class = classify(sample,training,group); % Classify them
            Corr_InconsCons(NN) = 1-(mean(class == Correct)); % look at the proportion correct

            
            %% Train Cons, Test Inconsistent
            train_idx = randsample(Vek_Cons,floor(length(comb)*0.75)); % Select random 75% of all trials as training
            sample_idx=  randsample(Vek_Incons,floor(length(comb)*0.25)); % use the rest for training

            % Sort them accordingly
            sample = Trials_Incons(sample_idx,:);
            Correct = Material_Incons(sample_idx);
            training = Trials_Cons(train_idx,:);
            group = Material_Cons(train_idx);

            % Do the classification
            class = classify(sample,training,group); % Classify them
            Corr_ConsIncons(NN) = 1-(mean(class == Correct)); % look at the proportion correct

        end

        Corr_Time_InconsCons(aa)= mean(Corr_InconsCons); % For each point time, your estimate is the average of the iterations
        Corr_Time_ConsIncons(aa)= mean(Corr_ConsIncons); % For each point time, your estimate is the average of the iterations
   
    end

    metrics.PropCorrect_InconsCons(1,subject,:) = movmean(Corr_Time_InconsCons,10);
    metrics.PropCorrect_ConsIncons(1,subject,:) = movmean(Corr_Time_ConsIncons,10);


    %% Do the cross-decoding over time 

    % Train Inconsistent and test consistent 
    comb_cons = find(sub.Bad_Trial(1,subject,:) == 0);
    Vek_cons = [1:length(comb_cons)];

    comb_incons = find(sub.Bad_Trial(2,subject,:) == 0);
    Vek_incons = [1:length(comb_incons)];

    for NN = 1:50
        for aa = 1:length(Vek_cons)
            % train data
            train_idx = randsample(Vek_incons,floor(length(Vek_incons)*0.50));
            training = [squeeze(sub.VerPos(2,subject,comb_incons(train_idx))) squeeze(sub.HorPos(2,subject,comb_incons(train_idx)))];
            group = squeeze(sub.material(2,subject,comb_incons(train_idx)));
            
            %test data
            sample = [squeeze(sub.VerPos(1,subject,comb_cons(aa))) squeeze(sub.HorPos(1,subject,comb_cons(aa)))];
            class = classify(sample,training,group);
            Check_LeaveOutInconsCons(NN,aa) = 1-(class == squeeze(sub.material(1,subject,comb_cons(aa))));
        end
    end
  
    Correct_LeaveOutInconsCons = mean(Check_LeaveOutInconsCons);
    Old_Time=comb_cons; % Normalize the length
    New_Time =linspace(1,length(Correct_LeaveOutInconsCons),100);
    metrics.CorrectNormTimeLeaveOut_InconsCons(1,subject,:) = movmean_asy(interp1(Old_Time,Correct_LeaveOutInconsCons,New_Time),7);
    
    
  % Train Consistent and test Inconsistent 
    comb_cons = find(sub.Bad_Trial(1,subject,:) == 0);
    Vek_cons = [1:length(comb_cons)];

    comb_incons = find(sub.Bad_Trial(2,subject,:) == 0);
    Vek_incons = [1:length(comb_incons)];

    for NN = 1:50
        for aa = 1:length(Vek_incons)
            % train data
            train_idx = randsample(Vek_cons,floor(length(Vek_cons)*0.50));
            training = [squeeze(sub.VerPos(1,subject,comb_cons(train_idx))) squeeze(sub.HorPos(1,subject,comb_cons(train_idx)))];
            group = squeeze(sub.material(1,subject,comb_cons(train_idx)));
            
            %test data
            sample = [squeeze(sub.VerPos(2,subject,comb_incons(aa))) squeeze(sub.HorPos(2,subject,comb_incons(aa)))];
            class = classify(sample,training,group);
            Check_LeaveOutConsIncons(NN,aa) = 1-(class == squeeze(sub.material(2,subject,comb_incons(aa))));
        end
    end
  
    Correct_LeaveOutConsIncons = mean(Check_LeaveOutConsIncons);
    Old_Time=comb_incons; % Normalize the length
    New_Time =linspace(1,length(Correct_LeaveOutConsIncons),100);
    metrics.CorrectNormTimeLeaveOut_ConsIncons(1,subject,:) = movmean_asy(interp1(Old_Time,Correct_LeaveOutConsIncons,New_Time),7);
    
%% Save the figures
if Figures_Avg
    figure(2)
    print([resultpath,'TrajectoriesSubVert',num2str(subject)],'-dtiff')
    figure(3)
    print([resultpath,'TrajectoriesSubHor',num2str(subject)],'-dtiff')
    figure(4)
    print([resultpath,'ClassificationSub',num2str(subject)],'-dtiff')
    figure(99)
    print([resultpath,'EffectSub',num2str(subject)],'-dtiff')

end


