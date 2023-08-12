module State.Replaying exposing (Model, Msg, update, view)

import Action
import Data.CellType exposing (CellType(..))
import Data.Deck exposing (Selected(..))
import Data.Game exposing (Game)
import Element exposing (Element)
import Framework
import Layout
import UndoList exposing (UndoList)
import View.Game as GameView
import View.Header as HeaderView



----------------------
-- Model
----------------------


type alias Model =
    UndoList Game


type Msg
    = Next
    | Previous


type alias Action =
    Action.Action Model Never Never Never



----------------------
-- Update
----------------------


update : Msg -> Model -> Action
update msg model =
    case msg of
        Next ->
            Action.updating
                ( model |> UndoList.redo, Cmd.none )

        Previous ->
            Action.updating
                ( model |> UndoList.undo, Cmd.none )



----------------------
-- View
----------------------


view : Float -> msg -> (Msg -> msg) -> Model -> Element msg
view scale restartMsg msgMapper model =
    let
        ({ score } as game) =
            model.present
    in
    [ HeaderView.viewWithUndo
        { restartMsg = restartMsg
        , previousMsg = msgMapper Previous
        , nextMsg = msgMapper Next
        }
        score
    , GameView.viewReplay scale game
    ]
        |> Element.column Framework.container
