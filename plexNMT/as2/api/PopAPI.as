import mx.utils.Delegate;

import com.syabas.as2.common.D;
import com.syabas.as2.common.Util;

import it.sephiroth.XMLObject;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;

class plexNMT.as2.api.PopAPI {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PopAPI;
	
	// Public Properties:
	// Private Properties:
	private var playingInterval:Number = 0;
	private var videoKey:String = "";

	// Initialization:
	public function PopAPI() {}

	// Public Methods:
	public function playVOD(key:String, partKey:String, resume:Number)
	{
		D.debug(D.lDev, "PopAPI - Doing playVOD...");
		videoKey = key;
		Util.loadURL("http://127.0.0.1:8008/playback" + 
					 "?arg0=start_vod" + 
					 "&arg1=" + key + 
					 "&arg2=" + PlexData.oSettings.url + partKey + 
					 "&arg3=show" + 
					 "&arg4=" + resume + 
					 "&arg5=" + PlexData.oSettings.buffer + 
					 "&arg6=enable");
		playingInterval = setInterval(Delegate.create(this,getCurrentTime), 5000);
	}
	
	public function stopUpdates()
	{
		clearInterval(this.playingInterval);
	}
	// Private Methods:
	private function getCurrentTime()
	{
		Util.loadURL("http://127.0.0.1:8008/playback" + 
					 "?arg0=get_current_vod_info", Delegate.create(this, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PopAPI - getCurrentTime successful: " + success);
                PlexData.oCurrentTime = new XMLObject().parseXML(xml, true);
                delete xml
				//Utils.varDump(PlexData.oCategories)
			}else{
				D.debug(D.lDebug, "PopAPI - Faled to get Current Time...");
			}
			this.onCurrentTime();
		}), {target:"xml", timeout:5000});
	}
	
	private function onCurrentTime()
	{
		//D.debug(D.lDev, "PopAPI - Doing onCurrentTime...");
		//xml : theDavidBox/returnValue = 0 then PlexAPI._setProgress(key, time, state)
		/*
		*	key = xml(theDavidBox/response/title)
		*	time = xml(theDavidBox/currentTime/title)
		*	state = "playing"
		*/
		D.debug(D.lDev, "PopAPI - PlexData.oCurrentTime.theDavidBox[0].response[0]: ");
		D.debug(D.lDev, Utils.varDump(PlexData.oCurrentTime.theDavidBox[0].response[0]));
		//var key:Number = PlexData.oCurrentTime.theDavidBox[0].response[0].Data.time;
		/*if (PlexData.oCurrentTime.theDavidBox[0].response[0].Data.currentTime != undefined)
		{*/
			var key:String = this.videoKey;
			var time:Number = int(PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime.data);
			var _state:String = PlexData.oCurrentTime.theDavidBox[0].response[0].currentStatus.data;
			PlexAPI._setProgress(key, time, _state);
		/*} else {
			clearInterval(playingInterval);
		}*/
		
	}
	
	
}