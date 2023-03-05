module Main exposing (..)

import Browser exposing (Document)
import Card exposing (Card)
import Config
import Dict exposing (Dict)
import Html
import Html.Attributes
import Layout


type alias Model =
    { world : Dict ( Int, Int ) Card
    , deck : List Card
    }


type Msg
    = ClickedAt ( Int, Int )


init : () -> ( Model, Cmd Msg )
init () =
    ( { world = Dict.empty
      , deck = [ Card.Tree, Card.Water, Card.Fire ]
      }
    , Cmd.none
    )


view : Model -> Document Msg
view model =
    { title = "Little World Puzzler"
    , body =
        [ List.range 0 (Config.worldSize - 1)
            |> List.map
                (\y ->
                    List.range 0 (Config.worldSize - 1)
                        |> List.map
                            (\x ->
                                model.world
                                    |> Dict.get ( x, y )
                                    |> (\maybeCard ->
                                            maybeCard
                                                |> Maybe.map Card.emoji
                                                |> Maybe.withDefault ""
                                                |> Html.text
                                                |> Layout.el
                                                    (Layout.asButton
                                                        { onPress = ClickedAt ( x, y ) |> Just
                                                        , label =
                                                            maybeCard
                                                                |> Maybe.map Card.emoji
                                                                |> Maybe.withDefault " "
                                                        }
                                                        ++ Layout.centered
                                                        ++ [ Html.Attributes.style "width" "32px"
                                                           , Html.Attributes.style "height" "32px"
                                                           , Html.Attributes.style
                                                                "border"
                                                                "1px solid rgba(0,0,0,0.2)"
                                                           ]
                                                    )
                                       )
                            )
                        |> Layout.row []
                )
            |> Layout.column []
        , "Next: "
            ++ (model.deck
                    |> List.map Card.emoji
                    |> String.concat
               )
            |> Html.text
        ]
    }


neighborsOf : ( Int, Int ) -> List ( Int, Int )
neighborsOf ( x, y ) =
    [ ( x + 1, y ), ( x, y + 1 ), ( x, y - 1 ), ( x - 1, y ) ]


tick : Dict ( Int, Int ) Card -> ( Dict ( Int, Int ) Card, List Card )
tick world =
    world
        |> Dict.foldl
            (\pos card ( output, newCards ) ->
                pos
                    |> neighborsOf
                    |> List.filterMap (\p -> world |> Dict.get p)
                    |> (\neighbors ->
                            ( output
                                |> Dict.update pos
                                    (\_ -> Card.transform neighbors card)
                            , newCards
                                ++ (card
                                        |> Card.produce neighbors
                                        |> Maybe.map List.singleton
                                        |> Maybe.withDefault []
                                   )
                            )
                       )
            )
            ( world, [] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedAt pos ->
            case model.deck of
                card :: deck ->
                    ( model.world
                        |> Dict.insert pos card
                        |> tick
                        |> (\( world, newCards ) ->
                                { model
                                    | world = world
                                    , deck = deck ++ newCards
                                }
                           )
                    , Cmd.none
                    )

                [] ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
