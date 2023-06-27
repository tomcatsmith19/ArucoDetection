import cv2

# Open the camera
cap = cv2.VideoCapture(0)

# Check if the camera is opened correctly
if not cap.isOpened():
    raise IOError("Cannot open webcam")

# Retrieve supported resolutions
supported_resolutions = []
for index in range(100):
    width = cap.get(cv2.CAP_PROP_FRAME_WIDTH + index)
    height = cap.get(cv2.CAP_PROP_FRAME_HEIGHT + index)

    if width == 0 or height == 0:
        break

    supported_resolutions.append((int(width), int(height)))

# Print the supported resolutions
print("Supported Resolutions:")
for resolution in supported_resolutions:
    print(f"{resolution[0]}x{resolution[1]}")

# Release the VideoCapture object
cap.release()