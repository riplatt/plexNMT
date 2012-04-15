
/*import flash.display.*;
import flash.events.*;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.Timer;*/

import plexNMT.as2.substrate.*;

/**
 * The main implementation of the Substrate project
 * @author Oliver Salzburg - Original implementation by Jared Tarbell
 */
class plexNMT.as2.substrate.Substrate extends MovieClip {
	
	// Main application settings
	
	public static const CANVAS_BACKGROUND_COLOR:Number 	= 0xFFFFFFFF;
	public static const ROAD_COLOR:Number 				= 0xFF000000;
	
	public static const ITERATIONS_PER_UPDATE:Number 		= 1;
	
	public static const CANVAS_SIZE_X:Number 				= 1280;
	public static const CANVAS_SIZE_Y:Number 				= 720;
	
	public static const MAX_CRACKS:Number 				= 350; // The maximum number of crack instances that can ever exist at a time
	public static const MAX_CRACKING:Number 			= CANVAS_SIZE_X * CANVAS_SIZE_Y >> 4; // The total maximum of cracks that will ever be spawned
	public static const INITIAL_CRACKS:Number 			= 10;
	
	// Crack settings
	
	public static const FUZZYNESS:Number 				= 0.33;
	public static const CURVE_CHANCE:Number 			= 0.05;
	public static const USE_SANDPAINTER:Boolean 		= true;
	public static const SUB_PIXEL_DRAWING:Boolean		= false;
	
	// Grid of cracks
	private static var crackgrid:Array;
	private static var cracks:Array;
	
	public static function get crackGrid():Array { return crackgrid; }
	
	private var currentCrackCount:Number 	= 0;
	private var totalCracksSpawned:Number = 0;
	
	// Timer
	private var timer:Timer;
	
	// Canvas
	private var canvas:BitmapData;
	private var canvasBitmap:Bitmap;
	
	// Stage
	private var parentMC:MovieClip = null;
	
	public function Substrate(prentMC:MovieClip):void {
		trace("Doing Substrate function...");
		this.parentMC = parentMC;
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		ColorHelper.loadPalette( );
		crackgrid = new Array( CANVAS_SIZE_X * CANVAS_SIZE_Y );
		cracks = new Array( MAX_CRACKS );
		
		canvas = new BitmapData( CANVAS_SIZE_X, CANVAS_SIZE_Y, false, CANVAS_BACKGROUND_COLOR );
		canvasBitmap = new Bitmap( canvas );
		addChild( canvasBitmap );
		
		stage.addEventListener( MouseEvent.MOUSE_UP, onClick );
		
		//loadSound();
		
		begin();
		
	}
	
	private function loadSound():void{
		var sound:Sound = new Sound( new URLRequest( "alk_mooshy.mp3" ) );
		sound.play();
	}
	
	private function onClick( e:MouseEvent ):void {
		begin();
	}
	
	private function onDraw( event:TimerEvent ):void {
		canvas.lock();
		for( var iter:Number = 0; iter < ITERATIONS_PER_UPDATE; ++iter ) {
			for( var n:Number = 0; n < currentCrackCount; ++n ) {
				var crack:Crack = cracks[ n ] as Crack;
				crack.move();
			}
		}
		canvas.unlock();
	}
	
	public function makeCrack():void {
		if( ++totalCracksSpawned >= MAX_CRACKING ) {
			timer.stop();
			begin();
		}
		if( currentCrackCount < MAX_CRACKS ) {
			// make a new crack instance
			var crack:Crack = new Crack( canvas );
			cracks[ currentCrackCount ] = crack;
			currentCrackCount++;
			
			crack.addEventListener( Crack.MAKE_CRACK, onMakeCrack );
		}
	}
	
	private function onMakeCrack( e:Event ):void {
		makeCrack();
	}

	private function begin():void {
		totalCracksSpawned = 0;
		
		// erase crack grid
		for( var y:Number = 0; y < CANVAS_SIZE_Y; ++y ) {
			for( var x:Number = 0; x < CANVAS_SIZE_X; ++x ) {
				crackgrid[ y * CANVAS_SIZE_X + x ] = 10001;
			}
		}
		// make random crack seeds
		for( var k:Number = 0; k < 16; ++k ) {
			var i:Number = Number( Math.random() * ( CANVAS_SIZE_X * CANVAS_SIZE_Y - 1 ) );
			crackgrid[ i ] = Number( Math.random() * 360 );
		}

		// make just three cracks
		currentCrackCount = 0;
		for( var crackIdx:Number = 0; crackIdx < INITIAL_CRACKS; ++crackIdx  ) {
			makeCrack();
		}
		
		canvas.fillRect( new Rectangle( 0, 0, CANVAS_SIZE_X, CANVAS_SIZE_Y ), CANVAS_BACKGROUND_COLOR );
		
		timer = new Timer( 1 );
		timer.addEventListener( TimerEvent.TIMER, onDraw );
		timer.start();
	}

}