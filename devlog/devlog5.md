# Devlog 5 - Introducing Randomness

Sofar each game was the same. Today we want to add randomness to the game.


To shuffle the deck, we use the `List.sortBy` function to randomly rearrange it.

```
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
```

Next we add a new field `selected` that contains the drawn card. With that we can adjust the `drawCard` function:

```
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
```

## Fetching the initial seed

There are different approaches how to initialize the seed, but the way i like to do it, is to not let `Game.init` be random and ensure that the player can only start and action if the seed has been fetched.

```
init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , seed = Random.initialSeed 42
      }
    , Random.generate Restart Random.independentSeed
    )
```

We only ever use randomness when drawing new cards, so we draw the first card only once we have fetched the seed.

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Restart initialSeed ->
            Random.step (Game.drawCard Game.init) initialSeed
                |> (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                          }
                        , Cmd.none
                        )
                   )
            ..
```

## Let it snow ❄️

The new card for today is snow ❄️.

Now turns into water, if it touches fire.

```
( Just Water, List.member Fire )
```

and it produces more snow, if it touches water.

```
( Snow, List.member Water )
```

[![Current Progress](https://orasund.github.io/littleWorldPuzzler/devlog/5/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/5/) 

---

And with that, the devlog is over again. You can [checkout the source code](https://github.com/Orasund/littleWorldPuzzler/tree/418978effb24bc138f4ba3c7f92342e1da7d7133) and the [PR](https://github.com/Orasund/littleWorldPuzzler/pull/3) as usual.