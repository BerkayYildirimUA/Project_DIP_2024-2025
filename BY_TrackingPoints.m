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
tracker = vision.PointTracker('MaxBidirectionalError', 3, 'NumPyramidLevels', 4, 'BlockSize', [15, 15], 'MaxIterations', 50);

%use all bounds in the mask
binaryImage = imbinarize(image_gray, 0.1);
[y, x] = find(binaryImage);
points = [x, y];

%group points together for more stability and accuracy
points = groupPoints(points, 15);

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

% use foreground detetctor to get rid of background later 
foregroundDetector = vision.ForegroundDetector(...
    'NumGaussians', 3, ...
    'NumTrainingFrames', 10, ...
    'MinimumBackgroundRatio', 0.7, 'LearningRate', 0.2);

%get medium of all pixles in a point in the video where there is a lot of
%movements. This gets rid of the moving object, and we will train the
%foregroundDetector on these frames.

frameRange = 900:1000;
numFrames = numel(frameRange);
[rows, cols] = size(squeeze(frames(1, :, :)));
selectedFrames = zeros(rows, cols, numFrames); % 3D array for stacking frames

% Process and collect frames
for idx = 1:numFrames
    currentFrame = squeeze(frames(frameRange(idx), :, :)); % Extract frame
    currentFrame = adapthisteq(currentFrame, "Distribution", "exponential"); % Enhance frame
    selectedFrames(:, :, idx) = currentFrame;
    if (idx > (numFrames-10)) %so it has a litte more training data
        medianFrame = median(selectedFrames, 3); % Median frame as background
        foregroundDetector(medianFrame);
    end
end

f = waitbar(0,'Please wait...'); %so you know how long it's taking
% Track across frames
for i = 269:1500

    % Extract the next frame
    nextFrame = squeeze(frames(i, :, :));
    nextFrame = adapthisteq(nextFrame, "Distribution", "exponential");
    
    waitbar((i-268)/(1500-268),f,'computing...');

    % Normalize lighting using top rows
    currentBrightness = mean(nextFrame(topRows, :), 'all'); %mean brightes of top pixles
    adjustmentFactor = referenceBrightness / currentBrightness;
    nextFrame = nextFrame * adjustmentFactor;
    nextFrame = min(nextFrame, 255); % Clip to valid range
    
    % Track points
    [newPoints, validity] = tracker(nextFrame);
    validNewPoints = newPoints(validity, :);

    validNewPoints = groupPoints(validNewPoints, 15);

    %create new mask for this frame
    
    % Step 1: Adaptive threshold to binarize the frame
    binaryFrame = imbinarize(nextFrame, 'adaptive');

    %detect forground
    backgroundMask = ~foregroundDetector(double(nextFrame));
    imtool(backgroundMask);
    
    thick = bwmorph(backgroundMask,"thicken", 2)
%%%
     closedBg = imclose(thick, strel('disk', 1));
    % 
     openedbg = bwareaopen(~closedBg, 90000, 4);
    
    
    imtool(binaryFrame);
    imtool(backgroundMask);
    binaryFrame(find(backgroundMask)) = false;
    imtool(binaryFrame);

    % Step 2: Label connected components and compute properties
    CC = bwconncomp(binaryFrame);
    L = labelmatrix(CC); % Labeled image
    props = regionprops(CC, 'PixelIdxList'); % Get pixel indices of each region

    % Step 3: Map valid tracked points to regions
    pointIndices = sub2ind(size(binaryFrame), round(validNewPoints(:,2)), round(validNewPoints(:,1)));
    pointLabels = L(pointIndices);
    
    % Count points in each region
    regionCounts = accumarray(pointLabels(pointLabels > 0), 1, [CC.NumObjects, 1]);
    
    % Step 4: Get the top 2 regions with the most tracked points
    [~, sortedIndices] = maxk(regionCounts, 2); % Top 2 regions
    topRegionsMask = false(size(binaryFrame));
    
    for idx = 1:length(sortedIndices)
        topRegionsMask(CC.PixelIdxList{sortedIndices(idx)}) = true;
    end


    % Step 5: Edge detection on the grayscale frame to refine boundaries
    nextFrameCut = nextFrame .* uint8(topRegionsMask);
    edges = edge(nextFrameCut, 'Canny'); % Detect edges on the grayscale frame
    
    
    % Step 6: Combine mask and edges
    refinedMask = topRegionsMask & ~edges; % Remove everything outside detected edges
    refinedMask = imfill(refinedMask, 'holes'); % Fill holes inside the mask
    
    refinedMask = imerode(refinedMask, [1 1; 1 1]);
    refinedMask = imdilate(refinedMask, [1 1 1; 1 1 1]);
    
    % Step 7: Extract new points from the refined mask
    [y_mask, x_mask] = find(refinedMask);
    newPointsFromMask = double([x_mask, y_mask]); % Ensure points are 'double'
    
    newPointsFromMask = groupPoints(newPointsFromMask, 15);
    
    % Update the tracker with the refined points
    if ~isempty(newPointsFromMask)
        setPoints(tracker, newPointsFromMask);
    end

end

close(outputVideo);
