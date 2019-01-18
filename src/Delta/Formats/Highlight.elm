module Delta.Formats.Highlight exposing (Value(..), decoder)

import Delta.Decode as Decode
import Json.Decode as Json


type Value
    = NoHighlight
    | Highlight Id


type Id
    = Id Int


decoder : Decode.Attribute { other | highlight : Value }
decoder =
    Decode.attr
        "highlight"
        (Json.andThen
            (\id ->
                Json.succeed (\attrs -> { attrs | highlight = Highlight (Id id) })
            )
            Json.int
        )
