import cv2
import keyboard
import os

# Input video file
video_path = "Video_1.mp4"

# Output directory for saved frames
output_dir = "selected_frames"
os.makedirs(output_dir, exist_ok=True)

# Open the video
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print("Error: Cannot open video.")
    exit()

frame_count = 0  # Frame counter
saved_count = 0  # Counter for saved frames

print("Instructions:")
print("Press 'Enter' to save the frame.")
print("Press 'Delete' to skip the frame.")
print("Press 'Esc' to quit.")

while True:
    ret, frame = cap.read()
    if not ret:
        print("End of video.")
        break

    # Display the current frame
    cv2.imshow("Frame Viewer", frame)
    frame_count += 1

    # Wait for key press
    key = cv2.waitKey(0)  # 0 = Wait indefinitely for a key press

    if keyboard.is_pressed("enter"):  # Save frame
        frame_path = os.path.join(output_dir, f"frame_{frame_count:04d}.png")
        cv2.imwrite(frame_path, frame)
        saved_count += 1
        print(f"Saved: {frame_path}")
    elif keyboard.is_pressed("delete"):  # Skip frame
        print(f"Skipped frame {frame_count}.")
    elif keyboard.is_pressed("esc"):  # Quit
        print("Quitting...")
        break

# Release the video capture and close the display window
cap.release()
cv2.destroyAllWindows()

print(f"Total frames processed: {frame_count}")
print(f"Total frames saved: {saved_count}")
