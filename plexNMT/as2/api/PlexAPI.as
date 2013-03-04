
import com.syabas.as2.common.Util;
import com.syabas.as2.common.JSONUtil;
import com.syabas.as2.common.D;

import it.sephiroth.XMLObject;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;

/* -- to infrom plex what we are
?X-Plex-Client-Capabilities => 
	protocols=
		http-live-streaming,
		http-mp4-streaming,
		http-streaming-video,
		http-streaming-video-720p,
		http-mp4-video,
		http-mp4-video-720p;
	videoDecoders=
		h264{
			profile:high
			&resolution:1080
			&level:51
			};
	audioDecoders=
		mp3,
		aac{
			bitrate:160000
			}
&X-Plex-Client-Platform => 
	iOS
&X-Plex-Product =>
	Plex/iOS
&X-Plex-Version =>
	2.4.0
	
   -- to tell plex how much we have seen of video
/progress?key => 
	14872
&identifier => 
	com.plexapp.plugins.library
&time =>
	22672
&state => 
	playing //playing, stopped
	
	
-- Plex Headers

X-Plex-Platform (Platform name, eg iOS, MacOSX, Android, LG, etc)
X-Plex-Platform-Version (Operating system version, eg 4.3.1, 10.6.7, 3.2)
X-Plex-Provides (one or more of [player, controller, server])
X-Plex-Product (Plex application name, eg Laika, Plex Media Server, Media Link)
X-Plex-Version (Plex application version number)
X-Plex-Device (Device name and model number, eg iPhone3,2, Motorola XOOM™, LG5200TV)
X-Plex-Client-Identifier (UUID, serial number, or other number unique per device)


*/

class plexNMT.as2.api.PlexAPI 
{
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PlexAPI;
	public static var plexURL:String = null;
	
	// Public Properties:
	// Private Properties:
	private static var menu:String = "";

	// Initialization:
	
	// Public Functions
	public static function loadJSON(url:String, onLoadCB:Function, plexHeaders:Boolean)
	{
		var postLV:LoadVars = new LoadVars();
		var getLV:LoadVars = new LoadVars();
		var jsonData:Object = {};
		
		getLV.onData = function(src:String) {
            if (src == undefined) {
                D.debug(D.lDebug, "Error loading JSON content.");
                onLoadCB(false, null);
            }
			if (src.indexOf("}{") != -1)
			{
				D.debug(D.lError, "PlexAPI - Malformed json string found...");
				src = src.split("}{").join("},{");
				jsonData = JSONUtil.parseJSON(src);
			} else {
				D.debug(D.lDebug, "PlexAPI - JSON string Formate OK...");
				jsonData = JSONUtil.parseJSON(src);
			}
			D.debug(D.lDebug, "PlexAPI - loadJSON typeOf(jsonData): " + typeof(jsonData));
			onLoadCB(true, jsonData);
        };
		
		if (plexHeaders)
		{
			postLV.addRequestHeader("X-Plex-Platform", "FlashLite");
			postLV.addRequestHeader("X-Plex-Platform-Version", "3.1");
			postLV.addRequestHeader("X-Plex-Provides", "player");
			postLV.addRequestHeader("X-Plex-Product", "plexNMT");
			postLV.addRequestHeader("X-Plex-Version", "0.01");
			postLV.addRequestHeader("X-Plex-Device", PlexData.oNMT.modelname); 		//
			postLV.addRequestHeader("X-Plex-Client-Identifier", PlexData.oNMT.id);
		}
		
		postLV.addRequestHeader("Accept", "application/json");
        postLV.sendAndLoad(url, getLV, "POST");
	}
	
	public static function getSections(onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + "/library/sections", Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got Sections from PLEX...");
                PlexData.oSections = json;
				PlexData.setSections();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Sections from PLEX...");
			}
			this.onLoad();
		}), false);
	}	
	
	public static function getCategories(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + "/library/sections/" + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got Categories from PLEX...");
                PlexData.oCategories =  json;
				PlexData.setCategories();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Categories from PLEX...");
			}
			this.onLoad();
		}), false);
	}
	
	public static function getFilters(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + "/library/sections/" + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got Filters from PLEX...");
                PlexData.oFilters = json;
				PlexData.setFilters();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Filters from PLEX...");
			}
			this.onLoad();
		}), false);
	}
	
	public static function getWallData(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got Wall Data from PLEX...");
                PlexData.oWallData = json;
				PlexData.setWallData();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Wall Data from PLEX...");
			}
			this.onLoad();
		}), false);
	}
	
	public static function getPartWallData(key:String, offset:Number, size:Number, onLoad:Function, timeout:Number):Void
	{
		var urlEatra:String = "?type=1&X-Plex-Container-Size="+size+"&X-Plex-Container-Start="+offset;
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got Part Wall Data from PLEX...");
                //PlexData.oWallData = json;
				PlexData.addWallData(json);
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Part Wall Data from PLEX...");
			}
			this.onLoad();
		}), false);
	}
	
	public static function getMovieData(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got MovieData from PLEX...");
                PlexData.oMovieData = json;
				PlexData.setMovieData();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Movie Data from PLEX...");
			}
			this.onLoad();
		}), false);
	}
		
	public static function getSeasonData(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got SeasonData from PLEX...");
                PlexData.oSeasonData = json;
				PlexData.setSeasonData();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Season Data from PLEX...");
			}
			this.onLoad();
		}), false);
	}
	
	public static function getEpisodeData(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got EpisodeData from PLEX...");
                PlexData.oEpisodeData = json;
				PlexData.setEpisodeData();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Episode Data from PLEX...");
			}
			this.onLoad(PlexData.oEpisodeData);
		}), false);
	}
	
	public static function getBackground(key:String, onLoad:Function, timeout:Number):Void
	{
		PlexAPI.loadJSON(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, json:Object):Void
		{
			if(success)
			{
				D.debug(D.lDev, "PlexAPI - Got Background from PLEX...");
                PlexData.oBackground = json;
				PlexData.setBackground();
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get Background Data from PLEX...");
			}
			this.onLoad(PlexData.oWallData);
		}), false);
	}
	
	public static function getViewGroup(url:String, onLoad:Function, timeout:Number):Void
	{
		D.debug(D.lDev, "PlexAPI - getViewGroup called with: " + url);
		Util.loadURL(PlexData.oSettings.url + url + "?X-Plex-Container-Start=0&X-Plex-Container-Size=0", Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			D.debug(D.lDebug, "PlexAPI - getViewGroup Load XML...");
			var viewGroup:String = "Error";
			if(success)
			{
				D.debug(D.lDebug, "PlexAPI - Got ViewGroup from PLEX...");
				viewGroup = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.viewGroup.toString());
			}else{
				D.debug(D.lError, "PlexAPI - Failed to get ViewGroup Data from PLEX...");
			}
			this.onLoad(viewGroup);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getImg(_arg:Object):String
	{
		var strURL:String = PlexData.oSettings.url + "/photo/:/transcode";
		strURL = strURL + "?width=" + _arg.width;
		strURL = strURL + "&height=" + _arg.height;
		strURL = strURL + "&url=" + escape(PlexData.oSettings.url + _arg.key);
		return strURL;
	}
	
	public static function _setProgress(key:String, time:Number, _state:String)
	{
		/* /:/progress?key=26147						Video key
		*	&identifier=com.plexapp.plugins.library
		*	&time=24688									Time ms
		*	&state=stopped 								playing || stopped
		*/
		D.debug(D.lDebug,"PlexAPI - Doing _setProgress with key: " + key + ", state: " + _state);
		if (key == "play")
		{
			key = "playing";
		} 
		var url:String = PlexData.oSettings.url + "/:/progress" +
						 "?key=" + key +
						 "&identifier=com.plexapp.plugins.library" +
						 "&time=" + (time * 1000) +
						 "&state=" + _state;
		Util.loadURL(url);
	}
	
	public static function markWatched(key:String)
	{
		var url:String = PlexData.oSettings.url + "/:/scrobble" +
						 "?key=" + key +
						 "&identifier=com.plexapp.plugins.library";
		Util.loadURL(url);
	}
}