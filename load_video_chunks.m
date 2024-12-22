function load_video_chunks(video_numbers, deleteFramesAfterVideoIsMade)
    % Load video chunks into the workspace and optionally delete frames after concatenation.
    % 
    % Parameters:
    % video_numbers: Array of video numbers to load (default: 1:7).
    % deleteFramesAfterVideoIsMade: Boolean to indicate whether to delete frame variables 
    %                               after creating the video (default: false).

    if nargin < 1
        video_numbers = 1:7; % Default to videos 1 through 7
    end
    if nargin < 2
        deleteFramesAfterVideoIsMade = false; % Default to keep frames
    end

    base_path = "Imports"; % Folder where the files are stored

    for video_num = video_numbers
        video_var_name = sprintf('Video_%d', video_num);

        % Check if the video is already loaded
        if evalin('base', sprintf('exist(''%s'', ''var'')', video_var_name))
            fprintf('Skipping Video_%d: Already loaded.\n', video_num);

            % Delete frame variables if the video is already loaded
            if deleteFramesAfterVideoIsMade
                for chunk_num = 0:9
                    frame_var_name = sprintf('Frame_%d_%d', video_num, chunk_num);
                    if evalin('base', sprintf('exist(''%s'', ''var'')', frame_var_name))
                        evalin('base', sprintf('clear %s', frame_var_name));
                        fprintf('Deleted %s as Video_%d is already loaded.\n', frame_var_name, video_num);
                    end
                end
            end

            continue;
        end

        frames = []; % Initialize empty array for concatenated frames

        for chunk_num = 0:9 % Each video has 9 chunks
            chunk_file = sprintf("Ballenwerper_sync_380fps_%03d_chunk_%d.mat", video_num, chunk_num);
            chunk_path = fullfile(base_path, chunk_file);
            frame_var_name = sprintf('Frame_%d_%d', video_num, chunk_num);

            if evalin('base', sprintf('exist(''%s'', ''var'')', frame_var_name))
                fprintf('Skipping %s: Already loaded.\n', frame_var_name);
                continue;
            end

            if isfile(chunk_path)
                fprintf('Loading %s...\n', chunk_path);
                loaded_data = load(chunk_path);

                % Automatically detect the data field
                field_names = fieldnames(loaded_data);
                if numel(field_names) ~= 1
                    error('Unexpected structure in %s. Expected exactly one field.', chunk_file);
                end

                data_field = field_names{1};
                chunk_data = loaded_data.(data_field);

                % Save chunk data to a frame variable
                assignin('base', frame_var_name, chunk_data);

                % Append chunk data to frames
                frames = cat(1, frames, chunk_data);
            else
                warning('Chunk file %s not found. Skipping.', chunk_file);
            end
        end

        % Assign concatenated frames to the video variable
        assignin('base', video_var_name, frames);
        fprintf('Video_%d loaded and concatenated into variable %s.\n', video_num, video_var_name);

        % Delete frame variables if the option is enabled
        if deleteFramesAfterVideoIsMade
            for chunk_num = 0:9
                frame_var_name = sprintf('Frame_%d_%d', video_num, chunk_num);
                if evalin('base', sprintf('exist(''%s'', ''var'')', frame_var_name))
                    evalin('base', sprintf('clear %s', frame_var_name));
                    fprintf('Deleted %s after concatenating Video_%d.\n', frame_var_name, video_num);
                end
            end
        end
    end
end