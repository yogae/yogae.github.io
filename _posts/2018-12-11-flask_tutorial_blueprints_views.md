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

