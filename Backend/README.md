# Charter—backend

This is a happy-go-lucky collection of (mostly Node) scripts that run the backend for the Charter iOS app.

## Getting started

> This is probably not ready for other people to run yet. You’re welcome to try, it’s just not fully formed. At this stage, these are mainly instructions for myself.

## Overview

### Set up

I’ve been running the backend on DigitalOcean, but it should work anywhere.

**Requirements**

- node, >4.0
- npm
- forever
- MongoDB
- Java 8
- RESTHeart

### Getting it running

The general idea behind the backend is this: import archival data from lists.swift.org into a MongoDB database. Then set up a mail listener that’ll listen for new emails from the mailing lists and add those to the database. Then start up the web server (which at this stage is just a REST wrapper around MongoDB).

Getting a Charter backend instance involves:

- Generating the archival email JSON that you want to import from the archives on lists.swift.org (this is done with the iOS/MailingListToJSON app).
- Importing that JSON to MongoDB on the server: `mongoimport --db charter --collection emails --type json --file emails.json --jsonArray --upsert`
- Running the database reformatting script, `node db-format.js`
- Creating indexes on the database, `db.emails.createIndex({date: 1})`
- Run the mail listener script with `forever start mail.js` (note that you have to be subscribed to the Swift mailing lists and have your DNS set up correctly for [mailin.io](http://mailin.io/doc))
- After the first email comes in, manuall find and set its archiveURL to be correct (emails that come in after it will have their archiveURL determined by this document). This has to occur after the first email in case there is a large time gap between importing from the archives and when we start our mail listener.

  ```js
  db.emails.update({
    archiveURL: 'old_url'}, { $set: {
    archiveURL: 'new_url'}
  })
  ```

- Run the web server, `forever start -c sh run-server.sh`

```sh
java -server -jar ~/restheart-1.1.5/restheart.jar ~/restheart-1.1.5/etc/restheart.yml
```

### Notes to myself

**Subscribe to the lists**

Make sure you’re actually subscribed to the Swift mailing lists with DNS set up so that you’ll receive the messages to your server instance

**Install forever**

`sudo npm install -g forever`

**RESTHeart config**

[Adapted from the RESTHeart docs](https://softinstigate.atlassian.net/wiki/display/RH/Installation+and+Setup#InstallationandSetup-auth-with-jep).

Create a user that has read permission on the emails database to use with RESTHeart.

```
> use admin
> db.createUser({
    user: "db_username",
    pwd: "db_password",
    roles:[ {role: "read", db: "charter" }]
})
```

Set the following line in `restheart/etc/restheart.yml` to connect with that user

```
mongo-uri: mongodb://db_username:db_password@127.0.0.1/?authSource=admin
```

Add some HTTP Basic Auth security (note that this is different to the database user you set up above) in `restheart/etc/security.yml`.

```
## Configuration for file based Identity Manager
users:
    - userid: some_REST_user
      password: some_REST_password
      roles: [users]
```

```
# Users with role 'users' can GET any collection or document resource (excluding dbs)
permissions:
    - role: users
      predicate: regex[pattern="/.*/.*", value="%R", full-match=true] and method[value="GET"]
```

Start the server with the config file: `java -server -jar restheart.jar etc/restheart.yml `
