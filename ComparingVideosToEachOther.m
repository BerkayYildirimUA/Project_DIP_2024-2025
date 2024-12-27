%% Reading and loading the video data of the first and the third video chunk
% This code may be should be changed on the way you get the frames variable
% The frames variable should have a format of Nx1726x2240 with N the amount
% of frames in the video

clear 
close all 
clc

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_0.mat");
frame1 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_1.mat");
frame2 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_2.mat");
frame3 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_3.mat");
frame4 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_4.mat");
frame5 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_5.mat");
frame6 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_6.mat");
frame7 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_7.mat");
frame8 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_8.mat");
frame9 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_9.mat");

frames = cat(1, frame0.video_data, frame1.video_data, frame2.video_data, ...
     frame3.video_data, frame4.video_data, frame5.video_data, ...
     frame6.video_data, frame7.video_data, frame8.video_data, ...
     frame9.video_data);

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_0.mat");
frame1 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_1.mat");
frame2 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_2.mat");
frame3 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_3.mat");
frame4 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_4.mat");
frame5 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_5.mat");
frame6 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_6.mat");
frame7 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_7.mat");
frame8 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_8.mat");
frame9 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_9.mat");

frames3 = cat(1, frame0.Ballenwerper_sync_380fps_003, frame1.Ballenwerper_sync_380fps_003, ...
    frame2.Ballenwerper_sync_380fps_003, frame3.Ballenwerper_sync_380fps_003, ...
    frame4.Ballenwerper_sync_380fps_003, frame5.Ballenwerper_sync_380fps_003, ...
     frame6.Ballenwerper_sync_380fps_003, frame7.Ballenwerper_sync_380fps_003, ...
     frame8.Ballenwerper_sync_380fps_003, frame9.Ballenwerper_sync_380fps_003);


%% tracking the video and getting the theta values 

% frame point accessed using png file
frame_PointB = imread('frame_PointB.png');

% Define Point A as a constant (permanent position)
pointA = [897.6928, 937.0970]; % Fixed coordinates of Point A

% Detect initial keypoints
pointB = detectHarrisFeatures(frame_PointB); % detects corners

% First frame is shown with the reference and tracking point
figure;
firstFrame = squeeze(frames(1, :, :));
imshow(firstFrame);
hold on
plot(pointA(1), pointA(2), "ro", "LineWidth", 3, 'DisplayName', 'Reference');
plot(pointB.Location(1), pointB.Location(2), 'g.', 'LineWidth', 3, 'DisplayName', 'Tracking');
legend show;
hold off

% track the video
[theta, trackedPoints] = track(frames, pointA, pointB.Location);


%% tracking the video and getting the theta values 
% The points are extracted by first using ginput to find the coordinates
% and then hardcode them into the code

% Define Point A as a constant (permanent position)
point3A = [875.798716452742, 958.158109684948];

point3B = [734.818553092182, 1205.88039673279];

% First frame is shown with the reference and tracking point
figure;
firstFrame = squeeze(frames3(1, :, :));
imshow(firstFrame);
hold on
plot(point3A(1), point3A(2), "ro", "LineWidth", 3, 'DisplayName', 'Reference');
plot(point3B(1), point3B(2), 'g.', 'LineWidth', 3, 'DisplayName', 'Tracking');
legend show;
hold off

[theta3, trackedPoints3] = track(frames3, point3A, point3B);
%% Getting the angular speed and plotting the it and the theta values

% Enter the framerate of the video
fps = 380;

% Generate time vector
timeVid = (0:length(theta)-1) / fps * 1000;

% Compute angular speed (degrees per second)
% Use finite difference method: diff(theta) / diff(time)
omega = [0; diff(theta) * fps]; % Add 0 to align the array size

% Multiplies by the fps to get similar values as in csv file
% I do not know the correlation between this values the framerate of the
% video, maybe just coincidence?

% Plot the last frame and trajectory
figure;
imshow(squeeze(frames(end, :, :))); % Show the last frame
hold on;
plot(trackedPoints(:, 1), trackedPoints(:, 2), 'g-', 'LineWidth', 1.5); % Plot trajectory
plot(pointA(1), pointA(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Mark Point A
plot(trackedPoints(end, 1), trackedPoints(end, 2), 'bo', 'MarkerSize', 10, 'LineWidth', 2)
title('Trajectory of Point B');
legend({'Trajectory', 'Point A', 'Point B'}, 'Location', 'Best');
hold off;

% Plot angle theta vs time
figure;
subplot(2, 1, 1);
plot(timeVid, theta, 'LineWidth', 2);
xlabel('t (ms)');
ylabel(' \theta (°)');
title('Angle of Rod with Respect to -Y Axis');
grid on;

% Plot angular speed vs time
subplot(2, 1, 2);
plot(timeVid, omega, 'LineWidth', 2);
xlabel('t (ms)');
ylabel('Angular Speed (°/ms)');
title('Angular Speed of Rod');
grid on;


%% Getting the angular speed and plotting the it and the theta values

% Enter the framerate of the video
fps = 380;

% Generate time vector
timeVid3 = (0:length(theta3)-1) / fps * 1000;

% Compute angular speed (degrees per second)
% Use finite difference method: diff(theta) / diff(time)
omega3 = [0; diff(theta3) * fps]; % Add 0 to align the array size

% Multiplies by the values 380 to get similar values as in csv file
% I do not know the correlation between this values the framerate of the
% video, maybe just coincidence?

% Plot the last frame and trajectory
figure;
imshow(squeeze(frames3(end, :, :))); % Show the last frame
hold on;
plot(trackedPoints3(:, 1), trackedPoints3(:, 2), 'g-', 'LineWidth', 1.5); % Plot trajectory
plot(point3A(1), point3A(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Mark Point A
plot(trackedPoints3(end, 1), trackedPoints3(end, 2), 'bo', 'MarkerSize', 10, 'LineWidth', 2)
title('Trajectory of Point 3B');
legend({'Trajectory', 'Point 3A', 'Point 3B'}, 'Location', 'Best');
hold off;

% Plot angle theta vs time
figure;
subplot(2, 1, 1);
plot(timeVid3, theta3, 'LineWidth', 2);
xlabel('t (ms)');
ylabel(' \theta (°)');
title('Angle of Rod with Respect to -Y Axis');
grid on;

% Plot angular speed vs time
subplot(2, 1, 2);
plot(timeVid3, omega3, 'LineWidth', 2);
xlabel('t (ms)');
ylabel('Angular Speed (°/ms)');
title('Angular Speed of Rod');
grid on;

%%
% Compute the difference in positions and angular speeds
theta_diff = theta - theta3; % Difference in positions
omega_diff = omega - omega3; % Difference in angular speeds

% Visualization
figure;

% Plot angular positions
subplot(3, 1, 1);
plot(timeVid, theta, 'b-', 'LineWidth', 1.5); hold on;
plot(timeVid3, theta3, 'r--', 'LineWidth', 1.5);
xlabel('Time (ms)');
ylabel('Angular Position (rad)');
legend('\theta', '\theta_3');
title('Angular Position Comparison');
grid on;

% Plot angular speeds
subplot(3, 1, 2);
plot(timeVid, omega, 'b-', 'LineWidth', 1.5); hold on;
plot(timeVid3, omega3, 'r--', 'LineWidth', 1.5);
xlabel('Time (ms)');
ylabel('Angular Speed (rad/ms)');
legend('\omega_1', '\omega_2');
title('Angular Speed Comparison');
grid on;

% Plot difference in angular positions
subplot(3, 1, 3);
plot(timeVid, theta_diff, 'k-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('\Delta\theta (rad)');
title('Difference in Angular Positions');
grid on;
