
import com.syabas.as2.common.Util;
import mx.utils.Delegate;
import mx.xpath.XPathAPI;

class plexNMT.as2.api.PlexAPI 
{
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PlexAPI;
	public static var plexURL:String = "http://192.168.0.3:32400";
	
	// Public Properties:
	// Private Properties:
	private static var menu:String = "";

	// Initialization:
	public static function loadData(url:String, onLoad:Function, timeout:Number):Void 
	{
		trace("Doing PlexAPI.loadData...");
		Util.loadURL(url, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if (success)
			{
				trace("PlexAPI.loadData Successful...");
				
				menu = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.viewGroup.toString());
				trace("PlexAPI.loadData.menu : ");
				trace(menu);
				//switch (type) 
				switch (menu)
				{
					case "" :
					case "secondary" :
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Directory");
						var dataLen:Number = xmlNodeList.length;
						//trace("xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						//var strTemp:String = null;
							
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							var itemNode:XMLNode = null;
							for (var i:Number=0; i<dataLen; i++)
							{
								itemNode = xmlNodeList[i];
								//trace(itemNode.attributes["title"]);
								//strTemp = url + "/" + Util.trim(itemNode.attributes["key"]);
								//trace("PlexAPI.strTemp: " + strTemp);
								
								data.push
								({
									//title:Util.trim(XPathAPI.selectSingleNode(itemNode, "/").attributes.title.toString()),
									title:Util.trim(itemNode.attributes["title"]),
									index:Number(i+1),
									key:Util.trim(itemNode.attributes["key"]),
									type:Util.trim(itemNode.attributes["type"]),
									url:null
								});
							}
							//Debug 
							//trace("PlexAPI.url: " + url);
							//var_dump(data);
						}
						this.onLoad(data);
					break;
					//case "movie" :
					case "movie" :
						trace("Doing PlexAPI.movie...");
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video");
						var dataLen:Number = xmlNodeList.length;
						trace("movie.xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							trace("Doing PlexAPI.movie has length...");
							var itemNode:XMLNode = null;
							trace("Doing PlexAPI.movie for loop...");
							for (var i:Number=0; i < dataLen; i++)
							{
								itemNode = xmlNodeList[i];
								//trace(itemNode.attributes["title"]);
								//trace(XPathAPI.selectSingleNode(itemNode, "/Video/Media/Part").attributes.key);
								data.push
								({
									title:Util.trim(itemNode.attributes["title"]),
									index:Number(i+1),
									artURL:plexURL + "/photo/:/transcode?width=1280&height=720&url=" + escape(plexURL + Util.trim(itemNode.attributes["art"])),
									thumbURL:plexURL + "/photo/:/transcode?width=117&height=174&url=" + escape(plexURL + Util.trim(itemNode.attributes["thumb"])),
									url:plexURL + Util.trim(XPathAPI.selectSingleNode(itemNode, "/Video/Media/Part").attributes.key.toString()),
									tagline:Util.trim(itemNode.attributes["tagline"]),
									ratingKey:Util.trim(itemNode.attributes["ratingKey"]),
									total:dataLen
								});
							}
							trace("Done PlexAPI.movie for loop...");
							//Debug 
							//var_dump(data);
						}
						//trace(data);
						this.onLoad(data);
						trace("Done PlexAPI.movie...");
					break;
					case "show" :
					trace("Doing PlexAPI.show...");
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Directory");
						var dataLen:Number = xmlNodeList.length;
						trace("movie.xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							trace("Doing PlexAPI.show has length...");
							var itemNode:XMLNode = null;
							trace("Doing PlexAPI.show for loop...");
							for (var i:Number=0; i < dataLen; i++)
							{
								itemNode = xmlNodeList[i];
								data.push
								({
									title:Util.trim(itemNode.attributes["title"]),
									index:Number(i+1),
									artURL:plexURL + "/photo/:/transcode?width=1280&height=720&url=" + escape(plexURL + Util.trim(itemNode.attributes["art"])),
									thumbURL:plexURL + "/photo/:/transcode?width=117&height=174&url=" + escape(plexURL + Util.trim(itemNode.attributes["thumb"])),
									bannerURL:plexURL + "/photo/:/transcode?width=117&height=174&url=" + escape(plexURL + Util.trim(itemNode.attributes["banner"])),
									url:plexURL + Util.trim(XPathAPI.selectSingleNode(itemNode, "/Video/Media/Part").attributes.key.toString()),
									key:Util.trim(itemNode.attributes["ratingKey"]),
									total:dataLen
								});
							}
							trace("Done PlexAPI.show for loop...");
							//Debug 
							//var_dump(data);
						}
						//trace(data);
						this.onLoad(data);
						trace("Done PlexAPI.movie...");
					break;
					case "season" :
					case "episode" :
					case "artist" :
					case "album" :
						trace("Doing PlexAPI." + menu + "...");
					break;
					default :
						trace("Unknowen PlexAPI." + menu + "...");
					break;
				}
			}
			else
			{
				this.onLoad(null);
			}
		}), {target:"xml", timeout:timeout});
	}

	public static function loadMoveDetails(url:String, onLoad:Function, timeout:Number):Void 
	{
		trace("Doing PlexAPI.loadMoveDetails...");
		Util.loadURL(url, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if (success)
			{
				trace("PlexAPI.loadMoveDetails Successful...");
				
				var data:Array = new Array();
				data.push
				({
					title:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.title.toString()),
					artURL:plexURL + "/photo/:/transcode?width=1280&height=720&url=" + escape(plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.art.toString())),
					posterURL:plexURL + "/photo/:/transcode?width=1280&height=720&url=" + escape(plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.thumb.toString())),
					studioURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/studio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.studio.toString()) + "?t=1"),
					contentRatingURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/contentRating/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.contentRating.toString()) + "?t=1"),
					videoResolutionURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/videoResolution/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.videoResolution.toString()) + "?t=1"),
					aspectRatioURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/aspectRatio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.aspectRatio.toString()) + "?t=1"),
					audioChannelsURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/audioChannels/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioChannels.toString()) + "?t=1"),
					audioCodecURL:plexURL + "/photo/:/transcode?width=1000&height=38&url=" + escape(plexURL + "/system/bundle/media/flags/audioCodec/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioCodec.toString()) + "?t=1"),
					durationMIN:int(Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media/Part").attributes.duration.toString())/60000).toString() + " minutes",
					summary:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.summary.toString()),
					rating:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.rating.toString())/10
				});
				this.onLoad(data);
				trace("Done PlexAPI.loadMoveDetails...");
			}
			else
			{
				this.onLoad(null);
			}
		}), {target:"xml", timeout:timeout});
	}
																									   
	private function var_dump(_obj:Object)
	{
		trace("Doing var_dump...");
		trace(_obj);
		trace("Looping Through _obj...");
		for (var i in _obj)
		{
			trace("_obj[" + i + "] = " + _obj[i] + " type = " + typeof(_obj[i]));
			if (typeof(_obj[i]) == "object")
			{
				var_dump(_obj[i]);
			}
		}
	}
}