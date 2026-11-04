%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script to create Videos based on input images and scenes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = Create_Videos(xpos, ypos,events, material, video, Experiment,subject,t,ShowFrames)

global stimpath Connector resultpath

disp (['You are creating a video...'])
Frames = 1000;

%% Get the gaze position during the video
xpix = xpos(events(3):events(4));
ypix = ypos(events(3):events(4));

% Get a timing vector that matches the 30 Hz to align the gaze position
Timing = round([1:1000/30:3333]); %Refresh Rate --> 30 Hz --> one frame is 1000/30

%% Now loop through the images
for frame = 1:Frames
    
    %% Get the image
    disp(['... this is frame ', num2str(frame)])

    if frame < 10
        Filename = ['000',num2str(frame)];
    elseif frame >= 10 & frame < 100
        Filename = ['00',num2str(frame)];
    else
        Filename = ['0',num2str(frame)];
    end
    
    if strcmp(Experiment,'1')
    if material == 1
        Img = imread([stimpath,'plastic_congruent',Connector,num2str(video),Connector,Filename,'.png']);
    else
        Img = imread([stimpath,'metal_congruent',Connector,num2str(video),Connector,Filename,'.png']);
    end
    elseif strcmp(Experiment,'2')
        if material == 1
        Img = imread([stimpath,'plastic_incongruent',Connector,num2str(video),Connector,Filename,'.png']);
    else
        Img = imread([stimpath,'metal_incongruent',Connector,num2str(video),Connector,Filename,'.png']);
    end
    end
    
    Img = imresize(Img,1.5);
    
        
    %% Look up Gaze at correct time point
%     keyboard
    X = nanmean(xpix(Timing(frame):Timing(frame)));
    Y = nanmean(ypix(Timing(frame):Timing(frame)));
    
    %% add the gaze to the image
    x_Vec = [1:size(Img,2)]-X;
    y_Vec = [1:size(Img,1)]-Y;
    
    [x y] = meshgrid(x_Vec,y_Vec);
    Dist = sqrt(x.^2+y.^2);
    
    check = find(Dist < 40);
    
    Img_update = permute(Img,[3 1 2]);
    Img_update(:,check) = repmat([255 0 0]',[1 length(check)]);
    Img_video =  permute(Img_update,[2 3 1]);
    
    
    %% If you want to see the frames, turn it on at
    if ShowFrames
        figure(frame) % add the gaze to the image
        hold on;
        imshow(Img_video)        
    end
    
    %% Save the images
    ImSave{frame} = Img_video;
    
    
end


%% Now convert the images into videos

disp('Converting Video')
writerObj = VideoWriter([resultpath, 'Exp', Experiment,'Sub',subject,'Trial',num2str(t),'VideoMat',num2str(material),'Vid',num2str(video),'.mp4'],'MPEG-4'); % Define Writer Object
writerObj.FrameRate = 30; % Set FrameRate
open(writerObj); % Open
for frame = 1 :Frames
    % Add the individual Frames to the movie    
    writeVideo(writerObj, ImSave{frame});
end
close(writerObj); % End the video


end



