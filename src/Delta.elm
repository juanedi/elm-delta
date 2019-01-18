module Delta exposing
    ( Blot(..)
    , Delta(..)
    , Op(..)
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


ops : Delta attrs -> List (Op attrs)
ops (Delta operations) =
    operations
