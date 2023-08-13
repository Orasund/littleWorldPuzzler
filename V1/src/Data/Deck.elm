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

import Data.Card exposing (Card(..))
import Random exposing (Generator)
import Random.List as RandomList


type Selected
    = First
    | Second


type alias Deck =
    { remaining : List Card
    , current : Card
    , played : List Card
    }


generator : Generator Deck
generator =
    [ Wood
    , Wood
    , Wood
    , Wood
    , Lake
    , Lake
    , Lake
    , Lake
    , Stone
    , Fire
    ]
        |> fromList
        |> shuffle


fromList : List Card -> Deck
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


remaining : Deck -> List Card
remaining =
    .remaining


played : Deck -> List Card
played =
    .played


first : Deck -> Card
first =
    .current


second : Deck -> Maybe Card
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


addToDiscard : Card -> Deck -> Deck
addToDiscard cellType deck =
    { deck | played = cellType :: deck.played }


shuffle : Deck -> Generator Deck
shuffle deck =
    deck.current
        :: deck.remaining
        ++ deck.played
        |> RandomList.shuffle
        |> Random.map fromList
