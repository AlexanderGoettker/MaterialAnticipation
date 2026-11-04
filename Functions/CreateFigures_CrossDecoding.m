function [metrics] = CreateFiguresDecoding(metrics,sub)


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

%% Show Decoding over Time within a trial

for exp = 1:2
    figure(3)
    hold on;
%     shadedErrorBar(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))',(std(squeeze(metrics.PropCorrect(exp,:,:)))/sqrt(size(metrics.PropCorrect,2))),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))','-','Color',Colormap_exp(exp,:),'LineWidth',2)
    ylabel('Prop Correct')
    xlabel('Time from Water Contact [ms]')
    plot([-1500 800],[0.5 0.5],'k--')
    plot([0 0],[0.4 1],'k--')
    ylim([0.4 1])
    xlim([-1500 400])
end

hold on;
% shadedErrorBar(sub.Timing, squeeze(mean(metrics.PropCorrect_InconsCons(1,:,:),2))',(std(squeeze(metrics.PropCorrect_InconsCons(1,:,:)))/sqrt(size(metrics.PropCorrect,2))),'lineprops',{'-','Color',Colormap_exp(1,:)})
plot(sub.Timing, squeeze(mean(metrics.PropCorrect_InconsCons(1,:,:),2))','--','Color',Colormap_exp(1,:),'LineWidth',2)
hold on;
% shadedErrorBar(sub.Timing, squeeze(mean(metrics.PropCorrect_ConsIncons(1,:,:),2))',(std(squeeze(metrics.PropCorrect_ConsIncons(1,:,:)))/sqrt(size(metrics.PropCorrect,2))),'lineprops',{'-','Color',Colormap_exp(2,:)})
plot(sub.Timing, squeeze(mean(metrics.PropCorrect_ConsIncons(1,:,:),2))','--','Color',Colormap_exp(2,:),'LineWidth',2)


% Do a t-test
check = find(sub.Timing >-50 & sub.Timing <50); 

Consistent = squeeze(mean(metrics.PropCorrect_InconsCons(1,:,check),3));
Inconsistent = squeeze(mean(metrics.PropCorrect_ConsIncons(1,:,check),3)); 
[h p t stats] = ttest(Consistent,Inconsistent); 

Consistent_First = find(metrics.Order == 1);
Inconsistent_First = find(metrics.Order == 2);
figure(1);
hold on;
plot(Consistent(Consistent_First),Inconsistent(Consistent_First),'ko','MarkerFaceColor','k')
plot(Consistent(Inconsistent_First),Inconsistent(Inconsistent_First),'ks','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.4 1])
ylim([0.4 1])
xlabel('Prop Correct Consistent')
ylabel('Prop Correct Inconsistent')
keyboard

%% Learning Figure
for exp =1:2
figure(44)
hold on;
% shadedErrorBar([1:100],nanmean(metrics.CorrectNormTimeLeaveOut(exp,:,:)),nanstd(metrics.CorrectNormTimeLeaveOut(exp,:,:))/sqrt(size(metrics.CorrectNormTime,2)),'lineprops',{'-','Color',Colormap_exp(exp,:)})
plot([1:100],squeeze(nanmean(metrics.CorrectNormTimeLeaveOut(exp,:,:))),'-','Color',Colormap_exp(exp,:),'LineWidth',2)
ylabel('Prop Classified')
xlabel('Time of Block')
plot([1 100],[0.5 0.5],'k--')
ylim([0.3 1])
end
hold on; 
plot([1:100],squeeze(nanmean(metrics.CorrectNormTimeLeaveOut_ConsIncons(1,:,:))),'--','Color',Colormap_exp(2,:),'LineWidth',2)
hold on; 
plot([1:100],squeeze(nanmean(metrics.CorrectNormTimeLeaveOut_InconsCons(1,:,:))),'--','Color',Colormap_exp(1,:),'LineWidth',2)


keyboard
