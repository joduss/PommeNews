from typing import List

from tensorflow.python.keras.callbacks import LambdaCallback
from tensorflow.python.keras.models import Model

from classifier.Data.TrainValidationDataset import TrainValidationDataset
from data_models.weights.theme_weights import ThemeWeights


class IClassifierModel:

    def train_model(self, themes_weight: ThemeWeights, dataset: TrainValidationDataset, voc_size: int, keras_callback: LambdaCallback):
        """
        Creates and train the model.
        :param themes_weight:
        :param dataset:
        :param voc_size:
        :return:
        """
        raise Exception("Not implemented.")


    def get_model_name(self) -> str:
        """
        Return the name of the model.
        """
        raise Exception("Not implemented.")


    def get_keras_model(self) -> Model:
        """
        Returns the trained model.
        Throws an exception no model has been trained.
        """
        raise Exception("Not implemented.")
