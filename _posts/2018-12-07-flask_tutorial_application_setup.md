---
layout: post
title:  "flask tutorial - Application Setup"
date: 2018-12-07
categories: Python
author: yogae
---

## Project Layout

project의 layout은 이렇게 보일 것입니다.

```
/home/user/Projects/flask-tutorial
├── flaskr/
│   ├── __init__.py
│   ├── db.py
│   ├── schema.sql
│   ├── auth.py
│   ├── blog.py
│   ├── templates/
│   │   ├── base.html
│   │   ├── auth/
│   │   │   ├── login.html
│   │   │   └── register.html
│   │   └── blog/
│   │       ├── create.html
│   │       ├── index.html
│   │       └── update.html
│   └── static/
│       └── style.css
├── tests/
│   ├── conftest.py
│   ├── data.sql
│   ├── test_factory.py
│   ├── test_db.py
│   ├── test_auth.py
│   └── test_blog.py
├── venv/
├── setup.py
└── MANIFEST.in
```

- `flaskr/` application code와 file을 포함합니다.
- `tests` test module을 포함합니다.
- `venv/` python virtual eviroment

```
# .gitignore 예시
venv/

*.pyc
__pycache__/

instance/

.pytest_cache/
.coverage
htmlcov/

dist/
build/
*.egg-info/
```

## Application Setup

Flask application은 Flask class의 객체 입니다. 구성과 URL같은 application에 대한 모든 것은 Flask class에 등록될 것 입니다.

Flask 객체를 전역으로 생성하는 것 대신 funciton 안에 생성 할 것 입니다. 이 function은  *application factory*이라고 합니다. 설정, 등록, setup  *application factory*에서 일어나고 application이 반환될 것입니다.

### The Application Factory

```python
# flaskr/__init__.py
import os

from flask import Flask

# application factory
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # a simple page that says hello
    @app.route('/hello')
    def hello():
        return 'Hello, World!'

    return app
```

1. `app = Flask(__name__, instance_relative_config=True)` `Flask`객체를 생성합니다.
   - `__name__` 현재 Python module의 이름입니다. app은 setup을 위하여 어디에 위치해 있는지 알아야 합니다. `__name__` 는 위치를 알기위한 간편한 방법입니다.
   - `instance_relative_config=True` 은 구성 file이 instance folder에 연관된 app이라는 것을 알려줍니다. instance folder는  `flaskr` package 밖에 위치하고 설정 secret이나 database file 같은 version control에 commit되어서는 않되는 local data를 가지고 있습니다.
2. `app.config.from_mapping()`  app에서 사용할 기본 구성을 설정합니다.:
   - [`SECRET_KEY`](http://flask.pocoo.org/docs/1.0/config/#SECRET_KEY) 는 data를 안전하게 지키기 위하여 Flask와 extension에서 사용됩니다. 개발 단계에서는 `'dev'`로 설정하여 간편하게 사용하지만 배포단계에서는 random value로 override해야 합니다.
   - `DATABASE`SQListe database file의 path입니다. `app.instance_path` 안에 있습니다. `app.instance_path` 은 instance folder의 path입니다.
3. `app.config.from_pyfile()`은  `config.py` file이 존재한다면  `config.py` file의 기본 configuration를 overrideg합니다.
4. [`os.makedirs()`](https://docs.python.org/3/library/os.html#os.makedirs) `app.instance_path`가 존재하는지 확인합니다.

### Run The Application

development mode에서는 exception이 발생하면 debugger를 보여고 code를 변경하면 server를 재실행 합니다.

```python
export FLASK_APP=flaskr
export FLASK_ENV=development
flask run
```

