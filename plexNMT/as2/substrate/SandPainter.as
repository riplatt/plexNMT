
import flash.display.BitmapData;

/**
 * The <code>SandPainter</code> places colored grains of sand along a given line
 * @author Oliver Salzburg - Original implementation by Jared Tarbell
 */
public class plexNMT.as2.substrate.SandPainter {
	
	private var color:uint;
	private var grainDistance:Number;
	
	private var canvas:BitmapData; // Local reference to the canvas
	
	/**
	 * Default constructor
	 */
	public function SandPainter( canvas:BitmapData ) {
		color = ColorHelper.somecolor();
		grainDistance = MathHelper.randomRange( 0.01, 0.1 );
		
		this.canvas = canvas;
	}
	
	/**
	 * Render a line of sand grains at a certain location
	 */
	public function render( x:Number, y:Number, ox:Number, oy:Number ):void {
		// modulate gain
		grainDistance += MathHelper.randomRange( -0.050, 0.050 );
		var maxg:Number = 1.0;
		if ( grainDistance < 0 ) grainDistance = 0;
		if ( grainDistance > maxg ) grainDistance = maxg;
		
		// calculate grains by distance
		//var grains:int = int( Math.sqrt( ( ox - x ) * ( ox - x ) + ( oy - y ) * ( oy - y ) ) );
		var grains:int = 64;
		
		// lay down grains of sand (transparent pixels)
		var w:Number = grainDistance / ( grains - 1 );
		var sineval:Number = 0;
		
		var alpha:Number = 0;
		var sine:Number = 0;
		var xpos:uint = 0;
		var ypos:uint = 0;
		
		for( var i:uint = 0; i < grains; i++ ) {
			alpha = 0.1 - i / ( grains * 10.0 );
			sine = Math.sin( Math.sin( sineval += w ) );
			xpos = ox + ( x - ox ) * sine;
			ypos = oy + ( y - oy ) * sine;
			
			// Do NOT use subpixel drawing here, it'll kill performance
			ColorHelper.putPixel32( canvas, xpos, ypos, color, alpha * 256 );
		}
	}
	
	/**
	 * Returns an exact copy of the object
	 * @return An exact copy of the object
	 */
	public function clone():SandPainter {
		var clone:SandPainter = new SandPainter( canvas );
		return clone;
	}
	
	/**
	 * Returns a representation of the object as a string
	 * @return A representation of the object as a string
	 */
	public function toString():String {
		return "[object SandPainter]";
	}
	
}

