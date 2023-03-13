# Devlog 6 - Follow the fun

It's devlog time! Today wanted to make the game more fun. For game design it's usually a good i idea to [**follow the fun**](https://www.youtube.com/watch?v=kMDe7_YwVKI).

I just did a game jam over the weekend that was a lot of fun and coming back to this project I notice how much i actually hated the core loop (not only in this version, but also in the original game).

In this game you should play around with different systems and really try to break the game with some fun combo. But instead i was afraid to shift gears, carefully placing every card, hoping i didn't miscalculate something.

So I removed the original fail state. Originally the game ended once all tiles on the board are filled. This time around, I reset the game and also give the player some money as an incentive to try again.

## Building your deck

This new concept of "rounds" lead to a gameplay, where you would try a deck, then buy different cards to try again. So I displayed the shop only between two rounds. 

```
type Effect
    = OpenShop
```

To do so I added an effect type. Effects are essentially things that the game need from the main application. In this case we request the shop to be opened. By closing the shop again, the game knows that the player has build their deck.

```
placeCard : ( Int, Int ) -> Game -> Generator ( Game, List Effect )
```

I've updated the `placeCard` function to now return a list of effects. Yes, right now a list does not make any sense, but i expect to have a lot more effects than just opening the shop.

```
applyEffect : Effect -> Model -> Model
applyEffect effect model =
    case effect of
        OpenShop ->
            { model | viewShop = True }
```

I also added a new function called `applyEffect` that specifies what each effect does. I can now loop over every effect in the response and we are done.

```
update msg model =
    case msg of
        ClickedAt pos ->
            ( model.seed
                |> Random.step (Game.placeCard pos model.game)
                |> (\( ( game, effects ), seed ) ->
                        effects
                            |> List.foldl applyEffect
                                { model
                                    | game = game
                                    , seed = seed
                                }
                   )
            , Cmd.none
            )
```

## Display active tiles

One important game mechanic is that some cards will start producing new cards indefinitely if a specific condition is met. I Implemented this with a small icon on the top right of the cell. This icon shows which card is currently being produced.

[![Current Progress](https://orasund.github.io/littleWorldPuzzler/devlog/6/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/6/) 

## No new card for this devlog

I was thinking if i wanted to add another card for this devlog, but decided against it. I haven't actually tried out the existing cards that much. I will probably stop adding cards for now until I have a better feeling of the existing mechanics in the game.