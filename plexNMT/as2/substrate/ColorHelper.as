import flash.display.Bitmap;
import flash.display.BitmapData;

/**
 * General helper functions to help dealing with colors
 * @author Oliver Salzburg - Original implementation by Jared Tarbell
 */
public class plexNMT.as2.substrate.ColorHelper {
	
	/*
	[Embed(source='../../../../assets/palette.png')]
	public static var Palette:Class;
	*/
	
	// Palette parameters
	private static const MAX_PALETTE_SIZE:Number = 512;
	private static var palette:Array = new Array();
	
	private static function get paletteSize():Number { return palette.length; }
	
	/**
	 * Construct Number color value from RGB values
	 * <p>Alpha will be set to 255</p>
	 * @param	r Red phase (0-255)
	 * @param	g Green phase (0-255)
	 * @param	b Blue phase (0-255)
	 * @return An Number representing the requested color
	 */
	public static function fromRGB( r:Number, g:Number, b:Number ):Number {
		return fromRGBA( r, g, b, 255 );
	}
	
	/**
	 * Construct Number color value from RGB values
	 * @param	r Red phase (0-255)
	 * @param	g Green phase (0-255)
	 * @param	b Blue phase (0-255)
	 * @param	a Alpha phase (0-255)
	 * @return An Number representing the requested color
	 */
	public static function fromRGBA( r:Number, g:Number, b:Number, a:Number ):Number {
		return ( a << 24 ) | ( r << 16 ) | ( g << 8 ) | b;
	}
	
	/**
	 * Extract the alpha value from a given color
	 * @param	color The given color
	 * @return The alpha value
	 */
	public static function getA( color:Number ):Number {
		return color >> 24 & 0xFF;
	}
	
	/**
	 * Extract the red value from a given color
	 * @param	color The given color
	 * @return The red value
	 */
	public static function getR( color:Number ):Number {
		return color >> 16 & 0xFF;
	}
	
	/**
	 * Extract the green value from a given color
	 * @param	color The given color
	 * @return The green value
	 */
	public static function getG( color:Number ):Number {
		return color >> 8 & 0xFF;
	}
	
	/**
	 * Extract the blue value from a given color
	 * @param	color The given color
	 * @return The blue value
	 */
	public static function getB( color:Number ):Number {
		return color & 0xFF;
	}
	
	/**
	 * Format an Number so that it is easier readable
	 * @param	color The given color
	 * @return A nice string describing the color
	 */
	public static function RGBtoString( color:Number ):String {
		return "A:" + getA( color ) + " R:" + getR( color ) + " G:" + getG( color ) + " B:" + getB( color );
	}
	
	/**
	 * Blend two colors based on a given alpha value
	 * @param	src The source color value
	 * @param	dst The destination color value
	 * @param	alpha The alpha value to use for blending (0-255)
	 * @return The blended color
	 */
	public static function blend( src:Number, dst:Number, alpha:Number ):Number {
		return ColorHelper.fromRGB( ( alpha * ColorHelper.getR( dst ) + ( 256 - alpha ) * ColorHelper.getR( src ) ) >> 8,
																( alpha * ColorHelper.getG( dst ) + ( 256 - alpha ) * ColorHelper.getG( src ) ) >> 8,
																( alpha * ColorHelper.getB( dst ) + ( 256 - alpha ) * ColorHelper.getB( src ) ) >> 8 );
	}
	
	/**
	 * Puts a pixel on a canvas
	 * @param	canvas The canvas to use
	 * @param	x The x-coordinate
	 * @param	y The y-coordinate
	 * @param	color The color to put on the canvas
	 * @param	alpha The alpha value to use
	 */
	public static function putPixel32( canvas:BitmapData, x:Number, y:Number, color:Number, alpha:Number ):void {
		if( alpha > 255 ) alpha = 255;
		var srcColor:Number = canvas.getPixel32( x, y );
		var newColor:Number = blend( srcColor, color, alpha );
		canvas.setPixel32( x, y, newColor );
	}
	
	/**
	 * Puts a pixel on a canvas whith subpixel accuracy
	 * <p>Looking at the results of this function, the approach seems questionable.
	 * Further investigation and correction of the implementation is in order</p>
	 * @param	canvas The canvas to use
	 * @param	x The x-coordinate
	 * @param	y The y-coordinate
	 * @param	color The color to put on the canvas
	 * @param	alpha The alpha value to use
	 */
	public static function putSubPixel32( canvas:BitmapData, x:Number, y:Number, color:Number, alpha:Number ):void {
		var xweight:Number = x - Number( x );
		var yweight:Number = y - Number( y );
		var xweightn:Number = 1 - xweight;
		var yweightn:Number = 1 - yweight;
		
		var alpha0:Number = ( xweightn 	* yweightn ) * alpha;
		var alpha1:Number = ( xweight 	* yweightn ) * alpha;
		var alpha2:Number = ( xweightn 	* yweight  ) * alpha;
		var alpha3:Number = ( xweight 	* yweight  ) * alpha;
		
		putPixel32( canvas, x + 0, y + 0, color, alpha0 );
		putPixel32( canvas, x + 1, y + 0, color, alpha1 );
		putPixel32( canvas, x + 0, y + 1, color, alpha2 );
		putPixel32( canvas, x + 1, y + 1, color, alpha3 );
	}
	
	/**
	 * Returns a random color from the palette
	 * @return A random color from the palette
	 */
	public static function somecolor():Number {
		// pick some random good color
		var color:Number = palette[ Number( Math.random() * paletteSize ) ];
		return color;
	}

	/**
	 * Loads and image and constructs the palette from it
	 */
	public static function loadPalette( ):void {
		trace("Doing loadPalette function...");
		palette.push( 0x3a242b, 0x3b2426, 0x352325, 0x836454, 0x7d5533, 0x8b7352, 0xb1a181, 0xa4632e, 0xbb6b33, 0xb47249, 0xca7239, 0xd29057, 0xe0b87e, 0xd9b166, 0xf5eabe, 0xfcfadf, 0xd9d1b0, 0xfcfadf, 0xd1d1ca, 0xa7b1ac, 0x879a8c, 0x9186ad, 0x776a8e, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF );
		return;
		/*
		var bitmap:Bitmap = new Palette() as Bitmap;
		
		for( var x:Number = 0; x < bitmap.width; ++x ) {
			for( var y:Number = 0; y < bitmap.height; ++y ) {
				var c:Number = bitmap.bitmapData.getPixel32( x, y );
				var exists:Boolean = false;
				for( var n:Number = 0; n < paletteSize; ++n ) {
					if( c == palette[ n ] ) {
						exists = true;
						break;
					}
				}
				if( !exists ) {
					// add color to pal
					if( paletteSize < MAX_PALETTE_SIZE ) {
						palette.push( c );
						if( paletteSize >= MAX_PALETTE_SIZE ) return;
					}
				}
			}
		}
		*/
	}

	
	/**
	 * Returns an exact copy of the object
	 * @return An exact copy of the object
	 */
	public function clone():ColorHelper {
		var clone:ColorHelper = new ColorHelper();
		return clone;
	}
	
	/**
	 * Returns a representation of the object as a string
	 * @return A representation of the object as a string
	 */
	public function toString():String {
		return "[object ColorHelper]";
	}
	
}
	

