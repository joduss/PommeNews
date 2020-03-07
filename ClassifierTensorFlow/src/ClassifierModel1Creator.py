from dataclasses import dataclass
from typing import List

import tensorflow as tf
import tensorflow.keras as keras

@dataclass
class ClassifierModel1Creator:

    voc_size: int = -1
    theme_count: int = -1
    theme_weight: List[int] = -1

    trainData: tf.data.Dataset = None
    train_batch_count: int = -1

    validationData: tf.data.Dataset = None
    validation_batch_count: int = -1

    def is_valid(self):
        return (self.voc_size != -1
                and self.theme_count != -1
                and len(self.theme_weight) != 0
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
                keras.layers.Embedding(input_dim=self.voc_size, output_dim=embedding_output_dim),
                keras.layers.Conv1D(1, 2, input_shape=(self.voc_size, embedding_output_dim)),
                keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim, return_sequences=True)),
                keras.layers.Dropout(0.07),
                keras.layers.Bidirectional(keras.layers.LSTM(last_dim)),
                keras.layers.Dense(last_dim, activation=tf.nn.relu),
                keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid)
            ]
        )

        model.summary()

        # 1
        model.compile(optimizer=tf.keras.optimizers.Adam(),
                      loss=tf.keras.losses.binary_crossentropy,
                      metrics=[tf.keras.metrics.CategoricalAccuracy()])

        model.fit(self.trainData, epochs=epochs, steps_per_epoch=self.train_batch_count,
                  validation_data=self.validationData, validation_steps=self.validation_batch_count,
                  class_weight=self.theme_weight)

        return model
