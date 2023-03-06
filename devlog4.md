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

Previously our rules could have done anything, but we only ever did two things: reproduce and destroy. So to enforce this, i changed the types of the two functions.

```
transform : Card -> ( Maybe Card, List Card -> Bool )
transform card =
    case card of
        Water ->
            ( Nothing, always True )

        Tree ->
            ( Just Fire, List.member Fire )

        Fire ->
            ( Nothing, List.member Water )

        Rabbit ->
            ( Just Wolf, List.member Wolf )

        Wolf ->
            ( Nothing, List.member Rabbit )

        Volcano ->
            ( Nothing, List.member Fire )
```

The transform function will now enforce only one possible card that it can transform into.

```
produces : Card -> ( Card, List Card -> Bool )
produces card =
    case card of
        Water ->
            ( card, (/=) [] )

        Tree ->
            ( card, List.member Water )

        Fire ->
            ( card, (==) (List.repeat 4 Fire) )

        Rabbit ->
            ( card
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Wolf ->
            ( card, (==) (List.repeat 4 Rabbit) )

        Volcano ->
            ( Fire, always True )
```

The produce function will also only allow one card type that can be produced. And yes, it does not always produce itself.

This is where our card for this devlog comes into play: The Volcano 🌋.

**Rules(Volcano)**
* Volcanos will always spawn fire
* Volcanos disappear when touching fire

So Volcanos gives you one point per round. However you also get one fire, that you somehow need to get rid again.

[![Current Progress](https://orasund.github.io/littleWorldPuzzler/devlog/4/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/4/) 

_Click to play_

---

And with that, the devlog is over again. You can [checkout the source code](https://github.com/Orasund/littleWorldPuzzler/tree/9d912ac729ac1ded60f51f701d83345c15feac0e/src) as usual. I also have made a PR, if you want to see the changes from last time.