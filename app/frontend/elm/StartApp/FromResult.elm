module StartApp.FromResult where

import Task
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Signal exposing (Signal, Mailbox)
import StartApp
import Effects exposing (Never, Effects)


type alias Config model action error =
    { init : Result error (model, Effects action)
    , update : action -> model -> (model, Effects action)
    , viewSuccess : Signal.Address action -> model -> Html
    , viewError : error -> Html
    , inputs : List (Signal.Signal action)
    }


start : Config model action error -> StartApp.App (Result error model)
start config =
    case config.init of
        Ok tuple ->
            let
                app =
                    StartApp.start <|
                        StartApp.Config
                            tuple
                            config.update
                            config.viewSuccess
                            config.inputs
            in
                { app | model = Signal.map Ok app.model }

        Err error ->
            { html  = Signal.constant (config.viewError error)
            , model = Signal.constant (Err error)
            , tasks = Signal.constant (Task.succeed ())
            }
