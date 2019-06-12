---
layout: post
title: stream으로 데이터 전송 방법 및 axios 사용 문제점
date: 2019-06-11
categories: ETC
author: yogae
---

# Node.js stream

```javascript
export function func(req: Request, res: Response, next: NextFunction) {
    const query = queryParser.parseQuery(req.query);
    objectDao
        .listCursor(identityID, query)
        .pipe(res.type('json'));
};
```

listCurosr는 mongoose에서 QueryCursor를 반환합니다. mongoose의 QueryCursor는 stream library의 readable을 확장한 class입니다. node.js의 response 객체는 stream library의 writable을 확장한 객체 입니다. 따라서 pipe로 연결하여 readable 객체를 writable로 연결할 수 있습니다. mongoose에서 읽어온 data를 stream으로 연결하여 반환합니다.

## Axios stream

```javascript
import axios, { AxiosInstance } from 'axios';
import { Readable } from 'stream';

const response = await axios.get('', { responseType: 'stream'});
const readable: Readable = response.data
```

axios의 config에 responseType: 'stream'으로 설정하여 반환되는 데이터를 readable 객체로 받을 수 있습니다.

## Browser에서 stream 사용시 문제점

axios는 node.js로 실행할 경우 http를 사용하여 request를 만들고 browser로 실행할 경우 XMLHttpRequests를 사용하여  request를 만듭니다. node.js로 실행하여 위의 code를 실행하면 정상적으로 동작하지만 browser에서 실행하면 readable 객체를 반환받을 수 없습니다.

문제의 원인은 XMLHttpRequests에서 stream 형식을 지원하지 않는 것입니다. 아래는 XMLHttpRequests의 responseType에 대한 정보입니다.

| Value                       | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `""`                        | An empty `responseType` string is treated the same as `"text"`, the default type (therefore, as a [`DOMString`](https://developer.mozilla.org/en-US/docs/Web/API/DOMString). |
| `"arraybuffer"`             | The [`response`](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/response) is a JavaScript [`ArrayBuffer`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer) containing binary data. |
| `"blob"`                    | The `response` is a [`Blob`](https://developer.mozilla.org/en-US/docs/Web/API/Blob) object containing the binary data. |
| `"document"`                | The `response` is an [HTML](https://developer.mozilla.org/en-US/docs/Glossary/HTML) [`Document`](https://developer.mozilla.org/en-US/docs/Web/API/Document) or [XML](https://developer.mozilla.org/en-US/docs/Glossary/XML) [`XMLDocument`](https://developer.mozilla.org/en-US/docs/Web/API/XMLDocument), as appropriate based on the MIME type of the received data. See [HTML in XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/HTML_in_XMLHttpRequest) to learn more about using XHR to fetch HTML content. |
| `"json"`                    | The `response` is a JavaScript object created by parsing the contents of received data as [JSON](https://developer.mozilla.org/en-US/docs/Glossary/JSON). |
| `"text"`                    | The `response` is text in a [`DOMString`](https://developer.mozilla.org/en-US/docs/Web/API/DOMString) object. |
| `"moz-chunked-arraybuffer"` | Similar to `"arraybuffer"`, but the data is received in a stream. When using this response type, the value in `response`is only available in the handler for the `progress` event, and only contains the data received since the last `progress`event, rather than the cumulative data received since the request was sent.Accessing `response` during a `progress` event returns the data received so far. Outside the `progress` event handler, the value of `response` is always `null`. |
| `"ms-stream"`               | The `response` is part of a streaming download; this response type is only allowed for download requests, and is only supported by Internet Explorer. |

### 해결방법

axios 대신 fetch를 사용하여 구현할 수 있습니다.

```javascript
var chunkedUrl = 'https://jigsaw.w3.org/HTTP/ChunkedScript';
fetch(chunkedUrl)
  .then(processChunkedResponse)
  .then(onChunkedResponseComplete)
  .catch(onChunkedResponseError)
  ;

function onChunkedResponseComplete(result) {
  console.log('all done!', result)
}

function onChunkedResponseError(err) {
  console.error(err)
}

function processChunkedResponse(response) {
  var text = '';
  var reader = response.body.getReader()
  var decoder = new TextDecoder();
  
  return readChunk();

  function readChunk() {
    return reader.read().then(appendChunks);
  }

  function appendChunks(result) {
    var chunk = decoder.decode(result.value || new Uint8Array, {stream: !result.done});
    console.log('got chunk of', chunk.length, 'bytes')
    text += chunk;
    console.log('text so far is', text.length, 'bytes\n');
    if (result.done) {
      console.log('returning')
      return text;
    } else {
      console.log('recursing')
      return readChunk();
    }
  }
}
```

