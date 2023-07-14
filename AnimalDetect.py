import cv2
import numpy as np
import math
import socket
import struct
import time

font = cv2.FONT_HERSHEY_PLAIN
dictionary = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)
cap = cv2.VideoCapture(2)
cap2 = cv2.VideoCapture(0)

if not cap.isOpened():
    raise IOError("Cannot open webcam 1")
if not cap2.isOpened():
    raise IOError("Cannot open webcam 2")

cap.set(cv2.CAP_PROP_FOCUS, 20)
cap.set(cv2.CAP_PROP_ZOOM, 0)
cap2.set(cv2.CAP_PROP_FOCUS, 20)
cap2.set(cv2.CAP_PROP_ZOOM, 0)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 9998))

while True:
    data_received = s.recv(1024)[2:].decode("utf-8")
    print("Data Received: ", data_received)

    if int(data_received) == 1:
        distraction = 1
        start_time = time.time()
        
        while time.time()-start_time <= 6:
            # Read frame from the camera 1
            ret, frame = cap.read()
            if not ret:
                break

            # Read frame from the camera 2
            ret2, frame2 = cap2.read()
            if not ret2:
                break
            
            # Draw ROI outline for the right half of the screen for camera 1
            roi_start = ((frame.shape[1] // 2) - 30, 0)
            roi_end = (frame.shape[1] - 100, frame.shape[0])
            cv2.rectangle(frame, roi_start, roi_end, (255, 0, 0), 3)

            # Draw ROI outline for the left half of the screen for camera 2
            roi_start2 = (100, 0)
            roi_end2 = ((frame.shape[1] // 2) + 20, frame2.shape[0])
            cv2.rectangle(frame2, roi_start2, roi_end2, (255, 0, 0), 3)

            # Detect ArUco markers in the frame of camera 1
            corners, marker_ids, rejected = cv2.aruco.detectMarkers(frame, dictionary)

            # Detect ArUco markers in the frame of camera 2
            corners2, marker_ids2, rejected2 = cv2.aruco.detectMarkers(frame2, dictionary)

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

                    # Print yaw value in the center of the marker
                    yaw_text = f"{int(yaw)} deg"
                    cv2.putText(frame, yaw_text, tuple(centroid), font, 1.3, (0, 0, 255), 2)

                    # Determine color based on marker orientation and centroid position
                    color = (0, 255, 0)
                    if 5 < yaw < 175 and centroid_x > ((frame.shape[1] // 2) - 50):
                        # Change the border color of the marker to green (animal was paying attention)
                        color = (0, 255, 0)
                        distraction = 0
                    else:
                        # Keep border color of the marker at yellow (animal was not paying attention)
                        color = (0, 255, 255)

                    # Draw marker outline and label corners
                    cv2.polylines(frame, [corner], True, color, 3, cv2.LINE_AA)
                    cv2.putText(frame, "FL", tuple(top_right), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame, "FR", tuple(top_left), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame, "BR", tuple(bottom_right), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame, "BL", tuple(bottom_left), font, 1.3, (255, 0, 255), 2)
            
            if corners2:
                for corner2, marker_id2 in zip(corners2, marker_ids2):
                    corner2 = corner2.reshape(4, 2)
                    corner2 = corner2.astype(int)
                    
                    top_right2, top_left2, bottom_right2, bottom_left2 = corner2

                    # Calculate radian yaw angle of the pose
                    delta_pos2 = top_left2 - top_right2
                    yaw2 = math.degrees(np.arctan2(delta_pos2[1], delta_pos2[0]))

                    # Calculate centroid of the marker
                    centroid2 = np.mean(corner2, axis=0).astype(int)
                    centroid_x2 = centroid2[0]

                    # Print yaw value in the center of the marker
                    yaw_text2 = f"{int(yaw2)} deg"
                    cv2.putText(frame2, yaw_text2, tuple(centroid2), font, 1.3, (0, 0, 255), 2)

                    # Determine color based on marker orientation and centroid position
                    color2 = (0, 255, 0)
                    if -175 < yaw2 < -5 and centroid_x2 < ((frame2.shape[1] // 2) + 50):
                        # Change the border color of the marker to green (animal was paying attention)
                        color2 = (0, 255, 0)
                        distraction = 0
                    else:
                        # Keep border color of the marker at yellow (animal was not paying attention)
                        color2 = (0, 255, 255)

                    # Draw marker outline and label corners
                    cv2.polylines(frame2, [corner2], True, color2, 3, cv2.LINE_AA)
                    cv2.putText(frame2, "FL", tuple(top_right2), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame2, "FR", tuple(top_left2), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame2, "BR", tuple(bottom_right2), font, 1.3, (255, 0, 255), 2)
                    cv2.putText(frame2, "BL", tuple(bottom_left2), font, 1.3, (255, 0, 255), 2)

            # Display the resulting frame from camera 1
            cv2.imshow("frame", frame)

            # Display the resulting frame from camera 2
            cv2.imshow("frame2", frame2)

            # Check for keyboard input
            key = cv2.waitKey(1)
            if key == ord('q'):
                break

        # Send MATLAB distraction variable
        data_str = str(distraction)
        data_encoded = data_str.encode("utf-8")
        s.send(struct.pack('!h', len(data_encoded)))
        s.send(data_encoded)
        print("Data Sent: ", data_encoded)

    elif int(data_received) == 42:
        break

# Release the VideoCapture object 1
cap.release()

# Release the VideoCapture object 2
cap2.release()

# Close all OpenCV windows
cv2.destroyAllWindows()

# Close the socket
s.close()