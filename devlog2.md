# Devlog 2 - Expanding the core loop

In the last devlog, we introduced a small proof of concept.
Today i want to expand that concept and see if i run into any walls.

The current game is bit to hard.
To fix this i am thinking of rewarding the player with new cards every 10 turns.
This is actually the same mechanic as in the original game, but this time im thinking of letting the player choose the cards they get.

Im still unsure if the player should get one or more cards, so lets just go with one -  that's easier to implement.

However, I'd like to also give the option to select a special card that you can only play if a hard to reach state is reached. This card will be the rabbit.

## Rabbits

```
Rules (Rabbit)
* Rabbits produce new rabbits if they are near at least two trees.
* Rabbits despawn if the are not near at least two trees.
```

This rules are the first that we could not have pulled of in the original game. Originally i sticked to very traditional cell automata rules. This time around i decided to write my own DSL that will generate the automata rules for me.

I said in the last devlog, that i wanted to limit myself to only two (cell automata) rules. Now im loosening the limitation by saying im only allowing two rules written in my DSL. This is of course cheating as i could design my DSL to be as powerful as i want. But i think i can handle my new found powers.

## Buying cards

Next i thought of a easy UX how one can get new cards every 10 turns without needing to implement an overlay.

My solution was to have a shop, where the player can buy items with points. Each turn a player gets one point, so after 10 turns they can buy a card for 10 points.

I didn't end up actually implementing it that way. I wanted to make it more interesting, so now the player gets a point for each new card produced. This way they are interested in producing as much cards as possible.

I also gave cards different prices: Water is worth 20 points, everything else is 10 points. That's because you can't loose your water card.

After playing the game, i noticed that by not being able to loose water, you actually can't "loose" the game. So i tweaked the rule, such that water always needs to be placed next to something for it to spawn more water.

![Adding the Shop](https://orasund.github.io/littleWorldPuzzler/devlog/2/game.png)