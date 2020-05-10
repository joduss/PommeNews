from typing import List
import tensorflow as tf

from tensorflow.python.keras.losses import BinaryCrossentropy


class WeightedBinaryCrossEntropy(BinaryCrossentropy):

    def __init__(self, weights: List[float], from_logits: bool):
        super().__init__(from_logits=from_logits)
        self.weights = weights

    def call(self, y_true, y_pred):

        nb_pred = tf.shape(y_true)[0]

        epsilon = 0


        weight_tensor = tf.convert_to_tensor([self.weights])
        weight_tensor = 1 / weight_tensor

        penalization_matrix = tf.tile(weight_tensor, tf.convert_to_tensor([nb_pred,1]) )
        #penalization_matrix = tf.tile(weight_tensor, tf.constant([nb_pred,1]) )
        penalization_matrix = penalization_matrix * -(y_true - 1) + y_true

        inline_loss = - (1 - y_true) * self.log2(1 - y_pred + epsilon) - y_true * self.log2(y_pred - epsilon)
        #inline_loss = tf.math.maximum(y_true, 0) - y_true * y_pred + tf.math.log(1 + tf.math.exp(-tf.math.abs(y_true)))

        weighted_loss = inline_loss * penalization_matrix

        # y_true[0:10, 1] * 2

        # dtype.


        #loss = tf.reduce_sum(weighted_loss)

        #penalization_matrix = tf.tile(weight_tensor, tf.convert_to_tensor([nb_pred,1]) )

        #weighted_loss = tf.where(tf.math.is_nan(weighted_loss), x=[0], y=weighted_loss)

        return tf.reduce_sum(weighted_loss, 1)


    def log2(self, x):
        numerator = tf.math.log(x)
        denominator = tf.math.log(tf.constant(2, dtype=numerator.dtype))
        return numerator / denominator