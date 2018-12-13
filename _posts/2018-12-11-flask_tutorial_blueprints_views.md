---
layout: post
title:  "flask tutorial - Blueprints and Views"
date: 2018-12-11
categories: Python
author: yogae
---

view function은 request에 대한 반응을 작성합니다. view는 response할 data를 반환합니다. flask는 또한 name과 argument를 기반으로 view로 URL을 만들고 다른 곳으로 direction할 수 있습니다.

## Create a Blueprint

Blueprint는 view와 다른 code를 그룹 조직화 할 수 있는 방법입니다. view와 다른 code를 직접적으로 사용하는 것보다 blueprint와 함께 사용합니다. 

```python
# flaskr/auth.py
import functools

from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)
from werkzeug.security import check_password_hash, generate_password_hash

from flaskr.db import get_db

bp = Blueprint('auth', __name__, url_prefix='/auth')
```

이름이 auth인 blueprint를 만들었습니다. blueprint는 어디에 정의되어 있는지 알아야합니다. 두 번째 인자로 `__name__`을 넣어서 어디에 위치한지 blueprint에 전달합니다. `url_prefix`는 blueprint와 관련된 모든 URL앞에 prefix를 추가합니다.

blueprint를 추가하기 위하여 `app.register_blueprint()`을 사용합니다.

```python
# flaskr/__init__.py
def create_app():
    app = ...
    # existing code omitted

    from . import auth
    app.register_blueprint(auth.bp)

    return app
```

## The First View: Register

```python
# flaskr/auth.py
@bp.route('/register', methods=('GET', 'POST'))
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None

        if not username:
            error = 'Username is required.'
        elif not password:
            error = 'Password is required.'
        elif db.execute(
            'SELECT id FROM user WHERE username = ?', (username,)
        ).fetchone() is not None:
            error = 'User {} is already registered.'.format(username)

        if error is None:
            db.execute(
                'INSERT INTO user (username, password) VALUES (?, ?)',
                (username, generate_password_hash(password))
            )
            db.commit()
            return redirect(url_for('auth.login'))

        flash(error)

    return render_template('auth/register.html')
```

- `@bp.route`은 URL `/register`에 register view function을 연결합니다.`/auth/register`request를 받았을 때 register view function을 호출합니다.
- `request.form`은 summit된 form key와 value를 mapping하는 특별한 dict type입니다.

- `fetchone()` query한 하나의 row를 반환합니다.
- `url_for()`url를 생성합니다.

## Login

```python
# flaskr/auth.py
@bp.route('/login', methods=('GET', 'POST'))
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None
        user = db.execute(
            'SELECT * FROM user WHERE username = ?', (username,)
        ).fetchone()

        if user is None:
            error = 'Incorrect username.'
        elif not check_password_hash(user['password'], password):
            error = 'Incorrect password.'

        if error is None:
            session.clear()
            session['user_id'] = user['id']
            return redirect(url_for('index'))

        flash(error)

    return render_template('auth/login.html')
```

- `session`은 request통해 data를 저장하는 dict입니다. user의 id는 새로운 session에 저장됩니다.  User 정보는 browser에 보내지는 cookie에 저장되고 browser는 이후의 request에 이 정보를 실어서 보냅니다.

```python
# flaskr/auth.py
@bp.before_app_request
def load_logged_in_user():
    user_id = session.get('user_id')

    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            'SELECT * FROM user WHERE id = ?', (user_id,)
        ).fetchone()
```

`bp.before_app_request()`는 view function전에 실행하는 function을 등록합니다.

## Logout

```python
# flaskr/auth.py
@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))
```

## Require Authentication in Other Views

```python
# flaskr/auth.py
def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('auth.login'))

        return view(**kwargs)

    return wrapped_view
```

