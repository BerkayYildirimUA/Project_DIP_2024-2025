function video_to_mp4(video_var_name, output_filename, frame_rate)
    % Convert a loaded video variable into an MP4 file, processing frames sequentially.
    % Displays a wait bar with estimated time remaining.
    %
    % Parameters:
    % video_var_name: The name of the variable in the workspace containing the video.
    % output_filename: The output filename (e.g., 'output.mp4').
    % frame_rate: Frame rate for the output video (e.g., 30 for 30 fps).

    % Check if the variable exists in the workspace
    if ~evalin('base', sprintf('exist(''%s'', ''var'')', video_var_name))
        error('Variable %s does not exist in the workspace.', video_var_name);
    end

    % Retrieve the video data from the workspace
    video_data = evalin('base', video_var_name);

    % Validate video data dimensions
    if ndims(video_data) ~= 3
        error('Video data must be a 3D array: [frames, height, width].');
    end

    % Get the number of frames
    num_frames = size(video_data, 1);

    % Initialize the video writer
    video_writer = VideoWriter(output_filename, 'MPEG-4');
    video_writer.FrameRate = frame_rate;
    open(video_writer);

    % Initialize wait bar
    wait_bar = waitbar(0, 'Processing video frames...', 'Name', 'Video to MP4 Conversion');
    start_time = tic; % Start timing

    % Process and write each frame incrementally
    for frame_idx = 1:num_frames
        % Extract the current frame
        frame = squeeze(video_data(frame_idx, :, :));

        % Ensure the frame is of type double
        frame = double(frame);

        % Normalize frame to [0, 1] if necessary
        if max(frame(:)) > 1
            frame = frame / max(frame(:));
        end

        % Convert to RGB format (grayscale to RGB)
        frame_rgb = repmat(frame, [1, 1, 3]);

        % Write the frame to the video
        writeVideo(video_writer, frame_rgb);

        % Update the wait bar
        elapsed_time = toc(start_time);
        estimated_total_time = (elapsed_time / frame_idx) * num_frames;
        time_remaining = estimated_total_time - elapsed_time;
        waitbar(frame_idx / num_frames, wait_bar, ...
            sprintf('Processing video frames... %d/%d\nEstimated time remaining: %.1f seconds', ...
            frame_idx, num_frames, time_remaining));
    end

    % Close the video writer
    close(video_writer);

    % Close the wait bar
    close(wait_bar);

    fprintf('Video saved to %s.\n', output_filename);
end


