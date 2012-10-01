﻿
import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.Remote;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.Tile;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.SetSizePlugin;

import com.syabas.as2.common.Util;
import com.syabas.as2.common.D;

import mx.utils.Delegate;

class plexNMT.as2.pages.Wall2 {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.Wall2;
	
	// Public Properties:
	// Private Properties:
	private var _wall:MovieClip = null;
	private var holders:Array = new Array();
	private var navX:Number = 0;
	private var navY:Number = 0;
	private var navHigh:Number = 0;
	private var navLow:Number = 0;
	//Key Listener
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	// Initialization:
	public function Wall2(parentMC:MovieClip) 
	{
		trace("Wall - Initializing Wall...");
		_wall = parentMC.createEmptyMovieClip("_wall", parentMC.getNextHighestDepth());
		//_wall._x = 80;
		PlexData.setWall();
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin, SetSizePlugin]);
		
		//Key Listener
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		this.enableKeyListener();
		
		//Build Stage
		setStage()
		
		//Get Wall Data
		if (PlexData.oWallData.MediaContainer[0] != undefined)
		{	
			D.debug(D.lInfo, "Wall - Already have wall data at pos: " + PlexData.oWallData.intPos);
			this.onLoadData();
		} else {
			var key:String = "/library/sections/";
			if (PlexData.oSections.MediaContainer[0] != undefined && PlexData.oCategories.MediaContainer[0] == undefined) 
			{
				key = key + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key + "/all";
			}else{
				key = key + PlexData.oSections.MediaContainer[0].Directory[PlexData.oSections.intPos].attributes.key + "/";
				key = key + PlexData.oCategories.MediaContainer[0].Directory[PlexData.oCategories.intPos].attributes.key;
			}
			if (PlexData.oFilters.MediaContainer[0] != undefined) 
			{
				key = key + PlexData.oFilters.MediaContainer[0].Directory[PlexData.oFilters.intPos].attributes.key;
			}
			D.debug(D.lInfo, "Wall - Calling getWallData with: " + key);
			//PlexData.oWallData.key = key;
			PlexAPI.getWallData(key, Delegate.create(this, this.onLoadData), PlexData.oSettings.timeout);
			//PlexAPI.getWallDataRange(key, 0, 28, Delegate.create(this, this.onLoadData), PlexData.oSettings.timeout);
		}
	}

	// Public Methods:
	public function destroy()
	{
		trace("Wall - destroying Wall...");
		//Remove Listener
		Key.removeListener(this.keyListener);
		delete keyListener;
		//Remove Main MC
		this._wall.removeMovieClip();
		delete this._wall;
	}
	// Private Methods:
	private function onLoadData()
	{
		var lenX:Number = this.holders.length;
		var lenY:Number = 0;
		var i:Number = 0;
		var j:Number = 0;
		var r:Number = 0;
		var url:String = "";
		var key:String = "";
		
		
		
		for (i=0; i<lenX; i++)
		{
			lenY = this.holders[i].length;
			//trace("Wall - onLoadData || lenX:" + lenX + ", lenY:" + lenY);
			for(j=0; j<lenY; j++)
			{
				if (PlexData.oWallData.MediaContainer[0].Directory != undefined) 
				{
					key = PlexData.oWallData.MediaContainer[0].Directory[PlexData.GetRotation("oWallData", r)].attributes.thumb;
				} else {
					key = PlexData.oWallData.MediaContainer[0].Video[PlexData.GetRotation("oWallData", r)].attributes.thumb;
				}
				url = PlexData.oSettings.url + "/photo/:/transcode?width="+PlexData.oWall.thumb.size+"&height="+PlexData.oWall.thumb.size+"&url=" + escape(PlexData.oSettings.url + Util.trim(key));
				//trace("Wall - Loading Image to " + holders[i][j]);
				this.holders[i][j]._tile.loadImg(url);
				this.holders[i][j].intPos = r;
				r++;
			}
		}
	}
	
	private function hightLight()
	{
		trace("Wall - Hight Lighting holder_"+navY+"_"+navX+"...");
		this.unHightLight();
		this.holders[navY][navX]._tile.select();
	}
	
	private function unHightLight()
	{
		//trace("Wall - un-Hight Lighting holders");
		var x:Number = 0;
		var lenX:Number = 0;//this.holders.length;
		var y:Number =0;
		var lenY:Number = this.holders.length;//0;
		for (y=0; y<lenY; y++)
		{
			lenX = this.holders[y].length;
			for (x=0; x<lenX; x++)
			{
				this.holders[y][x]._tile.deselect();
			}
		}
	}
	
	private function setStage():Void
	{
		trace("Wall - Setting Stage...");
		//position wall
		this._wall._x = PlexData.oWall.topLeft.x;
		this._wall._y = PlexData.oWall.topLeft.y;
		//Set navHigh & navLow;
		this.navHigh = PlexData.oWall.rows*2-1;
		this.navLow = this.navY = PlexData.oWall.rows;
		
		var x:Number = 0;
		var posY:Number = -2 * (PlexData.oWall.thumb.height + PlexData.oWall.vgap);
		var y:Number =0;
		var posX:Number = 0;
		for (y=0; y<PlexData.oWall.rows*3; y++)
		{
			posX = 0;
			this.holders[y] = new Array();
			for (x=0; x<PlexData.oWall.columns; x++)
			{
				trace("Wall - Setting holder["+y+"]["+x+"] to _x:"+posX+", _y:"+posY);
				this.holders[y][x] = this._wall.createEmptyMovieClip("holder_"+y+"_"+x, _wall.getNextHighestDepth());
				
				this.holders[y][x]._tile = new Tile(this.holders[y][x], "poster", PlexData.oWall.thumb.width, PlexData.oWall.thumb.height);
				TweenLite.to(this.holders[y][x], 0, {_x:posX, _y:posY});
				posX = posX + PlexData.oWall.thumb.width + PlexData.oWall.hgap;
			}
			posY = posY + PlexData.oWall.thumb.height + PlexData.oWall.vgap;
		}
		this.hightLight();
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
		trace("Wall - keyDownCB with:"+keyCode);
		
		switch (keyCode)
		{
			case Key.UP:
				//this.holders[0].unshift(this.holders[0].pop());
				navY--;
				if (navY < navLow)
				{
					navY = navLow;
				}
				this.hightLight();
			break;
			case Key.DOWN:
				//this.holders[0].push(this.holders[0].shift());
				navY++;
				if (navY > navHigh)
				{
					navY = navHigh;
				}
				this.hightLight();
			break;
			case Key.RIGHT:
				//this.holders.push(this.holders.shift());
				navX++;
				this.hightLight();
			break;
			case Key.LEFT:
				//this.holders.push(this.holders.shift());
				navX--;
				this.hightLight();
			break;
			case "soft1":
			case Remote.BACK:
			case Remote.HOME:
				this.destroy();
				PlexData.oWallData = new Object();
				gotoAndPlay("main");
			break;
			case "soft2":
			case Remote.PLAY:
				//Play Current
			break;
			case Remote.YELLOW:
				this.destroy();
				gotoAndPlay("settings");
			break;
		}
	}

}