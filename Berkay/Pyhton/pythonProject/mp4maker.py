import os
import numpy as np
import cv2

FOLDER = ''  # Folder within your PyCharm project where the .npy files are stored


def npy_to_mp4(output_folder):
    # Use the current working directory as the base
    base_path = os.getcwd()
    input_path = os.path.join(base_path, FOLDER)

    if not os.path.exists(input_path):
        print(f"Error: Folder '{FOLDER}' does not exist in the current working directory.")
        return

    npy_files = [f for f in os.listdir(input_path) if f.endswith('.npy')]

    if not npy_files:
        print(f"Error: No .npy files found in '{FOLDER}' folder.")
        return

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for npy_file in npy_files:
        npy_path = os.path.join(input_path, npy_file)
        video_name = os.path.splitext(npy_file)[0] + '.mp4'
        output_path = os.path.join(output_folder, video_name)

        try:
            data = np.load(npy_path)

            if data.ndim == 3:  # Grayscale video (frames, height, width)
                height, width = data.shape[1], data.shape[2]
                is_color = False
            elif data.ndim == 4:  # Color video (frames, height, width, channels)
                height, width = data.shape[1], data.shape[2]
                is_color = True
            else:
                print(f"Skipping {npy_file}: Unsupported data shape {data.shape}")
                continue

            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            fps = 30  # Default frame rate
            writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height), is_color)

            for frame in data:
                if not is_color:
                    frame = cv2.cvtColor(frame, cv2.COLOR_GRAY2BGR)
                writer.write(frame.astype(np.uint8))

            writer.release()
            print(f"Saved {video_name} to {output_folder}")
        except Exception as e:
            print(f"Error processing {npy_file}: {e}")


if __name__ == "__main__":
    output_folder = os.path.join(os.getcwd(), 'mp4_output')  # Create output folder in the project directory
    npy_to_mp4(output_folder)
