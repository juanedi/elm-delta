module Delta.Formats.Highlight exposing (Value(..), decoder, highlight)

import Delta exposing (Delta, Range)
import Delta.Decode as Decode
import Json.Decode as Json


type Value
    = NoHighlight
    | Highlight Id


type alias Id =
    Int


type State
    = State { nextId : Id }


type alias Attributes other =
    { other | highlight : Value }


init : State
init =
    State { nextId = 1 }


highlight : Range -> State -> Delta (Attributes other) -> ( Delta (Attributes other), State )
highlight range (State { nextId }) delta =
    ( Delta.format
        range
        (\attrs -> { attrs | highlight = Highlight nextId })
        delta
    , State { nextId = nextId + 1 }
    )


decoder : Decode.Attribute (Attributes other)
decoder =
    Decode.attr
        "highlight"
        (Json.andThen
            (\id ->
                Json.succeed (\attrs -> { attrs | highlight = Highlight id })
            )
            Json.int
        )
