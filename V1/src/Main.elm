module Main exposing (main)

import Browser
import Data.Card exposing (Card)
import Data.Deck exposing (Selected)
import Html
import Html.Attributes
import Layout
import Random exposing (Seed)
import State exposing (Action(..))
import Time
import View



----------------------
-- Model
----------------------


type alias Model =
    { state : State.Model
    , updating : Bool
    }


type Msg
    = PositionSelected ( Int, Int )
    | PlaceCard ( Int, Int ) Selected
    | UpdateGame
    | ViewCard Card
    | CloseOverlay
    | PickCardToAdd Card
    | Restart Seed



----------------------
-- Init
----------------------


init : () -> ( Model, Cmd Msg )
init _ =
    ( { state = State.init (Random.initialSeed 42)
      , updating = False
      }
    , Random.generate Restart Random.independentSeed
    )



----------------------
-- Update
----------------------


applyActions : List Action -> Model -> Model
applyActions actions m =
    actions
        |> List.foldl
            (\action model ->
                case action of
                    UpdateGameAction ->
                        { model | updating = True }
            )
            m


updateStateTo : Model -> State.Model -> Model
updateStateTo model state =
    { model | state = state }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( case msg of
        PositionSelected position ->
            State.positionSelected position model.state
                |> updateStateTo model

        PlaceCard position selected ->
            State.placeCard position selected model.state
                |> (\( m, l ) ->
                        m
                            |> updateStateTo model
                            |> applyActions l
                   )

        UpdateGame ->
            State.updateGame model.state
                |> updateStateTo { model | updating = False }

        ViewCard card ->
            State.viewCard card model.state
                |> updateStateTo model

        CloseOverlay ->
            State.closeOverlay model.state
                |> updateStateTo model

        PickCardToAdd card ->
            State.pickCardToAdd card model.state
                |> updateStateTo model

        Restart seed ->
            State.init seed
                |> updateStateTo model
    , Cmd.none
    )



----------------------
-- Subscriptions
----------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.updating then
        Time.every 200 (\_ -> UpdateGame)

    else
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
        , [ State.viewGame
                { restart = Restart
                , placeCard = PlaceCard
                , viewCard = ViewCard
                , selectPositon = PositionSelected
                }
                model.state
                |> Layout.el (Html.Attributes.style "height" "100%" :: Layout.centered)
          , State.viewOverlay
                { restart = Restart
                , closeOverlay = CloseOverlay
                , selectCardToAdd = PickCardToAdd
                }
                model.state
          ]
            |> Html.div
                [ Html.Attributes.style "width" "100%"
                , Html.Attributes.style "height" "100%"
                , Html.Attributes.style "position" "relative"
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
