import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras.metrics import AUC, BinaryAccuracy, FalseNegatives, FalsePositives, Precision, Recall, \
    TrueNegatives, TruePositives
from tensorflow.python.keras.models import Model
from tensorflow.python.keras.callbacks import LambdaCallback
from tensorflow.python.keras.layers import Dropout
from tensorflow.python.keras.regularizers import l1, l2

from classifier.Data.TrainValidationDataset import TrainValidationDataset
from classifier.models.IClassifierModel import IClassifierModel
from classifier.models.utility.ManualInterrupter import ManualInterrupter
from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy
from data_models.weights.theme_weights import ThemeWeights


class ClassifierModel5(IClassifierModel):

    embedding_output_dim = 128
    epochs = 14

    # Will contain the model once trained.
    __model__: Model

    # Model properties
    __model_name__ = "Model-5"
    run_eagerly: bool = False

    # Other properties
    __plot_directory: str

    def __init__(self, plot_directory: str = None):
        self.__plot_directory = plot_directory


    def train_model(self, themes_weight: ThemeWeights,
                    dataset: TrainValidationDataset,
                    voc_size: int,
                    keras_callback: LambdaCallback):

        conv_reg = 0.01
        dense_reg = 0.01
        dropout = 0.2

        article_length = dataset.article_length
        theme_count = dataset.theme_count

        input = keras.layers.Input(shape=(dataset.article_length,))

        layer = keras.layers.Embedding(input_dim=voc_size, input_length=article_length, output_dim=self.embedding_output_dim,
                                       mask_zero=True)(input)
        layer = Dropout(dropout)(layer)

        conv1 = keras.layers.Conv1D(filters=128, kernel_size=2, input_shape=(voc_size, self.embedding_output_dim),
                                    activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        conv1 = keras.layers.GlobalMaxPooling1D()(conv1)
        conv1 = Dropout(dropout)(conv1)

        conv2 = keras.layers.Conv1D(filters=128, kernel_size=3, input_shape=(voc_size, self.embedding_output_dim),
                                    activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        conv2 = keras.layers.GlobalMaxPooling1D()(conv2)
        conv2 = Dropout(dropout)(conv2)

        conv3 = keras.layers.Conv1D(filters=128, kernel_size=1, input_shape=(voc_size, self.embedding_output_dim),
                                    activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        conv3 = keras.layers.GlobalMaxPooling1D()(conv3)
        conv3 = Dropout(dropout)(conv3)

        conv4 = keras.layers.Conv1D(filters=128, kernel_size=5, input_shape=(voc_size, self.embedding_output_dim),
                                    activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        conv4 = keras.layers.GlobalMaxPooling1D()(conv4)
        conv4 = Dropout(dropout)(conv4)

        layer = keras.layers.Concatenate()([conv1, conv2, conv3, conv4])
        layer = keras.layers.Dense(256, activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        layer = keras.layers.Dropout(dropout)(layer)
        layer = keras.layers.Dense(96, activation=tf.nn.relu, kernel_regularizer=keras.regularizers.l2(l=conv_reg))(layer)
        layer = keras.layers.Dropout(dropout)(layer)

        layer = keras.layers.Dense(theme_count, activation=tf.nn.sigmoid, kernel_regularizer=keras.regularizers.l2(l=dense_reg))(layer)

        model = keras.Model(inputs=input, outputs=layer)


        model.compile(optimizer=tf.keras.optimizers.Adam(clipnorm=1),
                      loss=WeightedBinaryCrossEntropy(themes_weight.weight_array()),
                      metrics=[AUC(multi_label=True), BinaryAccuracy(), TruePositives(),
                         TrueNegatives(), FalseNegatives(), FalsePositives(),
                         Recall(), Precision()],
                      run_eagerly=True)

        model.summary()
        self.__model__ = model

        if self.__plot_directory is not None:
            self.plot_model(self.__plot_directory)

        # Fix for https://github.com/tensorflow/tensorflow/issues/38988
        model._layers = [layer for layer in model._layers if not isinstance(layer, dict)]

        callbacks = [ManualInterrupter(), keras_callback]

        model.fit(dataset.trainData,
                  epochs=self.epochs,
                  steps_per_epoch=dataset.train_batch_count,
                  validation_data=dataset.validationData,
                  validation_steps=dataset.validation_batch_count,
                  callbacks=callbacks,
                  )


    def get_model_name(self):
        return self.__model_name__

    def get_keras_model(self) -> Model:
        if self.__model__ is None:
            raise Exception("The model must first be trained!")
        return self.__model__