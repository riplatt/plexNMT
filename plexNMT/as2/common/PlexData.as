
import mx.xpath.XPathAPI;

import plexNMT.as2.common.Utils;

class plexNMT.as2.common.PlexData {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.PlexData;
	public static var oData:Object = {};
	public static var oBackground:Object = {};
	public static var oSettings:Object = {};
	public static var oWall:Object = {};
	public static var oPage:Object = {};
	public static var oLanguage:Object = {};
	public static var oSections:Object = {};
	public static var oCategories:Object = {};
	public static var oFilters:Object = {};
	public static var oWallData:Object = {};
	public static var oMovieData:Object = {};
	public static var oHeaders:Object = {};
	public static var oCurrentTime:Object = {};
	
	
	public static var iBob:Number = 0;
	//private static var soPlex:MobileSharedObject = null;
	
	
	private function PlexData()
	{
		//Don't do anything...
	}
	
	public static function init()
	{
		if(oSettings.init != true){
			trace("Building PlexData...");
			//SO
			//soPlex = new MobileSharedObject("");
			
			//Menus
			oData.level1 = {};
			oData.level1.items = new Array(); 								//sections - {key:1, title:"Movie1", url:"1"}, {key:2, title:"Move2", url:"2"}, etc...
			oData.level1.current = new Object({key:"", title:"", url:""});	//{key:1, title:"Movie1", url:"1"};
			oData.level1.age = null;										//Age - getTime();
			
			oData.level2 = {};
			oData.level2.items = new Array(); 								//fillter - {key:"all", title:"All Movies", url:"1/all"}, {key:"unwatched", title:"Unwatched", url:"1/unwatched"}, etc...
			oData.level2.current = new Object({key:"", title:"", url:""});	//{key:"genre", title:"By Genre", url:"1/genre"};
			oData.level2.age = null;										//Age - getTime();
			
			oData.level3 = {};
			oData.level3.items = new Array(); 								//fillter argument - {key:17, title:"Action", url:"1/genre/17"}, {key:19, title:"Action/Adventure", url:"1/genre/17"}, etc...
			oData.level3.current = new Object({key:"", title:"", url:""});	//{key:17, title:"Action", url:"1/genre/17"};
			oData.level3.age = null;										//Age - getTime();
			
			//Background
			/*oBackground.items = new Array();
			oBackground.current = new Array();
			oBackground.init = false;
			oBackground.index = 0;
			oBackground.speed = 7;											//Speed of background image change in seconds
			oBackground.highres = true;*/
			
			//Wall
			oWall.items = new Array();
			oWall.current = new Object();
			oWall.rows = 3;
			oWall.columns = 9;
			oWall.vgap = null;
			oWall.hgap = null;
			oWall.thumb = {};
			oWall.thumb.width = null;
			oWall.thumb.height = null;
			oWall.thumb.size = null;
			oWall.topLeft = {};
			oWall.topLeft.x = null;
			oWall.topLeft.y = null;
			
			setWall();
			
			//Settings
			oSettings.url = null;
			oSettings.ip = "192.168.1.3";
			oSettings.port = "32400";
			oSettings.curLevel = null;
			oSettings.init = true;
			oSettings.previous = null;
			oSettings.debugLevel = 0;
			oSettings.buffer = 0;
			oSettings.overscan = false;
			oSettings.overscanbg = false;
			oSettings.overscanxshift = 0;
			oSettings.overscanyshift = 0;
			oSettings.overscanx = 1;
			oSettings.overscany = 1;
			oSettings.language = "en";
			oSettings.backgroundKey = "/library/sections/2/recentlyAdded?X-Plex-Container-Start=0&X-Plex-Container-Size=50"
			
			//Language
			oLanguage = new Object();
			
			//Page
			oPage = new Object({current:"main", plexDataURL:""});
			//oPage.histroy = new Array();
			
			//ID
			/*
			* X-Plex-Platform (Platform name, eg iOS, MacOSX, Android, LG, etc)
			* X-Plex-Platform-Version (Operating system version, eg 4.3.1, 10.6.7, 3.2)
			* X-Plex-Provides (one or more of [player, controller, server])
			* X-Plex-Product (Plex application name, eg Laika, Plex Media Server, Media Link)
			* X-Plex-Version (Plex application version number)
			* X-Plex-Device (Device name and model number, eg iPhone3,2, Motorola XOOM™, LG5200TV)
			* X-Plex-Client-Identifier (UUID, serial number, or other number unique per device)
			* X-Plex-Client-Platform
			*/
			oHeaders.platform = "X-Plex-Platform=POP-408";
			oHeaders.platformVersion = "&X-Plex-Platform-Version=xxxx-xxxx";
			oHeaders.provides = "&X-Plex-Provides=Player";
			oHeaders.product = "&X-Plex-Product=plexNMT";
			oHeaders.version = "&X-Plex-Version=0.0.1.gitString";
			oHeaders.device = "&X-Plex-Device=";
			oHeaders.clientIdentifier = "&X-Plex-Client-Identifier=";
			oHeaders.clientPlatform = "&X-Plex-Client-Platform=";
			oHeaders.header = oHeaders.platform +
							  oHeaders.platformVersion +
							  oHeaders.provides +
							  oHeaders.product +
							  oHeaders.product +
							  oHeaders.version +
							  oHeaders.device +
							  oHeaders.clientIdentifier +
							  oHeaders.clientPlatform;
			
		} else {
			trace("PlexData already built...");
		}
		
	}
	
	public static function setSections()
	{
		var tmpObj1:Object = new Object({attributes:{title:"Settings"}});
		var tmpObj2:Object = new Object({attributes:{title:"Exit"}});
		oSections.MediaContainer[0].Directory.push(tmpObj1);
		oSections.MediaContainer[0].Directory.push(tmpObj2);
		oSections.MediaContainer[0].attributes.size = (oSections.MediaContainer[0].attributes.size*1) + 2
		oSections.intPos = 0;
		oSections.intLength = oSections.MediaContainer[0].attributes.size - 1;
		//Utils.varDump(oSections)
	}
	
	public static function setCategories()
	{
		oCategories.intPos = 0;
		oCategories.intLength = oCategories.MediaContainer[0].attributes.size - 1;
	}
	
	public static function setFilters()
	{
		oFilters.intPos = 0;
		oFilters.intLength = oFilters.MediaContainer[0].attributes.size - 1;
	}
	
	public static function setBackground()
	{
		oBackground.intPos = 0;
		oBackground.intLength = oBackground.MediaContainer[0].attributes.size - 1;
		trace("PlexData - oBackground.intLength: " + oBackground.intLength);
	}
	
	public static function setWallData()
	{
		oWallData.intPos = 0;
		oWallData.intLength = oWallData.MediaContainer[0].attributes.size - 1;
	}
	
	public static function GetRotation(_objItem:String, menuRotation:Number):Number
	{
		var intPos:Number = PlexData[_objItem].intPos;
		var len:Number = PlexData[_objItem].MediaContainer[0].attributes.size - 1
		var rot:Number = Math.abs(menuRotation);
		var ve:Boolean = false;
		
		if (menuRotation < 0)
		{
			ve = true;
		}
		for(var i=0;i<rot;i++)
		{
			if(ve)
			{
				intPos--;
				if (intPos < 0)
				{
					intPos = len;
				}
			}else{
				intPos++;
				if (intPos > len)
				{
					intPos = 0;
				}
			}
		}
		//trace("PlexData - GetRotation Returning: " + intPos + " From a Rotation of: " + menuRotation);
		return intPos;
	}
	public static function _addItem(_level:String, _item:Object):Void
	{
		oData[_level].items.push(_item)
	}
	
	public static function clearItem(_level:String):Void
	{
		oData[_level].items = new Array()
	}
	
	public static function rotateItemsLeft(_level:String):Void
	{
		oData[_level].items.push(oData[_level].items.shift()); 
	}
	
	public static function rotateItemsRight(_level:String):Void
	{
		oData[_level].items.unshift(oData[_level].items.pop());
	}
	
	public static function setCurrent(_level:String, _item:Object):Void
	{
		oData[_level].current = _item
	}
	
	public static function setURL(_url:String):Void
	{
		oSettings.url = _url
	}
	
	public static function setWall():Void
	{
		//Set defulats if not set
		oWall.rows = (oWall.rows == null) ? 2 : oWall.rows;
		oWall.rows = (oWall.rows == 0) ? 1 : oWall.rows;
		
		oWall.columns = (oWall.columns == null) ? 7 : oWall.columns;
		oWall.columns = (oWall.columns == 0) ? 1 : oWall.columns;
		
		var wallWidth = 1120;
		var wallHeight = 425;
		
		var thumbWidth = wallWidth / oWall.columns;
		var thumbHeight = wallHeight / oWall.rows;
		
		//Check for Music or Video
		var type:String = oWallData.MediaContainer[0].attributes.viewGroup;
		switch (type)
			{
				case "artist":
				case "album":
					//Music
					if (thumbWidth < thumbHeight)
					{
						oWall.thumb.width = thumbWidth;
						oWall.thumb.height = thumbWidth;
						oWall.vgap = oWall.hgap = 0.078740157*thumbWidth;
					} else {
						oWall.thumb.height = thumbHeight;
						oWall.thumb.width = thumbHeight;
						oWall.vgap = oWall.hgap = 0.054347826*thumbWidth;
					}
				break;
				default :
					//Video
					if (thumbWidth*1.49 < thumbHeight)
					{
						oWall.thumb.width = 0.921259843*thumbWidth;
						oWall.thumb.height = oWall.thumb.width*1.49;
						oWall.vgap = oWall.hgap = 0.078740157*thumbWidth;
					} else {
						oWall.thumb.height = 0.945652174*thumbHeight;
						oWall.thumb.width = 0.672*thumbHeight;
						oWall.vgap = oWall.hgap = 0.054347826*thumbWidth;
					}
				break;
			}
		
		oWall.thumb.size = Math.ceil(oWall.thumb.height);
		
		//center grid
		var gridWidth = (oWall.thumb.width * oWall.columns) + (oWall.hgap * (oWall.columns - 1));
		var gridHeight = (oWall.thumb.height * oWall.rows) + (oWall.vgap * (oWall.rows - 1));
		
		
		oWall.topLeft.x = 1280/2 - gridWidth/2;
		oWall.topLeft.y = 720/2 - gridHeight/2;
		
	}
	
	public static function setLanguage():Void {
		var xml:XML = new XML();
		xml.ignoreWhite = true;
		
		xml.onLoad = function(success:Boolean):Void {
			
			//Clean XML Call
			delete xml.idMap;
			xml = null;
		}
		xml.load("./lang" + oSettings.language);
	}
}