import mx.utils.Delegate;

import com.syabas.as2.common.D;
import com.syabas.as2.common.VKMain;

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
	private var select:Array = new Array();
	//Key Board
	private var vkMC:MovieClip = null;
	private var vkMain:VKMain = null;
	private var kbData:Object = null;
	private var kbData2:Object = null;
	//Text fields
	private var txtIP:TextField = null;
	private var txtPort:TextField = null;
	private var txtHTTPTimeout:TextField = null;

	// Initialization:
	public function SettingsPage(parentMC:MovieClip) 
	{
		_settings = parentMC.createEmptyMovieClip("plex", parentMC.getNextHighestDepth());
		build(_settings);
		showSavedData();
	}

	// Public Methods:
	public function destroy():Void
	{
		_settings.removeMovieClip();
		delete _settings;
		
	}
	// Private Methods:
	private function showSavedData()
	{
		txtIP.text = PlexData.oSettings.ip;
		txtPort.text = PlexData.oSettings.port;
		txtHTTPTimeout.text = PlexData.oSettings.timeout;
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
		
		//Positioning
		mc._plex._x = 200;
		//trace(Utils.varDump(mc));
		
		
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
