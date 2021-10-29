# w000t

[![Build Status](https://travis-ci.org/odwrtw/w000t.svg?branch=master)](https://travis-ci.org/odwrtw/w000t)

![w000t it!](https://w000t.me/51e46581c7)

* Shorten all your URLs
* Tag them if you want
* Keep them private or make them public
* Be amazed by your w000t wall

## Running server locally

1. Clone repository `git clone git@github.com:odwrtw/w000t.git && cd odwrtw`
2. Install [mongodb](https://docs.mongodb.com/manual/administration/install-community/), [redis](https://redis.io/topics/quickstart), [nodejs](https://nodejs.org/en/download/)
3. Install `bower` and components
```
npm install -g bower
bower install
```
4. Install gems `bundle install`
5. Create database and run migrations `bundle exec rails db:create && bundle exec rails db:migrate && bundle exec rails db:seed`
6. Run server `bundle exec rails server -p 4000`
7. Open application link `http://localhost:4000/`

## Running tests
Run `bundle exec rspec spec`