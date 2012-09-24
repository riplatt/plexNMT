
import com.syabas.as2.common.VKMain;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.JSONUtil;
import com.syabas.as2.common.D;

import mx.utils.Delegate;

import plexNMT.as2.common.Remote;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.popSharedObjects;

class plexNMT.as2.pages.SettingsPage {
	
	private var parentMC:MovieClip = null;
	private var mainMC:MovieClip = null;
	private var vkMC:MovieClip = null;

	private var vkMain:VKMain = null;
	private var kbData:Object = null;
	private var kbData2:Object = null;
	private var keyListener:Object = null;
	private var index:Number = null;
	private var lastSuggString:String = null;

	private var fn:Object = null;
	
	//private var plexSO:MobileSharedObject = null;
	private var plexIP:String = null;
	private var plexPort:String = null;
	private var wallCol:String = null;
	private var wallRow:String = null;

	public function SettingsPage(parentMC:MovieClip)
	{
		trace("Doing Settings Page with: "+parentMC);
		this.parentMC = parentMC;
		this.mainMC = parentMC.attachMovie("settingsMC", "settingsMC" , parentMC.getNextHighestDepth(), {_x:0, _y:0});
		this.vkMC = mainMC.createEmptyMovieClip("vk", mainMC.getNextHighestDepth());

		//plexSO = new MobileSharedObject(mainMC.out_0);
		//testFSCommands();
		
		fn = {
			onKeyDown : Delegate.create(this, this.onKeyDown),
			onDoneCB : Delegate.create(this, this.onDoneCB),
			suggUpdateCB : Delegate.create(this, this.suggUpdateCB),
			onSuggLoad : Delegate.create(this, this.onSuggLoad)
		};
		//var bob = Delegate.create(this, this.onloadPlexSO)
		Util.loadURL("json/vk3_data.json", Delegate.create(this, this.loadAlphanum));
		

	}
	
	private function onloadPlexSO(){
		Util.loadURL("json/vk3_data.json", Delegate.create(this, this.loadAlphanum));
	}

	public function destroy():Void
	{
		cleanUp(this.parentMC);
		
		delete vkMain;
		delete kbData;
		delete kbData2;
		Key.removeListener(this.keyListener);
		delete keyListener;
		delete fn;
		//delete plexSO;
		
		this.index = null;
		this.lastSuggString = null;
		this.plexIP = null;
		this.plexPort = null;
		this.wallCol = null;
		this.wallRow = null;
		
	}
	
	private function loadAlphanum(success:Boolean, data:String, o:Object):Void
	{
		this.kbData = JSONUtil.parseJSON(data).keyboard_data;

		Util.loadURL("json/vk3_data_alphanum.json", Delegate.create(this, this.onloadAlphanum));
	}

	private function onloadAlphanum(success:Boolean, data:String, o:Object):Void
	{
		this.kbData2 = JSONUtil.parseJSON(data).keyboard_data;

		this.keyListener = new Object();
		this.keyListener.onKeyDown = this.fn.onKeyDown;

		Key.addListener(this.keyListener);
		
		if (PlexData.oSettings.ip == null)
		{
			this.mainMC.txt_0.text = "192.168.1.3";
		} else {
			this.mainMC.txt_0.text = PlexData.oSettings.ip;
		}
		// set txt_1 equal to SO data 'plexPort'
		if (PlexData.oSettings.port == null)
		{
			this.mainMC.txt_1.text = "32400";
		} else {
			this.mainMC.txt_1.text = PlexData.oSettings.port;
		}
		// set txt_2 equal to SO data 'wallCol'
		if (PlexData.oWall.columns == null)
		{
			this.mainMC.txt_2.text = "3";
		} else {
			this.mainMC.txt_2.text = PlexData.oWall.rows;
		}
		// set txt_3 equal to SO data 'wallRow'
		if (PlexData.oWall.rows == null)
		{
			this.mainMC.txt_3.text = "9";
		} else {
			this.mainMC.txt_3.text = PlexData.oWall.columns;
		}
		// set txt_4 equal to defualt debug level
		this.mainMC.txt_4.text = PlexData.oSettings.debugLevel;
		this.mainMC.txt_5.text = PlexData.oSettings.buffer;
				
		this.index = 0;
		trace("Settings plexData.oSettings.url:" + PlexData.oSettings.url);
		this.focusTextField();
	}
	
	private function onLoadPlexIP(success:Boolean, data:String, o:Object):Void {
		this.mainMC.txt_0.text = data
	}

	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		//trace("Doing Key With: "+keyCode+" and index: "+this.index);

		switch (keyCode)
		{
			case Key.UP:
				this.index --;
				if (this.index < 0)
				{
					this.index =5;
				}
				this.focusTextField();
			break;
			case Key.DOWN:
				this.index ++;
				if (this.index > 5)
				{
					this.index = 0;
				}
				this.focusTextField();
			break;
			case Key.ENTER:
				this.startInput();
			break;
			case "soft1":  //for testing on pc
			case Remote.BACK:
				this.setSettingsData();
				popSharedObjects.savePlexData();
				this.destroy();
				gotoAndPlay("main");
				break;
			case Remote.HOME:
				this.setSettingsData();
				popSharedObjects.savePlexData();
				this.destroy();
				gotoAndPlay("main");
			break;
			case Remote.YELLOW:
				this.setSettingsData();
				popSharedObjects.savePlexData();
				this.destroy();
				gotoAndPlay("settings");
			break;
			
		}
		
	}
	
	private function setSettingsData()
	{
		PlexData.oSettings.ip = this.mainMC.txt_0.text;
		PlexData.oSettings.port = this.mainMC.txt_1.text;
		PlexData.oSettings.url = "http://"+PlexData.oSettings.ip+":"+PlexData.oSettings.port
		
		PlexData.oWall.rows = this.mainMC.txt_2.text;
		PlexData.oWall.columns = this.mainMC.txt_3.text;
		PlexData.oSettings.buffer = this.mainMC.txt_4.text;
		
		PlexData.setWall();
	}
	private function focusTextField():Void
	{
		var offColor:Number = 0x6E7B8B;
		var onColor:Number = 0xFFFFFF;
		trace("Setting pointer with index: "+this.index);
		this.mainMC["txt_0"].background = true;
		this.mainMC["txt_0"].backgroundColor = offColor;
		this.mainMC["txt_1"].background = true;
		this.mainMC["txt_1"].backgroundColor = offColor;
		this.mainMC["txt_2"].background = true;
		this.mainMC["txt_2"].backgroundColor = offColor;
		this.mainMC["txt_3"].background = true;
		this.mainMC["txt_3"].backgroundColor = offColor;
		this.mainMC["txt_4"].background = true;
		this.mainMC["txt_4"].backgroundColor = offColor;
		this.mainMC["txt_5"].background = true;
		this.mainMC["txt_5"].backgroundColor = offColor;
		
		this.mainMC["txt_" + this.index].backgroundColor = onColor;
		//this.mainMC.mc_pointer._y = this.mainMC["txt_" + this.index]._y; // move red pointer
	}
	
	private function startInput():Void
	{
		var vkObj:Object = new Object();
		vkObj.onDoneCB = this.fn.onDoneCB;
		vkObj.onCancelCB = this.fn.onDoneCB;
		vkObj.onSuggUpdateCB = null 									//(this.index == 2 ? this.fn.suggUpdateCB : null);
		vkObj.keyboard_data = (this.index == 4 ? this.kbData2 : this.kbData);
		vkObj.initValue = this.mainMC["txt_" + this.index].text;
		vkObj.parentPath = this.mainMC._url;
		vkObj.title = this.mainMC["lable_" + this.index].text;
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

		this.keyListener.onKeyDown = null;
	}

	private function onDoneCB(s:String):Void
	{
		//Write sharedObjects
		switch (this.index)
		{
			case 0:
				PlexData.oSettings.ip = s;
			break;
			case 1:
				PlexData.oSettings.port = s;
			break;
			case 2:
				PlexData.oWall.rows = s;
				PlexData.setWall();
			break;
			case 3:
				PlexData.oWall.columns = s;
				PlexData.setWall();
			break;
			case 4:
				D.level = int(s);
				PlexData.oSettings.debugLevel = int(s);
				D.debug(D.lDebug,"Settings - Debug level on...");
				D.debug(D.lInfo,"Settings - Info level on...");
				D.debug(D.lError,"Settings - Error level on...");
				if(s == 0){
					D.debug(D.lInfo,"Settings - Logging off...");
					D.mc._visible = false;
					D.destroy();
				} else {
					if (D.loaded != true)
					{
						D.init({mc:{level:100, showHideKC:16777250, upKC:Key.UP, downKC:40
							, mcProps:{_x:725, _y:50, _width:500, _height:600}}, remote:{ip:"127.0.0.1"}
						});
						
					}
				}
			break;
			case 5:
				PlexData.oSettings.buffer = s;
			break;
		}
		this.mainMC["txt_" + this.index].text = s;
		PlexData.oSettings.url = "http://"+PlexData.oSettings.ip+":"+PlexData.oSettings.port
		//PlexData.writeSO();
		this.lastSuggString = null;
		this.vkMain.hideVK();
		this.keyListener.onKeyDown = this.fn.onKeyDown;
		fn.onKeyDown;
	}

	private function onCancelCB(s:String):Void
	{
		this.lastSuggString = null;
		this.vkMain.hideVK();
		this.keyListener.onKeyDown = this.fn.onKeyDown;
	}

	/*
	* Suggestion list update callback from virtual keyboard
	*
	* text	- The current text in the input textfield
	*/
	private function suggUpdateCB(text:String):Void
	{
		var pos:Number = this.vkMain.getCaretPosition();
		var searchText:String = text.substring(0, pos);
		var url:String = "http://suggestqueries.google.com/complete/search?hl=en&client=products&ds=yt&json=t&cp=1&q=" + escape(searchText);

		Util.loadURL(url, this.fn.onSuggLoad, { id:searchText } );
		this.lastSuggString = searchText;
	}

	private function onSuggLoad(success:Boolean, data:String, o:Object):Void
	{
		var result:Object = JSONUtil.parseJSON(data);

		if (o.o.id == this.lastSuggString)
		{
			this.vkMain.updateSuggestion(Util.isBlank(result[1].toString()) ? [] : result[1], this.lastSuggString);
		}

		result = null;
	}
	
	private function testFSCommands(){
		D.debug(D.lDebug,"Splash - fscommand2 GetMaxSignalLevel: " + fscommand2("GetMaxSignalLevel"));
		D.debug(D.lDebug,"Splash - fscommand2 GetSignalLevel: " + fscommand2("GetSignalLevel"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkConnectionName: " + fscommand2("GetNetworkConnectionName"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkConnectStatus: " + fscommand2("GetNetworkConnectStatus"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkGeneration: " + fscommand2("GetNetworkGeneration"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkName: " + fscommand2("GetNetworkName"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkRequestStatus: " + fscommand2("GetNetworkRequestStatus"));
		D.debug(D.lDebug,"Splash - fscommand2 GetNetworkStatus: " + fscommand2("GetNetworkStatus"));
		D.debug(D.lDebug,"Splash - fscommand2 GetBatteryLevel: " + fscommand2("GetBatteryLevel"));
		D.debug(D.lDebug,"Splash - fscommand2 GetMaxBatteryLevel: " + fscommand2("GetMaxBatteryLevel"));
		D.debug(D.lDebug,"Splash - fscommand2 GetPowerSource: " + fscommand2("GetPowerSource"));
		D.debug(D.lDebug,"Splash - fscommand2 GetPlatform: " + fscommand2("GetPlatform"));
		D.debug(D.lDebug,"Splash - fscommand2 GetDevice: " + fscommand2("GetDevice"));
		D.debug(D.lDebug,"Splash - fscommand2 GetDeviceID: " + fscommand2("GetDeviceID"));
		D.debug(D.lDebug,"Splash - fscommand2 GetTotalPlayerMemory: " + fscommand2("GetTotalPlayerMemory"));
		D.debug(D.lDebug,"Splash - fscommand2 GetFreePlayerMemory: " + fscommand2("GetFreePlayerMemory"));
		D.debug(D.lDebug,"Splash - fscommand2 GetMaxVolumeLevel: " + fscommand2("GetMaxVolumeLevel"));
		D.debug(D.lDebug,"Splash - fscommand2 GetVolumeLevel: " + fscommand2("GetVolumeLevel"));
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
}