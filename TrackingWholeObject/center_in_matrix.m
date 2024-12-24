function centeredMask = center_in_matrix(mask, n)
    % Get the size of the input mask
    [rows, cols] = size(mask);
    
    % Trim the input mask if it exceeds the desired dimensions
    if rows > n
        startRow = floor((rows - n) / 2) + 1;
        endRow = startRow + n - 1;
        mask = mask(startRow:endRow, :);
    end
    if cols > n
        startCol = floor((cols - n) / 2) + 1;
        endCol = startCol + n - 1;
        mask = mask(:, startCol:endCol);
    end
    
    % Update size after trimming
    [rows, cols] = size(mask);
    
    % Initialize an n x n matrix of zeros
    centeredMask = false(n, n);
    
    % Compute the start and end indices for centering
    rowStart = ceil((n - rows) / 2) + 1;
    colStart = ceil((n - cols) / 2) + 1;
    rowEnd = rowStart + rows - 1;
    colEnd = colStart + cols - 1;
    
    % Place the trimmed or unmodified mask in the center
    centeredMask(rowStart:rowEnd, colStart:colEnd) = mask;
end
