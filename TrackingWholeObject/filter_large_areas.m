function filteredMask = filter_large_areas(mask, maxSize)
    % mask: Input binary mask
    % maxSize: Maximum allowable area size (in pixels)

    % Label connected components
    labeledMask = bwlabel(mask);
    
    % Measure properties of connected components
    stats = regionprops(labeledMask, 'Area');
    
    % Find components that are within the size limit
    validLabels = find([stats.Area] <= maxSize);
    
    % Create a new mask containing only valid components
    filteredMask = ismember(labeledMask, validLabels);
end