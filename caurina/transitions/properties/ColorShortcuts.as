/**
 * properties.ColorShortcuts
 * List of default special color properties (normal and splitter properties) for the Tweener class
 * The function names are strange/inverted because it makes for easier debugging (alphabetic order). They're only for internal use (on this class) anyways.
 *
 * @author		Zeh Fernando, Nate Chatellier, Arthur Debert
 * @version		1.0.0
 */

import caurina.transitions.Tweener;
import caurina.transitions.AuxFunctions;

class caurina.transitions.properties.ColorShortcuts {

	// Defines luminance using sRGB luminance
	private static var LUMINANCE_R:Number = 0.212671;
	private static var LUMINANCE_G:Number = 0.715160;
	private static var LUMINANCE_B:Number = 0.072169;
	
	/**
	 * There's no constructor.
	 */
	public function ColorShortcuts () {
		trace ("This is an static class and should not be instantiated.")
	}

	/**
	 * Registers all the special properties to the Tweener class, so the Tweener knows what to do with them.
	 */
	public static function init():Void {

		// Normal properties
		Tweener.registerSpecialProperty("_color_ra", _oldColor_property_get, _oldColor_property_set, ["ra"]);
		Tweener.registerSpecialProperty("_color_rb", _oldColor_property_get, _oldColor_property_set, ["rb"]);
		Tweener.registerSpecialProperty("_color_ga", _oldColor_property_get, _oldColor_property_set, ["ga"]);
		Tweener.registerSpecialProperty("_color_gb", _oldColor_property_get, _oldColor_property_set, ["gb"]);
		Tweener.registerSpecialProperty("_color_ba", _oldColor_property_get, _oldColor_property_set, ["ba"]);
		Tweener.registerSpecialProperty("_color_bb", _oldColor_property_get, _oldColor_property_set, ["bb"]);
		Tweener.registerSpecialProperty("_color_aa", _oldColor_property_get, _oldColor_property_set, ["aa"]);
		Tweener.registerSpecialProperty("_color_ab", _oldColor_property_get, _oldColor_property_set, ["ab"]);

		Tweener.registerSpecialProperty("_color_redMultiplier", 	_color_property_get,	_color_property_set, ["ra"]);
		Tweener.registerSpecialProperty("_color_redOffset",			_oldColor_property_get, _oldColor_property_set, ["rb"]);
		Tweener.registerSpecialProperty("_color_greenMultiplier",	_color_property_get,	_color_property_set, ["ga"]);
		Tweener.registerSpecialProperty("_color_greenOffset",		_oldColor_property_get, _oldColor_property_set, ["gb"]);
		Tweener.registerSpecialProperty("_color_blueMultiplier",	_color_property_get,	_color_property_set, ["ba"]);
		Tweener.registerSpecialProperty("_color_blueOffset",		_oldColor_property_get, _oldColor_property_set, ["bb"]);
		Tweener.registerSpecialProperty("_color_alphaMultiplier",	_color_property_get,	_color_property_set, ["aa"]);
		Tweener.registerSpecialProperty("_color_alphaOffset",		_oldColor_property_get, _oldColor_property_set, ["ab"]);

		// Normal splitter properties
		Tweener.registerSpecialPropertySplitter("_color", _color_splitter);
		Tweener.registerSpecialPropertySplitter("_colorTransform", _colorTransform_splitter);

		// Color changes that depend on the ColorMatrixFilter
		Tweener.registerSpecialProperty("_brightness",		_brightness_get,	_brightness_set, [false]);
		Tweener.registerSpecialProperty("_tintBrightness",	_brightness_get,	_brightness_set, [true]);
		Tweener.registerSpecialProperty("_contrast",		_contrast_get,		_contrast_set);

	}


	// ==================================================================================================================================
	// PROPERTY GROUPING/SPLITTING functions --------------------------------------------------------------------------------------------

	// ----------------------------------------------------------------------------------------------------------------------------------
	// _color

	/**
	 * Splits the _color parameter into specific color variables
	 *
	 * @param		p_value				Number		The original _color value
	 * @return							Array		An array containing the .name and .value of all new properties
	 */
	public static function _color_splitter (p_value:Number, p_parameters:Array):Array {
		var nArray:Array = new Array();
		if (p_value == null) {
			// No parameter passed, so just resets the color
			nArray.push({name:"_color_redMultiplier",	value:1});
			nArray.push({name:"_color_redOffset",		value:0});
			nArray.push({name:"_color_greenMultiplier",	value:1});
			nArray.push({name:"_color_greenOffset",		value:0});
			nArray.push({name:"_color_blueMultiplier",	value:1});
			nArray.push({name:"_color_blueOffset",		value:0});
		} else {
			// A color tinting is passed, so converts it to the object values
			nArray.push({name:"_color_redMultiplier",	value:0});
			nArray.push({name:"_color_redOffset",		value:AuxFunctions.numberToR(p_value)});
			nArray.push({name:"_color_greenMultiplier",	value:0});
			nArray.push({name:"_color_greenOffset",		value:AuxFunctions.numberToG(p_value)});
			nArray.push({name:"_color_blueMultiplier",	value:0});
			nArray.push({name:"_color_blueOffset",		value:AuxFunctions.numberToB(p_value)});
		}
		return nArray;
	}


	// ----------------------------------------------------------------------------------------------------------------------------------
	// _colorTransform

	/**
	 * Splits the _colorTransform parameter into specific color variables
	 *
	 * @param		p_value				Number		The original _colorTransform value
	 * @return							Array		An array containing the .name and .value of all new properties
	 */
	public static function _colorTransform_splitter (p_value:Object, p_parameters:Array):Array {
		var nArray:Array = new Array();
		if (p_value == null) {
			// No parameter passed, so just resets the color
			nArray.push({name:"_color_redMultiplier",	value:1});
			nArray.push({name:"_color_redOffset",		value:0});
			nArray.push({name:"_color_greenMultiplier",	value:1});
			nArray.push({name:"_color_greenOffset",		value:0});
			nArray.push({name:"_color_blueMultiplier",	value:1});
			nArray.push({name:"_color_blueOffset",		value:0});
		} else {
			// A color tinting is passed, so converts it to the object values
			if (p_value.ra != undefined) nArray.push({name:"_color_ra", value:p_value.ra});
			if (p_value.rb != undefined) nArray.push({name:"_color_rb", value:p_value.rb});
			if (p_value.ga != undefined) nArray.push({name:"_color_ba", value:p_value.ba});
			if (p_value.gb != undefined) nArray.push({name:"_color_bb", value:p_value.bb});
			if (p_value.ba != undefined) nArray.push({name:"_color_ga", value:p_value.ga});
			if (p_value.bb != undefined) nArray.push({name:"_color_gb", value:p_value.gb});
			if (p_value.aa != undefined) nArray.push({name:"_color_aa", value:p_value.aa});
			if (p_value.ab != undefined) nArray.push({name:"_color_ab", value:p_value.ab});
			if (p_value.redMultiplier != undefined)		nArray.push({name:"_color_redMultiplier", value:p_value.redMultiplier});
			if (p_value.redOffset != undefined)			nArray.push({name:"_color_redOffset", value:p_value.redOffset});
			if (p_value.blueMultiplier != undefined)	nArray.push({name:"_color_blueMultiplier", value:p_value.blueMultiplier});
			if (p_value.blueOffset != undefined)		nArray.push({name:"_color_blueOffset", value:p_value.blueOffset});
			if (p_value.greenMultiplier != undefined)	nArray.push({name:"_color_greenMultiplier", value:p_value.greenMultiplier});
			if (p_value.greenOffset != undefined)		nArray.push({name:"_color_greenOffset", value:p_value.greenOffset});
			if (p_value.alphaMultiplier != undefined)	nArray.push({name:"_color_alphaMultiplier", value:p_value.alphaMultiplier});
			if (p_value.alphaOffset != undefined)		nArray.push({name:"_color_alphaOffset", value:p_value.alphaOffset});
		}
		return nArray;
	}


	// ==================================================================================================================================
	// NORMAL SPECIAL PROPERTY functions ------------------------------------------------------------------------------------------------

	// ----------------------------------------------------------------------------------------------------------------------------------
	// _color_*

	/**
	 * _color_*
	 * Generic function for the ra/rb/etc components of the deprecated colorTransform object
	 */
	public static function _oldColor_property_get (p_obj:Object, p_parameters:Array):Number {
		return (new Color(p_obj)).getTransform()[p_parameters[0]];
	}
	public static function _oldColor_property_set (p_obj:Object, p_value:Number, p_parameters:Array):Void {
		var cfObj:Object = new Object();
		cfObj[p_parameters[0]] = p_value; // Math.round(p_value);
		(new Color(p_obj)).setTransform(cfObj);
	}

	/**
	 * _color_*
	 * Generic function for the redMultiplier/redOffset/etc components of the new colorTransform
	 */
	public static function _color_property_get (p_obj:Object, p_parameters:Array):Number {
		return (new Color(p_obj)).getTransform()[p_parameters[0]] / 100;
	}
	public static function _color_property_set (p_obj:Object, p_value:Number, p_parameters:Array):Void {
		var cfObj:Object = new Object();
		cfObj[p_parameters[0]] = p_value * 100;
		(new Color(p_obj)).setTransform(cfObj);
	}

	// ----------------------------------------------------------------------------------------------------------------------------------
	// Special coloring

	/**
	 * _brightness
	 * Brightness of an object: -1 -> [0] -> +1
	 */
	public static function _brightness_get (p_obj:Object, p_parameters:Array):Number {

		var isTint:Boolean = p_parameters[0];

		/*
		// Using ColorMatrix:
		
		var mtx:Array = getObjectMatrix(p_obj);
		
		var mc:Number = 1 - ((mtx[0] + mtx[6] + mtx[12]) / 3); // Brightness as determined by the main channels
		var co:Number = (mtx[4] + mtx[9] + mtx[14]) / 3; // Brightness as determined by the offset channels
		*/

		var cfm:Object = (new Color(p_obj)).getTransform();
		var mc:Number = 1 - ((cfm.ra + cfm.ga + cfm.ba) / 300); // Brightness as determined by the main channels
		var co:Number = (cfm.rb + cfm.gb + cfm.bb) / 3;

		if (isTint) {
			// Tint style
			return co > 0 ? co / 255 : -mc;
		} else {
			// Native, Flash "Adjust Color" and Photoshop style
			return co / 100;
		}
	}
	public static function _brightness_set (p_obj:Object, p_value:Number, p_parameters:Array):Void {
		//var mtx:Array = getObjectMatrix(p_obj);

		var isTint:Boolean = p_parameters[0];

		var mc:Number; // Main channel
		var co:Number; // Channel offset

		if (isTint) {
			// Tint style
			mc = 1 - Math.abs(p_value);
			co = p_value > 0 ? Math.round(p_value*255) : 0;
		} else {
			// Native, Flash "Adjust Color" and Photoshop style
			mc = 1;
			co = Math.round(p_value*100);
		}

		/*
		// Using ColorMatrix:
		var mtx:Array = [
			mc, cc, cc, cc, co,
			cc, mc, cc, cc, co,
			cc, cc, mc, cc, co,
			0,  0,  0,  1,  0
		];
		setObjectMatrix(p_obj, mtx);
		*/
		var cfm:Object = {ra:mc * 100, rb:co, ga:mc * 100, gb:co, ba:mc * 100, bb:co};
		(new Color(p_obj)).setTransform(cfm);
	}

	/**
	 * _contrast
	 * Contrast of an object: -1 -> [0] -> +1
	 */
	public static function _contrast_get (p_obj:Object, p_parameters:Array):Number {

		/*
		// Using ColorMatrix:
		var mtx:Array = getObjectMatrix(p_obj);

		var mc:Number = ((mtx[0] + mtx[6] + mtx[12]) / 3) - 1;		// Contrast as determined by the main channels
		var co:Number = (mtx[4] + mtx[9] + mtx[14]) / 3 / -128;		// Contrast as determined by the offset channel
		*/
		var cfm:Object = (new Color(p_obj)).getTransform();
		var mc:Number;	// Contrast as determined by the main channels
		var co:Number;	// Contrast as determined by the offset channel
		mc = ((cfm.ra + cfm.ga + cfm.ba) / 300) - 1;
		co = (cfm.rb + cfm.gb + cfm.bb) / 3 / -128;
		/*
		if (cfm.ra < 100) {
			// Low contrast
			mc = ((cfm.ra + cfm.ga + cfm.ba) / 300) - 1;
			co = (cfm.rb + cfm.gb + cfm.bb) / 3 / -128;
		} else {
			// High contrast
			mc = (((cfm.ra + cfm.ga + cfm.ba) / 300) - 1) / 37;
			co = (cfm.rb + cfm.gb + cfm.bb) / 3 / -3840;
		}
		*/

		return (mc+co)/2;
	}
	public static function _contrast_set (p_obj:Object, p_value:Number, p_parameters:Array):Void {
		
		var mc:Number;	// Main channel
		var co:Number;	// Channel offset
		mc = p_value + 1;
		co = Math.round(p_value*-128);

		/*
		if (p_value < 0) {
			// Low contrast
			mc = p_value + 1;
			co = Math.round(p_value*-128);
		} else {
			// High contrast
			mc = (p_value * 37) + 1;
			co = Math.round(p_value*-3840);
		}
		*/
		
		// Flash: * 8, * -512

		/*
		// Using ColorMatrix:
		var mtx:Array = [
			mc,	0,	0, 	0, co,
			0,	mc,	0, 	0, co,
			0,	0,	mc,	0, co,
			0,  0, 	0, 	1,  0
		];
		setObjectMatrix(p_obj, mtx);
		*/
		var cfm:Object = {ra:mc * 100, rb:co, ga:mc * 100, gb:co, ba:mc * 100, bb:co};
		(new Color(p_obj)).setTransform(cfm);
	}

}
