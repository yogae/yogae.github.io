---
layout: post
title:  "TensorFlow - Estimators"
date: 2019-01-22
categories: ML
author: yogae
---

Estimators는 machine learning programming을 매우 단순하게하는 높은 수준의 TensorFlow API입니다.

## Estimators의 장점

- local host에서  Estimator-based model을 실행할 수 있고 model을 변경하지않고 여러 server에 분산 할 수 있습니다.
- model 개발자 사이에서 구현물들을 쉽게 공유할 수 있습니다.
- 높은 수준의 직관적인 코드로 최첨단 모델을 개발할 수 있습니다. 저 수준의 TensorFlow APIs 보다 model을 쉽게 만들 수 있습니다.
- Estimator는 `tf.keras.layers` 위에 구성됩니다.
- Estimator는 분산된 안전한 training loop를 제공합니다.
  - build the graph
  - initialize variables
  - load data
  - handle exceptions
  - create checkpoint files and recover from failures
  - save summaries for TensorBoard

##Pre-made Estimators

 Pre-made Estimators를 사용하면 기본 TensorFlow API보다 높은 개념 수준에서 작업 할 수 있습니다. graph나 sessions을 만드는 것을 걱정할 필요가 없고  `tf.Graph` 와 `tf.Session` object를 관리할 필요가 없습니다.

### Structure of a pre-made Estimators program

1. dataset을 importing하는 함수 구성

   training set을 importing하는 funtion을 만들고 test set을 import하는 fuction을 만들 것입니다. Dataset importing 함수는 2가지 객체를 반환해야 합니다.

   - 특성의 이름이 key이고 특성 data가 포함된 Tensors(또는 SparseTensors)가  value인 dictionary
   - 하나 또는 그 이상의 label을 포함하는 Tensor

   ```python
   # example
   def input_fn(dataset):
      ...  # manipulate dataset, extracting the feature dict and the label
      return feature_dict, label
   ```

2. 특성 column 정의

   각각의 tf.feature_column은 특성의 이름, type, input pre-processing을 식별합니다.

   ```python
   # Define three numeric feature columns.
   population = tf.feature_column.numeric_column('population')
   crime_rate = tf.feature_column.numeric_column('crime_rate')
   median_education = tf.feature_column.numeric_column('median_education',
                       normalizer_fn=lambda x: x - global_education_mean)
   ```

3. pre-made Estimator를 객체화

   ```python
   # Instantiate an estimator, passing the feature columns.
   estimator = tf.estimator.LinearClassifier(
       feature_columns=[population, crime_rate, median_education],
       )
   ```

4. training, evaluating 그리고 inference 함수 호출

   ```python
   # my_training_set is the function created in Step 1
   estimator.train(input_fn=my_training_set, steps=2000)
   ```

## Reference

- https://www.tensorflow.org/guide/estimators

