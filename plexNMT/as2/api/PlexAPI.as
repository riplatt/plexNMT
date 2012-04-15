﻿
import com.syabas.as2.common.Util;
import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import plexNMT.as2.common.PlexData;

class plexNMT.as2.api.PlexAPI 
{
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PlexAPI;
	//public static var plexURL:String = "http://192.168.1.3:32400";
	public static var plexURL:String = null;
	
	// Public Properties:
	// Private Properties:
	private static var menu:String = "";

	// Initialization:
	public static function loadData(url:String, onLoad:Function, timeout:Number):Void 
	{
		//trace("Doing PlexAPI.loadData...");
		Util.loadURL(url, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if (success)
			{
				//trace("PlexAPI.loadData Successful...");
				plexURL = PlexData.oSettings.url;
				plexURL = plexURL.substr(1, plexURL.length - 1);
				menu = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.viewGroup.toString());
				
				//trace("PlexAPI.loadData.menu : ");
				//trace(menu);
				//switch (type) 
				switch (menu)
				{
					case "" :
					case "secondary" :
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Directory");
						var dataLen:Number = xmlNodeList.length;
						//trace("xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						data.type = menu;
						//var strTemp:String = null;
							
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							var itemNode:XMLNode = null;
							url = url; //Dont know why i need to do this but url is undifind if i don't????
							for (var i:Number=0; i<dataLen; i++)
							{
								itemNode = xmlNodeList[i];
								//trace(itemNode.attributes["title"]);
								//strTemp = url + "/" + Util.trim(itemNode.attributes["key"]);
								//trace("PlexAPI.strTemp: " + strTemp);
								
								data.push
								({
									//title:Util.trim(XPathAPI.selectSingleNode(itemNode, "/").attributes.title.toString()),
									menu:menu,
									title:Util.trim(itemNode.attributes["title"]),
									index:Number(i+1),
									key:Util.trim(itemNode.attributes["key"]),
									type:Util.trim(itemNode.attributes["type"]),
									url:url + "/" + Util.trim(itemNode.attributes["key"])
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
						//trace("Doing PlexAPI.movie...");
						plexURL = PlexData.oSettings.url;
						plexURL = plexURL.substr(0, plexURL.length - 1);
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video");
						var dataLen:Number = xmlNodeList.length;
						//trace("movie.xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						data.type = menu;
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							//trace("Doing PlexAPI.movie has length...");
							var itemNode:XMLNode = null;
							//trace("Doing PlexAPI.movie for loop...");
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
									thumbURL:plexURL + "/photo/:/transcode?width="+PlexData.oWall.thumb.size+"&height="+PlexData.oWall.thumb.size+"&url=" + escape(plexURL + Util.trim(itemNode.attributes["thumb"])),
									url:plexURL + Util.trim(XPathAPI.selectSingleNode(itemNode, "Video/Media/Part").attributes.key.toString()),
									tagline:Util.trim(itemNode.attributes["tagline"]),
									ratingKey:Util.trim(itemNode.attributes["ratingKey"]),
									type:menu,
									total:dataLen
								});
							}
							//trace("Done PlexAPI.movie for loop...");
							//Debug 
							//var_dump(data);
						}
						//trace(data);
						this.onLoad(data);
						//trace("Done PlexAPI.movie...");
					break;
					case "show" :
						//trace("Doing PlexAPI.show...");
						plexURL = PlexData.oSettings.url;
						plexURL = plexURL.substr(0, plexURL.length - 1);
						var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Directory");
						var dataLen:Number = xmlNodeList.length;
						//trace("movie.xmlNodeList.length: " + dataLen);
						var data:Array = new Array();
						data.type = menu;
						var mediaTagVersion:String = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.mediaTagVersion.toString());
						
						//Debug
						//trace(xmlNodeList);
						
						if (dataLen > 0)
						{
							//trace("Doing PlexAPI.show has length...");
							var itemNode:XMLNode = null;
							//trace("Doing PlexAPI.show for loop...");
							for (var i:Number=0; i < dataLen; i++)
							{
								itemNode = xmlNodeList[i];
								data.push
								({
									
									index:Number(i+1),
									title:Util.trim(itemNode.attributes.title.toString()),
									artURL:plexURL + "/photo/:/transcode?width=1280&height=720&url=" + escape(plexURL + Util.trim(itemNode.attributes.art.toString())),
									thumbURL:plexURL + "/photo/:/transcode?width=336&height=500&url=" + escape(plexURL + Util.trim(itemNode.attributes.thumb.toString())),
									bannerURL:plexURL + Util.trim(itemNode.attributes.banner.toString()),
									studioURL:plexURL + "/system/bundle/media/flags/studio/" + Util.trim(XPathAPI.selectSingleNode(itemNode, "/Directory").attributes.studio.toString()) + "?t=" + mediaTagVersion,
									contentRatingURL:plexURL + "/system/bundle/media/flags/contentRating/" + Util.trim(XPathAPI.selectSingleNode(itemNode, "/Directory").attributes.contentRating.toString()) + "?t=" + mediaTagVersion,
									seasonURL:plexURL + Util.trim(XPathAPI.selectSingleNode(itemNode, "/Directory").attributes.key.toString()),
									key:Util.trim(itemNode.attributes["ratingKey"]),
									total:dataLen
								});
							}
							//trace("Done PlexAPI.show for loop...");
							//Debug 
							//var_dump(data);
						}
						//trace(data);
						this.onLoad(data);
						//trace("Done PlexAPI.movie...");
					break;
					case "season" :
					case "episode" :
					case "artist" :
					case "album" :
						trace("Doing PlexAPI." + menu + "...");
						plexURL = PlexData.oSettings.url;
						var data:Array = new Array();
						data.type = menu;
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
		//trace("Doing PlexAPI.loadMoveDetails...");
		Util.loadURL(url, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if (success)
			{
				//trace("PlexAPI.loadMoveDetails Successful...");
				
				//var data:Array = new Array();
				//data.push
				var mediaTagVersion:String = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.mediaTagVersion.toString());
				var data:Object = 
				{
					title:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.title.toString()),
					artURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.art.toString()),
					posterURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.thumb.toString()),
					studioURL:plexURL + "/system/bundle/media/flags/studio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.studio.toString()) + "?t=" + mediaTagVersion,
					contentRatingURL:plexURL + "/system/bundle/media/flags/contentRating/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.contentRating.toString()) + "?t=" + mediaTagVersion,
					videoResolutionURL:plexURL + "/system/bundle/media/flags/videoResolution/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.videoResolution.toString()) + "?t=" + mediaTagVersion,
					aspectRatioURL:plexURL + "/system/bundle/media/flags/aspectRatio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.aspectRatio.toString()) + "?t=" + mediaTagVersion,
					audioChannelsURL:plexURL + "/system/bundle/media/flags/audioChannels/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioChannels.toString()) + "?t=" + mediaTagVersion,
					audioCodecURL:plexURL + "/system/bundle/media/flags/audioCodec/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioCodec.toString()) + "?t=" + mediaTagVersion,
					durationMIN:int(Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media/Part").attributes.duration.toString())/60000).toString() + " minutes",
					summary:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.summary.toString()),
					rating:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.rating.toString())/10,
					videoURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media/Part").attributes.key.toString())
				};
				var dataLen:Number = null;
				var xmlNodeList:Array = null;
				//Cast
				xmlNodeList = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video/Role");
				//trace("xmlNodeList: " + xmlNodeList.join());
				//var_dump(xmlNodeList);
				dataLen = xmlNodeList.length;
				//trace("PlexAPI.loadMoveDetails.xmlNodeList.length: " + dataLen);
				var cast:Array = new Array();
				if (dataLen > 0)
				{
					var itemNode:XMLNode = null;
					for (var i:Number=0; i<dataLen; i++)
					{
						//itemNode = xmlNodeList[i];
						cast[i] = Util.trim(xmlNodeList[i].attributes.tag.toString());
					}
				}
				//trace("cast: " + cast.join());
				data.cast = cast;
				
				//Director
				xmlNodeList = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video/Director");
				//trace("xmlNodeList: " + xmlNodeList.join());
				//var_dump(xmlNodeList);
				dataLen = xmlNodeList.length;
				//trace("PlexAPI.loadMoveDetails.xmlNodeList.length: " + dataLen);
				var director:Array = new Array();
				if (dataLen > 0)
				{
					var itemNode:XMLNode = null;
					for (var i:Number=0; i<dataLen; i++)
					{
						//itemNode = xmlNodeList[i];
						director[i] = Util.trim(xmlNodeList[i].attributes.tag.toString());
					}
				}
				//trace("director: " + director.join());
				data.director = director;
				
				//Writer
				xmlNodeList = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video/Writer");
				//trace("xmlNodeList: " + xmlNodeList.join());
				//var_dump(xmlNodeList);
				dataLen = xmlNodeList.length;
				//trace("PlexAPI.loadMoveDetails.xmlNodeList.length: " + dataLen);
				var writer:Array = new Array();
				if (dataLen > 0)
				{
					var itemNode:XMLNode = null;
					for (var i:Number=0; i<dataLen; i++)
					{
						//itemNode = xmlNodeList[i];
						writer[i] = Util.trim(xmlNodeList[i].attributes.tag.toString());
					}
				}
				//trace("writer: " + writer.join());
				data.writer = writer;
				
				//Genre
				xmlNodeList = XPathAPI.selectNodeList(xml.firstChild, "/MediaContainer/Video/Genre");
				//trace("xmlNodeList: " + xmlNodeList.join());
				//var_dump(xmlNodeList);
				dataLen = xmlNodeList.length;
				//trace("PlexAPI.loadMoveDetails.xmlNodeList.length: " + dataLen);
				var genre:Array = new Array();
				if (dataLen > 0)
				{
					var itemNode:XMLNode = null;
					for (var i:Number=0; i<dataLen; i++)
					{
						//itemNode = xmlNodeList[i];
						genre[i] = Util.trim(xmlNodeList[i].attributes.tag.toString());
					}
				}
				//trace("genre: " + genre.join(" | "));
				data.genre = genre;
				
				
				this.onLoad(data);
				//trace("Done PlexAPI.loadMoveDetails...");
			}
			else
			{
				this.onLoad(null);
			}
		}), {target:"xml", timeout:timeout});
	}
																
	public static function loadShowDetails(url:String, onLoad:Function, timeout:Number):Void 
	{
		//trace("Doing PlexAPI.loadMoveDetails...");
		Util.loadURL(url, Delegate.create({onLoad:onLoad}, function(success:Boolean, xml:XML, o:Object):Void
		{
			if (success)
			{
				//trace("PlexAPI.loadMoveDetails Successful...");
				
				//var data:Array = new Array();
				//data.push
				var mediaTagVersion:String = Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer").attributes.mediaTagVersion.toString());
				var data:Object = 
				{
					/*title:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.title.toString()),
					artURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.art.toString()),
					posterURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.thumb.toString()),
					studioURL:plexURL + "/system/bundle/media/flags/studio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.studio.toString()) + "?t=" + mediaTagVersion,
					contentRatingURL:plexURL + "/system/bundle/media/flags/contentRating/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.contentRating.toString()) + "?t=" + mediaTagVersion,
					videoResolutionURL:plexURL + "/system/bundle/media/flags/videoResolution/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.videoResolution.toString()) + "?t=" + mediaTagVersion,
					aspectRatioURL:plexURL + "/system/bundle/media/flags/aspectRatio/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.aspectRatio.toString()) + "?t=" + mediaTagVersion,
					audioChannelsURL:plexURL + "/system/bundle/media/flags/audioChannels/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioChannels.toString()) + "?t=" + mediaTagVersion,
					audioCodecURL:plexURL + "/system/bundle/media/flags/audioCodec/" + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media").attributes.audioCodec.toString()) + "?t=" + mediaTagVersion,
					durationMIN:int(Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media/Part").attributes.duration.toString())/60000).toString() + " minutes",
					summary:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.summary.toString()),
					rating:Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video").attributes.rating.toString())/10,
					videoURL:plexURL + Util.trim(XPathAPI.selectSingleNode(xml.firstChild, "/MediaContainer/Video/Media/Part").attributes.key.toString())*/
				}
				
			}
		}), {target:"xml", timeout:timeout});
	}
	private function var_dump(_obj:Object)
	{
		//trace("Doing var_dump...");
		trace(_obj);
		//trace("Looping Through _obj...");
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