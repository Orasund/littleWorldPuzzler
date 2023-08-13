module Data.Card exposing
    ( Card(..)
    , deck
    , list
    , name
    , toString
    )


type Card
    = Water
    | Plant
    | Cactus
    | Wood
    | Stone
    | Worm
    | Lake
    | Fire
    | Mountain
    | Volcano
    | Glacier
    | Ice
    | Snow
    | Evergreen
    | Weed


list : List Card
list =
    --Also works as execution order for conflicting rules
    [ Snow, Fire, Glacier, Volcano, Mountain, Evergreen, Ice, Lake, Wood, Weed, Water, Plant, Cactus, Stone, Worm ]


deck : List Card
deck =
    [ Plant
    , Plant
    , Plant
    , Water
    , Stone
    , Fire
    ]


toString : Card -> String
toString cellType =
    String.fromChar <|
        case cellType of
            Water ->
                '💧'

            Plant ->
                '🌱'

            Cactus ->
                '🌵'

            Wood ->
                '🌳'

            Stone ->
                '🪨'

            Worm ->
                '🪱'

            Lake ->
                '🌊'

            Fire ->
                '🔥'

            Mountain ->
                '⛰'

            Volcano ->
                '🌋'

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


name : Card -> String
name cellType =
    case cellType of
        Water ->
            "Water"

        Plant ->
            "Plant"

        Cactus ->
            "Dead Leafs"

        Wood ->
            "Wood"

        Stone ->
            "Stone"

        Worm ->
            "Worm"

        Lake ->
            "Lake"

        Fire ->
            "Fire"

        Mountain ->
            "Stone"

        Volcano ->
            "Volcano"

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
