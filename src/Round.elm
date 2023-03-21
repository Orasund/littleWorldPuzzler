module Round exposing (..)

import Card exposing (Card)
import Config
import Dict exposing (Dict)
import Pack exposing (Pack)
import Random exposing (Generator)


type alias Round =
    { world : Dict ( Int, Int ) Card
    , selected : Maybe Card
    , backpack : Maybe Card
    , deck : List Card
    , pack : Pack
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


new : Pack -> Round
new pack =
    { world = Dict.empty
    , selected = Nothing
    , backpack = Nothing
    , deck = Pack.cards pack
    , turns = Pack.surviveTurns pack
    , pack = pack
    , points = 0
    }


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
                { round
                    | world = world
                    , selected = Nothing
                    , turns = round.turns - 1
                    , deck = round.deck ++ newCards
                    , points = round.points + List.length newCards
                }
           )


placeCard : ( Int, Int ) -> Card -> Round -> Round
placeCard pos card round =
    { round | world = round.world |> Dict.insert pos card }
