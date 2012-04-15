
import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.FPS;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import com.adobe.as2.MobileSharedObject;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;

//import caurina.transitions.Tweener;

import mx.utils.Delegate;

class plexNMT.as2.pages.HomeMenu {

	// Constants:
	public static var CLASS_REF = plexNMT.as2.pages.HomeMenu;
	public static var plexURL:String = "http://192.168.1.3:32400/";

	// Public Properties:
	// Private Properties:
	private var plexSO:MobileSharedObject = null;
	private var plex:Object = new Object();
	private var history:Object = new Object();
	private var wallData:Array = new Array();
	private var backgroundData:Array = new Array();
	private var firstMenuMaxX:Number = null;
	private var secondMenuMaxX:Number = null;
	private var thirdMenuMaxX:Number = null;
	private var currImg:String = null;
	private var arrPos:Number = 0;
	private var crossfadeInterval:Number = null;
	//private var fpsComp:FPS = null;
	//private var myTimeline:TimelineLite = null;
	//Home Data
	private var firstHistory:Array = null;
	private var secondHistory:Array = null;
	private var thirdHistory:Array = null;
	private var firstData:Array = null;
	private var secondData:Array = null;
	private var thirdData:Array = null;
	private var firstAge:Number = null;
	private var secondAge:Number = null;
	private var thirdAge:Number = null;
	//Menu Background
	private var firstOffset:Number = null;
	private var secondOffset:Number = null;
	private var thirdOffset:Number = null;
	//MovieClips
	private var parentMC:MovieClip = null;
	private var mainMC:MovieClip = null;
	private var movFrameRateMC:MovieClip = null;
	private var backgroundMC:MovieClip = null;
	private var menuBGMC:MovieClip = null;
	private var gFirstMenuMC:MovieClip = null;
	private var gSecondMenuMC:MovieClip = null;
	private var gThirdMenuMC:MovieClip = null;
	//Grids
	private var g11:GridLite = null;
	private var g12:GridLite = null;
	private var g13:GridLite = null;
	private var g14:GridLite = null;
	private var g15:GridLite = null;
	private var g21:GridLite = null;
	private var g22:GridLite = null;
	private var g23:GridLite = null;
	private var g24:GridLite = null;
	private var g25:GridLite = null;
	private var g31:GridLite = null;
	private var g32:GridLite = null;
	private var g33:GridLite = null;
	private var g34:GridLite = null;
	private var g35:GridLite = null;

	// Initialization:
	public function HomeMenu(parentMC:MovieClip) {

		trace("Doing HomeMenu with: "+parentMC);
		this.parentMC = parentMC;
		this.mainMC = this.parentMC.createEmptyMovieClip("mainMC", this.parentMC.getNextHighestDepth());
		
		this.firstOffset = 100;
		this.secondOffset = 10;
		this.thirdOffset = 10;
		
		//FPS
		/*this.fpsComp = new FPS();
		trace(fpsComp.fps);*/
		
		//Shared Objects
		plexSO = new MobileSharedObject(this.mainMC.out_0);
		//var bob:Object = plexSO.readFromSO();
		//trace("Dumping bob");
		//var_dump(bob);
		//Restore Histroy
		this.plex = _level0.plex.home;
		trace(_level0.plex);
		trace("Dumping plex");
		var_dump(plex);
		trace("plex.arrPos: " + plex.arrPos);
		(plex.arrPos)? arrPos = plex.arrPos : arrPos = 0 ;
		(plex.history)? history = plex.history : history = null;
		
		(plex.first.history)? firstHistory = plex.first.history : firstHistory = null;
		(plex.first.data)? firstData = plex.first.data : firstData = null;
		(plex.first.age)? firstAge = plex.first.age : firstAge = null;
		
		(plex.second.history)? secondHistory = plex.second.history : secondHistory = null;
		(plex.second.data)? secondData = plex.second.data : secondData = null;
		(plex.second.age)? secondAge = plex.second.age : secondAge = null;
		
		(plex.third.history)? thirdHistory = plex.third.history : thirdHistory = null;
		(plex.third.data)? thirdData = plex.third.data : thirdData = null;
		(plex.third.age)? thirdAge = plex.third.age : thirdAge = null;
		
		//GreenSock Tween Control
		OverwriteManager.init(OverwriteManager.PREEXISTING);
		
		this.setStage();

		this.loadFirstMenu();
		this.loadRecentlyAdded();

	}

	// Public Methods:
	public function destroy():Void {
		
		//Destroy Girds
		//var_dump(_level0);
		for (var i:Number = 1; i<4; i++) {
			for(var j:Number = 1; j<5; j++){
				this["g" + i + j].destroy();
				delete this["g" + i + j];
				this["g" + i + j] = null;
			}
		}
		
		//Destroy Movie Clips
		cleanUp(this.parentMC);
		
		//Var
		this.plex = null;
		this.history = null;
		this.backgroundData = null;
		
		//Arrays
		//firstHistory.splice(0);
		delete firstHistory;
		//firstData.splice(0);
		delete firstData;
		
		//secondHistory.splice(0);
		delete secondHistory;
		//secondData.splice(0);
		delete secondData;
		
		//thirdHistory.splice(0);
		delete thirdHistory;
		//thirdData.splice(0);
		delete thirdData;
		
		//delete plexSO;
		//Timers
		clearInterval(crossfadeInterval);
		
		trace("Done Destroying...");
		//var_dump(_level0);
		
	}

	// Private Methods:
	private function loadFirstMenu() {
		if (plexSO.readFromSO("plexIP") == null)
		{
			//this.destroy();
			//gotoAndPlay("settings");
			trace("plexIP Not Set...");
		}
		trace("Doing HomeMenu.loadFirstMenu...");
		trace("firstHistory: " + firstHistory);
		trace("secondHistory: " + secondHistory);
		trace("thirdHistory: " + thirdHistory);
		
		//trace(g11);
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		trace("firstData: " + firstData + ", firstAge: " + firstAge + ", timeTemp: " + timeTemp);
		if (firstData != null && timeTemp < firstAge) {
			trace("Loading First Menu With Previous Data...");
			onLoadFirstMenu(firstData)
		} else {
			firstAge = todayData.getTime() + 1800000; //30mins from now
			trace("Loading URL "+plexURL+"library/sections");
			PlexAPI.loadData(plexURL+"library/sections",Delegate.create(this, this.onLoadFirstMenu),5000);
		}
	}

	private function onLoadFirstMenu(data:Array) {
		//Add Exit and Setting to Menu
		data.push({title:"Exit", key:"0", url:"system?arg0=load_launcher", menu:"exit"}
				  ,{title:"Settings", key:"0", url:"", menu:"settings"}
				  //,{title:"Substrate", key:"0", url:"", menu:"substrate"}
				  );

		firstData = data;

		this.g11.data = this.g12.data = this.g13.data = this.g14.data = this.g15.data = data;

		this.g11.createUI(0);
		this.g12.createUI(0);
		this.g13.createUI(0);
		this.g14.createUI(0);
		this.g15.createUI(0);

		var dataLen = data.length;
		
		this.firstMenuMaxX = getMaxTxtLen(this.g11);
		
		if(firstHistory != null && firstHistory != undefined) {
			trace("Doing First Menu From History...");
			for (var i:Number = 0; i<5; i++) {
				//trace(history.first[i]);
				this["g1"+(i+1)].highlight(firstHistory[i]);
			}
			
			menuBGMC._alpha = 0;
			TweenLite.to(gFirstMenuMC, 0.7, {_alpha:100, _x:50});
			TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.firstMenuMaxX + firstOffset - 1300});
			if(secondHistory != null && secondHistory != undefined) {
				trace("secondHistory: " + secondHistory);
				this.loadSecondMenu();
				/*trace("secondHistory: ");
				var_dump(secondHistory);*/
			}
		} else {
			trace("Doing First Menu With New Data...");
			if (dataLen>0) {
				var d:Number = dataLen-2;
				for (var i:Number = 1; i<6; i++) {
					if (d>dataLen-1) {
						d = 0;
					}
					this["g1"+i].highlight(d);
					//this["g1"+i + "_0_0"].txt.autoSize = true
					d++;
				}			
			//trace("this.firstMenuMaxX: " + this.firstMenuMaxX);
			menuBGMC._alpha = 0;
			TweenLite.to(gFirstMenuMC, 0.7, {_alpha:100, _x:50});
			TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.firstMenuMaxX + firstOffset - 1300});
			//firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
			} else {
				trace("Error no length to first menu data...");
			}
		}
	}

	private function loadSecondMenu(_obj:Object):Void {
		trace("Doing loadSecondMenu with: " + _obj);
		
		firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
		//var_dump(history);
		
		var data:Object = _obj.data;
		if (data == undefined || data == null){
			//trace("Doing loadSecondMenu.data is null getting data...");
			_obj = this.g13.getData(this.g13._hl);
		}
		//trace("Got data for: " + _obj);
		//var_dump(_obj);
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		if (secondData != null && timeTemp < secondAge) {
			trace("Loading Seconds Menu With Previous Data...");
			onLoadSecondMenu(secondData)
		} else {
			secondAge = todayData.getTime() + 18000000; //30mins from now
			PlexAPI.loadData(_obj.url,Delegate.create(this, this.onLoadSecondMenu), 5000);
		}
	}

	private function onLoadSecondMenu(data:Array):Void {
		if (data[0].menu == "secondary") {
			secondData = data;
			this.g21.data = this.g22.data = this.g23.data = this.g24.data = this.g25.data = data;

			this.g21.createUI(0);
			this.g22.createUI(0);
			this.g23.createUI(0);
			this.g24.createUI(0);
			this.g25.createUI(0);

			var dataLen = data.length;
			
			this.secondMenuMaxX = getMaxTxtLen(this.g21);
			
			if(secondHistory != null && secondHistory != undefined) {
				trace("Doing Second Menu From History...");
				for (var i:Number = 0; i<5; i++) {
					trace("Setting g2" + (i+1) + " to " + secondHistory[i]);
					this["g2"+(i+1)].highlight(secondHistory[i]);
					this["g1"+(i+1)].unhighlight()
				}
				
				gSecondMenuMC._x = this.firstMenuMaxX + 60;
				gSecondMenuMC._alpha = 0;
				TweenLite.to(gSecondMenuMC, 0.6, {_alpha:100});
				TweenLite.to(gFirstMenuMC, 0.6, {_alpha:40, _x:50});
				TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.secondMenuMaxX + secondOffset + this.firstMenuMaxX + firstOffset - 1300});
				
				if(thirdHistory != null && thirdHistory != undefined) {
					trace("thirdHistory: " + thirdHistory);
					this.loadThirdMenu();
				}
			} else {
				if (dataLen>0) {
					var d:Number = dataLen-2;
					for (var i:Number = 1; i<6; i++) {
						if (d>dataLen - 1) {
							d = 0;
						}
						this["g2"+i].highlight(d);
						d++;
					}

				gSecondMenuMC._x = this.firstMenuMaxX + 60;
				gSecondMenuMC._alpha = 0;
				TweenLite.to(gSecondMenuMC, 0.6, {_alpha:100});
				TweenLite.to(gFirstMenuMC, 0.6, {_alpha:40, _x:50});
				TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.secondMenuMaxX + secondOffset + this.firstMenuMaxX + firstOffset - 1300});
			
				} else {
					trace("Error no length to second menu data...");
				}
			}
		} else {
			trace("Second Menu Goto Load Page");
			firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
			secondHistory = [this.g21._hl, this.g22._hl, this.g23._hl, this.g24._hl, this.g25._hl];
			thirdHistory = null;
			wallData = data;
			loadPage(data);
		}
	}

	private function loadThirdMenu(_obj:Object):Void {
		trace("Doing loadThirdMenu with: " + _obj);
		//var_dump(_obj);
		
		secondHistory = [this.g21._hl, this.g22._hl, this.g23._hl, this.g24._hl, this.g25._hl];
		
		var data:Object = _obj.data;
		if (data == undefined || data == null){
			//trace("Doing loadSecondMenu.data is null getting data...");
			_obj = this.g23.getData(this.g23._hl);
		}
		//trace("Got data for: " + _obj);
		//var_dump(_obj);
		var todayData:Date = new Date();
		var timeTemp:Number = todayData.getTime();
		if (thirdData != null && timeTemp < thirdAge) {
			trace("Loading Third Menu With Previous Data...");
			onLoadThirdMenu(thirdData)
		} else {
			thirdAge = todayData.getTime() + 18000000; //30mins from now
			PlexAPI.loadData(_obj.url, Delegate.create(this, this.onLoadThirdMenu),5000);
		}
	}

	private function onLoadThirdMenu(data:Array):Void {
		//trace("Doing onLoadThirdMenu with: " + data);
		gFirstMenuMC._alpha = 66;
		thirdData = data;
		if (data[0].menu == "secondary") {
			
			gThirdMenuMC._alpha = 0;
			this.g31.data = this.g32.data = this.g33.data = this.g34.data = this.g35.data=data;

			this.g31.createUI(0);
			this.g32.createUI(0);
			this.g33.createUI(0);
			this.g34.createUI(0);
			this.g35.createUI(0);
			
			var dataLen = data.length;

			this.thirdMenuMaxX = getMaxTxtLen(this.g31);
			if(thirdHistory != null && thirdHistory != undefined) {
				trace("Doing third Menu From History...");
				for (var i:Number = 0; i<5; i++) {
					trace("Setting g2" + (i+1) + " to " + thirdHistory[i]);
					this["g3"+(i+1)].highlight(thirdHistory[i]);
					this["g2"+(i+1)].unhighlight()
				}
				
				gThirdMenuMC._x = gSecondMenuMC._x + gSecondMenuMC._width + 10;
				trace("gFirstMenuMC._alpha: " + gFirstMenuMC._alpha + ", gSecondMenuMC._alpha: " + gSecondMenuMC._alpha);
				gFirstMenuMC._alpha = 40;
				TweenLite.to(gThirdMenuMC, 0.6, {_alpha:100});
				TweenLite.to(gSecondMenuMC, 0.6, {_alpha:40});
				TweenLite.to(gFirstMenuMC, 0.6, {_alpha:25, _x:50});
				TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.thirdMenuMaxX + thirdOffset + this.secondMenuMaxX + secondOffset + this.firstMenuMaxX + firstOffset - 1300});

			} else {
				if (dataLen>0) {
					var d:Number = dataLen-2;
					for (var i:Number = 1; i<6; i++) {
						if (d>dataLen - 1) {
							d = 0;
						}
						this["g3"+i].highlight(d);
						//trace(": "+this["g2"+i].highlight(d));
						d++;
					}
					
					gThirdMenuMC._x = gSecondMenuMC._x + gSecondMenuMC._width + 10;
					trace("gFirstMenuMC._alpha: " + gFirstMenuMC._alpha + ", gSecondMenuMC._alpha: " + gSecondMenuMC._alpha);
					gFirstMenuMC._alpha = 40;
					TweenLite.to(gThirdMenuMC, 0.6, {_alpha:100});
					TweenLite.to(gSecondMenuMC, 0.6, {_alpha:40});
					TweenLite.to(gFirstMenuMC, 0.6, {_alpha:25, _x:50});
					TweenLite.to(menuBGMC, 0.6, {_alpha:100, _x:this.thirdMenuMaxX + thirdOffset + this.secondMenuMaxX + secondOffset + this.firstMenuMaxX + firstOffset - 1300});
				
				} else {
					trace("Error no length to second menu data...");
				}
			}
		} else {
			firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
			secondHistory = [this.g21._hl, this.g22._hl, this.g23._hl, this.g24._hl, this.g25._hl];
			thirdHistory = null;
			wallData = data;
			loadPage(data);
		}
	}

	private function onItemUpdateCB(_obj:Object):Void {
		//trace("Doing HomeMenu.onItemUpdateCB for: " + _obj.data.title);
		//var_dump(_obj.data);
		_obj.mc.txt.htmlText = _obj.data.title;
		_obj.mc.txt.autoSize = true;
		
	}

	private function onItemClearCB(_obj:Object):Void {
		_obj.mc.txt.htmlText = "";
	}

	private function menuOverRightCB():Boolean {
		return false;
	}

	private function menuOverLeftCB():Boolean {
		return false;
	}

	private function firstMenuOverRightCB(_obj:Object):Boolean {
		//trace("Doing firstMenuOverRightCB with: ");
		//var_dump(_obj.data);
		//loadSecondMenu(_obj.data.url);
		return false;
	}

	private function firstOnEnterCB(_obj:Object):Void {
		//trace("Doing firstOnEnterCB with: ");
		//firstData = null;
		firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
		secondHistory = null;
		thirdHistory = null;
		var data:Array = new Array();
		//var_dump(_obj.data);
		_obj.data.url = _obj.data.url + "/all";
		data.push(_obj.data)
		wallData = null;
		loadPage(data);
	}

	private function secondMenuOverRightCB():Boolean {
		//loadThirdMenu(_obj.data.url);
		return false;
	}

	private function cleanSecondMenuCB() {
		TweenLite.to(gSecondMenuMC, 0.6, {_alpha:0});
		TweenLite.to(gFirstMenuMC, 0.6, {_alpha:100, _x:50});
		TweenLite.to(menuBGMC, 0.6, {_x:this.firstMenuMaxX + firstOffset - 1300});
		
		secondHistory = null;
		secondData = null;
		
		for (var i:Number = 0; i<5; i++) {
			//trace(history.first[i]);
			this["g1"+(i+1)].highlight(firstHistory[i]);
		}
	}
	private function clearG2():Void {
		//trace("Clearing G2");
		for (var i:Number = 0; i<5; i++) {
			this["g2"+(i+1)].clear();
		}
	}

	private function secondOnEnterCB(_obj:Object) {
		//trace("Doing secondOnEnterCB with: ");
		loadThirdMenu();
	}

	private function thirdMenuOnEnterCB(_obj:Object):Void {
		trace("Doing thirdOnEnterCB with: ");
		var data:Array = new Array();
		
		firstHistory = [this.g11._hl, this.g12._hl, this.g13._hl, this.g14._hl, this.g15._hl];
		secondHistory = [this.g21._hl, this.g22._hl, this.g23._hl, this.g24._hl, this.g25._hl];
		thirdHistory = [this.g31._hl, this.g32._hl, this.g33._hl, this.g34._hl, this.g35._hl];
		
		wallData = null;
		_obj.data.url = _obj.data.url;
		data.push(_obj.data)
		loadPage(data);
	}
	
	private function cleanThirdMenuCB() {
		trace("gFirstMenuMC._alpha: " + gFirstMenuMC._alpha + ", gSecondMenuMC._alpha: " + gSecondMenuMC._alpha);
		TweenLite.to(gThirdMenuMC, 0.6, {_alpha:0});
		TweenLite.to(gSecondMenuMC, 0.6, {_alpha:100});
		TweenLite.to(gFirstMenuMC, 0.6, {_alpha:40, _x:50});
		TweenLite.to(menuBGMC, 0.6, {_x:this.secondMenuMaxX + secondOffset + this.firstMenuMaxX + firstOffset - 1300});
		thirdHistory = null;
		thirdData = null;
		
		for (var i:Number = 0; i<5; i++) {
			this["g2"+(i+1)].highlight(history.second[i]);
		}
	}
	
	private function clearG3():Void {
		//trace("Clearing G3");
		for (var i:Number = 0; i<5; i++) {
			this["g3"+(i+1)].clear();
		}
	}

	private function loadPage(data:Array):Void {
		
		trace("Doing loadPage...");
		//var_dump(data);
		
		var page:String = data[0].menu;

		switch (page) {
			case "exit" :
				this.destroy();
				Util.loadURL("http://127.0.0.1:8008/system?arg0=load_launcher");
				break;
			case "settings" :
				this.destroy();
				gotoAndPlay("settings");
				break;
			case "substrate" :
				this.destroy();
				gotoAndPlay("substrate");
				break;
			default :
				plex = ({home:{
							first:{
								history:this.firstHistory,
								data:this.firstData,
								age:this.firstAge
							},
							second:{
								history:this.secondHistory,
								data:this.secondData,
								age:this.secondAge
							},
							third:{
								history:this.thirdHistory,
								data:this.thirdData,
								age:this.thirdAge
							},
							arrPos:this.arrPos
						},
						wallData:this.wallData,
						plexPath:data[0].url
					});
				//trace("Doing plex dump");
				//var_dump(plex);
				//trace("/-------------------/");
				_level0.plex = plex;
				//var_dump(_level0);
				//trace("/-------------------/");
				//trace("_level0.plex: " + _level0.plex);
				this.destroy();
				gotoAndPlay("wall");
				break;
		}

	}
	private function loadRecentlyAdded():Void{
		PlexAPI.loadData(plexURL+"library/sections/1/recentlyAdded",Delegate.create(this, this.onLoadRecentlyAdded),5000);
	}
	private function onLoadRecentlyAdded(data:Array):Void{
		
		this.backgroundData = data;
		UI.loadImage(backgroundData[arrPos].artURL,this.backgroundMC,"imgBG1");
		this.backgroundMC.imgBG1._alpha = 100;
		this.currImg = "imgBG2";
		if(++arrPos >= backgroundData.length) {arrPos = 0;}
		//this.arrPos = 1;
		crossfadeInterval = setInterval(Delegate.create(this,crossfade),15000);
		
	}
	private function loadBackgroundImage(imageURL:String){
		
	}
	
	private function crossfade() {
		trace("Doing crossfade with: " + this.currImg);
		if (this.currImg == "imgBG1") {
			//trace("Doing BG1...");
			//trace("backgroundData["+arrPos+"].artURL: " + backgroundData[arrPos].artURL);
			UI.loadImage(backgroundData[arrPos].artURL,this.backgroundMC,"imgBG1");
			this.backgroundMC.imgBG1._alpha = 0;
			TweenLite.to(backgroundMC.imgBG1, 1.7, {_alpha:100});
			TweenLite.to(backgroundMC.imgBG2, 1.7, {_alpha:0});
			if(++arrPos >= backgroundData.length) {arrPos = 0;}
			this.currImg = "imgBG2";
		} else {
			//trace("backgroundData["+arrPos+"].artURL: " + backgroundData[arrPos].artURL);
			UI.loadImage(backgroundData[arrPos].artURL,this.backgroundMC,"imgBG2");
			this.backgroundMC.imgBG2._alpha = 0;
			TweenLite.to(this.backgroundMC.imgBG2, 1.7, {_alpha:100});
			TweenLite.to(this.backgroundMC.imgBG1, 1.7, {_alpha:0});
			if(++arrPos >= backgroundData.length) {arrPos = 0;}
			this.currImg = "imgBG1";
		}
	}
	
	private function setStage():Void {
		this.backgroundMC = this.mainMC.createEmptyMovieClip("backgroundMC", this.mainMC.getNextHighestDepth());
		this.menuBGMC = this.mainMC.attachMovie("menuBGMC", "menuBGSMC", this.mainMC.getNextHighestDepth());
		//this.menuBGMC._height = 350;
		this.menuBGMC._x = -1300;
		this.gThirdMenuMC = this.mainMC.createEmptyMovieClip("gThirdMenuMC", this.mainMC.getNextHighestDepth());
		gThirdMenuMC._alpha = 0;
		//gThirdMenuMC._x = 250;
		this.gSecondMenuMC = this.mainMC.createEmptyMovieClip("gSecondMenuMC", this.mainMC.getNextHighestDepth());
		gSecondMenuMC._alpha =0;
		this.gFirstMenuMC = this.mainMC.createEmptyMovieClip("gFirstMenuMC", this.mainMC.getNextHighestDepth());
		gFirstMenuMC._alpha =0;
		
		/*this.mainMC.createTextField("fps_txt", this.mainMC.getNextHighestDepth(), 900, 500, 50, 50);
		this.mainMC.fps_txt.background = true;
		this.mainMC.fps_txt.backgroundColor = 0xFFFFFF;
		this.mainMC.fps_txt.text = this.fpsComp.fps;*/
		
		var g11mcArray:Array = UI.attachMovieClip({parentMC:this.gFirstMenuMC, cSize:1, rSize:1, mcPrefix:"g11", mcName:"txt2AwayMC", x:0, y:65});
		this.g11 = new GridLite();
		this.g11.xMCArray = g11mcArray;
		this.g11.xHoriz = false;
		this.g11.xWrap = true;
		this.g11.xWrapLine = false;
		//this.g11.data = data;
		this.g11.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g11.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		/*this.g11.hlCB = Delegate.create(this, this.hlCB);
		this.g11.unhlCB = Delegate.create(this, this.unhlCB);
		this.g11.overTopCB = Delegate.create(this, this.overTopCB);
		this.g11.overBottomCB = Delegate.create(this, this.overBottomCB);
		this.g11.overLeftCB = Delegate.create(this, this.overLeftCB);*/
		this.g11.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g11.onEnterCB = Delegate.create(this, this.menuOverRightCB);
		/*this.g11.onKeyDownCB = Delegate.create(this, this.onKeyDownCB);
		this.g11.onHLStopCB = Delegate.create(this, this.onHLStopCB);
		this.g11.createUI(0);
		this.g11.highlight(data.length);*/

		var g12mcArray:Array = UI.attachMovieClip({parentMC:this.gFirstMenuMC, cSize:1, rSize:1, mcPrefix:"g12", mcName:"txt1AwayMC", x:0, y:115});
		this.g12 = new GridLite();
		this.g12.xMCArray = g12mcArray;
		this.g12.xHoriz = false;
		this.g12.xWrap = true;
		this.g12.xWrapLine = false;
		//this.g12.data = data;
		this.g12.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g12.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g12.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g12.onEnterCB = Delegate.create(this, this.menuOverRightCB);
		//First Menu Selection
		var g13mcArray:Array = UI.attachMovieClip({parentMC:this.gFirstMenuMC, cSize:1, rSize:1, mcPrefix:"g13", mcName:"txtMC", x:0, y:165});
		this.g13 = new GridLite();
		this.g13.xMCArray = g13mcArray;
		this.g13.xHoriz = false;
		this.g13.xWrap = true;
		this.g13.xWrapLine = false;
		this.g13.xHLStopTime = 700;
		//this.g13.data = data;
		this.g13.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g13.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g13.overRightCB = Delegate.create(this, this.loadSecondMenu);
		this.g13.onEnterCB = Delegate.create(this, this.firstOnEnterCB);

		var g14mcArray:Array = UI.attachMovieClip({parentMC:this.gFirstMenuMC, cSize:1, rSize:1, mcPrefix:"g14", mcName:"txt1AwayMC", x:0, y:215});
		this.g14 = new GridLite();
		this.g14.xMCArray = g14mcArray;
		this.g14.xHoriz = false;
		this.g14.xWrap = true;
		this.g14.xWrapLine = false;
		//this.g14.data = data;
		this.g14.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g14.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g14.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g14.onEnterCB = Delegate.create(this, this.menuOverRightCB);

		var g15mcArray:Array = UI.attachMovieClip({parentMC:this.gFirstMenuMC, cSize:1, rSize:1, mcPrefix:"g15", mcName:"txt2AwayMC", x:0, y:265});
		this.g15 = new GridLite();
		this.g15.xMCArray = g15mcArray;
		this.g15.xHoriz = false;
		this.g15.xWrap = true;
		this.g15.xWrapLine = false;
		//this.g15.data = data;
		this.g15.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g15.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g15.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g15.onEnterCB = Delegate.create(this, this.menuOverRightCB);

		//Second Menu
		var g21mcArray:Array = UI.attachMovieClip({parentMC:this.gSecondMenuMC, cSize:1, rSize:1, mcPrefix:"g21", mcName:"txt2AwayMC", x:0, y:65});
		this.g21 = new GridLite();
		this.g21.xMCArray = g21mcArray;
		this.g21.xHoriz = false;
		this.g21.xWrap = true;
		this.g21.xWrapLine = false;
		//this.g21.data = data;
		this.g21.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g21.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g21.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g21.overLeftCB = Delegate.create(this, this.menuOverLeftCB);

		var g22mcArray:Array = UI.attachMovieClip({parentMC:this.gSecondMenuMC, cSize:1, rSize:1, mcPrefix:"g22", mcName:"txt1AwayMC", x:0, y:115});
		this.g22 = new GridLite();
		this.g22.xMCArray = g22mcArray;
		this.g22.xHoriz = false;
		this.g22.xWrap = true;
		this.g22.xWrapLine = false;
		//this.g22.data = data;
		this.g22.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g22.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g22.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g22.overLeftCB = Delegate.create(this, this.menuOverLeftCB);
		//Second Menu Selection
		var g23mcArray:Array = UI.attachMovieClip({parentMC:this.gSecondMenuMC, cSize:1, rSize:1, mcPrefix:"g23", mcName:"txtMC", x:0, y:165});
		this.g23 = new GridLite();
		this.g23.xMCArray = g23mcArray;
		this.g23.xHoriz = false;
		this.g23.xWrap = true;
		this.g23.xWrapLine = false;
		this.g23.xHLStopTime = 700;
		//this.g23.data = data;
		this.g23.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g23.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g23.overRightCB = Delegate.create(this, this.loadThirdMenu);
		this.g23.overLeftCB = Delegate.create(this, this.cleanSecondMenuCB);
		this.g23.onEnterCB = Delegate.create(this, this.secondOnEnterCB);

		var g24mcArray:Array = UI.attachMovieClip({parentMC:this.gSecondMenuMC, cSize:1, rSize:1, mcPrefix:"g24", mcName:"txt1AwayMC", x:0, y:215});
		this.g24 = new GridLite();
		this.g24.xMCArray = g24mcArray;
		this.g24.xHoriz = false;
		this.g24.xWrap = true;
		this.g24.xWrapLine = false;
		//this.g24.data = data;
		this.g24.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g24.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g24.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g24.overLeftCB = Delegate.create(this, this.menuOverLeftCB);

		var g25mcArray:Array = UI.attachMovieClip({parentMC:this.gSecondMenuMC, cSize:1, rSize:1, mcPrefix:"g25", mcName:"txt2AwayMC", x:0, y:265});
		this.g25 = new GridLite();
		this.g25.xMCArray = g25mcArray;
		this.g25.xHoriz = false;
		this.g25.xWrap = true;
		this.g25.xWrapLine = false;
		//this.g25.data = data;
		this.g25.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g25.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g25.overRightCB = Delegate.create(this, this.menuOverRightCB);
		this.g25.overLeftCB = Delegate.create(this, this.menuOverLeftCB);

		//Third Menu
		var g31mcArray:Array = UI.attachMovieClip({parentMC:this.gThirdMenuMC, cSize:1, rSize:1, mcPrefix:"g31", mcName:"txt2AwayMC", x:0, y:65});
		this.g31 = new GridLite();
		this.g31.xMCArray = g31mcArray;
		this.g31.xHoriz = false;
		this.g31.xWrap = true;
		this.g31.xWrapLine = false;
		//this.g31.data = data;
		this.g31.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g31.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g31.overLeftCB = Delegate.create(this, this.menuOverLeftCB);

		var g32mcArray:Array = UI.attachMovieClip({parentMC:this.gThirdMenuMC, cSize:1, rSize:1, mcPrefix:"g32", mcName:"txt1AwayMC", x:0, y:115});
		this.g32 = new GridLite();
		this.g32.xMCArray = g32mcArray;
		this.g32.xHoriz = false;
		this.g32.xWrap = true;
		this.g32.xWrapLine = false;
		//this.g32.data = data;
		this.g32.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g32.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g32.overLeftCB = Delegate.create(this, this.menuOverLeftCB);
		//Third Menu Selection
		var g33mcArray:Array = UI.attachMovieClip({parentMC:this.gThirdMenuMC, cSize:1, rSize:1, mcPrefix:"g33", mcName:"txtMC", x:0, y:165});
		this.g33 = new GridLite();
		this.g33.xMCArray = g33mcArray;
		this.g33.xHoriz = false;
		this.g33.xWrap = true;
		this.g33.xWrapLine = false;
		this.g33.xHLStopTime = 700;
		//this.g33.data = data;
		this.g33.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g33.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g33.overLeftCB = Delegate.create(this, this.cleanThirdMenuCB);
		this.g33.onEnterCB = Delegate.create(this, this.thirdMenuOnEnterCB);

		var g34mcArray:Array = UI.attachMovieClip({parentMC:this.gThirdMenuMC, cSize:1, rSize:1, mcPrefix:"g34", mcName:"txt1AwayMC", x:0, y:215});
		this.g34 = new GridLite();
		this.g34.xMCArray = g34mcArray;
		this.g34.xHoriz = false;
		this.g34.xWrap = true;
		this.g34.xWrapLine = false;
		//this.g34.data = data;
		this.g34.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g34.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g34.overLeftCB = Delegate.create(this, this.menuOverLeftCB);

		var g35mcArray:Array = UI.attachMovieClip({parentMC:this.gThirdMenuMC, cSize:1, rSize:1, mcPrefix:"g35", mcName:"txt2AwayMC", x:0, y:265});
		this.g35 = new GridLite();
		this.g35.xMCArray = g35mcArray;
		this.g35.xHoriz = false;
		this.g35.xWrap = true;
		this.g35.xWrapLine = false;
		//this.g35.data = data;
		this.g35.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g35.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g35.overLeftCB = Delegate.create(this, this.menuOverLeftCB);
		
		
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
	
	private function maxValue(_array):Number {

		var mxm:Number = _array[0];
		var arrayLen:Number = _array.length;
		for (var i:Number = 0; i<arrayLen; i++) {
			if (_array[i]>mxm) {
				mxm = _array[i];
			}
		}
		return mxm;
    }
	
	private function getMaxTxtLen(_obj:Object):Number {
		
		var dataLen:Number = _obj.data.length;
		var mxm:Number = 0;
		for(var i=0; i<dataLen; i++){
			_obj.highlight(i);
			_obj.getMC().txt._width
			//trace("_obj.getMC().txt._width: " + _obj.getMC().txt._width);
			if (_obj.getMC().txt._width>mxm){
				mxm = _obj.getMC().txt._width;
			}
		}
		return mxm;
	}
	
	private function var_dump(_obj:Object) {
		//trace("Doing var_dump...");
		//trace(_obj);
		//trace("Looping Through _obj...");
		for (var i in _obj) {
			trace("key: " + i + ", value: " + _obj[i] + ", type: " + typeof(_obj[i]));
			if (typeof (_obj[i]) == "object" || typeof (_obj[i]) == "movieclip") {
				var_dump(_obj[i]);
			}
			trace("end: " + i);
		}
	}
}