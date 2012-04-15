
/*import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.PoNumber;*/

/**
 * A crack along the canvas
 * @author Oliver Salzburg - Original implementation by Jared Tarbell
 */
public class plexNMT.as2.substrate.Crack extends EventDispatcher {
	
	private var x:Number;
	private var y:Number;
	private var direction:Number; // Direction of travel in degrees
	private var directionStep:Number; // Stepping used to manipulate the direction each iteration
	
	private var canvas:BitmapData; // Local reference to canvas
	private var sandPaNumberer:SandPaNumberer; // SandPaNumberer instance for this crack
	
	public static const MAKE_CRACK:String = "makeCrack"; // makeCrack event
	
	/**
	 * Default constructor
	 */
	public function Crack( canvas:BitmapData ) {
		this.canvas = canvas;
		
		directionStep = 0;
		if( Math.random() < Substrate.CURVE_CHANCE ) {
			directionStep = MathHelper.randomRange( -0.2, 0.2 );
		}
		
		// find placement along existing crack
		findStart();
		
		if( Substrate.USE_SANDPAINTER ) {
			sandPaNumberer = new SandPaNumberer( canvas );
		}
	}
	
	/**
	 * Find a starting location for this crack
	 */
	private function findStart():Void {
		// pick random poNumber
		var px:Number = 0;
		var py:Number = 0;
		
		// shift until crack is found
		var found:Boolean = false;
		var timeout:Number = 0;
		while( ( !found ) || ( timeout++ > 1000 ) ) {
			px = Number( Math.random() * Substrate.CANVAS_SIZE_X );
			py = Number( Math.random() * Substrate.CANVAS_SIZE_Y );
			if( Substrate.crackGrid[ py * Substrate.CANVAS_SIZE_X + px ] < 10000 ) {
				found = true;
			}
		}
		
		if( found ) {
			// start crack
			var a:Number = Substrate.crackGrid[ py * Substrate.CANVAS_SIZE_X + px ];
			if( Math.random() < 0.5 ) {
				a -= 90 + Number( MathHelper.randomRange( -2, 2 ) );
			} else {
				a += 90 + Number( MathHelper.randomRange( -2, 2 ) );
			}
			//a = Number( Math.random() * 360 );
			startCrack( px, py, a );
		}
		
	}
	
	/**
	 * Start cracking
	 * @param	X X-coordinate to start from
	 * @param	Y Y-coordinate to start from
	 * @param	T Direction of travel (in degrees)
	 */
	private function startCrack( x:Number, y:Number, direction:Number ):Void {
		this.x = x;
		this.y = y;
		this.direction = direction;
		this.x += 0.61 * Math.cos( direction * Math.PI / 180 );
		this.y += 0.61 * Math.sin( direction * Math.PI / 180 );
	}
	
	/**
	 * Move the crack further along
	 */
	public function move():Void {
		// continue cracking
		x += 0.42 * Math.cos( direction * Math.PI / 180 );
		y += 0.42 * Math.sin( direction * Math.PI / 180 );
		
		direction += directionStep;
		
		// add fuzz
		var cx:Number = x;
		var cy:Number = y;
		if( Substrate.FUZZYNESS > 0 ) {
			cx = Number( x + MathHelper.randomRange( -Substrate.FUZZYNESS, Substrate.FUZZYNESS ) );
			cy = Number( y + MathHelper.randomRange( -Substrate.FUZZYNESS, Substrate.FUZZYNESS ) );
		}
		
		// draw sand paNumberer
		regionColor();
		
		// Draw black crack
		// I am not generating new coordinates (as in the original implementation), as i didn't see any visual difference.
		// So i re-use the coordinates already calculated.
		if( Substrate.SUB_PIXEL_DRAWING ) {
			ColorHelper.putSubPixel32( canvas, x, y, Substrate.ROAD_COLOR, 0.85 * 256 );
		} else {
			ColorHelper.putPixel32( canvas, cx, cy, Substrate.ROAD_COLOR, 0.85 * 256 );
		}
		
		// bound check
		if( ( 0 <= cx ) && ( cx < Substrate.CANVAS_SIZE_X ) && ( 0 <= cy ) && ( cy < Substrate.CANVAS_SIZE_Y ) ) {
			// safe to check
			if( ( Substrate.crackGrid[ cy * Substrate.CANVAS_SIZE_X + cx ] > 10000 ) || ( Math.abs( Substrate.crackGrid[ cy * Substrate.CANVAS_SIZE_X + cx ] - direction ) < 5 ) ) {
				// continue cracking
				Substrate.crackGrid[ cy * Substrate.CANVAS_SIZE_X + cx ] = Number( direction );
			} else if( Math.abs( Substrate.crackGrid[ cy * Substrate.CANVAS_SIZE_X + cx ] - direction ) > 2 ) {
				// crack encountered (not self), stop cracking
				findStart();
				dispatchEvent( new Event( MAKE_CRACK ) );
			}
		} else {
			// out of bounds, stop cracking
			findStart();
			dispatchEvent( new Event( MAKE_CRACK ) );
		}
	}
	
	/**
	 * Apply sand-paNumbering to the crack
	 */
	private function regionColor():Void {
		// Return if no SandPaNumberer exists or none is used
		if( sandPaNumberer == null ) return;
		
		// start checking one step away
		var rx:Number = x;
		var ry:Number = y;
		var openspace:Boolean = true;
		
		// find extents of open space
		while( openspace ) {
			// move perpendicular to crack
			rx += 0.81 * Math.sin( direction * Math.PI / 180 );
			ry -= 0.81 * Math.cos( direction * Math.PI / 180 );
			var cx:Number = Number( rx );
			var cy:Number = Number( ry );
			if( ( cx >= 0 ) && ( cx < Substrate.CANVAS_SIZE_X ) && ( cy >= 0 ) && ( cy < Substrate.CANVAS_SIZE_Y ) ) {
				// safe to check
				if( Substrate.crackGrid[ cy * Substrate.CANVAS_SIZE_X + cx ] > 10000 ) {
					// space is open
				} else {
					openspace = false;
				}
			} else {
				openspace = false;
			}
		}
		// draw sand paNumberer
		sandPaNumberer.render( rx, ry, x, y );
	}
	
	/**
	 * Returns an exact copy of the object
	 * @return An exact copy of the object
	 */
	public function clone():Crack {
		var clone:Crack = new Crack( canvas );
		clone.startCrack( x, y, direction );
		return clone;
	}
	
	/**
	 * Returns a representation of the object as a string
	 * @return A representation of the object as a string
	 */
	override public function toString():String {
		return "[object Crack]";
	}
	
}


