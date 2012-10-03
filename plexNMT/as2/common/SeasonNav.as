import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Remote;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.SetSizePlugin;
import com.greensock.plugins.GlowFilterPlugin;

import mx.utils.Delegate;

class plexNMT.as2.common.SeasonNav {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.SeasonNav;
	
	// Public Properties:
	// Private Properties:
	private var seasons:MovieClip = null;
	private var holders:Array = new Array();
	private var holder1:MovieClip = null;
	private var holder2:MovieClip = null;
	private var holder3:MovieClip = null;
	private var holder4:MovieClip = null;
	private var holder5:MovieClip = null;
	private var holder6:MovieClip = null;
	private var holder7:MovieClip = null;
	private var hiResImg:MovieClip = null;
	private var seasonData:Array = new Array();
	private var fn:Function = null;
	private var selectToggle:Boolean = false;
	
	
	private var keyListener:Object = null;
	private var klInterval:Number = 0;

	// Initialization:
	public function SeasonNav(parentMC:MovieClip, data:Array, updateFN:Function) 
	{
		trace("SeasonNav - Doing Initializtion...");
		//trace(Utils.varDump(data));
		//GreenSock Tween Control
		//OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([GlowFilterPlugin, AutoAlphaPlugin]);
		
		//Update function
		fn = updateFN;
		//Key Listener
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		seasonData = data;
		seasons = parentMC.createEmptyMovieClip("seasons", parentMC.getNextHighestDepth());
		buildHolders(seasons)
	}
	
	public function _select()
	{
		//this.selectToggle = true;
		this._position();
		this.enableKeyListener();
	}
	
	public function _unselect()
	{
		//this.selectToggle = false;
		this.disableKeyListener();
		this.deselect();
	}

	// Public Methods:
	public function destroy()
	{
		this.seasons.removeMovieClip();
		delete this.seasons
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
	}
	
	public function _update()
	{
		trace("SeasonNav - Doing _update...");
		this.delHolders();
		//buildHolders(this.seasons);
		trace("SeasonNav - Done _update...");
	}
	// Private Methods:
	private function delHolders()
	{
		trace("SeasonNav - Doing delHolders...");
		this.holder1.removeMovieClip();
		this.holder2.removeMovieClip();
		this.holder3.removeMovieClip();
		this.holder4.removeMovieClip();
		this.holder5.removeMovieClip();
		this.holder6.removeMovieClip();
		this.holder7.removeMovieClip();
		
		this.holder1 = null;
		this.holder2 = null;
		this.holder3 = null;
		this.holder4 = null;
		this.holder5 = null;
		this.holder6 = null;
		this.holder7 = null;
		
	}
	
	private function buildHolders(mc:MovieClip)
	{
		trace("SeasonNav - Doing buildHolders with: " + mc);
		holder1 = mc.createEmptyMovieClip("holder1", 1);
		holder1._alpha = 0;
		holder1._visible = false;
		holder1.autoAlpha = 0;
		trace("SeasonNav - PlexData.oSeasonData.intPos:" + PlexData.oSeasonData.intPos);
		if ((PlexData.oSeasonData.intPos-3)>=0)
		{
			trace("SeasonNav - PlexData.oSeasonData.intPos-3:" + PlexData.oSeasonData.intPos-3);
			var h1URL:String = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",-3)].attributes.thumb});
			UI.loadImage(h1URL, holder1, "img");
		}
		
		holder2 = mc.createEmptyMovieClip("holder2", 3);
		holder2._alpha = 0;
		holder2._visible = false;
		holder2.autoAlpha = 0;
		if ((PlexData.oSeasonData.intPos-2)>=0)
		{
			holder2.autoAlpha = 100;
			var h2URL:String = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",-2)].attributes.thumb});
			UI.loadImage(h2URL, holder2, "img");
		}
		
		holder3 = mc.createEmptyMovieClip("holder3", 5);
		holder3._alpha = 0;
		holder3._visible = false;
		holder3.autoAlpha = 0;
		if ((PlexData.oSeasonData.intPos-1)>=0)
		{
			holder3.autoAlpha = 100;
			var h3URL = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",-1)].attributes.thumb});
			UI.loadImage(h3URL, holder3, "img");
		}
		
		holder4 = mc.createEmptyMovieClip("holder4", 7);
		holder4._alpha = 0;
		holder4._visible = false;
		holder4.autoAlpha = 100;
		var h4URL:String = PlexAPI.getImg({width:134, height:198,
									  key:seasonData[PlexData.GetRotation("oSeasonData",0)].attributes.thumb});
		UI.loadImage(h4URL, holder4, "img");
		
		holder5 = mc.createEmptyMovieClip("holder5", 2);
		holder5._alpha = 0;
		holder5._visible = false;
		holder5.autoAlpha = 0;
		if ((PlexData.oSeasonData.intPos+1)<=PlexData.oSeasonData.intLength)
		{
			holder5.autoAlpha = 100;
			var h5URL:String = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",1)].attributes.thumb});
			UI.loadImage(h5URL, holder5, "img");
		}
		
		holder6 = mc.createEmptyMovieClip("holder6", 4);
		holder6._alpha = 0;
		holder6._visible = false;
		holder6.autoAlpha = 0;
		if ((PlexData.oSeasonData.intPos+2)<=PlexData.oSeasonData.intLength)
		{
			holder6.autoAlpha = 100;
			var h5URL:String = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",2)].attributes.thumb});
			UI.loadImage(h5URL, holder6, "img");
		}
		
		holder7 = mc.createEmptyMovieClip("holder7", 6);
		holder7._alpha = 0;
		holder7._visible = false;
		holder7.autoAlpha = 0;
		if ((PlexData.oSeasonData.intPos+3)<=PlexData.oSeasonData.intLength)
		{
			var h5URL:String = PlexAPI.getImg({width:134, height:198,
										  key:seasonData[PlexData.GetRotation("oSeasonData",3)].attributes.thumb});
			UI.loadImage(h5URL, holder7, "img");
		}
		
		this.holders = [holder1, holder2, holder3, holder4, holder5, holder6, holder7];
		
		//Move Season Holders into position
		mc._x = 288;
		mc._y = 522;
	}
	
	private function deselect()
	{
		trace("SeasonNav - Doing deselect...");
		TweenLite.to(this.holders[3], 0.4, {_x:379.50, _y:25, _width:117, _height:173});
	}
	
	private function _position()
	{
		trace("SeasonNav - Doing position...");
		var pos:Array = new Array();
		pos[0] = {autoAlpha:0, _x:0, _y:25, _width:117, _height:173};
		pos[1] = {autoAlpha:this.holders[1].autoAlpha, _x:129, _y:25, _width:117, _height:173};
		pos[2] = {autoAlpha:this.holders[2].autoAlpha, _x:254.25, _y:25, _width:117, _height:173};
		pos[3] = {autoAlpha:this.holders[3].autoAlpha, _x:372.61, _y:0, _width:134, _height:198};
		pos[4] = {autoAlpha:this.holders[4].autoAlpha, _x:504.75, _y:25, _width:117, _height:173};
		pos[5] = {autoAlpha:this.holders[5].autoAlpha, _x:630, _y:25, _width:117, _height:173};
		pos[6] = {autoAlpha:0, _x:760.5, _y:25, _width:117, _height:173};
		//Move Posters
		TweenLite.to(this.holders[0], 0.2, pos[0]);
		this.holders[0].swapDepths(1);
		TweenLite.to(this.holders[1], 0.4, pos[1]);
		this.holders[1].swapDepths(3);
		TweenLite.to(this.holders[2], 0.4, pos[2]);
		this.holders[2].swapDepths(5);
		TweenLite.to(this.holders[3], 0.4, pos[3]);
		this.holders[3].swapDepths(7);
		TweenLite.to(this.holders[4], 0.4, pos[4]);
		this.holders[4].swapDepths(2);
		TweenLite.to(this.holders[5], 0.4, pos[5]);
		this.holders[5].swapDepths(4);
		TweenLite.to(this.holders[6], 0.2, pos[6]);
		this.holders[6].swapDepths(6);
	}
	
	private function newImg(intImg:Number, intHolder:Number)
	{
		trace("SeasonNav - Doing newImg With intImg: " + intImg + ", intHolder: " + intHolder);
		trace("SeasonNav - PlexData.oSeasonData.intPos: " + PlexData.oSeasonData.intPos);
		var url:String = PlexAPI.getImg({width:134, height:198, key:seasonData[PlexData.GetRotation("oSeasonData", intImg)].attributes.thumb});
		UI.loadImage(url, holders[intHolder], "img");
	}
	
	private function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.klInterval = _global["setInterval"](Delegate.create(this, this.onEnableKeyListener), 500); // delay abit to prevent getting the previously press key.
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
			case Key.LEFT:
				PlexData.oSeasonData.intPos--;
				if (PlexData.oSeasonData.intPos < 0)
				{
					this.holders[0].autoAlpha = 0;
					PlexData.oSeasonData.intPos = 0;
				} else {
					this.holders.unshift(this.holders.pop());
					if ((PlexData.oSeasonData.intPos-3)>=0)
					{
						this.holders[0].autoAlpha = 100;
						this.newImg(-3, 0);
					} else {
						this.holders[0].autoAlpha = 0;
					}
				}
				this._position();
			break;
			case Key.RIGHT:
				PlexData.oSeasonData.intPos++;
				if (PlexData.oSeasonData.intPos > PlexData.oSeasonData.intLength)
				{
					this.holders[6].autoAlpha = 0;
					PlexData.oSeasonData.intPos = PlexData.oSeasonData.intLength;
				} else {
					this.holders.push(this.holders.shift());
					if((PlexData.oSeasonData.intPos+3)<=PlexData.oSeasonData.intLength)
					{
						this.holders[6].autoAlpha = 100;
						this.newImg(3, 6);
					} else {
						this.holders[6].autoAlpha = 0;
					}
				}
				this._position();
			break;
		}
		trace("SeasonNav - Calling fastUpdate...");
		this.fn();
	}

}