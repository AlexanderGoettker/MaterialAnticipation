function [VerVek VerVekTar VerPos Timing] = alignVerVek(xpos,ypos,events,sub,xtar,ytar)

global Figures

% Interpolate the target position to match the eye movement data
Old_Time=[1:length(xtar)]; 
New_Time =linspace(1,length(xtar),events(4)-events(3)+1);
yt= interp1(Old_Time,ytar,New_Time); 
xt= interp1(Old_Time,xtar,New_Time); 

% Align the vector on the moment of the drop
crit_Moment = round(events(3)+(events(4)-events(3))*sub.critical_frame/100); 
Timing = [-800:800]; 

% Get the eye and target vector aligned on this time point
VerVek = ypos(crit_Moment+Timing);
VerVekTar = yt(crit_Moment-events(3)+Timing);

% Get one estimate for the vertical eye position around the water contact
VerPos = median(ypos(crit_Moment-50:crit_Moment+50)); 

if ~isempty(find(isnan(VerVek)))
    keyboard
end

if Figures
     figure
     hold on 
     plot(Timing,VerVek)
     plot([Timing(1)  Timing(end)], [sub.Plank sub.Plank],'k--')
     plot([Timing(1)  Timing(end)], [sub.Water sub.Water],'k--')
     plot([Timing(1)  Timing(end)], [sub.Ground sub.Ground],'k--')
     plot(Timing,VerVekTar,'k--')
     xlabel('Time relative to Water Contact [ms]' )
     ylabel('Vertical Eye Position [dva]')
     ylim([-10 5])  
          
end
