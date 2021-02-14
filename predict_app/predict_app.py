from __future__ import division, print_function

import base64
import gc
import io
import os

import numpy as np
from PIL import Image
from flask import request, jsonify, Flask, render_template, __main__
from flask_cors import CORS

import cv2 as cv
from pathlib import Path
from PIL import Image
import random

from tensorflow.python.keras.models import load_model
import keras.backend as K
from keras.preprocessing.image import ImageDataGenerator
from keras import layers, models, optimizers, losses, Sequential
from keras.preprocessing.image import img_to_array, load_img
from keras.applications.vgg16 import VGG16
from keras.callbacks import ModelCheckpoint, LearningRateScheduler, TensorBoard, EarlyStopping
from tqdm import tqdm  # to increase iteration speed
import gc
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from tensorflow.python.client import device_lib
from sklearn import preprocessing, model_selection
from werkzeug.utils import secure_filename

#os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
# os.environ reprsesents user's environment variables as a map
# handles allocation exceeds 10%
# TF_CPP_MIN_LOG_LEVEL: 3 is available in the os.environ map
# TF_CPP_MIN_lOG is used To disable all logging output from TensorFlow
# and set the following environment variable before launching Python
# Takes for values:
#                   0 (all messages logged --> defualt behaviour)
#                   1 (INFO messages not printed)
#                   2 (INFO, WARNING messages not printed)
#                   3(INFO, WARNING ERROR MESSAGES NOT PRINTED)

app = Flask(__name__)
# initialising a Flask instance
# __name__: built in variable; evaluates the name of the current module
CORS(app)

model = []
prediction_distr = []
graphs = []

config = tf.ConfigProto()
config.gpu_options.allow_growth = True
session = tf.Session(config=config)

def get_model(i):  # a function to load the model
    if i < 7:
         # model can be accessed throughout the app
        m = load_model('extracted_path_of_h5 files_directory\h5 files\groceries_'+str(i+1)+'.h5', compile=False)
        print("model "+ str(i+1)+" loaded!")
        graph = tf.get_default_graph()
        return m, graph;


def read_class(i):  # a mapof the encoded target with its corresponding class
    with open('extracted_path_of_class_maps_directory\class_maps\class_map_'+str(i+1)+'.txt', 'r') as file:
        c = file.read()
    c = eval(c)
    return c
    # takes content from txt file (created in groceies.ipynb) and converts to dictionary

def preprocess_image(image, target_size):
    image = Image.open(image)
    if image.mode != 'RGB':  # if the image is not in rgb, convert to rgb
        image = image.convert('RGB')
    image = image.resize(target_size)
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    return image  # expands the array by inserting a new axis at the specified position
    # basically for axis = 0 changes shape from (n,n) to (1, n, n)
    # for axis = 1, shape change follows (n, n) to (n, 1 , n)

def looping_model_and_class():
    for i in range(7):
        print("Loading Keras Models...")
        gc.collect()
        m,g = get_model(i)
        model.append(m);
        graphs.append(g)
    print("Models loaded")

looping_model_and_class()
 # essential for smooth running of the model
def prediction_logic(i, image):
    m = model[i]
    g = graphs[i]
    with g.as_default():
        pred_distribution = m.predict(image)
        pred_distribution = np.argmax(pred_distribution)
    return pred_distribution

@app.route('/')
def home():
    return render_template('index.html')

# the flask app can be accessed by host/upload
# nature of the app is: post
@app.route('/predict', methods=['POST'])
# upload image to server and predict
def predict():
    f = request.files['file']
    f.save(
        os.path.join('uploads', secure_filename(f.filename)))  # save image as file in uploads directory in the server
    image = os.path.join('uploads', str(f).split(' ')[1].split('\'')[1])
    image = preprocess_image(image, (100, 100))
    for i in range(7):
        p = prediction_logic(i, image)
        prediction_distr.append(p)
    pred = np.asarray(prediction_distr)
    p = np.argmax(pred)
    i = list(pred).index(p)
    class_dictionary = read_class(i)
    print(class_dictionary[p])
    return jsonify(class_dictionary[p])