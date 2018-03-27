port module Barcoder exposing (..)

import Html exposing (..)

import App.View exposing (..)
import Types exposing (..)

main : Program Never Model Msg
main =
    Html.program
        { init = initModelAndCommands
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


initModelAndCommands : ( Model, Cmd Msg )
initModelAndCommands =
    ( defaultModel, Cmd.none )


