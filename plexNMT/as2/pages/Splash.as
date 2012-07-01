

import com.syabas.as2.common.D;

import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.popSharedObjects;

import mx.utils.Delegate;

class plexNMT.as2.pages.Splash {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.Splash;
	//public var plexData:PlexData = null;
	
	private var strSplashTxt;
	//private var objSO:popSharedObjects;
	private static var reps:Number;
	private static var IntervalID:Number = null;

	// Initialization:
	public function Splash(parentMC:MovieClip) {
		//objSO:popSharedObjcets;
		
		IntervalID = setInterval(Delegate.create(this, this.wacthdog), 700);
		reps = 5;
		
		PlexData.init();
		
		popSharedObjects.getSO();

		D.debug(D.lInfo,"Splash - Press The Blue Key to Turn This Debug Window Off...");
	}

	// Public Methods:
	public static function destroy():Void {
		//Var
		IntervalID = null;
		reps = null;
	}
	
	// Private Methods
	private function wacthdog() {
		var strSplashTxt:String;
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
	}
	
	private function loadPage(page:String):Void {
		
		destroy();
		//trace("Going to page " + page);
		if(page == ""){
			page = "main";
		}
		gotoAndPlay(page);
		
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