function simplifiedMask = polylinear_approximation(mask, D)
    % mask: binary mask
    % D: maximum allowable distance from a point to the line

    % Extract points from the binary mask
    [row, col] = find(mask);
    points = [col, row];

    % Initialize stacks
    TP = 1; % Start with the first index
    PD = zeros(size(points, 1), 1); % Preallocate PD to the maximum possible size
    pdIndex = 1; % Current top index for PD
    PD(pdIndex) = size(points, 1); % Add the last point to PD

    while ~isempty(TP)
        % Get the tops of the stacks
        tTP = TP(end);
        tPD = PD(pdIndex);

        % Line endpoints
        p1 = points(tTP, :);
        p2 = points(tPD, :);

        % Points between tTP and tPD
        segmentIndices = (tTP+1):(tPD-1);
        if isempty(segmentIndices)
            % No intermediate points, move tTP to PD
            pdIndex = pdIndex + 1;
            PD(pdIndex) = tTP;
            TP(end) = []; % Remove top of TP
            continue;
        end
        segmentPoints = points(segmentIndices, :);

        % Calculate distance of all points to the line defined by p1 and p2
        distances = point_to_line_distance(segmentPoints, p1, p2);
        [maxDist, maxIdx] = max(distances);

        if maxDist > D
            % If max distance exceeds D, add the farthest point to TP
            TP = [TP; segmentIndices(maxIdx)];
        else
            % Otherwise, move tTP to PD
            pdIndex = pdIndex + 1;
            PD(pdIndex) = tTP;
            TP(end) = []; % Remove top of TP
        end
    end

    % Reconstruct simplified points from PD
    simplifiedIndices = flip(PD(1:pdIndex));
    simplifiedPoints = points(simplifiedIndices, :);

    % Create a binary mask from simplified points
    simplifiedMask = false(size(mask));
    for i = 1:size(simplifiedPoints, 1)
        simplifiedMask(simplifiedPoints(i, 2), simplifiedPoints(i, 1)) = true;
    end
end