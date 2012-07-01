
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Remote;

class plexNMT.as2.common.MenuTop {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.MenuTop;
	
	
	// Public Properties:
		
	// Private Properties:
	////Menu Background
	private var level1Offset:Number = null;
	private var level2Offset:Number = null;
	private var level3Offset:Number = null;
	private var level1MaxX:Number = null;
	private var level2MaxX:Number = null;
	private var level3MaxX:Number = null;
	private var bgXOffset:Number = null;
	private var bgYOffset:Number = null;
	///Menu
	private var menuMC:MovieClip = null;
	private var menu1MC:MovieClip = null;
	private var menu2MC:MovieClip = null;
	private var menu3MC:MovieClip = null;
	////MovieClips
	private var parentMC:MovieClip = null;

	// Destroy all global variables.
	public function destroy():Void
	{	
		// Movie Clips
		cleanUp(this.menuMC);
		
		// Properties Delete
		level1Offset = null;
		level2Offset = null;
		level3Offset = null;
		bgXOffset = null;
		bgYOffset = null;
	}
	// Initialization:
	public function MenuTop(parentMC:MovieClip) 
	{
		if (PlexData.oData.level1.current.title == "")
		{
			
		}
		this.menuMC  = this.parentMC.createEmptyMovieClip("menuMC", this.parentMC.getNextHighestDepth());
	}
    // first entry function
    public static function start()
    {
		
    }
	
	public static function enable()
    {
		TweenLite.to(this.menu1MC.item_0, 0.7, {_alpha:100});
		TweenLite.to(this.menu1MC.item_1, 0.7, {_alpha:100, _x:50});
		TweenLite.to(this.menu1MC.item_2, 0.7, {_alpha:100, _x:100});
		TweenLite.to(this.menu1MC.item_3, 0.7, {_alpha:100, _x:150});
		
		TweenLite.to(this.menu2MC.item_0, 0.7, {_alpha:100});
		TweenLite.to(this.menu2MC.item_1, 0.7, {_alpha:100, _x:50});
		TweenLite.to(this.menu2MC.item_2, 0.7, {_alpha:100, _x:100});
		TweenLite.to(this.menu2MC.item_3, 0.7, {_alpha:100, _x:150});
		
		TweenLite.to(this.menu3MC.item_0, 0.7, {_alpha:100});
		TweenLite.to(this.menu3MC.item_1, 0.7, {_alpha:100, _x:50});
		TweenLite.to(this.menu3MC.item_2, 0.7, {_alpha:100, _x:100});
		TweenLite.to(this.menu3MC.item_3, 0.7, {_alpha:100, _x:150});
    }
	
	public static function disable()
	{
		TweenLite.to(this.menu1MC.item_0, 0.7, {_alpha:0});
		TweenLite.to(this.menu1MC.item_1, 0.7, {_alpha:100, _x:0});
		TweenLite.to(this.menu1MC.item_2, 0.7, {_alpha:0, _x:0});
		TweenLite.to(this.menu1MC.item_3, 0.7, {_alpha:0, _x:0});
		
		TweenLite.to(this.menu2MC.item_0, 0.7, {_alpha:0});
		TweenLite.to(this.menu2MC.item_1, 0.7, {_alpha:100, _x:0});
		TweenLite.to(this.menu2MC.item_2, 0.7, {_alpha:0, _x:0});
		TweenLite.to(this.menu2MC.item_3, 0.7, {_alpha:0, _x:0});
		
		TweenLite.to(this.menu3MC.item_0, 0.7, {_alpha:0});
		TweenLite.to(this.menu3MC.item_1, 0.7, {_alpha:100, _x:0});
		TweenLite.to(this.menu3MC.item_2, 0.7, {_alpha:0, _x:0});
		TweenLite.to(this.menu3MC.item_3, 0.7, {_alpha:0, _x:0});
	}
	
	private function updateMenu(i:Number) {
		
		//var i:Number = PlexData.oSettings.curLevel;
		trace("HomeMenu - Updataing the menu @ level " + i);
		PlexData.oData["level"+i].current = PlexData.oData["level"+i].items[2];
		for (var j:Number = 0; j<5; j++) {
				this["menu"+i+"MC"]["item_"+j].txt.htmlText = PlexData.oData["level"+i].items[0].title;
				PlexData.oData["level"+i].items[0].width = this["menu"+i+"MC"]["item_"+j].txt.textWidth;
				PlexData.rotateItemsLeft("level"+i);
			}

		for (var k:Number =0; k<5; k++) {
			PlexData.rotateItemsRight("level"+i);
		}
		
		this["level"+i+"MaxX"] = getMaxTxtLen(PlexData.oData["level"+i].items);
		
		switch (i)
		{
			case 1:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:100, _x:this.level1Offset});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:0, _x:150});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:0, _x:250});
				//TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.menuBGOffset});
			break;
			case 2:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:40});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.level2Offset});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:0, _x:250});
				//TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level2MaxX + this.level2Offset + this.level1MaxX + this.level1Offset + this.menuBGOffset});
			break;
			case 3:
				TweenLite.to(this.menu1MC, 1.2, {_alpha:25});
				TweenLite.to(this.menu2MC, 1.2, {_alpha:40, _x:this.level1MaxX + this.level1Offset + this.level2Offset});
				TweenLite.to(this.menu3MC, 1.2, {_alpha:100, _x:this.level1MaxX + this.level1Offset + this.level2MaxX + this.level2Offset + this.level3Offset});
				//TweenLite.to(this.menuBGMC, 0.6, {_alpha:100, _x:this.level3MaxX + this.level3Offset + this.level2MaxX + this.level2Offset + this.level1MaxX + this.level1Offset + this.menuBGOffset});

			break;
		}
			
	}
	
	private function buildMenu():Void {
		//this.backgroundMC = this.menuMC.createEmptyMovieClip("backgroundMC", this.menuMC.getNextHighestDepth());
		//this.menuBGMC = this.menuMC.attachMovie("menuBGMC", "menuBGMC", this.menuMC.getNextHighestDepth(), {_x:-1300, _alpha:0});
		this.menu3MC = this.menuMC.attachMovie("menuTopMC", "menu3MC", this.menuMC.getNextHighestDepth(), {_x:250, _y:10, _alpha:0});
		this.menu2MC = this.menuMC.attachMovie("menuTopMC", "menu2MC", this.menuMC.getNextHighestDepth(), {_x:150, _y:10, _alpha:0});
		this.menu1MC = this.menuMC.attachMovie("menuTopMC", "menu1MC", this.menuMC.getNextHighestDepth(), {_x:50, _y:10, _alpha:0});
		
		//auto size text fields
		this.menu1MC.item_0.txt.autoSize = "left";
		this.menu1MC.item_1.txt.autoSize = "left";
		this.menu1MC.item_2.txt.autoSize = "left";
		this.menu1MC.item_3.txt.autoSize = "left";
		
		this.menu2MC.item_0.txt.autoSize = "left";
		this.menu2MC.item_1.txt.autoSize = "left";
		this.menu2MC.item_2.txt.autoSize = "left";
		this.menu2MC.item_3.txt.autoSize = "left";
		
		this.menu3MC.item_0.txt.autoSize = "left";
		this.menu3MC.item_1.txt.autoSize = "left";
		this.menu3MC.item_2.txt.autoSize = "left";
		this.menu3MC.item_3.txt.autoSize = "left";
		//trace("buldMenu dumpping this...");
		//var_dump(this);
		
	}
	
	private function getMaxTxtLen(_obj:Object):Number {
		
		//trace("getMaxTxtLen Dumping _obj...");
		//var_dump(_obj);
		
		var dataLen:Number = _obj.length;
		var mxm:Number = 0;
		for(var i=0; i<dataLen; i++){
			if (_obj[i].width>mxm){
				mxm = _obj[i].width;
			}
		}
		return mxm;
	}
	
	private function cleanUp(_obj:Object)
	{
		for (var i in _obj)
		{
			if (i != "plex"){
				//trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
				if (typeof(_obj[i]) == "object" || typeof (_obj[i]) == "movieclip"){
					cleanUp(_obj[i]);
				}
				if (typeof(_obj[i]) == "movieclip"){
					//trace("Removing: " + _obj[i]);
					_obj[i].removeMovieClip();
					delete _obj[i];
				}
			}
		}
	}
}