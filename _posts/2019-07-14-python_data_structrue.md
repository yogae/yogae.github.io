---
layout: post
title: python 자료구조
data: 2019-07-14
categories: Python
author: yogae
---

## 튜플

튜플은 1차원의 고정된 크기를 가지는 변경 불가능한 순차 자료형입니다.

```python
# 튜플 생성
tup = 4, 5, 6

tup2 = (3, 4, 5), (7, 8)
```

```python
# 자료형을 tuple로 변현
tuple([1, 2, 3])

tuple('str')
```

```python
# tuple 원소 접근
tup[0] 

# tuple 값 분리
tup = (4, 5, 6)
a, b, c = tup

tup = 1, 2, (3, 4)
a, b, (c, d) = tup

values = 1, 2, 3, 4
a, b, *rest = values
rest # [3, 4]
```

### 연산자

```python
(3, 4, 5) + (6, 7) # (3, 4, 5, 6, 7)
(1, 2) * 2 # (1, 2, 1, 2)
```

### 메서드

- count: 주어진 값과 같은 값이 몇 개 있는지 반환

  ```python
  a = (1, 2, 2, 3, 3, 3, 4, 4, 4, 4)
  a.count(3) # 3
  ```

- index: 주어진 값의 위치 반환

  ```python
  a = (3, 4, 5, 6)
  a.index(5) # 2
  ```

## 리스트

튜플과 대조적으로 기스트는 크기나 내용의 변경이 가능합니다.

```
listA = [1, 2, 3]
listTup = list([4, 5, 6])
```

### 연산자

```python
# 이어붙이기
[1, 2, 3] + [4, 5, 6] # [1, 2, 3, 4, 5, 6]

# 슬라이싱
seq = [3, 4, 5, 6]
seq[:2] # [3, 4]
seq[1:2] # [4]
seq[-1:] # [6] 음수는 끝에서 부터 위치
seq[::2] # [3, 5] 간격(step)을 지정
seq[::-1] # [6, 5, 4, 3] step이 -1인 경우 연순으로 반환 
```

### 메서드

- append: 리스트의 끝에 새로운 값을 추가

  ```python
  listA.append('hi')
  ```

- insert: 리스트의 특정 위치에 새로운 값을 추가

  ```python
  listA.insert(1, 'hello')
  ```

- pop: 특정 위치의 값을 반환하고 해당 값을 리스트에서 삭제

  ```python
  listA.pop(2)
  ```

- remove: 원소를 삭제

  ```python
  listA.remove(1)
  ```

- extend: 이어붙이기(리스트의 + 연산자를 사용하여 이어붙이는 것 보다 성능이 좋음)

  ```python
  listA.extend([2, 3, 4])
  ```

- sort: 정렬

  ```python
  listA.sort()
  listA.sort(key=len)
  ```

### 내장 순차 자료형 함수

- enumerate: 순차 자료형에서 색인을 함께 반환할 때 사용

  ```python
  for index, value in enumerate(listA):
  	print(index, value)
  ```

- sorted: 정렬된 새로운 순차 자료형을 반환

  ```python
  sorted([3, 1, 2, 6, 8, 3, 4]) # [1, 2, 3, 3, 4, 6, 8]
  ```

- zip: 순차 자료형을 서로 짝지은 튜플을 생성

  ```python
  # 리스트의 크기는 자료형 중에 짧은 크기로 정해진다.
  list1 = ['a', 'b', 'c', 'd']
  list2 = [1, 2, 3]
  zipped = zip(list1, list2)
  list(zipped)
  ```

- reversed: 순차 자료형을 역순으로 변경

  ```python
  list(reversed(range(3))) # [2, 1 ,0]
  ```

## 사전

