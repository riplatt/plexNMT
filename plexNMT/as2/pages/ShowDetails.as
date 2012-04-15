import plexNMT.as2.api.PlexAPI;

import com.syabas.as2.common.GridLite;

import com.greensock.TweenLite;

import mx.utils.Delegate;

class plexNMT.as2.pages.ShowDetails {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.ShowDetails;
	public static var plexURL:String = "http://192.168.0.3:32400/";
	
	// Public Properties:
	// Private Properties:
	//MovieClips
	private var parentMC:MovieClip = null;
	private var backgroundMC:MovieClip = null;
	private var gShowSelectBGMC:MovieClip = null;
	private var infoBGMC:MovieClip = null;
	private var gShowSelectMC:MovieClip = null;
	private var gSeasonSelectMC:MovieClip = null;
	private var gEpisodeSelectMC:MovieClip = null;
	private var gControlSelectMC:MovieClip = null;
	private var preloadMC:MovieClip = null;
	//Girds
	private var g11:GridLite = null;
	private var g12:GridLite = null;
	private var g13:GridLite = null;
	private var g2:GridLite = null;
	private var g3:GridLite = null;
	private var g4:GridLite = null;
	//Strings
	private var plexPath:String = null;

	// Initialization:
	public function ShowDetails(parentMC:MovieClip) {
		trace("Doing Show Details Page with: " + parentMC);
		this.parentMC = parentMC;
		this.mainMC = this.parentMC.createEmptyMovieClip("mainMC", this.parentMC.getNextHighestDepth());
		
		this.setStage();
		
		//this.plexPath = _level0.plex.detailPath;
		this.wallData = _level0.plex.wallData;
		this.showData = _level0.plex.detailData;
		
		this.loadShows();
		
	}

	// Public Methods:
	public function destroy():Void {
		
	}
	// Private Methods:
	private function loadShows() {
		this.preloadMC = this.parentMC.attachMovie("preload200", "preload200", parentMC.getNextHighestDepth(), {_x:640, _y:360});
		//PlexAPI.loadShowDetails(plexPath, Delegate.create(this, this.onLoadShows), 5000);
		onLoadShows(this.wallData[this.showData.index - 1])
		loadSeasons()
	}
	
	private function onLoadShows(data:Array) {
		
		this.loadSeasons()
	}
	
	private function loadSeasons() {
		
		PlexAPI.loadShowDetails(plexPath, Delegate.create(this, this.onLoadShows), 5000);
	}
	
	private function onLoadSeasons() {
		
	}
	
	private function loadEpisodes() {
		
		PlexAPI.loadShowDetails(plexPath, Delegate.create(this, this.onLoadShows), 5000);
	}
	
	private function onLoadEpisodes() {
		
	}
	
	private function setStage() {
		//Background Movie art/fanart
		this.backgroundMC = this.mainMC.createEmptyMovieClip("backgroundMC", this.mainMC.getNextHighestDepth());
		//Background Next/Previous Shows thumbs
		this.gShowSelectBGMC = this.mainMC.createEmptyMovieClip("gShowSelectBGMC", this.mainMC.getNextHighestDepth());
		//Backgrouns for info pane
		this.infoBGMC = this.mainMC.createEmptyMovieClip("infoBGMC", this.mainMC.getNextHighestDepth());
		this.infoBGMC.createTextField("showTitleTF", this.infoBGMC.getNextHighestDepth(), 340, 360, 20, 100);
		this.infoBGMC.createTextField("seasonTF", this.infoBGMC.getNextHighestDepth(), 360, 360, 16, 50);
		this.infoBGMC.createTextField("episodeTF", this.infoBGMC.getNextHighestDepth(), 360, 410, 16, 50);
		this.infoBGMC.createTextField("summaryTF", this.infoBGMC.getNextHighestDepth(), 380, 360, 250, 400);
		//Current Selected show poster 
		this.gShowSelectMC = this.mainMC.createEmptyMovieClip("gShowSelectMC", this.mainMC.getNextHighestDepth());
		//Season select bar
		this.gSeasonSelectMC = this.mainMC.createEmptyMovieClip("gSeasonSelectMC", this.mainMC.getNextHighestDepth());
		//episode select bar
		this.gEpisodeSelectMC = this.mainMC.createEmptyMovieClip("gEpisodeSelectMC", this.mainMC.getNextHighestDepth());
		//control bar i.e play all, resume, edit etc...
		this.gControlSelectMC = this.mainMC.createEmptyMovieClip("gControlSelectMC", this.mainMC.getNextHighestDepth());
		
		//Background Next/Previous Shows top thumb 
		var g11mcArray:Array = UI.attachMovieClip({parentMC:this.gShowSelectBGMC, cSize:1, rSize:1, mcPrefix:"g11", mcName:"thumbShow1AwayMC", x:0, y:0});
		this.g11 = new GridLite();
		this.g11.xMCArray = g11mcArray;
		this.g11.xHoriz = false;
		this.g11.xWrap = true;
		this.g11.xWrapLine = false;
		this.g11.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g11.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g11.overRightCB = Delegate.create(this, this.overRightCB);
		this.g11.onEnterCB = Delegate.create(this, this.onEnterCB);
		//Background Next/Previous Shows bottom thumb 
		var g12mcArray:Array = UI.attachMovieClip({parentMC:this.gShowSelectBGMC, cSize:1, rSize:1, mcPrefix:"g12", mcName:"thumbShow1AwayMC", x:0, y:261});
		this.g12 = new GridLite();
		this.g12.xMCArray = g12mcArray;
		this.g12.xHoriz = false;
		this.g12.xWrap = true;
		this.g12.xWrapLine = false;
		this.g12.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g12.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g12.overRightCB = Delegate.create(this, this.overRightCB);
		this.g12.onEnterCB = Delegate.create(this, this.onEnterCB);
		
		//Current Show Selection Thumb 
		var g13mcArray:Array = UI.attachMovieClip({parentMC:this.gShowSelectBGMC, cSize:1, rSize:1, mcPrefix:"g13", mcName:"thumbShowMC", x:0, y:0});
		this.g13 = new GridLite();
		this.g13.xMCArray = g13mcArray;
		this.g13.xHoriz = false;
		this.g13.xWrap = true;
		this.g13.xWrapLine = false;
		this.g13.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g13.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g13.overRightCB = Delegate.create(this, this.overRightCB);
		this.g13.onEnterCB = Delegate.create(this, this.onEnterCB);
		
		//Season Selection thumbs 
		var g2mcArray:Array = UI.attachMovieClip({parentMC:this.gSeasonSelectMC, cSize:3, rSize:1, mcPrefix:"g2", mcName:"thumbSeasonMC", x:0, y:0});
		this.g2 = new GridLite();
		this.g2.xMCArray = g2mcArray;
		this.g2.xHoriz = false;
		this.g2.xWrap = true;
		this.g2.xWrapLine = false;
		this.g2.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g2.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g2.overTopCB = Delegate.create(this, this.overTopCB);
		this.g2.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.g2.overRightCB = Delegate.create(this, this.overRightCB);
		this.g2.onEnterCB = Delegate.create(this, this.onEnterCB);
		
		//Control Selection
		var g3mcArray:Array = UI.attachMovieClip({parentMC:this.gControlSelectMC, cSize:3, rSize:1, mcPrefix:"g3", mcName:"controlMC", x:0, y:65});
		this.g3 = new GridLite();
		this.g3.xMCArray = g3mcArray;
		this.g3.xHoriz = false;
		this.g3.xWrap = true;
		this.g3.xWrapLine = false;
		//this.g3.data = data;
		this.g3.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g3.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		/*this.g3.hlCB = Delegate.create(this, this.hlCB);
		this.g3.unhlCB = Delegate.create(this, this.unhlCB);
		this.g3.overTopCB = Delegate.create(this, this.overTopCB);*/
		this.g3.overBottomCB = Delegate.create(this, this.overBottomCB);
		this.g3.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.g3.overRightCB = Delegate.create(this, this.overRightCB);
		this.g3.onEnterCB = Delegate.create(this, this.onEnterCB);
		/*this.g3.onKeyDownCB = Delegate.create(this, this.onKeyDownCB);
		this.g3.onHLStopCB = Delegate.create(this, this.onHLStopCB);
		this.g3.createUI(0);
		this.g3.highlight(data.length);*/
		
		//Episode Selection thumbs 
		var g4mcArray:Array = UI.attachMovieClip({parentMC:this.gEpisodeSelectMC, cSize:3, rSize:1, mcPrefix:"g4", mcName:"thumbSeasonMC", x:0, y:0});
		this.g4 = new GridLite();
		this.g4.xMCArray = g4mcArray;
		this.g4.xHoriz = false;
		this.g4.xWrap = true;
		this.g4.xWrapLine = false;
		this.g4.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g4.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g4.overTopCB = Delegate.create(this, this.overTopCB);
		this.g4.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.g4.overRightCB = Delegate.create(this, this.overRightCB);
		this.g4.onEnterCB = Delegate.create(this, this.onEnterCB);
		
		
	}

}