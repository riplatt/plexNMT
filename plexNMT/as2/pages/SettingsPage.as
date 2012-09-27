import mx.utils.Delegate;

import com.syabas.as2.common.D;
import com.syabas.as2.common.VKMain;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.JSONUtil;

import com.designvox.tranniec.JSON;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;

import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.popSharedObjects;

class plexNMT.as2.pages.SettingsPage {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.SettingsPage;
	
	// Public Properties:
	// Private Properties:
	private var _settings:MovieClip = null
	//key Listener
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	//TAB Control
	private var objNav:Object = new Object();
	private var arrMenu:Array = new Array();
	private var arrPlex:Array = new Array(new Array());
	private var arrWall:Array = new Array(new Array());
	private var arrNMT:Array = new Array(new Array());
	private var navX:Number = 0;
	private var navY:Number = 0;
	private var navMenu:Boolean = true;
	//Key Board
	private var vkMC:MovieClip = null;
	private var vkMain:VKMain = null;
	private var kbData:Object = null;
	private var kbData2:Object = null;
	private var fn:Object = null;
	//Text fields
	private var txtIP:TextField = null;
	private var txtPort:TextField = null;
	private var txtHTTPTimeout:TextField = null;
	private var txtWallMovRow:TextField = null;
	private var txtWallMovCol:TextField = null;
	private var txtWallShoRow:TextField = null;
	private var txtWallShoCol:TextField = null;
	private var txtWallMusRow:TextField = null;
	private var txtWallMusCol:TextField = null;
	private var txtBuffer:TextField = null;
	private var txtDebugLvl:TextField = null;
	private var txtDebugRmt:TextField = null;

	// Initialization:
	public function SettingsPage(parentMC:MovieClip) 
	{
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		//Key Listener
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		this.enableKeyListener();
		
		_settings = parentMC.createEmptyMovieClip("_settings", parentMC.getNextHighestDepth());
		build(_settings);
		showData();
		
		this.vkMC = _settings.createEmptyMovieClip("vkMC", 999);

		fn = {
			onKeyDown : Delegate.create(this, this.keyDownCB),
			onDoneCB : Delegate.create(this, this.onDoneCB)
		};
		
		Util.loadURL("json/vk3_data.json", Delegate.create(this, this.loadAlphanum));
	}

	// Public Methods:
	public function destroy():Void
	{
		//Keyboard
		vkMC.removeMovieClip();
		delete vkMC;
		fn = null;
		//
		_settings.removeMovieClip();
		delete _settings;
		
		//Remove Listener
		this.disableKeyListener();
		Key.removeListener(this.keyListener);
		delete keyListener;
		
	}
	// Private Methods:
	private function loadAlphanum(success:Boolean, data:String, o:Object):Void
	{
		this.kbData = JSONUtil.parseJSON(data).keyboard_data;

		Util.loadURL("json/vk3_data_alphanum.json", Delegate.create(this, this.onloadAlphanum));
	}

	private function onloadAlphanum(success:Boolean, data:String, o:Object):Void
	{
		this.kbData2 = JSONUtil.parseJSON(data).keyboard_data;
	}
	
	private function showData()
	{
		txtIP.text = PlexData.oSettings.ip;
		txtPort.text = PlexData.oSettings.port;
		txtHTTPTimeout.text = PlexData.oSettings.timeout;
		//Wall
		txtWallMovRow.text = PlexData.oSettings.wall.movies.rows;
		txtWallMovCol.text = PlexData.oSettings.wall.movies.columns;
		txtWallShoRow.text = PlexData.oSettings.wall.shows.rows;
		txtWallShoCol.text = PlexData.oSettings.wall.shows.columns;
		txtWallMusRow.text = PlexData.oSettings.wall.music.rows;
		txtWallMusCol.text = PlexData.oSettings.wall.music.columns;
		//plexNMT
		txtBuffer.text = PlexData.oSettings.buffer;
		txtDebugLvl.text = PlexData.oSettings.debug.level;
		txtDebugRmt.text = PlexData.oSettings.debug.remote;
		//Debug
		D.level = PlexData.oSettings.debug.level;
		D.debug(D.lDebug,"Settings - Debug level on...");
		D.debug(D.lInfo,"Settings - Info level on...");
		D.debug(D.lError,"Settings - Error level on...");
		if(PlexData.oSettings.debug.level == 0){
			D.debug(D.lInfo,"Settings - Logging off...");
			D.mc._visible = false;
			D.destroy();
		} else {
			if (D.loaded != true)
			{
				D.init({mc:{level:100, showHideKC:16777250, upKC:Key.UP, downKC:40
					, mcProps:{_x:725, _y:50, _width:500, _height:600}}, remote:{ip:PlexData.oSettings.debug.remote}
				});
				
			}
		}
	}
	
	private function updateData()
	{
		//Plex Media Server
		PlexData.oSettings.ip = txtIP.text;
		PlexData.oSettings.port = txtPort.text;
		PlexData.oSettings.timeout = txtHTTPTimeout.text;
		PlexData.oSettings.url = "http://"+PlexData.oSettings.ip+":"+PlexData.oSettings.port
		//Wall
		PlexData.oSettings.wall.movies.rows = txtWallMovRow.text;
		PlexData.oSettings.wall.movies.columns = txtWallMovCol.text;
		PlexData.oSettings.wall.shows.rows = txtWallShoRow.text;
		PlexData.oSettings.wall.shows.columns = txtWallShoCol.text;
		PlexData.oSettings.wall.music.rows = txtWallMusRow.text;
		PlexData.oSettings.wall.music.columns = txtWallMusCol.text;
		//plexNMT
		PlexData.oSettings.buffer = txtBuffer.text;
		PlexData.oSettings.debug.level = int(txtDebugLvl.text);
		PlexData.oSettings.debug.remote = txtDebugRmt.text;
		//Debug
		D.level = PlexData.oSettings.debug.level;
		D.debug(D.lDebug,"Settings - Debug level on...");
		D.debug(D.lInfo,"Settings - Info level on...");
		D.debug(D.lError,"Settings - Error level on...");
		if(PlexData.oSettings.debug.level == 0){
			D.debug(D.lInfo,"Settings - Logging off...");
			D.mc._visible = false;
			D.destroy();
		} else {
			if (D.loaded != true)
			{
				D.init({mc:{level:100, showHideKC:16777250, upKC:Key.UP, downKC:40
					, mcProps:{_x:725, _y:50, _width:500, _height:600}}, remote:{ip:PlexData.oSettings.debug.remote}
				});
				
			}
		}

	}
	
	private function hlMenu()
	{
		var len:Number = arrMenu.length;
		for (var i:Number = 0; i<len; i++) {
			arrMenu[i].textColor = 0xFFFFFF;
			TweenLite.to(_settings["_"+arrMenu[i].text.toLowerCase()], 0, {autoAlpha:0});
		}
		arrMenu[0].textColor = 0xFFFF00;
		TweenLite.to(_settings["_"+arrMenu[0].text.toLowerCase()], 0, {autoAlpha:100});
	}
	
	private function dimMenu()
	{
		arrMenu[0].textColor = 0x999900;
	}
	
	private function hlSettings()
	{
		this.unHlSettings();
		trace("Setting - Hilighting:" + objNav[arrMenu[0].text][navY][navX]);
		objNav[arrMenu[0].text][navY][navX].backgroundColor = 0xFFFFFF;
		objNav[arrMenu[0].text][navY][navX].textColor = 0x000000;
	}
	
	private function unHlSettings()
	{
		var lenX:Number = objNav[arrMenu[0].text][0].length;
		var lenY:Number = objNav[arrMenu[0].text].length;
		trace("lenX:"+lenX+", lenY:"+lenY);
		trace("navX:"+navX+", navY:"+navY);
		var i:Number = 0;
		var j:Number = 0;
		for(i = 0; i<lenX; i++){
			for(j = 0; j<lenY; j++){
				trace("Setting - Dimming:" + objNav[arrMenu[0].text][j][i]);
				objNav[arrMenu[0].text][j][i].backgroundColor = 0x6E7B8B;
				objNav[arrMenu[0].text][j][i].textColor = 0xFFFFFF;
			}
		}
	}
	
	private function build(mc:MovieClip)
	{
		//Text Format
		var myFormat:TextFormat = new TextFormat();
		myFormat.align = "center";
		myFormat.font = "Arial";
		myFormat.color = 0xFFFFFF;
		myFormat.size = 18;
		//Menu MoveClip
		mc.createEmptyMovieClip("_nav", mc.getNextHighestDepth());
		//Plex Menu Item 
		mc._nav.createTextField("txt_0", mc._nav.getNextHighestDepth(), 30, 30, 150, 30);
		mc._nav.txt_0.autoSize = true;
		mc._nav.txt_0.setNewTextFormat(myFormat);
		mc._nav.txt_0.text = "Plex";
		//Wall Menu Item
		mc._nav.createTextField("txt_1", mc._nav.getNextHighestDepth(), 30, 60, 150, 30);
		mc._nav.txt_1.autoSize = true;
		mc._nav.txt_1.setNewTextFormat(myFormat);
		mc._nav.txt_1.text = "Wall";
		//plexNMT Menu Item
		mc._nav.createTextField("txt_2", mc._nav.getNextHighestDepth(), 30, 90, 150, 30);
		mc._nav.txt_2.autoSize = true;
		mc._nav.txt_2.setNewTextFormat(myFormat);
		mc._nav.txt_2.text = "plexNMT";
		
		var offColor:Number = 0x6E7B8B;
		//Plex Pane
		//Plex Settings
		mc.createEmptyMovieClip("_plex", mc.getNextHighestDepth());
		mc._plex._alpha = 0;
		mc._plex._visible = false;
		//IP
		//lable
		mc._plex.createTextField("lab_0", mc._plex.getNextHighestDepth(), 69, 30, 150, 26);
		mc._plex.lab_0.autoSize = true;
		mc._plex.lab_0.setNewTextFormat(myFormat);
		mc._plex.lab_0.text = "IP Address:";
		//Input
		txtIP = mc._plex.createTextField("txt_0", mc._plex.getNextHighestDepth(), 162, 30, 150, 26);
		//mc._plex.txt_0.autoSize = true;
		mc._plex.txt_0.setNewTextFormat(myFormat);
		mc._plex.txt_0.border = true;
		mc._plex.txt_0.background = true;
		mc._plex.txt_0.backgroundColor = offColor;
		mc._plex.txt_0.maxChars = 16
		mc._plex.txt_0.text = "555.555.555.555";
		mc._plex.txt_0.kbLable = "Enter IP Address of the PMS:";
		//Port
		//lable
		mc._plex.createTextField("lab_1", mc._plex.getNextHighestDepth(), 122, 60, 150, 26);
		mc._plex.lab_1.autoSize = true;
		mc._plex.lab_1.setNewTextFormat(myFormat);
		mc._plex.lab_1.text = "Port:";
		//Input
		txtPort = mc._plex.createTextField("txt_1", mc._plex.getNextHighestDepth(), 162, 60, 150, 26);
		//mc._plex.txt_1.autoSize = true;
		mc._plex.txt_1.setNewTextFormat(myFormat);
		mc._plex.txt_1.border = true;
		mc._plex.txt_1.background = true;
		mc._plex.txt_1.backgroundColor = offColor;
		mc._plex.txt_1.maxChars = 16
		mc._plex.txt_1.text = "Port";
		mc._plex.txt_1.kbLable = "Enter the Port of the PMS:";
		//Timeout
		//lable
		mc._plex.createTextField("lab_2", mc._plex.getNextHighestDepth(), 0, 90, 150, 26);
		mc._plex.lab_2.autoSize = true;
		mc._plex.lab_2.setNewTextFormat(myFormat);
		mc._plex.lab_2.text = "HTTP Timeout(ms):";
		//Input
		txtHTTPTimeout = mc._plex.createTextField("txt_2", mc._plex.getNextHighestDepth(), 162, 90, 150, 26);
		//mc._plex.txt_2.autoSize = true;
		mc._plex.txt_2.setNewTextFormat(myFormat);
		mc._plex.txt_2.border = true;
		mc._plex.txt_2.background = true;
		mc._plex.txt_2.backgroundColor = offColor;
		mc._plex.txt_2.maxChars = 16
		mc._plex.txt_2.text = "HTTP Timeout";
		mc._plex.txt_2.kbLable = "Enter The http Timeout in milliseconds:";
		
		//Wall Pane
		//Wall Settings
		mc.createEmptyMovieClip("_wall", mc.getNextHighestDepth());
		mc._wall._alpha = 0;
		mc._wall._visible = false;
		//Movies Lable
		//Lable
		mc._wall.createTextField("lab_00", mc._wall.getNextHighestDepth(), 0, 30, 150, 26);
		mc._wall.lab_00.autoSize = true;
		mc._wall.lab_00.setNewTextFormat(myFormat);
		mc._wall.lab_00.text = "Movies:";
		//Movies Wall Number of Rows
		//Lable
		mc._wall.createTextField("lab_0", mc._wall.getNextHighestDepth(), 74, 60, 150, 26);
		mc._wall.lab_0.autoSize = true;
		mc._wall.lab_0.setNewTextFormat(myFormat);
		mc._wall.lab_0.text = "Rows:";
		//Input
		txtWallMovRow = mc._wall.createTextField("txt_0", mc._wall.getNextHighestDepth(), 128, 60, 150, 26);
		mc._wall.txt_0.setNewTextFormat(myFormat);
		mc._wall.txt_0.border = true;
		mc._wall.txt_0.background = true;
		mc._wall.txt_0.backgroundColor = offColor;
		mc._wall.txt_0.maxChars = 3
		mc._wall.txt_0.text = "#Rows";
		mc._wall.txt_0.kbLable = "Enter the Number of Rows for the Movie Wall:";
		//Movies Wall Number of Columns
		//Lable
		mc._wall.createTextField("lab_1", mc._wall.getNextHighestDepth(), 290, 60, 150, 26);
		mc._wall.lab_1.autoSize = true;
		mc._wall.lab_1.setNewTextFormat(myFormat);
		mc._wall.lab_1.text = "Columns:";
		//Input
		txtWallMovCol = mc._wall.createTextField("txt_1", mc._wall.getNextHighestDepth(), 369, 60, 150, 26);
		mc._wall.txt_1.setNewTextFormat(myFormat);
		mc._wall.txt_1.border = true;
		mc._wall.txt_1.background = true;
		mc._wall.txt_1.backgroundColor = offColor;
		mc._wall.txt_1.maxChars = 3
		mc._wall.txt_1.text = "#Columns";
		mc._wall.txt_1.kbLable = "Enter the Number of Colums for the Movie Wall:";
		
		//Shows Lable
		//Lable
		mc._wall.createTextField("lab_20", mc._wall.getNextHighestDepth(), 0, 90, 150, 26);
		mc._wall.lab_20.autoSize = true;
		mc._wall.lab_20.setNewTextFormat(myFormat);
		mc._wall.lab_20.text = "Shows:";
		//Shows Wall Number of Rows
		//Lable
		mc._wall.createTextField("lab_2", mc._wall.getNextHighestDepth(), 74, 120, 150, 26);
		mc._wall.lab_2.autoSize = true;
		mc._wall.lab_2.setNewTextFormat(myFormat);
		mc._wall.lab_2.text = "Rows:";
		//Input
		txtWallShoRow = mc._wall.createTextField("txt_2", mc._wall.getNextHighestDepth(), 128, 120, 150, 26);
		mc._wall.txt_2.setNewTextFormat(myFormat);
		mc._wall.txt_2.border = true;
		mc._wall.txt_2.background = true;
		mc._wall.txt_2.backgroundColor = offColor;
		mc._wall.txt_2.maxChars = 3
		mc._wall.txt_2.text = "#Rows";
		mc._wall.txt_2.kbLable = "Enter the Number of Rows for the Shows Wall:";
		//Shows Wall Number of Columns
		//Lable
		mc._wall.createTextField("lab_3", mc._wall.getNextHighestDepth(), 290, 120, 150, 26);
		mc._wall.lab_3.autoSize = true;
		mc._wall.lab_3.setNewTextFormat(myFormat);
		mc._wall.lab_3.text = "Columns:";
		//Input
		txtWallShoCol = mc._wall.createTextField("txt_3", mc._wall.getNextHighestDepth(), 369, 120, 150, 26);
		mc._wall.txt_3.setNewTextFormat(myFormat);
		mc._wall.txt_3.border = true;
		mc._wall.txt_3.background = true;
		mc._wall.txt_3.backgroundColor = offColor;
		mc._wall.txt_3.maxChars = 3
		mc._wall.txt_3.text = "#Columns";
		mc._wall.txt_3.kbLable = "Enter the Number of Colums for the Shows Wall:";
		
		//Music Lable
		//Lable
		mc._wall.createTextField("lab_40", mc._wall.getNextHighestDepth(), 0, 150, 150, 26);
		mc._wall.lab_40.autoSize = true;
		mc._wall.lab_40.setNewTextFormat(myFormat);
		mc._wall.lab_40.text = "Music:";
		//Music Wall Number of Rows
		//Lable
		mc._wall.createTextField("lab_4", mc._wall.getNextHighestDepth(), 74, 180, 150, 26);
		mc._wall.lab_4.autoSize = true;
		mc._wall.lab_4.setNewTextFormat(myFormat);
		mc._wall.lab_4.text = "Rows:";
		//Input
		txtWallMusRow = mc._wall.createTextField("txt_4", mc._wall.getNextHighestDepth(), 128, 180, 150, 26);
		mc._wall.txt_4.setNewTextFormat(myFormat);
		mc._wall.txt_4.border = true;
		mc._wall.txt_4.background = true;
		mc._wall.txt_4.backgroundColor = offColor;
		mc._wall.txt_4.maxChars = 3
		mc._wall.txt_4.text = "#Rows";
		mc._wall.txt_4.kbLable = "Enter the Number of Rows for the Music Wall:";
		//Music Wall Number of Columns
		//Lable
		mc._wall.createTextField("lab_5", mc._wall.getNextHighestDepth(), 290, 180, 150, 26);
		mc._wall.lab_5.autoSize = true;
		mc._wall.lab_5.setNewTextFormat(myFormat);
		mc._wall.lab_5.text = "Columns:";
		//Input
		txtWallMusCol = mc._wall.createTextField("txt_5", mc._wall.getNextHighestDepth(), 369, 180, 150, 26);
		mc._wall.txt_5.setNewTextFormat(myFormat);
		mc._wall.txt_5.border = true;
		mc._wall.txt_5.background = true;
		mc._wall.txt_5.backgroundColor = offColor;
		mc._wall.txt_5.maxChars = 3
		mc._wall.txt_5.text = "#Columns";
		mc._wall.txt_5.kbLable = "Enter the Number of Columns for the Music Wall:";
		
		//PlexNMT Pane
		//NMT Settings
		mc.createEmptyMovieClip("_plexnmt", mc.getNextHighestDepth());
		mc._plexnmt._alpha = 0;
		mc._plexnmt._visible = false;
		//Video Buffer
		//Lable
		mc._plexnmt.createTextField("lab_0", mc._plexnmt.getNextHighestDepth(), 32, 30, 150, 26);
		mc._plexnmt.lab_0.autoSize = true;
		mc._plexnmt.lab_0.setNewTextFormat(myFormat);
		mc._plexnmt.lab_0.text = "Play Buffer:";
		//Input
		txtBuffer = mc._plexnmt.createTextField("txt_0", mc._plexnmt.getNextHighestDepth(), 128, 30, 150, 26);
		mc._plexnmt.txt_0.setNewTextFormat(myFormat);
		mc._plexnmt.txt_0.border = true;
		mc._plexnmt.txt_0.background = true;
		mc._plexnmt.txt_0.backgroundColor = offColor;
		mc._plexnmt.txt_0.maxChars = 6
		mc._plexnmt.txt_0.text = "Buffer";
		mc._plexnmt.txt_0.kbLable = "Enter the Video Stream Buffer in milliseconds:";
		//Debug Level
		//Lable
		mc._plexnmt.createTextField("lab_1", mc._plexnmt.getNextHighestDepth(), 20, 60, 150, 26);
		mc._plexnmt.lab_1.autoSize = true;
		mc._plexnmt.lab_1.setNewTextFormat(myFormat);
		mc._plexnmt.lab_1.text = "Debug Level:";
		//Input
		txtDebugLvl = mc._plexnmt.createTextField("txt_1", mc._plexnmt.getNextHighestDepth(), 128, 60, 150, 26);
		mc._plexnmt.txt_1.setNewTextFormat(myFormat);
		mc._plexnmt.txt_1.border = true;
		mc._plexnmt.txt_1.background = true;
		mc._plexnmt.txt_1.backgroundColor = offColor;
		mc._plexnmt.txt_1.maxChars = 6
		mc._plexnmt.txt_1.text = "Debug Level";
		mc._plexnmt.txt_1.kbLable = "Enter Debug Level (0-4), 0 to Turn Off:";
		//Debug Remote
		//Lable
		mc._plexnmt.createTextField("lab_2", mc._plexnmt.getNextHighestDepth(), 0, 90, 150, 26);
		mc._plexnmt.lab_2.autoSize = true;
		mc._plexnmt.lab_2.setNewTextFormat(myFormat);
		mc._plexnmt.lab_2.text = "Debug Remote:";
		//Input
		txtDebugRmt = mc._plexnmt.createTextField("txt_2", mc._plexnmt.getNextHighestDepth(), 128, 90, 150, 26);
		mc._plexnmt.txt_2.setNewTextFormat(myFormat);
		mc._plexnmt.txt_2.border = true;
		mc._plexnmt.txt_2.background = true;
		mc._plexnmt.txt_2.backgroundColor = offColor;
		mc._plexnmt.txt_2.maxChars = 16
		mc._plexnmt.txt_2.text = "Debug Remote";
		mc._plexnmt.txt_2.kbLable = "Enter IP of Debug Remote Server:";
		
		//Positioning
		mc._nav._x = 100;
		mc._nav._y = 100
		mc._plex._x = 300;
		mc._plex._y = 100;
		mc._wall._x = 300;
		mc._wall._y = 100;
		mc._plexnmt._x = 300;
		mc._plexnmt._y = 100;
		//trace(Utils.varDump(mc));
		//Navigation Array
		//[y][x]
		var i:Number = 0;
		var x:Number = 0;
		var y:Number = 0;
		//Plex Array
		for(y=0; y<3; y++){
			arrPlex[y] = new Array();
			for(x=0; x<1; x++){
				arrPlex[y][x] = mc._plex["txt_"+i];
				trace("arrPlex["+y+"]["+x+"]:"+arrPlex[y][x]+" || mc._plex[\"txt_"+i+"\"]:"+mc._plex["txt_"+i]);
				i++;
			}
		}
		//Wall Array
		i = 0;
		for(y=0; y<3; y++){
			arrWall[y] = new Array();
			for(x=0; x<2; x++){
				arrWall[y][x] = mc._wall["txt_"+i];
				trace("arrWall["+y+"]["+x+"]:"+arrWall[y][x]+" || mc._wall[\"txt_"+i+"\"]:"+mc._wall["txt_"+i]);
				i++;
			}
		}
		//plexNMT Array
		i = 0;
		for(y=0; y<3; y++){
			arrNMT[y] = new Array();
			for(x=0; x<1; x++){
				arrNMT[y][x] = mc._plexnmt["txt_"+i];
				trace("arrNMT["+y+"]["+x+"]:"+arrNMT[y][x]+" || mc._wall[\"txt_"+i+"\"]:"+mc._plexnmt["txt_"+i]);
				i++;
			}
		}
		
		//Navigation Menu Array;
		arrMenu = [mc._nav.txt_0, mc._nav.txt_1, mc._nav.txt_2];
		objNav = {Plex:arrPlex, Wall:arrWall, plexNMT:arrNMT};
		/*trace(Utils.varDump(arrMenu));
		trace(JSON.stringify(arrMenu));
		Utils.traceVar(arrMenu);*/
		
		hlMenu();
		
	}
	
	private function enableKeyListener():Void
	{
		D.debug(D.lDev, "Setting Page - Doing enableKeyListener...");
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
		D.debug(D.lDev, "Setting Page - keyDownCB.keyCode: " + keyCode);
		
		switch (keyCode)
		{
			case Remote.BACK:
			case Remote.HOME:
			case "soft1":
			case 81:
				this.updateData();
				popSharedObjects.savePlexData();
				this.destroy();
				gotoAndPlay("main");
			break;
			case Remote.YELLOW:
				this.destroy();
				gotoAndPlay("settings");
			break;
			case Key.ENTER:
				if (!navMenu) {
					this.startInput();
				}
			break;
			case Key.UP:
				if (navMenu) {
					this.arrMenu.unshift(this.arrMenu.pop());				
					hlMenu();
				} else {
					navY--;
					if (navY < 0){
						trace("navY < 0...");
						navY = 0;
					} else {
						hlSettings();
					}
				}
			break;
			case Key.DOWN:
				if (navMenu) {
					this.arrMenu.push(this.arrMenu.shift());
					hlMenu();
				} else {
					navY++;
					var lenY:Number = objNav[arrMenu[0].text].length;
					if(navY > lenY-1){navY = lenY-1}
					hlSettings();
				}
			break;
			case Key.RIGHT:
				if (navMenu) {
					navMenu = false
					navX = 0;
					navY = 0;
					dimMenu();
					hlSettings();
				} else {
					navX++;
					var lenX:Number = objNav[arrMenu[0].text][0].length;
					if(navX > lenX-1){navX = lenX-1}
					hlSettings();
				}
			break;
			case Key.LEFT:
				if (!navMenu) {
					navX--;
					if (navX < 0){
						trace("navX < 0...");
						navX = 0;
						navMenu = true;
						hlMenu();
						unHlSettings();
					} else {
						hlSettings();
					}
				}			
			break;
		}
	}
	
	private function startInput():Void
	{
		var vkObj:Object = new Object();
		vkObj.onDoneCB = this.fn.onDoneCB;
		vkObj.onCancelCB = this.fn.onDoneCB;
		vkObj.onSuggUpdateCB = null 						
		vkObj.keyboard_data = this.kbData;
		vkObj.initValue = this.objNav[arrMenu[0].text][navY][navX].text;
		vkObj.parentPath = this._settings._url;
		vkObj.title = objNav[arrMenu[0].text][navY][navX].kbLable;
		vkObj.showPassword = false //(this.index == 1);
		vkObj.disableSpace = false //(this.index == 3);

		if (this.vkMain == null)
		{
			this.vkMain = new VKMain();
			this.vkMain.startVK(this.vkMC, vkObj);
		}
		else
		{
			this.vkMain.restartVK(vkObj);
		}

		this.disableKeyListener();
	}

	private function onDoneCB(s:String):Void
	{
		this.objNav[arrMenu[0].text][navY][navX].text = s;
		this.updateData();
		this.vkMain.hideVK();
		this.enableKeyListener();
	}

	private function onCancelCB(s:String):Void
	{
		this.vkMain.hideVK();
		this.enableKeyListener();
	}
}
