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

dataset은 같은 구조를 가진 요소로 구성되어 있습니다. 각 요소는 하나 또는 그 이상의 `tf.Tensor` 객체(components라고 함)를 포함합니다. 각각의 component는 tensor에서 요소의 type을 나타내는 `tf.DType` 와 각 요소의 static shape를 나타내는 `tf.TensorShape` 가 있습니다. `Dataset.output_types`와 `Dataset.output_shapes` 는 dataset 요소의 유추된 type과 shape을 검사할 수 있습니다. 

### Creating an iterator

### Consuming values from an iterator

### Saving iterator state

## Reading input data

