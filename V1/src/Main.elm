module Main exposing (main)

import Action
import Browser
import Data.Game as Game
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Framework
import Html
import Html.Attributes as Attributes
import Random
import State.Finished as FinishedState
import State.Playing as PlayingState
import State.Prepairing as PreparingState
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
    | Playing PlayingState.Model
    | Finished FinishedState.Model


type Msg
    = PlayingSpecific PlayingState.Msg
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
        , Task.succeed
            ()
            |> Task.perform
                (\() ->
                    { width = width, height = height }
                        |> (\dim ->
                                Resized
                                    { scale = calcScale dim
                                    , portraitMode = calcPortraitMode dim
                                    }
                           )
                )
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
                    (\{ seed } ->
                        Random.step Game.generator seed
                            |> (\( game, s ) -> { game = game, seed = s })
                            |> PlayingState.init
                            |> (\( m, c ) ->
                                    ( m
                                    , c
                                    )
                               )
                    )
                    Playing
                    PlayingSpecific
                |> Action.apply

        ( PlayingSpecific playingMsg, Playing playingModel ) ->
            PlayingState.update playingMsg playingModel
                |> Action.config
                |> Action.withUpdate (\m -> Playing m) PlayingSpecific
                |> Action.withTransition
                    (FinishedState.init
                        >> (\( m, c ) ->
                                ( m
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
                Playing playingModel ->
                    Playing
                        playingModel

                Finished finishedModel ->
                    Finished
                        finishedModel

                Preparing ({ seed } as prepairingModel) ->
                    case seed of
                        Just s ->
                            Random.step Game.generator s
                                |> (\( game, s2 ) -> { game = game, seed = s2 })
                                |> PlayingState.init
                                |> Tuple.first
                                |> Playing

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
        content : Element Msg
        content =
            case model of
                Playing playingModel ->
                    PlayingState.view 1 Restart PlayingSpecific playingModel

                Finished finishedModel ->
                    FinishedState.view 1 Restart FinishedSpecific finishedModel

                Preparing _ ->
                    Element.none
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
        , content
            |> Element.layoutWith
                { options = Framework.layoutOptions }
                [ Font.family
                    [ Font.external
                        { url = "font.css"
                        , name = "Noto Emoji"
                        }
                    ]
                , Background.color <| Element.rgb255 44 48 51
                , Element.width (Element.px (round width))
                , Element.height (Element.px (round height))
                ]
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
