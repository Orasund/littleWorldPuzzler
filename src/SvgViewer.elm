module SvgViewer exposing (..)

import Svg.Path
import Svg.Writer


main =
    [ Svg.Path.startAt ( 50, 50 )
        |> Svg.Path.drawCircleArcAroundBy ( 12.5, 0 )
            { angle = pi / 2
            , clockwise = False
            }
        |> Svg.Path.drawCircleArcAroundBy ( 0, 12.5 )
            { angle = pi / 2
            , clockwise = True
            }
        |> Svg.Path.drawArcBy ( -50, 0 )
            { radiusX = 25
            , radiusY = 25
            , rotation = 0
            , takeTheLongWay = False
            , clockwise = True
            }
        |> Svg.Path.endClosed
        |> Svg.Writer.path
        |> Svg.Writer.withStrokeColor "black"
    ]
        |> Svg.Writer.toProgram
            { name = "image"
            , width = 100
            , height = 100
            }
