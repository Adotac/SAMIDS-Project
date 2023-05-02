import cv2

url = 'http://192.168.43.245/240x240.mjpeg'
cap = cv2.VideoCapture(url)

while True:
    ret, frame = cap.read()
    if ret:
        cv2.imshow('frame', frame)
        if cv2.waitKey(0):
            break
    else:
        print("no frames")
        break

cap.release()
cv2.destroyAllWindows()
