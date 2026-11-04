function [metrics] = PerceptIntercetp(metrics,sub)

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

%% Do a analysis for quantifying the identifiability and strength of the effect
% Compute per pair the average proportion correct --> high if two good
% materials, low if two bad materials 
% Compare this to the average distance in the vertical eye position 

% Consistent condition
for aa = 1:5
    for bb = 1:5        
        MatCorrect(aa,bb)= mean([mean(metrics.Correct(:,1,aa)) mean(metrics.Correct(:,2,bb))]);
        MatEffect(aa,bb)= nanmean(squeeze(metrics.VerImparMaterial(1,:,1,aa)-metrics.VerImparMaterial(1,:,2,bb)));        
        MatEffectHor(aa,bb)= nanmean(squeeze(metrics.HorImparMaterial(1,:,1,aa)-metrics.HorImparMaterial(1,:,2,bb)));
        MatEffectOverall(aa,bb) = sqrt(MatEffect(aa,bb).^2 + MatEffectHor(aa,bb).^2);
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
[x p] = corr(MatCorrect(:),MatEffect(:),'type','Spearman'); 



figure(67);
hold on;
mdl = fitlm(MatCorrect(:),MatEffectOverall(:));
plot(mdl)
plot(MatCorrect(:),MatEffectOverall(:),'ko','MarkerFaceColor','k')
legend off
xlabel('Prop Correct of Combination')
ylabel('Difference in Eye Position')
title('Consistent')
[x p] = corr(MatCorrect(:),MatEffectOverall(:),'type','Spearman'); 


clear MatCorrect MatEffect MatEffectOverall
% Do the same for the inconsistent condition
for aa = 1:5
    for bb = 1:5
        MatCorrect(aa,bb)= mean([mean(metrics.Correct(:,1,aa)) mean(metrics.Correct(:,2,bb))]);
        MatEffect(aa,bb)= nanmean(squeeze(metrics.VerImparMaterial(2,:,1,aa)-metrics.VerImparMaterial(2,:,2,bb)));
        MatEffectHor(aa,bb)= nanmean(squeeze(metrics.HorImparMaterial(2,:,1,aa)-metrics.HorImparMaterial(2,:,2,bb)));
        MatEffectOverall(aa,bb) = sqrt(MatEffect(aa,bb).^2 + MatEffectHor(aa,bb).^2);
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


figure(77);
hold on;
mdl = fitlm(MatCorrect(:),MatEffectOverall(:));
plot(mdl)
plot(MatCorrect(:),MatEffectOverall(:),'ko','MarkerFaceColor','k')
legend off
xlabel('Prop Correct of Combination')
ylabel('Difference in Eye Position')
title('Inconsistent')
[x p] = corr(MatCorrect(:),MatEffectOverall(:),'type','Spearman')



%% Supplemental Figures with respect to hits

figure(145); 
hold on; 
DistributionFigure(1,squeeze(mean(metrics.Hit(1,:,:),3))',Colormap_exp(1,:))
DistributionFigure(2,squeeze(mean(metrics.Hit(2,:,:),3))',Colormap_exp(2,:))
DistributionFigure(3,squeeze(mean(metrics.Hit(3,:,:),3))',Colormap_exp(3,:))
ylim([0 1])
ylabel('Prop Correct')
set(gca,'XTick',[1:3])
set(gca,'XTickLabels',Labels)
box off 

figure("Name",'Timing'); 
hold on; 
DistributionFigure(1,squeeze(mean(metrics.Timing(1,:,:)*(1000/30),3))',Colormap_exp(1,:))
DistributionFigure(2,squeeze(mean(metrics.Timing(2,:,:)*(1000/30),3))',Colormap_exp(2,:))
DistributionFigure(3,squeeze(mean(metrics.Timing(3,:,:)*(1000/30),3))',Colormap_exp(3,:))
ylabel('Reaction Time [ms]')
set(gca,'XTick',[1:3])
set(gca,'XTickLabels',Labels)
box off


figure; 
hold on; 
Corr = []; 
Hit = []; 

for exp = 1:3
Corr = [Corr;metrics.PropCorrectContact(exp,:)]; 
Hit = [Hit;squeeze(mean(metrics.Hit(exp,:,:),3)) ]; 
[x p] = corr(metrics.PropCorrectContact(exp,:)',squeeze(mean(metrics.Hit(exp,:,:),3))','type','Spearman')
end
[x p] = corr(Corr(:), Hit(:),'type','Spearman');
mdl = fitlm(Corr(:),Hit(:));
plot(mdl)
for exp = 1:3
plot(metrics.PropCorrectContact(exp,:),squeeze(mean(metrics.Hit(exp,:,:),3)),'o','MarkerFaceColor',Colormap_exp(exp,:),'Color',Colormap_exp(exp,:))
end 
xlabel('Prop Correct Eye')
ylabel('Interception Rate')
legend off
ylim([0.4 1])
keyboard
