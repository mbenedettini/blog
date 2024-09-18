---
title: Postgres migrations in Loopback v2
author: Mariano Benedettini
pubDatetime: 2017-02-27
hero: 
excerpt: Painless migrations? Yes, it's possible. 
description: ""
---

After going through the very well known cycle of denial, frustration, depression I finally accepted that the both libraries I was using to manage migrations in my Loopback projects were just awful.

I’m talking about [loopback-db-migrate](https://github.com/slively/loopback-db-migrate) and [loopback-component-migrate](https://github.com/fullcube/loopback-component-migrate), which suffer from a wide range of problems that I don’t want to remember, but of which I do recall the last one (I’m not sure to which one belongs, though): the down operation won’t accept a parameter indicating up to which migration perform the operation, therefore it will just perform a down operation for ALL OF THEM (at least that’s what happened to me).

The key was to realize that any migration framework with support for PostgreSQL would do it, because access to Loopback models could be easily given. Then I’ve decided to give [node-db-migrate](https://github.com/db-migrate/node-db-migrate) a try, which has support for Postgres and many other database engines.

I’ve started by installing it along with its pg module:

```shell
$ npm install --save db-migrate db-migrate-pg

```

Then I’ve added a file to hold its config. I’ve named it `migrate-database.json` and placed it under `server/`:


#### **`migrate-database.json`**
```json
{
    "defaultEnv": {"ENV": "NODE_ENV"},
    "development": {
        "driver": "pg",
        "user": {
            "ENV": "DB_USERNAME"
        },
        "password": {
            "ENV": "DB_PASSWORD"
        },
        "host": {
            "ENV": "DB_HOST"
        },
        "database": {
            "ENV": "DB_DATABASE"
        }
    }
}
```

As you probably have already realized, it just contains references to environment variables actually holding database credentials, name and host.

I mentioned earlier that access to Loopback models should be given inside our migration scripts, and that involves a few lines because Loopback requires to be booted. I use in my projects a loopback-init module that does that and also provides a stop() function to make sure we disconnect from every database (in some projects I use both Postgres and MongoDB), which I usually place in a directory lib/ located at the root of my project and I also use it from scripts:


#### **`loopback-init.js`**
```javascript
const loopback = require('loopback');
const boot = require('loopback-boot');

const logger = require('logger');

const app = loopback();
// This module resides in /lib so we should boot project from ../server
boot(app, __dirname + '/../server');

logger.debug('Loopback initialized');

app.stop = function () {
    // Disconnect from every data source
    Object.keys(app.dataSources).forEach(name => {
        let d = app.dataSources[name];
        if (typeof d.disconnect === 'function') {
            d.disconnect();
        }
    });
};

module.exports = app;

```

At this point we should be able to create our first migration:


`$ node node_modules/db-migrate/bin/db-migrate --config server/migrate-database.json create example-migration`


Which could look something like:


#### **`20170228221102-example-migration.js`**
```javascript
'use strict';

let dbm;
let type;
let seed;

const Promise = require('bluebird');
/* logger is a simple logging module that can be found here 
    https://gist.github.com/mbenedettini/a93ad95cbc352a3afd9ad7193af563d7 */
const logger = require('logger');
const app = require('loopback-init');

/**
  * We receive the dbmigrate dependency from dbmigrate initially.
  * This enables us to not have to rely on NODE_PATH.
  */
exports.setup = function(options, seedLink) {
    dbm = options.dbmigrate;
    type = dbm.dataType;
    seed = seedLink;
};

exports.up = async function(db) {
  const users = await app.models.MyUser.find();
  await Promise.each(users, user => {
    user.name = 'Joe';
    return user.save();
  });
  app.stop();
};

exports.down = function(db) {
    return null;
};

exports._meta = {
    "version": 1
};
```

**– Remember this is just an example, a proper down section should be always written! –**


and when we run it:


```shell

$ node node_modules/db-migrate/bin/db-migrate --config server/migrate-database.json up
[INFO] Processed migration 20170228221102-example-migration
[INFO] Done
```

You will notice that a new table migrations was automatically created to hold a list of already run migrations.

As a final step an npm command could be introduced to easily run migrations, within the scripts section of our `package.json`:

```json

"migrate": "node node_modules/db-migrate/bin/db-migrate --config server/migrate-database.json"

```

That’s pretty much it! I’m really happy with having getting rid of those horrible libraries and moved to a clean and mature tool such as [node-db-migrate](https://github.com/db-migrate/node-db-migrate).

I’d love to hear your thoughts, feel free to leave your comments and questions!
