import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.IMGLoader;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.Remote;

class plexNMT.as2.pages.MovieDetails
{
	public static var plexURL:String = "http://192.168.0.3:32400/";
	//public static var plexRatingKey:String = "2741"; //26,8,2763, 2557,2740,2741
	public static var plexRatingKey:String = null; //_level0.currentRatingKey;
	
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
	private var preloadMC:MovieClip = null;
	
	private var keyListener:Object = null;
	
	//var listenerObj:Object = new Object();
	
	// Destroy all global variables.
	public function destroy():Void
	{
		this.parentMC.removeMovieClip();
		delete this.parentMC;
		parentMC = null;
		
		this.backdropMC.removeMovieClip();
		delete this.backdropMC;
		backdropMC = null;
		
		this.posterMC.removeMovieClip();
		delete this.posterMC;
		posterMC = null;
		
		this.titleMC.removeMovieClip();
		delete this.titleMC;
		titleMC = null;
		
		this.ratingMC.removeMovieClip();
		delete this.ratingMC;
		ratingMC = null;
		
		this.minMC.removeMovieClip();
		delete this.minMC;
		minMC = null;
		
		this.studioMC.removeMovieClip();
		delete this.studioMC;
		studioMC = null;
		
		this.contentRatingMC.removeMovieClip();
		delete this.contentRatingMC;
		contentRatingMC = null;
		
		this.videoResolutionMC.removeMovieClip();
		delete this.videoResolutionMC;
		videoResolutionMC = null;
		
		this.aspectRatioMC.removeMovieClip();
		delete this.aspectRatioMC;
		aspectRatioMC = null;
		
		this.audioChannelsMC.removeMovieClip();
		delete this.audioChannelsMC;
		audioChannelsMC = null;
		
		this.audioCodecMC.removeMovieClip();
		delete this.audioCodecMC;
		audioCodecMC = null;
		
		this.summaryMC.removeMovieClip();
		delete this.summaryMC;
		summaryMC = null;
		
		this.preloadMC.removeMovieClip();
		delete this.preloadMC;
		preloadMC = null;
		
		
		delete this.keyListener;
		this.keyListener = null;
	}
	
	public function MovieDetails(parentMC:MovieClip)
	{
		trace("Doing plexNMT.movieDetails...");

		plexRatingKey = _level0.currentRatingKey;

		this.parentMC = parentMC;
		
		this.backdropMC = this.parentMC.createEmptyMovieClip("backdropMC", parentMC.getNextHighestDepth());
		backdropMC._y = 0;
		backdropMC._x = 0;
		
		this.bgOverlayMC = this.parentMC.attachMovie("bgOverlay", "bgOverlayMC", parentMC.getNextHighestDepth());
		backdropMC.setMask(bgOverlayMC);
		
		this.posterMC = this.parentMC.createEmptyMovieClip("posterMC", parentMC.getNextHighestDepth());
		posterMC._y = 0;
		posterMC._x = 0;
		
		this.titleMC = this.parentMC.createEmptyMovieClip("titleMC", parentMC.getNextHighestDepth());
		titleMC._y = 0;
		titleMC._x = 520;
		titleMC.createTextField("title_txt", titleMC.getNextHighestDepth(), 10, 24, 900, 50);
		
		this.ratingMC = this.parentMC.createEmptyMovieClip("ratingMC", parentMC.getNextHighestDepth());
		ratingMC._y = 80;
		ratingMC._x = 522;
		
		this.minMC = this.parentMC.createEmptyMovieClip("minMC", parentMC.getNextHighestDepth());
		minMC._y = 55;
		minMC._x = 650;
		minMC.createTextField("min_txt", minMC.getNextHighestDepth(), 10, 24, 900, 50);
		
		this.studioMC = this.parentMC.createEmptyMovieClip("studioMC", parentMC.getNextHighestDepth());
		//studioMC.addListener(listenerObj);
		studioMC._y = 125;
		studioMC._x = 520;		
		
		this.contentRatingMC = this.parentMC.createEmptyMovieClip("contentRatingMC", parentMC.getNextHighestDepth());
		contentRatingMC._y = 125;
		contentRatingMC._x = 560;
		
		this.aspectRatioMC = this.parentMC.createEmptyMovieClip("aspectRatioMC", parentMC.getNextHighestDepth());
		aspectRatioMC._y = 125;
		aspectRatioMC._x = 660;
		
		this.videoResolutionMC = this.parentMC.createEmptyMovieClip("videoResolutionMC", parentMC.getNextHighestDepth());
		videoResolutionMC._y = 125;
		videoResolutionMC._x = 740;
				
		this.audioCodecMC = this.parentMC.createEmptyMovieClip("audioCodecMC", parentMC.getNextHighestDepth());
		audioCodecMC._y = 125;
		audioCodecMC._x = 825;
		
		this.audioChannelsMC = this.parentMC.createEmptyMovieClip("audioChannelsMC", parentMC.getNextHighestDepth());
		audioChannelsMC._y = 125;
		audioChannelsMC._x = 965;
		
		this.summaryMC = this.parentMC.createEmptyMovieClip("summaryMC", parentMC.getNextHighestDepth());
		summaryMC._y = 165;
		summaryMC._x = 520;
		summaryMC.createTextField("summary_txt", summaryMC.getNextHighestDepth(), 10, 24, 700, 500);
		summaryMC.summary_txt.multiline = true;
		summaryMC.summary_txt.wordWrap = true;
		
		this.keyListener = new Object();
		this.keyListener.onKeyDown = this.onKeyDown();
		Key.addListener(this.keyListener);
		
		this.preloadMC = this.parentMC.attachMovie("preload200", "preload200", parentMC.getNextHighestDepth(), {_x:640, _y:360});
		trace("plexURL: " + plexURL+"library/metadata/" + plexRatingKey)
		PlexAPI.loadMoveDetails(plexURL+"library/metadata/" + plexRatingKey, Delegate.create(this, this.parseXML), 5000);
	}

	private function parseXML(data:Array):Void
	{
			trace("Doing moveieDetails.parseXML.data: ");
			//var_dump(data);
			this.preloadMC.removeMovieClip();
			delete this.preloadMC;
			this.preloadMC = null;
			
			trace("artURL: " + data[0].artURL);
			backdropMC.loadMovie(data[0].artURL);
			
			trace("posterURL: " + data[0].posterURL);
			posterMC.loadMovie(data[0].posterURL);
			
			trace("artURL: " + data[0].artURL);
			backdropMC.loadMovie(data[0].artURL);
			
			trace("title: " + data[0].title);
			var txtFormat:TextFormat = new TextFormat ();
			txtFormat.font = "Arial";
			txtFormat.size = 40;
			txtFormat.color = 0xFFFFFF;
			titleMC.title_txt.htmlText = data[0].title;
			titleMC.title_txt.setTextFormat(txtFormat);	
			
			trace("data[0].rating: " + data[0].rating);
			var rating:Number = 128 * data[0].rating;
			trace("rating: " + rating);
			ratingMC.attachMovie("rating_0", "rating_0", ratingMC.getNextHighestDepth()); //background
			ratingMC.attachMovie("rating_100", "rating_100", ratingMC.getNextHighestDepth()); //overlay
			ratingMC.createEmptyMovieClip("ratingMask", ratingMC.getNextHighestDepth()); //crop/mask of overlay
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
			
			trace("durationMIN: " + data[0].durationMIN);
			var minFormat:TextFormat = new TextFormat ();
			minFormat.font = "Arial";
			minFormat.size = 20;
			minFormat.color = 0xFFFFFF;
			minMC.min_txt.htmlText = data[0].durationMIN;
			minMC.min_txt.setTextFormat(minFormat);			
			
			trace("studioURL: " + data[0].studioURL);
			studioMC.loadMovie(data[0].studioURL);
			//var_dump(studioMC);
			
			trace("contentRatingURL: " + data[0].contentRatingURL);
			contentRatingMC.loadMovie(data[0].contentRatingURL);
			
			trace("videoResolutionURL: " + data[0].videoResolutionURL);
			videoResolutionMC.loadMovie(data[0].videoResolutionURL);
			
			trace("aspectRatioURL: " + data[0].aspectRatioURL);
			aspectRatioMC.loadMovie(data[0].aspectRatioURL);
			
			trace("audioChannelsURL: " + data[0].audioChannelsURL);
			audioChannelsMC.loadMovie(data[0].audioChannelsURL);
			
			trace("audioCodecURL: " + data[0].audioCodecURL);
			audioCodecMC.loadMovie(data[0].audioCodecURL);
			
			trace("summary: " + data[0].summary);
			var sumFormat:TextFormat = new TextFormat ();
			sumFormat.font = "Arial";
			sumFormat.size = 18;
			sumFormat.color = 0xFFFFFF;
			summaryMC.summary_txt.htmlText = data[0].summary;
			summaryMC.summary_txt.setTextFormat(sumFormat);
			
	}
	
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		trace("Doing MovieDetails.onKeyDown...");
		trace("KeyCode: " + keyCode);
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