
import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Background;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.D;

//import com.adobe.as2.MobileSharedObject;

//import com.greensock.TweenLite;
//import com.greensock.OverwriteManager;
import com.greensock.*;
import com.greensock.easing.*;
import com.greensock.plugins.*;

//import caurina.transitions.Tweener;

import mx.utils.Delegate;

class plexNMT.as2.pages.HomeMenu {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.HomeMenu;
	// Public Properties:
	public var plexData:PlexData = null;
	// Private Properties:
	private var plex:Object = new Object();
	private var history:Object = new Object();
	private var wallData:Array = new Array();
	private var backgroundData:Array = new Array();
	private var _background:Background = null;
	private var level1MaxX:Number = null;
	private var level2MaxX:Number = null;
	private var level3MaxX:Number = null;
	private var currImg:String = null;
	private var arrPos:Number = 0;
	private var crossfadeInterval:Number = null;
	private var keyListener:Object = null;

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
	//private var backgroundMC:MovieClip = null;
	private var menuBGMC:MovieClip = null;
	private var menu1MC:MovieClip = null;
	private var menu2MC:MovieClip = null;
	private var menu3MC:MovieClip = null;

	// Initialization:
	public function HomeMenu(parentMC:MovieClip) {
		
		D.debug(D.lInfo,"Home - Plex Server URL: " + PlexData.oSettings.url);
		D.debug(D.lDebug, "Home - Free Memory: " + fscommand2("GetFreePlayerMemory") + "kB");
		//trace("Home - parentMC:" + parentMC);
		//Utils.traceVar(_level0);
		//trace("Home - PlexData.oSettings");
		//Utils.traceVar(PlexData.oSettings);
		
		PlexData.oSettings.lastPage = "main";
		
		this.keyListener = new Object();
		this.keyListener.onKeyDown = Delegate.create(this, this.onKeyDown);

		Key.addListener(this.keyListener);
		
		this.parentMC = parentMC;
		this.mainMC = parentMC.createEmptyMovieClip("mainMC", parentMC.getNextHighestDepth());
		
		this.level1Offset = 50;
		this.level2Offset = 10;
		this.level3Offset = 10;
		this.menuBGOffset = 50 - 1300;
		
		//GreenSock Tween Control
		//OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([GlowFilterPlugin, AutoAlphaPlugin]);
		
		//Build stage
		this.setStage();
		
		if (PlexData.oSections.MediaContainer[0] == undefined)
		{	
			PlexData.oSettings.curLevel = 1;
			PlexData.oData.level1.loaded = false;
			//load main menu
			this.loadLevel1();
		} else {
			this.updateMenu(PlexData.oSettings.curLevel);
			this.startBackground();
		}
		
	}

	// Public Methods:
	public function destroy():Void {
		
		
		_background.destroy();
		_background = null;
		//Destroy Movie Clips
		cleanUp(this.parentMC);
		
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
		
		//delete plexSO;
		//Timers
		clearInterval(crossfadeInterval);
		crossfadeInterval = null;
		
		trace("Done Destroying...");
		//var_dump(_level0);
		
	}

	// Private Methods:
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		var i:Number = PlexData.oSettings.curLevel;
		//trace("Home - Doing Key With: "+keyCode+" @ Level: "+i);
		D.debug(D.lDev,"Home - Doing Key With: "+keyCode+" @ Level: " + i);

		switch (keyCode)
		{
			case Key.LEFT:
				PlexData.oSettings.curLevel --;
				if (PlexData.oSettings.curLevel < 1)
				{
					PlexData.oSettings.curLevel = 1;
				}
				this["loadLevel"+PlexData.oSettings.curLevel]();
			break;
			case Key.RIGHT:
				var key:String = "/library/sections/";
				if (PlexData.oCategories.MediaContainer[0] != undefined) 
				{
					key = key + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key + "/";
					key = key + PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.key + "/";
				}
				if (PlexData.oFilters.MediaContainer[0] != undefined) 
				{
					key = key + PlexData.oFilters.MediaContainer[0].Directory[PlexData.oFilters.intPos].attributes.key;
				}
				trace("Home - KeyDown: Calling getViewGroup with: " + key);
				PlexAPI.getViewGroup(key, Delegate.create(this, this.onLevelCheck), PlexData.oSettings.timeout);
				
			break;
			case Key.DOWN:
				switch (i)
				{	
					case 1:
						PlexData.oSections.intPos++;
						if (PlexData.oSections.intPos > PlexData.oSections.MediaContainer[0].attributes.size - 1)
						{
							PlexData.oSections.intPos = 0;
						}
					break;
					case 2:
						PlexData.oCategories.intPos++;
						if (PlexData.oCategories.intPos > PlexData.oCategories.MediaContainer[0].attributes.size - 1)
						{
							PlexData.oCategories.intPos = 0;
						}
					break;
					case 3:
						PlexData.oFilters.intPos++;
						if (PlexData.oFilters.intPos > PlexData.oFilters.MediaContainer[0].attributes.size - 1)
						{
							PlexData.oFilters.intPos = 0;
						}
					break;
				}
				this.updateMenu(i);
			break;
			case Key.UP:
				switch (i)
				{	
					case 1:
						PlexData.oSections.intPos--;
						if (PlexData.oSections.intPos < 0)
						{
							PlexData.oSections.intPos = PlexData.oSections.MediaContainer[0].attributes.size - 1;
						}
					break;
					case 2:
						PlexData.oCategories.intPos--;
						if (PlexData.oCategories.intPos < 0)
						{
							PlexData.oCategories.intPos = PlexData.oCategories.MediaContainer[0].attributes.size - 1;
						}
					break;
					case 3:
						PlexData.oFilters.intPos--;
						if (PlexData.oFilters.intPos < 0)
						{
							PlexData.oFilters.intPos = PlexData.oFilters.MediaContainer[0].attributes.size - 1;
						}
					break;
				}
				this.updateMenu(i);
			break;
			case Key.ENTER:
				this.loadPage();
			break;
			case Remote.HOME:
				this.destroy();
				gotoAndPlay("main");
			break;
			case Remote.YELLOW:
				this.destroy();
				gotoAndPlay("settings");
			break;
			
		}
		D.debug(D.lDev,"Home - Done Key Press Current Level: " + PlexData.oSettings.curLevel);
		
	}
	
	private function onLevelCheck(strViewGroup:String) {
		trace("Home - strViewGroup: " + strViewGroup);
		if (strViewGroup == "secondary" || strViewGroup == "" || PlexData.oSettings.curLevel == 3) {
			PlexData.oSettings.curLevel ++;
				if (PlexData.oSettings.curLevel > 3)
				{
					PlexData.oSettings.curLevel = 3;
				}
				this["loadLevel"+PlexData.oSettings.curLevel]();
		} else {
			this.onLoadPage("wall");
		}
	}
	private function updateMenu(i:Number) {
		
		D.debug(D.lDev,"Home - Updataing the menu @ level " + i);
		D.debug(D.lDev,"Home - Current URL:" + PlexData.oData["level"+i].current.url);
		D.debug(D.lDev,"Home - PlexData.oSections.MediaContainer[0] " + PlexData.oSections.MediaContainer[0]);
		D.debug(D.lDev,"Home - PlexData.oCategories.MediaContainer[0] " + PlexData.oCategories.MediaContainer[0]);
		D.debug(D.lDev,"Home - PlexData.oFilters.MediaContainer[0] " + PlexData.oFilters.MediaContainer[0]);
		var u:Number = 1;
		/*switch (i)
		{
			case 1:*/
			if (PlexData.oSections.MediaContainer[0] != undefined)
			{
				D.debug(D.lDev,"Home - Setting Menu Level 1...");
				this.menu1MC.item_0.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.GetRotation("oSections",-2)].attributes.title;
				this.menu1MC.item_1.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.GetRotation("oSections",-1)].attributes.title;
				this.menu1MC.item_2.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.GetRotation("oSections",0)].attributes.title;
				this.menu1MC.item_3.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.GetRotation("oSections",1)].attributes.title;
				this.menu1MC.item_4.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.GetRotation("oSections",2)].attributes.title;
				this.level1MaxX = getMaxTxtLen(this.menu1MC);
				u = 1;
			}
			/*break;
			case 2:*/
			if (PlexData.oCategories.MediaContainer[0] != undefined)
			{
				D.debug(D.lDev,"Home - Setting Menu Level 2...");
				this.menu2MC.item_0.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.GetRotation("oCategories",-2)].attributes.title;
				this.menu2MC.item_1.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.GetRotation("oCategories",-1)].attributes.title;
				this.menu2MC.item_2.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.GetRotation("oCategories",0)].attributes.title;
				this.menu2MC.item_3.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.GetRotation("oCategories",1)].attributes.title;
				this.menu2MC.item_4.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.GetRotation("oCategories",2)].attributes.title;
				this.level2MaxX = getMaxTxtLen(this.menu2MC);
				u = 2;
			}
			/*break;
			case 3:*/
			if (PlexData.oFilters.MediaContainer[0] != undefined)
			{
				D.debug(D.lDev,"Home - Setting Menu Level 3...");
				this.menu3MC.item_0.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.GetRotation("oFilters",-2)].attributes.title;
				this.menu3MC.item_1.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.GetRotation("oFilters",-1)].attributes.title;
				this.menu3MC.item_2.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.GetRotation("oFilters",0)].attributes.title;
				this.menu3MC.item_3.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.GetRotation("oFilters",1)].attributes.title;
				this.menu3MC.item_4.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.GetRotation("oFilters",2)].attributes.title;
				this.level3MaxX = getMaxTxtLen(this.menu3MC);
				u = 3;
			}
			/*break;
			
		}*/
		
		//this["level"+i+"MaxX"] = getMaxTxtLen(this["menu"+i+"MC"]);
		
		switch (u)
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
			D.debug(D.lDebug,"Home - loadLevel1: PlexData.oSettings.url == null...");
			this.destroy();
			gotoAndPlay("settings");
			return;
			//PlexData.readSO()
		}
		
		//Load background slide show
		this.loadBackground();

		PlexData.oCategories = new Object();;
		PlexData.oFilters = new Object();
		
		if (PlexData.oSections.MediaContainer[0] != undefined)
		{	
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			PlexAPI.getSections(Delegate.create(this, this.onLoadLevel), PlexData.oSettings.timeout);
		}		
	}

	private function loadLevel2():Void {
		trace("Home - Doing loadLevel2...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		var sectionKey:String = PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key;
		
		PlexData.oFilters = new Object();
		trace("PlexData.oCategories.MediaContainer[0]:"+PlexData.oCategories.MediaContainer[0]);
		if (PlexData.oCategories.MediaContainer[0] != undefined)
		{	
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			PlexAPI.getCategories(sectionKey, Delegate.create(this, this.onLoadLevel), PlexData.oSettings.timeout);
		}
	}
	
	private function loadLevel3():Void {
		trace("Home - Doing loadLevel3...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		var sectionKey:String = PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key;
		var categoryKey:String = PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.key;
		
		if (PlexData.oFilters.MediaContainer[0] != undefined)
		{	
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			PlexAPI.getFilters(sectionKey+"/"+categoryKey, Delegate.create(this, this.onLoadLevel), PlexData.oSettings.timeout);
		}
	}

	private function onLoadLevel(data:Array):Void {
		
		var i:Number = PlexData.oSettings.curLevel;
		this.updateMenu(i);
	}

	private function loadPage(data:Array):Void {
		
		trace("Doing loadPage...");
		trace("oSections: " + PlexData.oSections.MediaContainer[0]);
		trace("oCategories: " + PlexData.oCategories.MediaContainer[0]);
		trace("oFilters: " + PlexData.oFilters.MediaContainer[0]);
		var key:String = "/library/sections";
		if (PlexData.oCategories.MediaContainer[0] == undefined && PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key != undefined)
		{
			var sectionKey:String = PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key;
			PlexAPI.getCategories(sectionKey, Delegate.create(this, this.loadPage), PlexData.oSettings.timeout);
			PlexData.oSettings.curLevel ++;
			return;
		} else {
			key = key + "/" + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key;
			key = key + "/" + PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.key;
		}
		if (PlexData.oFilters.MediaContainer[0] != undefined) 
		{
			key = key + "/" + PlexData.oFilters.MediaContainer[0].Directory[PlexData.oFilters.intPos].attributes.key;
		}
		trace("Calling getViewGroup with: " + key);
		PlexAPI.getViewGroup(key, Delegate.create(this, this.onLoadPage), PlexData.oSettings.timeout);
	}
	
	private function onLoadPage(strViewGrouop:String):Void {
		//trace("Home - Doing onLoadPage with: " + strViewGrouop);
		var i:Number = PlexData.oSettings.curLevel
		var page:String = "";
		switch (i) {
			case 1:
				page = this.menu1MC.item_2.txt.htmlText = PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.title;
			break;
			case 2:
				page = this.menu2MC.item_2.txt.htmlText = PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.title;
			break;
			case 3:
				page = this.menu3MC.item_2.txt.htmlText = PlexData.oFilters.MediaContainer[0].Directory[PlexData.oFilters.intPos].attributes.title;
			break;
		}
		
		//trace("Home - page: " + page);
		switch (page.toLowerCase()) {
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
				if (strViewGrouop == "secondary" ) {
					PlexData.oSettings.curLevel ++;
					if (i > 3)
					{
						PlexData.oSettings.curLevel = 3;
					}
					this["loadLevel"+PlexData.oSettings.curLevel]();
				} else {
					this.destroy();
					gotoAndPlay("wall");
				}
				break;
		}
	}
	
	private function loadBackground():Void{
		//Temp till i put it into the setting on what to show in the background
		var key:String = PlexData.oSettings.backgroundKey;
		//PlexAPI.loadData(PlexData.oSettings.url+"library/sections/1/recentlyAdded",Delegate.create(this, this.onLoadRecentlyAdded),PlexData.oSettings.timeout);
		
		if (PlexData.oBackground.MediaContainer[0] == undefined)
		{	
			PlexAPI.getBackground(key, Delegate.create(this, this.onLoadBackground), PlexData.oSettings.timeout);
		} else if (crossfadeInterval == undefined){
			this.startBackground();
		}
	}
	private function onLoadBackground(data:Array):Void{
		this.startBackground();
		
	}
	private function startBackground()
	{
		trace("Home - Calling background update with: " + PlexData.oBackground.MediaContainer[0].Video[PlexData.oBackground.intPos].attributes.art);
		var _data:Array = new Array();
		_background._set(PlexData.oBackground.MediaContainer[0].Video[PlexData.oBackground.intPos].attributes.art);
		clearInterval(crossfadeInterval);
		crossfadeInterval = setInterval(Delegate.create(this, crossfade),15000);
	}
	
	private function crossfade() {
		//trace("Home - Doing crossfade...");
		if(++PlexData.oBackground.intPos >= PlexData.oBackground.intLength) {PlexData.oBackground.intPos = 0;};
		this._background._update(PlexData.oBackground.MediaContainer[0].Video[PlexData.oBackground.intPos].attributes.art);
	}
	
	private function setStage():Void {
		//this.backgroundMC = this.mainMC.createEmptyMovieClip("backgroundMC", this.mainMC.getNextHighestDepth());
		_background = new Background(this.mainMC);
		/*trace("Dumping _background...");
		Utils.varDump(_background);*/
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

			//trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object" || typeof (_obj[i]) == "movieclip"){
				cleanUp(_obj[i]);
			}
			if (typeof(_obj[i]) == "movieclip"){
				trace("Home - Removing: " + _obj[i]);
				_obj[i].removeMovieClip();
				delete _obj[i];
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
		
		var dataLen:Number = 5; //_obj.length;
		var mxm:Number = 0;
		
		for(var i=0; i<dataLen; i++){
			if (_obj["item_"+i].txt.textWidth>mxm){
				mxm = _obj["item_"+i].txt.textWidth;
			}
		}

		return mxm;
	}
}