function updatedImage = connect_all_points(image, xPoints, yPoints, maxDistance)
    % Default maxDistance to Inf if not provided
    if nargin < 4
        maxDistance = Inf;
    end

    % Ensure coordinates are integers
    xPoints = round(xPoints);
    yPoints = round(yPoints);

    % Initialize updated image
    updatedImage = image;

    % Create a list of unconnected points
    points = [xPoints(:), yPoints(:)];
    numPoints = size(points, 1);
    connected = false(numPoints, 1); % Tracks whether a point is connected
    connected(1) = true; % Start with the first point connected

    currentPoint = points(1, :); % Start from the first point

    % Connect all points
    for i = 1:numPoints - 1
        % Calculate distances to all unconnected points
        unconnectedIndices = find(~connected);
        distances = sqrt((points(unconnectedIndices, 1) - currentPoint(1)).^2 + ...
                         (points(unconnectedIndices, 2) - currentPoint(2)).^2);

        % Find the nearest unconnected point
        [minDistance, nearestIdx] = min(distances);
        nearestPointIdx = unconnectedIndices(nearestIdx);
        nearestPoint = points(nearestPointIdx, :);

        % Check if the nearest point is within the maxDistance
        if minDistance <= maxDistance
            % Connect the current point to the nearest unconnected point
            updatedImage = connect_pixels(updatedImage, currentPoint(1), currentPoint(2), ...
                                           nearestPoint(1), nearestPoint(2));

            % Mark the nearest point as connected
            connected(nearestPointIdx) = true;

            % Move to the nearest point
            currentPoint = nearestPoint;
        else
            % If no points are within maxDistance, break the loop
            break;
        end
    end

    % Optional: Connect the last point back to the first to form a loop if within maxDistance
    loopDistance = sqrt((points(1, 1) - currentPoint(1))^2 + (points(1, 2) - currentPoint(2))^2);
    if loopDistance <= maxDistance
        updatedImage = connect_pixels(updatedImage, currentPoint(1), currentPoint(2), ...
                                       points(1, 1), points(1, 2));
    end
end

function image = connect_pixels(image, x1, y1, x2, y2)
    % Bresenham's line algorithm to draw a line between two points
    % Initialize conditions
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    sx = sign(x2 - x1);
    sy = sign(y2 - y1);
    err = dx - dy;

    while true
        % Set the pixel
        image(y1, x1) = 1;

        % Check if the line has reached the end point
        if x1 == x2 && y1 == y2
            break;
        end

        % Calculate error and adjust coordinates
        e2 = 2 * err;
        if e2 > -dy
            err = err - dy;
            x1 = x1 + sx;
        end
        if e2 < dx
            err = err + dx;
            y1 = y1 + sy;
        end
    end
end