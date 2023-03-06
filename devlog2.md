# Devlog 2 - Expanding the core loop

In the last devlog, we introduced a small proof of concept.
Today i want to expand that concept and see if i run into any walls.

The current game is bit to hard.
To fix this i am thinking of rewarding the player with new cards every 10 turns.
This is actually the same mechanic as in the original game, but this time im thinking of letting the player choose the cards they get.

Im still unsure if the player should get one or more cards, so lets just go with one -  that's easier to implement.

However, I'd like to also give the option to select a special card that you can only play if a hard to reach state is reached. This card will be the rabbit.

## Some rules for rabbits

```
Rules (Rabbit)
* Rabbits produce new rabbits if they are near at least two trees.
* Rabbits despawn if the are not near at least two trees.
```

This rules are the first that we could not have pulled of in the original game. Originally i sticked to very traditional cell automata rules. This time around i decided to write my own DSL that will generate the automata rules for me.

I said in the last devlog, that i wanted to limit myself to only two (cell automata) rules. Now im loosening the limitation by saying im only allowing two rules written in my DSL. This is of course cheating as i could design my DSL to be as powerful as i want. But i think i can handle my new found powers.

currently rules are represented by two functions.

```
transform : List Card -> Card -> Maybe Card

produce : List Card -> Card -> Maybe Card
```

The `transform` function takes a neighborhood and the card and returns the content of the new cell. Returning nothing will destroy the card.

The `produce` has the same type signature (for now) and returns the card that the player should get. Returning nothing will do nothing.

for the rabbit, the rules are implemented quite straight forward.

```
transform : List Card -> Card -> Maybe Card
transform neighbors card =
    case card of
        Rabbit ->
            if
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            then
                Just card

            else
                Nothing
        ...
```

We check if there are at least two trees in the neighborhood.

```
produce : List Card -> Card -> Maybe Card
produce neighbors card =
    case card of
        Rabbit ->
            if
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            then
                Just Rabbit

            else
                Nothing
        ...
```

This is also the same code for the produce function. My fingers are itching to refactor this, but i will resist the urge.
I want to be really sure, that i know what the most complicated rule could look like, before I start writing some utility functions.

So from now on, i will add one new card per devlog. This should force me to think more and more out of the box and to break the rules i set for myself.
Only then i can come back and think about what rules i do and do not want to allow for this game.


## Buying cards

Next i thought of a easy UX how one can get new cards every 10 turns without needing to implement an overlay.

My solution was to have a shop, where the player can buy items with points. Each turn a player gets one point, so after 10 turns they can buy a card for 10 points.

I didn't end up actually implementing it that way. I wanted to make it more interesting, so now the player gets a point for each new card produced. This way they are interested in producing as much cards as possible.

I also gave cards different prices: Water is worth 20 points, everything else is 10 points. That's because you can't loose your water card.

After playing the game, I noticed that by not being able to loose water, you actually can't "loose" the game. So i tweaked the rule, such that water always needs to be placed next to something for it to spawn more water.

[![Adding the Shop](https://orasund.github.io/littleWorldPuzzler/devlog/2/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/2/)

_(Click to play)_

--

This it for now. We now know that the core mechanic works and that it is fun. This means we can actually spend some time making the game a bit prettier.

You can find the source code [here](https://github.com/Orasund/littleWorldPuzzler/tree/3b40756e4d8ed57f8e59c59c47d33903155efff4/V2)