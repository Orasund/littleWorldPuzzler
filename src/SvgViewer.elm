module SvgViewer exposing (..)

import Svg
import Svg.Path
import Svg.Writer


main =
    Svg.fireBack
        |> Svg.Writer.toProgram
            { name = "image"
            , width = 100
            , height = 100
            }
