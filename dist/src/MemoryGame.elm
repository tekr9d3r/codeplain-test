module MemoryGame exposing
    ( Card
    , CardState(..)
    , checkMatch
    , emojis
    , getAt
    , isAlreadyMatched
    , updateCardState
    )

import Process
import Task

-- DEFINITIONS

type CardState
    = FaceDown
    | FaceUp
    | Matched

type alias Card =
    { emoji : String
    , state : CardState
    }

emojis : List String
emojis =
    [ "🐶", "🐶", "🐱", "🐱", "🐭", "🐭", "🐹", "🐹"
    , "🐰", "🐰", "🦊", "🦊", "🐻", "🐻", "🐼", "🐼"
    ]

-- LOGIC HELPERS

isAlreadyMatched : Int -> List Card -> Bool
isAlreadyMatched index cards =
    case getAt index cards of
        Just card ->
            card.state == Matched

        Nothing ->
            -- If the card doesn't exist, treat it as unclickable/matched to prevent errors
            True

getAt : Int -> List a -> Maybe a
getAt target list =
    list |> List.drop target |> List.head

updateCardState : Int -> CardState -> List Card -> List Card
updateCardState targetIdx newState cards =
    List.indexedMap
        (\i c ->
            if i == targetIdx then
                { c | state = newState }
            else
                c
        )
        cards

checkMatch : 
    { model | cards : List Card, selectedIndices : List Int, isWaiting : Bool } 
    -> (Int -> Int -> msg) 
    -> (msg -> Cmd msg) 
    -> ({ model | cards : List Card, selectedIndices : List Int, isWaiting : Bool }, Cmd msg)
checkMatch model flipBackMsg sleepToTask =
    case model.selectedIndices of
        [ i1, i2 ] ->
            let
                card1 = getAt i1 model.cards
                card2 = getAt i2 model.cards
            in
            case ( card1, card2 ) of
                ( Just c1, Just c2 ) ->
                    if c1.emoji == c2.emoji then
                        let
                            matchedCards =
                                List.indexedMap
                                    (\i c ->
                                        if i == i1 || i == i2 then
                                            { c | state = Matched }
                                        else
                                            c
                                    )
                                    model.cards
                        in
                        ( { model | cards = matchedCards, selectedIndices = [] }, Cmd.none )
                    else
                        ( { model | isWaiting = True }
                        , sleepToTask (flipBackMsg i1 i2)
                        )

                _ ->
                    ( { model | selectedIndices = [] }, Cmd.none )

        _ ->
            ( model, Cmd.none )