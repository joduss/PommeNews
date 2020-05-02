from typing import List, Dict

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics
from tensorflow.keras import regularizers

from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy
from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter
from classifier.prediction.models.DatasetWrapper import DatasetWrapper

class ClassifierModel2:

    themes_weight: List[int]
    dataset: DatasetWrapper
    voc_size: int

    embedding_size = 128
    LTSM_output_size = 150
    dense2_output_size = 150

    must_stop = False

    def __init__(self, themes_weight: List[int], dataset: DatasetWrapper, voc_size: int):
        self.themes_weight = themes_weight
        self.dataset = dataset
        self.voc_size = voc_size

    def is_valid(self) -> bool:
        return self.themes_weight is not None \
            and self.dataset is not None \
            and self.voc_size is not None \
            and self.voc_size > 0


    def create_model(self):

        input = keras.layers.Input(shape=(self.dataset.article_length))

        outputs: List[keras.layers.Layer] = []

        for i in range(0, self.dataset.theme_count):
            print("")
            dense = keras.layers.Embedding(input_dim=self.voc_size, output_dim=self.embedding_size)(input)
            ltsm = keras.layers.Bidirectional(keras.layers.LSTM(self.LTSM_output_size, recurrent_dropout=0.2, dropout=0.2))(dense)
            dropout = keras.layers.Dropout(0.2)(ltsm)
            dense2 = keras.layers.Dense(units=self.dense2_output_size, activation=tf.nn.relu)(dropout)
            output = keras.layers.Dense(units=1,
                                        activation=tf.nn.sigmoid,
                                        name=str(i),
                                        kernel_regularizer=regularizers.l2(0.01),
                                        activity_regularizer=regularizers.l1(0.01)
                                        )(dense2)
            outputs.append(output)


        if len(outputs) > 1:
            outputs = [keras.layers.concatenate(outputs)]
        else:
            outputs = [outputs]

        model = keras.Model(inputs=[input], outputs=outputs)

        model.compile(optimizer=tf.keras.optimizers.Adam(clipnorm=1, clipvalue=0.5),
                      #loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      loss=WeightedBinaryCrossEntropy(weights=self.themes_weight, from_logits=True),
                      # loss = {"0" : tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      #         "1" : tf.keras.losses.BinaryCrossentropy(from_logits=True)},
                      metrics=[metrics.AUC(multi_label=True), metrics.BinaryAccuracy(), metrics.TruePositives(),
                               metrics.TrueNegatives(), metrics.FalseNegatives(), metrics.FalsePositives(),
                               metrics.Recall(), metrics.Precision()],
                      run_eagerly=False)

        model.summary()

        keras.utils.plot_model(model, 'model2.png', show_shapes=True)

        should_stop = False
        callbacks = [ManualInterrupter(should_stop)]

        # model.fit(self.dataset.trainData, epochs=15, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight=self.theme_weight)

        # model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight={ 0 : 1, 1 : 7.8, 2 : 4.3})

        model.fit(self.dataset.trainData, epochs=40, steps_per_epoch=self.dataset.train_batch_count,
                  validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
                  callbacks=callbacks)

        print("\nPerform evaluation---")
        model.evaluate(self.dataset.testData, steps=self.dataset.test_batch_count)

        return model