module View.Color exposing (..)


cardBackground : String
cardBackground =
    "color-mix(in lch, " ++ secondary ++ " 10%," ++ background ++ ")"


borderColor : String
borderColor =
    "color-mix(in lch, " ++ secondary ++ " 10%," ++ background ++ ")"


successShadeColor : String
successShadeColor =
    "color-mix(in lch, " ++ primary ++ ", transparent 0%)"


shadeColor : String
shadeColor =
    "color-mix(in lch, " ++ secondary ++ ", transparent 25%)"



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
