function [metrics] = compute_Average(metrics,sub,exp,subject)

global Figures_Avg resultpath
close all

% Find all possible materials and videos
Materials = unique(sub.material(exp,subject,:)); 
Videos = unique(sub.video(exp,subject,:)); 

%% Loop through them
for mat =1:length(Materials)
    for vid = 1:length(Videos)

        % Find the respective trials 
        comb = find(sub.material(exp,subject,:) == Materials(mat) & sub.video(exp,subject,:) == Videos(vid)); 
        
        % Get the proportion of a sinking response
        metrics.response(exp,subject,mat,vid) = mean(sub.response(exp,subject,comb)-1);
                
    end
    
    % Turn this into a proportion correct,  by taking the inverse for the
    % plastics
    if mat == 1
        metrics.correct(subject,mat,:) = 1- metrics.response(exp,subject,mat,:);
    else
        metrics.correct(subject,mat,:) =  metrics.response(exp,subject,mat,:);
    end

end






