import cv2
import numpy as np

# define the fonts for draw text on image
font = cv2.FONT_HERSHEY_PLAIN

# create the dictionary for markers type
dictionary = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)

# Open the camera.
cap = cv2.VideoCapture(0)

# Check if the camera is opened correctly
if not cap.isOpened():
    raise IOError("Cannot open webcam")

while True:
    # Read frame from the camera.
    ret, frame = cap.read()

    if not ret:
        break

    # Detect ArUco markers in the frame.
    corners, marker_ids, rejected = cv2.aruco.detectMarkers(frame, dictionary)

    # If markers are detected, draw them on the frame.
    if corners:
        for corner, marker_id in zip(corners, marker_ids):
            corner = corner.reshape(4, 2)
            corner = corner.astype(int)

            top_right, top_left, bottom_right, bottom_left = corner

            # Check if the marker is oriented with the top facing the right side of the screen
            # and the bottom facing the left side of the screen
            if top_left[0] < top_right[0] and bottom_left[0] < bottom_right[0]:
                # If yes, use green color for the marker
                color = (0, 255, 0)
            else:
                # If no, use yellow color for the marker
                color = (0, 255, 255)

            cv2.polylines(
                frame, [corner], True, color, 3, cv2.LINE_AA
            )

            # Label each corner.
            cv2.putText(frame, "TR", tuple(top_right), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "TL", tuple(top_left), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "BR", tuple(bottom_right), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "BL", tuple(bottom_left), font, 1.3, (255, 0, 255), 2)

            cv2.putText(
                frame, f"id: {marker_id[0]}", top_right, font, 1.3, (255, 0, 255), 2
            )

    # Display the resulting frame.
    cv2.imshow("frame", frame)

    # Break the loop on 'q' key press.
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the VideoCapture object.
cap.release()

# Close all OpenCV windows.
cv2.destroyAllWindows()
