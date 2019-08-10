from __future__ import absolute_import, division, print_function, unicode_literals
from tensorflow.python.keras.preprocessing.text import Tokenizer
from tensorflow.python.keras .layers import *

import tensorflow as tf
import numpy as np
import tensorflow.keras as keras
import math
import json

texts = ["I am groot", "I am him"]

tokenizer = Tokenizer()

tokenizer.fit_on_texts(texts=texts)

sequences = tokenizer.texts_to_sequences(texts)

for index, text in enumerate(texts):
    print(text, " => ", sequences[index])