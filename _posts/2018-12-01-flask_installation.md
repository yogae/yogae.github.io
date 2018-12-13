---
layout: post
title:  "flask 설치"
date: 2018-12-01
categories: Python
author: yogae
---

### Python Version

- 최신 Python 3 버전 사용을 권장
- Python 3.4 and newer, Python 2.7, PyPy 지원

### Dependencies

flask 설치와 함께 설치되는 package

- [Werkzeug](https://palletsprojects.com/p/werkzeug/) - application과 서버 사이의 Python interface, WSGI 규약을 설정하여 Web application 서버와 Web 서버 사이의 통신이 가능하도록 한다.
- [Jinja](http://jinja.pocoo.org/docs/2.10/) - application page를 render하는 template 언어
- [MarkupSafe](https://pypi.org/project/MarkupSafe/) - template를 redering할 때 injection attack을 피하기 위해 사용
- [ItsDangerous](https://pythonhosted.org/itsdangerous/) - Flask의 session cookie를 보호하기 위해 사용
- [Click](http://click.pocoo.org/) - command line을 쓰기 위한 framework

### Optional dependencies

사용자가 사용할 때 설치됨

- [Blinker](https://pythonhosted.org/blinker/) - signal을 지원하기 위한 package
  - Signal: core framework or another Flask extensions의 어디에서든 action이 발생하였을 때 notification을 전송하여 application의 분리를 돕는다.
- [SimpleJSON](https://simplejson.readthedocs.io/) - JSON 사용을 위한 package
- [python-dotenv](https://github.com/theskumar/python-dotenv#readme) - 환경변수를 관리하기 위한 package
- [Watchdog](https://pythonhosted.org/watchdog/) - reloader - nodemon과 비슷한 역할

### Virtual environments

- 많은 Python project를 가질수록, 다른 버전의 Python으로 작업할 필요가 있다. 새로운 버전의 library는 다른 project에서 호환성이 깨질 수 있다.
- Virtual enviroments는 Python library의 독립적인 그룹이 각 project마다 하나씩 있다. 하나의 project에 설치된 Pakage는 다른 project나 운영 system에 영향을 주지 않는다.
- Python 3은 virtual enviroment를 만들기위한 venv module과 번들링되어 있다. 

### Create an environment

```bash
mkdir myproject
cd myproject
python3 -m venv venv
```

### Install Flask

```bash
pip install Flask
```


## Reference
- [flask installation](http://flask.pocoo.org/docs/1.0/installation/#installation)
