
//import com.adobe.as2.MobileSharedObject;
import mx.xpath.XPathAPI;

class plexNMT.as2.common.PlexData {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.PlexData;
	public static var oData:Object = {};
	public static var oBackground:Object = {};
	public static var oSettings:Object = {};
	public static var oWall:Object = {};
	public static var oPage:Object = {};
	
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
			
		} else {
			trace("PlexData already built...");
		}
		
		//trace("Dumping PlexData...");
		//var_dump(oData);
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
	
	/*public static function readSO():Void
	{
		trace("PlexData Reading SO...");
		oSettings.ip = soPlex.readFromSO("plexIP");
		oSettings.port = soPlex.readFromSO("plexPort");
		oSettings.url = (soPlex.readFromSO("plexIP") == undefined ? oSettings.url : "http://"+oSettings.ip+":"+oSettings.port+"/");
		oWall.columns = (soPlex.readFromSO("wallCol") == undefined ? oWall.columns : soPlex.readFromSO("wallCol"));
		oWall.rows = (soPlex.readFromSO("wallRow") == undefined ? oWall.rows : soPlex.readFromSO("wallRow"));
	}
	
	public static function writeSO():Void
	{
		trace("PlexData Writing SO...");
		soPlex.writeToSO("plexIP", oSettings.ip);
		soPlex.writeToSO("plexPort", oSettings.port);
		soPlex.writeToSO("wallCol", oSettings.wallCol);
		soPlex.writeToSO("wallRow", oSettings.wallRow);
	}*/
	
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
		xml,load("./lang" + oSettings.language);
	}
	
	
	private static function var_dump(_obj:Object) {
		
		for (var i in _obj) {
			trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof (_obj[i]) == "object" || typeof (_obj[i]) == "movieclip") {
				var_dump(_obj[i]);
			}
			trace("end: " + i);
		}
	}
}