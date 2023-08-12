module Data.CellType exposing
    ( CellType(..)
    , json
    , list
    , name
    , toInt
    , toString
    )

import Jsonstore exposing (Json)


type CellType
    = Wood
    | Water
    | Fire
    | Stone
    | Volcano
    | Fog
    | Desert
    | Glacier
    | Ice
    | Snow
    | Evergreen
    | Weed


list : List CellType
list =
    [ Snow, Desert, Fire, Glacier, Volcano, Stone, Evergreen, Ice, Fog, Water, Wood, Weed ]


fromInt : Int -> CellType
fromInt n =
    case n of
        1 ->
            Wood

        2 ->
            Water

        3 ->
            Fire

        4 ->
            Stone

        5 ->
            Volcano

        6 ->
            Fog

        7 ->
            Desert

        8 ->
            Glacier

        9 ->
            Ice

        10 ->
            Snow

        11 ->
            Evergreen

        12 ->
            Weed

        _ ->
            Wood


toInt : CellType -> Int
toInt cellType =
    case cellType of
        Wood ->
            1

        Water ->
            2

        Fire ->
            3

        Stone ->
            4

        Volcano ->
            5

        Fog ->
            6

        Desert ->
            7

        Glacier ->
            8

        Ice ->
            9

        Snow ->
            10

        Evergreen ->
            11

        Weed ->
            12


toString : CellType -> String
toString cellType =
    String.fromChar <|
        case cellType of
            Wood ->
                '🌳'

            Water ->
                '🌊'

            Fire ->
                '🔥'

            Stone ->
                '⛰'

            Volcano ->
                '🌋'

            Fog ->
                '☁'

            Desert ->
                '🏜'

            Glacier ->
                '🏔'

            Ice ->
                '❄'

            Snow ->
                '⛄'

            Evergreen ->
                '🌲'

            Weed ->
                '🌿'


name : CellType -> String
name cellType =
    case cellType of
        Wood ->
            "Wood"

        Water ->
            "Water"

        Fire ->
            "Fire"

        Stone ->
            "Stone"

        Volcano ->
            "Volcano"

        Fog ->
            "Fog"

        Desert ->
            "Desert"

        Glacier ->
            "Glacier"

        Ice ->
            "Ice"

        Snow ->
            "Snow"

        Evergreen ->
            "Evergreen Tree"

        Weed ->
            "Weed"



{------------------------
   Json
------------------------}


json : Json CellType
json =
    Jsonstore.int
        |> Jsonstore.map
            fromInt
            toInt
