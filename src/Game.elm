module Game exposing (..)

import Card exposing (Card)
import Dict exposing (Dict)


type alias Game =
    { world : Dict ( Int, Int ) Card
    , deck : List Card
    , points : Int
    }


init : Game
init =
    { world = Dict.empty
    , deck = [ Card.Tree, Card.Water, Card.Fire ]
    , points = 0
    }


buyCard : Card -> Game -> Game
buyCard card game =
    if game.points >= Card.price card then
        { game
            | deck = game.deck ++ [ card ]
            , points = game.points - Card.price card
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


placeCard : ( Int, Int ) -> Game -> Game
placeCard pos game =
    case game.deck of
        card :: deck ->
            game.world
                |> Dict.insert pos card
                |> tick
                |> (\( world, newCards ) ->
                        { game
                            | world = world
                            , deck = deck ++ newCards
                            , points = game.points + List.length newCards
                        }
                   )

        [] ->
            game
