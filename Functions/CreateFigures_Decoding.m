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




%% Show Decoding over Time 
for exp = 1:3 
    figure(3)
    hold on;
    shadedErrorBar(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))',(std(squeeze(metrics.PropCorrect(exp,:,:)))/sqrt(size(metrics.PropCorrect,2))),'lineprops',{'-','Color',Colormap_exp(exp,:)})
    plot(sub.Timing, squeeze(mean(metrics.PropCorrect(exp,:,:),2))','-','Color',Colormap_exp(exp,:),'LineWidth',2)
    ylabel('Prop Correct')
    xlabel('Time from Water Contact [ms]')
    plot([-1500 800],[0.5 0.5],'k--')
    plot([0 0],[0.4 1],'k--')
    ylim([0.4 1])
    xlim([-1500 400])
end


%% Show the prop correct at water contact for Consistent vs Inconsistent
figure(1);
hold on;
plot(metrics.PropCorrectContact(1,Consistent_First),metrics.PropCorrectContact(2,Consistent_First),'ko','MarkerFaceColor','k')
plot(metrics.PropCorrectContact(1,Inconsistent_First),metrics.PropCorrectContact(2,Inconsistent_First),'ks','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.4 1])
ylim([0.4 1])
xlabel('Prop Correct Consistent')
ylabel('Prop Correct Inconsistent')



figure(111);
hold on;
plot(metrics.PropCorrectContactHor(1,Consistent_First),metrics.PropCorrectContactHor(2,Consistent_First),'ko')
plot(metrics.PropCorrectContactHor(1,Inconsistent_First),metrics.PropCorrectContactHor(2,Inconsistent_First),'ko','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.4 1])
ylim([0.4 1])
xlabel('Prop Correct Consistent')
ylabel('Prop Correct Inconsistent')

figure(112);
hold on;
plot(metrics.PropCorrectContactVer(1,Consistent_First),metrics.PropCorrectContactVer(2,Consistent_First),'ko')
plot(metrics.PropCorrectContactVer(1,Inconsistent_First),metrics.PropCorrectContactVer(2,Inconsistent_First),'ko','MarkerFaceColor','k')
axis square
plot([-1 3],[-1 3],'k--')
xlim([0.4 1])
ylim([0.4 1])
xlabel('Prop Correct Consistent')
ylabel('Prop Correct Inconsistent')

[h p t stats]= ttest(metrics.PropCorrectContact(1,:),metrics.PropCorrectContact(2,:))

keyboard