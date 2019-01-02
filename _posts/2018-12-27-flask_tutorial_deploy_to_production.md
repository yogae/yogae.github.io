---
layout: post
title:  "flask tutorial - Deploy to Production"
date: 2018-12-19
categories: Python
author: yogae
---

## Build and Install

다른 곳에 application을 배포할 때 배포 file을 build해야 합니다. 현재 python 배포 표준은 wheel format(.whl 확장자)입니다.

```bash
pip install wheel
```

python과 `setup.py` 을 실행하는 것은 build와 관련된 명령을 사용할 수 있습니다. `bdist_wheel` 명령은 wheel 배포 file을 build 합니다.

```bash
python setup.py bdist_wheel # dist/flaskr-1.0.0-py3-none-any.whl file이 만듦
```

```bash
# 다른 환경에서 package를 build
pip install flaskr-1.0.0-py3-none-any.whl

export FLASK_APP=flaskr
flask init-db
```

## Configure the Secret Key

production에서는 `SECRET_KEY` 를 랜덤한 byte로 변경하여 session cookie와 secret key를 사용하는 것을 보호해야 합니다.

```bash
# 랜덤 secret key 생성
python -c 'import os; print(os.urandom(16))' 
```

```python
# venv/var/flaskr-instance/config.py
SECRET_KEY = b'_5#y2L"F4Q8z\n\xec]/'
```

다른 필수적인 configuration을 config.py에 지정하여 사용할 수 있습니다.

## Run with a Production Server

public하게 server를 운영할 때는 `flask run`을 사용하지 않습니다. 개발 서버는 Werkzeug로 편리성을 제공하지만 효율적이고 안정적이고 안전하게 설계되지 않았습니다.

production WSGI server를 사용하기 위하여 [Waitress](https://docs.pylonsproject.org/projects/waitress/)을 사용합니다. 

```bash
pip install waitress
```

application object를 사용하기 위해 application factory를 부를 수 있도록 Waitress에게 알려줘야합니다.

```bash
waitress-serve --call 'flaskr:create_app'
```

