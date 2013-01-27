
import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Background;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.D;

import com.greensock.*;
import com.greensock.easing.*;
import com.greensock.plugins.*;

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
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		//Build stage
		this.setStage();
		
		if (PlexData.oSections._elementType == undefined)
		{	
			PlexData.oSettings.curLevel = 1;
			PlexData.oData.level1.loaded = false;
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
		
		trace("Done Destroying...");
		//var_dump(_level0);
		
	}

	// Private Methods:
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		var i:Number = PlexData.oSettings.curLevel;
		D.debug(D.lDev,"Home - Doing Key With: "+keyCode+" @ Level: " + i);

		switch (keyCode)
		{
			case Key.LEFT:
				PlexData.oSettings.curLevel --;
				if (PlexData.oSettings.curLevel < 1)
				{
					PlexData.oSettings.curLevel = 1;
				}
				this["loadLevel" + PlexData.oSettings.curLevel]();
			break;
			case Key.RIGHT:
				var type:String = PlexData.oSections._children[PlexData.oSections.intPos].type;
				switch (type)
				{
					case "movie" :
					case "show" :
						D.debug(D.lDev,"Home - PlexData.oSections._elementType " + PlexData.oSections._elementType);
						D.debug(D.lDev,"Home - PlexData.oCategories._elementType " + PlexData.oCategories._elementType);
						D.debug(D.lDev,"Home - PlexData.oFilters._elementType " + PlexData.oFilters._elementType);
						var key:String = "/library/sections/";
						if (PlexData.oCategories._elementType != undefined) 
						{
							key = key + PlexData.oSections._children[PlexData.oSections.intPos].key + "/";
							key = key + PlexData.oCategories._children[PlexData.oCategories.intPos].key + "/";
						}
						if (PlexData.oFilters._elementType != undefined) 
						{
							key = key + PlexData.oFilters._children[PlexData.oFilters.intPos].key;
						}
						D.debug(D.lDev,"Home - KeyDown: Calling getViewGroup with: " + key);
						PlexAPI.getViewGroup(key, Delegate.create(this, this.onLevelCheck), PlexData.oSettings.timeout);
					break;
					default :
						// Add not supported at this time popup 
						D.debug(D.lDev,"Home - Sorry " + PlexData.oSections._children[PlexData.oSections.intPos].title + " of type " + type + " is unsupported at this time");
					break;
				}
			break;
			case Key.DOWN:
				switch (i)
				{	
					case 1:
						PlexData.oSections.intPos++;
						if (PlexData.oSections.intPos > PlexData.oSections.intLength)
						{
							PlexData.oSections.intPos = 0;
						}
					break;
					case 2:
						PlexData.oCategories.intPos++;
						if (PlexData.oCategories.intPos > PlexData.oCategories.intLength)
						{
							PlexData.oCategories.intPos = 0;
						}
					break;
					case 3:
						PlexData.oFilters.intPos++;
						if (PlexData.oFilters.intPos > PlexData.oFilters.intLength)
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
							PlexData.oSections.intPos = PlexData.oSections.intLength;
						}
					break;
					case 2:
						PlexData.oCategories.intPos--;
						if (PlexData.oCategories.intPos < 0)
						{
							PlexData.oCategories.intPos = PlexData.oCategories.intLength;
						}
					break;
					case 3:
						PlexData.oFilters.intPos--;
						if (PlexData.oFilters.intPos < 0)
						{
							PlexData.oFilters.intPos = PlexData.oFilters.intLength;
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
		D.debug(D.lDev, "Home - onLevelCheck strViewGroup: " + strViewGroup);
		if (strViewGroup == "secondary" || strViewGroup == "" || PlexData.oSettings.curLevel == 3) {
			PlexData.oSettings.curLevel ++;
				if (PlexData.oSettings.curLevel > 3)
				{
					PlexData.oSettings.curLevel = 3;
				}
				D.debug(D.lDev, "Home - Calling loadLevel" + PlexData.oSettings.curLevel);
				this["loadLevel" + PlexData.oSettings.curLevel]();
		} else {
			this.onLoadPage("wall");
		}
	}
	private function updateMenu(i:Number) {
		
		D.debug(D.lDebug,"Home - Updataing the menu @ level " + i);
		D.debug(D.lDebug,"Home - Current URL:" + PlexData.oData["level"+i].current.url);
		D.debug(D.lDev,"Home - PlexData.oSections._elementType " + PlexData.oSections._elementType);
		D.debug(D.lDev,"Home - PlexData.oCategories._elementType " + PlexData.oCategories._elementType);
		D.debug(D.lDev,"Home - PlexData.oFilters._elementType " + PlexData.oFilters._elementType);
		var u:Number = 1;

		if (PlexData.oSections._elementType != undefined)
		{
			D.debug(D.lDev,"Home - Setting Menu Level 1...");
			this.menu1MC.item_0.txt.htmlText = PlexData.oSections._children[PlexData.GetRotation("oSections",-2)].title;
			this.menu1MC.item_1.txt.htmlText = PlexData.oSections._children[PlexData.GetRotation("oSections",-1)].title;
			this.menu1MC.item_2.txt.htmlText = PlexData.oSections._children[PlexData.GetRotation("oSections",0)].title;
			this.menu1MC.item_3.txt.htmlText = PlexData.oSections._children[PlexData.GetRotation("oSections",1)].title;
			this.menu1MC.item_4.txt.htmlText = PlexData.oSections._children[PlexData.GetRotation("oSections",2)].title;
			this.level1MaxX = getMaxTxtLen(this.menu1MC);
			u = 1;
		}

		if (PlexData.oCategories._elementType != undefined)
		{
			D.debug(D.lDev,"Home - Setting Menu Level 2...");
			this.menu2MC.item_0.txt.htmlText = PlexData.oCategories._children[PlexData.GetRotation("oCategories",-2)].title;
			this.menu2MC.item_1.txt.htmlText = PlexData.oCategories._children[PlexData.GetRotation("oCategories",-1)].title;
			this.menu2MC.item_2.txt.htmlText = PlexData.oCategories._children[PlexData.GetRotation("oCategories",0)].title;
			this.menu2MC.item_3.txt.htmlText = PlexData.oCategories._children[PlexData.GetRotation("oCategories",1)].title;
			this.menu2MC.item_4.txt.htmlText = PlexData.oCategories._children[PlexData.GetRotation("oCategories",2)].title;
			this.level2MaxX = getMaxTxtLen(this.menu2MC);
			u = 2;
		}
		
		if (PlexData.oFilters._elementType != undefined)
		{
			D.debug(D.lDev,"Home - Setting Menu Level 3...");
			this.menu3MC.item_0.txt.htmlText = PlexData.oFilters._children[PlexData.GetRotation("oFilters",-2)].title;
			this.menu3MC.item_1.txt.htmlText = PlexData.oFilters._children[PlexData.GetRotation("oFilters",-1)].title;
			this.menu3MC.item_2.txt.htmlText = PlexData.oFilters._children[PlexData.GetRotation("oFilters",0)].title;
			this.menu3MC.item_3.txt.htmlText = PlexData.oFilters._children[PlexData.GetRotation("oFilters",1)].title;
			this.menu3MC.item_4.txt.htmlText = PlexData.oFilters._children[PlexData.GetRotation("oFilters",2)].title;
			this.level3MaxX = getMaxTxtLen(this.menu3MC);
			u = 3;
		}
		
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
		D.debug(D.lDev,"Home - Doing loadLevel1...");
		
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
		
		if (PlexData.oSections._elementType != undefined)
		{	
			D.debug(D.lDev,"Home - Sections allready has Data...");
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			D.debug(D.lDev,"Home - Getting Sections Data...");
			PlexAPI.getSections(Delegate.create(this, this.onLoadLevel));
		}		
	}

	private function loadLevel2():Void {
		D.debug(D.lDev,"Home - Doing loadLevel2...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		var sectionKey:String = PlexData.oSections._children[PlexData.oSections.intPos].key;
		
		PlexData.oFilters = new Object();
		if (PlexData.oCategories._elementType != undefined)
		{	
			D.debug(D.lDev,"Home - Categories allready has Data...");
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			D.debug(D.lDev,"Home - Getting Categories with key:" + sectionKey);
			PlexAPI.getCategories(sectionKey, Delegate.create(this, this.onLoadLevel), PlexData.oSettings.timeout);
		}
	}
	
	private function loadLevel3():Void {
		D.debug(D.lDev,"Home - Doing loadLevel3...");
		
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		var sectionKey:String = PlexData.oSections._children[PlexData.oSections.intPos].key;
		var categoryKey:String = PlexData.oCategories._children[PlexData.oCategories.intPos].key;
		
		if (PlexData.oFilters._elementType != undefined)
		{	
			D.debug(D.lDev,"Home - Filters allready has Data...");
			this.updateMenu(PlexData.oSettings.curLevel);
		} else {
			D.debug(D.lDev,"Home - Getting Filters with key:" + categoryKey);
			PlexAPI.getFilters(sectionKey+"/"+categoryKey, Delegate.create(this, this.onLoadLevel), PlexData.oSettings.timeout);
		}
	}

	private function onLoadLevel():Void {
		
		//var i:Number = PlexData.oSettings.curLevel;
		this.updateMenu(PlexData.oSettings.curLevel);
	}

	private function loadPage(data:Array):Void {
		
		D.debug(D.lDebug, "Home - Doing loadPage...");
		D.debug(D.lDev, "Home - oSections: " + PlexData.oSections._elementType);
		D.debug(D.lDev, "Home - oCategories: " + PlexData.oCategories._elementType);
		D.debug(D.lDev, "Home - oFilters: " + PlexData.oFilters._elementType);
		var key:String = "/library/sections";
		if (PlexData.oCategories._elementType == undefined && PlexData.oSections._children[PlexData.oSections.intPos].key != undefined)
		{
			var sectionKey:String = PlexData.oSections._children[PlexData.oSections.intPos].key;
			PlexAPI.getCategories(sectionKey, Delegate.create(this, this.loadPage), PlexData.oSettings.timeout);
			PlexData.oSettings.curLevel ++;
			return;
		} else {
			key = key + "/" + PlexData.oSections._children[PlexData.oSections.intPos].key;
			key = key + "/" + PlexData.oCategories._children[PlexData.oCategories.intPos].key;
		}
		if (PlexData.oFilters._elementType != undefined) 
		{
			key = key + "/" + PlexData.oFilters._children[PlexData.oFilters.intPos].key;
		}
		D.debug(D.lDev, "Home - loadPage Calling getViewGroup with: " + key);
		PlexAPI.getViewGroup(key, Delegate.create(this, this.onLoadPage), PlexData.oSettings.timeout);
	}
	
	private function onLoadPage(strViewGrouop:String):Void {
		D.debug(D.lDev, "Home - onLoadPage strViewGroup: " + strViewGrouop);
		var i:Number = PlexData.oSettings.curLevel
		var page:String = "";
		switch (i) {
			case 1:
				page = this.menu1MC.item_2.txt.htmlText = PlexData.oSections._children[PlexData.oSections.intPos].title;
			break;
			case 2:
				page = this.menu2MC.item_2.txt.htmlText = PlexData.oCategories._children[PlexData.oCategories.intPos].title;
			break;
			case 3:
				page = this.menu3MC.item_2.txt.htmlText = PlexData.oFilters._children[PlexData.oFilters.intPos].title;
			break;
		}
		
		switch (page.toLowerCase()) {
			case "exit" :
				this.destroy();
				Util.loadURL("http://127.0.0.1:8008/system?arg0=load_launcher");
				break;
			case "settings" :
				this.destroy();
				gotoAndPlay("settings");
				break;
			default :
				if (strViewGrouop == "secondary" ) {
					PlexData.oSettings.curLevel ++;
					if (i > 3)
					{
						PlexData.oSettings.curLevel = 3;
					}
					this["loadLevel" + PlexData.oSettings.curLevel]();
				} else {
					this.destroy();
					gotoAndPlay("wall");
				}
				break;
		}
	}
	
	private function loadBackground():Void{
		var key:String = PlexData.oSettings.backgroundKey;
		
		if (PlexData.oBackground._elementType == undefined)
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
		D.debug(D.lDev, "Home - Calling background update with: " + PlexData.oBackground._children[PlexData.oBackground.intPos].art);
		var _data:Array = new Array();
		_background._set(PlexData.oBackground._children[PlexData.oBackground.intPos].art);
		clearInterval(crossfadeInterval);
		crossfadeInterval = setInterval(Delegate.create(this,crossfade),15000);
	}
	
	private function crossfade() {
		if(++PlexData.oBackground.intPos >= PlexData.oBackground.intLength) {PlexData.oBackground.intPos = 0;};
		this._background._update(PlexData.oBackground._children[PlexData.oBackground.intPos].art);
	}
	
	private function setStage():Void {

		_background = new Background(this.mainMC);
		
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
		
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
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