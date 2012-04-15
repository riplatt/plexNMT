//****************************************************************************
//Copyright (C) 2005 Adobe Systems, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
 * MobileSharedObject, Version 1
 * manages Shared Object in a Flash Lite 2 application
 */

class com.adobe.as2.MobileSharedObject {
	
	//---------------------------------------------- Properties
	private var Prefs:SharedObject;
	private var appName:String;
	private var mySORef:SharedObject;
	private var loaded:Boolean;
	private var readID:Number;
	private var writeID:Number;
	private var textPath:Object;
	
  	//---------------------------------------------- Methods
  	
  	/**
  	 * constructor method
  	 * 
  	 */
  	public function MobileSharedObject(path:String) {
		trace("Doing MobileSharedObject...");
		//trace("has Shared Objects capabilities: " + System.capabilities.hasSharedObjects); 
  		setDebug(path);														// set the path to the textfield used to show messages
  		if (System.capabilities.hasSharedObjects) {							// check to make sure handset supports Shared Objects
  			SharedObject.addListener("Prefs", loadCompleteSO);				// add a listener, because SO might not be immediately available
  			appName = "plexNMT";											// set local var with appName string
			Prefs = SharedObject.getLocal("Prefs");							// get reference to the SO, or create
			//while(SharedObject.loaded == false)
			//{}
			Prefs.path = this;												// set local property marking namespace

  		} else {
  			debug("This device may not support persistent storage, please save this app to your device and run in the standalone player to be sure.");	// if the device doesn't support Shared Objects, alert the user
  		}
  	}
  	
  	/**
  	 * loadCompleteSO method - used as a listener to the Shared Object object, fired once getLocal returns a reference
  	 * 
  	 * @param mySO	- the Shared Object reference returned from getLocal()
  	 */
  	private function loadCompleteSO(mySO:SharedObject):Void {
  		if (mySO.getSize() == 0) {											// if the SO is new
			
			mySO.path.debug("This is your first time running the app.\nCan not find any Shared Objects (Saved Data).\nPlease fill in the the ip and port");
			
			// format a timestamp
  			var now:Date = new Date();
  			var hour:Number = now.getHours();
  			var minutes:Number = now.getMinutes() > 9 ?
  						 		now.getMinutes() : "0" + now.getMinutes();
  			if (hour > 12) {
  				var timeString:String = (hour - 12) + ":" + minutes + "PM";
  			} else {
  				var timeString:String = hour + ":" + minutes + "AM";
  			}
  			
	  		mySO.data.soCreatedTime = timeString;							// set a timestamp, marking when SO was created
	  		mySO.data.firstTime = true;										// mark the first time running app
			mySO.flush();													// immediately write the timestamp to the SO
		} else {															// the SO already exists
			mySO.data.firstTime = null;										// unmark the first time running app
			delete mySO.data.firstTime;										// remove the first time var
			
			mySO.path.debug("Welcome back!");
		
		}
		mySO.path.setMarker();
  	}
  	
  	/**
  	 * setMarker method - used to set a marker alerting that loadCompleteSO has fired and is finished
  	 * 
  	 */
  	private function setMarker():Void {
  		loaded = true;
  	}
  	
  	/**
  	 * getMarker method - used by the other methods to see if loadCompleteSO has fired and is finished
  	 * 
  	 */
  	private function getMarker():Boolean {
  		return loaded;	
  	}
  	
  	/**
  	 * readFromSO method - used to read values from the SO
  	 * 
  	 * @param name	- optional param, represents the name of single var to retrieve from SO
  	 * @return String	- representing var value(s) from SO
  	 */
  	public function readFromSO(name:String):String {
		//debug("Reading "+name+" with marker: "+getMarker());
  		if (getMarker() == true) {											// check to see if listener has fired
  			clearInterval(readID);											// clear the interval if there was one
  			var value:String = "";											// placeholder for the value from SO
	  		if (name) {														// if just looking for a single var
	  			value = Prefs.data[name];									// get value					
	  		} else {														// looking for all vars from SO
	  			for (var idx in Prefs.data) {								// loop
	  				value += idx + ":" + Prefs.data[idx] + "\n";			// retrieve value
	  			}
	  		}
	  		if (Prefs.data.firstTime == undefined) {
	  			debug("data in your SO:");
				for (var idx in Prefs.data) {
		  			debug(idx+":"+Prefs.data[idx]);					// immediately write to textfield	
				}
	  		}
			//debug("Returning "+value);
			//trace("Returning "+value)
	  		return value;
  		} else if (readID == undefined) {									// if loadCompleteSO hasn't fired, set interval
			//debug("Waiting...");
  			readID = setInterval(this, "readFromSO", 12, name);				// set an interval to call again
			//debug("readID:"+readID.toString());
  		}
  	}
  	
  	/**
  	 * writeToSO method - used to write a name/value pair to the SO
  	 * 
  	 * @param name		- the name of the name/value pair
  	 * @param value		- the value of the name/value pair
  	 * @return Boolean	- whether flush was successful
  	 */
  	public function writeToSO(name:String, value:String):Boolean {
		//debug("Writing "+name+":"+value);
  		if (getMarker() == true) {											// check to see if listener has fired
  			clearInterval(writeID);											// clear the interval if there was one
  			Prefs.data[name] = value;										// set the name/value in SO
	  		var status = Prefs.flush();										// write to Shared Object immediately
	  		if (status == true) {											// check status of flush()
	  			return true;												// flush() was successful
	  		} else if (status == "pending") {								// if flush() is pending
	  			// more space needed
	  			// onStatus fired
	  			return false;												// return false and check the onStatus method
	  		} else if (status == false) {									// if flush() failed
	  			return false;	
	  		}
  		} else if (writeID == undefined) {									// if loadCompleteSO hasn't fired, set interval
  			writeID = setInterval(this, "writeToSO", 12, name, value);		// set an interval to call again
  		}
  	}
  	
  	/**
  	 * onStatus method - fired from a flush() return equal to pending, could be a result of more storage space needed
  	 * 
  	 * @return Boolean	- whether flush() ends in success or failure
  	 */
  	private function onStatus(infoObject:Object):Boolean {					// onStatus is fired when flush() returns "pending"
  		if (infoObject.code == "SharedObject.Flush.Success") {				// if flush() ends in success
  			return true;
  		} else if (infoObject.code == "SharedObject.Flush.Failed") {		// if flush() ends in failure
  			return false;
  		}
  	}
  	
  	/**
  	 * emptySO method - used to empty the SO, but not delete it from the disk
  	 * 
  	 */
  	public function emptySO():Void {
  		for (var idx in Prefs.data) {
  			Prefs.data[idx] = null;
  			delete Prefs.data[idx];	
  		}
  	}
  	
  	/**
  	 * removeSO method - used to empty and then delete SO from the disk
  	 * 
  	 */
  	public function removeSO():Void {
  		Prefs.clear();	
  	}
  	
  	/**
  	 * getSize method - used to retrieve the current size of the SO
  	 *
  	 * @return Number	- number of kb of SO 
  	 */
  	public function getSize():Number {
  		return Prefs.getSize();	
  	}
  	
  	/**
  	 * setDebug method - used to set the path to the textfield to write messages to
  	 * 
  	 * @param name - textfield path
  	 */
  	private function setDebug(path:String):Void {
		//trace("MobileSharedObject.setDebug: " + path);
  		textPath = path;
  	}
  	
  	/**
  	 * debug method - used to write strings to a textfield
  	 * 
  	 * @param message - the string to write to the textfield
  	 */
  	public function debug(message:String):Void {
		//trace("Writing Debug Message: " + message);
		//trace(eval(textPath));
  		eval(textPath).text += message + "\n";
		//_level0.settingsMC.out_0.text += message + "\n";
  	}
}