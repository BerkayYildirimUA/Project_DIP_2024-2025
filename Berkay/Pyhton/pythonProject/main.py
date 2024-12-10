import cv2
import numpy as np
from scipy.fftpack import fft
import matplotlib.pyplot as plt
import os

# Paths
video_path = 'Ballenwerper_sync_380fps_006.npy_output_video.mp4'
bg_subtraction_output_folder = 'bg_subtracted_frames/'
final_mask_output_folder = 'final_masks/'
combined_output_folder = 'combined_frames/'

os.makedirs(bg_subtraction_output_folder, exist_ok=True)
os.makedirs(final_mask_output_folder, exist_ok=True)
os.makedirs(combined_output_folder, exist_ok=True)

# Frame extraction parameters
frame_rate = 380  # Frames per second (adjust according to your video)

# Lists to store displacement data
time_series = []
displacements = []

# Step 1: Preprocessing - Create the Background Subtractor and Subtracted Frames
bg_subtractor = cv2.createBackgroundSubtractorMOG2(history=10, varThreshold=50, detectShadows=False)

cap = cv2.VideoCapture(video_path)
if not cap.isOpened():
    print("Error: Could not open video.")
    exit()

frame_index = 0
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Convert to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Apply CLAHE to normalize lighting
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray_equalized = clahe.apply(gray)

    # Apply background subtraction
    fg_mask = bg_subtractor.apply(gray_equalized, learningRate=0.01)

    # Save the background-subtracted mask for later use
    bg_subtracted_path = os.path.join(bg_subtraction_output_folder, f'bg_subtracted_{frame_index:04d}.png')
    cv2.imwrite(bg_subtracted_path, fg_mask)

    frame_index += 1

cap.release()
print("Background subtraction step complete. Masks saved.")

# Step 2: Post-Processing - Analyze the Preprocessed Frames
cap = cv2.VideoCapture(video_path)  # Reopen video for consistent indexing
frame_index = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Load the precomputed background-subtracted mask
    fg_mask = cv2.imread(os.path.join(bg_subtraction_output_folder, f'bg_subtracted_{frame_index:04d}.png'), cv2.IMREAD_GRAYSCALE)

    # Refine the mask with morphological operations
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    fg_mask_cleaned = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)

    # Save refined mask
    final_mask_path = os.path.join(final_mask_output_folder, f'final_mask_{frame_index:04d}.png')
    cv2.imwrite(final_mask_path, fg_mask_cleaned)

    # Calculate the centroid of the refined mask
    moments = cv2.moments(fg_mask_cleaned)
    if moments['m00'] != 0:
        cx = int(moments['m10'] / moments['m00'])
        cy = int(moments['m01'] / moments['m00'])
    else:
        cx, cy = 0, 0  # Fallback if no object detected

    # Record displacement (y-coordinate) and corresponding time
    time_series.append(frame_index / frame_rate)  # Time in seconds
    displacements.append(cy)

    # Save combined visualization for inspection
    combined = cv2.hconcat([cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY), fg_mask_cleaned])
    combined_output_path = os.path.join(combined_output_folder, f'combined_frame_{frame_index:04d}.png')
    cv2.imwrite(combined_output_path, combined)

    frame_index += 1

cap.release()

# Step 3: Analyze Frequency and Amplitude
# Perform FFT on displacement data
fft_result = fft(displacements)
frequencies = np.fft.fftfreq(len(fft_result), d=1/frame_rate)

# Filter out negative frequencies
positive_freqs = frequencies[:len(frequencies)//2]
fft_magnitude = np.abs(fft_result[:len(fft_result)//2])

# Identify dominant frequency
dominant_frequency = positive_freqs[np.argmax(fft_magnitude)]

# Calculate peak-to-peak amplitude
amplitude = max(displacements) - min(displacements)

# Step 4: Visualize Results
# Plot displacement over time
plt.figure()
plt.plot(time_series, displacements, label="Displacement (y-coordinate)")
plt.xlabel("Time (s)")
plt.ylabel("Displacement (pixels)")
plt.title("Displacement Over Time")
plt.legend()
plt.show()

# Plot FFT result
plt.figure()
plt.plot(positive_freqs, fft_magnitude, label="FFT Magnitude")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Amplitude")
plt.title("Frequency Spectrum")
plt.legend()
plt.show()

# Print results
print(f"Dominant Frequency: {dominant_frequency:.2f} Hz")
print(f"Peak-to-Peak Amplitude: {amplitude:.2f} pixels")
