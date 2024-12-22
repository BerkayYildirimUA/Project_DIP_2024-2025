function distances = point_to_line_distance(points, p1, p2)
    % Calculate perpendicular distances of points to the line defined by p1 and p2
    % points: Nx2 array of (x, y)
    % p1, p2: endpoints of the line
    
    % Vector representation of the line
    lineVec = p2 - p1;
    lineVecNorm = norm(lineVec);
    if lineVecNorm == 0
        distances = vecnorm(points - p1, 2, 2); % Distance to a single point
        return;
    end
    
    % Calculate perpendicular distance
    projection = (points - p1) * (lineVec / lineVecNorm)';
    closestPoint = p1 + projection * (lineVec / lineVecNorm);
    distances = vecnorm(points - closestPoint, 2, 2);
end
