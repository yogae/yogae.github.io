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

 ㅇㅇㅇ