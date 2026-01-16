function [metrics] = CreateFigures(metrics,sub)

%% Function to recreate figures from the manuscript 

close all
global resultpath
%Define plotting things 
Colormap = [152 0 54; 113 112 110]./255;
Colormap_exp = [59 100 33; 200 50 53; 180 180 180]./255;
Shiftmap = [-0.2 0.2];
Labels = {'Consistent','Inconsistent','Masks'};
Consistent_First = find(metrics.Order == 1);
Inconsistent_First = find(metrics.Order == 2);
SubplotMat = [5 4 6];

%% Show the prop correct at water contact for Consistent vs Inconsistent
figure(1);
hold on;
plot(metrics.PropCorrectContact(1,Consistent_First),metrics.PropCorrectContact(2,Consistent_First),'ko')
plot(metrics.PropCorrectContact(1,Inconsistent_First),metrics.PropCorrectContact(2,Inconsistent_First),'ko','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.4 1])
ylim([0.4 1])
xlabel('Prop Correct Consistent')
ylabel('Prop Correct Inconsistent')

figure(2);
hold on;
plot(mean(squeeze(metrics.Hit(1,Consistent_First,:)),2),mean(squeeze(metrics.Hit(2,Consistent_First,:)),2),'ko')
plot(mean(squeeze(metrics.Hit(1,Inconsistent_First,:)),2),mean(squeeze(metrics.Hit(2,Inconsistent_First,:)),2),'ko','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.2 1])
ylim([0.2 1])
xlabel('Hit Rate Consistent')
ylabel('Hit Rate Inconsistent')


%% Loop across the experiments and conditions
for exp =1:3

    
     
   for mat =1:2

        %% Figures across time
        figure(11);
        subplot(1,3,exp)
        hold on;        
        plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2),sub.Timing,'-','Color',Colormap(mat,:),'LineWidth',2)
        plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2)+(std(squeeze(metrics.VerVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2)-(std(squeeze(metrics.VerVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        plot(squeeze(metrics.VerVekTar(:,exp,1,mat)),sub.Timing,':','Color',Colormap(mat,:),'LineWidth',1)
        set(gca,'YDir','reverse')
        ylim([-400 400])
        xlim([-8 4])
        plot([-8 4],[0 0],'k-')
        title(Labels{exp})
        ylabel('Time relative to Water Contact [ms]')
        xlabel('Vertical Eye Position [dva]')

          %% Figures across time
        figure(171);
        subplot(3,1,exp)
        hold on;        
        shadedErrorBar(sub.Timing,median(squeeze(metrics.VerVek(:,exp,:,mat)),2),std(squeeze(metrics.VerVek(:,exp,:,mat))'),'lineprops',{'-','Color',Colormap(mat,:)})
        plot(sub.Timing,median(squeeze(metrics.VerVek(:,exp,:,mat)),2),'-','Color',Colormap(mat,:),'LineWidth',2)
        plot(sub.Timing,squeeze(metrics.VerVekTar(:,exp,1,mat)),'--','Color',Colormap(mat,:),'LineWidth',1)
        xlim([-400 400])
        ylim([-8 4])
        plot([0 0],[-8 4],'k-')
        title(Labels{exp})
        xlabel('Time relative to Water Contact [ms]')
        ylabel('Vertical Eye Position [dva]')


    end
    
    %% Show the classification over time
    figure(3)
    hold on;
    shadedErrorBar(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))',std(squeeze(metrics.PropCorrect(exp,:,:)))/sqrt(size(metrics.PropCorrect,2)),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))','-','Color',Colormap_exp(exp,:),'LineWidth',2)
    ylabel('Prop Correct')
    xlabel('Time from Water Contact [ms]')
    plot([-800 800],[0.5 0.5],'k--')
    plot([0 0],[0.4 1],'k--')
    ylim([0.4 1])
    xlim([-800 400])

   
%% Show the evolution of prop correct across the block
    figure(4)
    hold on;
    shadedErrorBar([1:100],nanmean(metrics.CorrectNormTime(exp,:,:)),nanstd(metrics.CorrectNormTime(exp,:,:))/sqrt(size(metrics.CorrectNormTime,2)),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot([1:100],squeeze(nanmean(metrics.CorrectNormTime(exp,:,:))),'-','Color',Colormap_exp(exp,:),'LineWidth',2)    
    ylabel('Prop Classified')
    xlabel('Time of Block')
    plot([1 100],[0.5 0.5],'k--')
    ylim([0.4 1])

    % Fit a learning rate to the average data
    optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
   for NN = 1:50 % Select random starting values, so you dont land in a local minima

        Start_Strategic = randn(1);
        Start_Gradual = randn(1);
        Asymptote = randn(1);
        Values = nanmean(metrics.CorrectNormTime(exp,:,:));
        [popt Val] = fminsearchbnd(@difference_function,[Start_Strategic Start_Gradual Asymptote],[-1 -1 0.1],[0 1 0.9], optionsMinsearch,Values,[0:99]);
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
    for MM =1 : 100

        % Pick a random sample of subjects
        Sample = randsample([1:30],25);
        Values = nanmean(metrics.CorrectNormTime(exp,Sample,:));

        optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
        for NN = 1:50 % Select random starting values, so you dont land in a local minima

            Start_Strategic = randn(1);
            Start_Gradual = randn(1);
            Asymptote = randn(1);
            [popt Val] = fminsearchbnd(@difference_function,[Start_Strategic Start_Gradual Asymptote],[-1 -1 0.1],[-0.1 2 0.90], optionsMinsearch,Values,[0:99]);
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
     
    end

    end
    %% Show the performance on Trial 1, splitted based on the starting condition
    figure(5)
    subplot(1,2,1)
    hold on;
    errorbar(exp+Shiftmap(1),mean(squeeze(metrics.CorrectEarly(exp,Consistent_First))),std(squeeze(metrics.CorrectEarly(exp,Consistent_First)))/sqrt(length(Consistent_First))*2,'o','Color',Colormap_exp(exp,:),'MarkerFaceColor',[1 1 1],'MarkerSize',12)
    errorbar(exp+Shiftmap(2),mean(squeeze(metrics.CorrectEarly(exp,Inconsistent_First))),std(squeeze(metrics.CorrectEarly(exp,Inconsistent_First)))/sqrt(length(Inconsistent_First))*2,'o','Color',Colormap_exp(exp,:),'MarkerFaceColor',Colormap_exp(exp,:),'MarkerSize',12)
    set(gca,'XTick',[1 2 3]);
    set(gca,'XTickLabels',Labels)
    ylabel('Prop Correct Trial 1')
    xlim([0.5 3.5])
    plot([0.5 3.5],[0.5 0.5],'k--')
    ylim([0.2 1])
    set(gca,'XTick',[])   
end



for exp = 1:2
    for NN = 1:3

        figure(13)
        subplot(1,3,NN)
        hold on; 
        DistributionFigure(exp,squeeze(metrics.FitParam(exp,:,NN))',Colormap_exp(exp,:))

    end
end

disp(['Asmyptote Consistent: ', num2str(median(squeeze(metrics.FitParam(1,:,3)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(1,:,3)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(1,:,3)),97.5))])
disp(['Asmyptote Inconsistent: ', num2str(median(squeeze(metrics.FitParam(2,:,3)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(2,:,3)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(2,:,3)),97.5))])

disp(['Learning Consistent: ', num2str(median(squeeze(metrics.FitParam(1,:,1)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(1,:,1)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(1,:,1)),97.5))])
disp(['Learning Inconsistent: ', num2str(median(squeeze(metrics.FitParam(2,:,1)))),', CI: ', num2str(prctile(squeeze(metrics.FitParam(2,:,1)),2.5)),' to ', num2str(prctile(squeeze(metrics.FitParam(2,:,1)),97.5))])


%% Do a analysis for quantifying the identifiability and strength of the effect
% Compute per pair the average proportion correct --> high if two good
% materials, low if two bad materials 
% Compare this to the average distance in the vertical eye position 

% Consistent condition
for aa = 1:5
    for bb = 1:5        
        MatCorrect(aa,bb)= mean([mean(metrics.Correct(:,1,aa)) mean(metrics.Correct(:,2,bb))]);
        MatEffect(aa,bb)= nanmean(squeeze(metrics.VerImparMaterial(1,:,1,aa)-metrics.VerImparMaterial(1,:,2,bb)));        
    end
end

figure(6);
hold on;
mdl = fitlm(MatCorrect(:),MatEffect(:));
plot(mdl)
plot(MatCorrect(:),MatEffect(:),'ko','MarkerFaceColor','k')
legend off
xlabel('Prop Correct of Combination')
ylabel('Difference in Eye Position')
title('Consistent')
[x p] = corr(MatCorrect(:),MatEffect(:),'type','Spearman')

clear MatCorrect MatEffect
% Do the same for the inconsistent condition
for aa = 1:5
    for bb = 1:5
        MatCorrect(aa,bb)= mean([mean(metrics.Correct(:,1,aa)) mean(metrics.Correct(:,2,bb))]);
        MatEffect(aa,bb)= nanmean(squeeze(metrics.VerImparMaterial(2,:,1,aa)-metrics.VerImparMaterial(2,:,2,bb)));
    end
end

figure(7);
hold on;
mdl = fitlm(MatCorrect(:),MatEffect(:));
plot(mdl)
plot(MatCorrect(:),MatEffect(:),'ko','MarkerFaceColor','k')
legend off
xlabel('Prop Correct of Combination')
ylabel('Difference in Eye Position')
title('Inconsistent')
[x p] = corr(MatCorrect(:),MatEffect(:),'type','Spearman')
