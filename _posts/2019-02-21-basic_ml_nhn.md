# 바로 실행해보는 딥러닝 기초

## TF 소개
- Deep learning을 위한 프레임워크
- google에서 만들고 유지 봇
- 사용자가 많다.
    - 구글링이 용이함
    - 새로운 모델 구현 및 지원이 빠름

- Tensor + Flow
    -  placeholder
        - 외부에서 값을 입력 받는 부분
        - 숫자 test 또는 image를 입력 할 수 잇다.
    - variable
        - 다른 곳에서 값을 받아올때
        - initialize가 필요
    - constant
        - 변하지 않는 상수
        - ex)
        ```python
            def get_data():
            node_a = tf.constant(3.0, dtype=tf.float32)
            node_b = tf.constant(4.0) # also tf.float32 implicitly
            return node_a, node_b
        ```
        ```python
        def build_model(node_a, node_b):
            add_ab = tf.add(node_a, node_b)
            node_c = tf.constant(2.0)
            ans = tf.multiply(add_ab, node_c)
            return ans
        ```

- TF 구성
    - build graph
        - graph를 생성 - 수식을 만들다.
    - run graph
        - session에 graph로 만들어진 수식을 실행한다.
        - 변수가 있는 경우 init해야하고 변수 값을 feed준다.

## ML이란
- 주어진 데이터를 잘 표현할 수 있는 모델을 찾고
- 모델을 이용하여 새로운 데이터를 예측하는 방법

- Linear Regression
    - 직선 그래프
    - 예측 값과 실제 값의 차이(loss function) -> 차이 값을 적은 것이 좋은 모델
    - 
```python
import tensorflow as tf
import numpy as np
import os
os.environ['CUDA_VISIBLE_DEVICES'] = ''
print ('tensorflow ver.{}'.format(tf.__version__))

# data 읽어오기
def get_data():
    data_x = np.reshape([[10, 1], [9, 1], [3, 1], [2, 1]], newshape=(4, 2))
    data_y = np.reshape([90, 80, 50, 30], newshape=(4, 1))
    return data_x, data_y

def build_model(X,W):
    hypothesis = tf.matmul(X, W) # Our Model
    
    return hypothesis

def get_loss(Y, model):
    loss = tf.reduce_mean(tf.square(model-Y))
    
    return loss

def get_optimizer():    
    optimizer = tf.train.GradientDescentOptimizer(learning_rate=0.01)
    # Optimizer 마다 defulat 값이 있음
    # 처음에는 default를 사용하다가 변경하여 사용하면 좋을 것 같다.

    return optimizer

def get_train_step(loss, optimizer):
    train_step = optimizer.minimize(loss)
    
    return train_step

## 데이터 읽어오기
data_x, data_y = get_data()

# 모델 만들기
X = tf.placeholder(tf.float32, shape=[4, 2])
Y = tf.placeholder(tf.float32, shape=[4, 1])

W = tf.Variable(tf.random_normal([2, 1]), name='weight')

model = build_model(X,W)

# Loss 정의
loss = get_loss(Y, model)

# Optimizer 설정
optimizer = get_optimizer()

# Train Step 정의
train_step = get_train_step(loss, optimizer)

sess = tf.Session()
sess.run(tf.global_variables_initializer())

for step in range(500):
    sess.run(train_step, feed_dict={X:data_x, Y:data_y})
    
    if (step) % 30 == 0:
        _loss, _W = sess.run([loss, W], feed_dict={X:data_x, Y:data_y})
        print '--step: {:3d}, W:({:.2f}, {:.2f}), Loss:{:.2f}'.format(step, _W[0][0], _W[1][0], _loss)

```

## Logistic Regression
- 시간에 따른 시험 합격 / 불합격 예측 문제
- sigmoid 함수를 사용하여 분류 그래프를 그릴 수 있음

```python
import tensorflow as tf
import numpy as np
import os
os.environ['CUDA_VISIBLE_DEVICES'] = ''

print ('tensorflow ver.{}'.format(tf.__version__))

def get_data():
    data_x = np.reshape([[10, 1], [9, 1], [3, 1], [2, 1]], newshape=(4, 2))
    data_y = np.reshape([1, 1, 0, 0], newshape=(4, 1))
    
    return data_x, data_y

def build_model(X,W):
    hypothesis = tf.sigmoid(tf.matmul(X, W))
    
    return hypothesis

def get_loss(Y, model):
    loss = tf.reduce_mean(-tf.reduce_sum(Y*tf.log(model) + (1-Y)*(tf.log(1-model))))
    
    return loss

def get_optimizer(lr_policy=None):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate=0.01)
    
    return optimizer

def get_train_step(loss, optimizer):
    train_step = optimizer.minimize(loss)

    return train_step

# 데이터 읽어오기
data_x, data_y = get_data()

# 모델 만들기
X = tf.placeholder(tf.float32, shape=[4, 2])
Y = tf.placeholder(tf.float32, shape=[4, 1])
W = tf.Variable(tf.random_normal([2, 1]), name='weight')

# Model 정의
model = build_model(X,W)

# Loss 정의
loss = get_loss(Y, model)

# Optimizer 설정
optimizer = get_optimizer()

# Train Step 정의
train_step = get_train_step(loss, optimizer)

sess = tf.Session()
sess.run(tf.global_variables_initializer())

for step in range(501):
    # Run graph
    sess.run(train_step, feed_dict={X:data_x, Y:data_y})
    if (step) % 30 == 0:
        _loss, _W = sess.run([loss, W], feed_dict={X:data_x, Y:data_y})
        print '--step: {:3d}, W:({:.2f}, {:.2f}), Loss:{:.2f}'.format(step, _W[0][0], _W[1][0], _loss)
```

## Neural Network의 기본 단위
- 인간의 뇌와 닮은 뉴럴 네트워크

- 2개 이상의 층을 완전 연결
    - 입력 층
    - 중간 층 여러개 층이 존재 가능
    - 출력 층
        - 선형함수
        - sigmoid - 분류
        - softmax - 3개 이상의 class로 분류

### Multi -Layer Perception(MLP)

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
import math
import os
import random
os.environ['CUDA_VISIBLE_DEVICES'] = ''

print ('tensorflow ver.{}'.format(tf.__version__))
tf.logging.set_verbosity(tf.logging.ERROR)

def get_data():
    return input_data.read_data_sets("MNIST_data/", one_hot=True)

mnist = get_data()

print 'train image num : ', mnist.train.images.shape
print 'train label num : ', mnist.train.labels.shape

# MNIST Data 살펴보기
sample_idx = random.sample(range(mnist.train.images.shape[0]), 1)

sample_img = Image.fromarray(np.reshape(mnist.train.images[sample_idx]*255, (28, 28)).astype(np.int32))
sample_label = mnist.train.labels[sample_idx]

plt.imshow(sample_img)
print 'label : ', sample_label

# build model
def build_model(x):
    W1 = tf.Variable(tf.random_normal([784, 128]), name='weight1')
    b1 = tf.Variable(tf.random_normal([128]), name='bias1')
    hidden_layer1 = tf.nn.sigmoid(tf.matmul(x, W1) + b1)

    W2 = tf.Variable(tf.random_normal([128, 32]), name='weight2')
    b2 = tf.Variable(tf.random_normal([32]), name='bias2')
    hidden_layer2 = tf.nn.sigmoid(tf.matmul(hidden_layer1, W2) + b2)

    W3 = tf.Variable(tf.random_normal([32, 10]), name='weight3')
    b3 = tf.Variable(tf.random_normal([10]), name='bias3')
    logits = tf.matmul(hidden_layer2, W3) + b3
    prediction = tf.nn.softmax(logits) # 확인을 위하여 추가한 code
    # softmax_cross_entropy_with_logits함수를 사용하면 제거 가능
    
    return {'logits': logits, 'prediction': prediction}

def get_loss(y, model):
    loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=model['logits'], labels=y))
    return loss

def get_optimizer():
    optimizer = tf.train.GradientDescentOptimizer(0.1)
    return optimizer

def get_train_step(loss, optimizer):
    train_step = optimizer.minimize(loss)

    return train_step

# 데이터 읽어오기
mnist = get_data()

# `Placeholder`: graph input 설정
x = tf.placeholder(tf.float32, [None, 784])
y = tf.placeholder(tf.float32, [None, 10])

sess = tf.Session()
sess.run(tf.global_variables_initializer())

# batch : 동시에 처리하는 데이터 묶음
# 1 epoch : 전체 데이터셋을 한 번 training에 사용
# 1 step(iteration) : training 연산을 한 번 실행
# MNIST train image 수 55,000
# batch size : 100
# 1 epoch을 위해서는 55,000/100 = 550 step 수행 필요

train_images_size = mnist.train.images.shape[0]
batch_size = 100
num_batch_per_epoch = int(math.ceil(train_images_size / batch_size))
num_epoch = 2

# Accuracy 정의
correct_prediction = tf.equal(tf.argmax(model['prediction'], 1), tf.argmax(y, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

for idx in range(num_batch_per_epoch*num_epoch):
    # load data
    batch_xs, batch_ys = mnist.train.next_batch(batch_size)

    if idx % 100 == 0:
        _accuracy, _loss = sess.run([accuracy, loss], feed_dict={x: mnist.test.images, y: mnist.test.labels})
        print ('[{:04d} step] accuracy : {:.4f}, loss :{:.4f}'.format(idx, _accuracy, _loss))
    # train
    sess.run(train_step, feed_dict={x:batch_xs, y:batch_ys})

```

## ML을 한다는 것
- 데이터를 모아 가공을 하고
- 데이터의 분포를 잘 표현할 수 있는 모델을 가정하고
- 모델을 평가할 수 있는 Loss 함수를 만들어
- 프로그래밍을 하는 것

## CNN

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
import matplotlib.pyplot as plt
import numpy as np
import os

tf.logging.set_verbosity(tf.logging.ERROR)

def get_data():
    return input_data.read_data_sets("datasets/mnist", one_hot=True)

def get_inputs():
    # image data입력 부분
    x = tf.placeholder(dtype=tf.float32, shape=[None, 28*28])
    # label data입력 부분
    y = tf.placeholder(dtype=tf.float32, shape=[None, 10])
    
    return x, y

# Model : algorithm 을 graph 연산으로 정의
def get_model(images):
    
    x_image = tf.reshape(images, [-1, 28, 28, 1])
    
    # filter shape : w, h, in_channel, out_channel
    conv1_filters = tf.Variable(tf.random_normal([3, 3, 1, 16], stddev=0.01))
    conv1 = tf.nn.conv2d(x_image, conv1_filters, strides=[1, 1, 1, 1], padding='SAME')
    conv1 = tf.nn.relu(conv1)
    print 'conv1', conv1

    pool1 = tf.nn.max_pool(conv1, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')
    print 'pool1', pool1

    batch, h, w, d = [x.value for x in pool1.get_shape()]    
    flatten = tf.reshape(pool1, [-1, h*w*d])
    print 'flatten', flatten
    
    fc_weights = tf.Variable(tf.random_normal([h*w*d, 10], stddev=0.01))
    fc_bias = tf.Variable(tf.random_normal([10]))
    
    logits = tf.matmul(flatten, fc_weights) + fc_bias
    print 'logits', logits
    return logits

def get_loss(logits, labels):
    # reduce_mean loss 값의 출력의 평균
    return tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=logits, labels=labels))

# 1. 데이터 읽기
mnist = get_data()

# 2. 모델과 모델입력부분 만들기
images, labels = get_inputs()
model_out = get_model(images)

# 3. Loss 만들기
loss = get_loss(model_out, labels)

# 4. Optimizer 만들기
optimizer = get_optimizer(lr=0.1)

train_op = optimizer.minimize(loss)

prediction = tf.nn.softmax(model_out)
correct_prediction = tf.equal(tf.argmax(prediction, 1), tf.argmax(labels, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

EPOCHS = 3
BATCH_SIZE = 100
NUM_BATCH_PER_EPOCH = int(mnist.train.images.shape[0]/float(BATCH_SIZE))

sess = tf.Session()
sess.run(tf.global_variables_initializer())

for ep in range(EPOCHS):
    for st in range(NUM_BATCH_PER_EPOCH):
        batch_images, batch_labels = mnist.train.next_batch(BATCH_SIZE)
        _, _acc, _loss = sess.run([train_op, accuracy, loss], feed_dict={images:batch_images, labels:batch_labels})
        
        if st % 100 == 0:
            print '{} Epoch, {} Step : acc({:.4f}), loss({:.4f})'.format(ep, st, _acc, _loss)
```





Full connect layers