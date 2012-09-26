import com.syabas.as2.common.D;

import com.designvox.tranniec.JSON;

import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;

class plexNMT.as2.common.popSharedObjects {
	
	//---------------------------------------------- Properties
	
	public static var strSharedObjectState:String;
	
	private static var oShdObj:SharedObject;
	//private var strSharedObjectState:String;
	
	//---------------------------------------------- Methods
	
  	public function popSharedObjects() {
		trace("Doing popSharedObjects...");
		
  	}
	
	public static function getSO(){
		trace("Doing getSO...");
		strSharedObjectState = "pending"
  		if (System.capabilities.hasSharedObjects) {							// check to make sure handset supports Shared Objects
			strSharedObjectState = "supported"
  			SharedObject.addListener("plexNMT_Prefs", fnShdObjLoaded);		// add a listener, because SO might not be immediately available
			trace("Reading Shared Objects...");
			oShdObj = SharedObject.getLocal("plexNMT_Prefs");					// get reference to the SO, or create
			//oShdObj.path = this;												// set local property marking namespace

  		} else {
  			//debug("This device may not support persistent storage, please save this app to your device and run in the standalone player to be sure.");	// if the device doesn't support Shared Objects, alert the user
			strSharedObjectState = "not supported"
  		}
	}
	
	public static function savePlexData() {
		
		D.debug(D.lInfo,"SharedObjects - Saving Data to Shared Objects...");
		clearSO();
		var jString:String = JSON.stringify(PlexData.oSettings);
		trace("SharedObjects - jString:" + jString);
		writeToSO("plexSettings", jString);
		
	}
	
	private static function fnShdObjLoaded (oShared:SharedObject ) {
		trace("Doing fnShdObjLoaded:" + oShared.getSize() +"...");
		if (oShared.getSize() == 0)
		{
			//Initialize the shared object here.
			writeToSO("status", "Old");
			strSharedObjectState = "new"
		}
		else
		{
			//Access the shared object data properties here.
			strSharedObjectState = readFromSO("status"); //"found"
			getPlexData()
		}
	}
	
	private static function getPlexData() {
		
		D.debug(D.lDebug,"SharedObjects - plexIP: " + readFromSO("plexIP"));
		trace("SharedObjects - plexIP: " + readFromSO("plexIP"));
		var jString:String = readFromSO("plexSettings");
		trace("SharedObjects - jString:" + jString)
		if (jString != undefined){var objSettings:Object = JSON.parse(jString);}
		//var objSettings:Object = JSON.parse(readFromSO("plexSettings"));
		D.debug(D.lDebug,Utils.varDump(objSettings));
		
		/*if(objSettings.ip != undefined)
		{
			PlexData.oSettings = objSettings;
			strSharedObjectState = "retrieved"
		} else {
			strSharedObjectState = "new"
		}*/
		
		PlexData.oSettings.ip = readFromSO("plexIP");
		PlexData.oSettings.port = readFromSO("plexPort");
		PlexData.oSettings.debugLevel = (readFromSO("debugLevel") == undefined ? PlexData.oSettings.debugLevel : readFromSO("debugLevel"));
		PlexData.oSettings.url = (readFromSO("plexIP") == undefined ? PlexData.oSettings.url : "http://"+PlexData.oSettings.ip+":"+PlexData.oSettings.port+"/");
		PlexData.oWall.movies.columns = (readFromSO("wallCol") == undefined ? PlexData.oWall.movies.columns : readFromSO("wallCol"));
		PlexData.oWall.movies.rows = (readFromSO("wallRow") == undefined ? PlexData.oWall.movies.rows : readFromSO("wallRow"));
		PlexData.oPage.current = (readFromSO("currentPage") == undefined ? PlexData.oPage.curren : readFromSO("currentPage"));
		strSharedObjectState = "new"
		
		
	}
	
	
	public static function readFromSO(name:String):String {

  			var value:String = "";											// placeholder for the value from SO
	  		if (name) {														// if just looking for a single var
	  			value = oShdObj.data[name];									// get value					
	  		} else {														// looking for all vars from SO
	  			for (var idx in oShdObj.data) {								// loop
	  				value += idx + ":" + oShdObj.data[idx] + "\n";			// retrieve value
	  			}
	  		}
	  		return value;

  	}
	
	public static function writeToSO(name:String, value:String):Boolean {

  			oShdObj.data[name] = value;										// set the name/value in SO
	  		var status = oShdObj.flush();										// write to Shared Object immediately
	  		if (status == true) {											// check status of flush()
	  			return true;												// flush() was successful
	  		} else if (status == "pending") {								// if flush() is pending
	  			// more space needed
	  			// onStatus fired
	  			return false;												// return false and check the onStatus method
	  		} else if (status == false) {									// if flush() failed
	  			return false;	
	  		}
  	}
	
	public static function clearSO():Void {

  			oShdObj.clear();
  	}
}