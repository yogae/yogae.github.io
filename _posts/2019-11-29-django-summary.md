---
layout: post
title:  "Django 프래임워크"
date: 2018-11-29
categories: Python
author: yogae
---

- Django 프레임워크를 사용하여 간단한 application 개발
- 파이썬 웹프로그래밍(김석훈 지음)책을 따라 작성
- hosing은 pythonanywhere을 사용

# 정리
- Django는 많은 기능들을 재공하고 있으며 이를 규격화 빠르게 개발 할 수 있도록 되어있다.
- 규격화되어 있는 부분들이 많아서 처음 시작할 때 알아야할 부분이 많아 보인다.
- Django에서 지원하는 ORM을 사용하면 admin 페이지를 쉽게 작성 가능하다. 
- MVT모델에 따라 작성하도록 되어 있으며, 많이 사용하는 view는 generic class view를 extend하여 쉽게 개발이 가능하다.
- NGNIX와 같을 웹서버 프로그램이 클라이언트 요청을 수신하므로, WAS 서버를 통하여 장고 웹 애플리케이션을 호출할 수 있도록 한다.

# test
- [django project code](https://github.com/yogae/django-test)
- [website](http://yogae.pythonanywhere.com/)