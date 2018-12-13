---
layout: post
title:  "context managers, with 구문"
date: 2018-12-02
categories: Python
author: yogae
---

## Context Managers

Context managers allow you to allocate and release resources precisely when you want to. The most widely used example of context managers is the `with` statement.

## with 구문

with 구문을 이용하면 try/finally을 대신하여 더 간편하고 쉽게 사용할 수 있습니다.

```python
file = open('some_file', 'w')
try:
    file.write('Hola!')
finally:
    file.close()
```

코드가 제대로 동작하지 않고 끝나더라도 finally는 무조건 샐행되는 것을 보장한다.

```python
class File(object):
    def __init__(self, file_name, method):
        self.file_obj = open(file_name, method)
    def __enter__(self):
        return self.file_obj
    def __exit__(self, type, value, traceback):
        self.file_obj.close()

with File('demo.txt', 'w') as opened_file:
    opened_file.write('Hola!')
```

`__enter__()`과 `__exit__()`을 정의하여 사용한다면 재사용성이 높아지고 편리할 것이다. context manager에 의해서 `__enter__`이 실행되고 여기서 반환하는 값이 `as`의 thing로 지정된다.



## Reference

- http://book.pythontips.com/en/latest/context_managers.html