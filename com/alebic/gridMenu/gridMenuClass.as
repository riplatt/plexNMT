/*
 * Copyright (c) 2009 Alen Alebic // www.alebic.net
 */

import mx.events.EventDispatcher;

class com.alebic.gridMenu.gridMenuClass extends MovieClip {
	
	// variable for the dispatched release event
	private var _onReleaseButtonEvent:String = "onReleaseButtonEvent";

	// inspectable parameters
	[Inspectable(name = " Total buttons", defaultValue = "12", type = "Number")]
	 public var iv_btnTotal:Number;
	[Inspectable(name = "Button  height", defaultValue = "100", type = "Number")]
	 public var iv_btnHeight:Number;
	[Inspectable(name = "Button  width", defaultValue = "100", type = "Number")]
	 public var iv_btnWidth:Number;
	[Inspectable(name = "Button alpha 1 (background)", defaultValue = "100", type = "Number")]
	 public var iv_btnBackgroundAlpha:Number; 
	[Inspectable(name = "Button alpha 2 (shadow)", defaultValue = "50", type = "Number")]
	 public var iv_btnShadowAlpha:Number;
	[Inspectable(name = "Button color 1 (background)", defaultValue = "#FFAE88", type = "Color")]
 	 public var iv_btnBackgroundColor:Number;  
	[Inspectable(name = "Button color 2 (shadow)", defaultValue = "#000000", type = "Color")]
	 public var iv_btnShadowColor:Number;
	[Inspectable(name = "Button corner radius", defaultValue = "12", type = "Number")]
	 public var iv_cornerRadius:Number; 
	[Inspectable(name = "Button graphic", defaultValue = "true", type = "Boolean")]
	 public var iv_btnBackgroundGraphic:Boolean; 
	[Inspectable(name = "Button icon centered", defaultValue = "true", type = "Boolean")]
	 public var iv_iconAlignment:Boolean;
	[Inspectable(name = "Button icons", defaultValue = "true", type = "Boolean")]
	 public var iv_btnIcons:Boolean;
	[Inspectable(name = "Button margin", defaultValue = "8", type = "Number")]
	 public var iv_btnMargin:Number;
	[Inspectable(name = "Button shadow distance", defaultValue = "2", type = "Number")]
	 public var iv_btnShadowDistance:Number; 
	[Inspectable(name = "Grid horizontal centering", defaultValue = "true", type = "Boolean")]
	 public var iv_centerGridH:Boolean;
	[Inspectable(name = "Grid vertical centering", defaultValue = "true", type = "Boolean")]
	 public var iv_centerGridV:Boolean;
	[Inspectable(name = "Label", defaultValue = "true", type = "Boolean")]
	 public var iv_btnLabel:Boolean; 
	[Inspectable(name = "Label alignment", defaultValue = "center, left, right", type = "List")]
	 public var iv_labelAlignment:String;
	[Inspectable(name = "Label font size", defaultValue = "15", type = "Number")]
	 public var iv_btnLabelFontSize:Number; 
	[Inspectable(name = "Label margin", defaultValue = "6", type = "Number")]
	 public var iv_btnLabelMargin:Number; 
	[Inspectable(name = "Label position", defaultValue = "bottom, top", type = "List")]
	 public var iv_btnLabelPosition:String;
	[Inspectable(name = "Label style", defaultValue = "none, bold, italic, bold & italic", type = "List")]
	 public var iv_btnLabelStyle:String;
	[Inspectable(name="Labels", defaultValue="Lab0, Lab1, Lab2, Lab3, Lab4, Lab5, Lab6, Lab7, Lab8, Lab9, Lab10, Lab11", type="Array")]
	 public var iv_btnLabels:Array;
	[Inspectable(name = "Selector", defaultValue = "false", type = "Boolean")]
	 public var iv_selector:Boolean; 
	[Inspectable(name = "Softkey buttons offset", defaultValue = "40", type = "Number")]
	 public var iv_softkeySpace:Number; 

	
	// stage width and height
	private var _sWidth:Number;
	private var _sHeight:Number;
	
	// rows and columns on stage, width and height
	private var _sRows:Number;
	private var _sColumns:Number;
	private var _sColumnWidth:Number;
	private var _sRowHeight:Number;
	
	// varibales to store inspectables
	private var _btnWidth:Number;
	private var _btnHeight:Number;
	private var _btnMargin:Number;
	private var _btnShadowDistance:Number;
	private var _btnFillColor:Number;
	private var _btnShadowColor:Number;
	private var _btnFillAlpha:Number;
	private var _btnShadowAlpha:Number;
	private var _btnIcons:Boolean;
	private var _btnLabels:Array;
	private var _btnLabelAlignment:String;
	private var _btnLabelMargin:Number;
	private var _btnLabelPosition:String;
	private var _btnIconAlignment:Boolean;
	private var _gridCenterVertical:Boolean;
	private var _gridCenterHorizontal:Boolean;
	private var _gridTotal:Number;
	private var _btnCornerRadius:Number;
	private var _btnLabelFontSize:Number;
	private var _btnLabelStyle:String;
	private var _btnBackgroundGraphic:Boolean;
	private var _btnLabel:Boolean;
	private var _softkeySpace:Number;
	private var _selector:Boolean;
	private var _maxColumns:Number;
	private var _maxRows:Number;
	
	// grid width and height
	private var _gridWidth:Number;
	private var _gridHeight:Number;
	
	// dummy MovieClip on stage representing the component
	private var dummy:MovieClip;
	
	// active (depressed) button pointer
	private var activMc:MovieClip;
	
	// active row and column
	private var activRow:Number = 0;
	private var activColumn:Number = 0;
	
	// temporary row and column variables
	private var tRow:Number = 0;
	private var tColumn:Number = 0;
	
	// i variable for loops
	private var i:Number;
	
	//public inspectables setter (all-in-one), for dynamic parameters setting
	public function setInspectables(var0:Number, var1:Number, var2:Number, var3:Number, var4:Number, var5:Number, var6:Number, var7:Number, var8:Boolean, var9:Boolean, var10:Boolean, var11:Number, var12:Number, var13:Boolean, var14:Boolean, var15:Boolean, var16:String, var17:Number, var18:Number, var19:String, var20:String, var21:Array, var22:Boolean, var23:Number):Void{
		
		var inspectablesArr = new Array('iv_btnTotal','iv_btnHeight','iv_btnWidth','iv_btnBackgroundAlpha','iv_btnShadowAlpha','iv_btnBackgroundColor','iv_btnShadowColor','iv_cornerRadius','iv_btnBackgroundGraphic','iv_iconAlignment','iv_btnIcons','iv_btnMargin','iv_btnShadowDistance','iv_centerGridH','iv_centerGridV','iv_btnLabel','iv_labelAlignment','iv_btnLabelFontSize','iv_btnLabelMargin','iv_btnLabelPosition','iv_btnLabelStyle','iv_btnLabels','iv_selector','iv_softkeySpace');
				
		for(i=0; i<inspectablesArr.length; i++){
			if(eval("var"+i) != undefined){
				this[inspectablesArr[i]] = eval("var"+i);
			}
		}
		
		resetGridMenu();
	}
	
	// the constructor
	private function gridMenuClass(){
		EventDispatcher.initialize(this);
		dummy._visible = false;
		createGridMenu();
	}
	
	// creates the menu
	private function createGridMenu():Void{
		setStage();
		setGrid();
		setButtons();
	}
	
	// removes all attached button MovieClips
	private function removeGridMenu():Void{
		for(i=0;i<_gridTotal;i++){
			this["btn"+i].removeMovieClip();
		}	
	}
	
	// resets the menu
	private function resetGridMenu():Void{
		tRow = 0;
		tColumn = 0;
		removeGridMenu();
		createGridMenu();
	}
	
	
	// sets stage width and height
	private function setStage():Void {
		_sWidth = Stage.width;
		_sHeight = Stage.height;		
	}
	
	// private function that sets grid variables
	private function setGrid():Void {
		_softkeySpace = iv_softkeySpace;
		_sColumnWidth = iv_btnWidth+iv_btnMargin*2;
		_sRowHeight = iv_btnHeight+iv_btnMargin*2;
		_gridCenterVertical = iv_centerGridV;
		_gridCenterHorizontal = iv_centerGridH;
		_gridTotal = iv_btnTotal;
		_selector = iv_selector;
		
		if(_sWidth > _sHeight){
			_sColumns = Math.floor((_sWidth-_softkeySpace*2)/_sColumnWidth);
			_sRows = Math.floor(_sHeight/_sRowHeight);
		}else{
			_sColumns = Math.floor(_sWidth/_sColumnWidth);
			_sRows = Math.floor((_sHeight-_softkeySpace*2)/_sRowHeight);
		}
		
	}
	
	// private function that sets button variables and positions/creates the buttons
	private function setButtons():Void {
		_btnWidth = iv_btnWidth;
		_btnHeight = iv_btnHeight;
		_btnMargin = iv_btnMargin;
		_btnFillColor = iv_btnBackgroundColor;
		_btnShadowColor = iv_btnShadowColor;
		_btnFillAlpha = iv_btnBackgroundAlpha;
		_btnShadowAlpha = iv_btnShadowAlpha;
		_btnShadowDistance = iv_btnShadowDistance;
		_btnLabels = iv_btnLabels;
		_btnLabel = iv_btnLabel;
		_btnLabelAlignment = iv_labelAlignment;
		_btnCornerRadius = iv_cornerRadius
		_btnIcons = iv_btnIcons;
		_btnIconAlignment = iv_iconAlignment;
		_btnLabelFontSize = iv_btnLabelFontSize;
		_btnLabelStyle = iv_btnLabelStyle;
		_btnLabelMargin = iv_btnLabelMargin;
		_btnLabelPosition = iv_btnLabelPosition;
		_btnBackgroundGraphic = iv_btnBackgroundGraphic;
		
		for(i=0;i<_gridTotal;i++){
			if(i % _sColumns == 0 && i > 0){				
				tColumn = 0;
				tRow++;				
			}else if(i > 0){
				tColumn++;
			}
			createButton("btn"+i,tRow, tColumn, i );
		}	
		
		_gridWidth = this._width;
		_gridHeight = this._height;
		
		centerGrid();
		
		// at the end calls a function to show buttons, as all buttons are created with _visible=false
		showButtons();
	
	}
	
	// centers the grid
	private function centerGrid():Void {
		if(_gridCenterVertical){
			this._y = (_sHeight-_gridHeight)/2;
			if(_sHeight > _sWidth){
				this._y -= _softkeySpace;
			}
		}
		if(_gridCenterHorizontal){
			this._x = (_sWidth-_gridWidth)/2;
			if(_sHeight < _sWidth){
				this._x -= _softkeySpace;
			}
		}
	}
	
	// public function for adjusting the layout after sensor/screen rotation
	public function adjustLayout():Void {

		hideButtons();
		
		_sWidth = Stage.width;
		_sHeight = Stage.height;
		
		setGrid();
		
		tRow = 0;
		tColumn = 0;
		
		// loop that repositions the buttons
		for(i=0;i<_gridTotal;i++){
			if(i % _sColumns == 0 && i > 0){				
				tColumn = 0;
				tRow++;				
			}else if(i > 0){
				tColumn++;
			}
			this["btn"+i]._x = _sColumnWidth * tColumn;
			this["btn"+i]._y = _sRowHeight * tRow;
			this["btn"+i].btnRC = tRow + "_" + tColumn;
			if(this["btn"+i] == activMc){
				activColumn = tColumn;
				activRow = tRow;
			}
		}
		
		_gridWidth = this._width;
		_gridHeight = this._height;
		
		centerGrid();
		
		showButtons();		
	}
	
	
	
	// function for button creation, receives button name, row and column index and button number
	private function createButton(btnName:String, btnRow:Number, btnColumn:Number, btnNo:Number):Void {
		
		this.createEmptyMovieClip(btnName,this.getNextHighestDepth());
		
		var mc:MovieClip = this[btnName];
		
		mc._visible = false;
		
		activMc = mc;
		
		mc.btnNo = btnNo;
		mc.btnRC = btnRow + "_" + btnColumn;
		mc.createEmptyMovieClip("btnShadow", mc.getNextHighestDepth());
		mc.createEmptyMovieClip("btnFill", mc.getNextHighestDepth());
		mc.btnShadow._x = mc.btnShadow._y = _btnShadowDistance;
			
		drawRoundedRectangle(mc.btnFill, _btnWidth, _btnHeight, _btnCornerRadius, _btnFillColor, _btnFillAlpha);
		drawRoundedRectangle(mc.btnShadow, _btnWidth, _btnHeight, _btnCornerRadius, _btnShadowColor, _btnShadowAlpha);
		
		if(_btnBackgroundGraphic){
			mc.attachMovie("buttonGraphic","graphicMC",mc.getNextHighestDepth());
			mc.graphicMC.setMask(mc.btnFill);
		}
		
		if(_btnIcons){
			mc.attachMovie("ico"+mc.btnNo,"ico",mc.getNextHighestDepth());
			var aspect:Number;
			if(mc.ico._width > _btnWidth){
				aspect = _btnWidth/mc.ico._width;
				mc.ico._width = _btnWidth;
				mc.ico._height *= aspect;
			}
			if(mc.ico._height > _btnHeight){
				aspect = _btnHeight/mc.ico._height;
				mc.ico._height = _btnHeight;
				mc.ico._width *= aspect;
			}
			if(_btnIconAlignment){
				mc.ico._x = (_btnWidth-mc.ico._width)/2;
				mc.ico._y = (_btnHeight-mc.ico._height)/2;
			}
		}
		
		if(_btnLabel){
			
			mc.attachMovie("buttonLabel","labelMC",mc.getNextHighestDepth());
			
			if(_btnLabelPosition == "bottom"){
				mc.labelMC._y = _btnHeight - _btnLabelFontSize - _btnLabelMargin;
			}else if(_btnLabelPosition == "top"){
				mc.labelMC._y = _btnLabelMargin;
			}		
			
			setLabel(mc);
			
		}
		
		if(_selector){
			mc.attachMovie("selector","selectorMC",mc.getNextHighestDepth());
			mc.selectorMC._visible = false;
			if(mc.selectorMC._width > _btnWidth || mc.selectorMC._height > _btnHeight){
				mc.selectorMC._width = _btnWidth;
				mc.selectorMC._height = _btnHeight;
			}
		}
				
		mc._x = _sColumnWidth * btnColumn;
		mc._y = _sRowHeight * btnRow;
				
		mc.btnFill.onRelease = function():Void {
			_parent._parent.onBtnRelease(mc);
		};
	}
	
	// set label properties
	private function setLabel(mc:MovieClip):Void{
		mc.labelMC.txt._width = _btnWidth;	
		mc.labelMC.txt.text = _btnLabels[activMc.btnNo];
		mc.labelMC.txt.setTextFormat(setLabelTextFormat());
	}
	
	// set label text format
	private function setLabelTextFormat():TextFormat{
		var txtFormat = new TextFormat;
		txtFormat.align = _btnLabelAlignment;
		txtFormat.size = _btnLabelFontSize;
		switch (_btnLabelStyle){
			case "bold":
				txtFormat.bold = true; 
				break;
			case "italic":
				txtFormat.italic = true;
				break;
			case "bold & italic":
				txtFormat.bold = true;
				txtFormat.italic = true;
				break;
			default:
				txtFormat.bold = false;
				txtFormat.italic = false;
		}
		return txtFormat;
	}
	
	// function that hides the buttons
	private function hideButtons():Void {
		i = 0;
		for(i=0;i<_gridTotal;i++){
			this["btn"+i]._visible = false;
		}
	}
	
	// function that shows the buttons one by one
	private function showButtons():Void {
		i = 0;
		this.onEnterFrame = function(){
			this["btn"+i++]._visible = true;
			if(i==_gridTotal){
				delete this.onEnterFrame;
				if(_selector && activMc == undefined){
					this["btn0"].selectorMC._visible = true;
					onBtnMove(this["btn0"]);
				}
			}
		}
	}
	
	// function that handels the onRelease action from each button
	private function onBtnRelease(mc:MovieClip):Void {
		
		// deactivate active button
		onBtnOut(activMc);
		
		activMc = mc;
		
		if(_selector){			
			mc.selectorMC._visible = true;
		}
		
		if(_btnBackgroundGraphic){
			mc.graphicMC.gotoAndStop("down_state");
		}
		
		if(_btnIcons){
			mc.ico.gotoAndStop("down_state");
		}

		if(_btnLabel){
			mc.labelMC.gotoAndStop("down_state");
			setLabel(mc)
		}
		
		var step:Number = 0;
		mc.onEnterFrame = function(){
			if(mc.btnFill._x < mc.btnShadow._x){
				step = Math.ceil((mc.btnShadow._x-mc.btnFill._x)/2);
				mc.btnFill._x += step;
				mc.btnFill._y += step;
				mc.labelMC._x += step;
				mc.labelMC._y += step;
				mc.ico._x += step;
				mc.ico._y += step;
				if(_parent._btnBackgroundGraphic){
					mc.graphicMC._x += step;
					mc.graphicMC._y += step;
				}
			}else{
				//invoke dispatch event function
				_parent.clickedHandler();
				delete mc.onEnterFrame;
			}
		}
		
		
	}
	
	// function for deactivation of the active button
	private function onBtnOut(mc:MovieClip):Void {
		if(mc != undefined){
			if(_selector){
				mc.selectorMC._visible = false;
			}
			if(_btnBackgroundGraphic){
				mc.graphicMC.gotoAndStop("up_state");
			}
			if(_btnIcons){
				mc.ico.gotoAndStop("up_state");
			}
			if(_btnLabel){
				mc.labelMC.gotoAndStop("up_state");
				setLabel(mc)
			}
			var step:Number = 0;
			mc.onEnterFrame = function(){
					if(mc.btnFill._x > mc.btnShadow._x-_parent._btnShadowDistance){
						step = Math.ceil((mc.btnShadow._x-_parent._btnShadowDistance+mc.btnFill._x)/2);
						mc.btnFill._x -= step;
						mc.btnFill._y -= step;
						mc.labelMC._x -= step;
						mc.labelMC._y -= step;
						mc.ico._x -= step;
						mc.ico._y -= step;
						if(_parent._btnBackgroundGraphic){
							mc.graphicMC._x -= step;
							mc.graphicMC._y -= step;
						}
					}else{
						delete mc.onEnterFrame;
					}
				}
		}
	}
	
	// function that moves button focus from key press events
	private function onBtnMove(mc:MovieClip):Void {
		
		// deactivate active button
		onBtnOut(activMc);
		
		activMc = mc;
		
		if(_selector){			
			mc.selectorMC._visible = true;
		}
		
		if(_btnBackgroundGraphic){
			mc.graphicMC.gotoAndStop("down_state");
		}
		
		if(_btnIcons){
				mc.ico.gotoAndStop("down_state");
			}
		
		if(_btnLabel){
			mc.labelMC.gotoAndStop("down_state");
			setLabel(mc)
		}

		var step:Number = 0;
		mc.onEnterFrame = function(){
			if(mc.btnFill._x < mc.btnShadow._x){
				step = Math.ceil((mc.btnShadow._x-mc.btnFill._x)/2);
				mc.btnFill._x += step;
				mc.btnFill._y += step;
				mc.labelMC._x += step;
				mc.labelMC._y += step;
				mc.ico._x += step;
				mc.ico._y += step;
				if(_parent._btnBackgroundGraphic){
					mc.graphicMC._x += step;
					mc.graphicMC._y += step;
				}
			}else{
				delete mc.onEnterFrame;
			}
		}
	}
	
	// public function for Key.DOWN press
	public function selectionDown():Void {
		if(activMc == undefined){
			onBtnMove(this["btn0"]);
		}else{
			activRow++;
			
			if((activColumn <= tColumn && activRow > tRow) || (activColumn > tColumn && activRow >= tRow)){
				activRow = 0;
			}
			
			selectionMove();
		}
	}
	
	// public function for Key.UP press
	public function selectionUp():Void {
		if(activMc == undefined){
			onBtnMove(this["btn0"]);
		}else{
			activRow--;
			if(activRow < 0){
				if(activColumn <= tColumn){
					activRow = tRow;
				}else{
					activRow = tRow-1;
				}
			}
			selectionMove();
		}
	}
	
	// public function for Key.RIGHT press
	public function selectionRight():Void {
		if(activMc == undefined){
			onBtnMove(this["btn0"]);
		}else{
			if(activColumn == tColumn && activRow == tRow){
				activRow = 0;
				activColumn = 0;
			}else{
				activColumn++;
				if(activColumn == _sColumns){
					activColumn = 0;
					activRow++;
				}
			}
			selectionMove();
		}
	}
	
	// public function for Key.LEFT press
	public function selectionLeft():Void {
		if(activMc == undefined){
			onBtnMove(this["btn0"]);
		}else{
			if(activColumn == 0 && activRow == 0){
				activRow = tRow;
				activColumn = tColumn;
			}else{
				activColumn--;
				if(activColumn < 0){
					activColumn = _sColumns-1;
					activRow--;
				}
			}
			selectionMove();
		}
	}
	
	// private function for all directional key press events
	private function selectionMove():Void {
		for(i=0;i<_gridTotal;i++){
				if(this["btn" + i].btnRC == activRow + "_" + activColumn){
					onBtnMove(this["btn"+i]);
					break;
				}
			}
	}
	
	// public function for Key.ENTER press
	public function selectionEnter():Void {
		clickedHandler();
	}
	
	// function for drawing a round edged restangle
	private function drawRoundedRectangle(target_mc:MovieClip, boxWidth:Number, boxHeight:Number, cornerRadius:Number, fillColor:Number, fillAlpha:Number):Void {
		with (target_mc) {
			beginFill(fillColor, fillAlpha);
			moveTo(cornerRadius, 0);
			lineTo(boxWidth-cornerRadius, 0);
			curveTo(boxWidth, 0, boxWidth, cornerRadius);
			lineTo(boxWidth, cornerRadius);
			lineTo(boxWidth, boxHeight-cornerRadius);
			curveTo(boxWidth, boxHeight, boxWidth-cornerRadius, boxHeight);
			lineTo(boxWidth-cornerRadius, boxHeight);
			lineTo(cornerRadius, boxHeight);
			curveTo(0, boxHeight, 0, boxHeight-cornerRadius);
			lineTo(0, boxHeight-cornerRadius);
			lineTo(0, cornerRadius);
			curveTo(0, 0, cornerRadius, 0);
			lineTo(cornerRadius, 0);
			endFill();
		}
	}
	
	// eventDispatcher functions, does not need implementation
	public function addEventListener():Void {
	}
	public function removeEventListener():Void {
	}
	public function dispatchEvent():Void {
	}
	
	// function to get the release event name
	public function onReleaseEvent():String {
		return _onReleaseButtonEvent;
	}
	
	// function for handling the click event
	private function clickedHandler():Void {
		this.dispatchEvent({type:_onReleaseButtonEvent, index:activMc.btnNo});
	}	
	
	// getter of current active button index number
    public function getActiveButton():Number{
        return activMc.btnNo;
    }
}

