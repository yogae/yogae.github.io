---
layout: post
title:  "flask tutorial - Make the Project Installable"
date: 2018-12-18
categories: Python
author: yogae
---

project를 설치가능하게 만든다는 것은 다른 환경에서 배포 file을 build하고 설치 할 수 있도록 하는 것을 의미합니다. 이것은 다른 library를 설피하는 것처럼 project를 배포하는 것입니다.

## Describe the Project

`setup.py` file은 포함하고 있는 file과 project를 설명합니다.

```python
# setup.py
from setuptools import find_packages, setup

setup(
    name='flaskr',
    version='1.0.0',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=[
        'flask',
    ],
)
```

`packages` 는 python에게 어떤 file이 포함되어 있는지 어느 directory를 포함하는지를 알려줍니다. `find_packages()` 는 자동으로 directory를 찾습니다. static file이나 template directory와 같은 다른 file을 포함시키기 위해서는 `include_package_data` 를 설정해야 합니다. `MANIFEST.in` 에 다른 file을 적어줍니다.

```
# MANIFEST.in
include flaskr/schema.sql
graft flaskr/static
graft flaskr/templates
global-exclude *.pyc
```

## Install the Project

설치하기 위하여 `pip` 를 사용합니다.

```bash
pip install -e .
```

pip가 현재 directory에 `setup.py` file을 찾고 설치합니다. `pip list` 로 설치된 project를 확인할 수 있습니다.

