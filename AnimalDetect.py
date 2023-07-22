import cv2
import numpy as np
import math
import socket
import struct

font = cv2.FONT_HERSHEY_PLAIN
dictionary = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)

# camera setup
cap = cv2.VideoCapture(2)
cap.set(cv2.CAP_PROP_FOCUS, 20)
cap.set(cv2.CAP_PROP_ZOOM, 0)
cap2 = cv2.VideoCapture(0)
cap2.set(cv2.CAP_PROP_FOCUS, 20)
cap2.set(cv2.CAP_PROP_ZOOM, 0)
print("Cameras connected")

# server socket setup with MATLAB
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 9999))
s.setblocking(False)
print("Connected to local host")

# primary loop that keeps running until MATLAB tells it to stop
trialStatus = 0
while int(trialStatus) != -1:
    # wait for MATLAB to send a value, indicating the start of a trial
    try:
        trialStatus = s.recv(1024)[2:].decode("utf-8")
        if not trialStatus:
            # if you see this, then matlab stopped communicating with python
            print("No trial data received")
        else:
            # if you see this, then matlab sent a value to begin the trial
            print("Trial was started")

            # reset distract variable to 1 (distracted) between trials
            distraction = 1

            # wait until the trial is over
            responseStatus = 0
            while int(responseStatus) != 2:
                try:
                    responseStatus = s.recv(1024)[2:].decode("utf-8")
                    if not responseStatus:
                        # if you see this, then matlab stopped communicating with python
                        print("No response data received")
                    else:
                        # if you see this, then matlab sent a value to end the trial
                        print("Trial was ended")
                        
                        # send distraction status back to MATLAB
                        data_str = str(distraction)
                        data_encoded = data_str.encode("utf-8")
                        s.send(struct.pack('!h', len(data_encoded)))
                        s.send(data_encoded)
                        if distraction == 0:
                            print("Animal was not distracted")
                        else:
                            print("Animal was distracted")
                        break

                except socket.error as e:
                    if e.errno == socket.errno.EWOULDBLOCK:
                        print("Response socket is waiting...")
                    else:
                        print("Response socket error:", e)

                # ---------------------------------------------------------------
                # as long as MATLAB does not end the trial, check for distraction
                # ---------------------------------------------------------------
                
                # Read frame from the cameraS
                success,frame=cap.read()
                if not success:
                    break
                success2,frame2=cap2.read()
                if not success2:
                    break
                
                # Draw ROI outline for the right half of the screen for camera 1
                roi_start = ((frame.shape[1] // 2 - 50), 0)
                roi_end = (frame.shape[1], frame.shape[0])
                cv2.rectangle(frame, roi_start, roi_end, (255, 0, 0), 3)

                # Draw ROI outline for the left half of the screen for camera 2
                roi_start2 = (0, 0)
                roi_end2 = ((frame.shape[1] // 2) + 50, frame2.shape[0])
                cv2.rectangle(frame2, roi_start2, roi_end2, (255, 0, 0), 3)

                # Detect ArUco markers in the frames of both cameras
                corners, marker_ids, rejected = cv2.aruco.detectMarkers(frame, dictionary)
                corners2, marker_ids2, rejected2 = cv2.aruco.detectMarkers(frame2, dictionary)

                # if the marker from camera 1 was found
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
                            # Change the border color of the marker to green (animal was not distracted)
                            color = (0, 255, 0)
                            distraction = 0
                        else:
                            # Keep border color of the marker at yellow (animal was distracted)
                            color = (0, 255, 255)

                        # Draw marker outline and label corners
                        cv2.polylines(frame, [corner], True, color, 3, cv2.LINE_AA)
                        cv2.putText(frame, "FL", tuple(top_right), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame, "FR", tuple(top_left), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame, "BR", tuple(bottom_right), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame, "BL", tuple(bottom_left), font, 1.3, (255, 0, 255), 2)
                
                # if the marker from camera 2 was found
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
                            # Change the border color of the marker to green (animal was not distracted)
                            color2 = (0, 255, 0)
                            distraction = 0
                        else:
                            # Keep border color of the marker at yellow (animal was distracted)
                            color2 = (0, 255, 255)

                        # Draw marker outline and label corners
                        cv2.polylines(frame2, [corner2], True, color2, 3, cv2.LINE_AA)
                        cv2.putText(frame2, "FL", tuple(top_right2), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame2, "FR", tuple(top_left2), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame2, "BR", tuple(bottom_right2), font, 1.3, (255, 0, 255), 2)
                        cv2.putText(frame2, "BL", tuple(bottom_left2), font, 1.3, (255, 0, 255), 2)

                # show both camera frames with ArUco tracking
                cv2.imshow("Camera 1",frame)
                cv2.imshow("Camera 2",frame2)

                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

    except socket.error as e:
        if e.errno == socket.errno.EWOULDBLOCK:
            print("Trial socket is waiting...")
        else:
            print("Trial socket error:", e)

    # Read frame from the cameraS
    success,frame=cap.read()
    if not success:
        break
    success2,frame2=cap2.read()
    if not success2:
        break
    
    # Draw ROI outline for the right half of the screen for camera 1
    roi_start = ((frame.shape[1] // 2 - 50), 0)
    roi_end = (frame.shape[1], frame.shape[0])
    cv2.rectangle(frame, roi_start, roi_end, (255, 0, 0), 3)

    # Draw ROI outline for the left half of the screen for camera 2
    roi_start2 = (0, 0)
    roi_end2 = ((frame.shape[1] // 2) + 50, frame2.shape[0])
    cv2.rectangle(frame2, roi_start2, roi_end2, (255, 0, 0), 3)

    # Detect ArUco markers in the frames of both cameras
    corners, marker_ids, rejected = cv2.aruco.detectMarkers(frame, dictionary)
    corners2, marker_ids2, rejected2 = cv2.aruco.detectMarkers(frame2, dictionary)

    # if the marker from camera 1 was found
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
                # Change the border color of the marker to green (animal was not distracted)
                color = (0, 255, 0)
            else:
                # Keep border color of the marker at yellow (animal was distracted)
                color = (0, 255, 255)

            # Draw marker outline and label corners
            cv2.polylines(frame, [corner], True, color, 3, cv2.LINE_AA)
            cv2.putText(frame, "FL", tuple(top_right), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "FR", tuple(top_left), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "BR", tuple(bottom_right), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame, "BL", tuple(bottom_left), font, 1.3, (255, 0, 255), 2)
    
    # if the marker from camera 2 was found
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
                # Change the border color of the marker to green (animal was not distracted)
                color2 = (0, 255, 0)
            else:
                # Keep border color of the marker at yellow (animal was distracted)
                color2 = (0, 255, 255)

            # Draw marker outline and label corners
            cv2.polylines(frame2, [corner2], True, color2, 3, cv2.LINE_AA)
            cv2.putText(frame2, "FL", tuple(top_right2), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame2, "FR", tuple(top_left2), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame2, "BR", tuple(bottom_right2), font, 1.3, (255, 0, 255), 2)
            cv2.putText(frame2, "BL", tuple(bottom_left2), font, 1.3, (255, 0, 255), 2)

    # show both camera frames with ArUco tracking
    cv2.imshow("Camera 1",frame)
    cv2.imshow("Camera 2",frame2)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# close all open streams
cap.release()
cap2.release()
cv2.destroyAllWindows()
s.close()