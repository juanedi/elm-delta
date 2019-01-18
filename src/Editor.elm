module Editor exposing
    ( Attributes
    , Content
    , decoder
    )

import Delta exposing (Delta)
import Delta.Decode as Decode
import Delta.Formats.Bold as Bold
import Delta.Formats.Italics as Italics
import Delta.Formats.List as List
import Json.Decode exposing (Decoder)


type alias Content =
    Delta Attributes


type alias Attributes =
    { bold : Bool
    , italics : Bool
    , list : List.Style
    }


empty : Attributes
empty =
    { bold = False
    , italics = False
    , list = List.None
    }


decoder : Decoder Content
decoder =
    Decode.delta
        (Decode.into empty
            |> Decode.with Bold.decoder
            |> Decode.with Italics.decoder
            |> Decode.with List.decoder
        )
