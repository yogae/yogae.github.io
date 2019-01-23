---
layout: post
title:  "API Conventions"
date: 2019-01-21
categories: ES
author: yogae
---

## Multiple Indices

index parameter를 참조하는 대부분의 APIs는 multiple indices를 지원합니다. wildcard를 또한 지원합니다.

```
# example
/users,events,pages/_search
/u*,e*,p*/_search
```

모든 multi indices API는 아래의 query string parameter를 지원합니다.

- `ignore_unavailable`

  특정 indices가 사용이 불가능 하다면 무시할지를 결정합니다. true 또는 false

- `allow_no_indices`

  wildcard 표현에 구체적인 indices가 없다면 실패여부를 제어합니다. true 또는 false

- `expand_wildcards`

  open이라면 오직 open indices만 확장되고 closed일 경우 오직 close만 확장합니다. 모든 indices를 확장하기 위해서 open,closed 두 값을 모두 넣을 수 있습니다(all과 똑같이 작동). none은 wildcard 확장을 막습니다.

## Date math support in index names

Date math index name은 Time-series indices의 범위로 검색이 가능합니다. indices의 개수를 제한하여 cluster에 load를 감소시키고 실행 performance를 향상시킵니다.

date math index name은 모두 중괄호 안에 있어야하며, 모든 특수문자는 URI encode해야 합니다.

```
<static_name{date_math_expr{date_format|time_zone}}>
```

| `static_name`    | is the static text part of the name                          |
| ---------------- | ------------------------------------------------------------ |
| `date_math_expr` | is a dynamic date math expression that computes the date dynamically |
| `date_format`    | is the optional format in which the computed date should be rendered. Defaults to `YYYY.MM.dd`. |
| `time_zone`      | is the optional time zone . Defaults to `utc`.               |

현재시간을 2024-03-22로 가정한 example입니다.

| Expression                              | Resolves to           |
| --------------------------------------- | --------------------- |
| `<logstash-{now/d}>`                    | `logstash-2024.03.22` |
| `<logstash-{now/M}>`                    | `logstash-2024.03.01` |
| `<logstash-{now/M{YYYY.MM}}>`           | `logstash-2024.03`    |
| `<logstash-{now/M-1M{YYYY.MM}}>`        | `logstash-2024.02`    |
| `<logstash-{now/d{YYYY.MM.dd|+12:00}}>` | `logstash-2024.03.23` |

## Date Math

date value 형식의 대부분의 parameter(gt와 lt같은 range quer, from과 to같은 daterange aggregations)는 date math를 이해합니다.

- `+1h` - 한 시간 더하기
- `-1d` - 한 시간 빼기
- `/d` - 가까운 날짜로 반올림

| `y`  | years   |
| ---- | ------- |
| `M`  | months  |
| `w`  | weeks   |
| `d`  | days    |
| `h`  | hours   |
| `H`  | hours   |
| `m`  | minutes |
| `s`  | seconds |

## Response Filtering

