module Game exposing (..)

import Card exposing (Card)
import Config
import Dict exposing (Dict)
import Pack exposing (Pack)
import Random exposing (Generator)
import Round exposing (Round, drawCard)


type alias Game =
    { round : Maybe Round
    , totalPoints : Int
    }


type Overlay
    = GameWon { score : Int }
    | GameLost


type Effect
    = OpenOverlay Overlay


init : Game
init =
    { round = Nothing
    , totalPoints = 0
    }


wonGame : Game -> Game
wonGame game =
    game.round
        |> Maybe.map
            (\round ->
                { game
                    | totalPoints = game.totalPoints + round.points
                    , round = Nothing
                }
            )
        |> Maybe.withDefault game


swapCards : Game -> Generator Game
swapCards game =
    game.round
        |> Maybe.map Round.swapCards
        |> Maybe.map
            (\round ->
                if round.backpack == Nothing || round.selected == Nothing then
                    Round.drawCard round

                else
                    Random.constant round
            )
        |> Maybe.map (Random.map (\round -> { game | round = Just round }))
        |> Maybe.withDefault (Random.constant game)


buyPack : Pack -> Game -> Maybe (Generator Game)
buyPack pack game =
    if game.totalPoints >= Pack.price pack then
        Round.new pack
            |> Round.drawCard
            |> Random.map
                (\round ->
                    { game
                        | round = round |> Just
                        , totalPoints = game.totalPoints - Pack.price pack
                    }
                )
            |> Just

    else
        Nothing


placeCard : ( Int, Int ) -> Game -> Generator ( Game, List Effect )
placeCard pos game =
    game.round
        |> Maybe.andThen
            (\round ->
                round.selected
                    |> Maybe.map
                        (\card ->
                            round
                                |> Round.tick
                                |> Round.placeCard pos card
                        )
            )
        |> Maybe.map
            (\round ->
                if round.turns <= 0 then
                    ( wonGame { game | round = Just round }
                    , [ GameWon { score = round.points }
                            |> OpenOverlay
                      ]
                    )
                        |> Random.constant

                else if round |> Round.roundEnded then
                    ( { game
                        | round = Nothing
                      }
                    , [ OpenOverlay GameLost ]
                    )
                        |> Random.constant

                else
                    round
                        |> Round.drawCard
                        |> Random.map (\it -> ( { game | round = Just it }, [] ))
            )
        |> Maybe.withDefault (Random.constant ( game, [] ))
