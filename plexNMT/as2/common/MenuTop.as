import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.SmallCaps;

import com.syabas.as2.common.UI;
import com.syabas.as2.common.D;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.*;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;

import mx.utils.Delegate;

class plexNMT.as2.common.MenuTop {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.MenuTop;
	
	
	// Public Properties:
		
	// Private Properties:
	private var menuMC:MovieClip = null;
	
	public function MenuTop(parentMC:MovieClip)
	{
		trace("MenuTop - parentMC:" + parentMC);
		//Utils.varDump(this.parentMC);
		trace("MenuTop - Adding new Menu Box...");
		menuMC = parentMC.createEmptyMovieClip("menuMC", parentMC.getNextHighestDepth()); //,{_x:10, _y:600});
		//trace("WallDetails - Calling draw...");
		menuMC._x = 140 //, 50);
		menuMC._y = 40;
		buildMenu(menuMC);
	}
	// Destroy all global variables.
	public function destroy():Void
	{
		
	}
	
	private function buildMenu(mc:MovieClip)
	{	
		//background
		drawRoundedRectangle(mc, 1000, 30, 10, 0x000000, 80, 2, 0xCCCCCC, 40);
		//Clock
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
		trace("MenuTop - Doing drawRoundedRectangle with:" + mc);
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
}