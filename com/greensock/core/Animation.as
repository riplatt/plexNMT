/**
 * VERSION: 12.0 beta 4.1
 * DATE: 2012-02-29
 * AS2 (AS3 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.core.SimpleTimeline;
/**
 * Animation is the base class for all TweenLite, TweenMax, TimelineLite, and TimelineMax classes and 
 * provides core functionality and properties. There is no reason to use this class directly.<br /><br />
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2012, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.core.Animation {
		public static var version:Number = 12.0;
		public static var ticker:MovieClip = _jumpStart(_root);
		private static var _rootFrame:Number = -1;
		public static var _rootTimeline:SimpleTimeline;
		public static var _rootFramesTimeline:SimpleTimeline;
		private static var _onTick:Array = [];
		private var _onUpdate:Function; 
		public var _delay:Number; 
		public var _rawPrevTime:Number;
		public var _active:Boolean; 
		public var _gc:Boolean; 
		public var _initted:Boolean; 
		public var _startTime:Number; 
		public var _time:Number; 
		public var _totalTime:Number; 
		public var _duration:Number; 
		public var _totalDuration:Number; 
		public var _pauseTime:Number;
		public var _timeScale:Number;
		public var _reversed:Boolean;
		public var _timeline:SimpleTimeline;
		public var _dirty:Boolean; 
		public var _paused:Boolean; 
		public var _next:Animation;
		public var _prev:Animation;
		public var vars:Object;
		public var timeline:SimpleTimeline;
		public var data:Object; 
		
		public function Animation(duration:Number, vars:Object) {
			this.vars = vars || {};
			_duration = _totalDuration = duration || 0;
			_delay = Number(this.vars.delay) || 0;
			_timeScale = 1;
			_totalTime = _time = 0;
			data = this.vars.data;
			_rawPrevTime = -1;
			_paused = false;
			
			if (_rootTimeline == null) {
				if (_rootFrame === -1) {
					_rootFrame = 0;
					_rootFramesTimeline = new SimpleTimeline();
					_rootTimeline = new SimpleTimeline();
					_rootTimeline._startTime = getTimer() / 1000;
					_rootFramesTimeline._startTime = 0;
					_rootTimeline._active = _rootFramesTimeline._active = true;
					_addTickListener("tick", _updateRoot, Animation);
				} else {
					return;
				}
			}
			if (ticker.onEnterFrame !== _tick) { //subloaded swfs in Flash Lite restrict access to _root.createEmptyMovieClip(), so we find the subloaded swf MovieClip to createEmptyMovieClip(), but if it gets unloaded, the onEnterFrame will stop running so we need to check each time a tween is created.
				_jumpStart(_root);
			}
			
			var tl:SimpleTimeline = (this.vars.useFrames) ? _rootFramesTimeline : _rootTimeline;
			tl.insert(this, tl._time);
			
			_reversed = (this.vars.reversed == true);
			if (this.vars.paused) {
				paused(true);
			}
		}
		
		public function play(from, suppressEvents:Boolean) {
			if (arguments.length) {
				seek(from, suppressEvents);
			}
			reversed(false);
			return paused(false);
		}
		
		public function pause(atTime, suppressEvents:Boolean) {
			if (arguments.length) {
				seek(atTime, suppressEvents);
			}
			return paused(true);
		}
		
		public function resume(from, suppressEvents:Boolean) {
			if (arguments.length) {
				seek(from, suppressEvents);
			}
			return paused(false);
		}
		
		public function seek(time, suppressEvents:Boolean) {
			return totalTime(Number(time), (suppressEvents != false));
		}
		
		public function restart(includeDelay:Boolean, suppressEvents:Boolean) {
			reversed(false);
			paused(false);
			return totalTime((includeDelay) ? -_delay : 0, (suppressEvents != false));
		}
		
		public function reverse(from, suppressEvents:Boolean) {
			if (arguments.length) {
				seek((from || totalDuration()), suppressEvents);
			}
			reversed(true);
			return paused(false);
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			
		}
		
		public function invalidate() {
			return this;
		}
		
		public function _enabled(enabled:Boolean, ignoreTimeline:Boolean):Boolean {
			_gc = !enabled; //note: it is possible for _gc to be true and timeline not to be null in situations where a parent TimelineLite/Max has completed and is removed - the developer might hold a reference to that timeline and later restart() it or something. 
			_active = (enabled && !_paused && _totalTime > 0 && _totalTime < _totalDuration);
			if (ignoreTimeline != true) {
				if (enabled && timeline == null) {
					_timeline.insert(this, _startTime - _delay);
				} else if (!enabled && timeline != null) {
					_timeline._remove(this, true);
				}
			}
			return false;
		}
		
		public function _kill(vars:Object, target:Object):Boolean {
			return _enabled(false, false);
		}
		
		public function kill(vars:Object, target:Object) {
			_kill(vars, target);
			return this;
		}
		
		private function _uncache(includeSelf:Boolean) {
			var tween:Animation = includeSelf ? this : timeline;
			while (tween) {
				tween._dirty = true;
				tween = tween.timeline;
			}
			return this;
		}
		
		
		public static function _updateRoot():Void {
			_rootFrame++;
			_rootTimeline.render((getTimer() / 1000 - _rootTimeline._startTime) * _rootTimeline._timeScale, false, false);
			_rootFramesTimeline.render((_rootFrame - _rootFramesTimeline._startTime) * _rootFramesTimeline._timeScale, false, false);
		}
		
		private static function _addTickListener(type:String, callback:Function, scope:Object, useParam:Boolean, priority:Number):Void {
			if (type === "tick") {
				priority = priority || 0;
				var i:Number = _onTick.length, index:Number = 0, l:Object;
				while (--i > -1) {
					if ((l = _onTick[i]).c === callback) {
						_onTick.splice(i, 1);
					} else if (index === 0 && l.p < priority) {
						index = i + 1;
					}
				}
				_onTick.splice(index, 0, {c:callback, s:scope, up:useParam, p:priority});
			}
		}
		
		private static function _removeTickListener(type:String, callback:Function):Void {
			var i:Number = _onTick.length;
			while (--i > -1) {
				if (_onTick[i].c === callback && type === "tick") {
					_onTick.splice(i, 1);
					return;
				}
			}
		}
		
		private static function _tick():Void {
			var i:Number = _onTick.length, l:Object;
			while (--i > -1) {
				if ((l = _onTick[i]).up) {
					l.c.call(l.s, {type:"tick", target:ticker});
				} else {
					l.c.call(l.s);
				}
			}
		}
		
		private static function _findSubloadedSWF(mc:MovieClip):MovieClip {
			for (var p:String in mc) {
				if (typeof(mc[p]) == "movieclip") {
					if (mc[p]._url != _root._url && mc[p].getBytesLoaded() != undefined) {
						return mc[p];
					} else if (_findSubloadedSWF(mc[p])) {
						return _findSubloadedSWF(mc[p]);
					}
				}
			}
			return undefined;
		}
		
		public static function _jumpStart(root:MovieClip):MovieClip {
			if (ticker != undefined) {
				ticker.removeMovieClip();
			}
			var mc:MovieClip = (root.getBytesLoaded() == undefined) ? _findSubloadedSWF(root) : root; //subloaded swfs won't return getBytesLoaded() in Flash Lite, and it locks us out from being able to createEmptyMovieClip(), so we must find the subloaded clip to do it there instead.
			var l:Number = 999; //Don't just do getNextHighestDepth() because often developers will hard-code stuff that uses low levels which would overwrite the TweenLite clip. Start at level 999 and make sure nothing's there. If there is, move up until we find an empty level.
			while (mc.getInstanceAtDepth(l)) {
				l++;
			}
			ticker = mc.createEmptyMovieClip("_gsAnimation" + String(version).split(".").join("_"), l);
			ticker.onEnterFrame = _tick;
			ticker.addEventListener = _addTickListener;
			ticker.removeEventListener = _removeTickListener;
			_rootTimeline._time = _rootTimeline._totalTime = ((getTimer() / 1000) - _rootTimeline._startTime) * _rootTimeline._timeScale; //so that the start time of subsequent tweens that get created are correct. Otherwise, in cases where an AS2/AS1 swf is unloaded from an AS3 swf and time elapses and then another AS2/AS1 swf is loaded, the tweens will have their cachedStartTime set to the timeline's cachedTotalTime which won't have been updated because the onEnterFrame may have been stopped because of the bug in Flash.
			return ticker;
		}
		
		
		
//---- GETTERS / SETTERS ------------------------------------------------------------
		
		public function eventCallback(type:String, callback:Function, params:Array, scope) {
			if (type == null) {
				return null;
			} else if (type.substr(0,2) === "on") {
				if (arguments.length === 1) {
					return vars[type];
				}
				if (callback == null) {
					delete vars[type];
				} else {
					vars[type] = callback;
					vars[type + "Params"] = params;
					vars[type + "Scope"] = scope;
					if (params) {
						var i:Number = params.length;
						while (--i > -1) {
							if (params[i] === "{self}") {
								params = vars[type + "Params"] = params.concat(); //copying the array avoids situations where the same array is passed to multiple tweens/timelines and {self} doesn't correctly point to each individual instance.
								params[i] = this;
							}
						}
					}
				}
				if (type === "onUpdate") {
					_onUpdate = callback;
				}
			}
			return this;
		}
		
		public function delay(value:Number) {
			if (!arguments.length) {
				return _delay;
			}
			if (_timeline.smoothChildTiming) {
				startTime( _startTime + value - _delay );
			}
			_delay = value;
			return this;
		}
		
		public function duration(value:Number) {
			if (!arguments.length) {
				_dirty = false;
				return _duration;
			}
			_duration = _totalDuration = value;
			_uncache(true); //true in case it's a TweenMax or TimelineMax that has a repeat - we'll need to refresh the totalDuration. 
			if (_timeline.smoothChildTiming) if (_active) if (value != 0) {
				totalTime(_totalTime * (value / _duration), true);
			}
			return this;
		}
		
		public function totalDuration(value:Number) {
			_dirty = false;
			return (!arguments.length) ? _totalDuration : duration(value);
		}
		
		public function time(value:Number, suppressEvents:Boolean) {
			if (!arguments.length) {
				return _time;
			}
			if (_dirty) {
				totalDuration();
			}
			if (value > _duration) {
				value = _duration;
			}
			return totalTime(value, suppressEvents);
		}
		
		public function totalTime(time:Number, suppressEvents:Boolean) {
			if (!arguments.length) {
				return _totalTime;
			}
			if (_timeline) {
				if (time < 0) {
					time += totalDuration();
				}
				if (_timeline.smoothChildTiming) {
					if (_dirty) {
						totalDuration();
					}
					if (time > _totalDuration) {
						time = _totalDuration;
					}
					_startTime = (_paused ? _pauseTime : _timeline._time) - ((!_reversed ? time : _totalDuration - time) / _timeScale);
					if (!_timeline._dirty) { //for performance improvement. If the parent's cache is already dirty, it already took care of marking the anscestors as dirty too, so skip the function call here.
						_uncache(false);
					}
					if (!_timeline._active) {
						//in case any of the anscestors had completed but should now be enabled...
						var tl:SimpleTimeline = _timeline;
						while (tl._timeline) {
							tl.totalTime(tl._totalTime, true);
							tl = tl._timeline;
						}
					}
				}
				if (_gc) {
					_enabled(true, false);
				}
				if (_totalTime != time) {
					render(time, suppressEvents, false);
				}
			}
			return this;
		}
		
		public function startTime(value:Number) {
			if (!arguments.length) {
				return _startTime;
			}
			if (value != _startTime) {
				_startTime = value;
				if (timeline) if (timeline._sortChildren) {
					timeline.insert(this, value - _delay); //ensures that any necessary re-sequencing of Animations in the timeline occurs to make sure the rendering order is correct.
				}
			}
			return this;
		}
		
		public function timeScale(value:Number) {
			if (!arguments.length) {
				return _timeScale;
			}
			value = value || 0.000001; //can't allow zero because it'll throw the math off
			if (_timeline && _timeline.smoothChildTiming) {
				var t:Number = (_pauseTime || _pauseTime == 0) ? _pauseTime : _timeline._totalTime;
				_startTime = t - ((t - _startTime) * _timeScale / value);
			}
			_timeScale = value;
			return _uncache(false);
		}
		
		public function reversed(value:Boolean) {
			if (!arguments.length) {
				return _reversed;
			}
			if (value != _reversed) {
				_reversed = value;
				totalTime(_totalTime, true);
			}
			return this;
		}
		
		public function paused(value:Boolean) {
			if (!arguments.length) {
				return _paused;
			}
			if (value != _paused) if (_timeline) {
				if (!value && _timeline.smoothChildTiming) {
					_startTime += _timeline.rawTime() - _pauseTime;
					_uncache(false);
				}
				_pauseTime = (value) ? _timeline.rawTime() : NaN;
				_paused = value;
				_active = Boolean(!_paused && _totalTime > 0 && _totalTime < _totalDuration);
			}
			if (_gc) if (!value) {
				_enabled(true, false);
			}
			return this;
		}
	
}