clearvars -except Video_6

currentPath = mfilename('fullpath');

separatorIndex = find(currentPath == filesep, 1, 'last');
projectRoot = currentPath(1:separatorIndex-1);
separatorIndex = find(projectRoot == filesep, 1, 'last');
projectRoot = projectRoot(1:separatorIndex-1);

load_video_chunks([6], true, projectRoot);
addpath(projectRoot);
frames = Video_6;

%% start frame
frame_1 = squeeze(frames(269, :, :));
frame_1 = adapthisteq(frame_1, "Distribution", "exponential");


%% lighting normalization lighting
% get avrage light of the top rows which don't move. We will change the
% gama of all frames later to mach this reference brightness
backGround = imread('updated_background.png');
topRows = 1:30;
referenceBrightness = mean(backGround(topRows, :), 'all');

%% machine mask
% hand made, (only shape matters)
image_gray = imread('cutout.png');

%use all pixles in the mask
binaryImage = imbinarize(image_gray, 0.1);
[y, x] = find(binaryImage);
points = [x, y];

%save area of mask, sligtly less than actualy size for safty
[totalArea, ~] = size(y);
totalArea = totalArea * 0.95;


%% Initialize point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 30, 'NumPyramidLevels', 3, 'BlockSize', [25, 25], 'MaxIterations', 20);
initialize(tracker, points, frame_1);


%% make video
% so we can keep track of progress
outputDir = 'videos';
if ~exist(outputDir, 'dir')
   mkdir(outputDir);
end

filename = fullfile(outputDir, [datestr(now, 'yyyymmdd_HHMMSS') '.mp4']);
outputVideo = VideoWriter(filename, 'MPEG-4');
outputVideo.FrameRate = 30; % Set desired frame rate
open(outputVideo);

%make a waitbar so we know how the code is doing.
startTime = tic;
hWaitbar = waitbar(0, 'Starting...', 'Name', 'Progress', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');

%start and end frames
lastFrameIndex = 1500;
startFrameIndex = 268;
for i = (startFrameIndex+1):(lastFrameIndex-1) %we use the previous and next frame as info later, so we start a bit later and stop a bit erlier
    %% waitbar
    if getappdata(hWaitbar, 'canceling')
        disp('User canceled the operation.');
        break;
    end

    elapsedTime = toc(startTime);
    progress = (i-startFrameIndex - 1)/(lastFrameIndex-startFrameIndex - 1);
    estimatedTotalTime = elapsedTime / progress;
    remainingTime = estimatedTotalTime - elapsedTime;
    waitbar(progress, hWaitbar, sprintf('Progress: %.2f%%\nTime left: %.1f seconds', progress * 100, remainingTime));

    %% Extract the next frame
    thisFrameNotNormal = squeeze(frames(i, :, :));
    thisFrame = normalizeFrame(thisFrameNotNormal, referenceBrightness);

    prevFrame = squeeze(frames(i - 1, :, :));
    prevFrame = normalizeFrame(prevFrame, referenceBrightness);

    nextFrame = squeeze(frames(i + 1, :, :));
    nextFrame = normalizeFrame(nextFrame, referenceBrightness);
    
    %% get area of intrest
    % get area of intrest from frames. These are the only places put are
    %allowed to be, it's a bit bigger than the actual area. Combing these 3
    %because frame to frame variation isn't that much, so were they overlap
    %should deffinatly be the area of intrest
    areaOfIntrest1 = getAreaOfIntrest(backGround, thisFrame);
    areaOfIntrest2 = getAreaOfIntrest(backGround, nextFrame);
    areaOfIntrest3 = getAreaOfIntrest(backGround, prevFrame);

    areaOfIntrest = areaOfIntrest1 & areaOfIntrest2 & areaOfIntrest3;
    
    % used for testing, sometimes we may wanna disable the above code and
    % see if this works better.
    %areaOfIntrest = getAreaOfIntrest(backGround, thisFrame);


    %% get Track points
    [newPoints, validity] = tracker(thisFrame);
    validNewPoints = newPoints(validity, :);

    % we turn these points into a binary mask
    validNewPointsBinaryMask = false(size(thisFrame)); % Initialize a binary mask of the same size as the frame
    
    rows = round(validNewPoints(:, 2)); % Y-coordinates 
    cols = round(validNewPoints(:, 1)); % X-coordinates

    % Set the corresponding locations in the mask to true
    validNewPointsBinaryMask(sub2ind(size(validNewPointsBinaryMask), rows, cols)) = true;
    
    %trim out points outside of the area of intrest
    validNewPointsBinaryMask = validNewPointsBinaryMask & areaOfIntrest; 

    %% add checker mask
    % the idea is, sometimes we lose point because of bad edge detection.
    % So using a checker box to "seed" new point is the idea.
    squareSize = 6;
    [maskHeight, maskWidth] = size(areaOfIntrest); % Size of the existing mask

    checkerPattern = checkerboard(squareSize, ceil(maskHeight / (2 * squareSize)), ...
                              ceil(maskWidth / (2 * squareSize)));

    checkerMask = checkerPattern > 0.5;

    checkerMask = checkerMask(1:maskHeight, 1:maskWidth);

    areaOfIntrestcheckerMask = areaOfIntrest & checkerMask;

    validNewPointsBinaryMask = validNewPointsBinaryMask | areaOfIntrestcheckerMask;

    %% edge detection
    %trying to use edge detection to redraw lost points. zerocross and log not
    %used cause they create to much noise.

    SobelMask       = edge(thisFrame, 'Sobel');
    PrewittMask     = edge(thisFrame, 'Prewitt');
    RobertsMask     = edge(thisFrame, 'Roberts');
    CannyMask       = edge(thisFrame, 'Canny', [], 4);
    % % 
    total = SobelMask | PrewittMask | RobertsMask | CannyMask;

    % can chose to add info of the neiboring frames as well. might help
    % close area's that didn't close because of bad edge detection
    
    % SobelMask       = edge(prevFrame, 'Sobel');
    % PrewittMask     = edge(prevFrame, 'Prewitt');
    % RobertsMask     = edge(prevFrame, 'Roberts');
    % CannyMask       = edge(prevFrame, 'Canny', [], 4);
    % ApproxCannyMask = edge(prevFrame, 'approxcanny');
    % % % 
    % prevTotal = SobelMask | PrewittMask | RobertsMask | CannyMask | ApproxCannyMask;

    % SobelMask       = edge(nextFrame, 'Sobel');
    % PrewittMask     = edge(nextFrame, 'Prewitt');
    % RobertsMask     = edge(nextFrame, 'Roberts');
    % CannyMask       = edge(nextFrame, 'Canny', [], 4);
    % ApproxCannyMask = edge(nextFrame, 'approxcanny');
    % % % 
    % nextTotal = SobelMask | PrewittMask | RobertsMask | CannyMask | ApproxCannyMask;

    %total = prevTotal | total | nextTotal;

    %% not used anymore -> is very slow, don't have to much time to keep running tests with this. Is still kinda promesing so kept it in
    % the idea here was, after edge detection or the binary mask of the valid points, we wanna find all pixles that
    % are at the end of a stray line, and make them connect to the closed
    % pixles like themselves. Like connect the dots. This could've helpt redraw
    % lost pixles, or closed open bounds caused by bad edge detection.

    % % % Step 1: Skeletonize the binary image
    %  skeleton = bwmorph(validNewPointsBinaryMask, 'skel', Inf);
    % % 
    % % % Step 2: Detect endpoints
    %  endpoints = bwmorph(skeleton, 'endpoints');
    % % 
    % % 
    % % % Get coordinates of the endpoints
    %  [end_y, end_x] = find(endpoints);
    % % 
    % % % Step 3: Connect spikes
    % % % Create a copy of the skeleton for modifications
    %  connectedSkeleton = connect_all_points(skeleton, end_x, end_y, 20);
    % %   
    % % %%%%
    % % diffrent way to try the same thing, 
    % %
    %  CannyMask = edge(validNewPointsBinaryMask, 'Canny');
    %  CannyEndpoints = bwmorph(CannyMask, 'endpoints');
    % % %filteredPoints = polylinear_approximation(CannyEndpoints, 10); % couldn't get polylinear_approximation working right
    % % 
    %  [end_y, end_x] = find(CannyEndpoints);
    %  CannyConnected = connect_all_points(CannyEndpoints, end_x, end_y);
    % 
    % 
    % 
    % validNewPointsBinaryMask = validNewPointsBinaryMask | connectedSkeleton | CannyConnected;



    
    %% cleaning up edges
    % there are lots of times that bad lighting causes edge detection to go
    % haywire inside of the machine. So, if there are to many pixles in an 
    % area, I wanna replace them with a hollow diamond shape. This would
    % make the mask have more of a real border, and less clumpt up points
    % near the edge.
    
    % Define the structural element
    se = strel('diamond', 7);

    % Get the binary mask of the structural element
    seMask = se.Neighborhood; % Structural element as binary mask

    % Create the hollow (outline) version of the structural element
    hollowSE = seMask & ~imerode(seMask, strel('disk', 1));

    % Calculate the number of pixels in the structural element
    numPixelsInSE = sum(seMask(:));

    % Convolve the input mask with the structural element
    localSum = conv2(double(total), double(seMask), 'same');

    % Calculate the percentage of white pixels in the neighborhood
    percentage = localSum / numPixelsInSE;

    % Find areas where 50% or more of the pixels are white
    thresholdMask = (percentage >= 0.5);

    % Get the indices of the pixels affected by the structural element
    [rows, cols] = find(thresholdMask);

    % Initialize lists for pixels to be set to 1 or 0
    needToBeOne = false(size(total));
    needToBeZero = false(size(total));

    % Create offsets for the hollow structural element
    [offsetRows, offsetCols] = find(hollowSE);
    centerOffset = floor(size(hollowSE) / 2);

    % Loop through each affected position and add indices
    for k = 1:length(rows)
        % Calculate the positions for the structural element
        rowOffset = rows(k) - centerOffset(1);
        colOffset = cols(k) - centerOffset(2);

        % Apply offsets for hollow region
        hollowRowIndices = rowOffset + offsetRows;
        hollowColIndices = colOffset + offsetCols;

        % Ensure indices are within bounds
        validIndices = hollowRowIndices > 0 & hollowColIndices > 0 & ...
                       hollowRowIndices <= size(total, 1) & hollowColIndices <= size(total, 2);

        hollowRowIndices = hollowRowIndices(validIndices);
        hollowColIndices = hollowColIndices(validIndices);

        % Update masks
        linearIndices = sub2ind(size(total), hollowRowIndices, hollowColIndices);
        needToBeOne(linearIndices) = true;
        needToBeZero(rows(k), cols(k)) = true; % Center pixel is cleared
    end

    % Update the result
    result = total;
    result(needToBeOne) = 1;
    result(needToBeZero) = 0;
    
    thinedTotalResult = bwmorph(result, 'remove') | bwmorph(areaOfIntrestcheckerMask, 'remove'); %a hallow version of the checker mask is added, also in an attempt to help close open bordereds.

    %% trying to create regions
    % I would ike to have regions in the mask. If a tracked point is inside of it
    % I would like to add all points in the enclosed region to the tracking list.
    
    thick = bwmorph(validNewPointsBinaryMask, 'thicken');
    brigdeClose = bwmorph(thick, 'close');
    bridged = bwmorph(brigdeClose, 'bridge');
    
    bridged(thinedTotalResult == 1) = 0;

    % %% STARS
    % %kinda similar idea as line 188
    % %I want to connect regions that didn't connect well because of bad edge
    % %dection. The idea here, we find these end point sof lines again. But this
    % %time, be just put a big star in there. The lines tend to be close to where
    % %they were suppose to end. So we hope they can connect to the other side of the line that the edge detection happened to miss.
    % 
    % %this is the shape I mean with "star":
    % % 1     1     1
    % %   1   1   1  
    % %     1 1 1    
    % % 1 1 1 1 1 1 1
    % %     1 1 1    
    % %   1   1   1  
    % % 1     1     1
    % 
    % %ends = bwmorph(~bridged, 'endpoints');
    % 
    % % find the ends, looking for pixles with exalt 1 neigbor or less
    % neighborhoodKernel = ones(3, 3); 
    % neighborhoodKernel(2, 2) = 0;
    % neighborCount = conv2(~bridged, neighborhoodKernel, 'same');
    % dots = (~bridged == 1) & (neighborCount <= 1);
    % 
    % %dots = filter_large_areas(ends, 1); % trying to get rid of area's if
    % %they are to close togater
    % 
    % %making the star shape
    % starLength = 9;
    % horizontal =    center_in_matrix(getnhood(strel("line",starLength,0)), starLength);
    % vertical =      center_in_matrix(getnhood(strel("line",starLength,90)), starLength);
    % leftleaning =   center_in_matrix(getnhood(strel("line",starLength * sqrt(2),45)), starLength);
    % rightleaning =  center_in_matrix(getnhood(strel("line",starLength * sqrt(2),-45)), starLength);
    % 
    % star = horizontal | vertical | leftleaning | rightleaning;
    % 
    % % adding the stars
    % stars = imdilate(dots, star);
    % 
    % %getting rid of to large areas
    % smallStars = filter_large_areas(stars, 200);
    % 
    % %make a copy for easy debugging
    % addedStars = bridged;
    % 
    % addedStars(smallStars == 1) = 0;
    %% final touch ups to the mask

    %open up the lines, get's rid of stray lines on the other edge.
    openUp = imopen(bridged, [1 1; 1 1]);
    
    %close up to fill in the whole a bit more
    %closed = imclose(openUp, strel("disk", 3));
    


    %% find the erea's with points in them 
    [labeledMask, numAreas] = bwlabel(openUp, 4);

    % % used for debuggings, shows all area's in diffrent colors
    %coloredImage = label2rgb(labeledMask, 'jet', 'k', 'shuffle'); 
    %imshow(coloredImage); 
    
    %filled masked with valid trecking points
    filledValidPoinst = imfill(validNewPointsBinaryMask, 'holes'); % validNewPointsBinaryMask from line 153
    
    %get rid of stray lines
    openUpValidPonits = imopen(filledValidPoinst, [1 1; 1 1]);

    
    %in the are finding the area's that have a tracking point in them and
    %adding them to a final mask. These are's are all suppose to be part of
    %the moving contraption
    [col, row] = find(openUpValidPonits);
    eraPoints = [row, col];

    validPointsIndices = sub2ind(size(thisFrame), round(eraPoints(:, 2)), round(eraPoints(:, 1))); % Convert points to linear indices
    areasWithPoints = unique(labeledMask(validPointsIndices)); % Get unique area labels with points
    
    areasWithPoints(areasWithPoints == 0) = [];
    finalMask = ismember(labeledMask, areasWithPoints);

    [row, col] = find(finalMask);
    pointsList = [col, row];

    combined = [validNewPoints; pointsList]; %you keep the points you still have and add the new ones

    %% FILTER OUT BAD POINTS
    % get rid of points that are outside of the Area of Intrest

    combinedMask = false(size(thisFrame)); % Initialize a binary mask of the same size as the frame

    rows = round(combined(:, 2)); % Y-coordinates 
    cols = round(combined(:, 1)); % X-coordinates 

    % Set the corresponding locations in the mask to true
    combinedMask(sub2ind(size(combinedMask), rows, cols)) = true;


    combinedMaskAndAreaOfIntrest = combinedMask & areaOfIntrest; % take only the parts insisde of the Area of Intrest
    filledUpCombo = imfill(combinedMaskAndAreaOfIntrest, 'holes');

    openComboMask = imopen(filledUpCombo, [1 1; 1 1]); %get rid of stray lines
    lastMask = imclose(openComboMask, [1 1; 1 1]); %fill up holes

    %%  thin final mask
    % to prevent infinte growth, we thin the final mask until it's the same
    % area as the original mask we found at the start

    currentArea = nnz(lastMask); % Count the number of non-zero (true) pixels
    while currentArea > totalArea
        lastMask = bwmorph(lastMask, 'thin', 1);
    
        currentArea = nnz(lastMask);
        %fprintf('Current area: %d, Target area: %d\n', currentArea, totalArea);
    end


    % imtool(areaOfIntrest);
    % imtool(lastMask);

    %% add new points to the tracker
    
    [row, col] = find(lastMask);
    finalPoints = [col, row];

    tracker.setPoints(finalPoints);

    %imshow(thisFrame);
    %hold on;
    %plot(col, row, 'rx', 'MarkerSize', 1); % Red 'x' markers for points
    %plot(combined(:, 1), combined(:, 2), 'bx', 'MarkerSize', 1); % Blue 'x' markers for new points
    %hold off;

    %% save to video

    thisFrameRGB = repmat(uint8(thisFrame), [1, 1, 3]); % Convert to RGB
    thisFrameRGB = insertMarker(thisFrameRGB, finalPoints, 'x', 'Color', 'red', 'Size', 1);
    %thisFrameRGB = insertMarker(thisFrameRGB, groupPoints(finalPoints, 300), 'x', 'Color', 'blue', 'Size', 5);

    writeVideo(outputVideo, thisFrameRGB);
end


close(hWaitbar); %doesn't seem to work for me but this is how you're suppose to do it.
if isvalid(hWaitbar)
    closeAllWaitbars(); %selfmade function. Sometimes I keep having floating waitbars I can't get rid of by pressing the red X.
end

close(outputVideo);
