import cv2
import numpy as np

def adjust_perspective_warp():
    cap = cv2.VideoCapture(0)  # 0 corresponds to the default webcam

    while True:
        # Capture a frame from the webcam
        ret, frame = cap.read()

        # Display the original frame
        cv2.imshow('Original Frame', frame)

        # Define the source and destination points for perspective transformation
        height, width = frame.shape[:2]
        src_points = np.float32([[0, 0], [width, 0], [width, height], [0, height]])
        #                         top left     top right           bottom left          bottom right
        dst_points = np.float32([[0, 0], [width, 0], [width, height], [100, height + 100]])

        # Compute the perspective transformation matrix
        perspective_matrix = cv2.getPerspectiveTransform(src_points, dst_points)

        # Apply the perspective transformation to the frame
        warped_frame = cv2.warpPerspective(frame, perspective_matrix, (width, height))

        # Display the warped frame
        cv2.imshow('Warped Frame', warped_frame)

        # Exit loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release the webcam and close windows
    cap.release()
    cv2.destroyAllWindows()

# Call the function to start adjusting the perspective warp
adjust_perspective_warp()
