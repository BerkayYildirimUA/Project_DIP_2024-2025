% frame0 = load("Ballenwerper_sync_380fps_006.npychunk_0.mat");
% frame1 = load("Ballenwerper_sync_380fps_006.npychunk_1.mat");
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

frame_PointB = imread('frame_PointB.png');

% 


% Load video frames into a 3D matrix 'frames' (300xHxW)
% Assume 'frames' is already in memory.

% Load video frames
numFrames = 1500;   % Total number of frames
frameRate = 1 / 0.25; % Frame rate (4 Hz, given ts = 0.25 seconds)

% Define Point A as a constant (permanent position)
pointA = [897.6928, 937.0970]; % Fixed coordinates of Point A


% Display first frame to select initial Point B
figure;
firstFrame = squeeze(frames(1, :, :)); % Extract first frame

% imshow(firstFrame, []);
% title('Select Point B (End of Rod)');
% hold on;

% [xA, yA] = ginput(1); % User clicks Point B
% pointA = [xA, yA]; % Point B: End of rod


% Select initial Point B manually
% [xB, yB] = ginput(1); % User clicks Point B
% pointB = [xB, yB]; % Point B: End of rod

% Initialize Point Tracker for Point B
% tracker = vision.PointTracker('MaxBidirectionalError', 2);
% initialize(tracker, pointB, firstFrame);

% Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 3);

% Detect initial keypoints
pointsB = detectHarrisFeatures(frame_PointB); %detects corners
%points = detectSIFTFeatures(image_gray_edge);
initialize(tracker, pointsB.Location, firstFrame);

% Initialize arrays for storing tracked positions and angles
trackedPointsB = zeros(numFrames, 2); % Frame, XY for Point B
theta = zeros(numFrames, 1);

 % imshow(firstFrame);
 % title('title');
 % hold on;
 % plot(pointsB);
 % plot(pointA(1), pointA(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle marker


% Process each frame and track Point B
for i = 1:numFrames
    currentFrame = squeeze(frames(i, :, :)); % Extract current frame

    % Track Point B
    [pointsB, validity] = tracker(currentFrame);

    if validity
        trackedPointsB(i, :) = pointsB; % Store Point B position

        % Compute angle theta with Point A as origin
        deltaX = pointsB(1) - pointA(1);
        deltaY = pointsB(2) - pointA(2);

        % Compute angle theta (in degrees) from the -y axis
        theta(i) = atan2d(deltaX, -deltaY);
    else
        trackedPointsB(i, :) = [NaN, NaN]; % Handle invalid tracking
        theta(i) = NaN;
    end

     % Visualize tracked points
    imshow(currentFrame);
    title(i);
    hold on;
   plot(pointsB(validity, 1), pointsB(validity, 2), 'r.');
   plot(pointA(1), pointA(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circle marker
    hold off;
    pause(0.1); % Play as a video
end

% Release tracker
release(tracker);

%%

% Generate time vector
time = (0:numFrames-1) * 0.25;

% Compute angular speed (degrees per second)
% Use finite difference method: diff(theta) / diff(time)
angularSpeed = [0; diff(theta) / 0.25]; % Add 0 to align the array size

% Plot angle theta vs time
figure;
subplot(2, 1, 1);
plot(time, theta, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Angle \theta (degrees)');
title('Angle of Rod with Respect to -Y Axis');
grid on;

% Plot angular speed vs time
subplot(2, 1, 2);
plot(time, angularSpeed, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Angular Speed (degrees/s)');
title('Angular Speed of Rod');
grid on;


%%% Here is were the we analyze the fft

% Remove NaN values from theta
theta_cleaned = theta(~isnan(theta)); % Remove NaN values
time_cleaned = time(~isnan(theta));  % Corresponding time values

% Sampling frequency
fs = 1 / 0.25; % Sampling frequency (4 Hz, based on time step)

% Subtract mean to remove DC offset
theta_cleaned = theta_cleaned - mean(theta_cleaned);

% Perform FFT
n = length(theta_cleaned);                 % Number of samples
frequencies = (0:n-1)*(fs/n);              % Frequency vector
fft_theta = fft(theta_cleaned);            % FFT of the angular displacement
magnitude = abs(fft_theta);                % Magnitude of the FFT

% Only keep positive frequencies
half_idx = 1:ceil(n/2);
frequencies = frequencies(half_idx);
magnitude = magnitude(half_idx);

% Plot the frequency spectrum
figure;
plot(frequencies, magnitude, 'LineWidth', 2);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Spectrum of Rod Motion');
grid on;

% Identify dominant vibration frequencies
[peaks, locations] = findpeaks(magnitude, frequencies, 'MinPeakHeight', max(magnitude)*0.1);
disp('Dominant frequencies (Hz):');
disp(locations);
