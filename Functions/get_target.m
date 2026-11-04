function [xtar ytar Img sub] = get_target(Experiment,material,video,sub);

global stimpath conv Connector

% Define key characteristics
Add_y =(conv.pix_y-sub.VerPix)/2;
Add_x =(conv.pix_x-sub.HorPix)/2;
sub.Water= (((1009+Add_y)-conv.pix_y/2)*conv.ppd_y)*-1; % Position of the water in va
sub.Plank= (((723+Add_y)-conv.pix_y/2)*conv.ppd_y)*-1; % Position of the end of the plan in dva
sub.Ground= (((1450+Add_y)-conv.pix_y/2)*conv.ppd_y)*-1; % position of the Ground in Dva
sub.critical_frame = 59; % The frame the sphere interacts with the water

% Load the target information
info = load([stimpath,'vals.mat']);
material_original = material; 

if strcmp(Experiment,'2') % If you are in the inconsistent condition, flip the material labels so you get the right trajectories
    if material ==1; material = 2; elseif material == 2; material = 1; end; 
    for frame = 1:100
        xpix(frame) = info.vals{material,frame,1}*1.5;
        ypix(frame) = info.vals{material,frame,2}*1.5;
    end
else
    for frame = 1:100
        xpix(frame) = info.vals{material,frame,1}*1.5;
        ypix(frame) = info.vals{material,frame,2}*1.5;
    end
end

ytar= (((ypix+Add_y)-conv.pix_y/2)*conv.ppd_y)*-1;
xtar= (((xpix+Add_x)-conv.pix_x/2)*conv.ppd_x);


% Load the first frame for a visualization
if strcmp(Experiment,'1')
    if material == 1
        Img = imread([stimpath,'plastic_congruent',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    else
        Img = imread([stimpath,'metal_congruent',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    end
elseif strcmp(Experiment,'2')
    if material_original == 1
        Img = imread([stimpath,'plastic_incongruent',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    else
        Img = imread([stimpath,'metal_incongruent',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    end
    
elseif strcmp(Experiment,'3')
    if material == 1
        Img = imread([stimpath,'control_floating',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    else
        Img = imread([stimpath,'control_sinking',Connector,num2str(video),Connector,'0001.png']);
        Img = imresize(Img,[sub.VerPix sub.HorPix]);
    end
end

