import tensorflow as tf
import tensorflow.keras as keras

# rule: out 1: si in1 >= 10 => 1
# rule out2: si in2 >= 20 => 1
from classifier.prediction.losses.weightedBinaryCrossEntropy import WeightedBinaryCrossEntropy

data_in = [[0, 6], [11, 6], [1, 1], [9, 0], [50, 20], [20, 22], [0, 19], [5, 17], [10, 9], [18, 3],
           [11, 19], [11, 21], [9,19], [9,21], [15,15], [18,22], [22,18], [3,3], [8,18], [0, 0]]
data_out = [[0, 0], [1, 0], [0, 0], [0, 0], [1, 1], [1, 1], [0, 0], [0, 0], [1, 0], [1, 0],
            [1, 0], [1,1], [0,0], [0,1], [1,0], [1,1], [1,0], [0,0], [0,0], [0,0]]

# data = [[0, 6],[11, 6],[1,1],[9,0],[50,20],[20,22],[0,19],[5,17],[10,9],[18, 3]]
# out = [[0, 0], [1,0], [0,0], [0,0], [1,1], [1,1], [0,0], [0,0], [1,0], [1,0]]

in_tf = tf.constant(data_in)
out_tf = tf.constant(data_out)
out_tf = tf.reshape(out_tf, [20,2,1])

# class 1: 10 / 20
# class 2: 5 / 20

# model = keras.models.Sequential([
#     keras.layers.Dense(2, activation=keras.activations.relu),
#     keras.layers.Dense(2, activation=keras.activations.sigmoid)
# ])

input = keras.layers.Input(shape=(2), name="Input")

dense = keras.layers.Dense(2, activation=keras.activations.relu)(input)
out1 = keras.layers.Dense(1, activation=keras.activations.sigmoid, name="out1")(dense)
out2 = keras.layers.Dense(1, activation=keras.activations.sigmoid, name="out2")(dense)

model = keras.Model(inputs=[input], outputs=[out1, out2])

model.summary()

model.compile(loss=WeightedBinaryCrossEntropy(3.03, from_logits=False), metrics=keras.metrics.BinaryAccuracy(), run_eagerly=True)
# model.fit(x=data_in, y=data_out, epochs=1000)
# model.fit(x=data_in, y=data_out, epochs=1000, class_weight={"out1" : {0: 1, 1: 1}, "out2" : {0 : 0.666, 1: 2}})
model.fit(x=data_in, y=data_out, epochs=1000, class_weight={0 : 1, 1: 3.03030303})


print(f"[11,27] => {model.predict([[12,27]])}")
print(f"[0,0] => {model.predict([[0,0]])}")
print(f"[9,18] => {model.predict([[9,18]])}")
print(f"[10,20] => {model.predict([[10,20]])}")
print(f"[0,22] => {model.predict([[0,22]])}")
print(f"[0,18] => {model.predict([[0,18]])}")
print(f"[8,0] => {model.predict([[8,0]])}")
print(f"[12,0] => {model.predict([[12,0]])}")


# Investigation how the MaxPooling, GlobalMaxPooling and Conv1D are working
# ========================================================
# ========================================================

# values = [[1, 2, 3, 0]]
# tf_values = tf.constant(values)
# print(tf_values.get_shape())
#
# embedder = keras.layers.Embedding(6, 2, mask_zero=True)
# embedded = embedder(tf_values)
#
# max_pool = keras.layers.MaxPooling1D()
# max_pooled = max_pool(embedded)
#
# global_max_pool = keras.layers.GlobalMaxPooling1D()
# global_max_pooled = global_max_pool(embedded)
#
# convolution = keras.layers.Conv1D(1, 3)
# convoluted = convolution(embedded)
#
# print("Embedded")
# print(embedded)
#
# a = 0.00484044
# af = 0.33562374
# b = -0.0118643
# bf = -0.0233146
#
# c = 0.04557529
# cf = -0.332606
# d = -0.00043412
# df = 0.66535354
#
# e = -0.04166546
# ef = 0.5160408
# f = -0.00935776
# ff = 0.28127122
#
# v = a*af + b*bf + c * cf + d*df + e*ef + f*ff
#
# print(v)
#
# # print("Max pooling:")
# # print(max_pooled)
# #
# # print("Global max pooling:")
# # print(global_max_pooled)
#
# print("Convoluted:")
# print(convoluted)
# print(convolution.get_weights())

# Difference => max pooling is some kind of convolution of the function (max()) and word with a window.


# Investigation how shuffle and batch are working together.
# ========================================================
# ========================================================


# def iterate(dataset: tf.data.Dataset, batch_count):
#     for batch in dataset:
#         print(batch.numpy())
#
#     #  for i in range(0,batch_count):
#     # #     print(list(dataset.as_numpy_iterator()))
#     #     iterator = dataset.__iter__()
#     #     try:
#     #         value = iterator.get_next()
#     #         print(value)
#     #     except tf.errors.OutOfRangeError:
#     #         pass
#
# x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
#
# d = tf.data.Dataset.from_tensor_slices((x)).shuffle(15)
#
# d1_batch_size = 3
# d1_batch_count = ceil(10 / d1_batch_size)
# d2_batch_size = 4
# d2_batch_count = ceil(10 / d2_batch_size)
#
# d1 = d.take(10).shuffle(15).batch(d1_batch_size)
#
# d2 = d.skip(10).take(5).batch(d2_batch_size)
#
# print(d1)
# print(d2)
#
# print("Iterate on d1")
# iterate(d1, d1_batch_count)
#
# print("Iterate second time on d1")
# iterate(d1, d1_batch_count)
#
#
#
# print("Iterate d2")
# iterate(d2, d2_batch_count)