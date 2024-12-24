function representativePoints = groupPoints(points, radius)
    % GROUPPOINTS Groups points into clusters and calculates their representative points.
    %
    % Inputs:
    %   points - Nx2 matrix of points (x, y coordinates)
    %   radius - Scalar defining the radius within which points are grouped
    %
    % Output:
    %   representativePoints - Mx2 matrix of representative points

    remainingPoints = points; % Points yet to be processed
    representativePoints = []; % Initialize the result

    while ~isempty(remainingPoints)
        % Take the first point
        currentPoint = remainingPoints(1, :);

        % Find points within the radius
        distances = sqrt((remainingPoints(:, 1) - currentPoint(1)).^2 + ...
                         (remainingPoints(:, 2) - currentPoint(2)).^2);
        nearbyPointsIdx = distances <= radius;

        % Calculate the average coordinates of the nearby points
        clusterPoints = remainingPoints(nearbyPointsIdx, :);
        avgPoint = mean(clusterPoints, 1);

        % Add the averaged point to the representative points
        representativePoints = [representativePoints; avgPoint];

        % Remove the used points from the remaining points
        remainingPoints(nearbyPointsIdx, :) = [];
    end
end
