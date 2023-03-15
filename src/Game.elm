module Game exposing (..)

import Card exposing (Card)
import Config
import Dict exposing (Dict)
import Pack exposing (Pack)
import Random exposing (Generator)


type alias Game =
    { world : Dict ( Int, Int ) Card
    , selected : Maybe Card
    , backpack : Maybe Card
    , deck : List Card
    , points : Int
    , turns : Int
    }


type Effect
    = OpenShop


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


init : Game
init =
    { world = Dict.empty
    , selected = Nothing
    , backpack = Nothing
    , deck = Pack.cards Pack.ForestFire
    , points = 0
    , turns = 0
    }


clearRound : Game -> Game
clearRound game =
    { game
        | world = Dict.empty
        , selected = Nothing
        , backpack = Nothing
        , deck = []
        , turns = 0
    }


runEnded : Game -> Bool
runEnded game =
    (game.deck == [] && game.selected == Nothing && game.backpack == Nothing)
        || (game.turns > Config.maxTurns)
        || (List.range 0 (Config.worldSize - 1)
                |> List.concatMap
                    (\x ->
                        List.range 0 (Config.worldSize - 1)
                            |> List.map (Tuple.pair x)
                    )
                |> List.all (\p -> Dict.get p game.world /= Nothing)
           )


drawCard : Game -> Generator Game
drawCard game =
    game.deck
        |> shuffle
        |> Random.map
            (\list ->
                case list of
                    head :: tail ->
                        if game.selected == Nothing then
                            { game
                                | selected = Just head
                                , deck = tail
                            }

                        else if game.backpack == Nothing then
                            { game | backpack = Just head, deck = tail }

                        else
                            game

                    [] ->
                        if game.backpack /= Nothing then
                            { game | backpack = Nothing, selected = game.backpack }

                        else
                            game
            )


swapCards : Game -> Generator Game
swapCards game =
    { game
        | selected = game.backpack
        , backpack = game.selected
    }
        |> (if game.backpack == Nothing then
                drawCard

            else
                Random.constant
           )


buyCard : Card -> Game -> Game
buyCard card game =
    if game.points >= Card.price card then
        { game
            | deck = game.deck ++ [ card ]
            , points = game.points - Card.price card
        }

    else
        game


buyPack : Pack -> Game -> Game
buyPack pack game =
    if game.points >= Pack.price pack then
        { game
            | deck = game.deck ++ Pack.cards pack
            , points = game.points - Pack.price pack
        }

    else
        game


neighborsOf : ( Int, Int ) -> List ( Int, Int )
neighborsOf ( x, y ) =
    [ ( x + 1, y ), ( x, y + 1 ), ( x, y - 1 ), ( x - 1, y ) ]


tick : Dict ( Int, Int ) Card -> ( Dict ( Int, Int ) Card, List Card )
tick world =
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
                                            |> (\( maybeCard, fun ) ->
                                                    if fun neighbors then
                                                        maybeCard

                                                    else
                                                        Just card
                                               )
                                    )
                            , newCards
                                ++ (Card.produces card
                                        |> (\( newCard, fun ) ->
                                                if fun neighbors then
                                                    [ newCard ]

                                                else
                                                    []
                                           )
                                   )
                            )
                       )
            )
            ( world, [] )


placeCard : ( Int, Int ) -> Game -> Generator ( Game, List Effect )
placeCard pos game =
    case game.selected of
        Just card ->
            game.world
                |> Dict.insert pos card
                |> tick
                |> (\( world, newCards ) ->
                        { game
                            | world = world
                            , deck = game.deck ++ newCards
                            , selected = Nothing
                            , points = game.points + List.length newCards
                            , turns = game.turns + 1
                        }
                            |> (\g ->
                                    if g |> runEnded then
                                        ( { g
                                            | points = g.points + Config.worldSize * Config.worldSize
                                          }
                                            |> clearRound
                                        , [ OpenShop ]
                                        )
                                            |> Random.constant

                                    else
                                        g
                                            |> drawCard
                                            |> Random.map (\it -> ( it, [] ))
                               )
                   )

        Nothing ->
            Random.constant ( game, [] )
