import cv2
import numpy as np
import math
import sys
import os
import socket

# Define the font for drawing text on the image
font = cv2.FONT_HERSHEY_PLAIN

# Create the dictionary for ArUco marker types
dictionary = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)

# Open the camera and check if it opened correctly
cap = cv2.VideoCapture(0)

# Set camera resolution to Ultra HD (3840x2160)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

# Check if the camera resolution was set successfully
if cap.get(cv2.CAP_PROP_FRAME_WIDTH) != 1280 or cap.get(cv2.CAP_PROP_FRAME_HEIGHT) != 720:
    print("Warning: Failed to set camera resolution to Ultra HD")

# Check if the camera is opened correctly
if not cap.isOpened():
    raise IOError("Cannot open webcam")

# Function to change camera focus value
def set_focus_value(value):
    cap.set(cv2.CAP_PROP_FOCUS, value)

# Create a socket object
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Set host to local machine (these values are default... only change port when necessary)
host = '127.0.0.1'
port = 9999

# Bind to the port
serversocket.bind((host, port))
print('Waiting for connection to MATLAB... You may now start the MATLAB script')

# Queue up to 5 requests
serversocket.listen(5)

# Establish a connection to the MATLAB script
clientsocket, addr = serversocket.accept()

while True:
    # Read frame from the camera
    ret, frame = cap.read()
    if not ret:
        break

    # Receive the data from MATLAB (0 = do nothing, 1 = begin detection analysis)
    dataReceived = clientsocket.recv(1024)

    # Print the received data
    #print("Data received from MATLAB: ", dataReceived)

    if dataReceived == 1:
        # Detect ArUco markers in the frame
        corners, marker_ids, rejected = cv2.aruco.detectMarkers(frame, dictionary)

        if corners:
            for corner, marker_id in zip(corners, marker_ids):
                corner = corner.reshape(4, 2)
                corner = corner.astype(int)
                
                top_right, top_left, bottom_right, bottom_left = corner

                # Calculate radian yaw angle of the pose
                delta_pos = top_left - top_right
                yaw = math.degrees(np.arctan2(delta_pos[1], delta_pos[0]))

                # Calculate centroid of the marker
                centroid = np.mean(corner, axis=0).astype(int)
                centroid_x = centroid[0]

                # Determine color based on marker orientation and centroid position
                color = (0, 255, 0)
                if 45 < yaw < 135 and centroid_x > frame.shape[1] // 2:
                    # Change the border color of the marker to green (animal was paying attention)
                    color = (0, 255, 0)
                    
                    # Send distraction data to client
                    msg = "0" # Not distracted
                    clientsocket.send(msg.encode('ascii'))
                else:
                    # Keep border color of the marker at yellow (animal was not paying attention)
                    color = (0, 255, 255)

                    # Send distraction data to client
                    msg = "1" # Distracted
                    clientsocket.send(msg.encode('ascii'))

                # Draw marker outline and label corners
                cv2.polylines(frame, [corner], True, color, 3, cv2.LINE_AA)
                cv2.putText(frame, "FL", tuple(top_right), font, 1.3, (255, 0, 255), 2)
                cv2.putText(frame, "FR", tuple(top_left), font, 1.3, (255, 0, 255), 2)
                cv2.putText(frame, "BR", tuple(bottom_right), font, 1.3, (255, 0, 255), 2)
                cv2.putText(frame, "BL", tuple(bottom_left), font, 1.3, (255, 0, 255), 2)

                # Print yaw value in the center of the marker
                yaw_text = f"{int(yaw)} deg"
                cv2.putText(frame, yaw_text, tuple(centroid), font, 1.3, (0, 0, 255), 2)

    # Draw ROI outline for the right half of the screen
    roi_start = (frame.shape[1] // 2, 0)
    roi_end = (frame.shape[1], frame.shape[0])
    cv2.rectangle(frame, roi_start, roi_end, (255, 0, 0), 3)

    # Display the resulting frame
    cv2.imshow("frame", frame)

    # Check for keyboard input
    key = cv2.waitKey(1)
    if key == ord('q'):
        break
    elif key == ord('f'):
        # Prompt user to enter focus value
        focus_value = int(input("Enter focus value: "))
        set_focus_value(focus_value)

# Release the VideoCapture object
cap.release()

# Close all OpenCV windows
cv2.destroyAllWindows()

# Close the client socket
clientsocket.close()