port module App.View exposing (..)

import Html exposing (Html, Attribute, div, text, input)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onCheck)
import Html.Lazy exposing (lazy3)
import QRCode exposing (QRCode)
import QRCode.ECLevel as ECLevel exposing (ECLevel)
import QRCode.Error exposing (Error)

import Types exposing(Model, Msg)

-- declare ports for JsBarcode interop
port encodeCode39Port : String -> Cmd msg
port encodeCode128Port : String -> Cmd msg

-- renderer types for QRCode
type Renderer
    = Canvas
    | Svg


-- default Model instance
defaultModel : Model
defaultModel =
    { base = ""
    , size = "normal"
    , renderCode39 = True
    , renderCode128 = True
    , renderQrCode = True
    }

-- view function that processes a string through the QRCode renderer and finally creates an HTML element
qrCodeView : String -> ECLevel -> Renderer -> Html msg
qrCodeView message ecLevel renderer =
    QRCode.encodeWithECLevel message ecLevel
        |> qrCodeRender renderer
        |> Result.withDefault
            (Html.text "Error while encoding to QR Code.")

-- helper function to handler QRCode processing
qrCodeRender : Renderer -> Result Error QRCode -> Result Error (Html msg)
qrCodeRender renderer =
    case renderer of
        Canvas ->
            Result.map QRCode.toCanvas

        Svg ->
            Result.map QRCode.toSvg


-- various UI helpers to reduce clutter in the view function
checkbox : (Bool -> Msg) -> Bool -> String -> Html Msg
checkbox tagger isChecked label =
    div []
        [ input [ type_ "checkbox", checked isChecked, onCheck tagger ] []
        , text label
        ]


radio : String -> Msg -> Bool -> String -> Html Msg
radio groupName msg isSelected label =
    div [ class "radio" ]
        [ input [ name groupName, type_ "radio", checked isSelected, onCheck (always msg) ] []
        , text label
        ]


radios : String -> List ( String, Msg ) -> String -> Html Msg
radios groupName namesAndMsgs selectedName =
    List.map (\( name, msg ) -> radio groupName msg (name == selectedName) name) namesAndMsgs
        |> div []


sizeOptions : List ( String, Msg )
sizeOptions =
    [ ( "smallest", Types.SizeChange "smallest" )
    , ( "small", Types.SizeChange "small" )
    , ( "normal", Types.SizeChange "normal" )
    , ( "large", Types.SizeChange "large" )
    ]

-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.Base str ->
            ( { model | base = str }, Cmd.batch [ if model.renderCode39 then encodeCode39Port str else Cmd.none
                                                , if model.renderCode128 then encodeCode128Port str else Cmd.none ] )
        Types.SizeChange str ->
            ( { model | size = str }, Cmd.none )

        Types.ToggleCode39 b ->
            ( { model | renderCode39 = b }, Cmd.none )

        Types.ToggleCode128 b ->
            ( { model | renderCode128 = b }, Cmd.none )

        Types.ToggleQrCode b ->
            ( { model | renderQrCode = b }, Cmd.none )

        _ ->
            ( model, Cmd.none )

-- VIEW
view : Model -> Html Msg
view { base, size, renderCode39, renderCode128, renderQrCode } =
    let
        showEdit h p =
            input [ class "controls-code-input", onInput h, placeholder p ] []

        placeholderText = "Any alphanumeric text can be encoded!"

        -- validateInput : String -> Maybe String
        validateInput s =
            case s of
                "" -> Nothing
                _ -> Just s

        -- checkInput : String -> Types.Base
        checkInput = (validateInput >> (\x -> Maybe.withDefault " " x) >> Types.Base)
    in
        div [ class "row app-container" ]
            [ div [ class "row controls-section" ]
                [ div [ class "row controls-header" ]
                      [ h2 [][ text "Encode text as Code39 / Code128 barcodes, and as QR Code" ] ]
                , div [ class "row controls-list" ]
                    [ div [ class "row controls-code-container" ]
                          [ div [ class "col-sm-3 input-label"][ h4 [][ text "Enter text to encode:" ] ]
                          , div [ class "col-sm-9 input-box"][ showEdit checkInput placeholderText ] ]
                    , div [ class "row controls-formatting" ]
                      [ div [ class "col-sm-6 controls-sizes" ]
                          [ div [ class "row label" ][ p [] [ text "Size: " ] ]
                          , div [class "row size-radios" ][ radios "sizebuttons" sizeOptions size ]
                          ]
                      , div [ class "col-sm-6 controls-encodings" ]
                          [ div [ class "row label" ][ p [][ text "Select any or all encoding types:" ] ]
                          , div [ class "row checkboxes" ]
                            [ div [class "col-sm-4" ][ checkbox Types.ToggleCode39 renderCode39 "Code39" ]
                            , div [ class "col-sm-4" ][ checkbox Types.ToggleCode128 renderCode128 "Code128" ]
                            , div [ class "col-sm-4" ][ checkbox Types.ToggleQrCode renderQrCode "Qr Code" ]
                            ]
                          ]
                      ]
                    ]
                ]
            , div [ class "row rendered-results-container" ]
              [ div [ class (String.append "row rendered-result code39 " size) ]
                    [ div [ class "row" ][ p [ class "label" ] [ text "Code39 Barcode:" ] ]
                    , div [ class "row" ] ( if renderCode39 then [ img [ id "barcode-code39" ][] ] else [] )
                    ]
              , div [ class (String.append "row rendered-result code128 " size) ]
                    [ div [ class "row" ][ p [ class "label" ] [ text "Code128 Barcode:" ] ]
                    , div [ class "row" ] ( if renderCode128 then [ img [ id "barcode-code128" ][] ] else [] )
                    ]
              , div [ class (String.append "row rendered-result qrcode " size) ]
                    [ div [ class "row" ][ p [ class "label" ] [ text "QR Code:" ] ]
                    , div [ class "row" ] ( if renderQrCode then [ lazy3 qrCodeView base ECLevel.Q Svg ] else [] )
                    ]
              ]
            ]
