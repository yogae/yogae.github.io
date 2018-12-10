---
layout: post
title:  "flask tutorial - Define and Access the Database"
date: 2018-12-10
categories: Python
author: yogae
---

SQLite database를 사용하여 user와 post를 저장할 것 입니다. Python에는 내장된 SQLite module을 지원합니다.

## Connect to the Database

먼저 해야할 것은 DB connection을 만드는 것 입니다. 수행되는 query와 opertion은 connection을 사용합니다. 수행이후 connection을 close합니다.

web application에서는 DB connection은 일반적으로 request와 연결됩니다. request를 처리할 때 생성되고 response가 전달되기 전에 close 됩니다.

```python
# flaskr/db.py
import sqlite3

import click
from flask import current_app, g
from flask.cli import with_appcontext


def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

    return g.db


def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()
```

`g`는 각 request마다 고유한 객체입니다. request를 처리하는 동안 여러 function에서 접근하는 data를 저장하기 위하여 사용합니다. connection은 저장되고 request에서 두번 `get_db`를 부른다면 새로운 connection을 만드는 대신 재사용합니다.

`current_app`은 request를 하고 있는 Flask application을 가르키기 위하여 사용하는 특별한 객체입니다. application factory를 사용하기 때문에 다른 code에서는 application 객체를 쓰지 않습니다. `get_db`은 application이 생성되고 requeset를 처리할 때 불려지고 `current_app`을 사용할 수 있습니다.

`sqlist3.connect()`는 `DATABASE` configuration key에서 가르켜지는 file로 connection를 생성합니다.

`sqlite3.Row`은 connection이 dicts 형태의 row를 반환하도록 합니다. 이는 이름으로 column에 접근이 가능하도록 합니다.

`close_db`는 connection이 생성되어 있는지 확인합니다. connection이 있다면 close합니다. 

## Create the Tables

