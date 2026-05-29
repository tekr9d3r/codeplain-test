module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import MemoryGame exposing (Card, CardState(..))
import Process
import Random
import Random.List
import Task

-- DEFINITIONS

type alias Model =
    { cards : List Card
    , selectedIndices : List Int
    , isWaiting : Bool
    , moves : Int
    }

type Msg
    = NoOp
    | ShuffledCards (List String)
    | CardClicked Int
    | FlipBack
    | RestartGame

-- INITIALIZATION

init : () -> ( Model, Cmd Msg )
init _ =
    ( { cards = []
      , selectedIndices = []
      , isWaiting = False
      , moves = 0
      }
    , Random.generate ShuffledCards (Random.List.shuffle MemoryGame.emojis)
    )

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShuffledCards shuffledEmojis ->
            let
                newCards =
                    List.map (\e -> { emoji = e, state = FaceDown }) shuffledEmojis
            in
            ( { model | cards = newCards }, Cmd.none )

        CardClicked index ->
            -- Player cannot flip more than two unmatched cards (isWaiting check)
            -- and cannot click already-matched cards (isAlreadyMatched check)
            if model.isWaiting || List.member index model.selectedIndices || MemoryGame.isAlreadyMatched index model.cards then
                ( model, Cmd.none )

            else
                let
                    updatedCards =
                        MemoryGame.updateCardState index FaceUp model.cards

                    newSelected =
                        index :: model.selectedIndices
                in
                if List.length newSelected == 2 then
                    MemoryGame.checkMatch
                        { model | cards = updatedCards, selectedIndices = newSelected, moves = model.moves + 1 }
                        (\_ _ -> FlipBack)
                        (\msgVal -> Process.sleep 1000 |> Task.perform (always msgVal))

                else
                    ( { model | cards = updatedCards, selectedIndices = newSelected }, Cmd.none )

        FlipBack ->
            let
                resetCards =
                    List.indexedMap
                        (\i c ->
                            if List.member i model.selectedIndices then
                                { c | state = FaceDown }
                            else
                                c
                        )
                        model.cards
            in
            ( { model | cards = resetCards, selectedIndices = [], isWaiting = False }, Cmd.none )

        RestartGame ->
            ( { model | selectedIndices = [], isWaiting = False, moves = 0 }
            , Random.generate ShuffledCards (Random.List.shuffle MemoryGame.emojis)
            )



-- VIEW

view : Model -> Html Msg
view model =
    div [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        , style "background-color" "#f0f2f5"
        , style "font-family" "sans-serif"
        ]
        [ div [ style "text-align" "center" ]
            [ h1 [] [ text "Memory Match" ]
            , div [ style "font-size" "1.2rem", style "margin-bottom" "10px" ]
                [ text ("Moves: " ++ String.fromInt model.moves) ]
            , button
                [ onClick RestartGame
                , style "padding" "10px 20px"
                , style "font-size" "1rem"
                , style "background-color" "#2ecc71"
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "5px"
                , style "cursor" "pointer"
                , style "margin-bottom" "10px"
                ]
                [ text "New Game" ]
            , div
                [ style "display" "grid"
                , style "grid-template-columns" "repeat(4, 80px)"
                , style "grid-gap" "10px"
                , style "margin-top" "20px"
                ]
                (List.indexedMap viewCard model.cards)
            , if List.all (\c -> c.state == Matched) model.cards && not (List.isEmpty model.cards) then
                div [ style "margin-top" "20px", style "font-weight" "bold", style "color" "green" ]
                    [ text ("Congratulations! You matched all pairs in " ++ String.fromInt model.moves ++ " moves. Refresh to play again.") ]

              else
                text ""
            ]
        ]

viewCard : Int -> Card -> Html Msg
viewCard index card =
    let
        content =
            case card.state of
                FaceDown -> ""
                FaceUp -> card.emoji
                Matched -> card.emoji

        bgColor =
            case card.state of
                FaceDown -> "#3498db"
                FaceUp -> "#ffffff"
                Matched -> "#2ecc71"

        cursorStyle =
            if card.state == FaceDown then "pointer" else "default"
    in
    div
        [ onClick (CardClicked index)
        , style "width" "80px"
        , style "height" "80px"
        , style "background-color" bgColor
        , style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "font-size" "2rem"
        , style "border-radius" "8px"
        , style "cursor" cursorStyle
        , style "box-shadow" "0 4px 6px rgba(0,0,0,0.1)"
        , style "user-select" "none"
        , style "transition" "transform 0.2s, background-color 0.2s"
        ]
        [ text content ]

-- MAIN

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }