﻿import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.D;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.api.PopAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;
//
import plexNMT.as2.common.Background;
import plexNMT.as2.common.MovieDetailsPane;
import plexNMT.as2.common.MenuTop;
import plexNMT.as2.common.PosterNav;
import plexNMT.as2.common.ResumePopUp;

class plexNMT.as2.pages.MovieDetails
{
	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.MovieDetails;
	
	// Private Variables
	private var mainMC:MovieClip = null;
	private var preloadMC:MovieClip = null;
	//key Listener
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	//TAB Control
	private var select:Array = new Array();
	//Slow Update
	private var slowUpdateInterval:Number;
	private var popAPI:PopAPI = null;
	
	private var _background:Background = null;
	private var _details:MovieDetailsPane = null;
	private var _poster:PosterNav = null;
	private var _menu:MenuTop = null;
	//var listenerObj:Object = new Object();
	
	// Destroy all global variables.
	public function destroy():Void
	{
		_background.destroy();
		_details.destroy();
		_menu.destroy();
		_poster.destroy();
		clearInterval(slowUpdateInterval);
		slowUpdateInterval = null;
		//Remove PopAPI
		popAPI = null;
		//Remove Listener
		this.disableKeyListener();
		Key.removeListener(this.keyListener);
		delete keyListener;

	}
	
	public function MovieDetails(parentMC:MovieClip)
	{
		D.debug(D.lInfo, "MovieDetails - Doing plexNMT.movieDetails...");
		D.debug(D.lDebug, "MovieDetails - Free Memory: " + fscommand2("GetFreePlayerMemory") + "kB");
		trace("MovieDetails - Doing plexNMT.movieDetails...");

		this.mainMC = parentMC;

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		//PopAPI interface
		popAPI= new PopAPI();
		
		this.preloadMC = this.mainMC.attachMovie("busy", "busy", mainMC.getNextHighestDepth(), {_x:640, _y:360, _width:200, _height:200});
		
		var key:String = PlexData.oWallData._children[PlexData.oWallData.intPos].key

		D.debug(D.lDebug, "MovieDetails - Calling getMovieData With: " + key);
		PlexAPI.getMovieData(key, Delegate.create(this, this.onDataLoad), PlexData.oSettings.timeout);
	}
	
	public function fastUpdate(arg:Object)
	{
		//Menu Number of:
		this._menu._update();
		//Details
		this._details.setText(PlexData.oWallData._children[PlexData.oWallData.intPos].title,
							  PlexData.oWallData._children[PlexData.oWallData.intPos].year,
							  PlexData.oWallData._children[PlexData.oWallData.intPos].tagline);
		//Slow Update
		clearInterval(slowUpdateInterval);
		slowUpdateInterval = setInterval(Delegate.create(this,slowUpdate),700);
		
	}
	
	public function slowUpdate()
	{
		D.debug(D.lDev, "MovieDetails - Doing slowUpdate...");
		clearInterval(slowUpdateInterval);
		var key:String = PlexData.oWallData._children[PlexData.oWallData.intPos].key
		PlexAPI.getMovieData(key, Delegate.create(this, this.onUpdateLoad), PlexData.oSettings.timeout);
	}
	
	private function onUpdateLoad()
	{
		this._details._update();
		var key:String = PlexData.oMovieData._children[0].art
		this._background._update(key);
	}
	
	private function onDataLoad(data:Object):Void
	{
			//Add Components
			_background = new Background(this.mainMC);
			
			_details = new MovieDetailsPane(this.mainMC);
			
			_poster = new PosterNav(this.mainMC, PlexData.oWallData._children, Delegate.create(this, this.fastUpdate));
			
			_menu = new MenuTop(this.mainMC);
			
			_background._set(PlexData.oMovieData._children[0].art);
			
			//this.select = [_details, _poster, _menu];
			this.select = [_details, _poster];
			this.select[0]._select();
			this.enableKeyListener();
						
			this.preloadMC.removeMovieClip();
			delete this.preloadMC;
			this.preloadMC = null;
	}
	
	private function enableKeyListener():Void
	{
		D.debug(D.lDev, "Moveie Details - Doing enableKeyListener...");
		if (this.keyListener.onKeyDown != null)
			return;
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.klInterval = _global["setInterval"](Delegate.create(this, this.onEnableKeyListener), 100); // delay abit to prevent getting the previously press key.
	}

	private function onEnableKeyListener():Void
	{
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.keyListener.onKeyDown = Delegate.create(this, this.keyDownCB);
	}

	private function disableKeyListener():Void
	{
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.keyListener.onKeyDown = null;
	}
	
	private function keyDownCB():Void
	{
		var keyCode:Number = Key.getCode();
		var asciiCode:Number = Key.getAscii();
		D.debug(D.lDev, "Moveie Details - keyDownCB.keyCode: " + keyCode);
		
		switch (keyCode)
		{
			case Remote.BACK:
			case "soft1":
			case 81: //Keyboard Q
				//this.disableKeyListener();
				this.destroy();
				gotoAndPlay("wall");
			break;
			case Remote.YELLOW:
				this.destroy();
				gotoAndPlay("settings");
			break;
			case Remote.RED:
			case 79:
				//TAB Toggle select's
				this.select[0]._unselect();
				this.select.push(this.select.shift());
				this.select[0]._select();
			break;
			case Remote.BLUE:
			case 80:
				//SHIFT+TAB Toggle select's
				this.select[0]._unselect();
				this.select.unshift(this.select.pop());
				this.select[0]._select();
			break;
			case Remote.HOME:
				this.destroy();
				gotoAndPlay("main");
			break;
			case Remote.STOP:
				popAPI.stopUpdates();
			break;
			case Remote.PLAY:
			case Remote.ENTER:
				D.debug(D.lDev, "MovieDetails - PLAY Button Pressed...");
				var key:String = PlexData.oWallData._children[PlexData.oWallData.intPos].ratingKey;
				var partKey:String = PlexData.oWallData._children[PlexData.oWallData.intPos]._children[0]._children[0].key;
				var resume:Number = 0;
				
				if (PlexData.oWallData._children[PlexData.oWallData.intPos].viewOffset != undefined && false) //Disable till play offset works
				{
					resume = PlexData.oWallData._children[PlexData.oWallData.intPos].viewOffset / 1000;
					this.disableKeyListener();
					var popUp:ResumePopUp = new ResumePopUp(this.mainMC, Delegate.create(this, this.onEnableKeyListener));
					
				} else {
					D.debug(D.lDev, "MovieDetails - Calling playVOD with:");
					D.debug(D.lDev, "MovieDetails - 	key => " + key);
					D.debug(D.lDev, "MovieDetails - 	partKey => " + partKey);
					D.debug(D.lDev, "MovieDetails - 	resume => " + resume);
					popAPI.playVOD(key, partKey, resume);
				}
			break;
		}
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
}