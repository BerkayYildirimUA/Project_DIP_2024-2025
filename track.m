function [theta, trackedPoints] = track(frames, pointA, pointB)

% This function trackes the pointB with reference to pointA of the frames
% parameter. It returns a vector of position (theta) values aswell as
% tracked points

% Initialize progress bar
waitBar = waitbar(0, 'Processing frames...');

% Get the frames
numFrames = size(frames, 1);

% Get the first frame
firstFrame = squeeze(frames(1, :, :));

% Initialize arrays for storing tracked positions and angles
trackedPoints = zeros(numFrames, 2); % Frame, XY for Point B
theta = zeros(numFrames, 1);

% Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 3);

% Initialize tracker
initialize(tracker, pointB, firstFrame);

% Process each frame and track Point B
for i = 1:numFrames
    currentFrame = squeeze(frames(i, :, :)); % Extract current frame

    % Track Point B
    [pointB, validity] = tracker(currentFrame);

    if validity
        trackedPoints(i, :) = pointB; % Store Point B position

        % Compute angle theta with Point A as origin
        deltaX = pointB(1) - pointA(1);
        deltaY = pointB(2) - pointA(2);

        % Compute angle theta (in degrees) from the -y axis
        % why does this work? 
        theta(i) = 180 + atan2d(deltaX, -deltaY);
    else
        trackedPoints(i, :) = [NaN, NaN]; % Handle invalid tracking
        theta(i) = NaN;
    end

      % Update progress bar
    waitbar(i / numFrames, waitBar, sprintf('Processing frame %d of %d...', i, numFrames));

end

% Close progress bar
close(waitBar);

% Release tracker
release(tracker);

end
