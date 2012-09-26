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

import mx.utils.Delegate;

class plexNMT.as2.common.WallDetails {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.WallDetails;

	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var detailsMC:MovieClip = null;
	
	//TextFields
	private var scTitle:SmallCaps = null;
	private var scRunTime:SmallCaps = null;
	private var scWatchTime:SmallCaps = null;
	private var scYear:SmallCaps = null;
	
	//Image MovieClips
	private var ratingMC:MovieClip = null;

	// Initialization:
	public function WallDetails(parentMC:MovieClip) {
		trace("WallDetails - parentMC:" + parentMC);
		//Utils.varDump(this.parentMC);
		trace("WallDetails - Adding new Details Box...");
		detailsMC = parentMC.createEmptyMovieClip("detailsMC", parentMC.getNextHighestDepth()); //,{_x:10, _y:600});
		//trace("WallDetails - Calling draw...");
		detailsMC._x = 10 //, 50);
		detailsMC._y = 615;
		buildDetails(detailsMC);
		
		current = 0;
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);

		/*trace("WallDetails - Dumping detailsMC...");
		Utils.varDump(detailsMC);*/
		return;
	}

	// Public Methods:
	public function setText():Void 
	{
		var _data:Array = new Array();
		if (PlexData.oWallData.MediaContainer[0].Video != undefined) 
		{
			_data = PlexData.oWallData.MediaContainer[0].Video;
		} else {
			_data = PlexData.oWallData.MediaContainer[0].Directory;
		}
		scTitle.text = _data[PlexData.oWallData.intPos].attributes.title;
		this.detailsMC._title._x = (this.detailsMC._width/2) - (this.detailsMC._title._width/2);
		this.detailsMC._title._visible = true;
		scRunTime.text = "Running Time: " + Utils.formatTime(_data[PlexData.oWallData.intPos].attributes.duration);
		this.detailsMC._runTime._x = (this.detailsMC._width/2) - (this.detailsMC._runTime._width/2);
		this.detailsMC._runTime._visible = true;
		scWatchTime.text = "Watched Time: " + Utils.formatTime(_data[PlexData.oWallData.intPos].attributes.viewOffset);
		this.detailsMC._watchTime._x = (this.detailsMC._width/2) - (this.detailsMC._watchTime._width/2);
		this.detailsMC._watchTime._visible = true;
		this.detailsMC._year.text = _data[PlexData.oWallData.intPos].attributes.year;
		
		//Utils.varDump(this.detailsMC);
	}
	public function _update():Void 
	{	
		var _data:Array = new Array();
		if (PlexData.oWallData.MediaContainer[0].Video != undefined) 
		{
			_data = PlexData.oWallData.MediaContainer[0].Video;
			//scRunTime.text = Utils.formatTime(PlexData.oWallData.MediaContainer[0].Video[PlexData.oWallData.intPos].attributes.duration);
		} else {
			_data = PlexData.oWallData.MediaContainer[0].Directory;
			//scRunTime.text = Utils.formatTime(PlexData.oWallData.MediaContainer[0].Directory[PlexData.oWallData.intPos].attributes.duration);
		}
		//Rating
		if (_data[PlexData.oWallData.intPos].attributes.rating != undefined &&  _data[PlexData.oWallData.intPos].attributes.rating != 0){
			TweenLite.to(this.detailsMC.ratingMC.ratingMask, 0.7, {_width:(128 * _data[PlexData.oWallData.intPos].attributes.rating / 10)});
		} else {
			TweenLite.to(this.detailsMC.ratingMC.ratingMask, 0.7, {_width:0});
		}
		//Studio Flag
		trace("Wall Details - Calling PlexAPI.getImg...");
		var url:String = PlexAPI.getImg({width:200,
									  height:80,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "studio/" + _data[PlexData.oWallData.intPos].attributes.studio +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(url, this.detailsMC.fStudio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"studio"});
		//Content Rating Flag
		var ratingURL:String = PlexAPI.getImg({width:50,
									  height:50,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "contentRating/" + _data[PlexData.oWallData.intPos].attributes.contentRating +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(ratingURL, this.detailsMC.fRating, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"rating"});
		//Aspect Ratio Flag
		var ratioURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "aspectRatio/" + _data[PlexData.oWallData.intPos].Media[0].attributes.aspectRatio +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(ratioURL, this.detailsMC.fRatio, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"ratio"});
		//Video Resolution Flag
		var resolutionURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "videoResolution/" + _data[PlexData.oWallData.intPos].Media[0].attributes.videoResolution +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(resolutionURL, this.detailsMC.fResolution, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"resolution"});
		//Video Codec Flag
		var videoCodecURL:String = PlexAPI.getImg({width:100,
									  height:60,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "videoCodec/" + _data[PlexData.oWallData.intPos].Media[0].attributes.videoCodec +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(videoCodecURL, this.detailsMC.fVideoCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"videoCodec"});
		//Audio Channels Flags
		var channelsURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "audioChannels/" + _data[PlexData.oWallData.intPos].Media[0].attributes.audioChannels +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(channelsURL, this.detailsMC.fChannels, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"channels"});
		//Audio Codec Flag
		var audioCodecURL:String = PlexAPI.getImg({width:60,
									  height:34,
									  key:PlexData.oWallData.MediaContainer[0].attributes.mediaTagPrefix + 
									  "audioCodec/" + _data[PlexData.oWallData.intPos].Media[0].attributes.audioCodec +
									  "?t=" + PlexData.oWallData.MediaContainer[0].attributes.mediaTagVersion});
		UI.loadImage(audioCodecURL, this.detailsMC.fAudioCodec, "img",{doneCB:Delegate.create(this, this.onFlagLoad), flag:"audioCodec"});
		
		
	}


	public function destroy():Void {
		//remove all clips in detailsMC
		this.cleanMC(this.detailsMC);
		//remove main movie cli[p holder
		this.detailsMC.removeMovieClip();
		delete this.detailsMC;
	}
	// Private Methods:
	private function onFlagLoad(success:Boolean, o:Object)
	{
		var flag:String = o.o.flag;
		if (flag != undefined)
		{
			switch (flag)
			{
				case "studio":
					this.detailsMC.fStudio._x = 1110 - this.detailsMC.fStudio._width;
					this.detailsMC.fStudio._y = 46 - (this.detailsMC.fStudio._height/2);
				break;
				case "rating":
					this.detailsMC.fRating._x = 1249 - this.detailsMC.fRating._width;
					this.detailsMC.fRating._y = 58 - (this.detailsMC.fRating._height/2);
				break;
				case "ratio":
					this.detailsMC.fRatio._x = 40 - (this.detailsMC.fRatio._width/2);
					this.detailsMC.fRatio._y = 25 - (this.detailsMC.fRatio._height/2);
				break;
				case "resolution":
					this.detailsMC.fResolution._x = 40 - (this.detailsMC.fResolution._width/2);
					this.detailsMC.fResolution._y = 48;
				break;
				case "videoCodec":
					this.detailsMC.fVideoCodec._x = 80;
					this.detailsMC.fVideoCodec._y = 26;
				break;
				case "channels":
					this.detailsMC.fChannels._x = 220 - (this.detailsMC.fChannels._width/2);
					this.detailsMC.fChannels._y = 25 - (this.detailsMC.fChannels._height/2);
				break;
				case "audioCodec":
					this.detailsMC.fAudioCodec._x = 220 - (this.detailsMC.fAudioCodec._width/2);
					this.detailsMC.fAudioCodec._y = 69 - (this.detailsMC.fAudioCodec._height/2);
				break;
				default :
					trace("WallDetails - Default switch...");
				break;
			}
		}
		
	}
	private function buildDetails(mc:MovieClip)
	{	
		var _data:Array = new Array();
		if (PlexData.oWallData.MediaContainer[0].Video != undefined) 
		{
			_data = PlexData.oWallData.MediaContainer[0].Video;
		} else {
			_data = PlexData.oWallData.MediaContainer[0].Directory;
		}
		//background
		drawRoundedRectangle(mc, 1260, 90, 30, 0x000000, 80, 2, 0xCCCCCC, 40);
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
		mc.ratingMC._x = 1120;
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
		myFormat.align = "center";
		myFormat.font = "Arial";
		myFormat.color = 0xFFFFFF;
		//Title
		mc.createTextField("_title", mc.getNextHighestDepth(), 0, 8, 150, 60);
		mc._title.autoSize = true;
		mc._title._visible = false;
		myFormat.size = 24;
		mc._title.setNewTextFormat(myFormat);
		scTitle = new SmallCaps(mc._title, 19, 24);
		scTitle.text = "Title";
		mc._title._x = (mc._width/2) - (mc._title._width/2);
		//Running Time
		mc.createTextField("_runTime", mc.getNextHighestDepth(), 0, 32, 150, 50);
		mc._runTime.autoSize = true;
		mc._runTime._visible = false;
		myFormat.size = 12;
		mc._runTime.setNewTextFormat(myFormat);
		scRunTime = new SmallCaps(mc._runTime, 14, 18);
		scRunTime.text = "Running Time: 0hrs 0mins"
		mc._runTime._x = (mc._width/2) - (mc._runTime._width/2);
		//Watched Time
		mc.createTextField("_watchTime", mc.getNextHighestDepth(), 0, 53, 150, 15);
		mc._watchTime.autoSize = true; 
		mc._watchTime._visible = false;
		mc._watchTime.setNewTextFormat(myFormat);
		scWatchTime = new SmallCaps(mc._watchTime, 14,18);
		scWatchTime.text = ""
		mc._watchTime._x = (mc._width/2) - (mc._watchTime._width/2);
		//Year
		mc.createTextField("_year", mc.getNextHighestDepth(), 1120, 38, 150, 15);
		mc._year.autoSize = true;
		myFormat.size = 32;
		mc._year.setNewTextFormat(myFormat);
		
		
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
	
	private function cleanMC(_obj:Object)
	{
		for (var i in _obj)
		{
			if (typeof(_obj[i]) == "movieclip"){
				trace("Removing: " + _obj[i]);
				_obj[i].removeMovieClip();
				delete _obj[i];
			}
		}
	}

}