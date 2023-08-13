module Data.Card exposing
    ( Card(..)
    , deck
    , list
    , name
    , toString
    )


type Card
    = Plant
    | Stone
    | Mouse
    | Cat
    | Tree
    | Bear
      --Old
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
    [ Snow, Fire, Glacier, Volcano, Mountain, Evergreen, Ice, Lake, Weed, Plant, Stone, Mouse, Cat, Tree, Bear ]


deck : List Card
deck =
    [ Plant
    , Plant
    , Plant
    , Plant
    , Plant
    , Plant
    , Plant
    , Stone
    , Stone
    , Stone
    ]


toString : Card -> String
toString cellType =
    String.fromChar <|
        case cellType of
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

            --Old
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
            "Bear"

        --Old
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
