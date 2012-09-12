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

class plexNMT.as2.common.MovieDetailsPane {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.MovieDetailsPane;

	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var movieDetailsMC:MovieClip = null;
	//detailData
	
	//TextFields
	private var scTitle:SmallCaps = null;
	private var scRunTime:SmallCaps = null;
	private var scWatchTime:SmallCaps = null;
	private var scYear:SmallCaps = null;
	
	//Image MovieClips
	private var ratingMC:MovieClip = null;

	// Initialization:
	public function MovieDetailsPane(parentMC:MovieClip) {
		trace("MovieDetailsPane - parentMC:" + parentMC);
		//Utils.varDump(this.parentMC);
		trace("MovieDetailsPane - Adding new Details Box...");
		movieDetailsMC = parentMC.createEmptyMovieClip("movieDetailsMC", parentMC.getNextHighestDepth()); //,{_x:10, _y:600});
		//trace("WallDetails - Calling draw...");
		movieDetailsMC._x = 480 //, 50);
		movieDetailsMC._y = 126;
		buildDetails(movieDetailsMC);
		
		current = 0;
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([GlowFilterPlugin, AutoAlphaPlugin]);
		
		return;
	}

	// Public Methods:
	public function setText(_title:String, _year:String, _tagline):Void 
	{
		this.movieDetailsMC._title.text = _title;
		this.movieDetailsMC._year.text = _year;
		this.movieDetailsMC._tagline.text = _tagline;
	}
	
	public function _select()
	{
		//TweenLite.to(this.movieDetailsMC, 1.4, {glowFilter:{color:0x0000ff, alpha:1, blurX:15, blurY:15}});
	}
	
	public function _unselect()
	{
		//TweenLite.to(this.movieDetailsMC, 1.4, {glowFilter:{remove:true}});
	}
	
	public function _update():Void 
	{	
		var _data:Array = new Array();
		_data = PlexData.oMovieData.MediaContainer[0];
		//D.debug(D.lDev, Utils.varDump(_data));

		//Rating
		if (_data.Video[0].attributes.rating != undefined &&  _data.Video[0].attributes.rating != 0){
			TweenLite.to(this.movieDetailsMC.ratingMC.ratingMask, 0.7, {_width:(128 * _data.Video[0].attributes.rating / 10)});
		} else {
			TweenLite.to(this.movieDetailsMC.ratingMC.ratingMask, 0.7, {_width:0});
		}
		var prefix:String = _data.attributes.mediaTagPrefix;
		var version:String = _data.attributes.mediaTagVersion;
		//Studio Flag
		trace("Wall Details - Calling PlexAPI.getImg...");
		var url:String = PlexAPI.getImg({width:200,
									  height:80,
									  key:prefix + "studio/" + _data.Video[0].attributes.studio + "?t=" + version});
		UI.loadImage(url, this.movieDetailsMC.fStudio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"studio"});
		//Content Rating Flag
		var ratingURL:String = PlexAPI.getImg({width:50,
									  height:50,
									  key:prefix + "contentRating/" + _data.Video[0].attributes.contentRating + "?t=" + version});
		UI.loadImage(ratingURL, this.movieDetailsMC.fRating, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"rating"});
		//Aspect Ratio Flag
		var ratioURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "aspectRatio/" + _data.Video[0].Media[0].attributes.aspectRatio + "?t=" + version});
		UI.loadImage(ratioURL, this.movieDetailsMC.fRatio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"ratio"});
		//Video Resolution Flag
		var resolutionURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "videoResolution/" + _data.Video[0].Media[0].attributes.videoResolution + "?t=" + version});
		UI.loadImage(resolutionURL, this.movieDetailsMC.fResolution, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"resolution"});
		//Video Codec Flag
		var videoCodecURL:String = PlexAPI.getImg({width:100,
									  height:60,
									  key:prefix + "videoCodec/" + _data.Video[0].Media[0].attributes.videoCodec + "?t=" + version});
		UI.loadImage(videoCodecURL, this.movieDetailsMC.fVideoCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"videoCodec"});
		//Audio Channels Flags
		var channelsURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "audioChannels/" + _data.Video[0].Media[0].attributes.audioChannels + "?t=" + version});
		UI.loadImage(channelsURL, this.movieDetailsMC.fChannels, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"channels"});
		//Audio Codec Flag
		var audioCodecURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:prefix + "audioCodec/" + _data.Video[0].Media[0].attributes.audioCodec + "?t=" + version});
		UI.loadImage(audioCodecURL, this.movieDetailsMC.fAudioCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"audioCodec"});
		//Times
		this.movieDetailsMC._runTime.text = "Running Time: " + Utils.formatTime( _data.Video[0].attributes.duration);
		if (_data.Video[0].attributes.viewOffset != undefined) {
			this.movieDetailsMC._watchTime.text = "Watched Time: " + Utils.formatTime( _data.Video[0].attributes.viewOffset);
		} else {
			this.movieDetailsMC._watchTime.text = "Watched: 0hrs 0mins";
		}
		//Summary
		this.movieDetailsMC._summary.text = _data.Video[0].attributes.summary;
		//Writer
		this.movieDetailsMC._writer.text = "Writer: " + _data.Video[0].Writer[0].attributes.tag;
		//Director
		this.movieDetailsMC._director.text = "Director: " + _data.Video[0].Director[0].attributes.tag;
		//Cast
		var castLen:Number = _data.Video[0].Role.length;
		var cast:String = "Cast: ";
		for (var c = 0; c<castLen; c++)
		{
			//Utils.varDump(c);
			cast = cast + _data.Video[0].Role[c].attributes.tag + " | ";
		}
		cast = cast.substr(0, (cast.length - 3));
		this.movieDetailsMC._cast.text = cast;
		//Genre
		//this.movieDetailsMC._genre.text = "Genre: " + _data.Video[0].Genre[0].attributes.tag;
		var genreLen:Number = _data.Video[0].Genre.length;
		var genre:String = "Genre: ";
		for (var g = 0; g<genreLen;g++)
		{
			genre = genre + _data.Video[0].Genre[g].attributes.tag + " | ";
		}
		genre = genre.substr(0, (genre.length - 3));
		this.movieDetailsMC._genre.text = genre;
		//Align
		UI.align([
				  {symbol:this.movieDetailsMC._writer},
				  {symbol:this.movieDetailsMC._director},
				  {symbol:this.movieDetailsMC._cast},
				  {symbol:this.movieDetailsMC._genre},
				  {symbol:this.movieDetailsMC._runTime},
				  {symbol:this.movieDetailsMC._watchTime}],
				 {halign:"left", valign:"top", layout:"vertical", gap:0, width:620, height:108, y:290, x:10}); //10, 366
				//left, right, center
	}


	public function destroy():Void {
		this.movieDetailsMC.removeMovieClip();
	}
	// Private Methods:
	private function onFlagLoad(success:Boolean, o:Object)
	{
		trace("MovieDetailsPane - Doing onFlagLoad with:" + o.o.flag);
		trace("this.movieDetailsMC._width:" + this.movieDetailsMC._width);
		var flag:String = o.o.flag;
		if (flag != undefined)
		{
			switch (flag)
			{
				case "studio":
					this.movieDetailsMC.fStudio._x = 650 - this.movieDetailsMC.fStudio._width;
					this.movieDetailsMC.fStudio._y = 495 - (this.movieDetailsMC.fStudio._height);
				break;
				case "rating":
					this.movieDetailsMC.fRating._x = 650 - this.movieDetailsMC.fRating._width;
					this.movieDetailsMC.fRating._y = 37;
				break;
				/*case "ratio":
					this.movieDetailsMC.fRatio._x = 10;
					this.movieDetailsMC.fRatio._y = 495 - (this.movieDetailsMC.fRatio._height);
				break;
				case "resolution":
					this.movieDetailsMC.fResolution._x = 5 + this.movieDetailsMC.fRatio._x + this.movieDetailsMC.fRatio._width;
					this.movieDetailsMC.fResolution._y = 495 - this.movieDetailsMC.fResolution._height;
				break;
				case "videoCodec":
					this.movieDetailsMC.fVideoCodec._x = 5 + this.movieDetailsMC.fResolution._x + this.movieDetailsMC.fResolution._width;
					this.movieDetailsMC.fVideoCodec._y = 495 - this.movieDetailsMC.fVideoCodec._height;
				break;
				case "channels":
					this.movieDetailsMC.fChannels._x = 5 + this.movieDetailsMC.fVideoCodec._x + this.movieDetailsMC.fVideoCodec._width;
					this.movieDetailsMC.fChannels._y = 495 - this.movieDetailsMC.fChannels._height;
				break;
				case "audioCodec":
					this.movieDetailsMC.fAudioCodec._x = 5 + this.movieDetailsMC.fChannels._x + this.movieDetailsMC.fChannels._width;
					this.movieDetailsMC.fAudioCodec._y = 495 - this.movieDetailsMC.fAudioCodec._height;
				break;*/
				default :
					trace("WallDetails - Default switch...");
				break;
			}
		}
		UI.align([
				  //{symbol:this.movieDetailsMC.fRating},
				  {symbol:this.movieDetailsMC.fRatio},
				  {symbol:this.movieDetailsMC.fResolution},
				  {symbol:this.movieDetailsMC.fVideoCodec},
				  {symbol:this.movieDetailsMC.fChannels},
				  {symbol:this.movieDetailsMC.fAudioCodec}],
				  //{symbol:this.movieDetailsMC.fStudio}],
				 {halign:"left", valign:"middle", gap:5, width:400, y:115, x:10})
	}
	
	private function buildDetails(mc:MovieClip)
	{	
		var _data:Array = new Array();
		_data = PlexData.oMovieData.MediaContainer[0];

		//background
		drawRoundedRectangle(mc, 660, 500, 30, 0x000000, 80, 2, 0xCCCCCC, 40);
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
		mc.ratingMC._x = this.movieDetailsMC._width - 140;
		mc.ratingMC.attachMovie("rating_0", "rating_0", mc.ratingMC.getNextHighestDepth()); 		//background
		mc.ratingMC.attachMovie("rating_100", "rating_100", mc.ratingMC.getNextHighestDepth()); 	//overlay
		mc.ratingMC.createEmptyMovieClip("ratingMask", mc.ratingMC.getNextHighestDepth()); 		//crop/mask of overlay
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
		mc.createTextField("_summary", mc.getNextHighestDepth(), 25, 77, 600, 220);
		//mc._summary.autoSize = "left";
		mc._summary.multiline = true;
		mc._summary.wordWrap = true;
		myFormat.size = 18;
		mc._summary.setNewTextFormat(myFormat);
		mc._summary.text = "Summary Text";
		//Writer
		mc.createTextField("_writer", mc.getNextHighestDepth(), 10, 366, 150, 15);
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
		mc._cast.text = "Cast: ";
		//Genre:
		mc.createTextField("_genre", mc.getNextHighestDepth(), 10, 399, 620, 40);
		//mc._genre.autoSize = true; 
		mc._genre.multiline = true;
		mc._genre.wordWrap = true;
		mc._genre.setNewTextFormat(myFormat);
		mc._genre.text = "Genre: ";
		//Running Time
		mc.createTextField("_runTime", mc.getNextHighestDepth(), 10, 412, 150, 15);
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
		mc.createTextField("_year", mc.getNextHighestDepth(), 522, 30, 150, 15);
		mc._year.autoSize = true;
		myFormat.size = 28;
		mc._year.setNewTextFormat(myFormat);
		//Tag Line
		mc.createTextField("_tagline", mc.getNextHighestDepth(), 10, 40, 520, 25);
		//mc._tagline.autoSize = true;
		myFormat.size = 18;
		mc._tagline.setNewTextFormat(myFormat);
		
		this.setText(_data.Video[0].attributes.title, _data.Video[0].attributes.year, _data.Video[0].attributes.tagline);
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
		trace("WallDetails - Doing drawRoundedRectangle with:" + mc);
		
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