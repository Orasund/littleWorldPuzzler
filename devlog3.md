# Devlog 3 - Layout the game

After two devlogs focused on gameplay, we now finally are doing a devlog all about some basic styling tricks.

## Adding a Stylesheet

My biggest Wow Moment while using Elm was the moment i realized i could inject a stylesheet into the application without needing to leave the realm of Elm.

``` Elm
Html.node "style" [] [ Html.text """
:root, body {
    height: 100%
} 

button:hover {
    filter: brightness(0.95)
}

button:focus {
    filter: brightness(0.90)
}

button:active {
    filter: brightness(0.7)
}
""" ]
```

Why do i even need a stylesheet, you might ask. Well there are two things that are impossible to do without: styling the body node and styling buttons.

I'm setting the height of the body to 100%, so that i can just ignore it going forward.

For styling buttons i like to just add a generic filter over it. This way i can still individually style different buttons and get the animations for hovering, focusing and activating for free.

## Basic Layouting

So i went ahead and did some layouting.

[![Current Progress](https://orasund.github.io/littleWorldPuzzler/devlog/3/game.png)](https://orasund.github.io/littleWorldPuzzler/devlog/3/)

_(Click to play)_

I've moved the point to the top and changed the list of buyable cards into a row.

For styling the grid didn't have to do much.

This is the styling of a cell:

```
(Layout.centered
    ++ [ Html.Attributes.style "width" "64px"
        , Html.Attributes.style "height" "64px"
        , Html.Attributes.style "border-radius" "16px"
        , Html.Attributes.style "font-size" "48px"
        , Html.Attributes.style
            "border"
            "1px solid rgba(0,0,0,0.2)"
        ]
)
```

and for the rows and columns of the grid i used `Layout.spacing 8`.

Now a word about spacing: I like to use powers of 2 for the size of the space. The smallest numbers is most often 8 (rarly 4). With that i have 8px for a small space, 16px for a normal space and 32px for a big space.

The cells are conceptually belong together - so i give them a small space. The different elements on the vertical axis are different things, so they get the biggest space between them. These spacings aren't final, but i think.

## Adding the Wolf 🐺 

In the last devlog I said that i will be adding one new card per devlog. So lets do this.

The wolf will feed on the rabbit. It eats rabbits to survive and dies if no rabbits are left.

This concept would have been quite easy to pull off in the old version of the game. But this time im not sure how i can achive this mechanic with just 2 rules. So i have to get a bit creative.

**Rules (🐺Wolf)**
* 🐺Wolfs reproduce when next to 4 🐰Rabbits
* 🐺Wolfs die if not next to 🐰rabbits

Now this might look good, but the rabbit isn't killed. So now i have to go back to the rabbit and change the rule for killing it

**Rules (🐰Rabbit)**
* 🐰Rabbits reproduce when next to at least 2 🌳trees
* 🐰Rabbits turn into 🐺wolfs when next to 🐺wolfs.

---

I really feel the urge to write down the DSL and start formalizing the rules. So maybe let's do this in the next devlog.

As always, you can find the source code [here](https://github.com/Orasund/littleWorldPuzzler/tree/113c8f162d353c794bdc3d6615acc7cd58cf4914/V2).