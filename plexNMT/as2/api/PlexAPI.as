﻿
import com.syabas.as2.common.Util;
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
	public static function getSections(onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + "/library/sections", Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getSections: " + success);
                PlexData.oSections = new XMLObject().parseXML(xml,true);
				PlexData.setSections();
                delete xml
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Sections...");
			}
			this.onLoad(PlexData.oSections);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getCategories(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + "/library/sections/" + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getCategories: " + success);
                PlexData.oCategories = new XMLObject().parseXML(xml, true);
				PlexData.setCategories();
                delete xml
				//Utils.varDump(PlexData.oCategories)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Categories...");
			}
			this.onLoad(PlexData.oCategories);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getFilters(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + "/library/sections/" + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getFilters: " + success);
                PlexData.oFilters = new XMLObject().parseXML(xml, true);
				PlexData.setFilters();
                delete xml
				//Utils.varDump(PlexData.oFilters)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Filters...");
			}
			this.onLoad(PlexData.oFilters);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getWallData(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getWallData: " + success);
                PlexData.oWallData = new XMLObject().parseXML(xml, true);
				PlexData.setWallData();
                delete xml
				//Utils.varDump(PlexData.oWallData)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get WallData...");
			}
			this.onLoad(PlexData.oWallData);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getMovieData(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getMovieData: " + success);
                PlexData.oMovieData = new XMLObject().parseXML(xml, true);
				PlexData.setMovieData();
                delete xml
				//Utils.varDump(PlexData.oFilters)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Movie Data...");
			}
			this.onLoad(PlexData.oFilters);
		}), {target:"xml", timeout:timeout});
	}
		
	public static function getSeasonData(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getSeasonData: " + success);
                PlexData.oSeasonData = new XMLObject().parseXML(xml, true);
				PlexData.setSeasonData();
                delete xml
				//Utils.varDump(PlexData.oMovieData)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Season Data...");
			}
			this.onLoad(PlexData.oSeasonData);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getEpisodeData(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getEpisodeData: " + success);
                PlexData.oEpisodeData = new XMLObject().parseXML(xml, true);
				PlexData.setEpisodeData();
                delete xml
				//Utils.varDump(PlexData.oEpisodeData)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Episode Data...");
			}
			this.onLoad(PlexData.oEpisodeData);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getBackground(key:String, onLoad:Function, timeout:Number):Void
	{
		Util.loadURL(PlexData.oSettings.url + key, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if(success)
			{
				trace("Doing PlexAPI - getSeasonData: " + success);
                PlexData.oSeasonData = new XMLObject().parseXML(xml, true);
				PlexData.setSeasonData();
                delete xml
				//Utils.varDump(PlexData.oMovieData)
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get Season Data...");
			}
			this.onLoad(PlexData.oWallData);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getViewGroup(url:String, onLoad:Function, timeout:Number):Void
	{
		trace("Doing getViewGroup with: " + url);
		Util.loadURL(PlexData.oSettings.url + url + "?X-Plex-Container-Start=0&X-Plex-Container-Size=0", Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			var viewGroup:String = "Error";
			if(success)
			{
				viewGroup = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.viewGroup.toString());
			}else{
				D.debug(D.lDebug, "PlexAPI - Faled to get ViewGroup...");
			}
			this.onLoad(viewGroup);
		}), {target:"xml", timeout:timeout});
	}
	
	public static function getImg(_arg:Object):String
	{
		//trace("Plex API - Doing getImg with:");
		//Utils.varDump(_arg);
		var strURL:String = PlexData.oSettings.url + "/photo/:/transcode";
		strURL = strURL + "?width=" + _arg.width;
		strURL = strURL + "&height=" + _arg.height;
		strURL = strURL + "&url=" + escape(PlexData.oSettings.url + _arg.key);
		//trace("Plex API - Returning: " + strURL);
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
		//http://plexIP:32400/:/scrobble?key=26360&identifier=com.plexapp.plugins.library
	}
}