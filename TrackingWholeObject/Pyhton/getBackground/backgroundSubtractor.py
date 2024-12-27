import cv2

# Input video file
video_path = "Video_1.mp4"
output_path = "background_knn.png"

# Initialize the KNN background subtractor
knn = cv2.createBackgroundSubtractorKNN()

# Open the video
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print("Error: Cannot open video.")
    exit()

frame_count = 0
print("Processing video for background extraction using KNN...")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Apply the KNN model to update the background
    knn.apply(frame)

    frame_count += 1
    if frame_count % 100 == 0:
        print(f"Processed {frame_count} frames...")

print("Video processing complete.")

# Retrieve the computed background image
background = knn.getBackgroundImage()

if background is not None:
    # Save the resulting background
    cv2.imwrite(output_path, background)
    print(f"Background image saved to: {output_path}")
else:
    print("No background image was generated. Check your video input or settings.")

# Release resources
cap.release()
