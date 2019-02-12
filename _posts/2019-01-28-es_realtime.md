---
layout: post
title:  "GET API"
date: 2019-01-28
categories: ES
author: yogae
---

### Realtime

By default, the get API is realtime, and is not affected by the refresh rate of the index (when data will become visible for search). If a document has been updated but is not yet refreshed, the get API will issue a refresh call in-place to make the document visible. This will also make other documents changed since the last refresh visible. In order to disable realtime GET, one can set the `realtime`parameter to `false`.

### Refresh

The `refresh` parameter can be set to `true` in order to refresh the relevant shard before the get operation and make it searchable. Setting it to `true` should be done after careful thought and verification that this does not cause a heavy load on the system (and slows down indexing).

## Reference

- https://qbox.io/blog/refresh-flush-operations-elasticsearch-guide

