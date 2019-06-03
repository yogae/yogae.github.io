---
layout: post
title:  "한글 완성형과 조합형"
date: 2019-06-01
categories: ETC
author: yogae
---

## 조합형(NFD - Normalization Form Canonical Decomposition)

한글 자모를 조합해서 한글을 표현합니다. 한글 표현에 있어 가장 합리적이고 이상적인 방식이라서 도스 시절에는 많이 사용되었지만 현재 많이 없어지고 있습니다.

## 완성형(NFC - Normalization Form Canonical Composition)

한글 글쓰기에서 많이 사용되는 글자들만 골라서, "가" "나" "다" "라" 이렇게 미리 만들어 놓고 한 덩어리로 표현하는 코드입니다.

## 문제점

Mac OS에서는 이 방식을 채택하여 사용하고 있습니다. 따라서 window나 다른 완성형을 사용하는 곳에서 Mac OS에서 만들어진 file(또는 한글을 사용하는 경우)을 전송받게되면 자모가 분리되어 보이는 현상이 발생합니다.

Mac에서 실행하는 Web Application의 경우 조합형으로 한글을 encoding하기 때문에 web application에서 받은 한글을 DB나 storage에 그대로 저장하는 경우 한글 search에 문제가 발생할 수 있습니다.

## 해결방법 - javascript

javascript 기본 함수 중에 `normalize()` 함수를 사용하여 한글 encoding을 변형할 수 있습니다.

normalize의 매개변수

- `NFC` — 정규형 정준 결합(Normalization Form Canonical Composition).
- `NFD` — 정규형 정준 분해(Normalization Form Canonical Decomposition).
- `NFKC` — 정규형 호환성 결합(Normalization Form Compatibility Composition).
- `NFKD` — 정규형 호환성 분해(Normalization Form Compatibility Decomposition).

```javascript
// 결합된 한글 문자열

// U+D55C: 한(HANGUL SYLLABLE HAN)
// U+AE00: 글(HANGUL SYLLABLE GEUL)
var first = '\uD55C\uAE00';

// 정규형 정준 분해 (NFD)
// 정준 분해 결과 초성, 중성, 종성의 자소분리가 일어납니다.
// 일부 브라우저에서는 결과값 '한글'이 자소분리된 상태로 보여질 수 있습니다. 

// U+1112: ᄒ(HANGUL CHOSEONG HIEUH)
// U+1161: ᅡ(HANGUL JUNGSEONG A)
// U+11AB: ᆫ(HANGUL JONGSEONG NIEUN)
// U+1100: ᄀ(HANGUL CHOSEONG KIYEOK)
// U+1173: ᅳ(HANGUL JUNGSEONG EU)
// U+11AF: ᆯ(HANGUL JONGSEONG RIEUL)
var second = first.normalize('NFD'); // '\u1112\u1161\u11AB\u1100\u1173\u11AF'


// 정규형 정준 결합 (NFC)
// 정준 결합 결과 자소분리 되었던 한글이 결합됩니다.

// U+D55C: 한(HANGUL SYLLABLE HAN)
// U+AE00: 글(HANGUL SYLLABLE GEUL)
var third = second.normalize('NFC'); // '\uD55C\uAE00'

console.log(second === third); // 같은 글자처럼 보이지만 false를 출력합니다.
```





