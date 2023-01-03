# Typing Tutor
An [elm](http://elm-lang.org/) app to track your typing accuracy and WPM.

It's pretty rudimentary, but works!

## Backend API
There is backend api which uses [JSON Server](https://github.com/typicode/json-server).
On first use, copy across the database file:

```bash
cp api/db.example.json api/db.json
```

And to seed the database, run:

```bash
./api/seedTutor.sh
```

Then run the API server using:

```bash
node api/api.js
```


## Running
```bash
npm start
```
## Tests
and run the tests from the command line with:

```bash
npx elm-test
npx elm-test ./tests/SpecificFile.elm
```

## Todo
see [TODO](../master/TODO)


## License
MIT Licensed, see [LICENSE](../master/LICENSE) for more details.


## Credit
Inspired by the (most excellent and fully featured) online
typing site for progammers: [typing.io](https://typing.io)

Used (elm-webpack-starter)[https://github.com/simonh1000/elm-webpack-starter]
for webpack setup foo.
