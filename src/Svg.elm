module Svg exposing (..)

import Svg.Path
import Svg.Writer exposing (SvgNode)


fireBack : List SvgNode
fireBack =
    [ [ ( "flame"
        , Svg.Path.startAt ( 0, 0 )
            |> Svg.Path.drawCircleArcBy ( 0, 40 )
                { angle = pi * 3 / 4
                , takeTheLongWay = False
                , clockwise = True
                }
            |> Svg.Path.drawCircleArcBy ( 0, 60 )
                { angle = pi * 3 / 4
                , takeTheLongWay = False
                , clockwise = False
                }
            |> Svg.Path.drawCircleArcBy ( 0, -40 )
                { angle = pi * 3 / 4
                , takeTheLongWay = False
                , clockwise = True
                }
            |> Svg.Path.drawCircleArcBy ( 0, -60 )
                { angle = pi * 3 / 4
                , takeTheLongWay = False
                , clockwise = False
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
        )
      ]
        |> Svg.Writer.define
    , [ Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "0"
            |> Svg.Writer.withCustomAttribute "y" "0"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "100"
            |> Svg.Writer.withCustomAttribute "y" "0"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "50"
            |> Svg.Writer.withCustomAttribute "y" "-50"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "50"
            |> Svg.Writer.withCustomAttribute "y" "50"
      ]
        |> Svg.Writer.group
        |> Svg.Writer.withFillColor "rgba(0,0,0,0.2)"
    ]
