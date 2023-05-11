import cv2
from ImagePredictor import ImagePredictor

ip = '192.168.43.245'
# Define the path to the trained SVM model

# svm_path = './j-notebooks/svm-rbf_classifier-95-rand-200.pkl'
# svm_path = './j-notebooks/svm-rbf_classifier-90-all-200.pkl'
# svm_path = './j-notebooks/sgd_classifier-92-rand-200.pkl'
# svm_path = './j-notebooks/svm-rbf_classifier-90r-over.pkl'
# svm_path = './j-notebooks/svm-rbf_classifier.pkl'
svm_path = './j-notebooks/sgd_classifier_new0.pkl'

# svm_path = './models/sgd_classifier-92-rand.pkl'
# svm_path = './models/svm_classifier-400-rand.pkl'
# svm_path = './models/svm_classifier - 93.pkl'

predictor = ImagePredictor(svm_path=svm_path)

predictor.predict_display(ip=ip)
