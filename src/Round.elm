module Round exposing (..)

import Card exposing (Card)
import Config
import Deck exposing (Deck)
import Dict exposing (Dict)
import Random exposing (Generator)


type alias CardId =
    Int


type alias Round =
    { cards : Dict CardId Card
    , nextCardId : CardId
    , world : Dict ( Int, Int ) Card
    , selected : Maybe CardId
    , backpack : Maybe CardId
    , deck : List CardId
    , pack : Deck
    , points : Int
    , turns : Int
    }


shuffle : List a -> Generator (List a)
shuffle list =
    Random.list (List.length list) (Random.float 0 1)
        |> Random.map
            (\randomList ->
                randomList
                    |> List.map2 Tuple.pair list
                    |> List.sortBy Tuple.second
                    |> List.map Tuple.first
            )


new : Deck -> Round
new pack =
    let
        cards =
            Deck.cards pack
                |> List.indexedMap Tuple.pair
                |> Dict.fromList
    in
    { cards = cards
    , nextCardId = Dict.size cards
    , world = Dict.empty
    , selected = Nothing
    , backpack = Nothing
    , deck = Dict.keys cards
    , turns = Deck.surviveTurns pack
    , pack = pack
    , points = 0
    }


getBackpack : Round -> Maybe ( CardId, Card )
getBackpack round =
    round.backpack
        |> Maybe.andThen
            (\cardId ->
                round.cards
                    |> Dict.get cardId
                    |> Maybe.map (Tuple.pair cardId)
            )


getSelected : Round -> Maybe ( CardId, Card )
getSelected round =
    round.selected
        |> Maybe.andThen
            (\cardId ->
                round.cards
                    |> Dict.get cardId
                    |> Maybe.map (Tuple.pair cardId)
            )


getDeck : Round -> List ( CardId, Card )
getDeck round =
    round.deck
        |> List.filterMap
            (\cardId ->
                Dict.get cardId round.cards
                    |> Maybe.map (Tuple.pair cardId)
            )


roundEnded : Round -> Bool
roundEnded game =
    (game.deck == [] && game.selected == Nothing && game.backpack == Nothing)
        || (game.turns <= 0)
        || (List.range 0 (Config.worldSize - 1)
                |> List.concatMap
                    (\x ->
                        List.range 0 (Config.worldSize - 1)
                            |> List.map (Tuple.pair x)
                    )
                |> List.all (\p -> Dict.get p game.world /= Nothing)
           )


addCard : Card -> Round -> Round
addCard card round =
    { round
        | cards =
            round.cards
                |> Dict.insert round.nextCardId card
        , nextCardId = round.nextCardId + 1
        , deck = round.nextCardId :: round.deck
    }


drawCard : Round -> Generator Round
drawCard game =
    game.deck
        |> shuffle
        |> Random.andThen
            (\list ->
                case list of
                    head :: tail ->
                        if game.selected == Nothing then
                            { game
                                | selected = game.backpack
                                , backpack = Just head
                                , deck = tail
                            }
                                |> (if game.backpack == Nothing then
                                        drawCard

                                    else
                                        Random.constant
                                   )

                        else
                            Random.constant game

                    [] ->
                        if game.selected == Nothing then
                            { game | backpack = Nothing, selected = game.backpack }
                                |> Random.constant

                        else
                            Random.constant game
            )


swapCards : Round -> Round
swapCards round =
    { round
        | selected = round.backpack
        , backpack = round.selected
    }


neighborsOf : ( Int, Int ) -> List ( Int, Int )
neighborsOf ( x, y ) =
    [ ( x + 1, y ), ( x, y + 1 ), ( x, y - 1 ), ( x - 1, y ) ]


updateWorld : Dict ( Int, Int ) Card -> ( Dict ( Int, Int ) Card, List Card )
updateWorld world =
    world
        |> Dict.foldl
            (\pos card ( output, newCards ) ->
                pos
                    |> neighborsOf
                    |> List.filterMap (\p -> world |> Dict.get p)
                    |> (\neighbors ->
                            ( output
                                |> Dict.update pos
                                    (\_ ->
                                        Card.transform card
                                            |> (\( maybeCard, exp ) ->
                                                    if Card.isValidNeighborhoods neighbors exp then
                                                        maybeCard

                                                    else
                                                        Just card
                                               )
                                    )
                            , newCards
                                ++ (Card.produces card
                                        |> (\( newCard, exp ) ->
                                                if Card.isValidNeighborhoods neighbors exp then
                                                    [ newCard ]

                                                else
                                                    []
                                           )
                                   )
                            )
                       )
            )
            ( world, [] )


tick : Round -> Round
tick round =
    round.world
        |> updateWorld
        |> (\( world, newCards ) ->
                newCards
                    |> List.foldl
                        addCard
                        { round
                            | world = world
                            , points = round.points + List.length newCards
                        }
           )


endTurn : Round -> Round
endTurn round =
    { round
        | selected = Nothing
        , turns = round.turns - 1
    }


placeSelected : ( Int, Int ) -> Round -> Maybe Round
placeSelected pos round =
    round
        |> getSelected
        |> Maybe.map
            (\( _, card ) ->
                { round | world = round.world |> Dict.insert pos card }
            )
