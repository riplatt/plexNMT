﻿import plexNMT.as2.common.LoadManager;
import plexNMT.as2.common.Utils;

import com.greensock.TweenLite;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.SetSizePlugin;
import com.greensock.plugins.GlowFilterPlugin;

import mx.utils.Delegate;
import flash.filters.*;

class plexNMT.as2.common.Tile {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.Tile;
	
	// Public Properties:
	// Private Properties:
	private var _tile:MovieClip = null;
	private var _selection:MovieClip = null;
	private var _background:MovieClip = null;
	private var _image:MovieClip = null;
	private var _foreground:MovieClip = null;
	private var imgLoader:LoadManager = null;
	private var imgWidth:Number = 0;
	private var imgHeight:Number = 0;
	// Initialization:
	public function Tile(parentMC:MovieClip, type:String, width:Number, height:Number) 
	{
		//GreenSock Tween Control
		TweenPlugin.activate([AutoAlphaPlugin, GlowFilterPlugin, SetSizePlugin]);
		TweenLite.defaultOverwrite = "preexisting";
		
		this._tile = parentMC.createEmptyMovieClip("_tile", parentMC.getNextHighestDepth());
		this.imgWidth = width;
		this.imgHeight = height;
		build(type);
	}

	// Public Methods:
	public function destroy():Void
	{
		//Remove Background
		this._background.removeMovieClip();
		delete this._background;
		//Remove Image
		this._image.removeMovieClip();
		delete this._image;
		//Remove Foreground
		this._foreground.removeMovieClip();
		delete this._foreground;
		//Remove Main Movie Clip
		this._tile.removeMovieClip();
		delete this._tile;
	}
	
	public function loadImg(url:String):Void
	{
		this.cancelLoad();
		this.imgLoader = new LoadManager(url, this._image);
		this.imgLoader.addEventListener('onLoadComplete', Delegate.create(this, onImageLoad));
		this.imgLoader.beginLoad();
	}
	
	public function select():Void
	{
		//trace("Tile - Doing select on:"+this._tile);
		TweenLite.to(this._foreground, 0.1, {autoAlpha:0});
		TweenLite.to(this._selection, 0.1, {autoAlpha:100});
	}
	
	public function deselect():Void
	{
		//trace("Tile - Doing deselect on:"+this._tile);
		TweenLite.to(this._foreground, 0, {autoAlpha:40});
		TweenLite.to(this._selection, 0, {autoAlpha:0});
	}
	// Private Methods:
	private function onImageLoad():Void
	{
		//trace("Tile - Doing onImageLoad with:"+this._tile);
		TweenLite.to(this._image, 0.1, {autoAlpha:100, _width:this.imgWidth, _height:this.imgHeight});
		TweenLite.to(this._background, 0, {delay:0.7, onComplete:Delegate.create(this, noBackground)});		
	}
	
	private function noBackground():Void
	{
		//trace("Tile - unloading Movie Clip on:"+this._background);
	 	this._background.unloadMovie();
	}
	
	private function cancelLoad():Void
	{
		if (this.imgLoader != null)
		{
			this.imgLoader.destroy();
			this.imgLoader = null;
		}
		TweenLite.to(this._image, 0, {autoAlpha:0});
	}
	
	private function build(type:String)
	{
		this._selection = this._tile.attachMovie("posterGlow", "_selection", 0);
		this._selection._visible = false;
		this._selection._alpha = 0;
		TweenLite.to(this._selection, 0, {_width:this.imgWidth*1.13, _height:this.imgHeight*1.084});
		
		this._background = this._tile.attachMovie(type, "_background", 1);
		this._background._visible = true;
		this._background._alpha = 100;
		TweenLite.to(this._background, 0, {_width:this.imgWidth, _height:this.imgHeight});
		
		this._image = this._tile.createEmptyMovieClip("_image", 2);
		this._image._visible = false;
		this._image._alpha = 0;

		this._foreground = this._tile.attachMovie(type, "_foreground", 3);
		this._foreground._visible = true;
		this._foreground._alpha = 40;
		TweenLite.to(this._foreground, 0, {_width:this.imgWidth, _height:this.imgHeight});
		//Utils.traceVar(this._tile)
	}

}