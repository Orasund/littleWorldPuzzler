# Devlog 8 - Addings Packs

Since last time I did some playtesting and tweaked some numbers.

I noticed, that im thinking of the cards als "packs" - combos of cards that spawn interesting gameplay.
So today i added these packs into the game.

[![Current Progress](https://orasund.github.io/littleWorldPuzzler/devlog/8/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/8/)

Packs can be bought just as the individual cards, but are cheeper in total.

## Adding the Eagle

I also went ahead and added the eagle. It's a varient of the wolf - also a creature that is feeding on the rabbit, but its a bit more flexible. I want to create a food chain and with the wolf i wasn't sure what creature would come next. For the Eagle i already know that i will be adding a Cat - or Lynx? At some point.

```
Eagle ->
    ( Nothing, List.member Rabbit )
```
The eagle dies if its next to a rabbit. 

```
Eagle ->
    ( Eagle, List.member Rabbit )
```
The eagle will also spawn a new card if its next to the rabbit. So the gameplay should feel like the eagle is constantly flying down to the ground, catching a rabbit and then disappearing again - only to appear again.

I was thinking of the Eagle should die off if no rabbit is around, but i already have this mechanic with the wolf - and i don't like it.