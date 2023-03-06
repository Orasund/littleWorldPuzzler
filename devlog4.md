# Devlog 4 : Adding some structure

In the previous devlogs we worked on gameplay and added some styling. This time we will focus on structing the code and doing some simple but needed refactoring. As usual we also add a new card at the end.

## The Game Type

The first thing i usually like to do, is to add a type that contains all game related information. Starting a new game should be as simple as creating as initializing the game type.

So i moved the content of the model and the functions used for updating the model into its own file.

So my update function now looks like this:

```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedAt pos ->
            ( model.game
                |> Game.placeCard pos
                |> (\it -> { model | game = it })
            , Cmd.none
            )

        BoughtCard card ->
            ( model.game
                |> Game.buyCard card
                |> (\it -> { model | game = it })
            , Cmd.none
            )

        Restart seed ->
            ( { model | game = Game.init, seed = seed }
            , Cmd.none
            )
```

And yes, i also added a restart button and a seed to the game. However the seed is currently not doing a lot. Randomness will be a topic for another time.

## Formalizing the rules

I have talked about the formalization of my rules a lot and today we will do our first small step into that direction.

Previously our rules could have done anything, but we only ever did two things: reproduce and destroy. So to enforce this, i changed the types of the two functions:

```
```