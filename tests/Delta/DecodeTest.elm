module Delta.DecodeTest exposing (tests)

import Delta exposing (..)
import Delta.Decode as Decode
import Delta.Formats.Bold as Bold
import Delta.Formats.Italics as Italics
import Expect
import Json.Decode as Json
import Test exposing (..)


tests : Test
tests =
    describe "decoding"
        [ describe "attributes"
            [ test "defaults to no-op value if no decoders are registered" <|
                \_ ->
                    """{ "bold": true, "italics": false }"""
                        |> Json.decodeString (Decode.attributes (Decode.into empty))
                        |> Expect.equal
                            (Ok
                                { bold = False
                                , italics = False
                                }
                            )
            , test "ignores unknown attributes" <|
                \_ ->
                    """{ "unknown": null }"""
                        |> Json.decodeString (Decode.attributes (Decode.into empty))
                        |> Expect.equal
                            (Ok
                                { bold = False
                                , italics = False
                                }
                            )
            , test "lets us compose different attribute decoders" <|
                \_ ->
                    let
                        decoder =
                            Decode.attributes
                                (Decode.into empty
                                    |> Decode.with Bold.decoder
                                    |> Decode.with Italics.decoder
                                )
                    in
                    """{ "bold": true, "italics": true }"""
                        |> Json.decodeString decoder
                        |> Expect.equal
                            (Ok
                                { bold = True
                                , italics = True
                                }
                            )
            ]
        , describe "deltas" <|
            let
                decoder =
                    Decode.delta
                        (Decode.into empty
                            |> Decode.with Bold.decoder
                            |> Decode.with Italics.decoder
                        )
            in
            [ test "decodes insert operations with no attributes" <|
                \_ ->
                    """
                    { "ops": [
                        { "insert": "foo " },
                        { "insert": "bar\\n" }
                      ]
                    }
                    """
                        |> Json.decodeString decoder
                        |> Result.map Delta.ops
                        |> Expect.equal
                            (Ok
                                [ Insert (Text "foo " empty)
                                , Insert (Text "bar\n" empty)
                                ]
                            )
            , test "decodes insert operations with attributes" <|
                \_ ->
                    """
                    { "ops": [
                        { "insert": "a", "attributes" : {} },
                        { "insert": "b", "attributes" : { "bold": true } },
                        { "insert": "c", "attributes" : { "italics": true } },
                        { "insert": "d", "attributes" : { "bold": true, "italics": true } }
                      ]
                    }
                    """
                        |> Json.decodeString decoder
                        |> Result.map Delta.ops
                        |> Expect.equal
                            (Ok
                                [ Insert (Text "a" empty)
                                , Insert (Text "b" { bold = True, italics = False })
                                , Insert (Text "c" { bold = False, italics = True })
                                , Insert (Text "d" { bold = True, italics = True })
                                ]
                            )
            ]
        ]


empty : { bold : Bool, italics : Bool }
empty =
    { bold = False, italics = False }
