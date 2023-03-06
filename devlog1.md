# Devlog 1 - New Beginning

Four years ago, I created a small game called [Little World Puzzler](https://orasund.itch.io/little-world-puzzler).

It became super popular amongst my friends, and I had a lot of fun designing smaller expansions to it.
Looking back, there are definitely a few things that I didn't know how to solve at the time.
But today I feel ready to redo the game and fix the problems it had.

I thought it is fun to take you with me on my journey.
I know it will be a long project, but I will take my time to make everything perfect.

And with that, lets begin.

## What is Little World Puzzler 1?

![Original Game](https://orasund.github.io/littleWorldPuzzler/devlog/1/game.png)

The original game was a mash-up of the game 2048 and cell automata.
I had the idea to place down cards, that then interacted with each other.

This time the idea stays the same, but I will focus more on the card-playing and deck building aspect of the game.
The automata of each card was able to produce new cards, which then could be picked up put in your hand.

## Rethinking the rules

In the first version I had the problem of forced feature creep:
A card could have up to 3 rules associated with it.
Most mechanics need multiple rules, so I designed the cards with only one or two rules.
This way I had space to add mechanics to other cards that I wanted to add later.

A good example for this is the “base” card of the game: 🌊 Water.


**Rules**
* Water disapears if it has at least two neighboring fires
* Water turns into ice if it is next to ice
* A empty tile will turn into a tree if its next to water

The last rule is the main mechanic: Water spawns trees.
The first rule is the secondary mechanic: Fire gets rid of water.

These two give the gameplay, where water turns into trees, trees can burn and too much fire will destroy water again.
So usually you would try to have a lot of trees and one single fire that endlessly wanders through the map, making space for new cards.

Fire is one of the best cards, because it makes space for new cards (similarly to stacking tiles in 2048).

Originally I wanted a third rule, that lets water move.
but I had to scrap it, when I added ice in one of my extensions.

---

This time I wanted to decouple the rules from the way how to get new cards.
With that, I will have a nicer way of adding new cards without needing to constantly reworking old ones.

I  want cards to always have two rules: one for changing the cell and one for getting a new card.

So the two new rules for water will be the following:

**Rules (💧Water)**
* 💧Water always disappears next turn.
* 💧Water always adds 💧water into your deck.


This will give you the feeling, that water is constantly moving.

Now you might wonder where the tree mechanic went. Well, let's look at the rule of that card:

**Rules (🌳Tree)**
* 🌳Trees disappear when next to 🔥fire
* 🌳Trees that are next to 💧water add a 🌳tree into your deck


You can see that the idea is the same, but the rules are really focused on the individual card.

The water card is also completely separated from the tree card.
I would easily add a different tree variant (like the evergreen from the original).
In the old version, adding the evergreen was a nightmare.

To get a complete picture, we also have to look at the fire card:

**Rules (🔥Fire)**
* 🔥Fire disappears next to 💧water
* 🔥Fire that is surrounded by 🔥fire will add 🔥fire to the deck

With this, we have the first few cards and mechanics.
Next we can go along and implement a first prototype.

[![First draft](https://orasund.github.io/littleWorldPuzzler/devlog/1/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/1/)

_(Click to play)_

The result is actually better then expected. The three cards feel very powerful and its actually a nice challenge to keep the system alive for as long as possible.

However, the game is a bit too hard for my liking and i might want to introduce a mechanic for getting cards back, that you lost. But that will be discussed in a different devlog.

## Implementing the first draft

The first draft was actually done quite straight forward. I didn't introduce any abstraction and always sticked to the most direct solution. I will abstract away and introduce patterns. But for this draft i wanted to have something small that should not raise any questions.

However, i snuck one small library of mine into the code: [Orasund/elm-layout](https://package.elm-lang.org/packages/Orasund/elm-layout/latest/). It's just a wrapper around Flexbox but using names taken from Elm-ui. It was meant to be a elm-ui inspired html-library.

I used the functions `Layout.row` and `Layout.column` to create the grid and `Layout.centered` for centering the emojis in the cell.
A small function that i also include into the libary is `Layout.asButton`, which turns any flexbox node into a button.

```
Layout.asButton
    { onPress =  ClickedAt ( x, y ) |> Just
    , label =
        maybeCard
            |> Maybe.map Card.emoji
            |> Maybe.withDefault " "
    }
```

The API is heavily taken from elm-ui, but the flexibility of it is crazy. In Elm-ui, buttons are always using `Html.button`.
This might get frustrating if you are forced to use a `div`, but have to wrap it into a button just to make it behave like a button.

---

That's it for the first devlog. You can checkout the source code [here](https://github.com/Orasund/littleWorldPuzzler/tree/4a36a09e59ed769ae490965a551edda2f82f4f30/DevLog1).