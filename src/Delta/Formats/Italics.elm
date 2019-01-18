module Delta.Formats.Italics exposing (decoder)

import Delta.Decode as Decode
import Json.Decode as Json


decoder : Decode.Attribute { other | italics : Bool }
decoder =
    Decode.bool "italics" (\value attrs -> { attrs | italics = value })
