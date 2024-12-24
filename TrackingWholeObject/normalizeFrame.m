function [outputFrame] = normalizeFrame(inputFrame, referenceBrightness)
    % applies adaptive histogram equalization to enhance contrast, and normalizes
    % its brightness based on a reference brightness value on any given
    % frame.

    % Inputs:
    % frames - the frame that needs afjustment
    % referenceBrightness - The desired reference brightness to normalize
    %                       the frame against.
    
    topRows = 1:30;
    nextFrame = adapthisteq(inputFrame, "Distribution", "exponential");
    

    % Normalize lighting using top rows
    currentBrightness = mean(nextFrame(topRows, :), 'all'); %mean brightes of top pixles
    adjustmentFactor = referenceBrightness / currentBrightness;
    nextFrame = nextFrame * adjustmentFactor;
    outputFrame = min(nextFrame, 255); % Clip to valid range

end