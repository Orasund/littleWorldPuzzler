module View.Color exposing (..)


cardBackground : String
cardBackground =
    "color-mix(in lch, " ++ secondary ++ " 10%," ++ background ++ ")"



---


background : String
background =
    -- White
    "#fefeff"


primary : String
primary =
    -- Green
    "#8bc82f"


secondary : String
secondary =
    -- Darkgreen
    "#555e6a"
