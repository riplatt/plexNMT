
import com.adobe.as2.MobileSharedObject;
import com.syabas.as2.common.VirtualKeyboard;
import mx.utils.Delegate;

import plexNMT.as2.common.Settings;
import plexNMT.as2.common.Remote;

class plexNMT.as2.pages.SettingsPage {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.SettingsPage;
	
	// Public Properties:
	public static var mySO:MobileSharedObject = null;
	// Private Properties:
	private var vk:VirtualKeyboard = null;
	private var arr:Array = new Array();
	private var kl:Object = null;
	private var settings:Object = new Object;
	private var mainMC:MovieClip = null;
	private var index:Number = 0;
	//private var acLib:LoadVars = null;
	private var inputText1:TextField = null;
	private var inputText2:TextField = null;
	private var inputText3:TextField = null;
	private var inputText4:TextField = null;
	private var output_txt:TextField = null;
	
	public function destroy() {
		//Destroy Movie Clips
		cleanUp(this.mainMC);
		
		//Text Fields
		this.mainMC.inputText1.removeTextField();
		this.inputText1 = null;
		this.mainMC.inputText2.removeTextField();
		this.inputText2 = null;
		this.mainMC.inputText3.removeTextField();
		this.inputText3 = null;
		this.mainMC.inputText4.removeTextField();
		this.inputText4 = null;
		this.mainMC.output_txt.removeTextField();
		this.output_txt = null;
		
		//Objects
		this.kl = null;
		delete kl;
		this.settings = null;
		delete settings;
	}
	// Initialization:
	public function SettingsPage(parentMC:MovieClip) {
		
		trace("Doing Settings Page...");
		this.mainMC = parentMC;
		
		var so:Settings = new Settings("Settings");
		settings = so.getValue();
		
		var myFmt:TextFormat = new TextFormat(); 
		myFmt.color = 0x000000;
		myFmt.size = 21;

		this.mainMC.createTextField("inputText1", this.mainMC.getNextHighestDepth(), 50, 50, 250, 27);
		this.mainMC.inputText1.type = "input";
		this.mainMC.inputText1.background = true;
		this.mainMC.inputText1.backgroundColor = 0xFFFFFF;
		//this.mainMC.inputText1.text = "Hello World"
		this.mainMC.inputText1.setNewTextFormat(myFmt);
		this.mainMC.attachMovie("cursor", "cursor1", this.mainMC.getNextHighestDepth(), {_x:52, _y:50, _alpha:0});
		
		this.mainMC.createTextField("inputText2", this.mainMC.getNextHighestDepth(), 50, 87, 250, 27);
		this.mainMC.inputText2.type = "input";
		this.mainMC.inputText2.background = true;
		this.mainMC.inputText2.backgroundColor = 0xFFFFFF;
		this.mainMC.inputText2.setNewTextFormat(myFmt);
		this.mainMC.attachMovie("cursor", "cursor2", this.mainMC.getNextHighestDepth(), {_x:52, _y:87, _alpha:0});
		
		this.mainMC.createTextField("inputText3", this.mainMC.getNextHighestDepth(), 50, 124, 250, 27);
		this.mainMC.inputText3.type = "input";
		this.mainMC.inputText3.background = true;
		this.mainMC.inputText3.backgroundColor = 0xFFFFFF;
		this.mainMC.inputText3.setNewTextFormat(myFmt);
		this.mainMC.attachMovie("cursor", "cursor3", this.mainMC.getNextHighestDepth(), {_x:52, _y:124, _alpha:0});
		
		this.mainMC.createTextField("inputText4", this.mainMC.getNextHighestDepth(), 50, 161, 250, 27);
		this.mainMC.inputText4.type = "input";
		this.mainMC.inputText4.background = true;
		this.mainMC.inputText4.backgroundColor = 0xFFFFFF;
		this.mainMC.inputText4.setNewTextFormat(myFmt);
		this.mainMC.attachMovie("cursor", "cursor4", this.mainMC.getNextHighestDepth(), {_x:52, _y:161, _alpha:0});
		
		this.mainMC.createTextField("output_txt", this.mainMC.getNextHighestDepth(), 50, 198, 250, 250);
		this.mainMC.output_txt.background = true;
		this.mainMC.output_txt.backgroundColor = 0xFFFFFF;
		this.mainMC.output_txt.multiline = true;
		this.mainMC.output_txt.wordWrap = true;
		//this.mainMC.output_txt.text = "Bobby";
		trace(this.mainMC.output_txt);
		
		// push available input text field in an array.
		this.arr.push( { t:this.mainMC.inputText1, c:this.mainMC.cursor1, key:"plexIP" } )
		this.arr.push( { t:this.mainMC.inputText2, c:this.mainMC.cursor2, key:"plexPort" } )
		this.arr.push( { t:this.mainMC.inputText3, c:this.mainMC.cursor3, key:"wallC" } )
		this.arr.push( { t:this.mainMC.inputText4, c:this.mainMC.cursor4, key:"wallR" } )
		
		// create an instance of the MobileSharedObject class
		//var mySO:MobileSharedObject = new MobileSharedObject("this.mainMC.output_txt");
		mySO = new MobileSharedObject("output_txt");
		// write a var to the Shared Object
		mySO.writeToSO("popbox", "pch:C-200");
		// set textfield equal to SO data
		mySO.readFromSO();
		
		if (System.capabilities.hasSharedObjects) {
			// show the current time
			// note the current time
			var now:Date = new Date();
			var hour:Number = now.getHours();
			var minutes:Number = now.getMinutes() > 9 ?
								now.getMinutes() : "0" + now.getMinutes();
			if (hour > 12) {
				var timeString:String = (hour - 12) + ":" + minutes + "PM";
			} else {
				var timeString:String = hour + ":" + minutes + "AM";
			}
			
			mySO.debug("current time = " + timeString + "\n");
		}

		this.initKB();
	}
	
	private function initKB():Void
	{
		// Loading Auto Complete dictionary.
		/*this.acLib = new LoadVars();
		this.acLib.load("ac.txt");*/
		
		var myFmt:TextFormat = new TextFormat(); 
		myFmt.color = 0xFF0000; 
		myFmt.underline = true; 
		
		this.mainMC.inputText1.setTextFormat(myFmt);

		var kbBaseMC:MovieClip = this.mainMC.createEmptyMovieClip("kbBaseMC", this.mainMC.getNextHighestDepth());
		kbBaseMC._x = 310;
		kbBaseMC._y = 40;

		var vkObj:Object = new Object()
		vkObj.parentMC = kbBaseMC;
		vkObj.maxLength = 128;
		// vkObj.alphanumeric = VKGenericTest.ALPHANUM;
		// vkObj.alphanumeric_capital = VKGenericTest.ALPHANUM_CAPITAL;
		// vkObj.symbol = VKGenericTest.SYMBOL;
		// vkObj.specialcharacter = VKGenericTest.SPECIAL_CHAR;
		// vkObj.specialcharacter_capital = VKGenericTest.SPECIAL_CHAR_CAPITAL;
		// vkObj.rSize = 4;
		// vkObj.cSize = 14;
		// vkObj.showPassword = true;
		vkObj.keyDownCB = Delegate.create(this, this.onKeyDownCB);
		vkObj.overTopCB = Delegate.create(this, this.overTopCB);
		vkObj.overBottomCB = Delegate.create(this, this.overBottomCB);
		// vkObj.overLeftCB = Delegate.create(this, this.overLeftCB);
		// vkObj.overRightCB = Delegate.create(this, this.overRightCB);
		// vkObj.capslock = true;

		// Possible startMode values are VirtualKeyboard.FUNCTION_OK, FUNCTION_CANCEL, FUNCTION_BACKSPACE, FUNCTION_CLEAR
		// , FUNCTION_SPACE, FUNCTION_DELETE, FUNCTION_SHIFT, FUNCTION_LEFT, FUNCTION_RIGHT, FUNCTION_UP, FUNCTION_DOWN, FUNCTION_CAPSLOCK
		// , FUNCTION_ALPHANUMERIC(Default), FUNCTION_SYMBOL, FUNCTION_SPECIAL_CHARACTER, FUNCTION_AUTO_COMPLETE
		// vkObj.startMode = 13;

		vkObj.showSuggestion = true;
		// vkObj.suggestion = new Array();
		vkObj.wrap = true;
		// auto complete LoadVar object for auto complete purposes.
		//vkObj.acLib = this.acLib;

		vkObj.onUpdateCB = Delegate.create(this, this.onUpdateCB);
		vkObj.onDoneCB = Delegate.create(this, this.onDoneCB);
		vkObj.onCancelCB = Delegate.create(this, this.onCancelCB);
		vkObj.initValue = "";

		this.vk = new VirtualKeyboard(vkObj);
		this.arr[index].c._alpha = 100;
		this.vk.enableKeyboard({inputTF:this.arr[index].t, inputCursor:this.arr[index].c});
	}

	private function onKeyDownCB() {
		var keyCode:Number = Key.getCode();
		var asciiCode:Number = Key.getAscii();
		
		switch (keyCode)
		{
			case Remote.BACK:
			case "soft1":
				this.destroy();
				gotoAndPlay("main");
			break;
		}
	}
	/*
	* When the TextField text is updated.
	*/
	private function onUpdateCB(str:String):Void
	{
		trace("onUpdateCB:"+str);
	}

	/*
	* When OK button on the Keyboard is pressed.
	*/
	private function onDoneCB(str:String):Void
	{
		trace("onDoneCB:" + str);

		// Hide the keyboard. The USB keyboard still enabled on the current active TextField.
		this.vk.hideKeyboard(true);
	}

	/*
	* When Cancel button on the Keyboard is pressed.
	*/
	private function onCancelCB(str:String):Void
	{
		trace("onCancelCB:" + str);

		// Hide the keyboard. The USB keyboard still enabled on the current active TextField.
		this.vk.hideKeyboard(true);
	}

	/*
	* When navigate over left of the Keyboard.
	*/
	private function overLeftCB():Void
	{
		trace("overLeftCB");
	}

	/*
	* When navigate over right of the Keyboard.
	*/
	private function overRightCB():Void
	{
		trace("overRightCB");
	}

	/*
	* When navigate over the top of the Keyboard.
	*/
	private function overTopCB():Boolean
	{
		this.vk.clear();
		this.arr[index].c._alpha = 0; // unhighlight current TextField.

		var len:Number = this.arr.length;
		if (index > 0)
			index -= 1;
		else
			index = len - 1;

		this.arr[index].c._alpha = 100; // highlight Textfield above.
		this.vk.enableKeyboard({inputTF:this.arr[index].t, inputCursor:this.arr[index].c, initValue:""}, 10);

		return true; // still enable the Keyboard.
	}

	/*
	* When navigate over the bottom of the Keyboard.
	*/
	private function overBottomCB():Boolean
	{
		this.vk.clear();
		this.arr[index].c._alpha = 0; // unhighlight current TextField.

		var len:Number = this.arr.length;
		if (index < len-1)
			index += 1;
		else
			index = 0;

		this.arr[index].c._alpha = 100; // highlight bottom TextField.
		this.vk.enableKeyboard({inputTF:this.arr[index].t, inputCursor:this.arr[index].c, initValue:""}, 22);

		return true; // still enable the Keyboard.
	}

	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
			if (i != "plex"){
				trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
				if (typeof(_obj[i]) == "object" || typeof (_obj[i]) == "movieclip"){
					cleanUp(_obj[i]);
				}
				if (typeof(_obj[i]) == "movieclip"){
					trace("Removing: " + _obj[i]);
					_obj[i].removeMovieClip();
					delete _obj[i];
				}
			}
		}
	}

}