import subprocess
import tempfile
from math import ceil
from shlex import shlex
from subprocess import call
import os
import tensorflow as tf

# print(subprocess.check_output(['/Users/jonathanduss/Desktop/ArticlePreprocessorTool2']), os.getcwd())
#
# (file, path) = tempfile.mkstemp()
# print(file)
# print(path)
#
# process = subprocess.Popen(["./ArticlePreprocessorTool", '/Users/jonathanduss/Desktop/untitled folder/articles_fr_28.json', '/Users/jonathanduss/Desktop/untitled folder/articles_fr_28_out.json'], stdout=subprocess.PIPE)
# #process = subprocess.Popen(["sh", 'a.sh'], stdout=subprocess.PIPE)
#
#
# while True:
#     p = process.poll()
#     output = process.stdout.readline()
#     if process.poll() is not None:
#         break
#     if output:
#         print(output.strip())

def iterate(dataset: tf.data.Dataset, batch_count):
    for batch in dataset:
        print(batch.numpy())

    #  for i in range(0,batch_count):
    # #     print(list(dataset.as_numpy_iterator()))
    #     iterator = dataset.__iter__()
    #     try:
    #         value = iterator.get_next()
    #         print(value)
    #     except tf.errors.OutOfRangeError:
    #         pass

x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

d = tf.data.Dataset.from_tensor_slices((x)).shuffle(15)

d1_batch_size = 3
d1_batch_count = ceil(10 / d1_batch_size)
d2_batch_size = 4
d2_batch_count = ceil(10 / d2_batch_size)

d1 = d.take(10).shuffle(15).batch(d1_batch_size)

d2 = d.skip(10).take(5).batch(d2_batch_size)

print(d1)
print(d2)

print("Iterate on d1")
iterate(d1, d1_batch_count)

print("Iterate second time on d1")
iterate(d1, d1_batch_count)



print("Iterate d2")
iterate(d2, d2_batch_count)