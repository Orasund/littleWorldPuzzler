module View.Color exposing (..)


cardBackground : String
cardBackground =
    mix (secondary ++ " 10%") background


borderColor : String
borderColor =
    mix (secondary ++ " 10%") background


successShadeColor : String
successShadeColor =
    mix
        (mix (primary ++ " 50%") "white" ++ " 80%")
        "transparent"


shadeColor : String
shadeColor =
    mix (secondary ++ " 30%") "transparent"


mix : String -> String -> String
mix a b =
    "color-mix(in lab," ++ a ++ ", " ++ b ++ ")"



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
