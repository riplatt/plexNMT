﻿import plexNMT.as2.api.PlexAPI;
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
		D.debug(D.lDev, "Background - Doing Initialization...");
		backgroundMC = parentMC.createEmptyMovieClip("backgroundMC", parentMC.getNextHighestDepth());
		D.debug(D.lDev, "Background - Got a depth of " + backgroundMC.getDepth());
		backgroundMC.swapDepths(0)
		current = 0;
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		return;
	}

	// Public Methods:
	public function _set(key:String)
	{
		D.debug(D.lDebug, "Background - Setting background to " + key);
		var url:String = PlexData.oSettings.url + "/photo/:/transcode?width=1280&height=720&url=" + escape(PlexData.oSettings.url + key)
		UI.loadImage(url, this.backgroundMC,"imgBG2", {scaleMode:2});
		this.current = 1;
	}	
	
	public function _update(key:String)
	{
		D.debug(D.lDebug, "Background - Updating background to " + key);
		var url:String = PlexData.oSettings.url + "/photo/:/transcode?width=1280&height=720&url=" + escape(PlexData.oSettings.url + key)
		if (this.current == 0) {
			//trace("Doing 0 with: " + url);
			UI.loadImage(url, this.backgroundMC,"imgBG2", {scaleMode:2});
			this.backgroundMC.imgBG2._alpha = 0;
			this.backgroundMC.imgBG2._visible = false;
			TweenLite.to(this.backgroundMC.imgBG2, 0, {autoAlpha:100});
			TweenLite.to(this.backgroundMC.imgBG1, 0, {autoAlpha:0});
			this.current = 1;
		} else {
			//trace("Doing 1 with: " + url);
			UI.loadImage(url, this.backgroundMC,"imgBG1", {scaleMode:2});
			this.backgroundMC.imgBG1._alpha = 0;
			this.backgroundMC.imgBG1._visible = false;
			TweenLite.to(this.backgroundMC.imgBG1, 0, {autoAlpha:100});
			TweenLite.to(this.backgroundMC.imgBG2, 0, {autoAlpha:0});
			this.current = 0;
		}
		return;
	}
	
	public function destroy():Void {
		this.backgroundMC.imgBG1.removeMovieClip();
		delete this.backgroundMC.imgBG1;
		this.backgroundMC.imgBG2.removeMovieClip();
		delete this.backgroundMC.imgBG2;
		this.backgroundMC.removeMovieClip();
		delete this.backgroundMC;
		
		return;
	}
	// Private Methods:

}