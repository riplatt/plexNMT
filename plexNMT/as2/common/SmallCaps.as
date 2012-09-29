class plexNMT.as2.common.SmallCaps {

	// Constants:
	public static var CLASS_REF=plexNMT.as2.common.SmallCaps;
	/**
	 * SmallCaps class.
	 * @description   Provides an interface for a TextField that should display its text in Small Caps style.  It applies text to the textfield,
	 *             and applies TextFormat objects to it as needed to resize the font to simulate the Small Caps style.  Characters in the text
	 *             that are uppercase appear in a larger font size, and all other characters appear in a smaller font size.  All lowercase
	 *             letters are coverted to uppercase after the font sizes have been determined.
	 * @author      Dru Kepple
	 * @version      0.2
	 **/


	private var _textField:TextField;
	private var _upperCaseSize:Number;
	private var _lowerCaseSize:Number;

	private var _upperCaseFormat:TextFormat;
	private var _lowerCaseFormat:TextFormat;

	/**
	* Constructor.
	* @param   textField      	TextField. The TextField to process.
	* @param   lowerCaseSize   	Number. Optional, defaults to 80% of the upperCaseSize.  The font size to be used for the "small" caps.
	* @param   upperCaseSize   	Number. Optional, defaults to the normal font size of the TextField specified by textField.
	*                      		The font size to be used for the "large" caps.
	**/
	public function SmallCaps(textField:TextField, lowerCaseSize:Number, upperCaseSize:Number) {
		if (textField == undefined) {
			trace("**** WARNING **** The textField parameter must be supplied.");
			return;
		}
		_textField = textField;
		// If upperCaseSize wasn't supplied, grab it from the textField.
		_upperCaseSize = upperCaseSize == undefined ? _textField.getTextFormat().size : upperCaseSize;
		// If lowerCaseSize wasn't supplied, grab it from 80% of the upperCaseSize.
		_lowerCaseSize = lowerCaseSize == undefined ? _upperCaseSize*0.8 : lowerCaseSize;

		_textField.autoSize = true;

		init();
	}

	private function init():Void {
		createVars();
	}

	private function createVars():Void {
		_upperCaseFormat = new TextFormat(null, _upperCaseSize);
		_lowerCaseFormat = new TextFormat(null, _lowerCaseSize);
	}

	/**
	* Turns the text of a TextField into faux-Small Caps style, parsing the string to turn chacters that are capitalized into
	* a larger font size, and to turn characters that are lowercase into uppercase but at a smaller font size.
	* @param   str      String. The String to set as the text of the TextField.  The String will get processed to be all uppercase,
	*                	and in the TextField it will have two different TextFormats applied to it for the Small Caps effect.
	* @return   Nothing.
	**/
	public function set text(str:String):Void {
		var upperCaseIndices:Array = new Array();
		var len = str.length;
		for (var i:Number = 0; i<len; i++) {
			var charCode = str.charCodeAt(i);
			if ((charCode>=65 && charCode<=90) || (charCode>=48&&charCode<=57)) {
				upperCaseIndices.push(i);
			}
		}

		_textField.text = str.toUpperCase();
		_textField.setTextFormat(_lowerCaseFormat);

		var len:Number = upperCaseIndices.length;
		for (var i:Number = 0; i<len; i++) {
			var strIndex:Number = upperCaseIndices[i];
			_textField.setTextFormat(strIndex, strIndex+1, _upperCaseFormat);
		}

	}

	/**
	* Provides access to the TextField associated with this SmallCaps object.
	* @return   TextField [read-only]
	**/
	public function get textField():TextField {
		return _textField;
	}

}