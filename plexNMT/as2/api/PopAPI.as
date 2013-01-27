import mx.utils.Delegate;
import mx.xpath.XPathAPI;

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
	
	public function getModel()
	{
		Util.loadURL("http://" + PlexData.oNMT.ip + ":8008/system?arg0=get_firmware_version", Delegate.create(this, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				D.debug(D.lDev,"Doing PopAPI - getModel successful: " + success);
				PlexData.oNMT.firmware = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/firmwareVersion").firstChild.nodeValue.toString();
				
				var start = PlexData.oNMT.firmware.indexOf("-POP-") + 5;
				var end = PlexData.oNMT.firmware.lastIndexOf("-");
				var tmpModel = PlexData.oNMT.firmware.substring(start, end);
				switch(tmpModel) {
					case "412":
					case "413":
						PlexData.oNMT.modelname = "POPBOX 3D";
					break;
					case "415":
						PlexData.oNMT.modelname = "AsiaBox";
					break;
					case "417":
						PlexData.oNMT.modelname = "POPBOX V8";
					break;
					case "420":
						PlexData.oNMT.modelname = "Popcorn Hour C300";
					break;
					case "421":
						PlexData.oNMT.modelname = "Popcorn Hour A300";
					break;
					default:
						PlexData.oNMT.modelname = "Popcorn Hour 200 Series";
					break;
				}
                delete xml
				//Look for new frimware
				Util.loadURL("http://" + PlexData.oNMT.ip + ":8008/system?arg0=system_info", Delegate.create(this, function(success:Boolean, xml:XML, o:Object):Void
				{
					if(success)
					{
						D.debug(D.lDev,"Doing PopAPI - Newer Firmware Found With System Info Support...");
						PlexData.oNMT.modelname = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/name").firstChild.nodeValue.toString();
						delete xml
					}else{
						D.debug(D.lDebug, "PopAPI - Running Older Firmware Without System Info...");
					}
				}), {target:"xml", timeout:PlexData.oSettings.timeout});
				
			}else{
				D.debug(D.lDebug, "PopAPI - Failed to get Model...");
			}
		}), {target:"xml", timeout:PlexData.oSettings.timeout});
	}
	
	public function getMAC()
	{
		Util.loadURL("http://127.0.0.1:8008/system?arg0=get_mac_address", Delegate.create(this, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				D.debug(D.lDev,"Doing PopAPI - getMAC successful...");
				var tmpMAC = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/macAddress").firstChild.nodeValue.toString();
				PlexData.oNMT.id = tmpMAC.split(":").join("");
                delete xml
			}else{
				D.debug(D.lDebug, "PopAPI - Failed to get MAC address...");
			}
			this.onCurrentTime();
		}), {target:"xml", timeout:PlexData.oSettings.timeout});
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
				D.debug(D.lDebug, "PopAPI - Failed to get Current Time...");
			}
			this.onCurrentTime();
		}), {target:"xml", timeout:PlexData.oSettings.timeout});
	}
	
	private function onCurrentTime()
	{
		D.debug(D.lDev, "PopAPI - onCurrentTime title: " + PlexData.oCurrentTime.theDavidBox[0].response[0].title[0].data);
		D.debug(D.lDev, "PopAPI - onCurrentTime currentTime: " + PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0].data);
		if (PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0] != undefined)
		{
			var key:String = PlexData.oCurrentTime.theDavidBox[0].response[0].title[0].data;
			var time:Number = int(PlexData.oCurrentTime.theDavidBox[0].response[0].currentTime[0].data);
			var _state:String = PlexData.oCurrentTime.theDavidBox[0].response[0].currentStatus[0].data;
			PlexAPI._setProgress(key, time, _state);
		} else {
			clearInterval(playingInterval);
		}
		
	}
	
	
}