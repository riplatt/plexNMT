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
		playingInterval = setInterval(Delegate.create(this,getCurrentTime), PlexData.oSettings.timeout);
	}
	
	public function queueVOD(_title:String, partKey:String)
	{
		D.debug(D.lDev, "PopAPI - Doing queueVOD...");
		Util.loadURL("http://127.0.0.1:8008/playback" + 
					 "?arg0=insert_vod_queue" +
					 "&arg1=" + _title + 
					 "&arg2=" + PlexData.oSettings.url + partKey + 
					 "&arg3=show" + 
					 "&arg4=start_zero");
	}
	
	public function playQueueVOD()
	{
		D.debug(D.lDev, "PopAPI - Doing playQueueVOD...");
		Util.loadURL("http://127.0.0.1:8008/playback" + 
					 "?arg0=next_vod_in_queue");
		playingInterval = setInterval(Delegate.create(this,getCurrentTime), PlexData.oSettings.timeout);
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
				D.debug(D.lDev,"Doing PopAPI - getCurrentTime successful: " + success);
                PlexData.oCurrentTime = new XMLObject().parseXML(xml, true);
                delete xml
				//Utils.varDump(PlexData.oCategories)
			}else{
				D.debug(D.lDebug, "PopAPI - Faled to get Current Time...");
			}
			this.onCurrentTime();
		}), {target:"xml", timeout:PlexData.oSettings.timeout});
	}
	
	private function onCurrentTime()
	{
		D.debug(D.lDev, "PopAPI - onCurrentTime title: " + PlexData.oCurrentTime.theDavidBox[0].response[0].title[0].data);
		D.debug(D.lDev, "PopAPI - onCurrentTime currentTime: " + PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0].data);
		//D.debug(D.lDev, Utils.varDump(PlexData.oCurrentTime.theDavidBox[0].response[0]));
		//var key:Number = PlexData.oCurrentTime.theDavidBox[0].response[0].Data.time;
		if (PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0] != undefined)
		{
			//var key:String = this.videoKey;
			var key:String = PlexData.oCurrentTime.theDavidBox[0].response[0].title[0].data;
			var time:Number = int(PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0].data);
			var _state:String = PlexData.oCurrentTime.theDavidBox[0].response[0].currentStatus[0].data;
			PlexAPI._setProgress(key, time, _state);
		} else {
			clearInterval(playingInterval);
		}
		
	}
	
	
}