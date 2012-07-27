
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
	public static var oCategory:Object = {};
	public static var oID:Object = {}
	
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
			oBackground.items = new Array();
			oBackground.current = new Array();
			oBackground.init = false;
			oBackground.index = 0;
			oBackground.speed = 7;											//Speed of background image change in seconds
			oBackground.highres = true;
			
			//Wall
			oWall.items = new Array();
			oWall.current = new Object();
			oWall.rows = null;
			oWall.columns = null;
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
			oSettings.ip = null;
			oSettings.port = null;
			oSettings.curLevel = null;
			oSettings.init = true;
			oSettings.previous = null;
			oSettings.debugLevel = 0;
			oSettings.overscan = false;
			oSettings.overscanbg = false;
			oSettings.overscanxshift = 0;
			oSettings.overscanyshift = 0;
			oSettings.overscanx = 1;
			oSettings.overscany = 1;
			oSettings.language = "en";
			
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
			oID.version = "0.0.1.gitString";
			oID.uuid = "uuid";
			oID.os = "syabas";
			oHeaders.platform = "X-Plex-Platform=POP-408";
			oHeaders.platformVersion = "&X-Plex-Platform-Version=xxxx-xxxx";
			oHeaders.provides = "&X-Plex-Provides=Player";
			oHeaders.product = "&X-Plex-Product=plexNMT";
			oHeaders.version = "&X-Plex-Version=0.0.1.gitString";
			oHeaders.device = "&X-Plex-Device=";
			oHeaders.clientIdentifier = "&X-Plex-Client-Identifier=";
			oHeaders.clientPlatform = "&X-Plex-Client-Platform=";
			oHeaders.header = 
			
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
		Utils.varDump(oSections)
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
		oWall.rows = (oWall.rows == null) ? 3 : oWall.rows;
		oWall.rows = (oWall.rows == 0) ? 1 : oWall.rows;
		
		oWall.columns = (oWall.columns == null) ? 9 : oWall.columns;
		oWall.columns = (oWall.columns == 0) ? 1 : oWall.columns;
		
		var wallWidth = 1120;
		var wallHeight = 500;
		
		var thumbWidth = wallWidth / oWall.columns;
		var thumbHeight = wallHeight/ oWall.rows;
		
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