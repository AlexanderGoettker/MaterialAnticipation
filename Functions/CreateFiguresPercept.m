function [] = CreateFigures(metrics,sub)

%% Init things
close all
global resultpath
%plotting colors
Colormap = [152 0 54; 113 112 110]./255;
Shiftmap = [-0.2 0.2];

% These are the possible materials and videos
Materials = [1:2]; 
Videos = [1:5];

PlotMap = [1 2 3 4 5; 6 7 8 9 10]; 
% Loop through them 
for mat = 1:length(Materials)
    for vid =1:length(Videos)

        figure(1)
        hold on;        
        DistributionFigure(vid+Shiftmap(mat),squeeze(metrics.response(1,:,mat,vid))',Colormap(mat,:))
        ylabel('Probability Sinking')
        plot([0 6],[0.5 0.5],'k--')
        set(gca,'XTick',[1:5])
        xlabel('Video')
        ylim([0 1])

        figure(2)
        hold on;        
        DistributionFigure(vid+Shiftmap(mat),squeeze(metrics.correct(:,mat,vid)),Colormap(mat,:))
        ylabel('Probability Correct')
        plot([0 6],[0.5 0.5],'k--')
        set(gca,'XTick',[1:5])
        xlabel('Video')
        ylim([0 1])

        
        figure(3)
        hold on; 
        errorbar(PlotMap(mat,vid),mean(squeeze(metrics.correct(:,mat,vid))),std(squeeze(metrics.correct(:,mat,vid))),'o','MarkerFaceColor',Colormap(mat,:),'Color',Colormap(mat,:))
        set(gca,'XTick',[1:10])
        hold on; plot([0 11],[0.5 0.5],'k--')
        xlim([0 11])
        daspect([2 1 1])
        ylabel('Judged Correctly')

    end
end

