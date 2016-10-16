module Tests exposing (..)

import Chunk exposing (Chunk, Status(..))
import Expect
import Script exposing (Script)
import Test exposing (..)
import TestChunk
import TestScript


all : Test
all =
    describe "Tests"
        [ TestScript.script
        , TestChunk.chunk
        ]
