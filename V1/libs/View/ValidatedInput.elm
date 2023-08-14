module View.ValidatedInput exposing (Model, Msg, getError, getRaw, getValue, init, update, view)

import Element exposing (Attribute, Element)
import Element.Events as Events
import Element.Input as Input exposing (Placeholder)


type Model err a
    = Model
        { raw : String
        , value : a
        , err : Maybe err
        , validator : String -> Result err a
        , toString : a -> String
        }


getRaw : Model err a -> String
getRaw (Model { raw }) =
    raw


getValue : Model err a -> a
getValue (Model { value }) =
    value


getError : Model err a -> Maybe err
getError (Model { err }) =
    err


type Msg
    = ChangedRaw String
    | LostFocus


init : { value : a, validator : String -> Result err a, toString : a -> String } -> Model err a
init { validator, toString, value } =
    Model
        { raw = value |> toString
        , value = value
        , err = Nothing
        , validator = validator
        , toString = toString
        }


update : Msg -> Model err a -> Model err a
update msg (Model model) =
    case msg of
        ChangedRaw string ->
            Model
                { model
                    | raw = string
                    , err = Nothing
                }

        LostFocus ->
            case model.validator model.raw of
                Ok value ->
                    Model
                        { model
                            | value = value
                            , err = Nothing
                        }

                Err err ->
                    Model
                        { model
                            | raw = model.value |> model.toString
                            , err = Just err
                        }


view :
    List (Attribute msg)
    -> Model err a
    ->
        { msgMapper : Msg -> msg
        , placeholder : Maybe (Placeholder msg)
        , label : String
        }
    -> Element msg
view attributes (Model model) { msgMapper, placeholder, label } =
    Input.text (attributes ++ [ LostFocus |> msgMapper |> Events.onLoseFocus ])
        { onChange = ChangedRaw >> msgMapper
        , text = model.raw
        , placeholder = placeholder
        , label = Input.labelHidden label
        }
