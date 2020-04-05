from dataclasses import dataclass
from typing import List, Dict

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics
from tensorflow_core.python.keras.callbacks import Callback, LambdaCallback

from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter


@dataclass
class ClassifierModel1Creator:

    article_length: int = -1

    voc_size: int = -1
    theme_count: int = -1
    theme_weight: Dict[int,float] = None

    trainData: tf.data.Dataset = None
    train_batch_count: int = -1

    validationData: tf.data.Dataset = None
    validation_batch_count: int = -1

    must_stop = False

    def is_valid(self):
        return (self.voc_size != -1
                and self.theme_count != -1
                and len(self.theme_weight) != None
                and self.trainData is not None
                and self.train_batch_count != -1
                and self.validationData is not None
                and self.validation_batch_count != -1)

    def create_model(self, embedding_output_dim, intermediate_dim, last_dim, epochs=3):

        model = tf.keras.Sequential(
            [
                # 1
                # keras.layers.Embedding(input_dim=voc_size, output_dim=firstLayoutOutputDim),
                # keras.layers.Dropout(0.2),
                # keras.layers.Conv1D(200,3,input_shape=(ARTICLE_MAX_WORD_COUNT,firstLayoutOutputDim), activation=tf.nn.relu),
                # keras.layers.GlobalAveragePooling1D(),
                # keras.layers.Dense(250, activation=tf.nn.relu),
                # keras.layers.Dense(theme_count, activation=tf.nn.softmax)

                # 2
                # keras.layers.Embedding(input_dim=voc_size, output_dim=firstLayoutOutputDim),
                # keras.layers.LSTM(ltsmOutputDim, dropout=0.2, recurrent_dropout=0.2, activation='tanh'),
                # keras.layers.Dense(theme_count, activation=tf.nn.softmax)

                # 3
                # keras.layers.Embedding(input_dim=self.voc_size, output_dim=embedding_output_dim),
                # keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim, return_sequences=True)),
                # # keras.layers.Dropout(0.1),
                # keras.layers.Bidirectional(keras.layers.LSTM(last_dim, dropout=0.05, recurrent_dropout=0.05)),
                # keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.softmax)

                # 4
                # keras.layers.Embedding(input_dim=self.voc_size, input_length=self.article_length, output_dim=embedding_output_dim),
                # keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim, return_sequences=True, dropout=0.2, recurrent_dropout=0.2)),
                # keras.layers.Dropout(0.2),
                # keras.layers.Bidirectional(keras.layers.LSTM(last_dim * 2, recurrent_dropout=0.2)), #was last_dim * 2
                # keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid)

                # 5
                #keras.layers.Embedding(input_dim=self.voc_size, input_length=self.article_length, output_dim=embedding_output_dim),
                # keras.layers.Conv1D(filters=64, kernel_size=5, input_shape=(self.voc_size, embedding_output_dim), activation="relu"),
                # keras.layers.MaxPool1D(4),
                #keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim, recurrent_dropout=0.1)),
                #keras.layers.Dense(last_dim, activation=tf.nn.relu),
                #keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid)

                #6
                keras.layers.Embedding(input_dim=self.voc_size, input_length=self.article_length, output_dim=embedding_output_dim),
                keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim)),
                keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid, use_bias=True,bias_initializer=tf.keras.initializers.Constant(-1.22818328))
                keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid, use_bias=True)

                # 7
                # keras.layers.Embedding(input_dim=self.voc_size, input_length=self.article_length,
                #                        output_dim=embedding_output_dim),
                # keras.layers.GlobalAvgPool1D(),
                # keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid)
            ]
        )

        model.summary()

        # 1
        # model.compile(optimizer=tf.keras.optimizers.Adam(),
        #               loss=tf.keras.losses.binary_crossentropy,
        #               metrics=[tf.keras.metrics.CategoricalAccuracy()])

        # model.compile(optimizer=tf.keras.optimizers.Adam(),
        #               loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
        #               metrics=[metrics.AUC(), metrics.BinaryAccuracy()])

        model.compile(optimizer=tf.keras.optimizers.Adam(),
                      loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      metrics=[metrics.AUC(), metrics.BinaryAccuracy(), metrics.TruePositives(), metrics.TrueNegatives(), metrics.FalseNegatives() , metrics.FalsePositives(), metrics.Recall(), metrics.Precision()])

        # model.fit(self.trainData, epochs=epochs, steps_per_epoch=self.train_batch_count,
        #           validation_data=self.validationData, validation_steps=self.validation_batch_count,
        #           class_weight=self.theme_weight)

        cb_list = [ManualInterrupter()]



        model.fit(self.trainData, epochs=epochs, steps_per_epoch=self.train_batch_count,
                  validation_data=self.validationData, validation_steps=self.validation_batch_count,
                  callbacks=cb_list, class_weight=self.theme_weight)


        return model


    def stop(self, model):
        model.stop_training = True



