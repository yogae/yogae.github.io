---
layout: post
title:  "flask quickstart"
date: 2018-12-02
categories: Python
author: yogae
---

##A Minimal Application

간단한 flask application을 아래와 같습니다.

```python
from flask import Flask
# class의 instance를 만듭니다.
# application module이나 package의 이름을 첫번째 인자로 넣습니다.
app = Flask(__name__)

# 어떤 URL이 trigger될지 알려줍니다.
@app.route('/')
# trigger될 함수
def hello_world():
    return 'Hello, World!'
```

> application을  `flask.py`로 사용하면 Flask에서 충돌이나므로  `flask.py`는 사용하면 안 됩니다.

application을 실행하기 위해서 flask 명령을 사용하거나 python의 `-m`을 Flask와 변경합니다. 실행 전에 `FLASK_APP`환경 변수를 이용하여 사용할 application을 설정해야합니다.

```bash
$ export FLASK_APP=hello.py

$ flask run
$ flask run --host=0.0.0.0 # 외부에 접속하는 사용자가 있는 경우
# 또는
$ python -m flask run
```

개발버전은 FLASK_ENV에 development를 설정하여 사용하면 아래와 같은 기능을 수행 할 수 있다.

1. it activates the debugger
2. it activates the automatic reloader
3. it enables the debug mode on the Flask application.

## Routing

 [`route()`](http://flask.pocoo.org/docs/1.0/api/#flask.Flask.route) decorator를 사용하여 function을 url에 바인딩한다.

```python
@app.route('/')
def index():
    return 'Index Page'

@app.route('/hello')
def hello():
    return 'Hello, World'
```

### Variable Rules

```python
@app.route('/user/<username>')
def show_user_profile(username):
    # show the user profile for that user
    return 'User %s' % username

@app.route('/post/<int:post_id>')
def show_post(post_id):
    # show the post with the given id, the id is an integer
    return 'Post %d' % post_id

@app.route('/path/<path:subpath>')
def show_subpath(subpath):
    # show the subpath after /path/
    return 'Subpath %s' % subpath
```

Converter Types: string, int, float, path(accepts slashes), uuid

### Unique URLs / Redirection Behavior

```python
# 'projects'로 접근하면 'projects/'로 redirec된다.
@app.route('/projects/')
def projects():
    return 'The project page'

# 'projects/'로 접근하면 404 error 발생
@app.route('/about')
def about():
    return 'The about page'
```

### HTTP Methods

```python
from flask import request

# method default: GET
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        return do_the_login()
    else:
        return show_the_login_form()
```

Get method를 사용하면 flask에서 자동적으로 `HEAD` method를 지원하고 `Head`request 를  HTTP RFC로 처리합니다. `OPTIONS`은 자동적으로 구현됩니다. 

### Static Files

static folder를 packge에 만들면 application에서 `/static`에서 사용할 수 있습니다.

static file을 URL로 생성하기 위해서는 `static` endpoint 이름을 사용해야합니다.

```python
# staic/style.css에 저장된 static file
url_for('static', filename='style.css')
```

### Redering Templates

flask는 자동적으로 Jinja2 template가 설정되어 있습니다. tempate를 render하기 위해서 **render_template()** method를 사용합니다. template의 이름과 template에 전달하고 싶은 value를 제공합니다.

```python
from flask import render_template

@app.route('/hello/')
@app.route('/hello/<name>')
def hello(name=None):
    return render_template('hello.html', name=name)
```

flask는 `templates` folder에서 template를 찾습니다. 

```python
# module
/application.py
/templates
    /hello.html
# package
/application
    /__init__.py
    /templates
        /hello.html
```

jinja2 templates 사용

 - [Template Designer Documentation](http://jinja.pocoo.org/docs/2.10/templates/)
 - [jinja 상속](http://flask.pocoo.org/docs/1.0/patterns/templateinheritance/#template-inheritance)

### Accessing Request Data

flask에서는 request object를 전역으로 사용합니다. method 속성을 사용하여 현재 request의 method를 이용가능합니다. form data에 접근하기 위해서는 form 속성을 사용할 수 있습니다. form 속성에 key가 존재하지 않으면 keyError가 발생합니다. keyError를 처리하지 않으면 400 Bad Request error page가 보여집니다.

```python
from flask import request

@app.route('/login', methods=['POST', 'GET'])
def login():
    error = None
    if request.method == 'POST':
        if valid_login(request.form['username'],
                       request.form['password']):
            return log_the_user_in(request.form['username'])
        else:
            error = 'Invalid username/password'
    # the code below is executed if the request method
    # was GET or the credentials were invalid
    return render_template('login.html', error=error)
```

parameters에 접근하기 위해서는 args속성을 사용합니다. URL parameter는 get 또는 keyError를 catch하여 접근하는 것을 추천합니다.

```python
searchword = request.args.get('key', '')
```

### File Uploads

HTML form에서 *enctype="multipart/form-data"* 속성을 추가해야합니다. upload된 file은 메모리 또는 filesystem의 임시 공간에 저장 됩니다. request object의 files속성으로 upload된 file에 접근할 수 있습니다. 각 file은 dictionary에 저장됩니다.  filesystem에 file을 저장하기 위하여 **save()** method를 사용할 수 있습니다.

```python
from flask import request

@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        f = request.files['the_file']
        f.save('/var/www/uploads/uploaded_file.txt')
```

### Cookie

```python
# Reading cookie
from flask import request

@app.route('/')
def index():
    username = request.cookies.get('username')
    # use cookies.get(key) instead of cookies[key] to not get a
    # KeyError if the cookie is missing.

# Store cookie
from flask import make_response

@app.route('/')
def index():
    resp = make_response(render_template(...))
    resp.set_cookie('username', 'the username')
    return resp
```

### Redirects and Errors

사용자를 다른 endpoint로 redirect하기 위하여 **redirect()** function을 사용합니다. request를 error code와 함께 중단하기 위해서는 **abort()** function을 사용합니다.

```python
from flask import abort, redirect, url_for

@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/login')
def login():
    abort(401)
    this_is_never_executed()
```

error page를 customize하고 싶다면 **errorhandler** decorator를 사용할 수 있습니다.

```python
from flask import render_template

@app.errorhandler(404)
def page_not_found(error):
    return render_template('page_not_found.html'), 404
```

```python
# response data를 변경하기 위하여 make_response()를 사용한다.
@app.errorhandler(404)
def not_found(error):
    resp = make_response(render_template('error.html'), 404)
    resp.headers['X-Something'] = 'A value'
    return resp
```

### Sessions

사용자가 하나의 reqeust에서 다음 request로 정보를 저장할 수 있도록 합니다. cookie를 사용하여 구현됩니다. session을 사용하기 위해서는 secret key를 설정해야 합니다.

```python
from flask import Flask, session, redirect, url_for, escape, request

app = Flask(__name__)

# Set the secret key to some random bytes. Keep this really secret!
# secret key를 생성하기 위한 명령: python -c 'import os; print(os.urandom(16))'
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

@app.route('/')
def index():
    if 'username' in session:
        return 'Logged in as %s' % escape(session['username'])
    return 'You are not logged in'

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        session['username'] = request.form['username']
        return redirect(url_for('index'))
    return '''
        <form method="post">
            <p><input type=text name=username>
            <p><input type=submit value=Login>
        </form>
    '''

@app.route('/logout')
def logout():
    # remove the username from the session if it's there
    session.pop('username', None)
    return redirect(url_for('index'))
```

### Logging

```python
app.logger.debug('A value for debugging')
app.logger.warning('A warning occurred (%d apples)', 42)
app.logger.error('An error occurred')
```

> [logger 참고](https://docs.python.org/3/library/logging.html)

## Reference

- [Quickstart](http://flask.pocoo.org/docs/1.0/quickstart/)