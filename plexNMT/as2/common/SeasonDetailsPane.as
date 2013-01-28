import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.SmallCaps;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.GlowFilterPlugin;

import mx.utils.Delegate;

class plexNMT.as2.common.SeasonDetailsPane {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.SeasonDetailsPane;

	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var seasonDetailsMC:MovieClip = null;
	//detailData
	
	//TextFields
	private var scTitle:SmallCaps = null;
	private var scRunTime:SmallCaps = null;
	private var scWatchTime:SmallCaps = null;
	private var scYear:SmallCaps = null;
	
	//Image MovieClips
	private var ratingMC:MovieClip = null;

	// Initialization:
	public function SeasonDetailsPane(parentMC:MovieClip) {
		D.debug(D.lDev, "SeasonDetailsPane - parentMC:" + parentMC);
		seasonDetailsMC = parentMC.createEmptyMovieClip("seasonDetailsMC", parentMC.getNextHighestDepth()); //,{_x:10, _y:600});
		seasonDetailsMC._x = 414;
		seasonDetailsMC._y = 126;
		
		buildDetails(seasonDetailsMC);
		
		current = 0;
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		return;
	}

	// Public Methods:
	public function setText(_title:String, _year:String, _tagline):Void 
	{
		this.seasonDetailsMC._title.text = _title;
		this.seasonDetailsMC._year.text = _year;
		this.seasonDetailsMC._tagline.text = _tagline;
	}
	
	public function setSeasonText(str:String)
	{
		this.seasonDetailsMC._season.text = str;
	}
	
	public function setEpisodeText(str:String)
	{
		this.seasonDetailsMC._episode.text = str;
	}
	
	public function setEpisodeTitleText(str:String)
	{
		this.seasonDetailsMC._episodeTitle.text = str;
	}
	
	public function setSummaryText(str:String)
	{
		this.seasonDetailsMC._summary.text = str;
	}
	
	public function _select()
	{
		//TweenLite.to(this.seasonDetailsMC, 1.4, {glowFilter:{color:0x0000ff, alpha:1, blurX:15, blurY:15}});
	}
	
	public function _unselect()
	{
		//TweenLite.to(this.seasonDetailsMC, 1.4, {glowFilter:{remove:true}});
	}
	
	public function _update():Void 
	{	
		var _season:Array = new Array();
		var _wall:Array = new Array();
		_wall = PlexData.oWallData._children[PlexData.oWallData.intPos];
		_season = PlexData.oSeasonData._children[PlexData.oSeasonData.intPos];
		//D.debug(D.lDev, Utils.varDump(_data));
		
		//Title
		this.seasonDetailsMC._title.text = _wall.title;
		//Year
		this.seasonDetailsMC._year.text = _wall.year;
		//Rating
		if (_wall.rating != undefined &&  _wall.rating != 0){
			TweenLite.to(this.seasonDetailsMC.ratingMC.ratingMask, 0.7, {_width:(128 * _wall.rating / 10)});
		} else {
			TweenLite.to(this.seasonDetailsMC.ratingMC.ratingMask, 0.7, {_width:0});
		}
		var prefix:String = PlexData.oWallData.mediaTagPrefix;
		var version:String = PlexData.oWallData.mediaTagVersion;
		//Studio Flag
		D.debug(D.lDev, "Wall Details - Calling PlexAPI.getImg...");
		var url:String = PlexAPI.getImg({width:200,
									  height:80,
									  key:prefix + "studio/" + _wall.studio + "?t=" + version});
		UI.loadImage(url, this.seasonDetailsMC.fStudio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"studio"});
		//Content Rating Flag
		var ratingURL:String = PlexAPI.getImg({width:40,
									  height:40,
									  key:prefix + "contentRating/" + _wall.contentRating + "?t=" + version});
		UI.loadImage(ratingURL, this.seasonDetailsMC.fRating, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"rating"});
		//Aspect Ratio Flag
		var ratioURL:String = PlexAPI.getImg({width:30,
									  height:30,
									  key:prefix + "aspectRatio/" + _wall._children.aspectRatio + "?t=" + version});
		UI.loadImage(ratioURL, this.seasonDetailsMC.fRatio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"ratio"});
		//Video Resolution Flag
		var resolutionURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "videoResolution/" + _wall._children.videoResolution + "?t=" + version});
		UI.loadImage(resolutionURL, this.seasonDetailsMC.fResolution, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"resolution"});
		//Video Codec Flag
		var videoCodecURL:String = PlexAPI.getImg({width:100,
									  height:60,
									  key:prefix + "videoCodec/" + _wall._children.videoCodec + "?t=" + version});
		UI.loadImage(videoCodecURL, this.seasonDetailsMC.fVideoCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"videoCodec"});
		//Audio Channels Flags
		var channelsURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "audioChannels/" + _wall._children.audioChannels + "?t=" + version});
		UI.loadImage(channelsURL, this.seasonDetailsMC.fChannels, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"channels"});
		//Audio Codec Flag
		var audioCodecURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "audioCodec/" + _wall._children.audioCodec + "?t=" + version});
		UI.loadImage(audioCodecURL, this.seasonDetailsMC.fAudioCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"audioCodec"});
		//Times
		this.seasonDetailsMC._runTime.text = "Running Time: " + Utils.formatTime( _wall.duration);
		if (_wall.viewOffset != undefined) {
			this.seasonDetailsMC._watchTime.text = "Watched Time: " + Utils.formatTime( _wall.viewOffset);
		} else {
			this.seasonDetailsMC._watchTime.text = "Watched: 0hrs 0mins";
		}
		//Summary
		this.seasonDetailsMC._summary.text = _wall.summary;
		
		var etLen:Number = _season._children.length;
		var eType:String = "";
		var genre:String = "Genre: ";
		var writer:String = "Writer: ";
		var director:String = "Director: ";
		var country:String = "Country: ";
		var role:String = "Cast: ";
		for (var et = 0; et < etLen; et++)
		{
			eType = _season._children[et]._elementType.toLowerCase();
			switch (eType)
			{
				case "genre": 
					//Genre
					genre += _season._children[et].tag + " | ";
				break;
				case "writer": 
					writer += _season._children[et].tag + " | ";
				break;
				case "director": 
					director += _season._children[et].tag + " | ";
				break;
				case "country": 
					country += _season._children[et].tag + " | ";
				break;
				case "role": 
					role += _season._children[et].tag + " | ";
				break;
			}
		}
		//Writer
		this.seasonDetailsMC._writer.text = writer.substr(0, (writer.length - 3));
		//Director
		this.seasonDetailsMC._director.text = director.substr(0, (director.length - 3));
		//Cast
		this.seasonDetailsMC._cast.text = role.substr(0, (role.length - 3));
		//Genre
		this.seasonDetailsMC._genre.text = genre.substr(0, (genre.length - 3));
		//Align
		UI.align([
				  {symbol:this.seasonDetailsMC._genre},
				  {symbol:this.seasonDetailsMC._runTime},
				  {symbol:this.seasonDetailsMC._watchTime}],
				 {halign:"left", valign:"top", layout:"vertical", gap:0, width:620, height:108, y:290, x:10}); //10, 366
				//left, right, center
	}


	public function destroy():Void {
		Utils.cleanUp(this.seasonDetailsMC);
		this.seasonDetailsMC.removeMovieClip();
		delete seasonDetailsMC.removeMovieClip();
	}
	// Private Methods:
	private function onFlagLoad(success:Boolean, o:Object)
	{
		//D.debug(D.lDev, "SeasonDetailsPane - Doing onFlagLoad with:" + o.o.flag);
		//D.debug(D.lDev, "this.seasonDetailsMC._width:" + this.seasonDetailsMC._width);
		var flag:String = o.o.flag;
		if (flag != undefined)
		{
			switch (flag)
			{
				case "studio":
					this.seasonDetailsMC.fStudio._x = 608 - this.seasonDetailsMC.fStudio._width;
					this.seasonDetailsMC.fStudio._y = 300 //495 - (this.seasonDetailsMC.fStudio._height);
				break;
				case "rating":
					this.seasonDetailsMC.fRating._x = 488 //650 - this.seasonDetailsMC.fRating._width;
					this.seasonDetailsMC.fRating._y = 33 //37;
				break;
				case "ratio":
					this.seasonDetailsMC.fRatio._x = 10;
					this.seasonDetailsMC.fRatio._y = 495 - (this.seasonDetailsMC.fRatio._height);
				break;
				case "resolution":
					this.seasonDetailsMC.fResolution._x = 5 + this.seasonDetailsMC.fRatio._x + this.seasonDetailsMC.fRatio._width;
					this.seasonDetailsMC.fResolution._y = 495 - this.seasonDetailsMC.fResolution._height;
				break;
				case "videoCodec":
					this.seasonDetailsMC.fVideoCodec._x = 5 + this.seasonDetailsMC.fResolution._x + this.seasonDetailsMC.fResolution._width;
					this.seasonDetailsMC.fVideoCodec._y = 495 - this.seasonDetailsMC.fVideoCodec._height;
				break;
				case "channels":
					this.seasonDetailsMC.fChannels._x = 5 + this.seasonDetailsMC.fVideoCodec._x + this.seasonDetailsMC.fVideoCodec._width;
					this.seasonDetailsMC.fChannels._y = 495 - this.seasonDetailsMC.fChannels._height;
				break;
				case "audioCodec":
					this.seasonDetailsMC.fAudioCodec._x = 5 + this.seasonDetailsMC.fChannels._x + this.seasonDetailsMC.fChannels._width;
					this.seasonDetailsMC.fAudioCodec._y = 495 - this.seasonDetailsMC.fAudioCodec._height;
				break;
				default :
					D.debug(D.lDev, "WallDetails - Default switch...");
				break;
			}
		}
		UI.align([
				  //{symbol:this.seasonDetailsMC.fRating},
				  {symbol:this.seasonDetailsMC.fRatio},
				  {symbol:this.seasonDetailsMC.fResolution},
				  {symbol:this.seasonDetailsMC.fVideoCodec},
				  {symbol:this.seasonDetailsMC.fChannels},
				  {symbol:this.seasonDetailsMC.fAudioCodec}],
				  //{symbol:this.seasonDetailsMC.fStudio}],
				 {halign:"left", valign:"middle", gap:5, width:400, y:115, x:10})
	}
	
	private function buildDetails(mc:MovieClip)
	{	
		var _data:Array = new Array();
		_data = PlexData.oSeasonData._children;

		//background
		drawRoundedRectangle(mc, 618, 405, 30, 0x000000, 80, 2, 0xCCCCCC, 40);
		//Studio Flag
		mc.createEmptyMovieClip("fStudio", mc.getNextHighestDepth());
		//Content Rating Flag
		mc.createEmptyMovieClip("fRating", mc.getNextHighestDepth());
		//Aspect Ratio Flag
		mc.createEmptyMovieClip("fRatio", mc.getNextHighestDepth());
		//Video Resolution Flag
		mc.createEmptyMovieClip("fResolution", mc.getNextHighestDepth());
		//Video Codec Flag
		mc.createEmptyMovieClip("fVideoCodec", mc.getNextHighestDepth());
		//Audio Channels Flags
		mc.createEmptyMovieClip("fChannels", mc.getNextHighestDepth());
		//Audio Codec Flag
		mc.createEmptyMovieClip("fAudioCodec", mc.getNextHighestDepth());
		//Rating
		mc.createEmptyMovieClip("ratingMC", mc.getNextHighestDepth());
		mc.ratingMC._y = 8;
		mc.ratingMC._x = this.seasonDetailsMC._width - 140;
		mc.ratingMC.attachMovie("rating_0", "rating_0", mc.ratingMC.getNextHighestDepth()); 		//background
		mc.ratingMC.attachMovie("rating_100", "rating_100", mc.ratingMC.getNextHighestDepth()); 	//overlay
		mc.ratingMC.createEmptyMovieClip("ratingMask", mc.ratingMC.getNextHighestDepth()); 			//crop/mask of overlay
		with(mc.ratingMC.ratingMask)
		{
			moveTo(0,0);
			beginFill(0x000088)
			lineTo(128,0);
			lineTo(128,24);
			lineTo(0,24);
			endFill();
		}
		mc.ratingMC.rating_100.setMask(mc.ratingMC.ratingMask);
		//Text Format
		var myFormat:TextFormat = new TextFormat();
		myFormat.align = "left";
		myFormat.font = "Arial";
		myFormat.color = 0xFFFFFF;
		//Title
		mc.createTextField("_title", mc.getNextHighestDepth(), 10, 5, 520, 60);
		//mc._title.autoSize = true;
		myFormat.size = 28;
		mc._title.setNewTextFormat(myFormat);
		/*scTitle = new SmallCaps(mc._title, 19, 24);
		scTitle.text = "Title";*/
		//Summary
		mc.createTextField("_summary", mc.getNextHighestDepth(), 25, 77, 580, 220);
		//mc._summary.autoSize = "left";
		mc._summary.multiline = true;
		mc._summary.wordWrap = true;
		myFormat.size = 18;
		mc._summary.setNewTextFormat(myFormat);
		mc._summary.text = "Summary Text";
		//Writer
		/*mc.createTextField("_writer", mc.getNextHighestDepth(), 10, 366, 150, 15);
		mc._writer.autoSize = true; 
		myFormat.size = 16;
		mc._writer.setNewTextFormat(myFormat);
		mc._writer.text = "Writer: ";
		//Director:
		mc.createTextField("_director", mc.getNextHighestDepth(), 10, 383, 150, 15);
		mc._director.autoSize = true; 
		myFormat.size = 16;
		mc._director.setNewTextFormat(myFormat);
		mc._director.text = "Director: ";
		//Cast:
		mc.createTextField("_cast", mc.getNextHighestDepth(), 10, 399, 620, 40);
		//mc._cast.autoSize = true; 
		mc._cast.multiline = true;
		mc._cast.wordWrap = true;
		myFormat.size = 16;
		mc._cast.setNewTextFormat(myFormat);
		mc._cast.text = "Cast: ";*/
		//Genre:
		mc.createTextField("_genre", mc.getNextHighestDepth(), 10, 399, 620, 40);
		//mc._genre.autoSize = true; 
		mc._genre.multiline = true;
		mc._genre.wordWrap = true;
		mc._genre.setNewTextFormat(myFormat);
		mc._genre.text = "Genre: ";
		//Running Time
		mc.createTextField("_runTime", mc.getNextHighestDepth(), 24, 353, 150, 15);
		mc._runTime.autoSize = true;
		//mc._runTime._visible = false;
		
		mc._runTime.setNewTextFormat(myFormat);
		/*scRunTime = new SmallCaps(mc._runTime, 14, 18);*/
		mc._runTime.text = "Running Time: 0hrs 0mins"
		//mc._runTime._x = (mc._width/2) - (mc._runTime._width/2);
		//Watched Time
		mc.createTextField("_watchTime", mc.getNextHighestDepth(), 10, 431, 150, 15);
		mc._watchTime.autoSize = true; 
		//mc._watchTime._visible = false;
		mc._watchTime.setNewTextFormat(myFormat);
		mc._watchTime.text = "Watched: 0hrs 0mins";
		/*scWatchTime = new SmallCaps(mc._watchTime, 14,18);
		scWatchTime.text = ""*/
		//mc._watchTime._x = (mc._width/2) - (mc._watchTime._width/2);
		//Year
		mc.createTextField("_year", mc.getNextHighestDepth(), 540, 32, 90, 20);//522, 30, 150, 15);
		mc._year.autoSize = true;
		myFormat.size = 28;
		mc._year.setNewTextFormat(myFormat);
		//Tag Line
		/*mc.createTextField("_tagline", mc.getNextHighestDepth(), 10, 40, 520, 25);
		//mc._tagline.autoSize = true;
		myFormat.size = 18;
		mc._tagline.setNewTextFormat(myFormat);*/
		//Season
		mc.createTextField("_season", mc.getNextHighestDepth(), 10, 35, 90, 20);
		mc._season.autoSize = true;
		myFormat.size = 18;
		mc._season.setNewTextFormat(myFormat);
		mc._season.text = "Season 00"
		//Episode
		mc.createTextField("_episode", mc.getNextHighestDepth(), 100, 35, 90, 20);
		mc._episode.autoSize = true;
		myFormat.size = 18;
		mc._episode.setNewTextFormat(myFormat);
		mc._episode.text = "Episode 00"
		//Episode Title
		mc.createTextField("_episodeTitle", mc.getNextHighestDepth(), 10, 55, 90, 20);
		mc._episodeTitle.autoSize = true;
		myFormat.size = 18;
		mc._episodeTitle.setNewTextFormat(myFormat);
		mc._episodeTitle.text = "Episode Title"
		
		this.setText(_data._children[0].title, _data._children[0].year, _data._children[0].tagline);
		this._update();
		
		
	}
	private function drawRoundedRectangle(mc:MovieClip, 
										  rectWidth:Number, 
										  rectHeight:Number, 
										  cornerRadius:Number, 
										  fillColor:Number, 
										  fillAlpha:Number, 
										  lineThickness:Number, 
										  lineColor:Number, 
										  lineAlpha:Number) {
	
		with (mc) {
			beginFill(fillColor,fillAlpha);
			lineStyle(lineThickness,lineColor,lineAlpha);
			moveTo(cornerRadius,0);
			lineTo(rectWidth-cornerRadius,0);
			curveTo(rectWidth,0,rectWidth,cornerRadius);
			lineTo(rectWidth,cornerRadius);
			lineTo(rectWidth,rectHeight-cornerRadius);
			curveTo(rectWidth,rectHeight,rectWidth-cornerRadius,rectHeight);
			lineTo(rectWidth-cornerRadius,rectHeight);
			lineTo(cornerRadius,rectHeight);
			curveTo(0,rectHeight,0,rectHeight-cornerRadius);
			lineTo(0,rectHeight-cornerRadius);
			lineTo(0,cornerRadius);
			curveTo(0,0,cornerRadius,0);
			lineTo(cornerRadius,0);
			endFill();
		}
	}

}