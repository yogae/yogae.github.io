---
layout: post
title:  "flask tutorial - Test Coverage"
date: 2018-12-19
categories: Python
author: yogae
---

code를 test하기 위하여 [pytest](https://pytest.readthedocs.io/en/latest/)와 [coverage](https://coverage.readthedocs.io/en/v4.5.x/)를 사용할 것입니다.

```bash
pip install pytest coverage
```

## Setup and Fixtures

`test_`로 시작하는 python module이 있고 각각의 test function은 `test_`로 시작합니다.

각 test는 임시 database file을 생성하고 test에 사용될 data를 populate합니다. 

```sql
# tests/data.sql
INSERT INTO user (username, password)
VALUES
  ('test', 'pbkdf2:sha256:50000$TCI4GzcX$0de171a4f4dac32e3364c7ddc7c14f3e2fa61f2d17574483f7ffbb431b4acb2f'),
  ('other', 'pbkdf2:sha256:50000$kJPKsz6N$d2d4784f1b030a9761f5ccaeeaca413f27f2ecb76d6168407af962ddce849f79');

INSERT INTO post (title, body, author_id, created)
VALUES
  ('test title', 'test' || x'0a' || 'body', 1, '2018-01-01 00:00:00');
```

 ```python
# tests/conftest.py
import os
import tempfile

import pytest
from flaskr import create_app
from flaskr.db import get_db, init_db

with open(os.path.join(os.path.dirname(__file__), 'data.sql'), 'rb') as f:
    _data_sql = f.read().decode('utf8')


@pytest.fixture
def app():
    db_fd, db_path = tempfile.mkstemp()

    app = create_app({
        'TESTING': True,
        'DATABASE': db_path,
    })

    with app.app_context():
        init_db()
        get_db().executescript(_data_sql)

    yield app

    os.close(db_fd)
    os.unlink(db_path)


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()
 ```

`tempfile.mkstemp()` 은 임시 파일을 생성하고 file object와 file path를 반환합니다. 

`TESTING` app이 test mode로 전환하여 flask의 내부에서 test를 보다 쉽게 할 수 있도록 합니다.

`client` fixture은 `app` fixture에서 만들어진 application object와 함께 `app.test_client()` 를 호출합니다. server를 운영하지 않으면서 application에 request를 하기 위해 client를 사용합니다.

`runner` fixture은 application에 등록되어 있는 click 명령을 호출할 수 있도록 합니다.

## Factory

```python
# tests/test_factory.py
from flaskr import create_app

def test_config():
    assert not create_app().testing
    assert create_app({'TESTING': True}).testing

def test_hello(client):
    response = client.get('/hello')
    assert response.data == b'Hello, World!'
```

## Database

```python
# tests/test_db.py
import sqlite3

import pytest
from flaskr.db import get_db


def test_get_close_db(app):
    with app.app_context():
        db = get_db()
        assert db is get_db()

    with pytest.raises(sqlite3.ProgrammingError) as e:
        db.execute('SELECT 1')

    assert 'closed' in str(e)
```

## Authentication

```python
# tests/conftest.py
class AuthActions(object):
    def __init__(self, client):
        self._client = client

    def login(self, username='test', password='test'):
        return self._client.post(
            '/auth/login',
            data={'username': username, 'password': password}
        )

    def logout(self):
        return self._client.get('/auth/logout')


@pytest.fixture
def auth(client):
    return AuthActions(client)
```

```python
# tests/test_auth.py
import pytest
from flask import g, session
from flaskr.db import get_db


def test_register(client, app):
    assert client.get('/auth/register').status_code == 200
    response = client.post(
        '/auth/register', data={'username': 'a', 'password': 'a'}
    )
    assert 'http://localhost/auth/login' == response.headers['Location']

    with app.app_context():
        assert get_db().execute(
            "select * from user where username = 'a'",
        ).fetchone() is not None


@pytest.mark.parametrize(('username', 'password', 'message'), (
    ('', '', b'Username is required.'),
    ('a', '', b'Password is required.'),
    ('test', 'test', b'already registered'),
))
def test_register_validate_input(client, username, password, message):
    response = client.post(
        '/auth/register',
        data={'username': username, 'password': password}
    )
    assert message in response.data
```

`pytest.mark.parametrize` 는 같은 test function을 사용하면서 다른 arguments를 사용할 때 사용합니다.

```python
# tests/test_auth.py
def test_login(client, auth):
    assert client.get('/auth/login').status_code == 200
    response = auth.login()
    assert response.headers['Location'] == 'http://localhost/'

    with client:
        client.get('/')
        assert session['user_id'] == 1
        assert g.user['username'] == 'test'


@pytest.mark.parametrize(('username', 'password', 'message'), (
    ('a', 'test', b'Incorrect username.'),
    ('test', 'a', b'Incorrect password.'),
))
def test_login_validate_input(auth, username, password, message):
    response = auth.login(username, password)
    assert message in response.data
```

## Blog

