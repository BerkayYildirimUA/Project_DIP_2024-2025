%

frame_1 = squeeze(video_data(119, :, :));    % First frame

image = imread('trail.png');
image_gray = rgb2gray(image);

image_gray = imadjust(image_gray); % Adjust contrast
image_gray = medfilt2(image_gray, [3 3]); % Apply median filter

image_gray_edge = edge(image_gray, 'canny'); % Perform edge detection
points = detectHarrisFeatures(image_gray_edge);
points_1 = detectHarrisFeatures(image_gray);

imshow(frame_1);
figure;

imshow(image_gray);
hold on;
plot(points_1.selectStrongest(100000));

figure;
imshow(image_gray_edge);
hold on;
plot(points.selectStrongest(100000));


figure;
%%% Till now working tracker


%Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 2);

% Detect initial keypoints
points = detectHarrisFeatures(image_gray_edge); %detects corners
initialize(tracker, points.Location, frame_1);

% Track across frames
for i = 119:150
    % Extract the next frame
    nextFrame = squeeze(video_data(i, :, :));

    % Track points
    [newPoints, validity] = tracker(nextFrame);

    % Visualize tracked points
    imshow(nextFrame);
    hold on;
    plot(newPoints(validity, 1), newPoints(validity, 2), 'r.');
    hold off;
    pause(0.1); % Play as a video
end


