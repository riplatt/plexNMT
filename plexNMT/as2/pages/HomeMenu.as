
import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.D;

//import com.adobe.as2.MobileSharedObject;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;

//import caurina.transitions.Tweener;

import mx.utils.Delegate;

class plexNMT.as2.pages.HomeMenu {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.HomeMenu;
	public var plexData:PlexData = null;
	//public var D:D = null;
	//PlexData = plexData; 
	//public static var plexURL:String = "http://192.168.1.3:32400/";

	// Public Properties:
	// Private Properties:
	//private var plexSO:MobileSharedObject = null;
	private var plex:Object = new Object();
	private var history:Object = new Object();
	private var wallData:Array = new Array();
	private var backgroundData:Array = new Array();
	private var level1MaxX:Number = null;
	private var level2MaxX:Number = null;
	private var level3MaxX:Number = null;
	private var currImg:String = null;
	private var arrPos:Number = 0;
	private var crossfadeInterval:Number = null;
	private var keyListener:Object = null;
	//private var fpsComp:FPS = null;
	//private var myTimeline:TimelineLite = null;
	//Home Data
	private var firstHistory:Array = null;
	private var secondHistory:Array = null;
	private var thirdHistory:Array = null;
	private var firstData:Array = null;
	private var secondData:Array = null;
	private var thirdData:Array = null;
	private var firstAge:Number = null;
	private var secondAge:Number = null;
	private var thirdAge:Number = null;
	//Menu Background
	private var level1Offset:Number = null;
	private var level2Offset:Number = null;
	private var level3Offset:Number = null;
	private var menuBGOffset:Number = null;
	//MovieClips
	private var parentMC:MovieClip = null;
	private var mainMC:MovieClip = null;
	private var movFrameRateMC:MovieClip = null;
	private var backgroundMC:MovieClip = null;
	private var menuBGMC:MovieClip = null;
	private var menu1MC:MovieClip = null;
	private var menu2MC:MovieClip = null;
	private var menu3MC:MovieClip = null;

	// Initialization:
	public function HomeMenu(parentMC:MovieClip) {
		
		PlexData.init();
		//var_dump(_level0);
		
		trace("Doing HomeMenu with: "+parentMC);
		D.debug(D.lInfo,"HomeMenu - Plex Server URL: " + PlexData.oSettings.url);
		
		this.keyListener = new Object();
		this.keyListener.onKeyDown = Delegate.create(this, this.onKeyDown);

		Key.addListener(this.keyListener);
		
		this.parentMC = parentMC;
		this.mainMC = this.parentMC.createEmptyMovieClip("mainMC", this.parentMC.getNextHighestDepth());
		
		this.level1Offset = 50;
		this.level2Offset = 10;
		this.level3Offset = 10;
		this.menuBGOffset = 50 - 1300;
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		
		//Build stage
		this.setStage();
		
		if (PlexData.oSettings.curLevel == null || PlexData.oData.level1.age == null)
		{
			trace("bob a...");
			PlexData.oSettings.curLevel = 1;
			PlexData.oData.level1.loaded = false;
			//load main menu
			this.loadLevel1();
		} else {
			for (var i:Number = 1; i<=PlexData.oSettings.curLevel;i++)
			{
				trace("bob b...");
				this.updateMenu(i);
				this.startBackground();
			}
		}
		
	}

	// Public Methods:
	public function destroy():Void {
		
		
		//Destroy Movie Clips
		cleanUp(this.parentMC);
		
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
		
		//Var
		this.plex = null;
		this.history = null;
		this.backgroundData = null;
		
		//Arrays
		//firstHistory.splice(0);
		delete firstHistory;
		//firstData.splice(0);
		delete firstData;
		
		//secondHistory.splice(0);
		delete secondHistory;
		//secondData.splice(0);
		delete secondData;
		
		//thirdHistory.splice(0);
		delete thirdHistory;
		//thirdData.splice(0);
		delete thirdData;
		
		//delete plexSO;
		//Timers
		clearInterval(crossfadeInterval);
		
		trace("Done Destroying...");
		//var_dump(_level0);
		
	}

	// Private Methods:
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		var i:Number = PlexData.oSettings.curLevel;
		//trace("HomeMenu - Doing Key With: "+keyCode+" @ Level: "+i);
		D.debug(D.lDebug,"HomeMenu - Doing Key With: "+keyCode+" @ Level: " + i);

		switch (keyCode)
		{
			case Key.LEFT:
				PlexData.oSettings.curLevel --;
				if (i < 1)
				{
					PlexData.oSettings.curLevel = 1;
				}
				this["loadLevel"+PlexData.oSettings.curLevel]();
			break;
			case Key.RIGHT:
				PlexData.oSettings.curLevel ++;
				if (i > 3)
				{
					PlexData.oSettings.curLevel = 3;
				}
				this["loadLevel"+PlexData.oSettings.curLevel]();
			break;
			case Key.UP:
				PlexData.rotateItemsRight("level"+i);
				if(i < 3)
				{
					PlexData.oData["level"+(i+1)].age = null;
				}
				this.updateMenu(i);
			break;
			case Key.DOWN:
				PlexData.rotateItemsLeft("level"+i);
				if(i < 3)
				{
					PlexData.oData["level"+(i+1)].age = null;
				}
				this.updateMenu(i);
			break;
			case Key.ENTER:
				this.loadPage();
			break;
			case "soft1":  //for testing on pc
			case Remote.BACK:
				//PlexData.readSO();
				this.destroy();
				gotoAndPlay("main");
			break;
			
		}
		D.debug(D.lDebug,"HomeMenu - Done Key Press Current Level: " + PlexData.oSettings.curLevel);
		
	}
	
	private function updateMenu(i:Number) {
		
		//var i:Number = PlexData.oSettings.curLevel;
		//trace("HomeMenu - Updataing the menu @ level " + i);
		D.debug(D.lDebug,"HomeMenu - Updataing the menu @ level " + i);
		D.debug(D.lDebug,"HomeMenu - Current URL:" + PlexData.oData["level"+i].current.url);
		PlexData.oData["level"+i].current = PlexData.oData["level"+i].items[2];
		for (var j:Number = 0; j<5; j++) {
				this["menu"+i+"MC"]["item_"+j].txt.htmlText = PlexData.oData["level"+i].items[0].title;
				PlexData.oData["level"+i].items[0].width = this["menu"+i+"MC"]["item_"+j].txt.textWidth;
				PlexData.rotateItemsLeft("level"+i);
			}

		for (var k:Number =0; k<5; k++) {
			PlexData.rotateItemsRight("level"+i);
		}
		
		this["level"+i+"MaxX"] = getMaxTxtLen(PlexData.oData["level"+i].items);
		
		switch (i)
		{
			case 1:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:100, _x:this.level1Offset});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:0, _x:150});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:0, _x:250});
				TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.menuBGOffset});
			break;
			case 2:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:40});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.level2Offset});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:0, _x:250});
				TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level2MaxX + this.level2Offset + this.level1MaxX + this.level1Offset + this.menuBGOffset});
			break;
			case 3:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:25});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:40, _x:this.level1MaxX + this.level1Offset + this.level2Offset});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.level2MaxX + this.level2Offset + this.level3Offset});
				TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level3MaxX + this.level3Offset + this.level2MaxX + this.level2Offset + this.level1MaxX + this.level1Offset + this.menuBGOffset});

			break;
		}
			
	}
	private function loadLevel1() {
		
		if (PlexData.oSettings.url == null) 
		{	
			D.debug(D.lDebug,"HomeMenu - loadLevel1: PlexData.oSettings.url == null...");
			this.destroy();
			gotoAndPlay("settings");
			return;
			//PlexData.readSO()
		}
		
		//Load background slide show
		if (PlexData.oBackground.init == false)
		{
			this.loadRecentlyAdded();
		}
		
		//D.debug(D.lInfo,"HomeMenu - loadLevel1...");
		//D.debug(D.lInfo,"HomeMenu - D.loaded = " + D.loaded);
		
		//trace(g11);
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		
		//trace("loadFirstMenu Dumpimg PlexData.oData.level1..");
		//var_dump(PlexData.oData.level1);
		
		if (PlexData.oData.level1.age != null && timeTemp < PlexData.oData.level1.age) {
			//trace("Loading First Menu With Previous Data...");
			PlexData.oData.level1.loaded = true;
			this.onLoadLevel(PlexData.oData.level1.items);
		} else {
			PlexData.oData.level1.age = todayData.getTime() + 1800000; //30mins from now
			//trace("Getting New Data For First Menu...");
			//trace("Loading URL "+PlexData.oSettings.url+"library/sections");
			PlexData.oData.level1.loaded = false;
			PlexAPI.loadData(PlexData.oSettings.url+"library/sections",Delegate.create(this, this.onLoadLevel),5000);
		}
		
		
	}

	private function loadLevel2():Void {
		trace("HomeMenu - Doing loadLevel2...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		
		if (PlexData.oData.level2.age != null && timeTemp < PlexData.oData.level2.age) {
			//trace("Loading Second Menu With Previous Data...");
			this.onLoadLevel(PlexData.oData.level2.items)
		} else {
			PlexData.oData.level2.age = todayData.getTime() + 1800000; //30mins from now
			PlexData.oData.level2.items = new Array();
			PlexData.oData.level2.current.title = "";
			//trace("Getting New Data For Second Menu...");
			PlexAPI.loadData(PlexData.oData.level1.current.url,Delegate.create(this, this.onLoadLevel),5000);
		}

	}
	
	private function loadLevel3():Void {
		trace("HomeMenu - Doing loadLevel3...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		
		if (PlexData.oData.level3.age != null && timeTemp < PlexData.oData.level3.age) {
			//trace("Loading Third Menu With Previous Data...");
			this.onLoadLevel(PlexData.oData.level3.items)
		} else {
			PlexData.oData.level3.age = todayData.getTime() + 1800000; //30mins from now
			PlexData.oData.level3.items = new Array();
			PlexData.oData.level3.current.title = "";
			//trace("Getting New Data For Third Menu...");
			PlexAPI.loadData(PlexData.oData.level2.current.url,Delegate.create(this, this.onLoadLevel),5000);
		}

	}

	private function onLoadLevel(data:Array):Void {
		
		var i:Number = PlexData.oSettings.curLevel;
		trace("HomeMenu - menu type:" + data.type);
		if (data.type == "secondary")
		{

		}
		//data.sort(Array.CASEINSENSITIVE);
		PlexData.oData["level"+i].items = data.concat();
		if (i == 1 and PlexData.oData.level1.loaded == false )
		{
			//Add Exit and Setting to Menu
			PlexData.oData.level1.items.push({title:"Exit", key:"0", url:"system?arg0=load_launcher", menu:"exit"}
				  						,{title:"Settings", key:"0", url:"", menu:"settings"}
				  						//,{title:"Substrate", key:"0", url:"", menu:"substrate"}
				  						);
			PlexData.oData.level1.loaded = true;
			
			
		}
		
		var dataLen = PlexData.oData["level"+i].items.length;
		//trace("HomeMenu - oData.level"+i+".current.title: " + PlexData.oData["level"+i].current.title);
		
		if (PlexData.oData["level"+i].current.title == "")
		{
			for (var c:Number = 0; c<2; c++)
			{
				PlexData.rotateItemsRight("level"+i);
			}
			PlexData.oData["level"+i].current = PlexData.oData["level"+i].items[2];
		} else {
				var wd:Number = 0;
				while(PlexData.oData["level"+i].items[2].title != PlexData.oData["level"+i].current.title)
				{
					D.debug(D.lDebug,"HomeMenu - Doing while...");
					PlexData.rotateItemsLeft("level"+i);
					wd++;
					if(wd > dataLen)
					{
						D.debug(D.lDebug,"HomeMenu - exiting while via watchdog...");
						break;
					}
				}
		}
		
		this.updateMenu(i);
	}

	private function loadPage(data:Array):Void {
		
		trace("Doing loadPage...");
		//var_dump(data);
		var i:Number = PlexData.oSettings.curLevel
		var page:String = PlexData.oData["level"+i].current.menu;

		switch (page) {
			case "exit" :
				this.destroy();
				Util.loadURL("http://127.0.0.1:8008/system?arg0=load_launcher");
				break;
			case "settings" :
				this.destroy();
				gotoAndPlay("settings");
				break;
			case "substrate" :
				this.destroy();
				gotoAndPlay("substrate");
				break;
			default :
				this.destroy();
				gotoAndPlay("wall");
				break;
		}

	}
	private function loadRecentlyAdded():Void{
		//Temp till i put it into the setting on what to show in the background
		PlexAPI.loadData(PlexData.oSettings.url+"library/sections/1/recentlyAdded",Delegate.create(this, this.onLoadRecentlyAdded),5000);
	}
	private function onLoadRecentlyAdded(data:Array):Void{
		//trace("HomeMenu - Dumming onLoadRecentlyAdded data...");
		//var_dump(data);
		PlexData.oBackground.init = true;
		PlexData.oBackground.items = data.concat();
		//this.backgroundData = data;
		
		if(++PlexData.oBackground.index >= PlexData.oBackground.items.length) {PlexData.oBackground.index = 0;}
		//this.arrPos = 1;
		this.startBackground();
		
	}
	private function startBackground()
	{
		UI.loadImage(PlexData.oBackground.items[PlexData.oBackground.index].artURL,this.backgroundMC,"imgBG1");
		this.backgroundMC.imgBG1._alpha = 100;
		this.currImg = "imgBG2";
		
		clearInterval(crossfadeInterval);
		crossfadeInterval = setInterval(Delegate.create(this,crossfade),15000);
	}
	
	private function crossfade() {
		//trace("Doing crossfade with: " + this.currImg);
		if(++PlexData.oBackground.index >= PlexData.oBackground.items.length) {PlexData.oBackground.index = 0;}
		if (this.currImg == "imgBG1") {
			//trace("Doing BG1...");
			//trace("backgroundData["+arrPos+"].artURL: " + backgroundData[arrPos].artURL);
			UI.loadImage(PlexData.oBackground.items[PlexData.oBackground.index].artURL,this.backgroundMC,"imgBG1");
			//this.backgroundMC.imgBG1._alpha = 0;
			TweenLite.to(backgroundMC.imgBG1, 1.7, {_alpha:100});
			TweenLite.to(backgroundMC.imgBG2, 1.7, {_alpha:0});
			if(++PlexData.oBackground.index >= PlexData.oBackground.items.length) {PlexData.oBackground.index = 0;}
			this.currImg = "imgBG2";
		} else {
			//trace("backgroundData["+arrPos+"].artURL: " + backgroundData[arrPos].artURL);
			UI.loadImage(PlexData.oBackground.items[PlexData.oBackground.index].artURL,this.backgroundMC,"imgBG2");
			//this.backgroundMC.imgBG2._alpha = 0;
			TweenLite.to(this.backgroundMC.imgBG2, 1.7, {_alpha:100});
			TweenLite.to(this.backgroundMC.imgBG1, 1.7, {_alpha:0});
			if(++PlexData.oBackground.index >= PlexData.oBackground.items.length) {PlexData.oBackground.index = 0;}
			this.currImg = "imgBG1";
		}
	}
	
	private function setStage():Void {
		this.backgroundMC = this.mainMC.createEmptyMovieClip("backgroundMC", this.mainMC.getNextHighestDepth());
		this.menuBGMC = this.mainMC.attachMovie("menuBGMC", "menuBGMC", this.mainMC.getNextHighestDepth(), {_x:-1300, _alpha:0});
		this.menu3MC = this.mainMC.attachMovie("menuMC", "menu3MC", this.mainMC.getNextHighestDepth(), {_x:250, _y:50, _alpha:0});
		this.menu2MC = this.mainMC.attachMovie("menuMC", "menu2MC", this.mainMC.getNextHighestDepth(), {_x:150, _y:50, _alpha:0});
		this.menu1MC = this.mainMC.attachMovie("menuMC", "menu1MC", this.mainMC.getNextHighestDepth(), {_x:50, _y:50, _alpha:0});
		
		//auto size text fields
		this.menu1MC.item_0.txt.autoSize = "left";
		this.menu1MC.item_1.txt.autoSize = "left";
		this.menu1MC.item_2.txt.autoSize = "left";
		this.menu1MC.item_3.txt.autoSize = "left";
		this.menu1MC.item_4.txt.autoSize = "left";
		
		this.menu2MC.item_0.txt.autoSize = "left";
		this.menu2MC.item_1.txt.autoSize = "left";
		this.menu2MC.item_2.txt.autoSize = "left";
		this.menu2MC.item_3.txt.autoSize = "left";
		this.menu2MC.item_4.txt.autoSize = "left";
		
		this.menu3MC.item_0.txt.autoSize = "left";
		this.menu3MC.item_1.txt.autoSize = "left";
		this.menu3MC.item_2.txt.autoSize = "left";
		this.menu3MC.item_3.txt.autoSize = "left";
		this.menu3MC.item_4.txt.autoSize = "left";
		//trace("setStage dumpping this...");
		//var_dump(this);
		
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
	
	private function maxValue(_array):Number {

		var mxm:Number = _array[0];
		var arrayLen:Number = _array.length;
		for (var i:Number = 0; i<arrayLen; i++) {
			if (_array[i]>mxm) {
				mxm = _array[i];
			}
		}
		return mxm;
    }
	
	private function getMaxTxtLen(_obj:Object):Number {
		
		//trace("getMaxTxtLen Dumping _obj...");
		//var_dump(_obj);
		
		var dataLen:Number = _obj.length;
		var mxm:Number = 0;
		for(var i=0; i<dataLen; i++){
			if (_obj[i].width>mxm){
				mxm = _obj[i].width;
			}
		}
		return mxm;
	}
	
	private function var_dump(_obj:Object) {
		//trace("Doing var_dump...");
		//trace(_obj);
		//trace("Looping Through _obj...");
		for (var i in _obj) {
			D.debug(D.lInfo,"key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object" || typeof(_obj[i]) == "movieclip") {
				var_dump(_obj[i]);
			}
			trace("end: " + i);
		}
	}
}