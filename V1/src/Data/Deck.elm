module Data.Deck exposing
    ( Deck
    , Selected(..)
    , addToDiscard
    , first
    , fromList
    , generator
    , playFirst
    , playSecond
    , played
    , remaining
    , second
    , shuffle
    )

import Data.CellType exposing (CellType(..))
import Random exposing (Generator)
import Random.List as RandomList


type Selected
    = First
    | Second


type alias Deck =
    { remaining : List CellType
    , current : CellType
    , played : List CellType
    }


generator : Generator Deck
generator =
    [ Wood
    , Wood
    , Wood
    , Wood
    , Water
    , Water
    , Water
    , Water
    , Stone
    , Fire
    ]
        |> fromList
        |> shuffle


fromList : List CellType -> Deck
fromList list =
    case list of
        head :: tail ->
            { remaining = tail
            , current = head
            , played = []
            }

        [] ->
            { remaining = []
            , current = Wood
            , played = []
            }


remaining : Deck -> List CellType
remaining =
    .remaining


played : Deck -> List CellType
played =
    .played


first : Deck -> CellType
first =
    .current


second : Deck -> Maybe CellType
second deck =
    deck.remaining
        |> List.head


playFirst : Deck -> Maybe Deck
playFirst deck =
    case deck.remaining of
        head :: tail ->
            { current = head
            , remaining = tail
            , played = deck.current :: deck.played
            }
                |> Just

        [] ->
            Nothing


playSecond : Deck -> Maybe Deck
playSecond deck =
    case deck.remaining of
        head :: tail ->
            { deck
                | remaining = tail
                , played = head :: deck.played
            }
                |> Just

        [] ->
            Nothing


addToDiscard : CellType -> Deck -> Deck
addToDiscard cellType deck =
    { deck | played = cellType :: deck.played }


shuffle : Deck -> Generator Deck
shuffle deck =
    deck.current
        :: deck.remaining
        ++ deck.played
        |> RandomList.shuffle
        |> Random.map fromList
