---
layout: post
title:  "같은 S3 event Notification에서 multiple lambda trigger"
date: 2019-03-26
categories: AWS
author: yogae
---

## Problem

Now as we know we can not have multiple lambda triggered directly from single S3 event as unfortunately at the moment, S3 is limited to a single event notification. This means that trying to add more than one Lambda function for the same event will result in an overlap error, thus we have to look into alternative architecture.

## Solution

1. SNS topic을 사용하여 여러 lambda function을 trigger할 수 있습니다.
2. lambda를 S3 event에 trigger되도록 설정하고 lambda에서 여러 lambda를 trigger할 수 있습니다.

## Reference

- https://www.linkedin.com/pulse/triggering-multiple-lambda-from-single-s3-event-kush-vyas