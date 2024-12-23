%  frame0 = load("Ballenwerper_sync_380fps_006.npychunk_0.mat");
%  frame1 = load("Ballenwerper_sync_380fps_006.npychunk_1.mat");
% frame2 = load("Ballenwerper_sync_380fps_006.npychunk_2.mat");
% frame3 = load("Ballenwerper_sync_380fps_006.npychunk_3.mat");
% frame4 = load("Ballenwerper_sync_380fps_006.npychunk_4.mat");
% frame5 = load("Ballenwerper_sync_380fps_006.npychunk_5.mat");
% frame6 = load("Ballenwerper_sync_380fps_006.npychunk_6.mat");
% frame7 = load("Ballenwerper_sync_380fps_006.npychunk_7.mat");
% frame8 = load("Ballenwerper_sync_380fps_006.npychunk_8.mat");
% frame9 = load("Ballenwerper_sync_380fps_006.npychunk_9.mat");
% 
% 
% 
% frames = cat(1, frame0.video_data, frame1.video_data, frame2.video_data, ...
%     frame3.video_data, frame4.video_data, frame5.video_data, ...
%     frame6.video_data, frame7.video_data, frame8.video_data, ...
%     frame9.video_data);

% frames = cat(1, frame0.video_data, frame1.video_data);
% %%%%%Code Starts from here
% 

frame_1 = squeeze(frames(1, :, :));    % First frame

% image = imread('trail.png');

image = imread('frame1.png');

image_GroundedRod = imread('frame_GroundedRod.png');

image_MovingBearing = imread('frame_MovingBearing.png');

image_gray = im2gray(image);

image_gray = imadjust(image_gray); % Adjust contrast
image_gray = medfilt2(image_gray, [3 3]); % Apply median filter

image_gray_edge = edge(image_gray, 'canny'); % Perform edge detection

% points = detectHarrisFeatures(image_gray_edge);
% imshow(image_gray_edge);
% title('GroundedRod after canny edge with harris points on')
% hold on;
% plot(points);


% points_2 = detectHarrisFeatures(image_gray_edge);
% imshow(image_gray_edge);
% hold on;
% plot(points_2);



%%% Till now working tracker


% % Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 3);

% Detect initial keypoints
points = detectHarrisFeatures(image_gray_edge); %detects corners
%points = detectSIFTFeatures(image_gray_edge);
initialize(tracker, points.Location, frame_1);

figure;

% Initialize variables for tracking properties
distances = [];
angles = [];
curvatures = []; % To store curvature values
baselinePoints = points.Location;

for i = 1:1500
    % Extract the next frame
    nextFrame = squeeze(frames(i, :, :));

    % Track points
    [newPoints, validity] = tracker(nextFrame);

    % Filter valid points
    validPoints = newPoints(validity, :);
     % Calculate pairwise distances and angles
    if i == 1
        baselinePoints = validPoints; % Save baseline points
    else
        % Calculate distances between tracked points
        frameDistances = pdist2(validPoints, validPoints);
        distances = [distances; mean(frameDistances, 'all')];

        % Calculate angles using vector math
        vecs = validPoints - circshift(validPoints, 1, 1);
        frameAngles = atan2d(vecs(:,2), vecs(:,1));
        angles = [angles; mean(diff(frameAngles))];
    end

    % Curvature analysis
    if ~isempty(validPoints) && size(validPoints, 1) > 2
        % Sort points to get them in order along the edge
        [~, order] = sortrows(validPoints, [2, 1]); % Sort by y, then x
        sortedPoints = validPoints(order, :);

        % Calculate curvature using finite differences
        x = sortedPoints(:, 1);
        y = sortedPoints(:, 2);

        % First and second derivatives
        dx = gradient(x);
        dy = gradient(y);
        d2x = gradient(dx);
        d2y = gradient(dy);

        % Curvature formula
        curvature = abs(dx .* d2y - dy .* d2x) ./ (dx.^2 + dy.^2).^(3/2);
        meanCurvature = mean(curvature, 'omitnan'); % Average curvature for the rod
        curvatures = [curvatures; meanCurvature]; % Store for each frame
    else
        curvatures = [curvatures; NaN]; % If points are invalid, store NaN
    end

    % Visualize tracked points
    imshow(nextFrame);
    title(['Frame: ', num2str(i)]);
    hold on;
    plot(validPoints(:, 1), validPoints(:, 2), 'r.');
    hold off;
    pause(0.1);
end

% Plot deformation metrics
figure;
subplot(3, 1, 1);
plot(distances);
title('Mean Distance Between Key Points Over Time');
ylabel('Distance (pixels)');

subplot(3, 1, 2);
plot(angles);
title('Change in Mean Angle Between Key Points Over Time');
ylabel('Angle (degrees)');

subplot(3, 1, 3);
plot(curvatures);
title('Mean Curvature Over Time');
ylabel('Curvature');
xlabel('Frame');
