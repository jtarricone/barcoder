module Types exposing (..)

type Msg
    = NoOp
    | Base String
    | SizeChange String
    | ToggleCode39 Bool
    | ToggleCode128 Bool
    | ToggleQrCode Bool


type alias Model =
    { base : String
    , size : String
    , renderCode39 : Bool
    , renderCode128 : Bool
    , renderQrCode : Bool
    }
