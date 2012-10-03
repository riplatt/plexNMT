﻿/**
 * VERSION: 12.0 beta 5.71
 * DATE: 2012-09-18
 * AS2 (AS3 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.core.Animation;
import com.greensock.core.SimpleTimeline;
import com.greensock.easing.Ease;
/**
 * 	TweenLite is an extremely fast, lightweight, and flexible tweening engine that serves as the foundation of 
 * 	the GreenSock Tweening Platform. A TweenLite instance handles tweening one or more numeric properties of any
 *  object over time, updating them on every frame. Sounds simple, but there's a wealth of capabilities and conveniences
 *  at your fingertips with TweenLite. 
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2012, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.TweenLite extends Animation {
		public static var version:Number = 12.0;
		public static var defaultEase:Ease = new Ease(null, null, 1, 1);
		public static var defaultOverwrite:String = "auto";
		public static var ticker:MovieClip = Animation.ticker;
		public static var _plugins:Object = {}; 
		public static var _onPluginEvent:Function;
		private static var _tweenLookup:Object = {}; 
		private static var _cnt:Number = 0;
		private static var _reservedProps:Object = {ease:1, delay:1, overwrite:1, onComplete:1, onCompleteParams:1, onCompleteScope:1, useFrames:1, runBackwards:1, startAt:1, onUpdate:1, onUpdateParams:1, onUpdateScope:1, onStart:1, onStartParams:1, onStartScope:1, onReverseComplete:1, onReverseCompleteParams:1, onReverseCompleteScope:1, onRepeat:1, onRepeatParams:1, onRepeatScope:1, easeParams:1, yoyo:1, orientToBezier:1, immediateRender:1, repeat:1, repeatDelay:1, data:1, paused:1, reversed:1};
		private static var _overwriteLookup:Object;
		public var target:Object; 
		public var ratio:Number;
		public var _propLookup:Object;
		public var _firstPT:Object;
		public var _ease:Ease;
		private var _targets:Array;
		private var _easeType:Number;
		private var _easePower:Number;
		private var _siblings:Array;
		private var _overwrite:Number;
		private var _overwrittenProps:Object; 
		private var _notifyPluginsOfEnabled:Boolean;
		
		public function TweenLite(target:Object, duration:Number, vars:Object) {
			super(duration, vars);
			
			if (!_overwriteLookup) {
				_overwriteLookup = {none:0, all:1, auto:2, concurrent:3, allOnStart:4, preexisting:5};
				_overwriteLookup["true"] = 1;
				_overwriteLookup["false"] = 0;
				_addTickListener("tick", _dumpGarbage, TweenLite);
			}
			
			ratio = 0;
			this.target = target;
			_ease = defaultEase; //temporary - we'll replace it in _init(). We need to set it here for speed purposes so that on the first render(), it doesn't throw an error. 
			
			_overwrite = (this.vars.overwrite == null) ? _overwriteLookup[defaultOverwrite] : (typeof(this.vars.overwrite) === "number") ? this.vars.overwrite >> 0 : _overwriteLookup[this.vars.overwrite];
			
			if (this.target instanceof Array && (typeof(this.target[0]) === "object" || typeof(this.target[0]) === "movieclip")) {
				_targets = this.target.concat();
				_propLookup = [];
				_siblings = [];
				var i:Number = _targets.length;
				while (--i > -1) {
					_siblings[i] = _register(_targets[i], this, false);
					if (_overwrite === 1) if (_siblings[i].length > 1) {
						_applyOverwrite(_targets[i], this, null, 1, _siblings[i]);
					}
				}
				
			} else {
				_propLookup = {};
				_siblings = _register(target, this, false);
				if (_overwrite === 1) if (_siblings.length > 1) {
					_applyOverwrite(target, this, null, 1, _siblings);
				}
			}
			
			if (this.vars.immediateRender || (duration === 0 && _delay === 0 && this.vars.immediateRender != false)) {
				render(-_delay, false, true);
			}
		}
		
		/*
		public function toString():String {
			return "[TweenLite target:" + target + ", duration:" + _duration + ", data:" + data + "]";
		}
		*/
		
		private function _init():Void {
			if (vars.startAt) {
				vars.startAt.overwrite = 0;
				vars.startAt.immediateRender = true;
				TweenLite.to(target, 0, vars.startAt);
			}
			var i:Number, initPlugins:Boolean, pt:Object;
			if (vars.ease instanceof Ease) {
				_ease = (vars.easeParams instanceof Array) ? vars.ease.config.apply(vars.ease, vars.easeParams) : vars.ease;
			} else if (typeof(vars.ease) === "function") {
				_ease = new Ease(vars.ease, vars.easeParams);
			} else {
				_ease = defaultEase;
			}
			_easeType = _ease._type;
			_easePower = _ease._power;
			_firstPT = null;
			
			if (_targets) {
				i = _targets.length;
				while (--i > -1) {
					if ( _initProps( _targets[i], (_propLookup[i] = {}), _siblings[i], (_overwrittenProps ? _overwrittenProps[i] : null)) ) {
						initPlugins = true;
					}
				}
			} else {
				initPlugins = _initProps(target, _propLookup, _siblings, _overwrittenProps);
			}
			
			if (initPlugins) {
				_onPluginEvent("_onInitAllProps", this); //reorders the array in order of priority. Uses a static TweenPlugin method in order to minimize file size in TweenLite
			}
			if (_overwrittenProps) if (_firstPT == null) if (typeof(target) !== "function") { //if all tweening properties have been overwritten, kill the tween. If the target is a function, it's most likely a delayedCall so let it live.
				_enabled(false, false);
			}
			if (vars.runBackwards) {
				pt = _firstPT;
				while (pt) {
					pt.s += pt.c;
					pt.c = -pt.c;
					pt = pt._next;
				}
			}
			_onUpdate = vars.onUpdate;
			_initted = true;
		}
		
		private function _initProps(target:Object, propLookup:Object, siblings:Array, overwrittenProps:Object):Boolean {
			var p:String, i:Number, initPlugins:Boolean, plugin:Object, a:Array;
			if (target == null) {
				return false;
			}
			for (p in vars) {
				if (_reservedProps[p]) { 
					if (p === "onStartParams" || p === "onUpdateParams" || p === "onCompleteParams" || p === "onReverseCompleteParams" || p === "onRepeatParams") if ((a = vars[p])) {
						i = a.length;
						while (--i > -1) {
							if (a[i] === "{self}") {
								a = vars[p] = a.concat(); //copy the array in case the user referenced the same array in multiple tweens/timelines (each {self} should be unique)
								a[i] = this;
							}
						}
					}
					
				} else if (_plugins[p] && (plugin = new _plugins[p]())._onInitTween(target, vars[p], this)) {
					
					//t - target 		[object]
					//p - property 		[string]
					//s - start			[number]
					//c - change		[number]
					//f - isFunction	[boolean]
					//n - name			[string]
					//pg - isPlugin 	[boolean]
					//pr - priority		[number]
					_firstPT = {_next:_firstPT, t:plugin, p:"setRatio", s:0, c:1, f:true, n:p, pg:true, pr:plugin._priority};
					i = plugin._overwriteProps.length;
					while (--i > -1) {
						propLookup[plugin._overwriteProps[i]] = _firstPT;
					}
					if (plugin._priority || plugin._onInitAllProps) {
						initPlugins = true;
					}
					if (plugin._onDisable || plugin._onEnable) {
						_notifyPluginsOfEnabled = true;
					}
					
				} else {
					_firstPT = propLookup[p] = {_next:_firstPT, t:target, p:p, f:(typeof(target[p]) === "function"), n:p, pg:false, pr:0};
					_firstPT.s = (!_firstPT.f) ? Number(target[p]) : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
					_firstPT.c = (typeof(vars[p]) === "number") ? Number(vars[p]) - _firstPT.s : (typeof(vars[p]) === "string" && vars[p].charAt(1) === "=") ? Number(vars[p].charAt(0)+"1") * Number(vars[p].substr(2)) : Number(vars[p]) || 0;
				}
				if (_firstPT) if (_firstPT._next) {
					_firstPT._next._prev = _firstPT;
				}
			}
			
			if (overwrittenProps) if (_kill(overwrittenProps, target)) { //another tween may have tried to overwrite properties of this tween before init() was called (like if two tweens start at the same time, the one created second will run first)
				return _initProps(target, propLookup, siblings, overwrittenProps);
			}
			if (_overwrite > 1) if (_firstPT) if (siblings.length > 1) if (_applyOverwrite(target, this, propLookup, _overwrite, siblings)) {
				_kill(propLookup, target);
				return _initProps(target, propLookup, siblings, overwrittenProps);
			}
			return initPlugins;
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			var isComplete:Boolean, callback:String, pt:Object, prevTime:Number = _time;
			if (time >= _duration) {
				_totalTime = _time = _duration;
				ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
				if (!_reversed) {
					isComplete = true;
					callback = "onComplete";
				}
				if (_duration === 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
					if (time === 0 || _rawPrevTime < 0) if (_rawPrevTime !== time) {
						force = true;
					}
					_rawPrevTime = time;
				}
				
			} else if (time <= 0) {
				_totalTime = _time = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				if (prevTime !== 0 || (_duration === 0 && _rawPrevTime > 0)) {
					callback = "onReverseComplete";
					isComplete = _reversed;
				}
				if (time < 0) {
					_active = false;
					if (_duration === 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
						if (_rawPrevTime >= 0) {
							force = true;
						}
						_rawPrevTime = time;
					}
				} else if (!_initted) { //if we render the very beginning (time == 0) of a fromTo(), we must force the render (normal tweens wouldn't need to render at a time of 0 when the prevTime was also 0). This is also mandatory to make sure overwriting kicks in immediately.
					force = true;
				}
				
			} else {
				_totalTime = _time = time;
				
				if (_easeType) {
					var r:Number = time / _duration, type:Number = _easeType, pow:Number = _easePower;
					if (type === 1 || (type === 3 && r >= 0.5)) {
						r = 1 - r;
					}
					if (type === 3) {
						r *= 2;
					}
					if (pow === 1) {
						r *= r;
					} else if (pow === 2) {
						r *= r * r;
					} else if (pow === 3) {
						r *= r * r * r;
					} else if (pow === 4) {
						r *= r * r * r * r;
					}
					
					if (type === 1) {
						ratio = 1 - r;
					} else if (type === 2) {
						ratio = r;
					} else if (time / _duration < 0.5) {
						ratio = r / 2;
					} else {
						ratio = 1 - (r / 2);
					}
					
				} else {
					ratio = _ease.getRatio(time / _duration);
				}
				
			}
			
			if (_time === prevTime && !force) {
				return;
			} else if (!_initted) {
				_init();
				if (!isComplete && _time) { //_ease is initially set to defaultEase, so now that init() has run, _ease is set properly and we need to recalculate the ratio. Overall this is faster than using conditional logic earlier in the method to avoid having to set ratio twice because we only init() once but renderTime() gets called VERY frequently.
					ratio = _ease.getRatio(_time / _duration);
				}
			}
			
			if (!_active) if (!_paused) {
				_active = true;  //so that if the user renders a tween (as opposed to the timeline rendering it), the timeline is forced to re-render and align it with the proper time/frame on the next rendering cycle. Maybe the tween already finished but the user manually re-renders it as halfway done.
			}
			if (prevTime === 0) if (vars.onStart) if (_time !== 0 || _duration === 0) if (!suppressEvents) {
				vars.onStart.apply(vars.onStartScope || this, vars.onStartParams);
			}
			
			pt = _firstPT;
			while (pt) {
				if (pt.f) {
					pt.t[pt.p](pt.c * ratio + pt.s);
				} else {
					pt.t[pt.p] = pt.c * ratio + pt.s;
				}
				pt = pt._next;
			}
			
			if (_onUpdate) if (!suppressEvents) {
				_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
			}
			
			if (callback) if (!_gc) { //check _gc because there's a chance that kill() could be called in an onUpdate
				if (isComplete) {
					if (_timeline.autoRemoveChildren) {
						_enabled(false, false);
					}
					_active = false;
				}
				if (!suppressEvents) if (vars[callback]) {
					vars[callback].apply(vars[callback + "Scope"] || this, vars[callback + "Params"]);
				}
			}
			
		}
		
		public function _kill(vars:Object, target:Object):Boolean {
			if (vars === "all") {
				vars = null;
			}
			if (vars == null) if (target == null || target == this.target) {
				return _enabled(false, false);
			}
			target = target || _targets || this.target;
			var i:Number, overwrittenProps:Object, p:String, pt:Object, propLookup:Object, changed:Boolean, killProps:Object, record:Boolean;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				i = target.length;
				while (--i > -1) {
					if (_kill(vars, target[i])) {
						changed = true;
					}
				}
			} else {
				if (_targets) {
					i = _targets.length;
					while (--i > -1) {
						if (target === _targets[i]) {
							propLookup = _propLookup[i] || {};
							_overwrittenProps = _overwrittenProps || [];
							overwrittenProps = _overwrittenProps[i] = vars ? _overwrittenProps[i] || {} : "all";
							break;
						}
					}
				} else if (target !== this.target) {
					return false;
				} else {
					propLookup = _propLookup;
					overwrittenProps = _overwrittenProps = vars ? _overwrittenProps || {} : "all";
				}
				
				if (propLookup) {
					killProps = vars || propLookup;
					record = (vars != overwrittenProps && overwrittenProps != "all" && vars != propLookup && (vars == null || vars._tempKill != true)); //_tempKill is a super-secret way to delete a particular tweening property but NOT have it remembered as an official overwritten property (like in BezierPlugin)
					for (p in killProps) {
						if ((pt = propLookup[p])) {
							if (pt.pg && pt.t._kill(killProps)) {
								changed = true; //some plugins need to be notified so they can perform cleanup tasks first
							}
							if (!pt.pg || pt.t._overwriteProps.length === 0) {
								if (pt._prev) {
									pt._prev._next = pt._next;
								} else if (pt == _firstPT) {
									_firstPT = pt._next;
								}
								if (pt._next) {
									pt._next._prev = pt._prev;
								}
								pt._next = pt._prev = null;
							}
							delete propLookup[p];
						}
						if (record) { 
							overwrittenProps[p] = 1;
						}
					}
				}
			}
			return changed;
		}
		
		public function invalidate() {
			if (_notifyPluginsOfEnabled) {
				_onPluginEvent("_onDisable", this);
			}
			_firstPT = null;
			_overwrittenProps = null;
			_onUpdate = null;
			_initted = _active = _notifyPluginsOfEnabled = false;
			_propLookup = (_targets) ? {} : [];
			return this;
		}
		
		public function _enabled(enabled:Boolean, ignoreTimeline:Boolean):Boolean {
			if (enabled && _gc) {
				if (_targets) {
					var i:Number = _targets.length;
					while (--i > -1) {
						_siblings[i] = _register(_targets[i], this, true);
					}
				} else {
					_siblings = _register(target, this, true);
				}
			}
			super._enabled(enabled, ignoreTimeline);
			if (_notifyPluginsOfEnabled) if (_firstPT) {
				return _onPluginEvent(((enabled) ? "_onEnable" : "_onDisable"), this);
			}
			return false;
		}
		
		
//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------
		
		public static function to(target:Object, duration:Number, vars:Object):TweenLite {
			return new TweenLite(target, duration, vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object):TweenLite {
			vars.runBackwards = true;
			if (vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return new TweenLite(target, duration, vars);
		}
		
		public static function fromTo(target:Object, duration:Number, fromVars:Object, toVars:Object):TweenLite {
			toVars.startAt = fromVars;
			if (fromVars.immediateRender) {
				toVars.immediateRender = true;
			}
			return new TweenLite(target, duration, toVars);
		}
		
		public static function delayedCall(delay:Number, callback:Function, params:Array, scope:Object, useFrames:Boolean):TweenLite {
			return new TweenLite(callback, 0, {delay:delay, onComplete:callback, onCompleteParams:params, onCompleteScope:scope, onReverseComplete:callback, onReverseCompleteParams:params, onReverseCompleteScope:scope, immediateRender:false, useFrames:useFrames, overwrite:0});
		}
		
		private static function _dumpGarbage():Void {
			if (!(_rootFrame % 60)) {
				var i:Number, a:Array, p:String;
				for (p in _tweenLookup) {
					a = _tweenLookup[p].tweens;
					i = a.length;
					while (--i > -1) {
						if (a[i]._gc) {
							a.splice(i, 1);
						}
					}
					if (a.length === 0) {
						delete _tweenLookup[p];
					}
				}
			}
		}
		
		public static function set(target:Object, vars:Object):TweenLite {
			return new TweenLite(target, 0, vars);
		}

		public static function killTweensOf(target:Object, vars:Object):Void {
			var a:Array = getTweensOf(target), i:Number = a.length;
			while (--i > -1) {
				a[i]._kill(vars, target);
			}
		}
		
		public static function killDelayedCallsTo(func:Function):Void {
			killTweensOf(func);
		}
		
		public static function getTweensOf(target:Object):Array {
			var i:Number, a:Array, j:Number, t:TweenLite;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				i = target.length;
				a = [];
				while (--i > -1) {
					a = a.concat(getTweensOf(target[i]));
				}
				i = a.length;
				//now get rid of any duplicates (tweens of arrays of objects could cause duplicates)
				while (--i > -1) {
					t = a[i];
					j = i;
					while (--j > -1) {
						if (t === a[j]) {
							a.splice(i, 1);
						}
					}
				}
			} else {
				a = _register(target).concat();
				i = a.length;
				while (--i > -1) {
					if (a[i]._gc) {
						a.splice(i, 1);
					}
				}
			}
			return a;
		}
		
		private static function _register(target:Object, tween:TweenLite, scrub:Boolean):Array {
			var id:String, i:Number, a:Array, p:String, tl:Object = _tweenLookup;
			if (typeof(target) === "movieclip") {
				id = String(target);
			} else {
				for (p in tl) {
					if (tl[p].target === target) {
						id = p;
						break;
					}
				}
			}
			if (!tl[id || (id = "t" + (_cnt++))]) {
				tl[id] = {target:target, tweens:[]};
			}
			if (tween) {
				a = tl[id].tweens;
				a[(i = a.length)] = tween;
				if (scrub) {
					while (--i > -1) {
						if (a[i] === tween) {
							a.splice(i, 1);
						}
					}
				}
			}
			return tl[id].tweens;
		}
		
		private static function _applyOverwrite(target:Object, tween:TweenLite, props:Object, mode:Number, siblings:Array):Boolean {
			var i:Number, changed:Boolean, curTween:TweenLite;
			if (mode === 1 || mode >= 4) {
				var l:Number = siblings.length;
				for (i = 0; i < l; i++) {
					if ((curTween = siblings[i]) !== tween) {
						if (!curTween._gc) if (curTween._enabled(false, false)) {
							changed = true;
						}
					} else if (mode === 5) {
						break;
					}
				}
				return changed;
			}
			//NOTE: Add 0.0000000001 to overcome floating point errors that can cause the startTime to be VERY slightly off (when a tween's time() is set for example)
			var startTime:Number = tween._startTime + 0.0000000001, overlaps:Array = [], oCount:Number = 0, globalStart:Number;
			i = siblings.length;
			while (--i > -1) {
				if ((curTween = siblings[i]) === tween || curTween._gc || curTween._paused) {
					//ignore
				} else if (curTween._timeline != tween._timeline) {
					globalStart = globalStart || _checkOverlap(tween, 0);
					if (_checkOverlap(curTween, globalStart) === 0) {
						overlaps[oCount++] = curTween;
					}
				} else if (curTween._startTime <= startTime) if (curTween._startTime + curTween.totalDuration() / curTween._timeScale + 0.0000000001 > startTime) if (!((tween._duration == 0 || !curTween._initted) && startTime - curTween._startTime <= 0.0000000002)) {
					overlaps[oCount++] = curTween;
				}
			}
			
			i = oCount;
			while (--i > -1) {
				curTween = overlaps[i];
				if (mode === 2) if (curTween._kill(props, target)) {
					changed = true;
				}
				if (mode !== 2 || (!curTween._firstPT && curTween._initted)) { 
					if (curTween._enabled(false, false)) { //if all property tweens have been overwritten, kill the tween.
						changed = true;
					}
				}
			}
			return changed;
		}
		
		private static function _checkOverlap(tween:Animation, reference:Number):Number {
			var tl:SimpleTimeline = tween._timeline, ts:Number = tl._timeScale, t:Number = tween._startTime;
			while (tl._timeline) {
				t += tl._startTime;
				ts *= tl._timeScale;
				if (tl._paused) {
					return -100;
				}
				tl = tl._timeline;
			}
			t /= ts;
			return (t > reference) ? t - reference : (!tween._initted && t - reference < 0.0000000002) ? 0.0000000001 : ((t = t + tween.totalDuration() / tween._timeScale / ts) > reference) ? 0 : t - reference - 0.0000000001;
		}
		
	
}