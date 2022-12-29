# Typing Tutor

An example app in [elm](http://elm-lang.org/) - tracks your typing.

It's pretty rudimentary at the moment (and may stay that way) as it's more
something to play with to learn-me-some-elm than a thing in itself.  I'll
keep working on it whilst it's fun tho.


## Running

```bash
npm run dev
```

## Back end API

The back end api is currently using [JSON Server](https://github.com/typicode/json-server).
On first use, copy across the database file:

```bash
cp api/db.example.json api/db.json
```

Then run the API server using:

```bash
node api/api.js
```

And to seed the database, run:

```bash
./api/seedTutor.sh
```

## Tests

There are tests - using elm-test - install this (globally) by:

```bash
npm install -g elm-test
```

and run the tests from the command line with:

```bash
elm-test
```

## Todo

see [TODO](../master/TODO)


## License

MIT Licensed, see [LICENSE](../master/LICENSE) for more details.


## Credit

Inspired by the (most excellent and fully featured) online
typing site for progammers: [typing.io](https://typing.io)
