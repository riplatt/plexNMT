/*var fpsComp:FPS = new FPS();
// access the framerate
trace(fpsComp.fps);*/
import mx.transitions.OnEnterFrameBeacon;

class plexNMT.as2.common.FPS {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.FPS;
	
	private var samplePoolSize:Number = 10;
	private var signal:Boolean = true;
	private var average:Number = 0;
	private var time:Number;
	private var times:Array = [];
	public var fps:Number;
	
	function FPS(){
		OnEnterFrameBeacon.init();
		MovieClip.addListener(this);
	}
	function onEnterFrame() {
		computeFps();
	}
	function computeFps() {
		if (signal == true) {
			time = getTimer();
		} else {
			times.push(getTimer()-time);
			if (times.length > samplePoolSize) {
				// we have reached full samplePool capacity,
				// each sample has a known weight now
				average -= times.shift()/samplePoolSize;
				average += times[times.length-1]/samplePoolSize;
			} else {
				// samplePool capacity not yet reached,
				// we have to recompute the average directly
				computeAverageDirectly();
			}
			fps = 1000 / average;
		}
		signal = !signal;
	}
	
	function computeAverageDirectly() {
		average = 0;
		for (var i in times) {
			average += times[i];
		}
		average = average/times.length;
	}
}