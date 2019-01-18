module Delta exposing
    ( Blot(..)
    , Delta(..)
    , Op(..)
    , Range
    , format
    , ops
    )

import Json.Decode as Decode exposing (Decoder)


type Delta attrs
    = Delta (List (Op attrs))


type Op attrs
    = Insert (Blot attrs)
    | Delete Int
    | Retain Int attrs


type Blot attrs
    = -- TODO: support other types of inserts
      Text String attrs


type alias Range =
    { index : Int, length : Int }


ops : Delta attrs -> List (Op attrs)
ops (Delta operations) =
    operations


format : Range -> (attrs -> attrs) -> Delta attrs -> Delta attrs
format range fun delta =
    -- TODO: not implemented yet!
    delta
