module Delta.Formats.Bold exposing (decoder)

import Delta.Decode as Decode
import Json.Decode as Json


decoder : Decode.Attribute { other | bold : Bool }
decoder =
    Decode.bool "bold" (\value attrs -> { attrs | bold = value })
