import cv2
import numpy as np

# Path to the noisy background image
input_path = "background_knn.png"

# Path to save the smoothed background
output_path = "background_knn_smoothed.png"

# Read the noisy background image
noisy_image = cv2.imread(input_path)

if noisy_image is None:
    print(f"Error: Could not load image from {input_path}")
    exit()

# Apply an averaging filter (kernel size 5x5)
kernel_size = (25, 25)
smoothed_image = cv2.blur(noisy_image, kernel_size)

# Save the smoothed image
cv2.imwrite(output_path, smoothed_image)
print(f"Smoothed background image saved to: {output_path}")
