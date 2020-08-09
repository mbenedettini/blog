---
title: Bluebird Promise.each and error propagation in promises
author: Mariano Benedettini
date: 2016-10-25
hero: 
excerpt: Avoid promises rejections bubble up 
---

[Bluebird](http://bluebirdjs.com/) `Promise.each` is one of the most powerful functions that great library has. It allows you to sequentially run an async operation on an array. This way you can be sure only one element of an array will be processed at a time.

However, Bluebird docs are not outstanding and frankly quite confusing sometimes.

Here’s an example of a loop through an array and execution of an async operation for each element. A successfully resolved promise will be returned for odd numbers and a rejected one for even:


```javascript
const Promise = require(‘bluebird’);

let processed = [];
Promise.each([1, 2, 3], n => {
  console.log(`Processing ${n}`);
  processed.push(n);
  if (n % 2) {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve(n);
      }, 250);
    });
  } else {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        reject(new Error(`stopped at ${n}`));
      }, 250);
    });
  }
}).then(success => {
  console.log(‘Successfully processed all numbers’);
}, error => {
  console.error(`Failed: ${error}`);
  console.log(`Processed: ${processed}`);
});

```

Running that piece of code shows us that the numbers are sequentially processed and also one other important thing: Promise.each will stop at the first failed Promise.

```shell
$ node each-test.js
Processing 1
Processing 2
Failed: Error: stopped at 2
Processed: 1,2

```


What if we want the loop to continue regardless each promise resolution? Easy, we should catch any possible error inside the loop, without allowing those errors to propagate to Promise.each:


```javascript
const Promise = require(‘bluebird’);

let processed = [];
Promise.each([1, 2, 3], n => {
  console.log(`Processing ${n}`);
  processed.push(n);
  if (n % 2) {
      return new Promise((resolve, reject) => {
          setTimeout(() => {
              resolve(n);
          }, 250);
      });
  } else {
      return new Promise((resolve, reject) => {
          setTimeout(() => {
              reject(new Error(`stopped at ${n}`));
          }, 250);
      }).catch(error => {
          console.log(`Caught ${error} but not propagating it`);
      });
  }
}).then(success => {
  console.log(‘Successfully processed all numbers’);
}, error => {
  console.error(`Failed: ${error}`);
  console.log(`Processed: ${processed}`);
});
```

Now the snippet with the added `catch` show that the loop failed at 2 but continued anyway with the next item:

```shell
Processing 1
Processing 2
Caught Error: stopped at 2 but not propagating it
Processing 3
Successfully processed all numbers
```

Exercise for the reader: what if we wanted to log the error inside the loop (line 19) but propagate it so that the loop won’t continue?
