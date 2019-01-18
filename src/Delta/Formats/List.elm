module Delta.Formats.List exposing
    ( Style(..)
    , decoder
    )

import Delta.Decode as Decode
import Json.Decode as Json


type Style
    = None
    | Bullet
    | Ordered


decoder : Decode.Attribute { other | list : Style }
decoder =
    Decode.attr
        "list"
        (Json.andThen
            (\style ->
                case style of
                    "bullet" ->
                        Json.succeed (\attrs -> { attrs | list = Bullet })

                    "ordered" ->
                        Json.succeed (\attrs -> { attrs | list = Ordered })

                    listStyle ->
                        Json.fail <| "Unsupported list style \"" ++ listStyle ++ "\""
            )
            Json.string
        )
