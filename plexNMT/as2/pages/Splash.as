

import com.syabas.as2.common.D;

import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.popSharedObjects;
import plexNMT.as2.common.Remote;

import mx.utils.Delegate;

class plexNMT.as2.pages.Splash {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.Splash;

	private static var reps:Number;
	private static var IntervalID:Number = null;
	
	private var keyListener:Object = null;

	// Initialization:
	public function Splash(parentMC:MovieClip) {
		
		IntervalID = setInterval(Delegate.create(this, this.wacthdog), 700);
		reps = 5;
		
		PlexData.init();
				
		popSharedObjects.getSO();
		
		this.keyListener = new Object();
		this.keyListener.onKeyDown = Delegate.create(this, this.onKeyDown);

		D.debug(D.lInfo,"Splash - Press The Blue Key to Turn This Debug Window Off...");
	}

	// Public Methods:
	public function destroy():Void {
		//Var
		IntervalID = null;
		reps = null;
		
		//Remove Listener
		Key.removeListener(keyListener);
		delete keyListener;
	}
	
	// Private Methods
	private function wacthdog() {
		D.debug(D.lDebug,"Splash - Shared Object: " + popSharedObjects.strSharedObjectState);
		
		switch (popSharedObjects.strSharedObjectState) {
			case "new":
				clearInterval(IntervalID);
				D.debug(D.lInfo,"Splash - First Run, no Saved Settings Going to Settings Page...");
				this.loadPage("settings");
				break;
			case "retrieved":
				clearInterval(IntervalID);
				if(PlexData.oSettings.url == null){
					D.debug(D.lInfo,"Splash - PLEX Server URL Not Set Going to Settings Page...");
					this.loadPage("settings");
				} else {
					D.debug(D.lInfo,"Splash - Useing PLEX Server:" + PlexData.oSettings.url + " and Going to " + PlexData.oPage.current + " Page..");
					this.loadPage(PlexData.oPage.current);
				}
				break;
			default:
				if(reps == 0) {
					clearInterval(IntervalID);
					D.debug(D.lInfo,"Splash - Shared Objects Not Responding Going to Settings Page..");
					this.loadPage("settings");
				} else {
					D.debug(D.lDebug,"Splash - Waiting of Shared Objects, Watchdog: " + reps);
					reps--;
				}
		}
		if(PlexData.oSettings.debugLevel == 0){
			D.mc._visible = false;
			D.destroy();
		}
	}
	
	private function loadPage(page:String):Void {
		
		destroy();
		D.debug(D.lDev,"Splash - PlexData.oPage.current: " + PlexData.oPage.current);
		D.debug(D.lDebug,"Splash - Loading Page: " + page);
		if(page == null){
			page = "main";
		}
		gotoAndPlay(page);
		
	}

	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();

		switch (keyCode)
		{
			case Remote.HOME:
				this.loadPage("main");
			break;
			case Remote.YELLOW:
				this.loadPage("settings");
			break;
		}
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
			if (i != "plex"){
				//trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
				if (typeof(_obj[i]) == "object" || typeof (_obj[i]) == "movieclip"){
					cleanUp(_obj[i]);
				}
				if (typeof(_obj[i]) == "movieclip"){
					//trace("Removing: " + _obj[i]);
					_obj[i].removeMovieClip();
					delete _obj[i];
				}
			}
		}
	}
	
	
	private function var_dump(_obj:Object) {
		//trace("Doing var_dump...");
		//trace(_obj);
		//trace("Looping Through _obj...");
		for (var i in _obj) {
			//D.debug(D.lInfo,"key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object" || typeof(_obj[i]) == "movieclip") {
				var_dump(_obj[i]);
			}
			trace("end: " + i);
		}
	}
}