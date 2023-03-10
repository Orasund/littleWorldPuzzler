module Game exposing (..)

import Card exposing (Card)
import Config
import Dict exposing (Dict)
import Random exposing (Generator)


type alias Game =
    { world : Dict ( Int, Int ) Card
    , selected : Maybe Card
    , deck : List Card
    , points : Int
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
    , deck =
        [ Card.Tree, Card.Tree, Card.Water, Card.Water, Card.Fire ]
    , points = 0
    }


runEnded : Game -> Bool
runEnded game =
    (game.deck == [])
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
                        { game
                            | selected = Just head
                            , deck = tail
                        }

                    [] ->
                        { game
                            | selected = Nothing
                            , deck = []
                        }
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
                            , points = game.points + List.length newCards
                        }
                            |> (\g ->
                                    if g |> runEnded then
                                        ( { g
                                            | world = Dict.empty
                                            , selected = Nothing
                                            , deck = []
                                            , points = g.points + Config.worldSize * Config.worldSize
                                          }
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
