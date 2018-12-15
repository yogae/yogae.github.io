---
layout: post
title:  "flask tutorial - Templates"
date: 2018-12-13
categories: Python
author: yogae
---

templates file은 `flaskr` package안에 있는  `templates` dicrectory에 저장됩니다. templates는 dynamic한 data를 위한 placeholder와 static data를 포함하는 file입니다. flask는 template를 render하기 위하여 Jinja template library를 사용합니다.

Jinja는 Python처럼 보이고 행동합니다. Jinja syntax를 구별하기 위하여 특별한 delimiters를 사용합니다. \{\{ \}\}은 output, \{\% \%\} if와 for 같은 제어 flow 구문을 의미합니다.

## The Base Layout

각각의 application의 page는 같은 layout를 가집니다. 전체 HTML을 다 작성하는 것 대신 base template을 extend하고 특별한 section을 override할 수 있습니다.

```jinja2
{# flaskr/templates/base.html #}
<!doctype html>
<title>{% block title %}{% endblock %} - Flaskr</title>
<link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
<nav>
  <h1>Flaskr</h1>
  <ul>
    {% if g.user %}
      <li><span>{{ g.user['username'] }}</span>
      <li><a href="{{ url_for('auth.logout') }}">Log Out</a>
    {% else %}
      <li><a href="{{ url_for('auth.register') }}">Register</a>
      <li><a href="{{ url_for('auth.login') }}">Log In</a>
    {% endif %}
  </ul>
</nav>
<section class="content">
  <header>
    {% block header %}{% endblock %}
  </header>
  {% for message in get_flashed_messages() %}
    <div class="flash">{{ message }}</div>
  {% endfor %}
  {% block content %}{% endblock %}
</section>
```

`g` 는 template에서 자동으로 사용가능합니다. `url_for()`또한 자동적으로 사용할 수 있고 view로 가는 URL을 생성합니다.

`get_flashed_messages()`는 message를 반환합니다. `flash()` 는 error message를 보여주기 위해 사용할 수 있습니다.

base template는  `template`에 직접적으로 있습니다. 조직적으로 유지하기 위하여 blueprint를 위한 blueprint에 같은 이름의 template를 directory에 넣을 수 있습니다.

## Register

```jinja2
{# flaskr/templates/auth/register.html #}
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Register{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="username">Username</label>
    <input name="username" id="username" required>
    <label for="password">Password</label>
    <input type="password" name="password" id="password" required>
    <input type="submit" value="Register">
  </form>
{% endblock %}
```

\{\% extends 'base.html' \%\} 은 base template에서 block을 대체해야 합니다. \{\% block \%\} tag는  base tamplate에 block을 override합니다.

\\{\% block header \%\} 안에 {\% block title \%\} 를 넣어서 window와 page가 같은 title을 두번 적상하지 않고 공유하게 합니다.

## Log In

```jinja2
{# flaskr/templates/auth/login.html #}
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Log In{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="username">Username</label>
    <input name="username" id="username" required>
    <label for="password">Password</label>
    <input type="password" name="password" id="password" required>
    <input type="submit" value="Log In">
  </form>
{% endblock %}
```

