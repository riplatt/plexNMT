import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;

class plexNMT.as2.common.Background {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.Background;
	
	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var backgroundMC:MovieClip = null;

	// Initialization:
	public function Background(parentMC:MovieClip)
	{
		/*trace("Background - parentMC:"+parentMC);
		Utils.varDump(this.parentMC);
		trace("Background - Adding new Background...");*/
		backgroundMC = parentMC.createEmptyMovieClip("backgroundMC", parentMC.getNextHighestDepth()); //,{_x:0, _y:0, _width:1280, _height:720});
		current = 0;
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		/*trace("Background - Dumping backgroundMC...");
		Utils.varDump(backgroundMC);*/
		return;
	}

	// Public Methods:
	public function _update(key:String)
	{
		//trace("Background - Updating Background with: " + key + ", " + this.current);
		var url:String = PlexData.oSettings.url + "/photo/:/transcode?width=1280&height=720&url=" + escape(PlexData.oSettings.url + key)
		if (this.current == 0) {
			//trace("Doing 0 with: " + url);
			UI.loadImage(url, this.backgroundMC,"imgBG2", {scaleMode:2});
			this.backgroundMC.imgBG2._alpha =0;
			this.backgroundMC.imgBG2._visible = false;
			TweenLite.to(this.backgroundMC.imgBG2, 4, {autoAlpha:100});
			TweenLite.to(this.backgroundMC.imgBG1, 2, {autoAlpha:0});
			this.current = 1;
		} else {
			//trace("Doing 1 with: " + url);
			UI.loadImage(url, this.backgroundMC,"imgBG1", {scaleMode:2});
			this.backgroundMC.imgBG1._alpha =0;
			this.backgroundMC.imgBG1._visible = false;
			TweenLite.to(this.backgroundMC.imgBG1, 4, {autoAlpha:100});
			TweenLite.to(this.backgroundMC.imgBG2, 2, {autoAlpha:0});
			this.current = 0;
		}
		//trace("Background - Dumping this.backgroundMC...");
		//Utils.varDump(this.backgroundMC);
		return;
	}
	
	public function destroy():Void {
		this.backgroundMC.imgBG1.removeMovieClip();
		this.backgroundMC.imgBG2.removeMovieClip();
		this.backgroundMC.removeMovieClip();
		
		return;
	}
	// Private Methods:

}