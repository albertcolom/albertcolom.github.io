---
title: "Top 10 Most Used Regex Patterns"
layout: post
date: 2023-11-10 00:00
image: https://miro.medium.com/v2/resize:fit:1400/0*lZ2mDr6jmZ8mCKm9
headerImage: false
tag:
- regex
category: blog
author: albertcolom
description: List of the most commonly used regular expressions that you should know.
---

![Regex](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*bc7VTQq0w_g8t01h0aRQjg.jpeg)

List of the most commonly used regular expressions that you should know.

Regular expressions or regex are used to search for and match patterns in strings or text data. This is useful for tasks such as validating input, searching for specific words or phrases, and extracting information from text.

In this post I have tried to gather some of the most used examples, I hope you find them useful ;-)

## 1- Regex Email Validation

Regex pattern that matches a valid email address.

**_Example:_** `name@domain.com` ➞ [https://regex101.com/r/1sIXyA/1](https://regex101.com/r/1sIXyA/1){:target="_blank"}{:target="_blank"}

```
/^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6})*$/
```

---

## 2- Regex URL Validation

Regex pattern that matches a valid URL starting with http or https.

**_Example:_** `https://www.domain.com/some-path` ➞ [https://regex101.com/r/gTO9nq/1](https://regex101.com/r/gTO9nq/1){:target="_blank"}{:target="_blank"}

```
/^(https?:\/\/)?([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5})(:[0-9]{1,5})?(\/.*)?$/
```

---

## 3- Regex Dates Validation

Regex pattern that matches a valid date in different formats.

## 3.1- Date Format YYYY-mm-dd

**_Example:_** `2001–10-25` ➞ [https://regex101.com/r/xZOOo9/1](https://regex101.com/r/xZOOo9/1){:target="_blank"}

```
/^([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))$/
```

## 3.2- Date Format dd-mm-YYYY

**_Example:_** `25–10-2001` ➞ [https://regex101.com/r/p4pFsm/1](https://regex101.com/r/p4pFsm/1){:target="_blank"}

```
/^((0[1-9]|[12]\d|3[01])-(0[1-9]|1[0-2])-[12]\d{3})$/
```

---

## 4- Regex Time Validation

Regex pattern that matches a valid time in different formats.

## 4.1- Time Format HH:mm AM/PM

**_Example:_** `11:45 PM` ➞ [https://regex101.com/r/vq9s8Z/1](https://regex101.com/r/vq9s8Z/1){:target="_blank"}

```
/^(1[0-2]|0?[1-9]):[0-5][0-9] (AM|PM)$/
```

## 4.1- Time Format hh:mm:ss

**_Example:_** `19:45:54` ➞ [https://regex101.com/r/cMqbxL/1](https://regex101.com/r/cMqbxL/1){:target="_blank"}

```
/^(0[0-9]|1[0-9]|2[1-4]):(0[0-9]|[1-5][0-9]):(0[0-9]|[1-5][0-9])$/
```

---

## 5- Regex Datetime Validation

Regex pattern that matches a valid datetime.

## 5.1- Datetime Format YYYY-mm-dd hh:mm:ss

**_Example:_** `2001–10-25 10:59:59` ➞ [https://regex101.com/r/GcnzIJ/1](https://regex101.com/r/GcnzIJ/1){:target="_blank"}

```
/^([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]) (0[0-9]|1[0-9]|2[1-4]):(0[0-9]|[1-5][0-9]):(0[0-9]|[1-5][0-9]))$/
```

## 5.2- Datetime Format dd-mm-YYYY hh:mm:ss

**_Example:_** `10–11-2001 10:59:59` ➞ [https://regex101.com/r/qfc0oc/1](https://regex101.com/r/qfc0oc/1){:target="_blank"}

```
/^((0[1-9]|[12]\d|3[01])-(0[1-9]|1[0-2])-[12]\d{3} (0[0-9]|1[0-9]|2[1-4]):(0[0-9]|[1-5][0-9]):(0[0-9]|[1-5][0-9]))$/
```

---

## 6- Regex UUID Validation

Regex pattern that matches a valid UUID (Universal Unique Identifier).

**_Example:_** `20354d7a-e4fe-47af-8ff6-187bca92f3f9` ➞ [https://regex101.com/r/ESgo7B/1](https://regex101.com/r/ESgo7B/1){:target="_blank"}

```
/^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$/
```

---

## 7- Regex IP Address Validation

Regex pattern that matches a valid IP Address version 4 and version 6.

## 7.1- IPv4 address

**_Example:_** `127.3.1.1` ➞ [https://regex101.com/r/6kWr5c/1](https://regex101.com/r/6kWr5c/1){:target="_blank"}

```
/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ 
```

## 7.2- IPv6 address

**_Example:_** `ee1a:5b37:e33f:811d:1cc8:3607:af73:1e23` ➞ [https://regex101.com/r/4yy1CE/1](https://regex101.com/r/4yy1CE/1){:target="_blank"}

```
/^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/
```

---


## 8- Regex File Validation

Regex pattern that matches a valid file path.

## 8.1- Absolute file path with extension

**_Example:_** `/some/path-to-fie/resource.zip` ➞ [https://regex101.com/r/3jdxKY/1](https://regex101.com/r/3jdxKY/1){:target="_blank"}

```
/^((\/|\\|\/\/|https?:\\\\|https?:\/\/)[a-z0-9_@\-^!#$%&+={}.\/\\\[\]]+)+\.[a-z]+$/
```

## 8.2- File with extension having 3 chars

**_Example:_** `resource.zip` ➞ [https://regex101.com/r/mRqdIg/1](https://regex101.com/r/mRqdIg/1){:target="_blank"}

```
/^[\w,\s-]+\.[A-Za-z]{3}$/
```

## 8.3- File with extension validation

**_Example:_** `resource.png` ➞ [https://regex101.com/r/Rj980C/1](https://regex101.com/r/Rj980C/1){:target="_blank"}

```
/^[\w,\s-]+\.(jpg|jpeg|png|gif|pdf)$/
```

---

## 9- Regex Password Strength Validation

Regex pattern matching a strength rules of the password.

## 9.1- Complex

Should have 1 lowercase letter, 1 uppercase letter, 1 number, 1 special character and be at least 8 characters long.

**_Example:_** `mYpa$$word123` ➞ [https://regex101.com/r/mAC0uS/1](https://regex101.com/r/mAC0uS/1){:target="_blank"}

```
/^(?=(.*[0-9]))(?=.*[\!@#$%^&*()\\[\]{}\-_+=~`|:;"'<>,.\/?])(?=.*[a-z])(?=(.*[A-Z]))(?=(.*)).{8,}$/
```

## 9.2- Moderate

Should have 1 lowercase letter, 1 uppercase letter, 1 number, and be at least 8 characters long.

**_Example:_** `passWord123` ➞ [https://regex101.com/r/7JBDjg/1](https://regex101.com/r/7JBDjg/1){:target="_blank"}

```
/^(?=(.*[0-9]))((?=.*[A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z]))^.{8,}$/
```

---

## 10- Regex Slug Validation

Regex pattern that matches a valid Slug.

**_Example:_** `some-valid-slug` ➞ [https://regex101.com/r/0Bo0eH/1](https://regex101.com/r/0Bo0eH/1){:target="_blank"}

```
/^[a-z0-9]+(?:-[a-z0-9]+)*$/
```
