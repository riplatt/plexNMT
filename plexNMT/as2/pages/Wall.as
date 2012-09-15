import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Background;
import plexNMT.as2.common.WallDetails;
import plexNMT.as2.common.MenuTop;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.D;

class plexNMT.as2.pages.Wall
{
	//public static var plexURL:String = "http://192.168.0.3:32400/";
	//Strings
	private var wallC:Number = 7;
	private var wallR:Number = 3;
	private var plexSection:String = null;
	private var plexCategory:String = null;
	private var plexFilter:String = null; 
	private var plexType:String = null;
	private var plexPath:String = null;
	private var wallCurrent:Number = null;
	private var wallData:Array = new Array();
	private var delayUpdate:Number = null;

	private var parentMC:MovieClip = null;
	private var mainMC:MovieClip = null;
	private var preloadMC:MovieClip = null;
	private var listMC:MovieClip = null;
	private var bobbyMC:MovieClip = null;
	private var g:GridLite = null;
	private var imgLoader:IMGLoader = null;
	private var titleMarquee:Marquee = null;
	private var data:Array = null;
	
	private var _background:Background = null;
	private var _details:WallDetails = null;
	private var _menu:MenuTop = null;
	
	// Destroy all global variables.
	public function destroy():Void
	{
		_background.destroy();
		_details.destroy();
		_menu.destroy();
		
		cleanUp(this.parentMC);
		
		this.g.destroy();
		delete this.g;
		this.g = null;
		
		this.imgLoader.destroy();
		delete this.imgLoader;
		this.imgLoader = null();
		
		this.titleMarquee.stop(false);
		delete this.titleMarquee;
		this.titleMarquee = null;
		
		trace("Done Wall.Clean Up...");
		//var_dump(_level0);
	}

	public function Wall(parentMC:MovieClip)
	{
		trace("Doing Wall...");
		
		var i:Number = PlexData.oSettings.curLevel;
		D.debug(D.lDebug,"Wall - PlexData.oSettings.curLevel: " + i);
		D.debug(D.lInfo,"Wall - Current URL: " + PlexData.oData["level"+i].current.url);
		D.debug(D.lDebug, "Wall - Free Memory: " + fscommand2("GetFreePlayerMemory") + "kB");
		var l1:String = "";
		if(i == 1)
		{
			var l1 = "/all";
		}
		
		_background = new Background(parentMC);

		this.parentMC = parentMC;
		this.mainMC = this.parentMC.attachMovie("wallMC", "mainMC", 1, {_x:0, _y:0});
		this.preloadMC = this.parentMC.attachMovie("busy001", "busy", 3, {_x:640, _y:360, _width:400, _height:400});
		
		

		// set how many Image will be loading at one time. Default is 1. Maximum 6.
		this.imgLoader = new IMGLoader(6);

		this.titleMarquee = new Marquee();
		
		if (PlexData.oWallData.MediaContainer[0] != undefined)
		{	
			this.onLoadData();
		} else {
			var key:String = "/library/sections/";
			if (PlexData.oSections.MediaContainer[0] != undefined && PlexData.oCategories.MediaContainer[0] == undefined) 
			{
				key = key + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key + "/all";
			}else{
				key = key + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key + "/";
				key = key + PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.key + "/";
			}
			if (PlexData.oFilters.MediaContainer[0] != undefined) 
			{
				key = key + PlexData.oFilters.MediaContainer[0].Directory[PlexData.oFilters.intPos].attributes.key;
			}
			trace("Calling getWallData with: " + key);
			PlexAPI.getWallData(key, Delegate.create(this, this.onLoadData), 5000);
		}
		/*if (PlexData.oWall.current.index != null){
			D.debug(D.lDebug,"Wall - Using Old Wall Data...");
			this.onLoadData(PlexData.oWall.items);
		} else {
			D.debug(D.lDebug,"Wall - Loading Wall Data with: " + PlexData.oData["level"+i].current.url+l1);
			PlexAPI.loadData(PlexData.oData["level"+i].current.url+l1, Delegate.create(this, this.onLoadData), 5000);
		}*/

		_details = new WallDetails(parentMC);
		_menu = new MenuTop(parentMC);
	}

	private function onLoadData()
	{
		//PlexData.oWall.items = data.concat();
		//wallData = data;
		/*this.preloadMC.removeMovieClip();
		delete this.preloadMC;
		this.preloadMC = null;*/
		this.updateBackground();
		PlexData.setWall();
		
		this.createGridLite();

	//trace("Done onLoadData...");
	}

	private function createGridLite():Void
	{
		this.listMC = this.mainMC.createEmptyMovieClip("listMC", 1);
		
		// using UI class to create and attach 4 columns and 3 rows MovieClip 2D arrays with 20 pixels horizontal and 10 pixels vertical gaps.
		var mcArray:Array = UI.attachMovieClip({
												parentMC:this.listMC, 
												cSize:PlexData.oWall.columns, 
												rSize:PlexData.oWall.rows,
												mcPrefix:"item", 
												mcName:"itemMC",
												x:PlexData.oWall.topLeft.x, 
												y:PlexData.oWall.topLeft.y,
												width:PlexData.oWall.thumb.width,
												height:PlexData.oWall.thumb.height,
												hgap:PlexData.oWall.hgap, 
												vgap:PlexData.oWall.vgap
		});

		this.g = new GridLite();

		// all variables prefix with 'x' are to be set ONE TIME ONLY.
		this.g.xMCArray = mcArray;

		// true to scroll Horizontally. Default is false(Vertical).
		this.g.xHoriz = false;

		// true to wrap from last to 1st, and from 1st to last line. Default is true.
		this.g.xWrap = true;

		// true to wrap from line to line (e.g. For vertical, go right on last column will go to
		// next line, go left on 1st column will go to the previous line). Default is true
		this.g.xWrapLine = true;

		// how many milliseconds the highlight navigation stop before calling to the onHLStopCB callback function. Default is 0(disable).
		this.g.xHLStopTime = 700;

		// data to be displayed on the Grid.
		//this.g.data = data;
		if (PlexData.oWallData.MediaContainer[0].Video != undefined) 
		{
			this.g.data = PlexData.oWallData.MediaContainer[0].Video;
		} else {
			this.g.data = PlexData.oWallData.MediaContainer[0].Directory;
		}

		// --- Set callback functions ---

		// callback function to Update the data on the movieClip. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
		this.g.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);

		// callback function to Clear the movieClip. Default is null.
		// Arguments: {mc:MovieClip}
		this.g.onItemClearCB = Delegate.create(this, this.onItemClearCB);

		// callback function to highlight the movieClip. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
		this.g.hlCB = Delegate.create(this, this.hlCB);

		// callback function to remove highlight from the movieClip. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
		this.g.unhlCB = Delegate.create(this, this.unhlCB);

		// callback function to be called when highlight go above the top most data row. Default is null.
		// Return: true to remain in the grid, else will unhighlight.
		this.g.overTopCB = Delegate.create(this, this.overTopCB);

		// callback function to be called when highlight go below the bottom most data row. Default is null.
		// Return: true to remain in the grid, else will unhighlight.
		this.g.overBottomCB = Delegate.create(this, this.overBottomCB);

		// overLeftCB:Function - callback function to be called when highlight go to the left over left most data column. Default is null.
		// Return: true to remain in the grid, else will unhighlight.
		this.g.overLeftCB = Delegate.create(this, this.overLeftCB);

		// callback function to be called when highlight go to the right over right most data column. Default is null.
		// Return: true to remain in the grid, else will unhighlight.
		this.g.overRightCB = Delegate.create(this, this.overRightCB);

		// callback function to be called when enter key is pressed. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
		this.g.onEnterCB = Delegate.create(this, this.onEnterCB);

		// callback function to be called when key other than up/down/left/right/enter is called. Default is null.
		// Arguments: o:Object {keyCode:Number, asciiCode:Number}
		this.g.onKeyDownCB = Delegate.create(this, this.onKeyDownCB);

		// callback function to be called when highlight stop for hlStopTime milliseconds. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
		this.g.onHLStopCB = Delegate.create(this, this.onHLStopCB);

		// callback function to be called when item is selected/unselected. Default is null.
		// Arguments: {mc:MovieClip, data:Object, dataIndex:Number, selected:Boolean}
		// Return: true to reset current selected item.
		//this.g.singleSelectCB = Delegate.create(this, this.singleSelectCB);

		// --- Create UI ---

		// If hl(data index) equals undefined or null then will load data from index 0.
		this.g.createUI(0);

		this.preloadMC.removeMovieClip();
		delete this.preloadMC;
		this.preloadMC = null;
		
		// Highlight with the specified hl(data index) and enable the keyListener.
		//trace("Highlighting Current...");
		this.g.unhighlight()
		this.g.highlight(PlexData.oWallData.intPos);

	}

	
	private function onItemShowCB(o:Object):Void
	{
		//trace("Doing onItemShowCB...");
		o.mc.preload.removeMovieClip();
		var preload:MovieClip = o.mc.attachMovie("preload40", "busy", 1, {_x:58, _y:87});
		o.mc.fail.text = "Unable to Load Image...";
		//trace("o.mc._name:" + o.mc._name);
		//trace("o.mc.imgMC:" + o.mc.imgMC);
		this.imgLoader.unload(o.mc._name, o.mc.imgMC, null);
	}

	private function onItemUpdateCB(o:Object):Void
	{
		//trace("Doing onItemUpdateCB with: " + o.mc);
		if(o.dataIndex == this.g._hl)
		{
			this.hlCB(o);
			this.onHLStopCB(o);
		}
		var url:String = PlexData.oSettings.url + "/photo/:/transcode?width="+PlexData.oWall.thumb.size+"&height="+PlexData.oWall.thumb.size+"&url=" + escape(PlexData.oSettings.url + Util.trim(o.data.attributes.thumb))
		this.imgLoader.load(o.mc._name, url, o.mc.imgMC,
			{
				mcProps:{_height:200,_width:200}, lmcId:"busy",
				lmcProps:{_x:100,_y:100},
				retry:0, timeout:30000, addToFirst:false,
				scaleMode:2, scaleProps:{center:false, 
										width:PlexData.oWall.thumb.width,
										height:PlexData.oWall.thumb.height,
										actualSizeOption:1},
				doneCB:Delegate.create(this, function(success:Boolean, obj:Object)
					{
						o.mc.preload.removeMovieClip();
						if(success == false)
							obj.o.mc.fail.text = "NoImage"
					})
			});
	}

	private function onItemClearCB(o:Object):Void
	{
		//trace("onItemClearCB...");
		this.imgLoader.unload(o.mc._name, o.mc.imgMC, "busy");

		this.mainMC.txtName.htmlText = "";
		o.mc.gotoAndStop("unhl");
	}

	private function hlCB(o:Object):Void
	{
		//trace("Doing hlCB...");
		PlexData.oWallData.intPos = this.g._hl;
		_details.setText();
		_menu._update();
		
		var data:Object = o.data;
		var mc:MovieClip = o.mc;
		mc.gotoAndStop("hl");
		//mc.txt.htmlText = Number(this.g._hl + 1) + "/" + this.g._len;
		this.mainMC.title.htmlText = o.data.attributes.title
		this.mainMC.tagline.htmlText = o.data.attributes.tagline
		/*if(!(data.title == undefined || data.title == null))
			this.mainMC.title.htmlText = data.title;
		if(!(data.tagline == undefined || data.tagline == null))
			this.mainMC.tagline.htmlText = data.tagline;*/
		this.mainMC.count.text = Number(this.g._hl + 1) + "/" + this.g._len;
	}

	private function unhlCB(o:Object):Void
	{
		//trace("Doing unhlCB...");
		this.titleMarquee.stop();
		this.mainMC.txtName.htmlText = "";
		o.mc.gotoAndStop("unhl");
	}

	private function onHLStopCB(o:Object):Void
	{
		//trace("Doing onHLStopCB...");
		// Stop the Marquee
		_details._update();
		
		this.mainMC.txtName.htmlText = "";
		this.titleMarquee.stop();

		this.titleMarquee.start(o.mc.title, {delayInMillis:1000, stepPerMove:2, endGap:10, vertical:false, framePerMove:1});
		clearInterval(delayUpdate);
		delayUpdate = setInterval(Delegate.create(this, updateBackground),3000);
	}
	
	private function updateBackground()
	{
		//trace("Wall - Doing Background up date...");
		clearInterval(delayUpdate);
		var key:String = "";
		if (PlexData.oWallData.MediaContainer[0].Directory != undefined) 
		{
			key = PlexData.oWallData.MediaContainer[0].Directory[this.g._hl].attributes.art;
		} else {
			key = PlexData.oWallData.MediaContainer[0].Video[this.g._hl].attributes.art;
		}
		this._background._update(key);
	}
	private function onKeyDownCB(obj:Object):Void
	{
		//trace(obj.keyCode); // key code receive from listener
		//trace(obj.asciiCode); // ASCII code receive from listener
		var txtKeyCode = obj.keyCode;
		clearInterval(delayUpdate);
		
		switch (txtKeyCode)
		{
			 case "soft1":
			 case Remote.BACK:
				this.destroy();
				PlexData.oWallData = new Object();
				//PlexData.oWall.current = new Object();
				//PlexData.oWall.items = new Array();
				gotoAndPlay("main");
			 break;
			 case "soft2":
			 case Remote.PLAY:
				//this.destroy();
				//var_dump(obj);
				//D.debug(D.lInfo,"Wall - Trying to play, Title: " + obj.title + " From: " + obj.playURL);
				//Util.loadURL("http://127.0.0.1:8008/playback?arg0=start_vod&arg1=" + obj.title + "&arg2=" + obj.playURL + "&arg3=show&arg4=0"); // Direct Play.
			break;
			 case Remote.HOME:
				this.destroy();
				PlexData.oWallData = new Object();
				gotoAndPlay("main");
			break;
			case Remote.YELLOW:
				this.destroy();
				gotoAndPlay("settings");
			break;
		}
		//delayUpdate = setInterval(Delegate.create(this, updateBackground),700);
	}

	private function onEnterCB(o:Object):Void
	{
		switch (o.data.attributes.type)
		{
			case "movie":
				//PlexData.oWall.current.url = PlexData.oSettings.url + o.data.attributes.key //"library/metadata/" + o.data.ratingKey;
				//PlexData.oWall.current.index = o.data.index - 1;
				PlexData.oWallData.intPos = this.g._hl;
				this.destroy();
				gotoAndPlay("movieDetails");
			break;
		}
		/*trace("dataIndex: " + o.dataIndex);
		trace("\n");*/
	}

	private function overRightCB():Boolean
	{
	//trace("over right...");
		return true; // return false to unhighlight from grid
	}

	private function overLeftCB():Boolean
	{
	//trace("over left...");
		return true; // return false to unhighlight from grid
	}

	private function overTopCB():Boolean
	{
	//trace("over top...");
		return true; // return false to unhighlight from grid
	}

	private function overBottomCB():Boolean
	{
	//trace("over bottom...");
		return true; // return false to unhighlight from grid
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
			trace("i: " + i);
			if (i != "plex"){
				trace("i: " + i + ", type: " + typeof(_obj[i]));
				if (typeof(_obj[i]) == "object"){
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
	
	private function var_dump(_obj:Object)
	{
		trace("Doing var_dump...");
		trace(_obj);
		trace("Looping Through _obj...");
		for (var i in _obj)
		{
			trace("_obj[" + i + "] = " + _obj[i] + " type = " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object")
			{
				var_dump(_obj[i]);
			}
		}
	}
}