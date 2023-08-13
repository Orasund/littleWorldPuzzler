module Data.Board exposing
    ( Board
    , columns
    , place
    , rows
    )

import Data.CellType exposing (CellType(..))
import Grid.Bordered as Grid exposing (Grid)


columns : Int
columns =
    4


rows : Int
rows =
    columns


type alias Board =
    Grid CellType


place : ( Int, Int ) -> CellType -> Board -> Board
place position cellType =
    Grid.ignoringErrors <|
        Grid.insert position cellType
