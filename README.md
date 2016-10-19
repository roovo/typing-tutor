# Typing Tutor

An example app in [elm](http://elm-lang.org/) - tracks your typing.

It's pretty rudimentary at the moment (and may stay that way) as it's more
something to play with to learn-me-some-elm than a thing in itself.  I'll
keep working on it whilst it's fun tho.

## Running

It's all in the front end at the moment and I'm using (the excellent)
[elm-live](https://github.com/tomekwi/elm-live) to run things whilst
developing.  To install this locally:

```
> npm install elm-live
```

then to run the project:

```
> ./node_modules/.bin/elm-live src/Main.elm
```


## Tests

There are tests - using elm-test - install this (globally) by:

```
> npm install -g elm-test
```

and run the tests from the command line with:

```
> elm-test
```

## Todo

see [TODO](../master/TODO)

## License

MIT Licensed, see [LICENSE](../master/LICENSE) for more details.


## Reading

Some links for reference whilst developing
  * https://www.speedtypingonline.com/typing-equations
  * http://prismjs.com/
    - `Prism.tokenize(text, grammar)` #=> An array of strings, tokens (class Prism.Token) and other arrays


