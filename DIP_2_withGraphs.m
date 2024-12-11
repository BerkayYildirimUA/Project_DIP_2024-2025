% clear; close all; clc;   % uncomment when too many variables in workspace

% frame0 = load("Ballenwerper_sync_380fps_006.npychunk_0.mat");
 frame1 = load("Ballenwerper_sync_380fps_006.npychunk_1.mat");
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


%%%%%Code Starts from here


frame_1 = squeeze(frame1.video_data(1, :, :));    % First frame

image = imread('trail.png');
image_gray = rgb2gray(image);
image_gray = imadjust(image_gray); % Adjust contrast
image_gray = medfilt2(image_gray, [3 3]); % Apply median filter

image_gray_edge = edge(image_gray, 'canny'); % Perform edge detection


%%% Till now working tracker


%Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 3);

% Detect initial keypoints
points = detectHarrisFeatures(image_gray_edge); %detects corners

initialize(tracker, points.Location, frame_1);

% figure;
% %This is the previous code (without the new added graph calculation)
% for i = 119:150
%     % Extract the next frame
%     nextFrame = squeeze(frame1.video_data(i, :, :));
% 
%     % Track points
%     [newPoints, validity] = tracker(nextFrame);
% 
%     % Visualize tracked points
%     imshow(nextFrame);
%     title('adjusted');
%     hold on;
%     plot(newPoints(validity, 1), newPoints(validity, 2), 'r.');
%     hold off;
%     pause(0.1); % Play as a video
% end
% 
% % for j = 1:150
% % 
% %     frame_one = squeeze(video_data(j,:,:));
% % 
% %     imshow(frame_one);
% % 
% %     title(j);
% %     pause(0.1);
% % end
% 
% 
% 




%%% code from ChatGPT to calculate position and speed according to the
%%% graphs in blackboard


% Initialize storage for position and speed
positions = [];
speeds = [];
time = []; % Time in milliseconds
frame_rate = 380; % Frame rate in Hz
dt = 1000 / frame_rate; % Time step in milliseconds

% Reference point (e.g., center of the frame)
[height, width] = size(frame_1);
center = [width / 2, height / 2];

% Track across frames
for i = 1:150
    % Extract the next frame
    nextFrame = squeeze(frame1.video_data(i, :, :));

    % Track points
    [newPoints, validity] = tracker(nextFrame);

    % Compute position (theta) for the valid point closest to the center
    validNewPoints = newPoints(validity, :);
    if ~isempty(validNewPoints)
        % Choose the closest valid point to the center
        [~, idx] = min(sqrt(sum((validNewPoints - center).^2, 2)));
        trackedPoint = validNewPoints(idx, :);

        % Compute angular position theta
        dx = trackedPoint(1) - center(1);
        dy = trackedPoint(2) - center(2);
        theta = atan2d(dy, dx); % Angle in degrees

        % Store position and time
        positions = [positions; theta];
        time = [time; (i - 1) * dt];

        % Calculate speed if more than one position is stored
        if length(positions) > 1
            speed = (positions(end) - positions(end-1)) / dt; % Change in theta over time
            speeds = [speeds; speed];
        else
            speeds = [speeds; 0]; % Initial speed is zero
        end
    end
end

% Plot position (theta) vs time
figure;
subplot(2, 1, 1);
plot(time, positions, '-b');
title('Position (\theta) vs Time');
xlabel('t [ms]');
ylabel('\theta [degrees]');
grid on;

% Plot speed (n) vs time
subplot(2, 1, 2);
plot(time, speeds, '-r');
title('Speed (n) vs Time');
xlabel('t [ms]');
ylabel('n [degrees/ms]');
grid on;

