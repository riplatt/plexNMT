import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.D;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.Utils;

class plexNMT.as2.pages.MovieDetails
{
	public static var plexURL:String = PlexData.oSettings.url;
	public static var plexRatingKey:String = null;
	
	private var parentMC:MovieClip = null;
	private var backdropMC:MovieClip = null;
	private var bgOverlayMC:MovieClip = null;
	private var posterMC:MovieClip = null;
	private var titleMC:MovieClip = null;
	private var ratingMC:MovieClip = null;
	private var minMC:MovieClip = null;
	private var studioMC:MovieClip = null;
	private var contentRatingMC:MovieClip = null;
	private var videoResolutionMC:MovieClip = null;
	private var aspectRatioMC:MovieClip = null;
	private var audioChannelsMC:MovieClip = null;
	private var audioCodecMC:MovieClip = null;
	private var summaryMC:MovieClip = null;
	private var castMC:MovieClip = null;
	private var directorMC:MovieClip = null;
	private var writerMC:MovieClip = null;
	private var preloadMC:MovieClip = null;
	
	private var onLoadResize:Object = null;
	
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	
	private var title:String = null;
	private var videoURL:String = null;
	
	//var listenerObj:Object = new Object();
	
	// Destroy all global variables.
	public function destroy():Void
	{
		cleanUp(this.parentMC);
				
		this.title = null;
		this.videoURL = null;
		
		delete this.onLoadResize;
		this.onLoadResize = null;
		
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;

	}
	
	public function MovieDetails(parentMC:MovieClip)
	{
		trace("Doing plexNMT.movieDetails...");
		
		plexRatingKey = _level0.plex.currentRatingKey;

		this.parentMC = parentMC;

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		this.preloadMC = this.parentMC.attachMovie("busy", "busy", parentMC.getNextHighestDepth(), {_x:640, _y:360, _width:200, _height:200});
		
		var key:String = PlexData.oWallData.MediaContainer[0].Video[PlexData.oWallData.intPos].attributes.key
		trace("oWallData.intPos: " + PlexData.oWallData.intPos);
		//trace("Calling getMovieData With: " + key);
		trace("Calling getMovieData With: " + key);
		PlexAPI.getMovieData(key, Delegate.create(this, this.onDataLoad), 5000);
	}

	private function onDataLoad(data:Object):Void
	{
			trace("Doing moveieDetails.parseXML.data: ");
			//var_dump(data);
			
			this.enableKeyListener();
			
			this.title = PlexData.oMovieData.MediaContainer[0].Video[0].attributes.title//data.title;
			//this.videoURL = data.videoURL;
			
			//Background
			var artURL:String = PlexData.oSettings.url + "/photo/:/transcode?width=1280&height=720&url=" + escape(PlexData.oSettings.url + PlexData.oMovieData.MediaContainer[0].Video[0].attributes.art)
			UI.loadImage(artURL, this.parentMC, "backdropMC", {mcProps:{_x:0, _y:0, _width:1280, _height:720}, lmcId:"busy", lmcProps:{_x:640, _y:360, _width:200, _height:200}});			
			
			this.bgOverlayMC = this.parentMC.attachMovie("bgOverlay", "bgOverlayMC", parentMC.getNextHighestDepth());
			backdropMC.setMask(bgOverlayMC);
			
			//Poster
			var posterURL:String = PlexData.oSettings.url + "/photo/:/transcode?width=402&height=595&url=" + escape(PlexData.oSettings.url + PlexData.oMovieData.MediaContainer[0].Video[0].attributes.thumb)
			UI.loadImage(posterURL, this.parentMC, "posterMC", {mcProps:{_x:0, _y:0, _width:486, _height:720}, lmcId:"busy", lmcProps:{_x:173, _y:290, _width:140, _height:140}});	

			//Title
			//trace("title: " + data.title);
			this.titleMC = this.parentMC.createEmptyMovieClip("titleMC", parentMC.getNextHighestDepth());
			titleMC.createTextField("title_txt", titleMC.getNextHighestDepth(), 0, 0, 900, 50);
			titleMC._y = 25;
			titleMC._x = 520;
			
			var txtFormat:TextFormat = new TextFormat ();
			txtFormat.font = "Arial";
			txtFormat.size = 40;
			txtFormat.color = 0xFFFFFF;
			titleMC.title_txt.htmlText = PlexData.oMovieData.MediaContainer[0].Video[0].attributes.title; //data.title;
			titleMC.title_txt.setTextFormat(txtFormat);	
			
			//Rating
			//trace("data.rating: " + data.rating);
			this.ratingMC = this.parentMC.createEmptyMovieClip("ratingMC", parentMC.getNextHighestDepth());
			ratingMC._y = 80;
			ratingMC._x = 522;
			var rating:Number = 128 * int(PlexData.oMovieData.MediaContainer[0].Video[0].attributes.rating) / 10 //data.rating;
			trace("rating: " + rating);
			ratingMC.attachMovie("rating_0", "rating_0", ratingMC.getNextHighestDepth()); 		//background
			ratingMC.attachMovie("rating_100", "rating_100", ratingMC.getNextHighestDepth()); 	//overlay
			ratingMC.createEmptyMovieClip("ratingMask", ratingMC.getNextHighestDepth()); 		//crop/mask of overlay
			with(ratingMC.ratingMask)
			{
				moveTo(0,0);
				beginFill(0x000088)
				lineTo(rating,0);
				lineTo(rating,24);
				lineTo(0,24);
				endFill();
			}
			ratingMC.rating_100.setMask(ratingMC.ratingMask);
			
			//Duration
			//trace("durationMIN: " + data.durationMIN);
			this.minMC = this.parentMC.createEmptyMovieClip("minMC", parentMC.getNextHighestDepth());
			minMC.createTextField("min_txt", minMC.getNextHighestDepth(), 0, 0, 900, 50);
			minMC._y = 79;
			minMC._x = 652;
			var minFormat:TextFormat = new TextFormat ();
			minFormat.font = "Arial";
			minFormat.size = 20;
			minFormat.color = 0xFFFFFF;
			minMC.min_txt.htmlText = Utils.formatTime(int(PlexData.oMovieData.MediaContainer[0].Video[0].Media[0].attributes.duration)); //data.durationMIN;
			minMC.min_txt.setTextFormat(minFormat);			
			
			//Studio
			//trace("studioURL: " + data.studioURL);
			var studioURL:String = "";
			UI.loadImage(studioURL, this.parentMC, "studioMC", {mcProps:{_x:520, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:550, _y:130, _width:40, _height:40}});
			//var_dump(studioMC);
			
			//Content Rating
			//trace("contentRatingURL: " + data.contentRatingURL);
			UI.loadImage(data.contentRatingURL, this.parentMC, "contentRatingMC", {mcProps:{_x:624, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:654, _y:130, _width:40, _height:40}});
			
			//Video Resolution
			//trace("videoResolutionURL: " + data.videoResolutionURL);
			UI.loadImage(data.videoResolutionURL, this.parentMC, "videoResolutionMC", {mcProps:{_x:728, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:758, _y:130, _width:40, _height:40}});
			
			//Aspect Ratio
			//trace("aspectRatioURL: " + data.aspectRatioURL);
			UI.loadImage(data.aspectRatioURL, this.parentMC, "aspectRatioMC", {mcProps:{_x:832, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:832, _y:130, _width:40, _height:40}});
			
			//Audio Codec
			//trace("audioCodecURL: " + data.audioCodecURL);
			UI.loadImage(data.audioCodecURL, this.parentMC, "audioCodecMC", {mcProps:{_x:936, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:966, _y:130, _width:40, _height:40}});
			
			//Audio Channels
			//trace("audioChannelsURL: " + data.audioChannelsURL);
			UI.loadImage(data.audioChannelsURL, this.parentMC, "audioChannelsMC", {mcProps:{_x:1040, _y:125, _width:100, _height:45}, lmcId:"preload40", lmcProps:{_x:1070, _y:130, _width:40, _height:40}});
			
			//Summary
			//trace("summary: " + data.summary);
			this.summaryMC = this.parentMC.createEmptyMovieClip("summaryMC", parentMC.getNextHighestDepth());
			summaryMC.createTextField("summary_txt", summaryMC.getNextHighestDepth(), 0, 0, 735, 250);
			summaryMC._y = 178;
			summaryMC._x = 520;
			summaryMC.summary_txt.multiline = true;
			summaryMC.summary_txt.wordWrap = true;
			var sumFormat:TextFormat = new TextFormat ();
			sumFormat.font = "Arial";
			sumFormat.size = 18;
			sumFormat.color = 0xFFFFFF;
			summaryMC.summary_txt.htmlText = PlexData.oMovieData.MediaContainer[0].Video[0].attributes.summary //.data.summary;
			summaryMC.summary_txt.setTextFormat(sumFormat);
			
			//Cast
			//trace("cast: " + data.cast);
			this.castMC = this.parentMC.createEmptyMovieClip("castMC", parentMC.getNextHighestDepth());
			castMC._y = 425;
			castMC._x = 520;
			castMC.createTextField("cast_title_txt", castMC.getNextHighestDepth(), 0, 0, 200, 500);
			castMC.createTextField("cast_txt", castMC.getNextHighestDepth(), 0, 22, 250, 205);
			castMC.cast_txt.multiline = true;
			castMC.cast_txt.wordWrap = true;
			var castTitleFormat:TextFormat = new TextFormat ();
			castTitleFormat.font = "Arial";
			castTitleFormat.size = 19;
			castTitleFormat.color = 0xFFCC00;
			castMC.cast_title_txt.htmlText = "Cast:"
			castMC.cast_title_txt.setTextFormat(castTitleFormat);
			
			var castFormat:TextFormat = new TextFormat ();
			castFormat.font = "Arial";
			castFormat.size = 18;
			castFormat.color = 0xFFFFFF;
			castMC.cast_txt.htmlText = data.cast.join("\n");
			castMC.cast_txt.setTextFormat(castFormat);
			
			//Director
			//trace("director: " + data.director);
			this.directorMC = this.parentMC.createEmptyMovieClip("directorMC", parentMC.getNextHighestDepth());
			directorMC._y = 425;
			directorMC._x = 770;
			directorMC.createTextField("director_title_txt", directorMC.getNextHighestDepth(), 0, 0, 200, 500);
			directorMC.createTextField("director_txt", directorMC.getNextHighestDepth(), 0, 22, 250, 205);
			directorMC.director_txt.multiline = true;
			directorMC.director_txt.wordWrap = true;
			var directorTitleFormat:TextFormat = new TextFormat ();
			directorTitleFormat.font = "Arial";
			directorTitleFormat.size = 19;
			directorTitleFormat.color = 0xFFCC00;
			directorMC.director_title_txt.htmlText = "Director:"
			directorMC.director_title_txt.setTextFormat(directorTitleFormat);
			
			var directorFormat:TextFormat = new TextFormat ();
			directorFormat.font = "Arial";
			directorFormat.size = 18;
			directorFormat.color = 0xFFFFFF;
			directorMC.director_txt.htmlText = data.director.join("\n");
			directorMC.director_txt.setTextFormat(directorFormat);
			
			//Writer
			//trace("writer: " + data.writer);
			this.writerMC = this.parentMC.createEmptyMovieClip("writerMC", parentMC.getNextHighestDepth());
			writerMC._y = 425;
			writerMC._x = 1020;
			writerMC.createTextField("writer_title_txt", writerMC.getNextHighestDepth(), 0, 0, 200, 500);
			writerMC.createTextField("writer_txt", writerMC.getNextHighestDepth(), 0, 22, 250, 205);
			writerMC.writer_txt.multiline = true;
			writerMC.writer_txt.wordWrap = true;
			var writerTitleFormat:TextFormat = new TextFormat ();
			writerTitleFormat.font = "Arial";
			writerTitleFormat.size = 19;
			writerTitleFormat.color = 0xFFCC00;
			writerMC.writer_title_txt.htmlText = "Writer:"
			writerMC.writer_title_txt.setTextFormat(writerTitleFormat);
			
			var writerFormat:TextFormat = new TextFormat ();
			writerFormat.font = "Arial";
			writerFormat.size = 18;
			writerFormat.color = 0xFFFFFF;
			writerMC.writer_txt.htmlText = data.writer.join("\n");
			writerMC.writer_txt.setTextFormat(writerFormat);
			
			this.preloadMC.removeMovieClip();
			delete this.preloadMC;
			this.preloadMC = null;
	}
	
	private function enableKeyListener():Void
	{
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
			case Remote.HOME:
				this.destroy();
				gotoAndPlay("main");
			break;
			case Remote.PLAY:
				//this.disableKeyListener();
				Util.loadURL("http://127.0.0.1:8008/playback?arg0=start_vod&arg1=" + this.title + "&arg2=" + this.videoURL + "&arg3=show&arg4=0&arg5=" + PlexData.oSettings.buffer + "&arg6=enable"); // Direct Play.
			break;
		}
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
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
	
	private function var_dump(_obj:Object)
	{
		//trace("Doing var_dump...");
		//trace(_obj);
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