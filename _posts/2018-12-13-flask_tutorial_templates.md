---
layout: post
title:  "flask tutorial - Templates"
date: 2018-12-13
categories: Python
author: yogae
---

templates file은 `flaskr` package안에 있는  `templates` dicrectory에 저장됩니다. templates는 dynamic한 data를 위한 placeholder와 static data를 포함하는 file입니다. flask는 template를 render하기 위하여 Jinja template library를 사용합니다.

Jinja는 Python처럼 보이고 행동합니다. Jinja syntax를 구별하기 위하여 특별한 delimiters를 사용합니다. \{\{ \}\}은 output, \{\% \%\} if와 for 같은 제어 flow 구문을 의미합니다.

