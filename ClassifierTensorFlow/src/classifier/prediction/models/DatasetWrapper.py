import math

import tensorflow as tf

class DatasetWrapper:

    def __init__(self, tf_dataset: tf.data.Dataset, train_ratio: float, validation_ratio: float, batch_size: int = 300):

        self.article_length = len(list(tf_dataset.as_numpy_iterator())[0][0])
        self.theme_count = len(list(tf_dataset.as_numpy_iterator())[0][1])
        self.count = len(list(tf_dataset.as_numpy_iterator()))

        self.dataset = tf_dataset.batch(batch_size).repeat().shuffle(batch_size)


        self.trainSize = int(train_ratio * self.count)
        self.validationSize = int(validation_ratio * self.count)
        self.testSize = self.count - self.trainSize - self.validationSize

        self.trainData = self.dataset.take(self.trainSize).repeat()
        self.validationData = self.dataset.skip(self.trainSize).take(self.validationSize).repeat()
        self.testData = self.dataset.skip(self.testSize)

        self.train_batch_count = int(math.ceil(self.trainSize / batch_size))
        self.test_batch_count = int(math.ceil(self.testSize / batch_size))
        self.validation_batch_count = int(math.ceil(self.validationSize / batch_size))


