from dataclasses import dataclass
from typing import List, Dict

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics

from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy
from classifier.prediction.models.DatasetWrapper import DatasetWrapper
from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter


@dataclass
class ClassifierModel1:

    # Variables
    themes_weight: List[int]
    dataset: DatasetWrapper
    voc_size: int

    # Configuration
    run_eagerly: bool = False
    must_stop = False
    model_name = "Model1"

    def __init__(self, themes_weight: List[int], dataset: DatasetWrapper, voc_size: int):
        self.themes_weight = themes_weight
        self.dataset = dataset
        self.voc_size = voc_size

    def is_valid(self) -> bool:
        return self.themes_weight is not None \
            and self.dataset is not None \
            and self.voc_size is not None \
            and self.voc_size > 0

    def create_model(self, embedding_output_dim, intermediate_dim, last_dim, epochs=3):

        article_length = self.dataset.article_length
        theme_count = self.dataset.theme_count

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
                keras.layers.Embedding(input_dim=self.voc_size, input_length=article_length, output_dim=embedding_output_dim, mask_zero=True),
                keras.layers.Bidirectional(keras.layers.LSTM(intermediate_dim, recurrent_dropout=0.15, dropout=0.1)),
                #keras.layers.Dropout(0.2),
                #keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid, use_bias=True,bias_initializer=tf.keras.initializers.Constant(-1.22818328))
                keras.layers.Dense(theme_count, activation=tf.nn.sigmoid)

                # 7
                # keras.layers.Embedding(input_dim=self.voc_size, input_length=self.article_length,
                #                        output_dim=embedding_output_dim),
                # keras.layers.GlobalAvgPool1D(),
                # keras.layers.Dense(last_dim, activation=tf.nn.relu),
                # keras.layers.Dense(self.theme_count, activation=tf.nn.sigmoid)
            ]
        )

        model.summary()
        model.save(self.model_name + ".h5")

        model.compile(optimizer=tf.keras.optimizers.Adam(),
                      loss=WeightedBinaryCrossEntropy(self.themes_weight, from_logits=True),
                      metrics=[metrics.AUC(), metrics.BinaryAccuracy(), metrics.TruePositives(), metrics.TrueNegatives(), metrics.FalseNegatives() , metrics.FalsePositives(), metrics.Recall(), metrics.Precision()],
                      run_eagerly=self.run_eagerly)

        keras.utils.plot_model(model, 'Model1.png', show_shapes=True)

        cb_list = [ManualInterrupter()]

        model.fit(self.dataset.trainData, epochs=epochs, steps_per_epoch=self.dataset.train_batch_count,
                  validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
                  callbacks=cb_list)

        model.save_weights(self.model_name + "_weight.h5")

        print("\nPerform evaluation---")
        model.evaluate(self.dataset.testData, steps=self.dataset.test_batch_count)

        return model


    def stop(self, model):
        model.stop_training = True



