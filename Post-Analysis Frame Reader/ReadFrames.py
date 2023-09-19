import cv2
import numpy as np
import tkinter as tk
from tkinter import filedialog
import os
from tqdm import tqdm  # Import tqdm for the progress bar

# Global variables to store ROI coordinates
roi_coords = None
roi_defined = False
drawing_roi = False  # Flag to indicate whether ROI is being drawn

# Function to define the ROI using mouse events
def define_roi(event, x, y, flags, param):
    global roi_coords, roi_defined, drawing_roi

    if event == cv2.EVENT_LBUTTONDOWN:
        roi_coords = (x, y)
        drawing_roi = True
    elif event == cv2.EVENT_MOUSEMOVE:
        if drawing_roi:
            # Draw a rectangle as the user clicks and drags
            frame_roi = first_frame.copy()
            cv2.rectangle(frame_roi, roi_coords, (x, y), (0, 255, 0), 2)
            cv2.imshow("First Frame", frame_roi)
    elif event == cv2.EVENT_LBUTTONUP:
        roi_coords += (x - roi_coords[0], y - roi_coords[1])
        roi_defined = True
        drawing_roi = False

# Function to check if the entire frame has a magenta color within the specified ROI
def frame_has_magenta_color_in_roi(frame, roi, lower_magenta, upper_magenta):
    if roi is None:
        return False

    x, y, w, h = roi

    # Crop the frame to the ROI
    roi_frame = frame[y:y + h, x:x + w]

    # Convert the cropped frame to HSV format (since OpenCV uses BGR)
    hsv_frame = cv2.cvtColor(roi_frame, cv2.COLOR_RGB2HSV)

    # Create a mask where pixels within the magenta color range are white
    color_mask = cv2.inRange(hsv_frame, lower_magenta, upper_magenta)

    # Check if any white pixel is present in the mask
    return np.any(color_mask)

# Function to highlight magenta color regions in the frame
def highlight_magenta_regions(frame, roi, lower_magenta, upper_magenta):
    if roi is None:
        return frame

    x, y, w, h = roi

    # Crop the frame to the ROI
    roi_frame = frame[y:y + h, x:x + w]

    # Convert the cropped frame to HSV format (since OpenCV uses BGR)
    hsv_frame = cv2.cvtColor(roi_frame, cv2.COLOR_RGB2HSV)

    # Create a mask where pixels within the magenta color range are white
    color_mask = cv2.inRange(hsv_frame, lower_magenta, upper_magenta)

    # Find contours in the mask
    contours, _ = cv2.findContours(color_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Draw bounding boxes or contours around the magenta regions
    for contour in contours:
        x_c, y_c, w_c, h_c = cv2.boundingRect(contour)
        x_global, y_global = x + x_c, y + y_c  # Adjust coordinates to global frame
        cv2.rectangle(frame, (x_global, y_global), (x_global + w_c, y_global + h_c), (0, 255, 0), 2)  # Draw a green rectangle

    return frame

# Function to open a file dialog and get the selected video file path
def select_video_file():
    root = tk.Tk()
    root.withdraw()  # Hide the main window
    file_path = filedialog.askopenfilename(title="Select a Video File", filetypes=[("Video files", "*.mp4 *.avi *.mkv")])
    return file_path

# Create folders to store detected and non-detected frames
output_detected_folder = "Detected Frames"
output_nondetected_folder = "Non-Detected Frames"
os.makedirs(output_detected_folder, exist_ok=True)
os.makedirs(output_nondetected_folder, exist_ok=True)

# Get the path to the selected video file
video_file_path = select_video_file()

# Check if a video file was selected
if not video_file_path:
    print("No video file selected. Exiting.")
    exit()

# Get the base name of the video file (excluding extension)
video_file_name = os.path.splitext(os.path.basename(video_file_path))[0]

# Create subfolders within the "Detected Frames" and "Non-Detected Frames" folders
output_detected_folder = os.path.join(output_detected_folder, video_file_name)
output_nondetected_folder = os.path.join(output_nondetected_folder, video_file_name)
os.makedirs(output_detected_folder, exist_ok=True)
os.makedirs(output_nondetected_folder, exist_ok=True)

# Define the lower and upper bounds for magenta color in HSV format
lower_magenta = np.array([155, 200, 100])  # Lower bound (adjust as needed)
upper_magenta = np.array([170, 255, 255])  # Upper bound (adjust as needed)

# Create a VideoCapture object and read from the selected file
cap = cv2.VideoCapture(video_file_path)

# Check if the video file opened successfully
if not cap.isOpened():
    print("Error opening video stream or file")
    exit()

# Create a window to display the first frame for defining the ROI
cv2.namedWindow("First Frame", cv2.WINDOW_NORMAL)  # Use cv2.WINDOW_NORMAL for resizable window
cv2.setMouseCallback("First Frame", define_roi)

# Get the first frame for defining the region of interest (ROI)
ret, first_frame = cap.read()
if not ret:
    print("Error reading the first frame. Exiting.")
    exit()

# Wait for the user to define the ROI by clicking and dragging
while not roi_defined:
    cv2.imshow("First Frame", first_frame)
    cv2.waitKey(1)

# Close the window for the first frame
cv2.destroyWindow("First Frame")

# Get the total number of frames in the video
total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

# Initialize a frame counter and counts for frames with the magenta color
frame_count = 0
frames_with_magenta_count = 0

# Create a tqdm progress bar for the analysis
with tqdm(total=total_frames) as pbar:
    # Read frames and count frames with the magenta color within the ROI
    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()

        # If the frame was not read successfully, break the loop
        if not ret:
            break

        # Increment the frame counter
        frame_count += 1

        # Check if the entire frame has the magenta color within the specified ROI
        if frame_has_magenta_color_in_roi(frame, roi_coords, lower_magenta, upper_magenta):
            print(f"Frame {frame_count} contains the magenta color within the ROI.")
            frames_with_magenta_count += 1

            # Highlight magenta color regions and save the frame to the detected folder
            highlighted_frame = highlight_magenta_regions(frame.copy(), roi_coords, lower_magenta, upper_magenta)
            frame_filename = os.path.join(output_detected_folder, f"frame_{frame_count}.png")
            cv2.imwrite(frame_filename, highlighted_frame)
        else:
            # Save the frame to the non-detected folder
            frame_filename = os.path.join(output_nondetected_folder, f"frame_{frame_count}.png")
            cv2.imwrite(frame_filename, frame)

        # Update the progress bar
        pbar.update(1)

# Release the video capture object
cap.release()

# Close all OpenCV windows
cv2.destroyAllWindows()

# Print the total number of frames containing the magenta color within the ROI
print(f"Total frames with the magenta color within the ROI: {frames_with_magenta_count}")

# Print the paths to the output folders
print(f"Detected frames saved in: {os.path.abspath(output_detected_folder)}")
print(f"Non-detected frames saved in: {os.path.abspath(output_nondetected_folder)}")
