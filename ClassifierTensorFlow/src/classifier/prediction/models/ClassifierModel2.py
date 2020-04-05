from dataclasses import dataclass
from typing import List

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics

from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter
from classifier.prediction.models.DatasetWrapper import DatasetWrapper



class ClassifierModel2:

    themes_weight: int
    dataset: DatasetWrapper
    voc_size: int

    must_stop = False

    def __init__(self, themes_weight: List[int], dataset: DatasetWrapper, voc_size: int):
        self.theme_weight = themes_weight
        self.dataset = dataset
        self.voc_size = voc_size

    def is_valid(self) -> bool:
        return self.theme_weight is not None \
            and self.dataset is not None


    def create_model(self):

        input = keras.layers.Input(shape=(self.dataset.article_length))

        outputs: List[keras.layers.Layer] = []

        for i in range(0, self.dataset.theme_count):
            print("")
            dense = keras.layers.Embedding(input_dim=self.voc_size, output_dim=128)(input)
            ltsm = keras.layers.Bidirectional(keras.layers.LSTM(256))(dense)
            dense2 = keras.layers.Dense(units=128, activation=tf.nn.relu)(ltsm)
            output = keras.layers.Dense(units=1, activation=tf.nn.sigmoid)(dense2)
            outputs.append(output)



        model = keras.Model(inputs=[input], outputs=[keras.layers.concatenate(outputs)])

        model.compile(optimizer=tf.keras.optimizers.Adam(),
                      loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      metrics=[metrics.AUC(), metrics.BinaryAccuracy(), metrics.TruePositives(),
                               metrics.TrueNegatives(), metrics.FalseNegatives(), metrics.FalsePositives(),
                               metrics.Recall(), metrics.Precision()])

        model.summary()

        keras.utils.plot_model(model, 'my_first_model_with_shape_info.png', show_shapes=True)

        should_stop = False
        callbacks = [ManualInterrupter(should_stop)]

        # model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight=self.theme_weight)

        model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
                  validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
                  callbacks=callbacks)

        print("\nPerform evaluation---")
        # modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)        model.evaluate(self.dataset.testData, steps=self.dataset.test_batch_count)

        return model