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

    end
end

