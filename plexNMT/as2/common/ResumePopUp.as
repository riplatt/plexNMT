import mx.utils.Delegate;

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

class plexNMT.as2.common.ResumePopUp {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.ResumePopUp;
	
	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var popUpMC:MovieClip = null;
	//key Listener
	private var keyListener:Object = null;
	private var klInterval:Number = 0;
	//Movie Clips
	private var _hightlight:MovieClip = null;
	private var _play:MovieClip = null;
	private var _resume:MovieClip = null;
	//Button Array
	private var buttons:Array = new Array();
	//Calling Page Callbackfunction
	private var fn:Function = null;

	// Initialization:
	public function ResumePopUp(parentMC:MovieClip, cb:Function)
	{
		
		popUpMC = parentMC.createEmptyMovieClip("popUpMC", 10000);
		fn = cb;
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);
		
		//Key Lister
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		//Build PopUp
		this.build();
		
		return;
	}

	// Public Methods:
	public function destroy():Void 
	{
		//Remove Listener
		this.disableKeyListener();
		Key.removeListener(this.keyListener);
		delete keyListener;
		//Highlight
		this.popUpMC._menu._highlight.removeMovieClip();
		delete this.popUpMC._menu._highlight;
		//Play button
		this.popUpMC._menu._play.removeTextField();
		delete this.popUpMC._menu._play;
		//Resume Button
		this.popUpMC._menu._resume.removeTextField();
		delete this.popUpMC._menu._resume;
		//Menu
		this.popUpMC._menu.removeMovieClip();
		delete this.popUpMC._menu;
		//PopUp
		this.popUpMC.removeMovieClip();
		delete this.popUpMC;
		
		return;
	}
	// Private Methods:
	
	private function build()
	{
		this.popUpMC.createEmptyMovieClip("_menu", popUpMC.getNextHighestDepth());
		//Background
		drawRoundedRectangle(this.popUpMC, 1280, 720, 0, 0x000000, 80, 0, 0xFFFFFF, 0);
		//Menu
		drawRoundedRectangle(this.popUpMC._menu, 350, 80, 14, 0x000000, 80, 2, 0xFFFFFF, 40);
		this.popUpMC._menu._x = 465;
		this.popUpMC._menu._y = 310;
		//Text Format
		var myFormat:TextFormat = new TextFormat();
		myFormat.align = "center";
		myFormat.font = "Arial";
		myFormat.size = 28;
		myFormat.color = 0xFFFFFF;
		//Highlight
		_hightlight = this.popUpMC._menu.createEmptyMovieClip("_highlight", popUpMC._menu.getNextHighestDepth());
		drawRoundedRectangle(popUpMC._menu._highlight, 348, 38, 15, 0x3333FF, 80, 2, 0x3333CC, 40);
		this.popUpMC._menu._highlight._x = 1;
		this.popUpMC._menu._highlight._y = 1;
		//Play Button
		_play = this.popUpMC._menu.createTextField("_play", popUpMC._menu.getNextHighestDepth(), 0, 0, 350, 40);
		this.popUpMC._menu._play.autoSize = true;
		this.popUpMC._menu._play.setNewTextFormat(myFormat);
		this.popUpMC._menu._play.text = "Play";
		this.popUpMC._menu._play._x = 175 - (this.popUpMC._menu._play._width/2);
		trace("ResumePopUp - Text Hight: " + this.popUpMC._menu._play._height);
		//Resume Button
		_resume = this.popUpMC._menu.createTextField("_resume", popUpMC._menu.getNextHighestDepth(), 0, 40, 350, 40);
		this.popUpMC._menu._resume.autoSize = true;
		this.popUpMC._menu._resume.setNewTextFormat(myFormat);
		this.popUpMC._menu._resume.text = "Resume @ " + Utils.formatTime( PlexData.oMovieData.MediaContainer[0].Video[0].attributes.duration);
		this.popUpMC._menu._resume._x = 175 - (this.popUpMC._menu._resume._width/2);
		trace("ResumePopUp - Text width: " + this.popUpMC._menu._play._width);
		
		buttons = [this._play, this._resume];
		this.enableKeyListener();
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
		trace("ResumePopUp - Doing drawRoundedRectangle with:" + mc);
		
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
	
	private function enableKeyListener():Void
	{
		D.debug(D.lDev, "ResumePopUp - Doing enableKeyListener...");
		if (this.keyListener.onKeyDown != null)
			return;
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.klInterval = _global["setInterval"](Delegate.create(this, this.onEnableKeyListener), 100); // delay abit to prevent getting the previously press key.
	}

	private function onEnableKeyListener():Void
	{
		D.debug(D.lDev, "ResumePopUp - Doing onEnableKeyListener...");
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
		D.debug(D.lDev, "ResumePopUp - keyDownCB.keyCode: " + keyCode);
		
		switch (keyCode)
		{
			case Key.UP:
				this.buttons.unshift(this.buttons.pop());
				TweenLite.to(this._hightlight, 0.3, {_y:this.buttons[0]._y});
			break;
			case Key.DOWN:
				this.buttons.push(this.buttons.shift());
				TweenLite.to(this._hightlight, 0.3, {_y:this.buttons[0]._y});
			break;
			case Remote.BACK:
			case "soft1":
				this.destroy();
				this.fn();
			break;
			case Remote.ENTER:
			case Remote.PLAY:

			break;
		}
	}

}