from typing import List

from tensorflow.python.keras.callbacks import LambdaCallback
from tensorflow.python.keras.models import Model

from classifier.Data.TrainValidationDataset import TrainValidationDataset


class IClassifierModel:

    def train_model(self, themes_weight: List[float], dataset: TrainValidationDataset, voc_size: int, keras_callback: LambdaCallback):
        """
        Creates and train the model.
        :param themes_weight:
        :param dataset:
        :param voc_size:
        :return:
        """
        raise Exception("Not implemented.")

    def get_name(self) -> str:
        raise Exception("Not implemented.")

    def get_keras_model(self) -> Model:
        raise Exception("Not implemented.")

    def get_theme_weight(self) -> List[float]:
        raise Exception("Not implemented")
