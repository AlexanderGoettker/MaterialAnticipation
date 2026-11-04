function [xtar ytar Magnitude Edge_Mat]= load_target(video,condition)

xtar = []; ytar=[];
global stimpath conv

if condition == 1     
    %Img = load([stimpath,conv.scene{video},'/norm/TargetInfo']);
    Img = load([stimpath,conv.scene{video},'/norm/TargetInfo']);
else
        %Img = load([stimpath,conv.scene{video},'/sup/TargetInfo']);
        Img = load([stimpath,conv.scene{video},'/sup/TargetInfo']);
end 
%end 



xtar = Img.Img.xtar; 
ytar = Img.Img.ytar;

%% Convert into degree 

xtar= (xtar-conv.pix_x/4).*conv.ppd_x; % Convert into degree
ytar= (ytar-conv.pix_y/4).*conv.ppd_y.*-1; % Convert into degree and inverse them
Magnitude(1,:) = (Img.Img.Hor_Magnitude-conv.pix_x/4).*conv.ppd_x;
Magnitude(2,:) = (Img.Img.Vert_Magnitude-conv.pix_y/4).*conv.ppd_y.*-1;

%% Get the continous measures and also convert them into degree 

Edge_Mat(:,1) = (Img.Img.Hor_min-conv.pix_x/4).*conv.ppd_x;
Edge_Mat(:,2) = (Img.Img.Hor_max-conv.pix_x/4).*conv.ppd_x;
Edge_Mat(:,3)= (Img.Img.Ver_min-conv.pix_y/4).*conv.ppd_y.*-1; % Convert into degree and inverse them
Edge_Mat(:,4)= (Img.Img.Ver_max-conv.pix_y/4).*conv.ppd_y.*-1; % Convert into degree and inverse them


