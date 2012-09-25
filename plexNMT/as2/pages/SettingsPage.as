import mx.utils.Delegate;

import com.syabas.as2.common.D;
import com.syabas.as2.common.VKMain;

import com.designvox.tranniec.JSON;

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
	private var arrMenu:Array = new Array();
	private var arrPlex:Array = new Array(new Array());
	private var arrWall:Array = new Array(new Array());
	private var arrNMT:Array = new Array(new Array());
	private var navX:Number = 0;
	private var navY:Number = 0;
	private var navZ:Number = 0;
	//Key Board
	private var vkMC:MovieClip = null;
	private var vkMain:VKMain = null;
	private var kbData:Object = null;
	private var kbData2:Object = null;
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

	// Initialization:
	public function SettingsPage(parentMC:MovieClip) 
	{
		_settings = parentMC.createEmptyMovieClip("plex", parentMC.getNextHighestDepth());
		build(_settings);
		showData();
	}

	// Public Methods:
	public function destroy():Void
	{
		_settings.removeMovieClip();
		delete _settings;
		
	}
	// Private Methods:
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
	}
	
	private function saveData()
	{
		//Plex Media Server
		PlexData.oSettings.ip = txtIP.text;
		PlexData.oSettings.port = txtPort.text;
		PlexData.oSettings.timeout = txtHTTPTimeout.text;
		//Wall
		PlexData.oSettings.wall.movies.rows = txtWallMovRow.text;
		PlexData.oSettings.wall.movies.columns = txtWallMovCol.text;
		PlexData.oSettings.wall.shows.rows = txtWallShoRow.text;
		PlexData.oSettings.wall.shows.columns = txtWallShoCol.text;
		PlexData.oSettings.wall.music.rows = txtWallMusRow.text;
		PlexData.oSettings.wall.music.columns = txtWallMusCol.text;
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
		mc._plex.createTextField("lab_0", mc._plex.getNextHighestDepth(), 33, 30, 150, 26);
		mc._plex.lab_0.autoSize = true;
		mc._plex.lab_0.setNewTextFormat(myFormat);
		mc._plex.lab_0.text = "IP Address:";
		//Input
		txtIP = mc._plex.createTextField("txt_0", mc._plex.getNextHighestDepth(), 128, 30, 150, 26);
		//mc._plex.txt_0.autoSize = true;
		mc._plex.txt_0.setNewTextFormat(myFormat);
		mc._plex.txt_0.border = true;
		mc._plex.txt_0.background = true;
		mc._plex.txt_0.backgroundColor = offColor;
		mc._plex.txt_0.maxChars = 16
		mc._plex.txt_0.type = "input";
		mc._plex.txt_0.text = "555.555.555.555";
		//Port
		//lable
		mc._plex.createTextField("lab_1", mc._plex.getNextHighestDepth(), 86, 60, 150, 26);
		mc._plex.lab_1.autoSize = true;
		mc._plex.lab_1.setNewTextFormat(myFormat);
		mc._plex.lab_1.text = "Port:";
		//Input
		txtPort = mc._plex.createTextField("txt_1", mc._plex.getNextHighestDepth(), 128, 60, 150, 26);
		//mc._plex.txt_1.autoSize = true;
		mc._plex.txt_1.setNewTextFormat(myFormat);
		mc._plex.txt_1.border = true;
		mc._plex.txt_1.background = true;
		mc._plex.txt_1.backgroundColor = offColor;
		mc._plex.txt_1.maxChars = 16
		mc._plex.txt_1.type = "input";
		mc._plex.txt_1.text = "Port";
		//Timeout
		//lable
		mc._plex.createTextField("lab_2", mc._plex.getNextHighestDepth(), 0, 90, 150, 26);
		mc._plex.lab_2.autoSize = true;
		mc._plex.lab_2.setNewTextFormat(myFormat);
		mc._plex.lab_2.text = "HTTP Timeout:";
		//Input
		txtHTTPTimeout = mc._plex.createTextField("txt_2", mc._plex.getNextHighestDepth(), 128, 90, 150, 26);
		//mc._plex.txt_2.autoSize = true;
		mc._plex.txt_2.setNewTextFormat(myFormat);
		mc._plex.txt_2.border = true;
		mc._plex.txt_2.background = true;
		mc._plex.txt_2.backgroundColor = offColor;
		mc._plex.txt_2.maxChars = 16
		mc._plex.txt_2.type = "input";
		mc._plex.txt_2.text = "HTTP Timeout";
		
		//Wall Pane
		//Wall Settings
		mc.createEmptyMovieClip("_wall", mc.getNextHighestDepth());
		mc._wall._alpha = 100;
		mc._wall._visible = true;
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
		mc._wall.txt_0.type = "input";
		mc._wall.txt_0.text = "#Rows";
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
		mc._wall.txt_1.type = "input";
		mc._wall.txt_1.text = "#Columns";
		
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
		mc._wall.txt_2.type = "input";
		mc._wall.txt_2.text = "#Rows";
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
		mc._wall.txt_3.type = "input";
		mc._wall.txt_3.text = "#Columns";
		
		//Music Lable
		//Lable
		mc._wall.createTextField("lab_40", mc._wall.getNextHighestDepth(), 0, 150, 150, 26);
		mc._wall.lab_40.autoSize = true;
		mc._wall.lab_40.setNewTextFormat(myFormat);
		mc._wall.lab_40.text = "Music:";
		//Shows Wall Number of Rows
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
		mc._wall.txt_4.type = "input";
		mc._wall.txt_4.text = "#Rows";
		//Shows Wall Number of Columns
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
		mc._wall.txt_5.type = "input";
		mc._wall.txt_5.text = "#Columns";
		
		//Positioning
		mc._plex._x = 200;
		mc._wall._x = 200;
		//trace(Utils.varDump(mc));
		//Navigation Array
		//[x][y]
		arrPlex[0][0] = mc._plex.txt_0;
		arrPlex[0][1] = mc._plex.txt_1;
		arrPlex[0][2] = mc._plex.txt_2;
		//Wall
		arrWall[0][0] = mc._wall.txt_0;
		arrWall[1][0] = mc._wall.txt_1;
		arrWall[0][1] = mc._wall.txt_2;
		arrWall[1][1] = mc._wall.txt_3;
		arrWall[0][2] = mc._wall.txt_4;
		arrWall[1][2] = mc._wall.txt_5;
		
		//Navigation Menu Array;
		arrMenu = [Array(arrPlex),Array(arrWall)];
		trace(Utils.varDump(arrMenu));
		trace(JSON.stringify(arrMenu));
		Utils.traceVar(arrMenu);
		
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
			case Key.UP:
				
			break;
			case Key.DOWN:
			
			break;
			case Key.RIGHT:
			
			break;
			case Key.LEFT:
			
			break;
			case Remote.HOME:
				this.destroy();
				gotoAndPlay("main");
			break;
		}
	}
	
	private function drawPane(mc:MovieClip, 
							  rectWidth:Number, 
							  rectHeight:Number, 
							  cornerRadius:Number, 
							  tabHeight:Number,
							  tabWidth:Number,
							  tabNumber:Number,
							  tabName:String,
							  fillColor:Number, 
							  fillAlpha:Number, 
							  lineThickness:Number, 
							  lineColor:Number, 
							  lineAlpha:Number) {
		trace("Setting Page - Doing drawPane with:" + mc);
		
		var x1:Number = cornerRadius;
		var y1:Number = tabHeight*(tabNumber-1);
		
		with (mc) {
			beginFill(fillColor,fillAlpha);
			lineStyle(lineThickness,lineColor,lineAlpha);
			
			moveTo(0, tabHeight*(tabNumber-1));
			lineTo(tabWidth, tabHeight*(tabNumber-1));
			lineTo(tabWidth, 0);
			lineTo(tabWidth+rectWidth, 0);
			lineTo(tabWidth+rectWidth, rectHeight);
			lineTo(tabWidth, rectHeight);
			lineTo(tabWidth, tabHeight*tabNumber);
			lineTo(0, tabHeight*tabNumber);
			
			/*curveTo(rectWidth, 0, rectWidth, cornerRadius);
			lineTo(rectWidth,cornerRadius);
			lineTo(rectWidth,rectHeight-cornerRadius);
			curveTo(rectWidth,rectHeight,rectWidth-cornerRadius,rectHeight);
			lineTo(rectWidth-cornerRadius,rectHeight);
			lineTo(cornerRadius,rectHeight);
			curveTo(0,rectHeight,0,rectHeight-cornerRadius);
			lineTo(0,rectHeight-cornerRadius);
			lineTo(0,cornerRadius);
			curveTo(0,0,cornerRadius,0);
			lineTo(cornerRadius,0);*/
			endFill();
		}
	}

}
