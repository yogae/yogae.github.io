---
layout: post
title:  "TensorFlow - Importing Data"
date: 2019-01-28
categories: ML
author: yogae
---

`tf.data` API는 복잡한 input pipline을 구성하기 위해 사용할 수 있습니다.  `tf.data` API는 많은 양의 data, 다른 data 포맷, 복잡한 변형을 다루기 쉽게 합니다. 

## Basic mechanics

Input pipeline을 시작하기 위해서 source를 정의해야합니다. 예를 들어, memory에 tensor로 부터 `Dataset` 을 만들기 위해서는 `tf.data.Dataset.from_tensors()` 나 `tf.data.Dataset.from_tensor_slices()` 를 사용할 수 있습니다. input data가 TFRecord format으로 dist에 있다면 `tf.data.TFRecordDataset` 을 만들 수 있습니다. 

`Dataset` 객체가 있으면 연속적인 method를 호출하여 새로운 `Dataset` 으로 변형할 수 있습니다.(예: `Dataset.map()`  `Dataset.batch()`)

`Dataset` 으로 부터 value를 사용하는 기본적인 방법은 iterator 객체를 만드는 것 입니다. `tf.data.Iterator`는 두가지 operation을 제공합니다.

 1. `Iterator.initializer`

    iterator의 상태를 초기화합니다.

 2. `Iterator.get_next()`

    다음 요소에 해당하는 `tf.Tensor` 객체를 반환합니다.

### Dataset structure

dataset은 같은 구조를 가진 요소로 구성되어 있습니다. 각 요소는 하나 또는 그 이상의 `tf.Tensor` 객체(components라고 함)를 포함합니다. 각각의 component는 tensor에서 요소의 type을 나타내는 `tf.DType` 와 각 요소의 static shape를 나타내는 `tf.TensorShape` 가 있습니다. `Dataset.output_types`와 `Dataset.output_shapes` 는 dataset 요소의 유추된 type과 shape을 검사할 수 있습니다. The *nested structure* of these properties map to the structure of an element, which may be a single tensor, a tuple of tensors, or a nested tuple of tensors. 

> - **name**, the name of a Tensor is used as an index for the tensor.
> - **shape**, describing the dimension information of the tensor.
> - **type**, showing what kind of data stored in Tensor.
>
> TensorFlow Tensor contains two kinds of shape: static shape and dynamic shape.  The static shape can be read using the tf.Tensor.get_shape() method; this shape is inferred from the operations that were used to create the tensor, and may be partially complete. If the static is not fully defined, the dynamic shape of a Tensor can be determined by evaluating tf.shape(t).
>
> 그냥 범위내에서 균등한 확률로 랜덤값이 나오게 하거나 = uniform
> 범위내에서 종모양의 정규분포에 따라 값이 나오게 하거나 = normal

```python
dataset1 = tf.data.Dataset.from_tensor_slices(tf.random_uniform([4, 10]))
print(dataset1.output_types)  # ==> "tf.float32"
print(dataset1.output_shapes)  # ==> "(10,)"

dataset2 = tf.data.Dataset.from_tensor_slices(
   (tf.random_uniform([4]),
    tf.random_uniform([4, 100], maxval=100, dtype=tf.int32)))
print(dataset2.output_types)  # ==> "(tf.float32, tf.int32)"
print(dataset2.output_shapes)  # ==> "((), (100,))"

dataset3 = tf.data.Dataset.zip((dataset1, dataset2))
print(dataset3.output_types)  # ==> (tf.float32, (tf.float32, tf.int32))
print(dataset3.output_shapes)  # ==> "(10, ((), (100,)))"
```

각각의 component에 이름을 붙이는 것이 편할 때가 있습니다. `collections.namedtuple` 을 사용하거나 dictionary을 사용할 수 있습니다.

```python
dataset = tf.data.Dataset.from_tensor_slices(
   {"a": tf.random_uniform([4]),
    "b": tf.random_uniform([4, 100], maxval=100, dtype=tf.int32)})
print(dataset.output_types)  # ==> "{'a': tf.float32, 'b': tf.int32}"
print(dataset.output_shapes)  # ==> "{'a': (), 'b': (100,)}"
```

어느 구조의 dataset에서도 Dataset transformations을 사용할 수 있습니다. 각각의 요소에 function을 적용하는 `Dataset.map()`, `Dataset.flat_map()`, 그리고 `Dataset.filter()` transformations을 사용할 때, element의 구조는 function의 argument를 결정합니다. 

```python
dataset1 = dataset1.map(lambda x: ...)

dataset2 = dataset2.flat_map(lambda x, y: ...)

# Note: Argument destructuring is not available in Python 3.
dataset3 = dataset3.filter(lambda x, (y, z): ...)
```

### Creating an iterator

input data Dataset을 구성할 때 다음 단계는 dataset에서 요소에 접근할 수 있는 `Iterator` 를 생성하는 것입니다. `tf.data` API는 현재 아래의 iterators를 지원합니다.

- **one-shot**,
- **initializable**,
- **reinitializable**, and
- **feedable**

`get_next` 함수는 sessiong에서 실행할 graph에서 실행할 operation을 생성합니다. 일반적으로tf.errors.OutOfRangeError가 발생할 때까지 `get_next` 함수를 실행합니다.



**one-shot** iterator는 iterator의 중에 가장 간단한 형식입니다. one-shot는 dataset을 통해 오직 한 번의 iterating만 지원하고 명시적으로 초기화할 필요가 없습니다. One-shot iterators는 queue-based input pipline을 지원하는 거의 모든 경우를 처리할 수 있습니다. 그러나 parameterization를 지원하지 않습니다.

```python
dataset = tf.data.Dataset.range(100)
iterator = dataset.make_one_shot_iterator()
next_element = iterator.get_next()

for i in range(100):
  value = sess.run(next_element)
  assert i == value
```

> 현재 one-shot iterators은 `Estimator`를 쉽게 사용가능한 유일한 type입니다.

**initializable** iterator을 사용하기 위해서는 명백한 `iterator.initializer` operation을 실행해야합니다. iterator을 초기화할 때 `tf.placeholder()` tensor를 사용하여 dataset을 정의를 paraemeter활 할 수 있습니다.

```python
max_value = tf.placeholder(tf.int64, shape=[])
dataset = tf.data.Dataset.range(max_value)
iterator = dataset.make_initializable_iterator()
next_element = iterator.get_next()

# Initialize an iterator over a dataset with 10 elements.
sess.run(iterator.initializer, feed_dict={max_value: 10})
for i in range(10):
  value = sess.run(next_element)
  assert i == value

# Initialize the same iterator over a dataset with 100 elements.
sess.run(iterator.initializer, feed_dict={max_value: 100})
for i in range(100):
  value = sess.run(next_element)
  assert i == value
```

**reinitializable** iteraor는 다른 여러 Dataset 객체로 부터 초기화 될 수 있습니다.

```python
# Define training and validation datasets with the same structure.
training_dataset = tf.data.Dataset.range(100).map(
    lambda x: x + tf.random_uniform([], -10, 10, tf.int64))
validation_dataset = tf.data.Dataset.range(50)

# A reinitializable iterator is defined by its structure. We could use the
# `output_types` and `output_shapes` properties of either `training_dataset`
# or `validation_dataset` here, because they are compatible.
iterator = tf.data.Iterator.from_structure(training_dataset.output_types, training_dataset.output_shapes)
next_element = iterator.get_next()

training_init_op = iterator.make_initializer(training_dataset)
validation_init_op = iterator.make_initializer(validation_dataset)

# Run 20 epochs in which the training dataset is traversed, followed by the
# validation dataset.
for _ in range(20):
  # Initialize an iterator over the training dataset.
  sess.run(training_init_op)
  for _ in range(100):
    sess.run(next_element)

  # Initialize an iterator over the validation dataset.
  sess.run(validation_init_op)
  for _ in range(50):
    sess.run(next_element)
```

**feedable** iterator는 `feed_dict` mechanism을 통해 어떤 `Iterator`를 사용할지 선택하기 위하여  `tf.placeholder` 와 함께 사용될 수 있습니다. reinitializable iterator과 같은 기능을 제공합니다. 그러나 dataset의 시작에서 iterator를 초기화할 필요가 없습니다. feedable iterator를 저정의하기 위해서 `Tf.data.Iterator.from_string_handle`을 사용할 수 있습니다.

```python
# Define training and validation datasets with the same structure.
training_dataset = tf.data.Dataset.range(100).map(
    lambda x: x + tf.random_uniform([], -10, 10, tf.int64)).repeat()
validation_dataset = tf.data.Dataset.range(50)

# A feedable iterator is defined by a handle placeholder and its structure. We
# could use the `output_types` and `output_shapes` properties of either
# `training_dataset` or `validation_dataset` here, because they have
# identical structure.
handle = tf.placeholder(tf.string, shape=[])
iterator = tf.data.Iterator.from_string_handle(
    handle, training_dataset.output_types, training_dataset.output_shapes)
next_element = iterator.get_next()

# You can use feedable iterators with a variety of different kinds of iterator
# (such as one-shot and initializable iterators).
training_iterator = training_dataset.make_one_shot_iterator()
validation_iterator = validation_dataset.make_initializable_iterator()

# The `Iterator.string_handle()` method returns a tensor that can be evaluated
# and used to feed the `handle` placeholder.
training_handle = sess.run(training_iterator.string_handle())
validation_handle = sess.run(validation_iterator.string_handle())

# Loop forever, alternating between training and validation.
while True:
  # Run 200 steps using the training dataset. Note that the training dataset is
  # infinite, and we resume from where we left off in the previous `while` loop
  # iteration.
  for _ in range(200):
    sess.run(next_element, feed_dict={handle: training_handle})

  # Run one pass over the validation dataset.
  sess.run(validation_iterator.initializer)
  for _ in range(50):
    sess.run(next_element, feed_dict={handle: validation_handle})
```

### Consuming values from an iterator

`Iterator.get_next()` method는 iterator의 다음 요소에 해당하는  `tf.Tensor` 객체를 하나 또는 그 이상 반환합니다. tensor가 평가될 때마다 기본 dataset에서 다음 요소의 값을 가지고 옵니다. TensorFlow에서 다른 stateful object처럼 `Iterator.get_next()` 호출하는 것은 iterator를 즉시 진행되지 않습니다. 대신 TensorFlow expression에서 반환되는  `tf.Tensor` 객체를 사용해야하고 다음 요소를 얻기위해 그 expression의 결과를 `tf.Session.run()` 으로 넘겨줘고 iterator을 진행시켜야합니다.)

iterator가 dataset의 마지막에 도달하면, `Iterator.get_next()` 을 실행하는 것은 `tf.errors.OutOfRangeError` 을 발생시킵니다. iterator가 사용불가 상태 이후에 iterater를 사용하기 위해서는 iterator를 초기화해야합니다.

```python
dataset = tf.data.Dataset.range(5)
iterator = dataset.make_initializable_iterator()
next_element = iterator.get_next()

# Typically `result` will be the output of a model, or an optimizer's
# training operation.
result = tf.add(next_element, next_element)

sess.run(iterator.initializer)
print(sess.run(result))  # ==> "0"
print(sess.run(result))  # ==> "2"
print(sess.run(result))  # ==> "4"
print(sess.run(result))  # ==> "6"
print(sess.run(result))  # ==> "8"
try:
  sess.run(result)
except tf.errors.OutOfRangeError:
  print("End of dataset")  # ==> "End of dataset"
```

### Saving iterator state

`tf.contrib.data.make_saveable_from_iterator` 함수는 iterator에서 iterator의 현재 상태를 저장하고 복원하기 위해 사용되는 `SaveableObject` 를 생성합니다. saveable 객체는 `tf.Variable` 과 같은 방법으로  `tf.train.Saver` valiables list나 `tf.GraphKeys.SAVEABLE_OBJECTS` collection에 추가될 수 있습니다.

```python
# Create saveable object from iterator.
saveable = tf.contrib.data.make_saveable_from_iterator(iterator)

# Save the iterator state by adding it to the saveable objects collection.
tf.add_to_collection(tf.GraphKeys.SAVEABLE_OBJECTS, saveable)
saver = tf.train.Saver()

with tf.Session() as sess:

  if should_checkpoint:
    saver.save(path_to_checkpoint)

# Restore the iterator state.
with tf.Session() as sess:
  saver.restore(sess, path_to_checkpoint)
```

## Reading input data

### Consuming NumPy arrays

모든 input data가 memory에 있다면 `Dataset`을 만드는 가장 쉬운 방법은 input data를 `tf.Tensor` 객체로 바꾸고 `Dataset.from_tensor_slices()` 을 사용하는 것입니다.

```python
# Load the training data into two NumPy arrays, for example using `np.load()`.
with np.load("/var/data/training_data.npy") as data:
  features = data["features"]
  labels = data["labels"]

# Assume that each row of `features` corresponds to the same row as `labels`.
assert features.shape[0] == labels.shape[0]

dataset = tf.data.Dataset.from_tensor_slices((features, labels))
```

`tf.constant()` operation으로 TensorFlow graph에 `features` and `labels` array를 포함할 것입니다. 이러한 작업은 작은 dataset에는 좋지만 큰 dataset을 요구하는 작업에서는 memory를 낭비합니다. `tf.GraphDef` protocol buffer에 2GB 제한 안에서 실행되어야 합니다.

`Tf.placeholder()` 로 dataset을 정의하고 `Iterator` 를 초기화할 때 NumPy array를 주입할 수 있습니다.

```python
# Load the training data into two NumPy arrays, for example using `np.load()`.
with np.load("/var/data/training_data.npy") as data:
  features = data["features"]
  labels = data["labels"]

# Assume that each row of `features` corresponds to the same row as `labels`.
assert features.shape[0] == labels.shape[0]

features_placeholder = tf.placeholder(features.dtype, features.shape)
labels_placeholder = tf.placeholder(labels.dtype, labels.shape)

dataset = tf.data.Dataset.from_tensor_slices((features_placeholder, labels_placeholder))
# [Other transformations on `dataset`...]
dataset = ...
iterator = dataset.make_initializable_iterator()

sess.run(iterator.initializer, feed_dict={features_placeholder: features,
                                          labels_placeholder: labels})
```

### Consuming TFRecord data

`tf.data` API는 큰 용량의 dataset의 처리를 위해 다양한 file formet을 지원합니다. TFRecord file format은 training data를 위해 많은 TensorFlow application에서 사용하는 simple record-oriented binary format입니다.

```python
# Creates a dataset that reads all of the examples from two files.
filenames = ["/var/data/file1.tfrecord", "/var/data/file2.tfrecord"]
dataset = tf.data.TFRecordDataset(filenames)
```

```python
filenames = tf.placeholder(tf.string, shape=[None])
dataset = tf.data.TFRecordDataset(filenames)
dataset = dataset.map(...)  # Parse the record into tensors.
dataset = dataset.repeat()  # Repeat the input indefinitely.
dataset = dataset.batch(32)
iterator = dataset.make_initializable_iterator()

# You can feed the initializer with the appropriate filenames for the current
# phase of execution, e.g. training vs. validation.

# Initialize `iterator` with training data.
training_filenames = ["/var/data/file1.tfrecord", "/var/data/file2.tfrecord"]
sess.run(iterator.initializer, feed_dict={filenames: training_filenames})

# Initialize `iterator` with validation data.
validation_filenames = ["/var/data/validation1.tfrecord", ...]
sess.run(iterator.initializer, feed_dict={filenames: validation_filenames})
```

### Consuming text data

`tf.data.TextLineDataset`는 하나 또는 그 이상의 text file에서 line을 쉽게 추출하는 방법을 제공합니다. 

```python
filenames = ["/var/data/file1.txt", "/var/data/file2.txt"]
dataset = tf.data.TextLineDataset(filenames)
```

default로 `TestLineDataset` 각 file의 모든 line을 반환합니다. 이 line들은 `Dataset.skip()` 과 `Dataset.filter()` transformation을 사용하여 제거될 수 있습니다. transformation을 각 file로 분리하기 위해서 `Dataset.flat_map()` 을 사용합니다.

```python
filenames = ["/var/data/file1.txt", "/var/data/file2.txt"]

dataset = tf.data.Dataset.from_tensor_slices(filenames)

# Use `Dataset.flat_map()` to transform each file as a separate nested dataset,
# and then concatenate their contents sequentially into a single "flat" dataset.
# * Skip the first line (header row).
# * Filter out lines beginning with "#" (comments).
dataset = dataset.flat_map(
    lambda filename: (
        tf.data.TextLineDataset(filename)
        .skip(1)
        .filter(lambda line: tf.not_equal(tf.substr(line, 0, 1), "#"))))
```

### Consuming CSV data

`tf.contrib.data.CsvDataset` class는 하나 또는 그 이상의 CSV file에서 record를 추출하는 방법을 제공합니다. 

```python
# Creates a dataset that reads all of the records from two CSV files, each with
# eight float columns
filenames = ["/var/data/file1.csv", "/var/data/file2.csv"]
record_defaults = [tf.float32] * 8   # Eight required float columns
dataset = tf.contrib.data.CsvDataset(filenames, record_defaults)
```

```python
# Creates a dataset that reads all of the records from two CSV files, each with
# four float columns which may have missing values
record_defaults = [[0.0]] * 8
dataset = tf.contrib.data.CsvDataset(filenames, record_defaults)
```

default로 `CsvDataset`은 file의 모든 line을 반환합니다. 이 line과 field는 `header` 그리고 `select_cols` argument를 사용하여 제거될 수 있습니다.

```python
# Creates a dataset that reads all of the records from two CSV files with
# headers, extracting float data from columns 2 and 4.
record_defaults = [[0.0]] * 2  # Only provide defaults for the selected columns
dataset = tf.contrib.data.CsvDataset(filenames, record_defaults, header=True, select_cols=[2,4])
```

## Batching dataset elements

### Simple batching

모든 요소가 같은 shape의 tensor로 구성된 경우

```python
inc_dataset = tf.data.Dataset.range(100)
dec_dataset = tf.data.Dataset.range(0, -100, -1)
dataset = tf.data.Dataset.zip((inc_dataset, dec_dataset))
batched_dataset = dataset.batch(4)

iterator = batched_dataset.make_one_shot_iterator()
next_element = iterator.get_next()

print(sess.run(next_element))  # ==> ([0, 1, 2,   3],   [ 0, -1,  -2,  -3])
print(sess.run(next_element))  # ==> ([4, 5, 6,   7],   [-4, -5,  -6,  -7])
print(sess.run(next_element))  # ==> ([8, 9, 10, 11],   [-8, -9, -10, -11])
```

다른 shape의 tensor로 구성된 경우

```python
dataset = tf.data.Dataset.range(100)
dataset = dataset.map(lambda x: tf.fill([tf.cast(x, tf.int32)], x))
dataset = dataset.padded_batch(4, padded_shapes=(None,))

iterator = dataset.make_one_shot_iterator()
next_element = iterator.get_next()

print(sess.run(next_element))  # ==> [[0, 0, 0], [1, 0, 0], [2, 2, 0], [3, 3, 3]]
print(sess.run(next_element))  # ==> [[4, 4, 4, 4, 0, 0, 0],
                               #      [5, 5, 5, 5, 5, 0, 0],
                               #      [6, 6, 6, 6, 6, 6, 0],
                               #      [7, 7, 7, 7, 7, 7, 7]]
```

## Training workflows

### Processing multiple epochs

```python
filenames = ["/var/data/file1.tfrecord", "/var/data/file2.tfrecord"]
dataset = tf.data.TFRecordDataset(filenames)
dataset = dataset.map(...)
dataset = dataset.repeat(10)
dataset = dataset.batch(32)
```

### Randomly shuffling input data

```python
filenames = ["/var/data/file1.tfrecord", "/var/data/file2.tfrecord"]
dataset = tf.data.TFRecordDataset(filenames)
dataset = dataset.map(...)
dataset = dataset.shuffle(buffer_size=10000)
dataset = dataset.batch(32)
dataset = dataset.repeat()
```