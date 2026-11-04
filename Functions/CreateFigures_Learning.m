
function [metrics] = CreateFiguresLearning(metrics,sub)

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


%% Perform a classical statistical test 

Consistent_Late = squeeze(nanmean(metrics.CorrectNormTimeLeaveOut(1,:,90:100),3));
Inconsistent_Late = squeeze(nanmean(metrics.CorrectNormTimeLeaveOut(2,:,90:100),3));
Mat = [Consistent_Late; Inconsistent_Late]; 
T = array2table(Mat');
T.Properties.VariableNames = {'Consistent','Inconsistent'}; 
writetable(T,'LateDecodingDynamicPrediction')


figure; 
hold on;
plot(Consistent_Late,Inconsistent_Late,'ro','MarkerFaceColor','r')
xlim([0.5 1])
ylim([0.5 1])
axis square
plot([0.5 1],[0.5 1],'w-')
xlabel('CONSISTENT Prop Correct at the end of the experiment ')
ylabel('INCONSISTENT Prop Correct at the end of the experiment ')
[h p t stats] = ttest(Consistent_Late,Inconsistent_Late); 
title(['t(29)=',num2str(stats.tstat),', p = ', num2str(p)])
print('t-test','-dtiff')





%% Loop across the experiments and conditions
for exp =1:3     
 %     end
    
%     keyboard
    
    %% Show the performance on Trial 1, splitted based on the starting condition
    if exp < 3
    figure(5)
    subplot(1,2,1)
    hold on;
    errorbar(exp+Shiftmap(1),mean(squeeze(metrics.CorrectEarlyLeaveOut(exp,Consistent_First))),std(squeeze(metrics.CorrectEarlyLeaveOut(exp,Consistent_First)))/sqrt(length(Consistent_First))*2,'s','Color',Colormap_exp(exp,:),'MarkerFaceColor',Colormap_exp(exp,:),'MarkerSize',12)
    errorbar(exp+Shiftmap(2),mean(squeeze(metrics.CorrectEarlyLeaveOut(exp,Inconsistent_First))),std(squeeze(metrics.CorrectEarlyLeaveOut(exp,Inconsistent_First)))/sqrt(length(Inconsistent_First))*2,'o','Color',Colormap_exp(exp,:),'MarkerFaceColor',Colormap_exp(exp,:),'MarkerSize',12)
    set(gca,'XTick',[1 2 3]);
    set(gca,'XTickLabels',Labels)
    ylabel('Prop Correct Trial 1')
    xlim([0.5 2.5])
    plot([0.5 3.5],[0.5 0.5],'k--')
    ylim([0 1])
    set(gca,'XTick',[])   
    end
   
    %% Show the evolution of prop correct across the block
    figure(4)
    hold on;
    shadedErrorBar([1:100],nanmean(metrics.CorrectNormTimeLeaveOut(exp,:,:)),nanstd(metrics.CorrectNormTimeLeaveOut(exp,:,:))/sqrt(size(metrics.CorrectNormTimeLeaveOut,2)),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot([1:100],squeeze(nanmean(metrics.CorrectNormTimeLeaveOut(exp,:,:))),'-','Color',Colormap_exp(exp,:),'LineWidth',2)    
    ylabel('Prop Classified')
    xlabel('Time of Block')
    plot([1 100],[0.5 0.5],'k--')
    ylim([0.3 1])

    
    % Fit a learning rate to the average data
    optionsMinsearch = optimset('MaxFunEvals',50000,'MaxIter',50000,'TolFun', 1e-12, 'TolX',1e-12);
   for NN = 1:50 % Select random starting values, so you dont land in a local minima

        Start_Strategic = randn(1);
        Start_Gradual = randn(1);
        Asymptote = randn(1);
        Values = nanmean(metrics.CorrectNormTimeLeaveOut(exp,:,:));
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
      for MM =1:100

        % Pick a random sample of subjects
        Sample = randsample([1:30],25);
        Values = nanmean(metrics.CorrectNormTimeLeaveOut(exp,Sample,:));

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


