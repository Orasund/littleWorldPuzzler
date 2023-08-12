module Main exposing (main)

import Action
import Browser
import Browser.Dom as Dom
import Element exposing (Element, Option)
import Element.Background as Background
import Element.Font as Font
import Framework
import Html
import Html.Attributes as Attributes
import Random
import State.Finished as FinishedState
import State.Playing as PlayingState
import State.Prepairing as PreparingState
import State.Ready as ReadyState
import Task


height : Float
height =
    600


width : Float
width =
    400



----------------------
-- Model
----------------------


type alias Config =
    { scale : Float
    , portraitMode : Bool
    }


type Model
    = Preparing PreparingState.Model
    | Ready ( ReadyState.Model, Config )
    | Playing ( PlayingState.Model, Config )
    | Finished ( FinishedState.Model, Config )


type Msg
    = PlayingSpecific PlayingState.Msg
    | ReadySpecific ReadyState.Msg
    | PreparingSpecific PreparingState.Msg
    | FinishedSpecific FinishedState.Msg
    | Resized Config
    | Restart


calcPortraitMode : { height : Float, width : Float } -> Bool
calcPortraitMode dim =
    dim.height > dim.width


calcScale : { height : Float, width : Float } -> Float
calcScale dim =
    if dim.width / dim.height > width / height then
        dim.height / height

    else
        dim.width / width



----------------------
-- Init
----------------------


init : () -> ( Model, Cmd Msg )
init _ =
    ( Preparing { scale = Nothing, seed = Nothing, portraitMode = False }
    , Cmd.batch
        [ Random.generate (PreparingSpecific << PreparingState.GotSeed)
            Random.independentSeed
        , Task.perform
            (\_ ->
                { width = width, height = height }
                    --{ width = viewport.width, height = viewport.height }
                    |> (\dim ->
                            Resized
                                { scale = calcScale dim
                                , portraitMode = calcPortraitMode dim
                                }
                       )
            )
            Dom.getViewport
        ]
    )



----------------------
-- Update
----------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( PreparingSpecific preparingMsg, Preparing preparingModel ) ->
            PreparingState.update preparingMsg preparingModel
                |> Action.config
                |> Action.withUpdate Preparing never
                |> Action.withTransition
                    (\{ scale, portraitMode, seed } ->
                        ReadyState.init seed
                            |> (\( m, c ) ->
                                    ( ( m
                                      , { scale = scale
                                        , portraitMode = portraitMode
                                        }
                                      )
                                    , c
                                    )
                               )
                    )
                    Ready
                    ReadySpecific
                |> Action.apply

        ( ReadySpecific readyMsg, Ready ( readyModel, config ) ) ->
            ReadyState.update readyMsg readyModel
                |> Action.config
                |> Action.withUpdate (\m -> Ready ( m, config )) ReadySpecific
                |> Action.withTransition
                    (PlayingState.init
                        >> (\( m, c ) ->
                                ( ( m, config )
                                , c
                                )
                           )
                    )
                    Playing
                    PlayingSpecific
                |> Action.apply

        ( PlayingSpecific playingMsg, Playing ( playingModel, config ) ) ->
            PlayingState.update playingMsg playingModel
                |> Action.config
                |> Action.withUpdate (\m -> Playing ( m, config )) PlayingSpecific
                |> Action.withTransition
                    (FinishedState.init
                        >> (\( m, c ) ->
                                ( ( m, config )
                                , c
                                )
                           )
                    )
                    Finished
                    FinishedSpecific
                |> Action.withExit (init ())
                |> Action.apply

        ( FinishedSpecific _, Finished _ ) ->
            ( model, Cmd.none )

        ( Restart, _ ) ->
            init ()

        ( Resized { scale, portraitMode }, _ ) ->
            ( case model of
                Playing ( playingModel, config ) ->
                    Playing
                        ( playingModel
                        , { config | scale = scale, portraitMode = portraitMode }
                        )

                Finished ( finishedModel, config ) ->
                    Finished
                        ( finishedModel
                        , { config | scale = scale, portraitMode = portraitMode }
                        )

                Ready ( readyModel, config ) ->
                    Ready
                        ( readyModel
                        , { config | scale = scale, portraitMode = portraitMode }
                        )

                Preparing ({ seed } as prepairingModel) ->
                    case seed of
                        Just s ->
                            Ready
                                ( ReadyState.init s
                                    |> Tuple.first
                                , { scale = scale
                                  , portraitMode = portraitMode
                                  }
                                )

                        Nothing ->
                            Preparing
                                { prepairingModel
                                    | scale = Just scale
                                    , portraitMode = portraitMode
                                }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )



----------------------
-- Subscriptions
----------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



{--onResize
        (\w h ->
            { width = toFloat w, height = toFloat h }
                |> (\dim ->
                        Resized
                            { scale = calcScale dim
                            , portraitMode = calcPortraitMode dim
                            }
                   )
        )--}
----------------------
-- View
----------------------


view : Model -> Browser.Document Msg
view model =
    let
        forceHover : Bool -> List Option
        forceHover bool =
            if bool then
                [ Element.forceHover
                ]

            else
                []

        content : Element Msg
        content =
            case model of
                Playing ( playingModel, { scale } ) ->
                    PlayingState.view scale Restart PlayingSpecific playingModel

                Finished ( finishedModel, { scale } ) ->
                    FinishedState.view scale Restart FinishedSpecific finishedModel

                Ready ( readyModel, { scale } ) ->
                    ReadyState.view scale Restart ReadySpecific readyModel

                Preparing _ ->
                    Element.none

        portraitMode : Bool
        portraitMode =
            case model of
                Playing ( _, config ) ->
                    config.portraitMode

                Finished ( _, config ) ->
                    config.portraitMode

                Ready ( _, config ) ->
                    config.portraitMode

                Preparing _ ->
                    False
    in
    { title = "Little World Puzzler"
    , body =
        [ Html.node "meta"
            [ Attributes.attribute "name" "viewport"
            , Attributes.attribute "content" "width=device-width, initial-scale=1.0"
            ]
            []
        , """
html,body {
    height:100%;
    width:100%;
    marign:0;
}

button:hover {
    filter:brightness(0.90);
}

button:focus {
    filter:brightness(0.75);
}
        """
            |> Html.text
            |> List.singleton
            |> Html.node "style" []
        , Element.layoutWith
            { options = forceHover portraitMode ++ Framework.layoutOptions }
            ([ Font.family
                [ Font.external
                    { url = "font.css"
                    , name = "Noto Emoji"
                    }
                ]
             , Background.color <| Element.rgb255 44 48 51
             , Element.width (Element.px (round width))
             , Element.height (Element.px (round height))
             ]
                ++ Framework.layoutAttributes
            )
          <|
            content
        ]
    }


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
