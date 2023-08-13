module Data.Board exposing
    ( Board
    , columns
    , place
    , rows
    )

import Data.Card exposing (Card(..))
import Grid.Bordered as Grid exposing (Grid)


columns : Int
columns =
    3


rows : Int
rows =
    columns


type alias Board =
    Grid Card


place : ( Int, Int ) -> Card -> Board -> Board
place position cellType =
    Grid.ignoringErrors <|
        Grid.insert position cellType
