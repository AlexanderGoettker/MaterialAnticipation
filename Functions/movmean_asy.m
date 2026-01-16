function [output] =movmean_asy(x,size)
%% Function for asymetric moving window
% See Wagner & Schütz saccadic adaptation paper
output = zeros(length(x),1);
for aa =1:length(x)
    if aa <= size
        output(aa) = mean(x(1:aa));
    else
        output(aa) = mean(x(aa-size:aa));
    end
end

