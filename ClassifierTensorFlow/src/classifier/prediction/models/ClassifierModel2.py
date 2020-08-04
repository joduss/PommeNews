from typing import List

import tensorflow as tf
import tensorflow.keras as keras
import tensorflow.keras.metrics as metrics
from tensorflow.keras import regularizers
from tensorflow.python.keras import Model
from tensorflow.python.keras.callbacks import LambdaCallback

from classifier.Data.TrainValidationDataset import TrainValidationDataset
from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy
from classifier.prediction.models.IClassifierModel import IClassifierModel
from classifier.prediction.models.utility.ManualInterrupter import ManualInterrupter
from classifier.Data.GlobalDataset import GlobalDataset
from tensorflow.keras.losses import BinaryCrossentropy

class ClassifierModel2(IClassifierModel):

    embedding_size = 128
    LTSM_output_size = 150
    dense2_output_size = 150

    # Configuration
    run_eagerly: bool = False
    must_stop = False

    __model__: Model = None
    __interrupter__: ManualInterrupter = ManualInterrupter()

    # Model properties
    __model_name__ = "Model1"

    def __init__(self):
        pass


    def train_model(self, themes_weight: List[float], dataset: TrainValidationDataset, voc_size: int, keras_callback: LambdaCallback):

        input = keras.layers.Input(shape=(dataset.article_length))

        outputs: List[keras.layers.Layer] = []
        # losses: List[keras.losses.Loss] = []

        for i in range(0, dataset.theme_count):
            print("")
            dense = keras.layers.Embedding(input_dim=voc_size, output_dim=self.embedding_size)(input)
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
            # losses.append(BinaryCrossentropy(from_logits=True))

        if len(outputs) > 1:
            outputs = [keras.layers.concatenate(outputs)]
        else:
            outputs = [outputs]

        model = keras.Model(inputs=[input], outputs=outputs)

        model.compile(optimizer=tf.keras.optimizers.Adam(clipnorm=1, clipvalue=0.5),
                      #loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      loss=WeightedBinaryCrossEntropy(weights=themes_weight, from_logits=True),
                      # loss = {"0" : tf.keras.losses.BinaryCrossentropy(from_logits=True),
                      #         "1" : tf.keras.losses.BinaryCrossentropy(from_logits=True)},
                      metrics=[metrics.AUC(multi_label=True), metrics.BinaryAccuracy(), metrics.TruePositives(),
                               metrics.TrueNegatives(), metrics.FalseNegatives(), metrics.FalsePositives(),
                               metrics.Recall(), metrics.Precision()],
                      run_eagerly=False)

        model.summary()

        keras.utils.plot_model(model, self.__model_name__ + '.png', show_shapes=True)

        should_stop = False
        callbacks = [self.__interrupter__, keras_callback]

        # model.fit(self.dataset.trainData, epochs=15, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight=self.theme_weight)

        # model.fit(self.dataset.trainData, epochs=10, steps_per_epoch=self.dataset.train_batch_count,
        #           validation_data=self.dataset.validationData, validation_steps=self.dataset.validation_batch_count,
        #           callbacks=callbacks, class_weight={ 0 : 1, 1 : 7.8, 2 : 4.3})

        model.fit(dataset.trainData, epochs=40, steps_per_epoch=dataset.train_batch_count,
                  validation_data=dataset.validationData, validation_steps=dataset.validation_batch_count,
                  callbacks=callbacks)

        self.__model__ = model


    def get_name(self):
        return "Model2"

    def get_keras_model(self) -> Model:
        if self.__model__ is None:
            raise Exception("The model must first be trained!")
        return self.__model__

    def stop(self, model):
        model.stop_training = True