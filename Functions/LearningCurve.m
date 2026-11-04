function [y]= CSFCurve (p,x)

% Define the function and compute if for the given x values and the
% parameter
% p(1) = Strategic Component
% p(2) = Gradual Component
% p(3) = Asympotote

% y = p(1)* 1.^-(x+p(2))+ p(3); 
% y = p(1)* log(x+p(2)); 

y =  p(1) * p(2).^x+ p(3); 
