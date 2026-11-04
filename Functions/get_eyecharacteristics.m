function [TimeBelowWater Error TrackDistance Bad_Trial] = get_eyecharacteristics(xpos,ypos,events,sub,xtar,ytar)

global Figures

% Interpolate the target position to match the eye movement data
Old_Time=[1:length(xtar)];
New_Time =linspace(1,length(xtar),events(4)-events(3)+1);
yt= interp1(Old_Time,ytar,New_Time);
xt= interp1(Old_Time,xtar,New_Time);
y = ypos(events(3):events(4));
x = xpos(events(3):events(4));

Bad_Trial = 0; 
Error = 0;
TimeBelowWater = NaN;

Distance = sqrt((x-xt').^2+(y-yt').^2);
TrackDistance = median(Distance);
if TrackDistance > 5
%     Bad_Trial =1;
end

if Bad_Trial == 0

    % Align the vector on the moment of the drop
    crit_Moment = round((events(4)-events(3))*sub.critical_frame/100);

    check = min(find(y(500:end)<sub.Water-1))+500;

    % Check whether the target goes below water
    if min(yt) < sub.Water-1

        % Find the time people the first time look close or under the water
        if isempty(check)
            Error = 1;
        end

        if Error == 0
        TimeBelowWater = check-min(find(yt<=sub.Water-1));
        end
        % If the target goes below the water and you dont look there, assign an
        % error

     

    else

        if ~isempty(check)
            TimeBelowWater = check-crit_Moment;
        end

        % If the target stays above the water and you look below, assign an
        % error
        if ~isempty(check)
            Error =1;
        end

    end

    

    if Figures
        figure
        hold on
        plot(y, 'r-')
        plot(yt,'k-')
        plot([1 length(y)], [sub.Plank sub.Plank],'k--')
        plot([1 length(y)], [sub.Water sub.Water],'k--')
        plot([1 length(y)], [sub.Ground sub.Ground],'k--')
        xlabel('Time in Video [ms]' )
        ylabel('Vertical Eye Position [dva]')
        title(['Time below water ', num2str(TimeBelowWater)])
        ylim([-10 10])
        %      keyboard

    end
end