---
layout: post
title:  "Node.js 비동기 처리"
date: 2018-11-30
categories: NodeJS
author: yogae 
---

##  Multi Thread

- Apache와 같은 일반적인 웹서버는 Multi Process 또는 Multi Thread의 형태를 가지고 있다. 
- 톰캣과 같은 서버는 위의 그림과 같이 Client에서부터 요청이 오면, Thread를 미리 만들어 놓은 Thread Pool에서 Thread를 꺼내서 Client의 요청을 처리하게 하고, 요청이 끝나면 Thread Pool로 돌려보낸 후, 다른 요청이 오면 다시 꺼내서 요청을 처리하게 하는 구조이다.
- 생성할 수 있는 Thread의 수는 한계가 있다.

## Single Thread Model

- 하나의 Thread만을 사용해서 여러 Client로부터 오는 Request를 처리한다.
- IO작업시 기다리지 않기 때문에(non-blocking), 하나의 Thread가 다른 요청을 받아서 작업을 처리할 수 있는 구조가 된다.  이 요청을 받아서 처리하는 Thread를 ELP (Event Loop Thread)라고 한다.
- thread pool을 별도로 운영하면서 blocking function call의 경우에는 thread pool의 thread를 이용하여 IO 처리를 하여 event loop thread가 io에 의해서 block되지 않게 한다.

# Node.js

- 실제로 V8과 같은 자바스크립트 엔진은 단일 호출 스택(Call Stack)을 사용하며, 요청이 들어올 때마다 해당 요청을 순차적으로 호출 스택에 담아 처리할 뿐이다. 
- libuv가 이벤트 루프를 제공한다. 자바스크립트 엔진은 비동기 작업을 위해 Node.js의 API를 호출하며, 이때 넘겨진 콜백은 libuv의 이벤트 루프를 통해 스케쥴되고 실행된다.
- 이벤트 루프는 '현재 실행중인 태스크가 없을 때'(주로 호출 스택이 비워졌을 때) 태스크 큐의 첫 번째 태스크를 꺼내와 실행한다.
- 마이크로 태스크는 쉽게 말해 일반 태스크보다 더 높은 우선순위를 갖는 태스크라고 할 수 있다. 즉, 태스크 큐에 대기중인 태스크가 있더라도 마이크로 태스크가 먼저 실행된다. 프라미스의 `then()` 메소드는 태스크 큐가 아닌 별도의 **마이크로 태스크 큐**에 추가한다.

### EventLoop

- 이벤트 루프는 가능하다면 언제나 시스템 커널에 작업을 떠넘겨서 Node.js가 논 블로킹 I/O 작업을 수행하도록 해줍니다.

- 이벤트루프는 메인스레드 겸 싱글스레드로서, 비즈니스 로직을 수행한다.

- 단계:

  1. Times: 타이머는 사람이 *실행하기를 원하는* **정확한** 시간이 아니라 제공된 콜백이 *일정 시간 후에 실행되어야 하는* **기준시간**을 지정합니다. 

  2. pending callbacks: 다음 루프 반복으로 연기된 I/O 콜백들을 실행합니다.

  3. Idle, prepare: 내부용으로만 사용합니다.

  4. Poll: 새로운 I/O이벤트를 가져옵니다. I/O와 연관된 콜백(클로즈 콜백, 타이머로 스케줄링된 콜백, `setImmediate()`를 제외한 거의 모든 콜백)을 실행합니다. 적절한 시기에 node는 여기서 블록 합니다.

     - 임계 값이 지난 타이머의 스크립트를 실행합니다.
     - **poll** 큐에 있는 이벤트를 처리합니다.

  5. Check: 

     - 이 단계는 **poll** 단계가 완료된 직후 사람이 콜백을 실행할 수 있게 합니다

     - `setImmediate()` 콜백은 여기서 호출됩니다.

  6. Close callbacks: 

     - 소켓이나 핸들이 갑자기 닫힌 경우(예: `socket.destroy()`) 이 단계에서 `'close'` 이벤트가 발생할 것입니다.

     - 일부 close 콜백들, 예를 들어 `socket.on('close', ...)`.





# reference

- http://sjh836.tistory.com/149
- [조대협의 블로그](http://bcho.tistory.com/881?category=513811)
- https://nodejs.org/ko/docs/guides/event-loop-timers-and-nexttick/
- https://meetup.toast.com/posts/89



