/**
 * properties.DisplayShortcuts.as
 * List of default special MovieClip properties (normal and splitter properties) for the Tweener class
 * The function names are strange/inverted because it makes for easier debugging (alphabetic order). They're only for internal use (on this class) anyways.
 *
 * @author		Zeh Fernando, Nate Chatellier, Arthur Debert
 * @version		1.0.0
 */

import caurina.transitions.Tweener;

class caurina.transitions.properties.DisplayShortcuts {

	/**
	 * There's no constructor.
	 */
	public function DisplayShortcuts () {
		trace ("This is an static class and should not be instantiated.")
	}

	/**
	 * Registers all the special properties to the Tweener class, so the Tweener knows what to do with them.
	 */
	public static function init():Void {

		// Normal properties
		Tweener.registerSpecialProperty("_frame", _frame_get, _frame_set);
		Tweener.registerSpecialProperty("_autoAlpha", _autoAlpha_get, _autoAlpha_set);

		// Scale splitter properties
		Tweener.registerSpecialPropertySplitter("_scale", _scale_splitter);

	}


	// ==================================================================================================================================
	// PROPERTY GROUPING/SPLITTING functions --------------------------------------------------------------------------------------------

	// ----------------------------------------------------------------------------------------------------------------------------------
	// scale
	public static function _scale_splitter(p_value:Number, p_parameters:Array) : Array{
		var nArray:Array = new Array();
		nArray.push({name:"_xscale", value: p_value});
		nArray.push({name:"_yscale", value: p_value});
		return nArray;
	}


	// ==================================================================================================================================
	// NORMAL SPECIAL PROPERTY functions ------------------------------------------------------------------------------------------------

	// ----------------------------------------------------------------------------------------------------------------------------------
	// _frame

	/**
	 * Returns the current frame number from the movieclip timeline
	 *
	 * @param		p_obj				Object		MovieClip object
	 * @return							Number		The current frame
	 */
	public static function _frame_get (p_obj:Object):Number {
		return p_obj._currentframe;
	}

	/**
	 * Sets the timeline frame
	 *
	 * @param		p_obj				Object		MovieClip object
	 * @param		p_value				Number		New frame number
	 */
	public static function _frame_set (p_obj:Object, p_value:Number):Void {
		p_obj.gotoAndStop(Math.round(p_value));
	}

	
	// ----------------------------------------------------------------------------------------------------------------------------------
	// _autoAlpha

	/**
	 * Returns the current alpha
	 *
	 * @param		p_obj				Object		MovieClip or Textfield object
	 * @return							Number		The current alpha
	 */
	public static function _autoAlpha_get (p_obj:Object):Number {
		return p_obj._alpha;
	}

	/**
	 * Sets the current autoAlpha
	 *
	 * @param		p_obj				Object		MovieClip or Textfield object
	 * @param		p_value				Number		New alpha
	 */
	public static function _autoAlpha_set (p_obj:Object, p_value:Number):Void {
		p_obj._alpha = p_value;
		p_obj._visible = p_value > 0;
	}

}
