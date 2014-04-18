riak-ruby-ca
============

certificate generating tool for riak ruby client testing

## prerequisites

* openssl command-line tool
* rake

## the basics

1. `rake server:sign`
2. put `server.key`, `server.crt`, and `ca.crt` on your riak and configure them
3. put `ca.crt` on your client

## the caveats

* 2048-bit keys. Too slow for development, possibly okay for production.
* The key/subject metadata is something you should change.
