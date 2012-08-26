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

class plexNMT.as2.common.WallDetails {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.WallDetails;

	// Public Properties:
	// Private Properties:
	private var current:Number;
	private var parentMC:MovieClip = null;
	private var detailsMC:MovieClip = null;

	// Initialization:
	public function WallDetails(parentMC:MovieClip) {
		trace("WallDetails - parentMC:" + parentMC);
		//Utils.varDump(this.parentMC);
		trace("WallDetails - Adding new Details Box...");
		detailsMC = parentMC.createEmptyMovieClip("detailsMC", parentMC.getNextHighestDepth()); //,{_x:10, _y:600});
		trace("WallDetails - Calling draw...");
		detailsMC._x = 10 //, 50);
		detailsMC._y = 615;
		detailsMC.htmlText = "Bob";
		/*detailsMC._width = 1260;
		detailsMC._height = 90;*/
		drawRoundedRectangle(detailsMC, 1260, 90, 30, 0x000000, 80, 2, 0xCCCCCC, 40);
		current = 0;
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		TweenPlugin.activate([AutoAlphaPlugin]);

		trace("WallDetails - Dumping detailsMC...");
		Utils.varDump(detailsMC);
		return;
	}

	// Public Methods:
	public function setTitle(_title:String):Void {

	}
	public function _update(key:String):Void {

	}

	public function destroy():Void {

	}
	// Private Methods:
	private function drawRoundedRectangle(mc:MovieClip, 
										  rectWidth:Number, 
										  rectHeight:Number, 
										  cornerRadius:Number, 
										  fillColor:Number, 
										  fillAlpha:Number, 
										  lineThickness:Number, 
										  lineColor:Number, 
										  lineAlpha:Number) {
		trace("WallDetails - Doing drawRoundedRectangle with:" + mc);
		mc.beginFill(fillColor,fillAlpha);
		mc.lineStyle(lineThickness,lineColor,lineAlpha);
		mc.moveTo(cornerRadius,0);
		mc.lineTo(rectWidth-cornerRadius,0);
		mc.curveTo(rectWidth,0,rectWidth,cornerRadius);
		mc.lineTo(rectWidth,cornerRadius);
		mc.lineTo(rectWidth,rectHeight-cornerRadius);
		mc.curveTo(rectWidth,rectHeight,rectWidth-cornerRadius,rectHeight);
		mc.lineTo(rectWidth-cornerRadius,rectHeight);
		mc.lineTo(cornerRadius,rectHeight);
		mc.curveTo(0,rectHeight,0,rectHeight-cornerRadius);
		mc.lineTo(0,rectHeight-cornerRadius);
		mc.lineTo(0,cornerRadius);
		mc.curveTo(0,0,cornerRadius,0);
		mc.lineTo(cornerRadius,0);
		mc.endFill();
		/*with (mc) {
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
		}*/
	}

}