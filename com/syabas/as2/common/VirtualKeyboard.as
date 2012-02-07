/***************************************************
* Copyright (c) 2011 Syabas Technology Inc.
* All Rights Reserved.
*
* The information contained herein is confidential property of Syabas Technology Inc.
* The use of such information is restricted to Syabas Technology Inc. platform and
* devices only.
*
* THIS SOURCE CODE IS PROVIDED ON AN "AS-IS" BASIS WITHOUT WARRANTY OF ANY KIND AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL Syabas Technology Sdn. Bhd. BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS UPDATE, EVEN IF Syabas Technology Sdn. Bhd.
* HAS BEEN ADVISED BY USER OF THE POSSIBILITY OF SUCH POTENTIAL LOSS OR DAMAGE.
* USER AGREES TO HOLD Syabas Technology Sdn. Bhd. HARMLESS FROM AND AGAINST ANY AND
* ALL CLAIMS, LOSSES, LIABILITIES AND EXPENSES.
*
* Version: 2.0.5
*
* Developer: Syabas Technology Inc.
*
* Class Description: Virtual Keyboard component.
*
***************************************************/

import com.syabas.as2.common.Grid;
import com.syabas.as2.common.Util;
import mx.utils.Delegate;

class com.syabas.as2.common.VirtualKeyboard
{
	// **WARNING: variables below are READ ONLY for public, they should not be changed outside of this class.
	//			It is used for user to perform function for specific movie clip.
	public static  var FUNCTION_OK:Number = 0; 					// Function OK 					-	when on enter this movie clip, perform keyboard done action.
	public static  var FUNCTION_CANCEL:Number = 1;				// Function CANCEL				-	when on enter this movie clip, perform keyboard cancel action.
	public static  var FUNCTION_BACKSPACE:Number = 2;			// Function BACKSPACE 			-	when on enter this movie clip, perform keyboard backspace action.
	public static  var FUNCTION_CLEAR:Number = 3;				// Function CLEAR 				-	when on enter this movie clip, perform keyboard clear action.
	public static  var FUNCTION_SPACE:Number = 4;				// Function SPACE 				-	when on enter this movie clip, perform keyboard space action.
	public static  var FUNCTION_DELETE:Number = 5;				// Function DELETE 				-	when on enter this movie clip, perform keyboard delete action.
	public static  var FUNCTION_SHIFT:Number = 6;				// Function SHIFT 				-	when on enter this movie clip, perform keyboard shift action.
	public static  var FUNCTION_LEFT:Number = 7;				// Function LEFT 				-	when on enter this movie clip, perform keyboard move cursor to left action.
	public static  var FUNCTION_RIGHT:Number = 8;				// Function RIGHT 				-	when on enter this movie clip, perform keyboard move cursor to right action.
	public static  var FUNCTION_UP:Number = 9;					// Function UP 					-	when on enter this movie clip, perform keyboard move cursor to up action.
	public static  var FUNCTION_DOWN:Number = 10;				// Function DOWN 				-	when on enter this movie clip, perform keyboard move cursor to down action.
	public static  var FUNCTION_CAPSLOCK:Number = 11;			// Function CAPSLOCK 			-	when on enter this movie clip, perform keyboard capital lock action.
	public static  var FUNCTION_ALPHANUMERIC:Number = 12;		// Function ALPHANUMERIC 		-	when on enter this movie clip, perform keyboard shift to alpha numeric mode action.
	public static  var FUNCTION_SYMBOL:Number = 13;				// Function SYMBOL 				-	when on enter this movie clip, perform keyboard shift to symbol mode action.
	public static  var FUNCTION_SPECIAL_CHARACTER:Number = 14;	// Function SPECIAL CHARACTER 	-	when on enter this movie clip, perform keyboard shift to special character mode action.
	public static  var FUNCTION_AUTO_COMPLETE:Number = 15;		// Function MULTI LANGUAGE 		-	when on enter this movie clip, perform keyboard shift to multi language mode action.

	private static var ALPHANUMERIC:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"a" }, { t:"b" }, { t:"c" }, { t:"d" }, { t:"e" }, { t:"f" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"g" }, { t:"h" }, { t:"i" }, { t:"j" }, { t:"k" }, { t:"l" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"m" }, { t:"n" }, { t:"o" }, { t:"p" }, { t:"q" }, { t:"r" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"s" }, { t:"t" }, { t:"u" }, { t:"v" }, { t:"w" }, { t:"x" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"y" }, { t:"z" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var ALPHANUMERIC_CAPITAL:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"A" }, { t:"B" }, { t:"C" }, { t:"D" }, { t:"E" }, { t:"F" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"G" }, { t:"H" }, { t:"I" }, { t:"J" }, { t:"K" }, { t:"L" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"M" }, { t:"N" }, { t:"O" }, { t:"P" }, { t:"Q" }, { t:"R" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"S" }, { t:"T" }, { t:"U" }, { t:"V" }, { t:"W" }, { t:"X" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"Y" }, { t:"Z" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var SYMBOL:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"~" }, { t:"!" }, { t:"@" }, { t:"#" }, { t:"$" }, { t:"%" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"^" }, { t:"&" }, { t:"(" }, { t:")" }, { t:"_" }, { t:"+" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"{" }, { t:"}" }, { t:"\'" }, { t:"[" }, { t:"]" }, { t:"-" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"=" }, { t:";" }, { t:"," }, { t:"." }, { t:"*" }, { t:"/" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:":" }, { t:"?" }, { t:"<" }, { t:">" }, { t:"\\" }, { t:"`" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"ä" }, { t:"é" }, { t:"ö" }, { t:"ü" }, { t:"ç" }, { t:"ñ" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var SYMBOL_CAPITAL:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"~" }, { t:"!" }, { t:"@" }, { t:"#" }, { t:"$" }, { t:"%" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"^" }, { t:"&" }, { t:"(" }, { t:")" }, { t:"_" }, { t:"+" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"{" }, { t:"}" }, { t:"\'" }, { t:"[" }, { t:"]" }, { t:"-" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"=" }, { t:";" }, { t:"," }, { t:"." }, { t:"*" }, { t:"/" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:":" }, { t:"?" }, { t:"<" }, { t:">" }, { t:"\\" }, { t:"`" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"ä" }, { t:"é" }, { t:"ö" }, { t:"ü" }, { t:"ç" }, { t:"ñ" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var SPECIALCHARACTER:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"ä" }, { t:"ö" }, { t:"ü" }, { t:"ß" }, { t:"â" }, { t:"ê" },
								  {t:"abc", cs:2, fn:11 }, { }, { t:"î" }, { t:"ô" }, { t:"û" }, { t:"ç" }, { t:"ë" }, { t:"ï" },
								  {t:"ABC", cs:2, fn:12 }, { }, { t:"ÿ" }, { t:"á" }, { t:"à" }, { t:" é" }, { t:" è" }, { t:"í" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"ì" }, { t:"ó" }, { t:"ò" }, { t:"ú" }, { t:"ù" }, { t:"æ" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"œ" }, { t:"ñ" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var SPECIALCHARACTER_CAPITAL:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"Ä" }, { t:"Ö" }, { t:"Ü" }, { t:"ß" }, { t:"Â" }, { t:"Ê" },
								  {t:"abc", cs:2, fn:11 }, { }, { t:"Î" }, { t:"Ô" }, { t:"Û" }, { t:"Ç" }, { t:"Ë" }, { t:"Ï" },
								  {t:"ABC", cs:2, fn:12 }, { }, { t:"Ÿ" }, { t:"Á" }, { t:"À" }, { t:"É" }, { t:"È" }, { t:"Í" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"Ì" }, { t:"Ó" }, { t:"Ò" }, { t:"Ú" }, { t:"Ù" }, { t:"Æ" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"Œ" }, { t:"Ñ" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var AUTOCOMPLETE:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"a" }, { t:"b" }, { t:"c" }, { t:"d" }, { t:"e" }, { t:"f" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"g" }, { t:"h" }, { t:"i" }, { t:"j" }, { t:"k" }, { t:"l" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"m" }, { t:"n" }, { t:"o" }, { t:"p" }, { t:"q" }, { t:"r" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"s" }, { t:"t" }, { t:"u" }, { t:"v" }, { t:"w" }, { t:"x" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"y" }, { t:"z" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var AUTOCOMPLETE_CAPITAL:Array =  [
								  {t:"clear", cs:2, fn:3 }, { }, { t:"delete", cs:2, fn:2 }, { }, { t:"◄", fn:7 }, { t:"►", fn:8 }, { t:"▲", fn:9 }, { t:"▼", fn:10 },
								  {t:"caps", cs:2, fn:11 }, { }, { t:"A" }, { t:"B" }, { t:"C" }, { t:"D" }, { t:"E" }, { t:"F" },
								  {t:"shift", cs:2, fn:6 }, { }, { t:"G" }, { t:"H" }, { t:"I" }, { t:"J" }, { t:"K" }, { t:"L" },
								  {t:"abc", cs:2, fn:12 }, { }, { t:"M" }, { t:"N" }, { t:"O" }, { t:"P" }, { t:"Q" }, { t:"R" },
								  {t:"symbol", cs:2, fn:13 }, { }, { t:"S" }, { t:"T" }, { t:"U" }, { t:"V" }, { t:"W" }, { t:"X" },
								  {t:"ac", cs:2, fn:15 }, { }, { t:"Y" }, { t:"Z" }, { t:"1" }, { t:"2" }, { t:"3" }, { t:"4" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"5" }, { t:"6" }, { t:"7" }, { t:"8" }, { t:"9" }, { t:"0" },
								  {gDis: {init:"toRight", fromLeft:"toRight", fromRight:"toLeft" }}, { gDis: {fromLeft:"toRight", fromRight:"toLeft" }}, { t:"cancel", fn:1, cs:2 }, { }, { t:"space", cs:2, fn:4 }, { }, { t:"ok", cs:2, fn:0 }, { } ];

	private static var SUGGESTION:Array = ["http://", "https://", "www.", ".", ".com", "/", "_", "-", ".htm", ".html", ".xml", ".rss", ".net", ".org", ":", "?", "&"];

	// config object properties default value.
	private static var DEFAULTS:Object = {
		parentMC:null, kbName:"keyboardMC", cSize:8, rSize:8, startMode:VirtualKeyboard.FUNCTION_ALPHANUMERIC, capslock:false, 
		inputTF:null, inputCursor:null, initValue:"", showPassword:false, hl:0,
		showSuggestion:false, wrap:true, acLib:null,
		onUpdateCB:null, onDoneCB:null, onCancelCB:null, onEnterCB:null,
		overTopCB:null, overBottomCB:null, overLeftCB:null, overRightCB:null, keyDownCB:null,
		alphanumeric:VirtualKeyboard.ALPHANUMERIC, alphanumeric_capital:VirtualKeyboard.ALPHANUMERIC_CAPITAL,
		specialcharacter:VirtualKeyboard.SPECIALCHARACTER, specialcharacter_capital:VirtualKeyboard.SPECIALCHARACTER_CAPITAL,
		autocomplete:VirtualKeyboard.AUTOCOMPLETE, autocomplete_capital:VirtualKeyboard.AUTOCOMPLETE_CAPITAL,
		symbol:VirtualKeyboard.SYMBOL, symbol_capital:VirtualKeyboard.SYMBOL_CAPITAL, suggestion:VirtualKeyboard.SUGGESTION
	};

	private var o:Object = null;
	private var kbMC:MovieClip = null;
	private var grid:Grid = null;

	private var mode:Number = VirtualKeyboard.FUNCTION_ALPHANUMERIC;
	private var initMode:Number = VirtualKeyboard.FUNCTION_ALPHANUMERIC;
	private var minCursorPos:Number = -1;
	private var maxCursorPos:Number = -1;
	private var inputPos:Number = 0;
	private var textWidths:Array = null;
	private var shift:Boolean = false;
	private var shiftCapslock:Boolean = false;
	private var selectedMC:MovieClip = null;
	private var input:String = "";

	private var suggGrid:Grid = null;
	private var suggMC:MovieClip = null;
	private var suggFocus:Boolean = false;

	private var keyListener:Object = null;
	private var klInterval:Number = 0;

	private var acIndex:Number = -1;
	private var acCount:Number = -1;
	private var acShow:Boolean = false;
	private var acTimeout:Number = 0;

	public function destroy():Void
	{
		_global.clearTimeout(this.acTimeout);
		
		delete this.o;
		this.o  = null;

		delete this.textWidths;
		this.textWidths = null;

		this.grid.destroy();
		delete this.grid;
		this.grid = null;

		this.suggGrid.destroy();
		delete this.suggGrid;
		this.suggGrid = null;

		this.suggMC.removeMovieClip();
		delete this.suggMC;
		this.suggMC = null;

		this.kbMC.removeMovieClip();
		delete this.kbMC;
		this.kbMC = null;
	}

	public function clear():Void
	{
		delete this.textWidths;
		this.textWidths = null
		this.textWidths = new Array();
		this.inputPos = 0;
		this.input = "";
	}

	public function VirtualKeyboard(vkObj:Object)
	{
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		this.o = new Object();
		for (var prop:String in VirtualKeyboard.DEFAULTS)
			this.o[prop] = VirtualKeyboard.DEFAULTS[prop]; // set config object to all default values.
		this.textWidths = new Array();
		this.set(vkObj);
	}

	/*
	* o: config object with properties below:
	*   1.  parentMC:MovieClip      - parent movieClip that house all the movieClips for the Virtual Keyboard
	*   2.  kbName:String           - [Optional] movieClip name used to create the virtual keyboard. Default is 'keyboardMC'
	*   3.  cSize:Number            - [Optional] number of column. Default is 8.
	*   4.  rSize:Number            - [Optional] number of row. Default is 8.
	*   5.  startMode:Number        - [Optional] keyboard starting layout. Default is VirtualKeyboard.FUNCTION_ALPHANUMERIC.
	*   6.  inputTF:TextField       - [Optional] keyboard input textfield. Default is original textfield which come with this keyboard.
	*   7.  inputCursor:MovieClip   - [Optional] keyboard input cursor. Default is original cursor which come with this keyboard.
	*   8.  showSuggestion:Boolean  - [Optional] true to show suggestion list on right side of virtual keyboard. Default is false.
	*   9.  wrap:Boolean            - [Optional] true to wrap from last to 1st, and 1st to last line. Default is true.
	*   10. acLib:LoadVar           - [Optional] auto complete dictionary for auto complete purposes. The complete word will be shown on suggestion list.
	*   11. onUpdateCB:Function     - [Optional] callback function to be called when input string is updated. Default is null.
	*   12. onDoneCB:Function       - [Optional] callback function to be called when OK Function Button is pressed. Default is null.
	*                                 Arguments: str:String - input value.
	*   13. onCancelCB:Function	    - [Optional] callback function to be called when Cancel Function button is pressed. Default is null.
	*                                 Arguments: str:String - initial value.
	*   14. overTopCB:Function      - [Optional] callback function to be called when key up is pressed only if inputTF is set and enableKeyboard is used instead of showKeyboard.  Default is null.
	*   15. overBottomCB:Function   - [Optional] callback function to be called when key down is pressed only if inputTF is set and enableKeyboard is used instead of showKeyboard.  Default is null.
	*   16. overLeftCB:Function	    - [Optional] callback function to be called when key left is pressed only if inputTF is set and enableKeyboard is used instead of showKeyboard.  Default is null.
	*   17. overRightCB:Function    - [Optional] callback function to be called when key right is pressed only if inputTF is set and enableKeyboard is used instead of showKeyboard.  Default is null.
	*   18. onEnterCB:Function      - [Optional] callback function to be called when key enter is pressed only if inputTF is set and enableKeyboard is used instead of showKeyboard.  Default is null.
	*                                 If this callback is null, the keyboard will be shown when Enter key is pressed.
	*   19. keyDownCB:Function      - [Optional] callback function to be called when key other than up/down/left/right/enter is pressed. Default is null.
	*                                 Arguments: o:Object {keyCode:Number, asciiCode:Number}
	*   20. alphanumeric:Array              - [Optional] keyboard alphanumeric layout data. Default is VirtualKeyboard.ALPHANUMERIC.
	*   21. alphanumeric_capital:Array      - [Optional] keyboard alphanumeric capital layout data. Default is VirtualKeyboard.ALPHANUMERIC_CAPITAL.
	*   22. specialcharacter:Array          - [Optional] keyboard special character layout data. Default is VirtualKeyboard.SPECIALCHARACTER,
	*   23. specialcharacter_capital:Array  - [Optional] keyboard special character capital layout data. Default is VirtualKeyboard.SPECIALCHARACTER_CAPITAL,
	*   24. symbol:Array                    - [Optional] keyboard symbol layout data. Default is VirtualKeyboard.SYMBOL
	*   25. symbol_capital:Array            - [Optional] keyboard symbol capital layout data. Default is VirtualKeyboard.SYMBOL_CAPITAL
	*   26. autocomplete:Array              - [Optional] keyboard auto complete layout data. Default is VirtualKeyboard.SYMBOL
	*   27. autocomplete_capital:Array      - [Optional] keyboard auto complete capital layout data. Default is VirtualKeyboard.SYMBOL_CAPITAL
	*   28. suggestion:Array                - [Optional] keyboard alphanumeric layout data. Default is VirtualKeyboard.SUGGESTION
	*/
	public function set(vkObj:Object):Void
	{
		if (!Util.isBlank(vkObj.startMode))
		{
			this.mode = vkObj.startMode;
			this.initMode = vkObj.startMode;
		}

		var temp:Object = null;
		// global config object.
		var kbO:Object = this.o;

		if(!Util.isBlank(vkObj.alphanumeric) && Util.isBlank(vkObj.alphanumeric_capital))
			vkObj.alphanumeric_capital = vkObj.alphanumeric;

		if(Util.isBlank(vkObj.alphanumeric) && !Util.isBlank(vkObj.alphanumeric_capital))
			vkObj.alphanumeric = vkObj.alphanumeric_capital;

		if(!Util.isBlank(vkObj.specialcharacter) && Util.isBlank(vkObj.specialcharacter_capital))
			vkObj.specialcharacter_capital = vkObj.specialcharacter;

		if(Util.isBlank(vkObj.specialcharacter) && !Util.isBlank(vkObj.specialcharacter_capital))
			vkObj.specialcharacter = vkObj.specialcharacter_capital;

		if(!Util.isBlank(vkObj.symbol) && Util.isBlank(vkObj.symbol_capital))
			vkObj.symbol_capital = vkObj.symbol;

		if(Util.isBlank(vkObj.symbol) && !Util.isBlank(vkObj.symbol_capital))
			vkObj.symbol = vkObj.symbol_capital;

		if(!Util.isBlank(vkObj.autocomplete) && Util.isBlank(vkObj.autocomplete_capital))
			vkObj.autocomplete_capital = vkObj.autocomplete;

		if(Util.isBlank(vkObj.autocomplete) && !Util.isBlank(vkObj.autocomplete_capital))
			vkObj.autocomplete = vkObj.autocomplete_capital;

		// copying all the new values to the global config object.
		for (var prop:String in vkObj)
		{
			temp = vkObj[prop];
			if (temp === undefined || VirtualKeyboard.DEFAULTS[prop] === undefined)
				continue;
			kbO[prop] = (temp == null ? VirtualKeyboard.DEFAULTS[prop] : temp);
		}
	}

	/*
	* Populate the Virtual Keyboard now.
	*
	* enable: true to show the highlight and enable keyListener. Default is true.
	* hl: Highlight with the hl(data index) specified and enable the keyListener.
	*/
	public function showKeyboard(enable:Boolean, hl:Number):Void
	{
		if(this.kbMC == null || this.kbMC == undefined)
		{
			this.kbMC = this.o.parentMC.attachMovie(this.o.kbName, "keyboardMC", 1);
			if (this.o.inputTF == null || this.o.inputCursor == null)
			{
				this.o.inputTF = this.kbMC.inputText;
				this.o.inputCursor = this.kbMC.cursor;
			}
			else
			{
				this.kbMC.inputText._visible = false;
				this.kbMC.cursor._visible = false;
			}
	
			var gObj:Object = new Object();
			gObj.parentMC = this.kbMC;
			gObj.rSize = this.o.rSize;
			gObj.cSize = this.o.cSize;
			gObj.wrapLine = false;
			gObj.wrap = this.o.wrap;
			gObj.data = this.o.alphanumeric;
			gObj.updateCB = Delegate.create(this, this.updateCB);
			gObj.clearCB = Delegate.create(this, this.clearCB);
			gObj.hlCB = Delegate.create(this, this.hlCB);
			gObj.unhlCB = Delegate.create(this, this.unhlCB);
			gObj.keyDownCB = Delegate.create(this, this.keyDownCB);
			gObj.onEnterCB = Delegate.create(this, this.onEnterCB);
			if (this.o.showSuggestion == true)
			{
				gObj.overLeftCB = Delegate.create(this, this.overLeftCB);
				gObj.overRightCB = Delegate.create(this, this.overRightCB);
				this.suggMC = this.kbMC.suggMC;
				this.suggGrid = new Grid( {
					parentMC:this.suggMC,
					rSize:8,
					cSize:1,
					wrapLine:false,
					data:this.o.suggestion,
					updateCB:Delegate.create(this, this.suggUpdateCB),
					clearCB:Delegate.create(this, this.clearCB),
					hlCB:Delegate.create(this, this.hlCB),
					unhlCB:Delegate.create(this, this.unhlCB),
					keyDownCB:Delegate.create(this, this.keyDownCB),
					overLeftCB:Delegate.create(this, this.overLeftCB),
					overRightCB:Delegate.create(this, this.overRightCB),
					onEnterCB:Delegate.create(this, this.onEnterCB)
				});
				this.suggGrid.populateUI(false);
			}
			this.grid = new Grid(gObj);
			this.grid.populateUI(false);
		}
		else
		{
			this.kbMC._visible = true;
			this.suggMC._visible = true;
		}

		if (enable == false)
			this.disableKeyboard();
		else
			this.enableKeyboard(null, hl);
	}

	/*
	* Hide the Virtual Keyboard.
	*
	* enable: true enable keyListener. Default is false.
	*/
	public function hideKeyboard(enable:Boolean):Void
	{
		this.initMode = this.mode;
		this.grid.unhighlight();
		this.suggGrid.unhighlight();
		this.suggMC._visible = false;
		this.kbMC._visible = false;
		if (enable == false)
			this.disableKeyboard();
		else
		{
			if (Util.isBlank(this.o.inputTF) || Util.isBlank(this.o.inputCursor))
				this.disableKeyboard();
			else
				this.enableKeyboard();
		}
	}

	/*
	* Enable the Virtual Keyboard now, if keyboard is presented, will enable highlight; Else enable support input from USB keyboard for custom input textfield.
	*/
	public function enableKeyboard(vkObj:Object, hl:Number):Void
	{
		if(Util.isNum(String(hl)) == true)
			this.o.hl = hl;
		if (!(Util.isBlank(vkObj.inputTF) || Util.isBlank(vkObj.inputCursor)) )
		{
			this.o.inputTF = vkObj.inputTF;
			this.o.inputCursor = vkObj.inputCursor;
		}

		if (Util.isBlank(this.o.inputTF) || Util.isBlank(this.o.inputCursor))
			return;
		if (this.kbMC == null || !this.kbMC._visible)
			this.enableKeyListener();
		else
		{
			this.disableKeyListener();
			this.grid.highlight(this.o.hl);			
			this.grid.set({data:this.switchMode()});
			this.grid.refresh();
		}

		if(this.textWidths.length == 0)
		{
			var initValue:String = this.o.initValue;
			if (Util.isBlank(initValue))
				initValue = this.o.inputTF.text;
			if (!Util.isBlank(initValue))
			{
				this.clearText();
				this.o.initValue = initValue;
				this.insertString(initValue);
			}
		}
	}

	/*
	* Enable the Virtual Keyboard now, if keyboard is presented, will remove highlight; Else disable support input from USB keyboard for custom input textfield.
	*/
	public function disableKeyboard():Void
	{
		if (this.kbMC == null || !this.kbMC._visible)
		{
			this.o.initValue = "";
			this.disableKeyListener();
		}
		else
		{
			if (this.suggFocus)
				this.suggGrid.unhighlight();
			else
				this.grid.unhighlight();
		}
	}

	private function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.klInterval = _global["setInterval"](Delegate.create(this, this.onEnableKeyListener), 100); // delay abit to prevent getting the previously press key.
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

	private function insertString(str:String):Void
	{
		var strLen:Number = str.length;
		var strC:String = "";
		for (var j:Number = 0; j < strLen; j++)
		{
			strC = str.charAt(j);
			this.addText(strC);
		}
	}

	private function keyDownCB(obj:Object):Void
	{
		var keyCode:Number = obj.keyCode;
		var asciiCode:Number = obj.asciiCode;
		if (Util.isBlank(String(keyCode)) || Util.isBlank(String(asciiCode)))
		{
			keyCode = Key.getCode();
			asciiCode = Key.getAscii();
		}
		var b:Boolean = false;
		switch(keyCode)
		{
			case Key.ENTER:
				if (this.kbMC == null || !this.kbMC._visible)
				{
					if (this.o.onEnterCB != null)
						this.o.onEnterCB();
					else
					{
						this.o.initValue = this.o.inputTF.text;
						this.showKeyboard(true);
					}
				}
			break;
			case Key.LEFT:
				if (this.kbMC == null || !this.kbMC._visible)
				{
					if (this.o.overLeftCB != null)
					{
						b = this.o.overLeftCB();
						if (!b || b == null || b == undefined)
							this.disableKeyboard();
					}
					else
						this.cursorToLeft();
				}
			break;
			case Key.RIGHT:
				if (this.kbMC == null || !this.kbMC._visible)
				{
					if (this.o.overRightCB != null)
					{
						b = this.o.overRightCB();
						if (!b || b == null || b == undefined)
							this.disableKeyboard();
					}
					else
						this.cursorToRight();
				}
			break;
			case Key.UP:
				if (this.kbMC == null || !this.kbMC._visible)
				{
					if (this.o.overTopCB != null)
					{
						b = this.o.overTopCB();
						if (!b || b == null || b == undefined)
							this.disableKeyboard();
					}
					else
						this.cursorToUp();
				}
			break;
			case Key.DOWN:
				if (this.kbMC == null || !this.kbMC._visible)
				{
					if (this.o.overBottomCB != null)
					{
						b = this.o.overBottomCB();
						if (!b || b == null || b == undefined)
							this.disableKeyboard();
					}
					else
						this.cursorToDown();
				}
			break;
			default:
				if (asciiCode >= 32 && asciiCode < 127)
					this.addText(String.fromCharCode(asciiCode));
				else if (asciiCode == 8) // backspace
					this.backspace();
				else if (asciiCode == 127) // delete
					this.deleteText();
				else
				{
					if (this.o.keyDownCB != null)
						this.o.keyDownCB({keyCode:keyCode,asciiCode:Key.getAscii()});
				}
			break;
		}
	}

	private function switchMode(opposite:Boolean):Array
	{
		if (Util.isBlank(String(opposite)))
			opposite = false;
		var d:Array = null;
		if (this.o.capslock == !opposite)
		{
			switch(this.mode)
			{
				case VirtualKeyboard.FUNCTION_ALPHANUMERIC:
					d = this.o.alphanumeric_capital;
				break;
				case VirtualKeyboard.FUNCTION_SYMBOL:
					d = this.o.symbol_capital;
				break;
				case VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER:
					d = this.o.specialcharacter_capital;
				break;
				case VirtualKeyboard.FUNCTION_AUTO_COMPLETE:
					d = this.o.autocomplete_capital;
				break;
			}
		}
		else if (this.o.capslock == opposite)
		{
			switch(this.mode)
			{
				case VirtualKeyboard.FUNCTION_ALPHANUMERIC:
					d = this.o.alphanumeric;
				break;
				case VirtualKeyboard.FUNCTION_SYMBOL:
					d = this.o.symbol;
				break;
				case VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER:
					d = this.o.specialcharacter;
				break;
				case VirtualKeyboard.FUNCTION_AUTO_COMPLETE:
					d = this.o.autocomplete;
				break;
			}
		}
		return d;
	}

	private function updateCB(o:Object):Void
	{
		if (o.data.t != undefined && o.data.t != null)
			o.mc.txt.text = o.data.t;
		if (o.data.fn == this.initMode)
		{
			if (o.dataIndex == this.grid.hl)
				o.mc.gotoAndStop("hlSelected");
			else
				o.mc.gotoAndStop("unhlSelected");
			this.selectedMC = o.mc;
			this.initMode = -1;
		}
		
		if(o.data.fn == VirtualKeyboard.FUNCTION_CAPSLOCK)
		{
			if(this.o.capslock == true)
			{
				if (o.dataIndex == this.grid.hl)
					o.mc.gotoAndStop("hlSelected");
				else
					o.mc.gotoAndStop("unhlSelected");
			}
		}
	}

	private function clearCB(o:Object):Void
	{
		o.mc.txt.text = "";
		o.mc.gotoAndStop("unhl");
	}

	private function hlCB(o:Object):Void
	{
		if (!Util.isBlank( o.data.fn))
		{
			if ((o.data.fn == VirtualKeyboard.FUNCTION_CAPSLOCK && this.o.capslock == true) || o.data.fn == this.mode)
			{
				o.mc.gotoAndStop("hlSelected");
				return;
			}
		}

		o.mc.gotoAndStop("hl");

		if (this.suggFocus)
		{
			var i:Number = o.dataIndex;
			var l:Number = this.suggGrid.o.len - 1;
			this.kbMC.suggMC.scrollMC._y = 5 + (i / l * 260);
		}
	}

	private function unhlCB(o:Object):Void
	{
		if (!Util.isBlank( o.data.fn))
		{
			if ((o.data.fn == VirtualKeyboard.FUNCTION_CAPSLOCK && this.o.capslock == true) || o.data.fn == this.mode)
			{
				o.mc.gotoAndStop("unhlSelected");
				return;
			}
		}
		o.mc.gotoAndStop("unhl");
	}

	private function onEnterCB():Void
	{
		if (this.grid.isRetrying())
		{
			this.grid.retry();
			return;
		}

		if (this.suggFocus)
		{
			var txt:Object = this.suggGrid.getData();
			if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			{
				for (var i:Number = 0; i < this.acCount; i++)
					this.backspace(true);				
				_global.clearTimeout(this.acTimeout);
				this.showList();
			}			
			var strLen:Number = txt.length;
			var strC:String = "";
			for (var j:Number = 0; j < strLen; j++)
			{
				strC = txt.charAt(j);
				this.addText(strC);
			}
			return;
		}

		var data:Object = this.grid.getData();
		var mc:MovieClip = this.grid.getMC();
		switch(data.fn)
		{
			case VirtualKeyboard.FUNCTION_OK:
				this.onDone();
			break;
			case VirtualKeyboard.FUNCTION_CANCEL:
				this.onCancel();
			break;
			case VirtualKeyboard.FUNCTION_BACKSPACE:
				this.backspace();
			break;
			case VirtualKeyboard.FUNCTION_CLEAR:
				this.clearText();
			break;
			case VirtualKeyboard.FUNCTION_SPACE:
				this.addText(" ");
			break;
			case VirtualKeyboard.FUNCTION_DELETE:
				this.deleteText();
			break;
			case VirtualKeyboard.FUNCTION_SHIFT:
				this.shiftText();
			break;
			case VirtualKeyboard.FUNCTION_LEFT:
				this.cursorToLeft();
			break;
			case VirtualKeyboard.FUNCTION_RIGHT:
				this.cursorToRight();
			break;
			case VirtualKeyboard.FUNCTION_UP:
				this.cursorToUp();
			break;
			case VirtualKeyboard.FUNCTION_DOWN:
				this.cursorToDown();
			break;
			case VirtualKeyboard.FUNCTION_CAPSLOCK:
				if (this.o.capslock == true)
				{
					this.o.capslock = false;
					mc.gotoAndStop("hl");
				}
				else if (this.o.capslock == false)
				{
					this.o.capslock = true;
					mc.gotoAndStop("hlSelected");
				}
				this.grid.set({data:this.switchMode()});
				this.grid.refresh();
				this.shift = false;
			break;
			case VirtualKeyboard.FUNCTION_ALPHANUMERIC:
				if (this.mode == VirtualKeyboard.FUNCTION_ALPHANUMERIC)
				{
					if (!Util.isBlank(data.tg))
					{
						this.mode = data.tg;
						this.selectedMC.gotoAndStop("hl");
						this.selectedMC = null;
						this.shift = false;
					}
					else
						this.mode = VirtualKeyboard.FUNCTION_ALPHANUMERIC;
				}
				else
				{
					this.mode = VirtualKeyboard.FUNCTION_ALPHANUMERIC;
					if (this.selectedMC !== null)
						this.selectedMC.gotoAndStop("unhl");
					this.selectedMC = mc;
					this.selectedMC.gotoAndStop("hlSelected");
					this.shift = false;
				}

				this.grid.set({data:this.switchMode()});
				this.grid.refresh();
				if(this.acShow == true)
				{
					this.acShow = false;
					this.resetSuggList();
				}
			break;
			case VirtualKeyboard.FUNCTION_SYMBOL:
				if (this.mode == VirtualKeyboard.FUNCTION_SYMBOL)
				{
					if (!Util.isBlank(data.tg))
					{
						this.mode = data.tg;
						this.selectedMC.gotoAndStop("hl");
						this.selectedMC = null;
						this.shift = false;
					}
					else
						this.mode = VirtualKeyboard.FUNCTION_SYMBOL;
				}
				else
				{
					this.mode = VirtualKeyboard.FUNCTION_SYMBOL;
					if (this.selectedMC !== null)
						this.selectedMC.gotoAndStop("unhl");
					this.selectedMC = mc;
					this.selectedMC.gotoAndStop("hlSelected");
					this.shift = false;
				}
				this.grid.set({data:this.switchMode()});
				this.grid.refresh();
				if(this.acShow == true)
				{
					this.acShow = false;
					this.resetSuggList();
				}
			break;
			case VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER:
				if (this.mode == VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER)
				{
					if (!Util.isBlank(data.tg))
					{
						this.mode = data.tg;
						this.selectedMC.gotoAndStop("hl");
						this.selectedMC = null;
						this.shift = false;
					}
					else
						this.mode = VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER;
				}
				else
				{
					this.mode = VirtualKeyboard.FUNCTION_SPECIAL_CHARACTER;
					if (this.selectedMC !== null)
						this.selectedMC.gotoAndStop("unhl");
					this.selectedMC = mc;
					this.selectedMC.gotoAndStop("hlSelected");
					this.shift = false;
				}
				this.grid.set({data:this.switchMode()});
				this.grid.refresh();
				if(this.acShow == true)
				{
					this.acShow = false;
					this.resetSuggList();
				}
			break;
			case VirtualKeyboard.FUNCTION_AUTO_COMPLETE:
				if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
				{
					if (!Util.isBlank(data.tg))
					{
						this.mode = data.tg;
						this.selectedMC.gotoAndStop("hl");
						this.selectedMC = null;
						this.shift = false;
					}
					else
					{
						this.acIndex = -1;
						this.acCount = 0;
						this.mode = VirtualKeyboard.FUNCTION_AUTO_COMPLETE;
					}
				}
				else
				{
					this.mode = VirtualKeyboard.FUNCTION_AUTO_COMPLETE;
					if (this.selectedMC !== null)
						this.selectedMC.gotoAndStop("unhl");
					this.selectedMC = mc;
					this.selectedMC.gotoAndStop("hlSelected");
					this.shift = false;
					this.acIndex = -1;
					this.acCount = 0;
				}
				this.grid.set({data:this.switchMode()});
				this.grid.refresh();
				this.showCombinationList();
			break;
			default:
				if (!(data.t == undefined && data.t == null))
				{
					if (data.t.length > 1)
						this.insertString(data.t);
					else
						this.addText(data.t);
				}
			break;
		}
	}

	private function overLeftCB():Boolean
	{
		var pos:Number = 0;
		if (this.suggFocus)
		{
			this.suggFocus = false;
			pos = (this.suggGrid.getR() + 1) * this.o.cSize;
			this.suggGrid.unhighlight();
			this.grid.highlight(Number(pos - 1));
		}
		else
		{
			if (this.o.wrap == false)
				return true;
			if(this.suggGrid.o.len > 0)
			{
				this.suggFocus = true;
				this.grid.unhighlight();
				pos = this.grid.getR() + this.suggGrid.top;
				this.suggGrid.highlight(pos);
			}
			else
			{
				this.suggFocus = false;
				pos = (this.grid.getR() + 1) * this.o.cSize;
				_global.setTimeout(Delegate.create(this, function ()
												{
													this.grid.highlight(Number(pos - 1));
												}),1);
			}
		}
		return false;
	}

	private function overRightCB():Boolean
	{
		var pos:Number = 0;
		if (this.suggFocus)
		{
			if (this.o.wrap == false)
				return true;
			this.suggFocus = false;
			pos = this.suggGrid.getR() * this.o.cSize;
			this.suggGrid.unhighlight();
			this.grid.highlight(pos);
		}
		else
		{
			if(this.suggGrid.o.len > 0)
			{
				this.suggFocus = true;
				this.grid.unhighlight();
				pos = this.grid.getR() + this.suggGrid.top;
				this.suggGrid.highlight(pos);
			}
			else
			{
				this.suggFocus = false;
				pos = (this.grid.getR()) * this.o.cSize;
				_global.setTimeout(Delegate.create(this, function ()
												{
													this.grid.highlight(Number(pos));
												}),1);
			}
		}
		return false;
	}

	private function suggUpdateCB(o:Object):Void
	{
		o.mc.txt.text = o.data;
	}

	private function shiftText():Void
	{
		if (this.shift == true)
		{
			this.shift = false;
			this.grid.set({data:this.switchMode()});
			this.grid.refresh();
		}
		else
		{
			this.shift = true;
			this.grid.set({data:this.switchMode(true)});
			this.grid.refresh();
		}
	}

	/*
	* Function : get the input text from the input field
	* NOTE : will return astericks (*) if showPassword flag is turned on
	*/
	public function getText():String
	{
		var txt:String = "";
		if (this.o.showPassword)
			txt = this.input;
		else
			txt = this.o.inputTF.text;
		return txt;
	}

	/*
	* Function : add the text before tshe caret in the input field
	* @c : the text to be added
	*/
	 private function addText(c:String):Void
	 {
		var txt:String = this.o.inputTF.text;
		var maxLength:Number = this.o.maxLength;
		if (maxLength != undefined && maxLength != null && txt.length + c.length - 1 > maxLength)
			return;
		if (this.minCursorPos == -1) // init minCursorPos
			this.minCursorPos = this.o.inputCursor._x;

		var charWidth:Number = this.o.inputTF.textWidth;
		if (this.o.showPassword == true)
		{
			txt += "*";
			this.input = this.input.substring(0, this.inputPos) + c + this.input.substring(this.inputPos,this.input.length);
		}
		else
			txt = txt.substring(0, this.inputPos) + c + txt.substring(this.inputPos,txt.length);
		this.o.inputTF.text = txt;
		charWidth = this.o.inputTF.textWidth - charWidth;
		this.textWidths.splice(this.inputPos,0,charWidth);
		this.inputPos ++;
		if (charWidth <= 0)
			return;

		var len:Number = this.textWidths.length;
		var cursorX:Number = this.o.inputCursor._x + charWidth;
		if (this.o.inputTF.maxhscroll == 0)
			this.o.inputCursor._x = cursorX;
		else
		{
			if (this.maxCursorPos == -1) // init maxCursorPos
			{
				var j:Number = 0;
				for (var i:Number = 0; i < len; i++)
					j += this.textWidths[i];
				this.maxCursorPos  = this.minCursorPos + j - this.o.inputTF.maxhscroll;
			}

			if (this.inputPos == this.textWidths.length) // last index
			{
				this.o.inputCursor._x = this.maxCursorPos;
				this.o.inputTF.hscroll = this.o.inputTF.maxhscroll;
			}
			else
			{
				if (this.maxCursorPos >= cursorX) // cursor not at maximum position
					this.o.inputCursor._x = cursorX;
				else
				{
					var maxCursorMove:Number = (this.maxCursorPos - this.minCursorPos)/4; // 25 percent of total textfield width
					var xToMove:Number = 0;
					for (var i:Number = this.inputPos-1; i > 0; i--)
					{
						if (Number(this.inputPos-i) < 0)
							break;
						xToMove += this.textWidths[this.inputPos-i];
						if (this.o.inputTF.hscroll + xToMove > this.o.inputTF.maxhscroll) // check the x position to move is reach the maximum can scroll.
						{
							xToMove -= (xToMove - Number(this.o.inputTF.maxhscroll - this.o.inputTF.hscroll));
							break;
						}
						if (maxCursorMove < xToMove) // check the x position to move is reach the maximum x can move.
						{
							xToMove -= this.textWidths[this.inputPos - i];
							break;
						}
					}

					this.o.inputTF.hscroll += xToMove;
					this.o.inputCursor._x -= (xToMove - charWidth);
				}
			}
		}
		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();

		this.o.onUpdateCB(this.getText());
		if (this.shift == true)
			this.shiftText();
	}

	private function getCombination():String
	{
		var txt:String = this.getText();
		txt = txt.substring(this.acIndex, Number(this.acIndex + this.acCount));
		return txt;
	}

	private function getAutoCompleteWord(combination:String):Array
	{
		var str:String = this.o.acLib[combination];
		str = Util.trim(str);
		var res:Array = new Array();
		if(str.length > 0)
			res = str.split(",");
		return res;
	}

	private function getCombinationIndex():Void
	{
		var ind:Number = -1;
		var c:Number = 1;
		var txt:String = this.getText();
		var sub:String = "";
		var count:Number = -1;
		for (var i:Number = this.inputPos - 1; i >= 0; i--)
		{
			sub = txt.substring(i, Number(i + c));
			var comb:Array = this.getAutoCompleteWord(sub);
			if(comb.length > 0)
			{
				ind = i;
				count = c;
			}
			c++;
		}
		if(ind == -1)
			ind = 0;
		this.acCount = count;
		this.acIndex = ind;
	}

	private function showCombinationList():Void
	{
		_global.clearTimeout(this.acTimeout);
		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.acTimeout = _global.setTimeout(Delegate.create(this, this.showList), 500);
	}

	private function showList():Void
	{
		_global.clearTimeout(this.acTimeout);
		this.getCombinationIndex();
		var comb:Array = this.getAutoCompleteWord(this.getCombination());
		if(comb.length > 0)
		{
			this.acShow = true;
			var l:Number = this.suggGrid.o.len
			this.suggGrid.set({data:comb});
			if(l <= 0)
				this.suggGrid.populateUI(false);
			else
				this.suggGrid.refresh();
			this.suggGrid.unhighlight();
			if(this.suggFocus)
				this.suggGrid.highlight(0);
		}
		else
		{
			if (this.acIndex !== -1)
			{
				if(this.inputPos > 1)
					this.acIndex = this.inputPos - 1;
				this.acCount = 1;
				if(this.acShow == true)
				{
					this.acShow = false;
					this.resetSuggList();
				}
			}
		}
	}

	private function resetSuggList():Void
	{
		var r:Number = this.suggGrid.getR()
		this.suggGrid.set({data:this.o.suggestion});
		this.suggGrid.refresh();
		this.suggGrid.unhighlight();
		if(this.suggFocus)
		{
			if(this.suggGrid.o.len <= 0)
			{
				this.suggFocus = false;
				var pos:Number = (r + 1) * this.o.cSize;
				this.suggGrid.unhighlight();
				this.grid.highlight(Number(pos - 1));
			}
			else
				this.suggGrid.highlight(0);
		}
	}

	/*
	* Function : delete one character before the caret in the input field
	*/
	private function backspace(clearCombination:Boolean):Void
	{
		var txt:String = this.o.inputTF.text;
		if (this.inputPos == 0 || txt.length == 0) // input position at first index and is empty string for input.
			return;

		this.inputPos--;
		txt = txt.substr(0, this.inputPos) + txt.substring(this.inputPos + 1, txt.length);
		if (this.o.showPassword == true)
			this.input = this.input.substr(0, this.inputPos) + this.input.substring(this.inputPos + 1, this.input.length);
		this.o.inputTF.text = txt;
		var charWidth:Number = this.textWidths.splice(this.inputPos,1)[0];
		var cursorX:Number = this.o.inputCursor._x - charWidth;

		if (this.inputPos == this.textWidths.length) // input position at last index
		{
			if (this.o.inputCursor._x == this.maxCursorPos) // cursor at the maximum position
			{
				if (this.o.inputTF.maxhscroll > 0) // check the text is scrollable
					this.o.inputTF.hscroll = this.o.inputTF.maxhscroll;
				else
				{
					this.o.inputCursor._x -= Number(charWidth - this.o.inputTF.hscroll);
					this.o.inputTF.hscroll = 0;
				}
			}
			else
			{
				if (cursorX < this.minCursorPos) //cursor at the minimum position
					this.o.inputCursor._x = minCursorPos;
				else
					this.o.inputCursor._x = cursorX;
			}
		}
		else
		{
			if (this.o.inputTF.maxhscroll > 0) // check the text is scrollable
			{
				if (this.o.inputTF.hscroll > 0)
					this.o.inputTF.hscroll -= charWidth;
				else
				{
					if (this.minCursorPos <= cursorX) // cursor at the minimum position
						this.o.inputCursor._x = cursorX;
					else
						this.o.inputCursor._x = this.minCursorPos;
				}
			}
			else
			{
				if (this.minCursorPos <= cursorX) // cursor at the minimum position
					this.o.inputCursor._x -= Number(charWidth - this.o.inputTF.hscroll);
				else
					this.o.inputCursor._x = this.minCursorPos;
				this.o.inputTF.hscroll = 0;
			}
		}
		
		if(clearCombination !== true && this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();

		this.o.onUpdateCB(this.getText());
		if (this.shift == true)
			this.shiftText();
	}

	/*
	* Function : delete one character after the caret in the input field
	*/
	private function deleteText():Void
	{
		var txt:String = this.o.inputTF.text;
		if (txt.length == 0 || txt.length == this.inputPos)
			return;

		var prevMaxScroll:Number = this.o.inputTF.maxhscroll;
		txt = txt.substr(0, this.inputPos) + txt.substring(this.inputPos + 1, txt.length);
		if (this.o.showPassword == true)
			this.input = this.input.substr(0, this.inputPos) + this.input.substring(this.inputPos + 1, this.input.length);
		this.o.inputTF.text = txt;
		var charWidth:Number = this.textWidths.splice(this.inputPos,1)[0];
		var cursorX:Number = this.o.inputCursor._x - charWidth;

		if (prevMaxScroll > 0)
		{
			if (prevMaxScroll < this.o.inputTF.hscroll)
			{
				this.o.inputCursor._x += (this.o.inputTF.hscroll - prevMaxScroll) + charWidth;
				this.o.inputTF.hscroll -= charWidth;
			}
			else if (prevMaxScroll == this.o.inputTF.hscroll)
			{
				if (this.o.inputTF.hscroll - charWidth >= 0)
				{
					if (cursorX <= this.maxCursorPos) // cursor at the maximum position
						this.o.inputCursor._x += charWidth;
					else
						this.o.inputCursor._x = this.maxCursorPos;
					this.o.inputTF.hscroll -= charWidth;
				}
				else
				{
					this.o.inputCursor._x += this.o.inputTF.hscroll;
					this.o.inputTF.hscroll = 0;
				}
			}
		}

		this.o.onUpdateCB(this.getText());
		if (this.shift == true)
			this.shiftText();
	}

	private function cursorToLeft():Void
	{
		if (this.inputPos <= 0)
			return;
		var charWidth:Number = 0;
		var len:Number = this.textWidths.length;
		var cursorX:Number = 0;
		var maxCursorMove:Number = 0;
		var xToMove:Number = 0;

		charWidth = this.textWidths[this.inputPos - 1];
		cursorX = this.o.inputCursor._x - charWidth;
		if (this.minCursorPos <= cursorX)
			this.o.inputCursor._x = cursorX;
		else
		{
			if (this.maxCursorPos == -1)
				maxCursorMove = (this.o.inputTF.textWidth - this.minCursorPos)/4;
			else
				maxCursorMove = (this.maxCursorPos - this.minCursorPos)/4;
			for (var i:Number = 0; i < this.inputPos; i++)
			{
				if (Number(this.inputPos - i) < 0)
					break;
				xToMove += this.textWidths[this.inputPos - i];
				if (Number(this.o.inputTF.hscroll - xToMove) < 0)
				{
					xToMove -= this.textWidths[this.inputPos - i];
					if (xToMove == 0)
						xToMove = this.o.inputTF.hscroll;
					break;
				}
				if (maxCursorMove < xToMove)
				{
					xToMove -= this.textWidths[this.inputPos - i];
					break;
				}
			}
			this.o.inputTF.hscroll -= xToMove;
			if (Number(xToMove - charWidth) > 0)
				this.o.inputCursor._x += Number(xToMove - charWidth);
			else
				this.o.inputCursor._x = this.minCursorPos;
		}
		this.inputPos--;

		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();
	}

	private function cursorToRight():Void
	{
		if (this.inputPos >= this.textWidths.length)
			return;
		var charWidth:Number = 0;
		var len:Number = this.textWidths.length;
		var cursorX:Number = 0;
		var maxCursorMove:Number = 0;
		var xToMove:Number = 0;

		charWidth = this.textWidths[this.inputPos];
		this.inputPos++;
		cursorX = this.o.inputCursor._x + charWidth;
		if (this.o.inputTF.maxhscroll == 0)
			this.o.inputCursor._x = cursorX;
		else
		{
			if (this.maxCursorPos >= cursorX)
				this.o.inputCursor._x += charWidth;
			else
			{
				maxCursorMove = (this.maxCursorPos - this.minCursorPos)/4;
				for (var i:Number = this.inputPos-1; i > 0; i--)
				{
					if (Number(this.inputPos-i) < 0)
						break;
					xToMove += this.textWidths[this.inputPos-i];
					if (this.o.inputTF.hscroll + xToMove > this.o.inputTF.maxhscroll)
					{
						xToMove -= (xToMove - Number(this.o.inputTF.maxhscroll - this.o.inputTF.hscroll));
						break;
					}
					if (maxCursorMove < xToMove)
					{
						xToMove -= this.textWidths[this.inputPos - i];
						break;
					}
				}
				this.o.inputTF.hscroll += xToMove;
				this.o.inputCursor._x -= Number(xToMove - charWidth);
			}
		}

		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();
	}

	private function cursorToUp():Void
	{
		if (this.minCursorPos == -1)
			return;
		var charWidth:Number = 0;
		var len:Number = this.textWidths.length;
		var cursorX:Number = 0;
		var maxCursorMove:Number = 0;
		var xToMove:Number = 0;

		this.o.inputCursor._x = this.minCursorPos;
		this.o.inputTF.hscroll = 0;
		this.inputPos = 0;

		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();
	}
	
	private function cursorToDown(option:Number):Void
	{
		if (this.textWidths.length == 0)
			return;
		var charWidth:Number = 0;
		var len:Number = this.textWidths.length;
		var cursorX:Number = 0;
		var maxCursorMove:Number = 0;
		var xToMove:Number = 0;

		if (this.o.inputTF.maxhscroll == 0)
		{
			for (var i:Number = 0; i < len; i++)
				xToMove += this.textWidths[i];
			this.o.inputCursor._x = this.minCursorPos + xToMove;
		}
		else
			this.o.inputCursor._x = this.maxCursorPos;
		this.o.inputTF.hscroll = this.o.inputTF.maxhscroll;
		this.inputPos = this.textWidths.length;

		if (this.mode == VirtualKeyboard.FUNCTION_AUTO_COMPLETE)
			this.showCombinationList();
	}

	/*
	* Function : clear the text in the input field
	*/
	private function clearText():Void
	{
		this.acIndex = -1; 
		this.acCount = 0;
		// initialize or reset
		if (this.minCursorPos != -1)
			this.o.inputCursor._x = this.minCursorPos;
		delete this.textWidths;
		this.textWidths = null;
		this.textWidths = new Array();
		this.inputPos = 0;
		this.input = "";
		this.o.inputTF.text = "";
		this.o.inputTF.hscroll = 0;
		this.o.onUpdateCB("");
		if (this.shift == true)
			this.shiftText();
		this.showCombinationList();
	}

	/*
	* Function : function handling events when the user has done the input
	*/
	private function onDone():Void
	{
		this.o.initValue = "";
		this.o.onDoneCB(this.getText());
	}

	/*
	* Function : function handling events when the user has cancel the input
	*/
	private function onCancel():Void
	{
		this.clearText();
		var t:String = this.o.initValue;
		this.o.initValue = "";
		this.insertString(t);
		this.o.onCancelCB(t);
	}
}