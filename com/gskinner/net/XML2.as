/**
* XML2 by Grant Skinner. Feb 27, 2004
* Updated Jan 2, 2005 to separate timeout and connectionTimeout
* Updated Nov 25, 2005 to work around Flash 8 "load" event bug, and support onHTTPStatus
* Visit www.gskinner.com for documentation, updates and more free code.
*
* You may distribute this code freely, as long as this comment block remains intact.
*/

import mx.events.EventDispatcher;

class com.gskinner.net.XML2 extends XML {
// define public properties:
	public var connectionTimeout:Number = 6000;
	public var timeout:Number = 30000;
	public var obj:Object = {};
	
// define private properties:
	private var tmp_connectionTimeoutID:Number;
	private var tmp_timeoutID:Number;
	
// define functions for EventDispatcher:
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	
// initialization:
	public function XML2(p_xml:String) {
		super(p_xml);
		EventDispatcher.initialize(this);
	}
	
// public methods:
	public function load(p_url:String):Void {
		setTimeouts();
		super.load(p_url);
	}
	
	public function sendAndLoad(p_url:String,p_targetXML:XML):Void {
		setTimeouts();
		super.sendAndLoad(p_url,p_targetXML);
	}
	
// private methods:
	private function setTimeouts():Void {
		clearTimeouts();
		tmp_connectionTimeoutID = setInterval(this,"onConnectionTimeout",connectionTimeout);
		tmp_timeoutID = setInterval(this,"onTimeout",timeout);
	}
	
	private function clearTimeouts():Void {
		clearInterval(tmp_connectionTimeoutID);
		clearInterval(tmp_timeoutID);
		delete(tmp_connectionTimeoutID);
		delete(tmp_timeoutID);
	}
	
	private function onLoad(p_success:Boolean):Void {
		if (!tmp_timeoutID) { return; }
		clearTimeouts();
		dispatchEvent({target:this, type:"complete", success:p_success, obj:obj});
	}
	
	private function onHTTPStatus(p_status:Number):Void {
		dispatchEvent({target:this,type:"httpStatus",httpStatus:p_status, obj:obj});
	}
	
	private function onTimeout():Void {
		trace("timeout");
		clearTimeouts();
		status = -100;
		dispatchEvent({target:this,type:"complete",success:false});
	}
	
	private function onConnectionTimeout():Void {
		if (getBytesTotal() != undefined && getBytesLoaded() > 0) { clearInterval(tmp_connectionTimeoutID); return; }
		clearTimeouts();
		status = -101;
		dispatchEvent({target:this,type:"complete",success:false});
	}
}