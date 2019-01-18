module Delta.Decode exposing
    ( Attribute
    , attr
    , attributes
    , bool
    , delta
    , into
    , with
    )

import Delta exposing (..)
import Json.Decode as Json exposing (Decoder)
import Json.Encode


type Attribute attrs
    = Attribute String (Json.Decoder (attrs -> attrs))


type Config attrs
    = Config
        { empty : attrs
        , attributes : List (Attribute attrs)
        }



---- DECODING DELTAS


delta : Config attrs -> Decoder (Delta attrs)
delta config =
    Json.map Delta <|
        Json.field "ops" <|
            Json.list (op config)


attributes : Config attrs -> Decoder attrs
attributes (Config config) =
    List.foldl
        compose
        (Json.succeed config.empty)
        config.attributes



---- HELPER DECODERS


op : Config attrs -> Decoder (Op attrs)
op config =
    Json.oneOf
        [ insert config
        , delete
        , retain config
        ]


insert : Config attrs -> Decoder (Op attrs)
insert ((Config c) as config) =
    Json.map Insert <|
        Json.map2 Text
            (Json.field "insert"
                Json.string
            )
            (fieldWithDefault "attributes"
                c.empty
                (attributes config)
            )


delete : Decoder (Op attrs)
delete =
    Json.map Delete
        (Json.field "delete" Json.int)


retain : Config attrs -> Decoder (Op attrs)
retain ((Config c) as config) =
    Json.map2 Retain
        (Json.field "retain" Json.int)
        (fieldWithDefault "attributes"
            c.empty
            (attributes config)
        )


fieldWithDefault : String -> attrs -> Decoder attrs -> Decoder attrs
fieldWithDefault fieldName default valueDecoder =
    Json.maybe
        (Json.field "attributes" valueDecoder)
        |> Json.map (Maybe.withDefault default)


compose : Attribute attrs -> Decoder attrs -> Decoder attrs
compose (Attribute field setterDecoder) =
    Json.andThen
        (\attrs ->
            Json.oneOf
                [ Json.map
                    (\setter -> setter attrs)
                    (Json.field field setterDecoder)
                , Json.succeed attrs
                ]
        )



----  BUILDING ATTRIBUTE DECODERS


bool : String -> (Bool -> attrs -> attrs) -> Attribute attrs
bool field setter =
    attr
        field
        (Json.andThen
            (\value ->
                Json.succeed
                    (\attrs -> setter value attrs)
            )
            Json.bool
        )


attr : String -> Json.Decoder (attrs -> attrs) -> Attribute attrs
attr =
    Attribute



----  COMPOSING ATTRIBUTE DECODERS


into : attrs -> Config attrs
into empty =
    Config
        { empty = empty
        , attributes = []
        }


with : Attribute attrs -> Config attrs -> Config attrs
with attribute (Config config) =
    Config { config | attributes = config.attributes ++ [ attribute ] }
