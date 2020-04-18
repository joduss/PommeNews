from dataclasses import dataclass
from typing import List, Dict
import numpy as np

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics

from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy
from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter
from classifier.prediction.models.DatasetWrapper import DatasetWrapper

class ClassifierModel3:

    themes_weight: Dict[int,float]
    voc_size: int

    X: np.ndarray
    Y: np.ndarray

    theme_count: int

    must_stop = False

    def __init__(self, themes_weight: Dict[int,float], X: np.ndarray, Y: np.ndarray, voc_size: int):
        self.theme_weight = themes_weight
        self.X = X
        self.Y = Y
        self.voc_size = voc_size
        self.themes_count = Y[0].size
        self.article_size = X[0].size


    def create_model(self):

        input = keras.layers.Input(shape=(self.X[0].size))

        outputs: List[keras.layers.Layer] = []

        for i in range(0, self.dataset.theme_count):
            print("")
            dense = keras.layers.Embedding(input_dim=self.voc_size, output_dim=128)(input)
            ltsm = keras.layers.Bidirectional(keras.layers.LSTM(256))(dense)
            dense2 = keras.layers.Dense(units=256, activation=tf.nn.relu)(ltsm)
            output = keras.layers.Dense(units=1, activation=tf.nn.sigmoid, name=str(i))(dense2)
            outputs.append(output)


        # if len(outputs) > 1:
        outputs = [keras.layers.concatenate(outputs)]
        # else:
        #     outputs = [outputs]

        model = keras.Model(inputs=[input], outputs=outputs)

        model.compile(optimizer=tf.keras.optimizers.Adam(),
                      #loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      loss=WeightedBinaryCrossEntropy(weights=[], from_logits=True),
                      # loss = {"0" : tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      #         "1" : tf.keras.losses.BinaryCrossentropy(from_logits=True)},
                      metrics=[metrics.AUC(), metrics.BinaryAccuracy(), metrics.TruePositives(),
                               metrics.TrueNegatives(), metrics.FalseNegatives(), metrics.FalsePositives(),
                               metrics.Recall(), metrics.Precision()])

        model.summary()

        keras.utils.plot_model(model, 'my_first_model_with_shape_info.png', show_shapes=True)

        should_stop = False
        callbacks = [ManualInterrupter(should_stop)]

        # model.fit(self.dataset.trainData, epochs=15, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight=self.theme_weight)

        model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
                  validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
                  callbacks=callbacks, class_weight={ 0 : 1, 1 : 7.8, 2 : 4.3})

        # model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks)

        print("\nPerform evaluation---")
        model.evaluate(self.dataset.testData, steps=self.dataset.test_batch_count)

        return model