module Game exposing (..)

import Deck exposing (Deck)
import Random exposing (Generator)
import Round exposing (Round)


type alias Game =
    { round : Maybe Round
    , totalPoints : Int
    }


type Effect
    = GameWon { score : Int, deck : Deck }
    | GameLost { turnsLeft : Int }


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


buyPack : Deck -> Game -> Maybe (Generator Game)
buyPack pack game =
    if game.totalPoints >= Deck.price pack then
        Round.new pack
            |> Round.drawCard
            |> Random.map
                (\round ->
                    { game
                        | round = round |> Just
                        , totalPoints = game.totalPoints - Deck.price pack
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
                round
                    |> Round.tick
                    |> Round.placeSelected pos
            )
        |> Maybe.map Round.endTurn
        |> Maybe.map
            (\round ->
                if round.turns <= 0 then
                    ( wonGame { game | round = Just round }
                    , [ GameWon
                            { score = round.points
                            , deck = round.pack
                            }
                      ]
                    )
                        |> Random.constant

                else if round |> Round.roundEnded then
                    ( { game
                        | round = Nothing
                      }
                    , [ GameLost { turnsLeft = round.turns } ]
                    )
                        |> Random.constant

                else
                    round
                        |> Round.drawCard
                        |> Random.map (\it -> ( { game | round = Just it }, [] ))
            )
        |> Maybe.withDefault (Random.constant ( game, [] ))
