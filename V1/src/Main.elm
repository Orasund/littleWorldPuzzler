module Main exposing (main)

import Browser
import Html
import Html.Attributes
import Layout
import Random exposing (Seed)
import State
import View



----------------------
-- Model
----------------------


type Model
    = Preparing
    | Playing State.Model


type Msg
    = PlayingSpecific State.Msg
    | Restart Seed



----------------------
-- Init
----------------------


init : () -> ( Model, Cmd Msg )
init _ =
    ( Preparing
    , Random.generate Restart Random.independentSeed
    )



----------------------
-- Update
----------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( PlayingSpecific playingMsg, Playing playingModel ) ->
            ( State.update playingMsg playingModel
                |> Playing
            , Cmd.none
            )

        ( Restart seed, _ ) ->
            State.init seed
                |> Tuple.mapBoth Playing
                    (Cmd.map PlayingSpecific)

        _ ->
            ( model, Cmd.none )



----------------------
-- Subscriptions
----------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



----------------------
-- View
----------------------


view : Model -> Browser.Document Msg
view model =
    { title = "Little World Puzzler"
    , body =
        [ Html.node "meta"
            [ Html.Attributes.attribute "name" "viewport"
            , Html.Attributes.attribute "content" "width=device-width, initial-scale=1.0"
            ]
            []
        , View.stylesheet
        , case model of
            Playing playingModel ->
                State.view Restart PlayingSpecific playingModel

            Preparing ->
                Layout.none
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
