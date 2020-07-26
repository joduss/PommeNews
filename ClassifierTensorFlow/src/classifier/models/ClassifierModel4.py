from typing import Dict, List

import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras.metrics import FalsePositives, TrueNegatives, FalseNegatives, Precision, TruePositives, \
    BinaryAccuracy, Recall, AUC
from tensorflow.python.keras import Model
from tensorflow.python.keras.callbacks import LambdaCallback
from tensorflow.python.keras.layers import Conv1D, Dense, Dropout, Embedding, MaxPooling1D

from classifier.Data.TrainValidationDataset import TrainValidationDataset
from classifier.models.IClassifierModel import IClassifierModel
from classifier.models.utility.ManualInterrupter import ManualInterrupter
from data_models.weights.theme_weights import ThemeWeights


class ClassifierModel4(IClassifierModel):

    embedding_size = 100

    # Will contain the model once trained.
    __model__: Model

    # Model properties
    __model_name__ = "Model-4"
    run_eagerly: bool = False


    def __init__(self):
        pass


    def train_model(self, themes_weight: ThemeWeights, dataset: TrainValidationDataset, voc_size: int, keras_callback: LambdaCallback):

        input = keras.layers.Input(shape=(dataset.article_length), name="Input")

        layer = Embedding(input_dim=voc_size, output_dim=self.embedding_size, name="Embedding")(input)
        layer = Conv1D(32, 3, name="Convolution")(layer)
        layer = MaxPooling1D(3, name="MaxPooling1D")(layer)
        layer = Dropout(0.25, name="Dropout")(layer)

        outputs: List[keras.layers.Layer] = []
        losses: Dict[str, keras.losses.Loss] = {}
        metrics: Dict[str, List[keras.metrics.Metric]] = {}
        class_weights: Dict[str, Dict[int, float]] = {}

        for i in range(0, dataset.theme_count):
            print("")

            name = f"output-{i}"

            output = Dense(1, name=name)(layer)

            outputs.append(output)
            losses[name] = keras.losses.BinaryCrossentropy(from_logits=True)
            metrics[name] = [AUC(multi_label=True), BinaryAccuracy(), TruePositives(),
                             TrueNegatives(), FalseNegatives(), FalsePositives(),
                             Recall(), Precision()]
            class_weights[name] = themes_weight.weights_of_theme(i)

        # if len(outputs) > 1:
        #     outputs = [keras.layers.concatenate(outputs)]
        # else:
        #     outputs = [outputs]

        model = keras.Model(inputs=[input], outputs=outputs)

        model.compile(optimizer=tf.keras.optimizers.Adam(clipnorm=1, clipvalue=0.5),
                      loss=losses,
                      metrics=metrics,
                      run_eagerly=False)

        model.summary()

        # Fix for https://github.com/tensorflow/tensorflow/issues/38988
        model._layers = [layer for layer in model._layers if not isinstance(layer, dict)]

        keras.utils.plot_model(model, self.get_model_name() + '.png', show_shapes=True)

        callbacks = [ManualInterrupter(), keras_callback]

        model.fit(dataset.trainData,
                  epochs=40,
                  class_weight=class_weights,
                  steps_per_epoch=dataset.train_batch_count,
                  validation_data=dataset.validationData,
                  validation_steps=dataset.validation_batch_count,
                  callbacks=callbacks)

        self.__model__ = model
        self.save_model()


    def get_model_name(self):
        return self.__model_name__

    def get_keras_model(self) -> Model:
        if self.__model__ is None:
            raise Exception("The model must first be trained!")
        return self.__model__