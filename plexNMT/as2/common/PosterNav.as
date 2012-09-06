import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Remote;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.GlowFilterPlugin;

import mx.utils.Delegate;

class plexNMT.as2.common.PosterNav {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.PosterNav;
	
	// Public Properties:
	// Private Properties:
	private var poster:MovieClip = null;
	private var holders:Array = new Array();
	private var holder1:MovieClip = null;
	private var holder2:MovieClip = null;
	private var holder3:MovieClip = null;
	private var holder4:MovieClip = null;
	private var holder5:MovieClip = null;
	private var wallData:Array = new Array();
	private var selectToggle:Boolean = false;
	
	
	private var keyListener:Object = null;
	private var klInterval:Number = 0;

	// Initialization:
	public function PosterNav(parentMC:MovieClip, data:Array) 
	{
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([GlowFilterPlugin, AutoAlphaPlugin]);
		
		//Key Listener
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		wallData = data;
		parentMC.createEmptyMovieClip("posters", parentMC.getNextHighestDepth());
		buildHolders(parentMC.posters)
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
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
	}
	// Private Methods:
	private function buildHolders(mc:MovieClip)
	{
		trace("PosterNav - Doing buildHolders with: " + mc);
		holder1 = mc.createEmptyMovieClip("holder1", 1); //, -198, 11, 156, 231);
		holder1.pos = 1;
		holder1._alpha = 0;
		holder1._visible = false;
		var h1URL:String = PlexAPI.getImg({width:156, height:231,
									  key:wallData[PlexData.GetRotation("oWallData",-2)].attributes.thumb});
		UI.loadImage(h1URL, holder1, "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:"holder1"});
		
		holder2 = mc.createEmptyMovieClip("holder2", 3); //, 18, 11, 156, 231);
		holder2.pos = 2;
		holder2._alpha = 0;
		holder2._visible = false;
		var h2URL:String = PlexAPI.getImg({width:156, height:231,
									  key:wallData[PlexData.GetRotation("oWallData",-1)].attributes.thumb});
		UI.loadImage(h2URL, holder2, "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:"holder2"});
		
		holder3 = mc.createEmptyMovieClip("holder3", 5); //, 156, 180, 246, 364);
		holder3.pos = 3;
		holder3._alpha = 0;
		holder3._visible = false;
		holder3.url = PlexAPI.getImg({width:246, height:364,
									  key:wallData[PlexData.GetRotation("oWallData",0)].attributes.thumb});
		UI.loadImage(holder3.url, holder3, "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:"holder3"});
		
		holder4 = mc.createEmptyMovieClip("holder4", 4); //, 18, 479, 156, 231);
		holder4.pos = 4;
		holder4._alpha = 0;
		holder4._visible = false;
		var h4URL:String = PlexAPI.getImg({width:156, height:231,
									  key:wallData[PlexData.GetRotation("oWallData",1)].attributes.thumb});
		UI.loadImage(h4URL, holder4, "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:"holder4"});
		
		holder5 = mc.createEmptyMovieClip("holder5", 2); //, -198, 479, 156, 231);
		holder5.pos = 5;
		holder5._alpha = 0;
		holder5._visible = false;
		var h5URL:String = PlexAPI.getImg({width:156, height:231,
									  key:wallData[PlexData.GetRotation("oWallData",2)].attributes.thumb});
		UI.loadImage(h5URL, holder5, "img",{doneCB:Delegate.create(this, this.onHolderLoad), holder:"holder5"});
		
		this.holders = [holder1, holder2, holder3, holder4, holder5];
		
		
		//Move/Resize Position 3 to un selected state
		//TweenLite.to(holder3, 30, {autoAlpha:100, _x:0, _y:333, onCompleteScope:this, onComplete:reloadImg, onCompleteParams:["holder3", holder3.url]});
	}
	
	private function onHolderLoad(success:Boolean, o:Object)
	{
		trace("PosterNav - Doing onHolderLoad with: " + o.o.holder);
		var holder:String = o.o.holder
		switch (holder)
		{
			case "holder1":
				TweenLite.to(this.holder1, 0, {autoAlpha:0, _x:-198, _y:11, _width:156, _height:231});
			break;
			case "holder2":
				TweenLite.to(this.holder2, 0, {autoAlpha:0, _x:18, _y:11, _width:156, _height:231});
			break;
			case "holder3":
				TweenLite.to(this.holder3, 0, {autoAlpha:100, _x:0, _y:125.04, _width:402, _height:595}); //, onCompleteScope:this, onComplete:position, onCompleteParams:["holder3", this.holder3.url]});
			break;
			case "holder4":
				TweenLite.to(this.holder4, 0, {autoAlpha:0, _x:18, _y:479, _width:156, _height:231});
			break;
			case "holder5":
				TweenLite.to(this.holder5, 0, {autoAlpha:0, _x:-198, _y:479, _width:156, _height:231, onCompleteScope:this, onComplete:deselect});
			break;
		}
	}
	private function deselect()
	{
		trace("PosterNav - Doing deselect...");
		var pos:Array = new Array();
		pos[0] = {autoAlpha:0}; //, onCompleteScope:this, onComplete:newImg, onCompleteParams:[-2, 0]};
		pos[1] = {autoAlpha:0};
		pos[2] = {autoAlpha:100, _x:0, _y:125.04, _width:402, _height:595};
		pos[3] = {autoAlpha:0};
		pos[4] = {autoAlpha:0}; //, onCompleteScope:this, onComplete:newImg, onCompleteParams:[2, 4]};
		//Move Posters
		TweenLite.to(this.holders[0], 0.4, pos[0]);
		TweenLite.to(this.holders[1], 0.4, pos[1]);
		TweenLite.to(this.holders[2], 0.4, pos[2]);
		TweenLite.to(this.holders[3], 0.4, pos[3]);
		TweenLite.to(this.holders[4], 0.4, pos[4]);
	}
	
	private function _position()
	{
		trace("PosterNav - Doing position...");
		var pos:Array = new Array();
		pos[0] = {autoAlpha:0, _x:-198, _y:11, _width:156, _height:231}; //, onCompleteScope:this, onComplete:newImg, onCompleteParams:[-2, 0]};
		pos[1] = {autoAlpha:100, _x:18, _y:11, _width:156, _height:231};
		pos[2] = {autoAlpha:100, _x:156, _y:179.64, _width:246, _height:364.08};
		pos[3] = {autoAlpha:100, _x:18, _y:479, _width:156, _height:231};
		pos[4] = {autoAlpha:0, _x:-198, _y:479, _width:156, _height:231}; //, onCompleteScope:this, onComplete:newImg, onCompleteParams:[2, 4]};
		//Move Posters
		TweenLite.to(this.holders[0], 0.4, pos[0]);
		this.holders[0].swapDepths(1);
		TweenLite.to(this.holders[1], 0.4, pos[1]);
		this.holders[0].swapDepths(3);
		TweenLite.to(this.holders[2], 0.4, pos[2]);
		this.holders[0].swapDepths(5);
		//TweenLite.to(this.holders[2].img, 1.4, {glowFilter:{color:0x0000ff, alpha:1, blurX:15, blurY:15, strength:1}});
		TweenLite.to(this.holders[3], 0.4, pos[3]);
		this.holders[0].swapDepths(4);
		TweenLite.to(this.holders[4], 0.4, pos[4]);
		this.holders[0].swapDepths(2);
	}
	
	private function newImg(intImg:Number, intHolder:Number)
	{
		trace("PosterNav - Doing newImg With intImg: " + intImg + ", intHolder: " + intHolder);
		trace("PosterNav - PlexData.oWallData.intPos: " + PlexData.oWallData.intPos);
		var url:String = PlexAPI.getImg({width:246, height:364,
									  key:wallData[PlexData.GetRotation("oWallData", intImg)].attributes.thumb});
		UI.loadImage(url, holders[intHolder], "img");
	}
	
	private function reloadImg(holder:String, url:String)
	{
		trace("PosterNav - holder3._width: " + this.holder3._width);
		trace("PosterNav - holder3._height: " + this.holder3._height);
		trace("PosterNav - holder3._xscale: " + this.holder3._xscale);
		trace("PosterNav - holder3._yscale: " + this.holder3._yscale);
		
		this.holder3._xscale = 100;
		this.holder3._yscale = 100;
		this.holder3.url = PlexAPI.getImg({width:402, height:595,
									  key:wallData[PlexData.GetRotation("oWallData", 0)].attributes.thumb});
		UI.loadImage(this.holder3.url, this.holder3, "img", {scaleMode:1});
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
				this.holders.unshift(this.holders.pop());
				PlexData.oWallData.intPos--;
				if (PlexData.oWallData.intPos < 0)
				{
					PlexData.oWallData.intPos = PlexData.oWallData.intLength;
				}
				this.newImg(-2, 0);
				this._position();
			break;
			case Key.DOWN:
				this.holders.push(this.holders.shift());
				PlexData.oWallData.intPos++;
				if (PlexData.oWallData.intPos > PlexData.oWallData.intLength)
				{
					PlexData.oWallData.intPos = 0;
				}
				this.newImg(2, 4);
				this._position();
			break;
		}
	}

}