import plexNMT.as2.api.PlexAPI;

import plexNMT.as2.common.Settings;
import plexNMT.as2.common.ExtArray;

import com.syabas.as2.common.GridLite;
//import com.syabas.as2.common.Grid;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.PlayerMain;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import caurina.transitions.Tweener;

class plexNMT.as2.pages.Main {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.MainMenu;
	public static var plexURL:String = "http://192.168.0.3:32400/";
	
	// Public Properties:
	// Private Properties:
	private var parentMC:MovieClip = null;	// the parent movieClip to attach the main movieClip.

	private var mainMC:MovieClip = null;
	private var g:GridLite = null;			// Grid object used for the main listing.
	//private var g:Grid = null;			// Grid object used for the main listing.
	private var itemMarquee:Marquee = null;	// Marquee for the listing item.
	private var msgMarquee:Marquee = null;	// Marquee for the item description.
	//private var menu:MainMenu = null;		// Menu object.
	private var fn:Object = null;			// storing all Delegate.create functions for performance tuning.
	
	private var link:String = null;			// set link to be loaded on the Grid.
	private var menuLevel:Number = 0;
	private var mcArray:Array = null;
	
	private static var plexSection:String = null;
	private static var plexCategory:String = null;
	private static var plexFilter:String = null; 
	private static var plexType:String = null;
	
	private var keyListener:Object = null;	// Object use to listen Key event.
	private var klTimeout:Number = null;	// Timeout use to enable Key Listener.

	// Destroy all global variables.
	public function destroy():Void
	{
		trace("Doing Main.Clean Up...");

		cleanUp(this.parentMC);
		
		this.g.destroy();
		delete this.g;
		this.g = null;
		
		this.itemMarquee.stop(false);
		delete this.itemMarquee;
		this.itemMarquee = null;
		
		this.msgMarquee.stop(false);
		delete this.msgMarquee;
		this.msgMarquee = null;
		
		delete this.mcArray;
		this.mcArray = null;
		
		delete this.fn;
		this.fn = null;
		
		Key.removeListener(this.keyListener);
		delete this.keyListener;
		this.keyListener = null;
		
		delete this.Main;
		this.Main = null;
		
		//var_dump(_level0);
		//trace("Done root dump...");
		//var_dump(_root);
		trace("Done Main.Clean Up...");

	}
	
	// Initialization:
	public function Main(parentMC:MovieClip) 
	{
		this.parentMC = parentMC;
		this.itemMarquee = new Marquee();
		this.msgMarquee = new Marquee();
		
		// contructing the Grid.
		this.g = new GridLite();
		this.g.xHoriz = true;
		this.g.xWrapLine = false;
		this.g.xHLStopTime = 700;
		this.g.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g.hlCB = Delegate.create(this, this.hlCB);
		this.g.unhlCB = Delegate.create(this, this.unhlCB);
		this.g.onHLStopCB = Delegate.create(this, this.onHLStopCB);
		this.g.onEnterCB = Delegate.create(this, this.onEnterCB);
		
		// storing all the callback functions.
		this.fn =
		{
			onLoadXML:Delegate.create(this, this.onLoadXML),
			onLoadRecentlyAdded:Delegate.create(this, this.onLoadRecentlyAdded),
			onEnableKeyListener:Delegate.create(this, this.onEnableKeyListener),
			onKeyDown:Delegate.create(this, this.onKeyDown)
		};

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		this.show();
	}
	
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		trace("Doing Main.onKeyDown...");
		trace("KeyCode: " + keyCode);
		switch (keyCode)
		{
			case Key.LEFT:
				break;
			case Key.RIGHT:
				break;
			case Key.DOWN:
				this.navDown();
				break;
			case Key.UP:
				this.navUp();
				break;
				break;
		}
	}
	
	private function onLoadXML(data:Array):Void
	{
		this.g.data = null;
		this.itemMarquee.stop();
		
		this.g.clear();
		this.g.xMCArray = mcArray;
		
		if (data == null) // network problem.
		{
			this.mainMC.msg.text = "Unable to connect to internet. Press enter to retry.";
			this.enableKeyListener();
		}
		else if (data.length == 0) // no data.
		{
			this.mainMC.msg.text = "No record found. Press enter to retry.";
			this.enableKeyListener();
		}
		else
		{
			switch (menuLevel) {
				case 0:
					trace("Adding Data to Item MC Object...");
					data.push({title:"Exit", key:"0", url:"system?arg0=load_launcher"},{title:"Settings", key:"0", url:""});
					
				break;
				case 1:
					//this.g.clear();
					//this.g.xMCArray = mcArray;
				break;
				case 2:
					//this.g.clear();
					//this.g.xMCArray = mcArray;
				break;
			}
			
			this.g.data = data;
			this.g.createUI(0);
			this.g.highlight(0);
		}

		this.mainMC.loadingMC.removeMovieClip(); // remove loading animation.
		
		this.mainMC.msg.text = "Recently Added: ";
		this.enableKeyListener();
	}
	
	private function loadRecentlyAdded():Void
	{
		PlexAPI.loadData(plexURL + "library/sections/3/recentlyAdded", this.fn.onLoadRecentlyAdded, 5000);
	}
	
	private function navDown():Void
	{
		var data:Object = getSelected();
		switch (menuLevel){
			case 0:
				this.disableKeyListener();
				plexSection = data.key;
				PlexAPI.loadData(plexURL + "library/sections/" + plexSection, this.fn.onLoadXML, 5000);
				menuLevel = menuLevel + 1;
			break;
			case 1:
				this.disableKeyListener();
				plexCategory = data.key;
				PlexAPI.loadData(plexURL + "library/sections/" + plexSection + "/" + plexCategory, this.fn.onLoadXML, 5000);
				menuLevel = menuLevel + 1;
			break;
		}
		
	}
	
	private function navUp():Void
	{
		var data:Object = getSelected();
		switch (menuLevel){
			case 1:
				this.disableKeyListener();
				plexSection = null;
				PlexAPI.loadData(plexURL + "library/sections/", this.fn.onLoadXML, 5000);
				menuLevel = menuLevel - 1;
			break;
			case 2:
				this.disableKeyListener();
				plexFilter = null;
				PlexAPI.loadData(plexURL + "library/sections/" + plexSection, this.fn.onLoadXML, 5000);
				menuLevel = menuLevel - 1;
			break;
		}
		
	}
	
	private function onLoadRecentlyAdded(data:Object):Void
	{
		trace("Doing onLoadRecentlyAdded...");
		//var_dump(data);
		var dataLen:Number = data.length;
		var titleArray:Array = new Array();
		for (var i:Number=0; i<dataLen; i++)
		{
			//var_dump(i);
			titleArray[i] = data[i].title.toString();
		}
		
		this.mainMC.msg.text = "Recently Added: " + titleArray.join("  |  ");
		this.msgMarquee.start(this.mainMC.msg, {delayInMillis:300, stepPerMove:2, endGap:30, vertical:false, framePerMove:1}); // start description Marquee.
		trace("Done onLoadRecentlyAdded...");
	}
	
	public function show():Void
	{
		// constructing the main movieClip.
		this.mainMC = this.parentMC.attachMovie("homeMC", "homeMC", this.parentMC.getNextHighestDepth(), {_x:0, _y:0});

		// initialized grid.
		/*var mcArray:Array = UI.attachMovieClip({
			parentMC:this.mainMC,
			cSize:5,
			rSize:1,
			mcPrefix:"item"
		});*/
		mcArray = UI.attachMovieClip({
			parentMC:this.mainMC,
			cSize:5,
			rSize:1,
			mcPrefix:"item"
		});
		//var_dump(mcArray);
		this.g.xMCArray = mcArray;

		// load menu data.
		//PlexAPI.loadData("http://192.168.0.3:32400/library/sections/", "sections", this.fn.onloadData, 5000);
		PlexAPI.loadData(plexURL + "library/sections", this.fn.onLoadXML, 5000);
		this.loadRecentlyAdded();
	}
	
	private function onItemUpdateCB(o:Object):Void
	{
		var data:Object = o.data;

 		// setting the item title on the listing item movieClip.
		// enclosed with [ ] if sub listing exists.
		o.mc.txt.htmlText = (Util.isBlank(data.url) ? data.title : data.title);
	}
	
	/*
	* Clear listing item. Will be called by the grid.
	*/
	private function onItemClearCB(o:Object):Void
	{
		o.mc.txt.htmlText = ""; // clear listing item.
		o.mc.gotoAndStop("unhl"); // go to unhl frame. no highlight.
		this.itemMarquee.stop(); // stop Marquee.
		
		
	}

	/*
	* Highlight listing item. Will be called by the grid.
	*/
	private function hlCB(o:Object):Void
	{
		var data:Object = o.data;
		var mc:MovieClip = o.mc;
		mc.gotoAndStop("hl"); // show highlight.
	}
	
	/*
	* Remove listing item highlight. Will be called by the grid.
	*/
	private function unhlCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");

		// stop all Marquee.
		this.itemMarquee.stop();
		//this.descMarquee.stop();
	}
	
	/*
	* When listing item is selected then start video playback. Will be called by the grid.
	*/
	private function onEnterCB(o:Object):Void
	{
		trace("Doing onEnterCB...");
		var menuItem:Object = getSelected();
		//var_dump(menuItem);
		var plex:Array = new Array();
		
		var itemTitle:String = menuItem.title;
		trace("itemTitle: " + itemTitle);
		switch (itemTitle) {
			case "Exit":
				this.destroy();
				Util.loadURL("http://127.0.0.1:8008/system?arg0=load_launcher");
			break;
			case "Settings":
				this.destroy();
				//gotoAndPlay(1);
			break;
			default:
				switch (menuLevel)
				{
					case 0 :
						plex.currentSection = menuItem.key;
						plex.currentCategory = "all";
						plex.currentFilter = null;
					break;
					case 1 :
						plex.currentCategory = menuItem.key;
						plex.currentFilter = null;
					break;
					case 2 :
						plex.currentFilter = menuItem.key;
					break;
				}
				plex.currentType =  menuItem.type;
				_level0.plex = plex;
				//var_dump(_level0);		
				this.destroy();
				gotoAndPlay("wall");
			break;
		}
		trace("Done onEnterCB...");
	}
	
	/*
	* Highlight stop for hlStopTime milliseconds. Will be called by the grid.
	*/
	private function onHLStopCB(o:Object):Void
	{
		var mc:MovieClip = o.mc;
		this.itemMarquee.start(mc.txt, {delayInMillis:200, stepPerMove:2, endGap:10, vertical:false, framePerMove:1});// start Marquee.
		var mainMC:MovieClip = this.mainMC;
		//this.descMarquee.start(mainMC.desc, {delayInMillis:1000, stepPerMove:1, endGap:3, vertical:true, framePerMove:30}); // start description Marquee.
	}
	
	private function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.klTimeout = _global.setTimeout(this.fn.onEnableKeyListener, 100); // delay abit to prevent getting the previously press key.
	}
	
	private function onEnableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = this.fn.onKeyDown;
	}
	
	private function disableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = null;
	}
	
	/*
	* Get selected menu item object. Return 0 if selected index is less than 0.
	*/
	public function getSelected():Object
	{
		var hl:Number = this.g._hl;
		if (hl < 0)
			hl = 0;
		return this.g.getData(hl);
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
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
		trace(_obj);
		for (var i in _obj)
		{
			trace("_obj[" + i + "]: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object")
			{
				var_dump(_obj[i]);
			}
			trace(_obj[i]);
		}
		trace("Done Main.var_dump...");
	}
}