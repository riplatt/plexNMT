import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Remote;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;

import mx.utils.Delegate;

class plexNMT.as2.common.EpisodeNav {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.EpisodeNav;
	
	// Public Properties:
	// Private Properties:
	private var imgLoader:IMGLoader = null;
	
	private var episodes:MovieClip = null;
	private var holders:Array = new Array();
	private var holder1:MovieClip = null;
	private var holder2:MovieClip = null;
	private var holder3:MovieClip = null;
	private var holder4:MovieClip = null;
	private var holder5:MovieClip = null;
	private var holder6:MovieClip = null;
	private var episodeData:Array = new Array();
	private var fn:Function = null;
	
	private var keyListener:Object = null;
	private var klInterval:Number = 0;

	// Initialization:
	public function EpisodeNav(parentMC:MovieClip, data:Array, updateFN:Function) 
	{
		D.debug(D.lDev, "EpisodeNav - Doing Initializtion with data:");
		D.debug(D.lDev, Utils.varDump(data));
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		//Update function
		fn = updateFN;
		//Key Listener
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		episodeData = data;
		episodes = parentMC.createEmptyMovieClip("episodes", parentMC.getNextHighestDepth());
		
		var key:String = PlexData.oEpisodeData._children[PlexData.oEpisodeData.intPos].key
		PlexAPI.getEpisodeData(key, Delegate.create(this, buildHolders), 5000);
	}
	
	public function _update()
	{
		D.debug(D.lDev, "EpisodeNav - Doing _update...");
		PlexData.oEpisodeData.intPos = 0;
		
		var _data:Array = PlexData.oEpisodeData._children;		
		
		this.holders[0].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[0], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:0, lmcId:"posterWide"});
		this.holders[1].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[1], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:1, lmcId:"posterWide"});
		this.holders[2].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[2], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:2, lmcId:"posterWide"});
		this.holders[3].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[3], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:3, lmcId:"posterWide"});
		this.holders[4].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[4], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:4, lmcId:"posterWide"});
		this.holders[5].autoAlpha = 0;
		UI.loadImage("posterWide", this.holders[5], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:5, lmcId:"posterWide"});

		this.holders[2].autoAlpha = 100;
		var h2URL:String = PlexAPI.getImg({width:263, height:148,
									  key:_data[PlexData.GetRotation("oEpisodeData",0)].thumb});
		UI.loadImage(h2URL, this.holders[2], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:2, lmcId:"posterWide", _selected:false});
		
		if ((PlexData.oEpisodeData.intPos+1)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[3].autoAlpha = 100;
			var h3URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData",1)].thumb});
			UI.loadImage(h3URL, this.holders[3], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:3, lmcId:"posterWide"});
		}
		
		if ((PlexData.oEpisodeData.intPos+2)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[4].autoAlpha = 100;
			var h4URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData",2)].thumb});
			UI.loadImage(h4URL, this.holders[4], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:4, lmcId:"posterWide"});
		}
		
		if ((PlexData.oEpisodeData.intPos+3)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[5].autoAlpha = 100;
			var h5URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData",3)].thumb});
			UI.loadImage(h5URL, this.holders[5], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:5, lmcId:"posterWide"});
		}

		D.debug(D.lDev, "EpisodeNav - Done _update...");
	}
	
	public function _select()
	{
		//this.selectToggle = true;
		this._position();
		this.enableKeyListener();
		D.debug(D.lDev, "EpisodeNav - Calling fastUpdate...");
		this.fn("episode");
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
		this.episodes.removeMovieClip();
		delete this.episodes
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
	}
	// Private Methods:
	private function delHolders()
	{
		D.debug(D.lDev, "EpisodeNav - Doing delHolders...");
		this.holder1.removeMovieClip();
		this.holder2.removeMovieClip();
		this.holder3.removeMovieClip();
		this.holder4.removeMovieClip();
		this.holder5.removeMovieClip();
		this.holder6.removeMovieClip();
		
		this.holder1 = null;
		this.holder2 = null;
		this.holder3 = null;
		this.holder4 = null;
		this.holder5 = null;
		this.holder6 = null;
	}
	
	private function buildHolders()
	{
		D.debug(D.lDev, "EpisodeNav - Doing buildHolders...");
		var mc:MovieClip = this.episodes;
		var _data:Array = PlexData.oEpisodeData._children;		
		//D.debug(D.lDev, Utils.varDump(this.episodeData));
		holder1 = mc.createEmptyMovieClip("holder1", 1);
		holder1._alpha = 0;
		holder1._visible = false;
		holder1.autoAlpha = 0;
		holder2 = mc.createEmptyMovieClip("holder2", 3);
		holder2._alpha = 0;
		holder2._visible = false;
		holder2.autoAlpha = 0;
		holder3 = mc.createEmptyMovieClip("holder3", 6);
		holder3._alpha = 0;
		holder3._visible = false;
		holder3.autoAlpha = 100;
		holder4 = mc.createEmptyMovieClip("holder4", 5);
		holder4._alpha = 0;
		holder4._visible = false;
		holder4.autoAlpha = 0;
		holder5 = mc.createEmptyMovieClip("holder5", 4);
		holder5._alpha = 0;
		holder5._visible = false;
		holder5.autoAlpha = 0;
		holder6 = mc.createEmptyMovieClip("holder6", 2);
		holder6._alpha = 0;
		holder6._visible = false;
		holder6.autoAlpha = 0;
		
		this.holders = [holder1, holder2, holder3, holder4, holder5, holder6];
		
		if ((PlexData.oEpisodeData.intPos-2)>=0)
		{
			this.holders[0].autoAlpha = 100;
			var h0URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData", -2)].thumb});
			UI.loadImage(h0URL, this.holders[0], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:0});
		}
				
		if ((PlexData.oEpisodeData.intPos-1)>=0)
		{
			this.holders[1].autoAlpha = 100;
			var h1URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData", -1)].thumb});
			UI.loadImage(h1URL, this.holders[1], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:1});
		}
		
		this.holders[2].autoAlpha = 100;
		var h2URL:String = PlexAPI.getImg({width:263, height:148,
									  key:_data[PlexData.GetRotation("oEpisodeData", 0)].thumb});
		UI.loadImage(h2URL, this.holders[2], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:2, _selected:false});
		
		
		if ((PlexData.oEpisodeData.intPos+1)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[3].autoAlpha = 100;
			var h3URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData", 1)].thumb});
			UI.loadImage(h3URL, this.holders[3], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:3});
		}
		
		
		if ((PlexData.oEpisodeData.intPos+2)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[4].autoAlpha = 100;
			var h4URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData", 2)].thumb});
			UI.loadImage(h4URL, this.holders[4], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:4});
		}
		
		
		if ((PlexData.oEpisodeData.intPos+3)<=PlexData.oEpisodeData.intLength)
		{
			this.holders[5].autoAlpha = 100;
			var h5URL:String = PlexAPI.getImg({width:263, height:148,
										  key:_data[PlexData.GetRotation("oEpisodeData", 3)].thumb});
			UI.loadImage(h5URL, this.holders[5], "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:5});
		}
		
		
		this.episodes._x = 1017;
		this.episodes._y = 0;		
	}
	
	private function onHolderLoad(success:Boolean, o:Object)
	{
		D.debug(D.lDev, "EpisodeNav - Doing onHolderLoad with: " + o.o.holder);
		var holder:Number = o.o.holder;
		var _sel:Boolean = o.o._selected;
		if (_sel == undefined || _sel == null || _sel == "")
			_sel = false;
		switch (holder)
		{
			case 0:
				TweenLite.to(this.holders[0], 0, {autoAlpha:0, _x:29, _y:-17, _width:234, _height:131.625});
			break;
			case 1:
				TweenLite.to(this.holders[1], 0, {autoAlpha:this.holders[1].autoAlpha, _x:29, _y:123.38, _width:234, _height:131.625});
			break;
			case 2:
				TweenLite.to(this.holders[2], 0, {autoAlpha:this.holders[2].autoAlpha, _x:29, _y:263.31, _width:234, _height:131.625});
			break;
			case 3:
				if (_sel)
				{
					TweenLite.to(this.holders[3], 0, {autoAlpha:this.holders[3].autoAlpha, _x:0, _y:255.16, _width:263, _height:148});
				} else {
					TweenLite.to(this.holders[3], 0, {autoAlpha:this.holders[3].autoAlpha, _x:29, _y:403.25, _width:234, _height:131.625});
				}
			break;
			case 4:
				TweenLite.to(this.holders[4], 0, {autoAlpha:this.holders[4].autoAlpha, _x:29, _y:543.19, _width:234, _height:131.625});
			break;
			case 5:
				TweenLite.to(this.holders[5], 0, {autoAlpha:0, _x:29, _y:684.38, _width:234, _height:131.625});
			break;
		}
	}
	
	private function deselect()
	{
		D.debug(D.lDev, "EpisodeNav - Doing deselect...");
		var pos:Array = new Array();
		pos[0] = {autoAlpha:0, _x:29, _y:-17, _width:234, _height:131.625};
		pos[1] = {autoAlpha:this.holders[1].autoAlpha, _x:29, _y:123.38, _width:234, _height:131.625};
		pos[2] = {autoAlpha:this.holders[2].autoAlpha, _x:29, _y:263.31, _width:234, _height:131.625};
		pos[3] = {autoAlpha:this.holders[3].autoAlpha, _x:29, _y:403.25, _width:234, _height:131.625};
		pos[4] = {autoAlpha:this.holders[4].autoAlpha, _x:29, _y:543.19, _width:234, _height:131.625};
		pos[5] = {autoAlpha:0, _x:29, _y:684.38, _width:234, _height:131.625}
		//Move Episodes
		TweenLite.to(this.holders[0], 0.4, pos[0]);
		TweenLite.to(this.holders[1], 0.4, pos[1]);
		TweenLite.to(this.holders[2], 0.4, pos[2]);
		TweenLite.to(this.holders[3], 0.4, pos[3]);
		TweenLite.to(this.holders[4], 0.4, pos[4]);
		TweenLite.to(this.holders[5], 0.4, pos[5]);
	}
	
	private function _position()
	{
		D.debug(D.lDev, "EpisodeNav - Doing position...");
		var pos:Array = new Array();
		pos[0] = {autoAlpha:0, _x:29, _y:-17, _width:234, _height:131.625};
		pos[1] = {autoAlpha:this.holders[1].autoAlpha, _x:29, _y:123.38, _width:234, _height:131.625};
		pos[2] = {autoAlpha:this.holders[2].autoAlpha, _x:0, _y:255.16, _width:263, _height:148};
		pos[3] = {autoAlpha:this.holders[3].autoAlpha, _x:29, _y:403.25, _width:234, _height:131.625};
		pos[4] = {autoAlpha:this.holders[4].autoAlpha, _x:29, _y:543.19, _width:234, _height:131.625};
		pos[5] = {autoAlpha:0, _x:29, _y:684.38, _width:234, _height:131.625}
		//Move Episodes
		TweenLite.to(this.holders[0], 0.2, pos[0]);
		this.holders[0].swapDepths(1);
		TweenLite.to(this.holders[1], 0.4, pos[1]);
		this.holders[1].swapDepths(3);
		TweenLite.to(this.holders[2], 0.4, pos[2]);
		this.holders[2].swapDepths(6);
		TweenLite.to(this.holders[3], 0.4, pos[3]);
		this.holders[3].swapDepths(5);
		TweenLite.to(this.holders[4], 0.4, pos[4]);
		this.holders[4].swapDepths(4);
		TweenLite.to(this.holders[5], 0.2, pos[5]);
		this.holders[4].swapDepths(2);
	}
	
	private function newImg(intImg:Number, intHolder:Number)
	{
		D.debug(D.lDev, "EpisodeNav - Doing newImg With intImg: " + intImg + ", intHolder: " + intHolder);
		D.debug(D.lDev, "EpisodeNav - PlexData.oEpisodeData.intPos: " + PlexData.oEpisodeData.intPos);
		var _data:Array = PlexData.oEpisodeData._children;	
		var url:String = PlexAPI.getImg({width:246, height:364, key:_data[PlexData.GetRotation("oEpisodeData", intImg)].thumb});
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
			case Key.UP:
				PlexData.oEpisodeData.intPos--;
				if (PlexData.oEpisodeData.intPos < 0)
				{
					this.holders[0].autoAlpha = 0;
					PlexData.oEpisodeData.intPos = 0;
				} else {
					this.holders.unshift(this.holders.pop());
					if ((PlexData.oEpisodeData.intPos-2)>=0)
					{
						this.holders[0].autoAlpha = 100;
						this.newImg(-3, 0);
					} else {
						this.holders[0].autoAlpha = 0;
					}
				}
				this.fn("episode");
				this._position();
			break;
			case Key.DOWN:
				PlexData.oEpisodeData.intPos++;
				if (PlexData.oEpisodeData.intPos > PlexData.oEpisodeData.intLength)
				{
					this.holders[5].autoAlpha = 0;
					PlexData.oEpisodeData.intPos = PlexData.oEpisodeData.intLength;
				} else {
					this.holders.push(this.holders.shift());
					if((PlexData.oEpisodeData.intPos+3)<=PlexData.oEpisodeData.intLength)
					{
						this.holders[5].autoAlpha = 100;
						this.newImg(3, 5);
					} else {
						this.holders[5].autoAlpha = 0;
					}
				}
				this.fn("episode");
				this._position();
			break;
		}
	}

}