import mx.utils.Delegate;
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
import plexNMT.as2.common.SeasonDetailsPane;
import plexNMT.as2.common.MenuTop;
import plexNMT.as2.common.PosterNav;
import plexNMT.as2.common.SeasonNav;
import plexNMT.as2.common.EpisodeNav;
import plexNMT.as2.common.ResumePopUp;

class plexNMT.as2.pages.SeasonDetails {
	
	// Constants:	
	public static var CLASS_REF = plexNMT.as2.pages.SeasonDetails;

	// Private Variables
	private var mainMC:MovieClip = null;
	private var preloadMC:MovieClip = null;
	//key Listener
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	//TAB Control
	private var select:Array = new Array();
	//Slow Update
	private var slowUpdateInterval:Number = 0;
	private var slowUpdateSection:String = "";
	
	private var popAPI:PopAPI = null;
	
	private var _background:Background = null;
	private var _details:SeasonDetailsPane = null;
	private var _poster:PosterNav = null;
	private var _season:SeasonNav = null;
	private var _episode:EpisodeNav = null;
	private var _menu:MenuTop = null;
	
	// Initialization:
	public function SeasonDetails(parentMC:MovieClip) 
	{
		D.debug(D.lDev, "SeasonDetails - Doing plexNMT.movieDetails...");
		
		this.mainMC = parentMC;

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		//PopAPI interface
		popAPI= new PopAPI();
		
		this.preloadMC = this.mainMC.attachMovie("busy", "busy", mainMC.getNextHighestDepth(), {_x:640, _y:360, _width:200, _height:200});
		
		var key:String = PlexData.oWallData.MediaContainer[0].Directory[PlexData.oWallData.intPos].attributes.key
		trace("oWallData.intPos: " + PlexData.oWallData.intPos);
		//trace("Calling getMovieData With: " + key);
		D.debug(D.lDev, "SeasonDetails - Calling getSeasonData With: " + key);
		trace("SeasonDetails - Calling getSeasonData With: " + key);
		PlexAPI.getSeasonData(key, Delegate.create(this, this.onSeasonLoad), 5000);
		
	}
	
	// Destroy all global variables.
	public function destroy():Void
	{
		_background.destroy();
		_details.destroy();
		_menu.destroy();
		_poster.destroy();
		_season.destroy();
		_episode.destroy();
		clearInterval(slowUpdateInterval);
		slowUpdateInterval = null;
		//Remove PopAPI
		popAPI = null;
		//Remove Listener
		this.disableKeyListener();
		Key.removeListener(this.keyListener);
		delete keyListener;

	}
	
	private function onSeasonLoad():Void
	{
		var key:String = PlexData.oSeasonData.MediaContainer[0].Directory[0].attributes.key
		PlexAPI.getEpisodeData(key, Delegate.create(this, this.onDataLoad), 5000);
	}
	private function onDataLoad(data:Object):Void
	{
		D.debug(D.lDev, "SeasonDetails - Doing seasonDetails.parseXML.data... ");
			//Add Components
			_background = new Background(this.mainMC);
			
			_details = new SeasonDetailsPane(this.mainMC);
			
			_poster = new PosterNav(this.mainMC, PlexData.oWallData.MediaContainer[0].Directory, Delegate.create(this, this.fastUpdate));
			_season = new SeasonNav(this.mainMC, PlexData.oSeasonData.MediaContainer[0].Directory, Delegate.create(this, this.fastUpdate));
			_episode = new EpisodeNav(this.mainMC, PlexData.oEpisodeData.MediaContainer[0].Directory, Delegate.create(this, this.fastUpdate));
			
			_menu = new MenuTop(this.mainMC);
			
			_background._set(PlexData.oSeasonData.MediaContainer[0].attributes.art);
			
			
			this.select = [_season, _poster, _episode];
			this.select[0]._select();
			this.enableKeyListener();
						
			this.preloadMC.removeMovieClip();
			delete this.preloadMC;
			this.preloadMC = null;
			
	}
	
	public function fastUpdate(str:String)
	{
		trace("SeasonDetails - fastUpdate str:" + str + "...");
		this.slowUpdateSection = str;
		switch (str)
		{
			case "poster":
				_details._update()
			break;
		}
		
		//Slow Update
		clearInterval(slowUpdateInterval);
		slowUpdateInterval = setInterval(Delegate.create(this,slowUpdate),700);
		
	}
	
	public function slowUpdate()
	{
		D.debug(D.lDev, "SeasonDetails - Doing slowUpdate...");
		trace("SeasonDetails - slowUpdate str:" + this.slowUpdateSection + "...");
		clearInterval(slowUpdateInterval);
		switch (this.slowUpdateSection)
		{
			case "poster":
				//Update Season
				PlexData.oSeasonData.intPos = 0;
				var key:String = PlexData.oWallData.MediaContainer[0].Directory[PlexData.oWallData.intPos].attributes.key;
				PlexAPI.getSeasonData(key, Delegate.create(this, function()
					{
						//Update Background
						_background._update(PlexData.oSeasonData.MediaContainer[0].attributes.art);
						_season._update();
						//Update Episode
						var key:String = PlexData.oSeasonData.MediaContainer[0].Directory[PlexData.oSeasonData.intPos].attributes.key;
						PlexAPI.getEpisodeData(key, Delegate.create(this, function()
							{
								_episode._update();
								//_episode = new EpisodeNav(this.mainMC, PlexData.oEpisodeData.MediaContainer[0].Directory, Delegate.create(this, this.fastUpdate));
							}), 5000);
					}), 5000);
				
				
			break;
			case "season":
				PlexData.oEpisodeData.intPos = 0;
				var key:String = PlexData.oSeasonData.MediaContainer[0].Directory[PlexData.oSeasonData.intPos].attributes.key;
				PlexAPI.getEpisodeData(key, Delegate.create(this, function()
					{
						_episode._update();
						//_episode = new EpisodeNav(this.mainMC, PlexData.oEpisodeData.MediaContainer[0].Directory, Delegate.create(this, this.fastUpdate));
					}), 5000);
			break;
		}
				
		
	}
	
	private function enableKeyListener():Void
	{
		D.debug(D.lDev, "SeasonDetails - Doing enableKeyListener...");
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
		D.debug(D.lDev, "SeasonDetails - keyDownCB.keyCode: " + keyCode);
		
		switch (keyCode)
		{
			case Remote.BACK:
			case "soft1":
			case 81:
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
				D.debug(D.lDev, "SeasonDetails - PLAY Button Pressed...");
				var _data:Array = PlexData.oEpisodeData.MediaContainer[0].Video
				var _len:Number = PlexData.oEpisodeData.intLength
				var key:String = "";
				var _title:String = "";
				var i:Number = 0;
				for (i=0; i<_len; i++)
				{
					_title = _data[i].attributes.title;
					D.debug(D.lDev, "SeasonDetails - Adding" + _title + " to queue");
					key = _data[i].Media[0].Part[0].attributes.key;
					popAPI.queueVOD(_title, key);
				}
				D.debug(D.lDev, "SeasonDetails - Play from queue...");
				popAPI.playQueueVOD();
				
			break;
			case Remote.ENTER:
				D.debug(D.lDev, "SeasonDetails - ENTER Button Pressed...");
				var _data:Array = PlexData.oEpisodeData.MediaContainer[0].Video;
				var partKey:String = _data[PlexData.oEpisodeData.intPos].Media[0].Part[0].attributes.key;
				var key:String = _data[PlexData.oEpisodeData.intPos].attributes.title;
				var resume:Numberq = 0;
				
				D.debug(D.lDev, "SeasonDetails - Calling playVOD with: key => " + key);
				D.debug(D.lDev, "SeasonDetails - partKey => " + partKey);
				D.debug(D.lDev, "SeasonDetails - resume => " + resume);
				popAPI.playVOD(key, partKey, resume);

			break;
		}
	}
}