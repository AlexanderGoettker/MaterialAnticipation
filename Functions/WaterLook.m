function [Water] = WaterLook(xpos,ypos,events,sub,xtar,ytar,Fig)

% Interpolate the target position to match the eye movement data
Old_Time=[1:length(xtar)];
New_Time =linspace(1,length(xtar),events(4)-events(3)+1);
yt= interp1(Old_Time,ytar,New_Time);
xt= interp1(Old_Time,xtar,New_Time);

% Align the vector on the moment of the drop
crit_Moment = round(events(3)+(events(4)-events(3))*sub.critical_frame/100);
crit_Moment_vid = round((events(4)-events(3))*sub.critical_frame/100);


% Point of Water Contact
HitPoint = [xt(crit_Moment_vid), yt(crit_Moment_vid)];

% Distance of Gaze to that point
Dist_eye = sqrt((xpos(events(3):crit_Moment)-HitPoint(1)).^2+(ypos(events(3):crit_Moment)-HitPoint(2)).^2);
Dist_ball = sqrt((xt(1:crit_Moment_vid)-HitPoint(1)).^2+(yt(1:crit_Moment_vid)-HitPoint(2)).^2);

Time = [events(3):crit_Moment]-crit_Moment;

% Define the first point they look to the potential point the ball drops
% into the water
if isempty(find(Dist_eye<2))
    Water =NaN;
else
    Water = Time(min(find(Dist_eye<2)))- Time(min(find(Dist_ball<2)));
end


if Fig
    figure;
    hold on;
    plot(xt,yt,'k-')
    plot(xpos(events(3):events(4)),ypos(events(3):events(4)),'b-')
    plot(xt(crit_Moment_vid),yt(crit_Moment_vid),'ro')

    figure;
    plot(Time,Dist)
end


