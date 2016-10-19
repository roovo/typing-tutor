reading
=======

http://prismjs.com/

    - Prism.tokenize(text, grammar) #=> An array of strings, tokens (class Prism.Token) and other arrays


https://www.speedtypingonline.com/typing-equations


project setup
=============

# use elm-live - puts it in ./node_modules
> npm install elm-live

# new elm project
> elm make
> mkdir src
> vim src/Main.elm        # and put some stuf in it: Html.text "foo"

# run elm-live
> ./node_modules/.bin/elm-live src/Main.elm

# install elm-test
> npm install -g elm-test         # if you haven't already
> elm-test init
> elm-test                        # run the tests
