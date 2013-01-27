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
	private var timeInterval:Number;

	public function MenuTop(parentMC:MovieClip) {
		menuMC = parentMC.createEmptyMovieClip("menuMC", parentMC.getNextHighestDepth());//,{_x:10, _y:600});
		menuMC._x = 140;//, 50);
		menuMC._y = 40;
		buildMenu(menuMC);
	}
	// Destroy all global variables.
	public function destroy():Void {
		this.menuMC.removeMovieClip();
		clearInterval(timeInterval);
	}
	
	public function _update()
	{
		//Count
		this.menuMC._count._visible = true;
		this.menuMC._count.text = (PlexData.oWallData.intPos + 1) +"/"+ (PlexData.oWallData.intLength + 1);
	}
	
	public function _select()
	{
		
	}

	private function buildMenu(mc:MovieClip) {
		var dateNow = new Date();
		//background
		mc.createEmptyMovieClip("_background",mc.getNextHighestDepth());
		drawRoundedRectangle(mc._background,1000,30,10,0x000000,80,2,0xCCCCCC,40);
		//Clock
		mc.createEmptyMovieClip("_clock",mc.getNextHighestDepth());
		mc._clock.autoSize = true;
		//Text Format
		var myFormat:TextFormat = new TextFormat();
		myFormat.align = "center";
		myFormat.font = "Arial";
		myFormat.color = 0xFFFFFF;
		myFormat.size = 18;
		//Time
		mc._clock.createTextField("_time",mc._clock.getNextHighestDepth(), 32, 2, 150, 30);
		mc._clock._time.autoSize = true;
		mc._clock._time.setNewTextFormat(myFormat);
		mc._clock._time.text = pad(String(dateNow.getHours())) + ":" + pad(String(dateNow.getMinutes()));
		drawEndcap(mc._clock,(mc._clock._time._x + mc._clock._time._width), 2, 0xCCCCCC, 40);
		timeInterval = setInterval(Delegate.create(this,updateTime),5000);
		//Section
		mc.createEmptyMovieClip("_section",mc.getNextHighestDepth());
		mc._section.createTextField("txt",mc.getNextHighestDepth(),30 + 2 + mc._clock._width, 2, 150, 30);
		if (PlexData.oSections._elementType != undefined)
		{
			mc._section.txt.autoSize = true;
			mc._section.txt.setNewTextFormat(myFormat);
			mc._section.txt.text = PlexData.oSections._children[PlexData.oSections.intPos].title;
			drawNext(mc._section,(mc._section.txt._x + mc._section.txt._width), 2, 0xCCCCCC, 40);
		}
		//Category
		mc.createEmptyMovieClip("_category",mc.getNextHighestDepth());
		mc._category.createTextField("txt",mc.getNextHighestDepth(),mc._section.txt._x + mc._section.txt._width + 7, 2, 150, 30);
		if (PlexData.oCategories._elementType != undefined)
		{
			mc._category.txt.autoSize = true;
			mc._category.txt.setNewTextFormat(myFormat);
			mc._category.txt.text = PlexData.oCategories._children[PlexData.oCategories.intPos].title;
			if (PlexData.oFilters._elementType == undefined) {
				drawEndcap(mc._category,(mc._category.txt._x + mc._category.txt._width), 2, 0xCCCCCC, 40);
			} else {
				drawNext(mc._category,(mc._category.txt._x + mc._category.txt._width), 2, 0xCCCCCC, 40);
			}
		}
		//Filter
		mc.createEmptyMovieClip("_filter",mc.getNextHighestDepth());
		mc._filter.createTextField("txt",mc.getNextHighestDepth(),mc._category.txt._x + mc._category.txt._width + 7, 2, 150, 30);
		mc._filter.txt.autoSize = true;
		mc._filter.txt.setNewTextFormat(myFormat);
		if (PlexData.oFilters._elementType != undefined)
		{
			mc._filter.txt.text = PlexData.oFilters._children[PlexData.oFilters.intPos].title;
			drawEndcap(mc._filter,(mc._filter.txt._x + mc._filter.txt._width), 2, 0xCCCCCC, 40);
		}else{
			mc._filter.txt.text = ""
		}
		//Count
		mc.createTextField("_count", mc.getNextHighestDepth(), mc._filter.txt._x + mc._filter.txt._width + 7, 2, 150, 30);
		mc._count.autoSize = true;
		mc._count.setNewTextFormat(myFormat);
		mc._count._visible = false;
		mc._count.text = (PlexData.oWallData.intPos + 1) +"/"+ (PlexData.oWallData.intLength + 1);
		
	}

	private function drawEndcap(mc:MovieClip, posX:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number) {
		//trace("MenuTop - Doing drawEndcap with:" + mc + ", posX:" + posX);
		var x:Number = mc._x+mc._width;
		//trace("MenuTop - x:"+x);
		with (mc) {
			lineStyle(lineThickness,lineColor,lineAlpha);
			moveTo(posX, 1);
			curveTo(posX + 5, 1, posX + 5, 11);
			lineTo(posX + 5, 19);
			curveTo(posX + 5, 28, posX, 28);
		}
	}
	
	private function drawNext(mc:MovieClip, posX:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number) {
		//trace("MenuTop - Doing drawNext with:" + mc + ", posX:" + posX);
		with (mc) {
			lineStyle(lineThickness,lineColor,lineAlpha);
			moveTo(posX, 1);
			//curveTo(posX + 5, 1, posX + 5, 11);
			lineTo(posX + 5, 15);
			//curveTo(posX + 5, 28, posX, 28);
			lineTo(posX, 28);
		}
	}
	
	private function updateTime()
	{
		var dateNow = new Date();
		this.menuMC._clock._time.text = pad(String(dateNow.getHours())) + ":" + pad(String(dateNow.getMinutes()));
	}

	private function drawRoundedRectangle(mc:MovieClip, rectWidth:Number, rectHeight:Number, cornerRadius:Number, fillColor:Number, fillAlpha:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number) {
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
		with (mc) {
			lineStyle(2,0xCCCCCC,40);
			moveTo(30,1);
			lineTo(30,29);
		}
	}
	private function pad(arg) {
		if (length(arg) == 1) {
			arg = "0"+arg;
			return arg;
		} else {
			arg = arg;
			return arg;
		}
	}
}