 % clear; close all; clc;   % uncomment when too many variables in workspace
 % 
if ~exist('frame0', 'var') || ~exist('frame1', 'var') || ...
   ~exist('frame2', 'var') || ~exist('frame3', 'var') || ...
   ~exist('frame4', 'var') || ~exist('frame5', 'var') || ...
   ~exist('frame6', 'var') || ~exist('frame7', 'var') || ...
   ~exist('frame8', 'var') || ~exist('frame9', 'var')

    clear; close all; clc;

    % Load the video frames
    frame0 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_0.mat");
    frame1 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_1.mat");
    frame2 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_2.mat");
    frame3 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_3.mat");
    frame4 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_4.mat");
    frame5 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_5.mat");
    frame6 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_6.mat");
    frame7 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_7.mat");
    frame8 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_8.mat");
    frame9 = load("Imports\Ballenwerper_sync_380fps_006.npychunk_9.mat");

    % Concatenate video data
    frames = cat(1, frame0.video_data, frame1.video_data, frame2.video_data, ...
        frame3.video_data, frame4.video_data, frame5.video_data, ...
        frame6.video_data, frame7.video_data, frame8.video_data, ...
        frame9.video_data);
else
    clearvars -except frame0 frame1 frame2 frame3 frame4 frame5 frame6 frame7 frame8 frame9 frames
end


%%%%%Code Starts from here

%start frame
frame_1 = squeeze(frames(269, :, :));
frame_1 = adapthisteq(frame_1, "Distribution", "exponential");

%%% Till now working tracker

% lighting normalization lighting
% get avrage light of the top rows which don't move. We will change the
% gama of all frames later to mach this reference brightness
topRows = 1:30;
referenceBrightness = mean(frame_1(topRows, :), 'all');

% mask
% hand made start, only shape matters)
image = imread('cutout.png');
image_gray = image;
image_gray = adapthisteq(image_gray, "Distribution", "exponential");


%Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 5, 'NumPyramidLevels', 3, 'BlockSize', [15, 15], 'MaxIterations', 20);

%use all bounds in the mask
binaryImage = imbinarize(image_gray, 0.1);
[y, x] = find(binaryImage);
points = [x, y];

%group points together for more stability and accuracy
points = groupPoints(points, 5);

initialize(tracker, points, frame_1);


%%% code from ChatGPT to calculate position and speed according to the
%%% graphs in blackboard

%make video file of points
 framesForVideo = cell(1, 1500 - 269 + 1);

 outputDir = 'videos';
 if ~exist(outputDir, 'dir')
    mkdir(outputDir);
 end

 filename = fullfile(outputDir, [datestr(now, 'yyyymmdd_HHMMSS') '.mp4']);
 outputVideo = VideoWriter(filename, 'MPEG-4');
 outputVideo.FrameRate = 30; % Set desired frame rate
 open(outputVideo);
 frameIndex = 1;

f = waitbar(0,'Please wait...'); %so you know how long it's taking
% Track across frames
for i = 269:1500
     %fprintf('Frame %d:', i);
     waitbar((i-268)/(1500-268),f,'computing...');

    % Extract the next frame
    nextFrame = squeeze(frames(i, :, :));
    nextFrame = adapthisteq(nextFrame, "Distribution", "exponential");
    

    % Normalize lighting using top rows
    currentBrightness = mean(nextFrame(topRows, :), 'all'); %mean brightes of top pixles
    adjustmentFactor = referenceBrightness / currentBrightness;
    nextFrame = nextFrame * adjustmentFactor;
    nextFrame = min(nextFrame, 255); % Clip to valid range
    
    % Track points
    [newPoints, validity] = tracker(nextFrame);
    validNewPoints = newPoints(validity, :);
    

    %validNewPoints = groupPoints(validNewPoints, 15);

    % [Gmag, ~] =  uint8(imgradient(nextFrame, 'sobel')); % Gradient magnitude
    % Gmag = uint8(Gmag);
    % GradientMask = Gmag > 80; %

    %create new mask for this frame   
    SobelMask       = edge(nextFrame, 'Sobel');
    PrewittMask     = edge(nextFrame, 'Prewitt');
    RobertsMask     = edge(nextFrame, 'Roberts');
    LoGMask         = edge(nextFrame, 'log');
    ZeroCrossMask   = edge(nextFrame, 'zerocross');
    CannyMask       = edge(nextFrame, 'Canny', [], 4);
    ApproxCannyMask = edge(nextFrame, 'approxcanny');

    total = SobelMask | PrewittMask | RobertsMask | LoGMask | ZeroCrossMask | CannyMask | ApproxCannyMask;

    total = bwareaopen(total, 200, 4);
    total = imclearborder(total, 8);

    % Step 1: Skeletonize the binary image
    skeleton = bwmorph(total, 'skel', Inf);

    % Step 2: Detect endpoints
    endpoints = bwmorph(skeleton, 'endpoints');


    % Get coordinates of the endpoints
    [end_y, end_x] = find(endpoints);

    % Step 3: Connect spikes
    % Create a copy of the skeleton for modifications
    connectedSkeleton = connect_all_points(skeleton, end_x, end_y);

    dilated = imdilate(connectedSkeleton, [1 1; 1 1]);
    total = bwareaopen(~dilated, 50000, 4);
    invertedMask = dilated | total;
    mask = ~invertedMask;

    % Step 1: Label the connected components in the mask
    [labeledMask, numAreas] = bwlabel(mask);

    % Step 2: Measure the properties of connected components
    stats = regionprops(labeledMask, 'Area', 'PixelIdxList');

    % Step 3: Filter areas based on size
    smallAreas = find([stats.Area] < 15000000);

    % Step 4: Create a new mask with only small areas
    smallAreaMask = ismember(labeledMask, smallAreas);

    % Step 5: Identify areas that have points inside
    validPointsIndices = sub2ind(size(mask), round(validNewPoints(:, 2)), round(validNewPoints(:, 1))); % Convert points to linear indices
    areasWithPoints = unique(labeledMask(validPointsIndices)); % Get unique area labels with points

    % Step 6: Filter areas that are both small and contain points
    finalAreaLabels = intersect(smallAreas, areasWithPoints);

    % Step 7: Create the final binary mask
    finalMask = ismember(labeledMask, finalAreaLabels);

    finalMask = bwmorph(finalMask, 'skel', Inf);

    imshowpair(finalMask, mask, 'diff');

    % Step 8: Convert the binary mask into a list of points
    [row, col] = find(finalMask);
    pointsList = [col, row]; % Convert to [x, y] format if needed

    pointsList = groupPoints(pointsList, 5);

    combined = [validNewPoints; pointsList];

    tracker.setPoints(combined);

    hold on;
    %plot(col, row, 'rx', 'MarkerSize', 1); % Red 'x' markers for points
    plot(combined(:, 1), combined(:, 2), 'bx', 'MarkerSize', 1); % Blue 'x' markers for new points
    hold off;


    nextFrameRGB = repmat(uint8(finalMask), [1, 1, 3]); % Convert to RGB
    nextFrameRGB = insertMarker(nextFrameRGB, pointsList, 'x', 'Color', 'red', 'Size', 1);

    writeVideo(outputVideo, nextFrameRGB);



end

close(f);
close(outputVideo);
