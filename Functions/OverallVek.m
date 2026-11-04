function [VerVek VerVekTar HorVek HorVekTar] = OverallVek(xpos,ypos,events,sub,xtar,ytar)

global Figures

% Interpolate the target position to match the eye movement data
Old_Time=[1:length(xtar)]; 
New_Time =linspace(1,length(xtar),3333);
yt= interp1(Old_Time,ytar,New_Time); 
xt= interp1(Old_Time,xtar,New_Time); 

% Align the vector on the moment of the drop
crit_Moment = round(events(3)+(events(4)-events(3))*sub.critical_frame/100); 

% Get the eye and target vector aligned on this time point
VerVek = ypos(events(3):events(3)+3333);
VerVekTar = yt;
HorVek = xpos(events(3):events(3)+3333);
HorVekTar = xt;


