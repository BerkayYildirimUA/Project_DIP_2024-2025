import cv2
import numpy as np
import os

# Directory containing the background images
input_dir = "selected_frames"
output_path = "background.png"

# Read all .png images
image_files = sorted([f for f in os.listdir(input_dir) if f.endswith(".png")])
images = []

for file_name in image_files:
    img_path = os.path.join(input_dir, file_name)
    frame = cv2.imread(img_path)
    if frame is not None:
        images.append(frame)

# Stack images into a NumPy array
image_stack = np.stack(images, axis=-1)

# Compute the temporal median
median_image = np.median(image_stack, axis=-1).astype(np.uint8)

# Save the resulting background
cv2.imwrite(output_path, median_image)
print(f"Background image saved to: {output_path}")