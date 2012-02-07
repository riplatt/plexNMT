﻿/**
 * Tweener
 * Transition controller for movieclips, sounds, textfields and other objects
 *
 * @author		Zeh Fernando, Nate Chatellier, Arthur Debert, Francis Turmel
 * @version		1.33.74
 */

/*
Licensed under the MIT License

Copyright (c) 2006-2008 Zeh Fernando, Nate Chatellier, Arthur Debert and Francis
Turmel

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

http://code.google.com/p/tweener/
http://code.google.com/p/tweener/wiki/License
*/

import caurina.transitions.Equations;
import caurina.transitions.AuxFunctions;
import caurina.transitions.SpecialProperty;
import caurina.transitions.SpecialPropertyModifier;
import caurina.transitions.SpecialPropertySplitter;
import caurina.transitions.TweenListObj;
import caurina.transitions.PropertyInfoObj;

class caurina.transitions.Tweener {

	private static var _engineExists:Boolean = false;		// Whether or not the engine is currently running
	private static var _inited:Boolean = false;				// Whether or not the class has been initiated
	private static var _currentTime:Number;					// The current time. This is generic for all tweenings for a "time grid" based update
	private static var _currentTimeFrame:Number;			// The current frame. Used on frame-based tweenings

	private static var _tweenList:Array;					// List of active tweens

	private static var _timeScale:Number = 1;				// Time scale (default = 1)

	private static var _transitionList:Object;				// List of "pre-fetched" transition functions
	private static var _specialPropertyList:Object;			// List of special properties
	private static var _specialPropertyModifierList:Object;	// List of special property modifiers
	private static var _specialPropertySplitterList:Object;	// List of special property splitters

	public static var autoOverwrite:Boolean = true;			// If true, auto overwrite on new tweens is on unless declared as false

	/**
	 * There's no constructor.
	 */
	public function Tweener () {
		trace ("Tweener is an static class and should not be instantiated.");
	}


	// ==================================================================================================================================
	// TWEENING CONTROL functions -------------------------------------------------------------------------------------------------------

	/**
	 * Adds a new tweening
	 *
	 * @param		(first-n param)		Object				Object that should be tweened: a movieclip, textfield, etc.. OR an array of objects
	 * @param		(last param)		Object				Object containing the specified parameters in any order, as well as the properties that should be tweened and their values
	 * @param		.time				Number				Time in seconds or frames for the tweening to take (defaults 2)
	 * @param		.delay				Number				Delay time (defaults 0)
	 * @param		.useFrames			Boolean				Whether to use frames instead of seconds for time control (defaults false)
	 * @param		.transition			String/Function		Type of transition equation... (defaults to "easeoutexpo")
	 * @param		.transitionParams	Object				* Direct property, See the TweenListObj class
	 * @param		.onStart			Function			* Direct property, See the TweenListObj class
	 * @param		.onUpdate			Function			* Direct property, See the TweenListObj class
	 * @param		.onComplete			Function			* Direct property, See the TweenListObj class
	 * @param		.onOverwrite		Function			* Direct property, See the TweenListObj class
	 * @param		.onStartParams		Array				* Direct property, See the TweenListObj class
	 * @param		.onUpdateParams		Array				* Direct property, See the TweenListObj class
	 * @param		.onCompleteParams	Array				* Direct property, See the TweenListObj class
	 * @param		.onOverwriteParams	Array				* Direct property, See the TweenListObj class
	 * @param		.rounded			Boolean				* Direct property, See the TweenListObj class
	 * @param		.skipUpdates		Number				* Direct property, See the TweenListObj class
	 * @return							Boolean				TRUE if the tween was successfully added, FALSE if otherwise
	 */
	public static function addTween (p_scopes:Object, p_parameters:Object):Boolean {
		if (p_scopes == undefined) return false;

		var i:Number, j:Number, istr:String;

		var rScopes:Array; // List of objects to tween
		if (p_scopes instanceof Array) {
			// The first argument is an array
			rScopes = p_scopes.concat();
		} else {
			// The first argument(s) is(are) object(s)
			rScopes = [p_scopes];
		}

        // make properties chain ("inheritance")
		var p_obj:Object = TweenListObj.makePropertiesChain(p_parameters);

		// Creates the main engine if it isn't active
		if (!_inited) init();
		if (!_engineExists || _root[getControllerName()] == undefined) startEngine(); // Quick fix for Flash not resetting the vars on double ctrl+enter...

		// Creates a "safer", more strict tweening object
		var rTime:Number = (isNaN(p_obj.time) ? 0 : p_obj.time); // Real time
		var rDelay:Number = (isNaN(p_obj.delay) ? 0 : p_obj.delay); // Real delay

		// Creates the property list; everything that isn't a hardcoded variable
		var rProperties:Object = new Object(); // Object containing a list of PropertyInfoObj instances
		var restrictedWords:Object = {overwrite:true, time:true, delay:true, useFrames:true, skipUpdates:true, transition:true, transitionParams:true, onStart:true, onUpdate:true, onComplete:true, onOverwrite:true, onError:true, rounded:true, onStartParams:true, onUpdateParams:true, onCompleteParams:true, onOverwriteParams:true, onStartScope:true, onUpdateScope:true, onCompleteScope:true, onOverwriteScope:true, onErrorScope:true};
		var modifiedProperties:Object = new Object();
		for (istr in p_obj) {
			if (!restrictedWords[istr]) {
				// It's an additional pair, so adds
				if (_specialPropertySplitterList[istr] != undefined) {
					// Special property splitter
					var splitProperties:Array = _specialPropertySplitterList[istr].splitValues(p_obj[istr], _specialPropertySplitterList[istr].parameters);
					for (i = 0; i < splitProperties.length; i++) {
						if (_specialPropertySplitterList[splitProperties[i].name] != undefined) {
							var splitProperties2:Array = _specialPropertySplitterList[splitProperties[i].name].splitValues(splitProperties[i].value, _specialPropertySplitterList[splitProperties[i].name].parameters);
							for (j = 0; j < splitProperties2.length; j++) {
								rProperties[splitProperties2[j].name] = {valueStart:undefined, valueComplete:splitProperties2[j].value, arrayIndex:splitProperties2[j].arrayIndex, isSpecialProperty:false};
							}
						} else {
							rProperties[splitProperties[i].name] = {valueStart:undefined, valueComplete:splitProperties[i].value, arrayIndex:splitProperties[i].arrayIndex, isSpecialProperty:false};
						}
					}
				} else if (_specialPropertyModifierList[istr] != undefined) {
					// Special property modifier
					var tempModifiedProperties:Array = _specialPropertyModifierList[istr].modifyValues(p_obj[istr]);
					for (i = 0; i < tempModifiedProperties.length; i++) {
						modifiedProperties[tempModifiedProperties[i].name] = {modifierParameters:tempModifiedProperties[i].parameters, modifierFunction:_specialPropertyModifierList[istr].getValue};
					}
				} else {
					// Regular property or special property, just add the property normally
					rProperties[istr] = {valueStart:undefined, valueComplete:p_obj[istr]};
				}
			}
		}

		// Verifies whether the properties exist or not, for warning messages
		for (istr in rProperties) {
			if (_specialPropertyList[istr] != undefined) {
				rProperties[istr].isSpecialProperty = true;
			} else {
				if (rScopes[0][istr] == undefined) {
					printError("The property '" + istr + "' doesn't seem to be a normal object property of " + rScopes[0].toString() + " or a registered special property.");
				}
			}
		}

		// Adds the modifiers to the list of properties
		for (istr in modifiedProperties) {
			if (rProperties[istr] != undefined) {
				rProperties[istr].modifierParameters = modifiedProperties[istr].modifierParameters;
				rProperties[istr].modifierFunction = modifiedProperties[istr].modifierFunction;
			}
			
		}
		
		var rTransition:Function; // Real transition

		if (typeof p_obj.transition == "string") {
			// String parameter, transition names
			var trans:String = p_obj.transition.toLowerCase();
			rTransition = _transitionList[trans];
		} else {
			// Proper transition function
			rTransition = p_obj.transition;
		}
		if (rTransition == undefined) rTransition = _transitionList["easeoutexpo"];

		var nProperties:Object;
		var nTween:TweenListObj;
		var myT:Number;

		for (i = 0; i < rScopes.length; i++) {
			// Makes a copy of the properties
			nProperties = new Object();
			for (istr in rProperties) {
				nProperties[istr] = new PropertyInfoObj(rProperties[istr].valueStart, rProperties[istr].valueComplete, rProperties[istr].valueComplete, rProperties[istr].arrayIndex, {}, rProperties[istr].isSpecialProperty, rProperties[istr].modifierFunction, rProperties[istr].modifierParameters);
			}

			if (p_obj.useFrames == true) {
				nTween = new TweenListObj(
					/* scope			*/	rScopes[i],
					/* timeStart		*/	_currentTimeFrame + (rDelay / _timeScale),
					/* timeComplete		*/	_currentTimeFrame + ((rDelay + rTime) / _timeScale),
					/* useFrames		*/	true,
					/* transition		*/	rTransition,
											p_obj.transitionParams
				);
			} else {
				nTween = new TweenListObj(
					/* scope			*/	rScopes[i],
					/* timeStart		*/	_currentTime + ((rDelay * 1000) / _timeScale),
					/* timeComplete		*/	_currentTime + (((rDelay * 1000) + (rTime * 1000)) / _timeScale),
					/* useFrames		*/	false,
					/* transition		*/	rTransition,
											p_obj.transitionParams
				);
			}

			nTween.properties			=	nProperties;
			nTween.onStart				=	p_obj.onStart;
			nTween.onUpdate				=	p_obj.onUpdate;
			nTween.onComplete			=	p_obj.onComplete;
			nTween.onOverwrite			=	p_obj.onOverwrite;
			nTween.onError              =   p_obj.onError;
			nTween.onStartParams		=	p_obj.onStartParams;
			nTween.onUpdateParams		=	p_obj.onUpdateParams;
			nTween.onCompleteParams		=	p_obj.onCompleteParams;
			nTween.onOverwriteParams	=	p_obj.onOverwriteParams;
			nTween.onStartScope			=	p_obj.onStartScope;
			nTween.onUpdateScope		=	p_obj.onUpdateScope;
			nTween.onCompleteScope		=	p_obj.onCompleteScope;
			nTween.onOverwriteScope		=	p_obj.onOverwriteScope;
			nTween.onErrorScope			=	p_obj.onErrorScope;
			nTween.rounded				=	p_obj.rounded;
			nTween.skipUpdates			=	p_obj.skipUpdates;

			// Remove other tweenings that occur at the same time
			if (p_obj.overwrite == undefined ? autoOverwrite : p_obj.overwrite) removeTweensByTime(nTween.scope, nTween.properties, nTween.timeStart, nTween.timeComplete);

			// And finally adds it to the list
			_tweenList.push(nTween);

			// Immediate update and removal if it's an immediate tween -- if not deleted, it executes at the end of this frame execution
			if (rTime == 0 && rDelay == 0) {
				myT = _tweenList.length-1;
				updateTweenByIndex(myT);
				removeTweenByIndex(myT);
			}
		}

		return true;
	}

	// A "caller" is like this: [          |     |  | ||] got it? :)
	// this function is crap - should be fixed later/extend on addTween()

	/**
	 * Adds a new *caller* tweening
	 *
	 * @param		(first-n param)		Object				Object that should be tweened: a movieclip, textfield, etc.. OR an array of objects
	 * @param		(last param)		Object				Object containing the specified parameters in any order, as well as the properties that should be tweened and their values
	 * @param		.time				Number				Time in seconds or frames for the tweening to take (defaults 2)
	 * @param		.delay				Number				Delay time (defaults 0)
	 * @param		.count				Number				Number of times this caller should be called
	 * @param		.transition			String/Function		Type of transition equation... (defaults to "easeoutexpo")
	 * @param		.onStart			Function			Event called when tween starts
	 * @param		.onUpdate			Function			Event called when tween updates
	 * @param		.onComplete			Function			Event called when tween ends
	 * @param		.waitFrames			Boolean				Whether to wait (or not) one frame for each call
	 * @return							Boolean				TRUE if the tween was successfully added, FALSE if otherwise
	 */
	public static function addCaller (p_scopes:Object, p_parameters:Object):Boolean {
		if (p_scopes == undefined) return false;

		var i:Number;

		var rScopes:Array; // List of objects to tween
		if (p_scopes instanceof Array) {
			// The first argument is an array
			rScopes = p_scopes.concat();
		} else {
			// The first argument(s) is(are) object(s)
			rScopes = [p_scopes];
		}

		var p_obj:Object = p_parameters;

		// Creates the main engine if it isn't active
		if (!_inited) init();
		if (!_engineExists || _root[getControllerName()] == undefined) startEngine(); // Quick fix for Flash not resetting the vars on double ctrl+enter...

		// Creates a "safer", more strict tweening object
		var rTime:Number = (isNaN(p_obj.time) ? 0 : p_obj.time); // Real time
		var rDelay:Number = (isNaN(p_obj.delay) ? 0 : p_obj.delay); // Real delay

		var rTransition:Function; // Real transition
		if (typeof p_obj.transition == "string") {
			// String parameter, transition names
			var trans:String = p_obj.transition.toLowerCase();
			rTransition = _transitionList[trans];
		} else {
			// Proper transition function
			rTransition = p_obj.transition;
		}
		if (rTransition == undefined) rTransition = _transitionList["easeoutexpo"];

		var nTween:TweenListObj;
		var myT:Number;
		for (i = 0; i < rScopes.length; i++) {

			if (p_obj.useFrames == true) {
				nTween = new TweenListObj(
					/* scope			*/	rScopes[i],
					/* timeStart		*/	_currentTimeFrame + (rDelay / _timeScale),
					/* timeComplete		*/	_currentTimeFrame + ((rDelay + rTime) / _timeScale),
					/* useFrames		*/	true,
					/* transition		*/	rTransition,
											p_obj.transitionParams
				);
			} else {
				nTween = new TweenListObj(
					/* scope			*/	rScopes[i],
					/* timeStart		*/	_currentTime + ((rDelay * 1000) / _timeScale),
					/* timeComplete		*/	_currentTime + (((rDelay * 1000) + (rTime * 1000)) / _timeScale),
					/* useFrames		*/	false,
					/* transition		*/	rTransition,
											p_obj.transitionParams
				);
			}

			nTween.properties			=	undefined;
			nTween.onStart				=	p_obj.onStart;
			nTween.onUpdate				=	p_obj.onUpdate;
			nTween.onComplete			=	p_obj.onComplete;
			nTween.onOverwrite			=	p_obj.onOverwrite;
			nTween.onStartParams		=	p_obj.onStartParams;
			nTween.onUpdateParams		=	p_obj.onUpdateParams;
			nTween.onCompleteParams		=	p_obj.onCompleteParams;
			nTween.onOverwriteParams	=	p_obj.onOverwriteParams;
			nTween.onStartScope			=	p_obj.onStartScope;
			nTween.onUpdateScope		=	p_obj.onUpdateScope;
			nTween.onCompleteScope		=	p_obj.onCompleteScope;
			nTween.onOverwriteScope		=	p_obj.onOverwriteScope;
			nTween.onErrorScope			=	p_obj.onErrorScope;
			nTween.isCaller				=	true;
			nTween.count				=	p_obj.count;
			nTween.waitFrames			=	p_obj.waitFrames;

			// And finally adds it to the list
			_tweenList.push(nTween);

			// Immediate update and removal if it's an immediate tween -- if not deleted, it executes at the end of this frame execution
			if (rTime == 0 && rDelay == 0) {
				myT = _tweenList.length-1;
				updateTweenByIndex(myT);
				removeTweenByIndex(myT);
			}
		}

		return true;
	}

	/**
	 * Remove an specified tweening of a specified object the tweening list, if it conflicts with the given time
	 *
	 * @param		p_scope				Object						List of objects affected
	 * @param		p_properties		Object 						List of properties affected (PropertyInfoObj instances)
	 * @param		p_timeStart			Number						Time when the new tween starts
	 * @param		p_timeComplete		Number						Time when the new tween ends
	 * @return							Boolean						Whether or not it actually deleted something
	 */
	public static function removeTweensByTime (p_scope:Object, p_properties:Object, p_timeStart:Number, p_timeComplete:Number):Boolean {
		var removed:Boolean = false;
		var removedLocally:Boolean;

		var i:Number;
		var tl:Number = _tweenList.length;
		var pName:String;

		for (i = 0; i < tl; i++) {
			if (p_scope == _tweenList[i].scope) {
				// Same object...
				if (p_timeComplete > _tweenList[i].timeStart && p_timeStart < _tweenList[i].timeComplete) {
					// New time should override the old one...
					removedLocally = false;
					for (pName in _tweenList[i].properties) {
						if (p_properties[pName] != undefined) {
							// Same object, same property
							// Finally, remove this old tweening and use the new one
							if (_tweenList[i].onOverwrite != undefined) {
								var eventScope:Object = _tweenList[i].onOverwriteScope != undefined ? _tweenList[i].onOverwriteScope : _tweenList[i].scope;
								try {
									_tweenList[i].onOverwrite.apply(eventScope, _tweenList[i].onOverwriteParams);
								} catch(e:Error) {
									handleError(_tweenList[i], e, "onOverwrite");
								}
							}
							_tweenList[i].properties[pName] = undefined;
							delete _tweenList[i].properties[pName];
							removedLocally = true;
							removed = true;
						}
					}
					if (removedLocally) {
						// Verify if this can be deleted
						if (AuxFunctions.getObjectLength(_tweenList[i].properties) == 0) removeTweenByIndex(i);
					}
				}
			}
		}

		return removed;
	}

	/**
	 * Remove tweenings from a given object from the tweening list
	 *
	 * @param		p_tween				Object		Object that must have its tweens removed
	 * @param		(2nd-last params)	Object		Property(ies) that must be removed
	 * @return							Boolean		Whether or not it successfully removed this tweening
	 */
	public static function removeTweens (p_scope:Object):Boolean {
		// Create the property list
		var properties:Array = new Array();
		var i:Number;
		for (i = 1; i < arguments.length; i++) {
			if (typeof(arguments[i]) == "string" && !AuxFunctions.isInArray(arguments[i], properties)) {
				if (_specialPropertySplitterList[arguments[i]]){
					//special property, get splitter array first
					var sps:SpecialPropertySplitter = _specialPropertySplitterList[arguments[i]];
					var specialProps:Array = sps.splitValues(p_scope, null);
					for (var j:Number = 0; j<specialProps.length; j++){
					//trace(specialProps[j].name);
						properties.push(specialProps[j].name);
					}
				} else {
					properties.push(arguments[i]);
				}
			}
		}

		// Call the affect function on the specified properties
		return affectTweens(removeTweenByIndex, p_scope, properties);
	}

	/**
	 * Remove all tweenings from the engine
	 *
	 * @return							Boolean		Whether or not it successfully removed a tweening
	 */
	public static function removeAllTweens ():Boolean {
		var removed:Boolean = false;
		var i:Number;
		for (i = 0; i < _tweenList.length; i++) {
			removeTweenByIndex(i);
			removed = true;
		}
		return removed;
	}

	/**
	 * Pause tweenings from a given object
	 *
	 * @param		p_scope				Object		Object that must have its tweens paused
	 * @param		(2nd-last params)	Object		Property(ies) that must be paused
	 * @return							Boolean		Whether or not it successfully paused something
	 */
	public static function pauseTweens (p_scope:Object):Boolean {
		// Create the property list
		var properties:Array = new Array();
		var i:Number;
		for (i = 1; i < arguments.length; i++) {
			if (typeof(arguments[i]) == "string" && !AuxFunctions.isInArray(arguments[i], properties)) properties.push(arguments[i]);
		}
		// Call the affect function on the specified properties
		return affectTweens(pauseTweenByIndex, p_scope, properties);
	}

	/**
	 * Pause all tweenings on the engine
	 *
	 * @return							Boolean		Whether or not it successfully paused a tweening
	 */
	public static function pauseAllTweens ():Boolean {
		var paused:Boolean = false;
		var i:Number;
		for (i = 0; i < _tweenList.length; i++) {
			pauseTweenByIndex(i);
			paused = true;
		}
		return paused;
	}

	/**
	 * Resume tweenings from a given object
	 *
	 * @param		p_scope				Object		Object that must have its tweens resumed
	 * @param		(2nd-last params)	Object		Property(ies) that must be resumed
	 * @return							Boolean		Whether or not it successfully resumed something
	 */
	public static function resumeTweens (p_scope:Object):Boolean {
		// Create the property list
		var properties:Array = new Array();
		var i:Number;
		for (i = 1; i < arguments.length; i++) {
			if (typeof(arguments[i]) == "string" && !AuxFunctions.isInArray(arguments[i], properties)) properties.push(arguments[i]);
		}
		// Call the affect function on the specified properties
		return affectTweens(resumeTweenByIndex, p_scope, properties);
	}

	/**
	 * Resume all tweenings on the engine
	 *
	 * @return							Boolean		Whether or not it successfully resumed a tweening
	 */
	public static function resumeAllTweens ():Boolean {
		var resumed:Boolean = false;
		var i:Number;
		for (i = 0; i < _tweenList.length; i++) {
			resumeTweenByIndex(i);
			resumed = true;
		}
		return resumed;
	}

	/**
	 * Do some generic action on specific tweenings (pause, resume, remove, more?)
	 *
	 * @param		p_function			Function	Function to run on the tweenings that match
	 * @param		p_scope				Object		Object that must have its tweens affected by the function
	 * @param		p_properties		Array		Array of strings that must be affected
	 * @return							Boolean		Whether or not it successfully affected something
	 */
	private static function affectTweens (p_affectFunction:Function, p_scope:Object, p_properties:Array):Boolean {
		var affected:Boolean = false;
		var i:Number;

		if (!_tweenList) return false;

		for (i = 0; i < _tweenList.length; i++) {
			if (_tweenList[i].scope == p_scope) {
				if (p_properties.length == 0) {
					// Can affect everything
					p_affectFunction(i);
					affected = true;
				} else {
					// Must check whether this tween must have specific properties affected
					var affectedProperties:Array = new Array();
					var j:Number;
					for (j = 0; j < p_properties.length; j++) {
						if (_tweenList[i].properties[p_properties[j]] != undefined) {
							affectedProperties.push(p_properties[j]);
						}
					}
					if (affectedProperties.length > 0) {
						// This tween has some properties that need to be affected
						var objectProperties:Number = AuxFunctions.getObjectLength(_tweenList[i].properties);
						if (objectProperties == affectedProperties.length) {
							// The list of properties is the same as all properties, so affect it all
							p_affectFunction(i);
							affected = true;
						} else {
							// The properties are mixed, so split the tween and affect only certain specific properties
							var slicedTweenIndex:Number = splitTweens(i, affectedProperties);
							p_affectFunction(slicedTweenIndex);
							affected = true;
						}
					}
				}
			}
		}
		return affected;
	}

	/**
	 * Splits a tweening in two
	 *
	 * @param		p_tween				Number		Object that must have its tweens split
	 * @param		p_properties		Array		Array of strings containing the list of properties that must be separated
	 * @return							Number		The index number of the new tween
	 */
	public static function splitTweens (p_tween:Number, p_properties:Array):Number {
		// First, duplicates
		var originalTween:TweenListObj = _tweenList[p_tween];
		var newTween:TweenListObj = originalTween.clone(false);

		// Now, removes tweenings where needed
		var i:Number;
		var pName:String;

		// Removes the specified properties from the old one
		for (i = 0; i < p_properties.length; i++) {
			pName = p_properties[i];
			if (originalTween.properties[pName] != undefined) {
				originalTween.properties[pName] = undefined;
				delete originalTween.properties[pName];
			}
		}

		// Removes the unspecified properties from the new one
		var found:Boolean;
		for (pName in newTween.properties) {
			found = false;
			for (i = 0; i < p_properties.length; i++) {
				if (p_properties[i] == pName) {
					found = true;
					break;
				}
			}
			if (!found) {
				newTween.properties[pName] = undefined;
				delete newTween.properties[pName];
			}
		}

		// If there are empty property lists, a cleanup is done on the next updateTweens() cycle
		_tweenList.push(newTween);
		return (_tweenList.length - 1);
		
	}


	// ==================================================================================================================================
	// ENGINE functions -----------------------------------------------------------------------------------------------------------------

	/**
	 * Updates all existing tweenings
	 *
	 * @return							Boolean		FALSE if no update was made because there's no tweening (even delayed ones)
	 */
	private static function updateTweens ():Boolean {
		if (_tweenList.length == 0) return false;
		var i:Number;
		for (i = 0; i < _tweenList.length; i++) {
			// Looping throught each Tweening and updating the values accordingly
			if (!_tweenList[i].isPaused) {
				if (!updateTweenByIndex(i)) removeTweenByIndex(i);
				if (_tweenList[i] == null) {
					removeTweenByIndex(i, true);
					i--;
				}
			}
		}

		return true;
	}

	/**
	 * Remove an specific tweening from the tweening list
	 *
	 * @param		p_tween				Number		Index of the tween to be removed on the tweenings list
	 * @return							Boolean		Whether or not it successfully removed this tweening
	 */
	public static function removeTweenByIndex (p_tween:Number, p_finalRemoval:Boolean):Boolean {
		_tweenList[p_tween] = null;
		if (p_finalRemoval) _tweenList.splice(p_tween, 1);
		return true;
	}

	/**
	 * Pauses an specific tween
	 *
	 * @param		p_tween				Number		Index of the tween to be paused
	 * @return							Boolean		Whether or not it successfully paused this tweening
	 */
	public static function pauseTweenByIndex (p_tween:Number):Boolean {
		var tTweening:Object = _tweenList[p_tween];	// Shortcut to this tweening
		if (tTweening == null || tTweening.isPaused) return false;
		tTweening.timePaused = getCurrentTweeningTime(tTweening);
		tTweening.isPaused = true;

		return true;
	}

	/**
	 * Resumes an specific tween
	 *
	 * @param		p_tween				Number		Index of the tween to be resumed
	 * @return							Boolean		Whether or not it successfully resumed this tweening
	 */
	public static function resumeTweenByIndex (p_tween:Number):Boolean {
		var tTweening:Object = _tweenList[p_tween];	// Shortcut to this tweening
		if (tTweening == null || !tTweening.isPaused) return false;
		var cTime:Number = getCurrentTweeningTime(tTweening);
		tTweening.timeStart += cTime - tTweening.timePaused;
		tTweening.timeComplete += cTime - tTweening.timePaused;
		tTweening.timePaused = undefined;
		tTweening.isPaused = false;

		return true;
	}

	/**
	 * Updates an specific tween
	 *
	 * @param		i					Number		Index (from the tween list) of the tween that should be updated
	 * @return							Boolean		FALSE if it's already finished and should be deleted, TRUE if otherwise
	 */
	private static function updateTweenByIndex (i:Number):Boolean {

		var tTweening:Object = _tweenList[i];	// Shortcut to this tweening

		if (tTweening == null || !tTweening.scope) return false;

		var isOver:Boolean = false;		// Whether or not it's over the update time
		var mustUpdate:Boolean;			// Whether or not it should be updated (skipped if false)

		var nv:Number;					// New value for each property

		var t:Number;					// current time (frames, seconds)
		var b:Number;					// beginning value
		var c:Number;					// change in value
		var d:Number; 					// duration (frames, seconds)

		var pName:String;				// Property name, used in loops
		var eventScope:Object;			// Event scope, used to call functions

		// Shortcut stuff for speed
		var tScope:Object;				// Current scope
		var cTime:Number = getCurrentTweeningTime(tTweening);
		var tProperty:Object;			// Property being checked

		if (cTime >= tTweening.timeStart) {
			// Can already start

			tScope = tTweening.scope;

			if (tTweening.isCaller) {
				// It's a 'caller' tween
				do {
					t = ((tTweening.timeComplete - tTweening.timeStart)/tTweening.count) * (tTweening.timesCalled+1);
					b = tTweening.timeStart;
					c = tTweening.timeComplete - tTweening.timeStart;
					d = tTweening.timeComplete - tTweening.timeStart;
					nv = tTweening.transition(t, b, c, d, tTweening.transitionParams);

					if (cTime >= nv) {
						if (tTweening.onUpdate != undefined) {
							eventScope = tTweening.onUpdateScope != undefined ? tTweening.onUpdateScope : tScope;
							try {
								tTweening.onUpdate.apply(eventScope, tTweening.onUpdateParams);
							} catch(e:Error) {
								handleError(tTweening, e, "onUpdate");
							}
						}

						tTweening.timesCalled++;
						if (tTweening.timesCalled >= tTweening.count) {
							isOver = true;
							break;
						}
						if (tTweening.waitFrames) break;
					}

				} while (cTime >= nv);
			} else {
				// It's a normal transition tween

				mustUpdate = tTweening.skipUpdates < 1 || tTweening.skipUpdates == undefined || tTweening.updatesSkipped >= tTweening.skipUpdates;

				if (cTime >= tTweening.timeComplete) {
					isOver = true;
					mustUpdate = true;
				}

				if (!tTweening.hasStarted) {
					// First update, read all default values (for proper filter tweening)
					if (tTweening.onStart != undefined) {
						eventScope = tTweening.onStartScope != undefined ? tTweening.onStartScope : tScope;
						try {
							tTweening.onStart.apply(eventScope, tTweening.onStartParams);
						} catch(e:Error) {
							handleError(tTweening, e, "onStart");
						}
					}
					var pv:Number;
					for (pName in tTweening.properties) {
						if (tTweening.properties[pName].isSpecialProperty) {
							// It's a special property, tunnel via the special property function
							if (_specialPropertyList[pName].preProcess != undefined) {
								tTweening.properties[pName].valueComplete = _specialPropertyList[pName].preProcess(tScope, _specialPropertyList[pName].parameters, tTweening.properties[pName].originalValueComplete, tTweening.properties[pName].extra);
							}
							pv = _specialPropertyList[pName].getValue(tScope, _specialPropertyList[pName].parameters, tTweening.properties[pName].extra);
						} else {
							// Directly read property
							pv = tScope[pName];
						}
						tTweening.properties[pName].valueStart = isNaN(pv) ? tTweening.properties[pName].valueComplete : pv;
					}
					mustUpdate = true;
					tTweening.hasStarted = true;
				}

				if (mustUpdate) {
					for (pName in tTweening.properties) {
						tProperty = tTweening.properties[pName];

						if (isOver) {
							// Tweening time has finished, just set it to the final value
							nv = tProperty.valueComplete;
						} else {
							if (tProperty.hasModifier) {
								// Modified
								t = cTime - tTweening.timeStart;
								d = tTweening.timeComplete - tTweening.timeStart;
								nv = tTweening.transition(t, 0, 1, d, tTweening.transitionParams);
								nv = tProperty.modifierFunction(tProperty.valueStart, tProperty.valueComplete, nv, tProperty.modifierParameters);
							} else {
								// Normal update
								t = cTime - tTweening.timeStart;
								b = tProperty.valueStart;
								c = tProperty.valueComplete - tProperty.valueStart;
								d = tTweening.timeComplete - tTweening.timeStart;
								nv = tTweening.transition(t, b, c, d, tTweening.transitionParams);
							}
						}

						if (tTweening.rounded) nv = Math.round(nv);
						if (tProperty.isSpecialProperty) {
							// It's a special property, tunnel via the special property method
							_specialPropertyList[pName].setValue(tScope, nv, _specialPropertyList[pName].parameters, tTweening.properties[pName].extra);
						} else {
							// Directly set property
							tScope[pName] = nv;
						}
					}

					tTweening.updatesSkipped = 0;

					if (tTweening.onUpdate != undefined) {
						eventScope = tTweening.onUpdateScope != undefined ? tTweening.onUpdateScope : tScope;
						try {
							tTweening.onUpdate.apply(eventScope, tTweening.onUpdateParams);
						} catch(e:Error) {
							handleError(tTweening, e, "onUpdate");
						}
					}
				} else {
					tTweening.updatesSkipped++;
				}
			}

			if (isOver && tTweening.onComplete != undefined) {
				eventScope = tTweening.onCompleteScope != undefined ? tTweening.onCompleteScope : tScope;
				try {
					tTweening.onComplete.apply(eventScope, tTweening.onCompleteParams);
				} catch(e:Error) {
					handleError(tTweening, e, "onComplete");
				}
			}

			return (!isOver);
		}

		// On delay, hasn't started, so return true
		return (true);

	}

	/**
	 * Initiates the Tweener. Should only be ran once
	 */
	private static function init():Void {
		_inited = true;

		// Registers all default equations
		_transitionList = new Object();
		Equations.init();

		// Registers all default special properties
		_specialPropertyList = new Object();
		_specialPropertyModifierList = new Object();
		_specialPropertySplitterList = new Object();
	}

	/**
	 * Adds a new function to the available transition list "shortcuts"
	 *
	 * @param		p_name				String		Shorthand transition name
	 * @param		p_function			Function	The proper equation function
	 */
	public static function registerTransition(p_name:String, p_function:Function): Void {
		if (!_inited) init();
		_transitionList[p_name] = p_function;
	}

	/**
	 * Adds a new special property to the available special property list.
	 *
	 * @param		p_name				Name of the "special" property.
	 * @param		p_getFunction		Function that gets the value.
	 * @param		p_setFunction		Function that sets the value.
	 */
	public static function registerSpecialProperty(p_name:String, p_getFunction:Function, p_setFunction:Function, p_parameters:Array, p_preProcessFunction:Function): Void {
		if (!_inited) init();
		var sp:SpecialProperty = new SpecialProperty(p_getFunction, p_setFunction, p_parameters, p_preProcessFunction);
		_specialPropertyList[p_name] = sp;
	}

	/**
	 * Adds a new special property modifier to the available modifier list.
	 *
	 * @param		p_name				Name of the "special" property modifier.
	 * @param		p_modifyFunction	Function that modifies the value.
	 * @param		p_getFunction		Function that gets the value.
	 */
	public static function registerSpecialPropertyModifier(p_name:String, p_modifyFunction:Function, p_getFunction:Function): Void {
		if (!_inited) init();
		var spm:SpecialPropertyModifier = new SpecialPropertyModifier(p_modifyFunction, p_getFunction);
		_specialPropertyModifierList[p_name] = spm;
	}

	/**
	 * Adds a new special property splitter to the available splitter list.
	 *
	 * @param		p_name				Name of the "special" property splitter.
	 * @param		p_splitFunction		Function that splits the value.
	 */
	public static function registerSpecialPropertySplitter(p_name:String, p_splitFunction:Function, p_parameters:Array): Void {
		if (!_inited) init();
		var sps:SpecialPropertySplitter = new SpecialPropertySplitter(p_splitFunction, p_parameters);
		_specialPropertySplitterList[p_name] = sps;
	}

	/**
	 * Starts the Tweener class engine. It is supposed to be running every time a tween exists
	 */
	private static function startEngine():Void {
		_engineExists = true;
		_tweenList = new Array();

		var randomDepth:Number = Math.floor(Math.random() * 999999);
		var fmc:MovieClip = _root.createEmptyMovieClip(getControllerName(), 31338+randomDepth);
		fmc.onEnterFrame = function(): Void {
			Tweener.onEnterFrame();
		};

		_currentTimeFrame = 0;
		updateTime();
	}

	/**
	 * Stops the Tweener class engine
	 */
	private static function stopEngine():Void {
		_engineExists = false;
		_tweenList = null;
		_currentTime = 0;
		_currentTimeFrame = 0;
		delete _root[getControllerName()].onEnterFrame;
		_root[getControllerName()].removeMovieClip();
	}

	/**
	 * Updates the time to enforce time grid-based updates
	 */
	public static function updateTime():Void {
		_currentTime = getTimer();
	}

	/**
	 * Updates the current frame count
	 */
	public static function updateFrame():Void {
		_currentTimeFrame++;
	}

	/**
	 * Ran once every frame. It's the main engine, updates all existing tweenings.
	 */
	public static function onEnterFrame():Void {
		updateTime();
		updateFrame();
		var hasUpdated:Boolean = false;
		hasUpdated = updateTweens();
		if (!hasUpdated) stopEngine();	// There's no tweening to update or wait, so it's better to stop the engine
	}

	/**
	 * Sets the new time scale.
	 *
	 * @param		p_time				Number		New time scale (0.5 = slow, 1 = normal, 2 = 2x fast forward, etc)
	 */
	public static function setTimeScale(p_time:Number):Void {
		var i:Number;
		var cTime:Number;

		if (isNaN(p_time)) p_time = 1;
		if (p_time < 0.00001) p_time = 0.00001;
		if (p_time != _timeScale) {
			// Multiplies all existing tween times accordingly
			for (i = 0; i<_tweenList.length; i++) {
				cTime = getCurrentTweeningTime(_tweenList[i]);
				_tweenList[i].timeStart = cTime - ((cTime - _tweenList[i].timeStart) * _timeScale / p_time);
				_tweenList[i].timeComplete = cTime - ((cTime - _tweenList[i].timeComplete) * _timeScale / p_time);
				if (_tweenList[i].timePaused != undefined) _tweenList[i].timePaused = cTime - ((cTime - _tweenList[i].timePaused) * _timeScale / p_time);
			}
			// Sets the new timescale value (for new tweenings)
			_timeScale = p_time;
		}
	}

	// ==================================================================================================================================
	// AUXILIARY functions --------------------------------------------------------------------------------------------------------------

	/**
	 * Finds whether or not an object has any tweening
	 *
	 * @param		p_scope				Object		Target object
	 * @return							Boolean		Whether or not there's a tweening occuring on this object (paused, delayed, or active)
	 */
	public static function isTweening(p_scope:Object):Boolean {
        var i:Number;

        for (i = 0; i<_tweenList.length; i++) {
            if (_tweenList[i].scope == p_scope) {
                return true;
            }
        }
        return false;
    }

	/**
	 * Return an array containing a list of the properties being tweened for this object
	 *
	 * @param		p_scope				Object		Target object
	 * @return							Array		List of strings with properties being tweened (including delayed or paused)
	 */
	public static function getTweens(p_scope:Object):Array {
        var i:Number;
		var pName:String;
        var tList:Array = new Array();

        for (i = 0; i<_tweenList.length; i++) {
            if (_tweenList[i].scope == p_scope) {
				for (pName in _tweenList[i].properties) tList.push(pName);
            }
        }
		return tList;
    }

	/**
	 * Return the number of properties being tweened for this object
	 *
	 * @param		p_scope				Object		Target object
	 * @return							Number		Total count of properties being tweened (including delayed or paused)
	 */
	public static function getTweenCount(p_scope:Object):Number {
        var i:Number;
		var c:Number = 0;

        for (i = 0; i<_tweenList.length; i++) {
            if (_tweenList[i].scope == p_scope) {
				c += AuxFunctions.getObjectLength(_tweenList[i].properties);
            }
        }
		return c;
    }

    /* Handles errors when Tweener executes any callbacks (onStart, onUpdate, etc)
    *  If the TweenListObj specifies an <code>onError</code> callback it well get called, passing the <code>Error</code> object and the current scope as parameters. If no <code>onError</code> callback is specified, it will trace a stackTrace.
    */
    private static function handleError(pTweening : Object, pError : Error, pCallBackName : String) : Void{
        // do we have an error handler?
        if (pTweening.onError != undefined && typeof(pTweening.onError == "function")){
            // yup, there's a handler. Wrap this in a try catch in case the onError throws an error itself.
			var eventScope:Object = pTweening.onErrorScope != undefined ? pTweening.onErrorScope : pTweening.scope;
            try {
                pTweening.onError.apply(eventScope, [pTweening.scope, pError]);
            } catch (metaError : Error){
				printError(pTweening.scope.toString() + " raised an error while executing the 'onError' handler. Original error:\n " + pError +  "\nonError error: " + metaError);
            }
        } else {
            // if handler is undefied or null trace the error message (allows empty onErro's to ignore errors)
            if (pTweening.onError == undefined){
				printError(pTweening.scope.toString() + " raised an error while executing the '" + pCallBackName.toString() + "'handler. \n" + pError );
            }
        }
    }

	/**
	 * Get the current tweening time (no matter if it uses frames or time as basis), given a specific tweening
	 *
	 * @param		p_tweening				TweenListObj		Tween information
	 */
	public static function getCurrentTweeningTime(p_tweening:Object):Number {
		return p_tweening.useFrames ? _currentTimeFrame : _currentTime;
	}

	/**
	 * Return the current tweener version
	 *
	 * @return							String		The number of the current Tweener version
	 */
	public static function getVersion():String {
		return "AS2_FL7 1.33.74";
    }

	/**
	 * Return the name for the controller movieclip
	 *
	 * @return							String		The number of the current Tweener version
	 */
	public static function getControllerName():String {
		return "__tweener_controller__"+Tweener.getVersion();
    }



	// ==================================================================================================================================
	// DEBUG functions ------------------------------------------------------------------------------------------------------------------

	/**
	 * Output an error message
	 *
	 * @param		p_message				String		The error message to output
	 */
	public static function printError(p_message:String): Void {
		//
		trace("## [Tweener] Error: "+p_message);
	}

}
