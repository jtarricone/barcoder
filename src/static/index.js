Object.assign = require('object-assign');

// pull in desired CSS/SASS files
require( './styles/main.scss' );
var JsBarcode = require( 'jsbarcode' );
var $ = jQuery = require( '../../node_modules/jquery/dist/jquery.js' );
require( '../../node_modules/bootstrap-sass/assets/javascripts/bootstrap.js' );

// instantiate & embed Elm app
var Elm = require( '../elm/Main' );
elmApp = Elm.Barcoder.embed( document.getElementById( 'main' ) );

// declare Elm ports
elmApp.ports.encodeCode128Port.subscribe(encodeCode128Barcode);
elmApp.ports.encodeCode39Port.subscribe(encodeCode39Barcode);
elmApp.ports.saveImagePort.subscribe(saveImage);

/* since this is such a simple interaction it's arguably preferable
    to just define the functions here rather than in static/js/[...] */
function encodeCode128Barcode(code) {
    JsBarcode("#barcode-code128",
              code,
              {
                  format: "code128",
                  font: "OCR-B",
                  displayValue: true
              });
}

function encodeCode39Barcode(code) {
    JsBarcode("#barcode-code39",
              code,
              {
                  format: "code39",
                  font: "OCR-B",
                  displayValue: true
              });
}
