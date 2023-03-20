module Svg exposing (..)

import Svg.Path
import Svg.Writer exposing (SvgNode)


fireBack : List SvgNode
fireBack =
    [ [ ( "flame"
        , Svg.Path.startAt ( 0, 0 )
            |> Svg.Path.drawCircleArcBy ( 0, 40 )
                { angle = pi / 2
                , takeTheLongWay = False
                , clockwise = True
                }
            |> Svg.Path.drawCircleArcBy ( 0, 60 )
                { angle = pi / 2
                , takeTheLongWay = False
                , clockwise = False
                }
            |> Svg.Path.drawCircleArcBy ( 0, -20 )
                { angle = pi / 2
                , takeTheLongWay = False
                , clockwise = True
                }
            |> Svg.Path.drawCircleArcBy ( 0, -80 )
                { angle = pi / 2
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
            |> Svg.Writer.withCustomAttribute "x" "25"
            |> Svg.Writer.withCustomAttribute "y" "-75"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "25"
            |> Svg.Writer.withCustomAttribute "y" "25"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "50"
            |> Svg.Writer.withCustomAttribute "y" "50"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "50"
            |> Svg.Writer.withCustomAttribute "y" "-50"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "75"
            |> Svg.Writer.withCustomAttribute "y" "75"
      , Svg.Writer.use "flame"
            |> Svg.Writer.withCustomAttribute "x" "75"
            |> Svg.Writer.withCustomAttribute "y" "-25"
      ]
        |> Svg.Writer.group
        |> Svg.Writer.withFillColor "rgba(0,0,0,0.2)"
    ]


volcanoBack : List SvgNode
volcanoBack =
    [ [ Svg.Writer.rectangle
            { topLeft = ( 0, 0 )
            , height = 100
            , width = 100
            }
            |> Svg.Writer.withFillColor "white"
      , Svg.Writer.circle
            { radius = 25
            , pos = ( 50, 50 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 25
            , pos = ( 0, 0 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 25
            , pos = ( 100, 0 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 25
            , pos = ( 0, 100 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 25
            , pos = ( 100, 100 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 5
            , pos = ( 50, 0 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 5
            , pos = ( 50, 100 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 5
            , pos = ( 0, 50 )
            }
            |> Svg.Writer.withFillColor "black"
      , Svg.Writer.circle
            { radius = 5
            , pos = ( 100, 50 )
            }
            |> Svg.Writer.withFillColor "black"
      ]
        |> Svg.Writer.defineMask "mask"
    , Svg.Writer.rectangle
        { topLeft = ( 0, 0 )
        , height = 100
        , width = 100
        }
        |> Svg.Writer.withMask "mask"
        |> Svg.Writer.withFillColor "rgba(0,0,0,0.2)"
    ]


leaveBack =
    [ [ Svg.Path.startAt ( 0, 5 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
      , [ Svg.Path.startAt ( 50 + 25, 40 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
        , Svg.Path.startAt ( -100 + 50 + 25, 40 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = True
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
        ]
            |> Svg.Writer.group
      , Svg.Path.startAt ( 70, 55 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
      , [ Svg.Path.startAt ( 90, -5 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
        , Svg.Path.startAt ( 90, 95 )
            |> Svg.Path.drawLineBy ( -20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, 20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.drawLineBy ( 0, 20 )
            |> Svg.Path.drawLineBy ( 20, 0 )
            |> Svg.Path.drawCircleArcAroundBy ( 0, -20 )
                { angle = 2 * pi / 4
                , clockwise = False
                }
            |> Svg.Path.endClosed
            |> Svg.Writer.path
        ]
            |> Svg.Writer.group
      ]
        |> Svg.Writer.group
        |> Svg.Writer.withFillColor "rgba(0,0,0,0.2)"
    ]
