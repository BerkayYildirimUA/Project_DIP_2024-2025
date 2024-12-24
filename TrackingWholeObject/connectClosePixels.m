function outputImage = connectClosePixels(binaryImage, maxDistance)
% CONNECTCLOSEPIXELS Connects black pixels within a specified distance using KD-Tree.
%
% This version uses no explicit for-loops. Instead, it uses cellfun and vectorized operations.
%
% INPUTS:
%   binaryImage   - Binary image (1=white, 0=black).
%   maxDistance   - Maximum distance between black pixels to connect them.
%
% OUTPUT:
%   outputImage   - Modified binary image with lines drawn between close black pixels.

    % Ensure binary and black pixels are '1'
    if ~islogical(binaryImage)
        binaryImage = imbinarize(binaryImage);
    end
    binaryImage = ~binaryImage; % Now black = 1

    % Get pixel coordinates
    [rows, cols] = find(binaryImage);
    pixelCoords = [cols, rows]; % (x,y) format

    % Create KD-Tree
    kdtree = KDTreeSearcher(pixelCoords);

    % Find neighbors within maxDistance (rangesearch returns a cell array)
    neighbors = rangesearch(kdtree, pixelCoords, maxDistance);

    % Remove the first element (the point itself) from each neighbors list
    % Using cellfun to avoid explicit loops
    cleanedNeighbors = cellfun(@(x) x(2:end), neighbors, 'UniformOutput', false);

    % For each pixel i, we need to replicate its coordinate as many times as it has neighbors
    startPointsCell = cellfun(@(idxs, i) repmat(pixelCoords(i,:), numel(idxs), 1), ...
                              cleanedNeighbors, ...
                              num2cell((1:size(pixelCoords,1))'), ...
                              'UniformOutput', false);

    % For each pixel, endPoints are simply the coordinates of its neighbors
    endPointsCell = cellfun(@(idxs) pixelCoords(idxs, :), cleanedNeighbors, 'UniformOutput', false);

    % Combine start and end points into line segments
    lineSegmentsCell = cellfun(@(s,e) [s,e], startPointsCell, endPointsCell, 'UniformOutput', false);

    % Concatenate all line segments
    if ~isempty(lineSegmentsCell)
        lines = vertcat(lineSegmentsCell{:});
    else
        lines = [];
    end

    % Draw lines using insertShape
    % Convert binary to RGB for insertShape
    outputRGB = uint8(cat(3, binaryImage*255, binaryImage*255, binaryImage*255));

    if ~isempty(lines)
        outputRGB = insertShape(outputRGB, 'Line', lines, 'Color', 'black', 'LineWidth', 1);
    end

    % Convert back to binary
    outputImage = ~imbinarize(rgb2gray(outputRGB));
end
