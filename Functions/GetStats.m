function [] = GetStats(metrics)

global resultfiles 

% Init Things 
PropCorrect = []; 
Asymptote = []; 
HitRate = []; 
% Fill out the tables 
for exp =1:3 

    PropCorrect = [PropCorrect; metrics.PropCorrectContact(exp,:)];
    Asymptote = [Asymptote;  metrics.LearningParamSubject(exp,:,3)]; 
    HitRate = [HitRate; squeeze(mean(metrics.Hit(exp,:,:),3))];

    for mat = 1:2 

    end
end



%% Save them
T = array2table(PropCorrect');
T.Properties.VariableNames = {'Consistent','Inconsistent','Mask'};
writetable(T,[resultfiles,'PropCorrect'])

T = array2table(Asymptote');
T.Properties.VariableNames = {'Consistent','Inconsistent','Mask'};
writetable(T,[resultfiles,'Asymptote'])

T = array2table(HitRate');
T.Properties.VariableNames = {'Consistent','Inconsistent','Mask'};
writetable(T,[resultfiles,'HitRate'])






