module Data.Card exposing
    ( Card(..)
    , deck
    , list
    , name
    , number
    , toString
    )

import Dict exposing (Dict)


type Card
    = Plant
    | Stone
    | Mouse
    | Cat
    | Tree
    | Bear


list : List Card
list =
    --Also works as execution order for conflicting rules
    [ Plant, Stone, Mouse, Cat, Tree, Bear ]


number : Dict String Int
number =
    List.indexedMap
        (\i card ->
            ( toString card, i )
        )
        list
        |> Dict.fromList


deck : List Card
deck =
    [ Plant
    , Plant
    , Plant
    , Stone
    ]


toString : Card -> String
toString cellType =
    (case cellType of
        Plant ->
            '🌿'

        Stone ->
            '🪨'

        Mouse ->
            '🐭'

        Cat ->
            '🐱'

        Bear ->
            '🐺'

        Tree ->
            '🌳'
    )
        |> String.fromChar


name : Card -> String
name cellType =
    case cellType of
        Plant ->
            "Bush"

        Stone ->
            "Stone"

        Mouse ->
            "Mouse"

        Cat ->
            "Cat"

        Tree ->
            "Tree"

        Bear ->
            "Friend"
