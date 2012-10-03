/**
 * VERSION: 12.0 beta 1
 * DATE: 2012-02-20
 * AS3 (AS2 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.core.Animation;
/**
 * SimpleTimeline is the base class for TimelineLite and TimelineMax, providing the
 * most basic timeline functionality and it is used for the root timelines in TweenLite but is only
 * intended for internal use in the GreenSock tweening platform. It is meant to be very fast and lightweight.
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2012, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.core.SimpleTimeline extends Animation {
		public var autoRemoveChildren:Boolean; 
		public var smoothChildTiming:Boolean;
		public var _sortChildren:Boolean;
		public var _first:Animation;
		public var _last:Animation;
		
		public function SimpleTimeline(vars:Object) {
			super(0, vars);
			this.autoRemoveChildren = this.smoothChildTiming = true;
		}
		
		public function insert(tween, time) {
			tween._startTime = Number(time || 0) + tween._delay;
			if (tween._paused) if (this != tween._timeline) { //we only adjust the _pauseTime if it wasn't in this timeline already. Remember, sometimes a tween will be inserted again into the same timeline when its startTime is changed so that the tweens in the TimelineLite/Max are re-ordered properly in the linked list (so everything renders in the proper order). 
				tween._pauseTime = tween._startTime + ((rawTime() - tween._startTime) / tween._timeScale);
			}
			if (tween.timeline) {
				tween.timeline._remove(tween, true); //removes from existing timeline so that it can be properly added to this one.
			}
			tween.timeline = tween._timeline = this;
			if (tween._gc) {
				tween._enabled(true, true);
			}
			
			var prevTween:Animation = _last;
			if (_sortChildren) {
				var st:Number = tween._startTime;
				while (prevTween && prevTween._startTime > st) {
					prevTween = prevTween._prev;
				}
			}
			if (prevTween) {
				tween._next = prevTween._next;
				prevTween._next = Animation(tween);
			} else {
				tween._next = _first;
				_first = Animation(tween);
			}
			if (tween._next) {
				tween._next._prev = tween;
			} else {
				_last = Animation(tween);
			}
			tween._prev = prevTween;
			
			if (_timeline) {
				_uncache(true);
			}
			
			return this;
		}
		
		public function _remove(tween, skipDisable:Boolean) {
			if (tween.timeline == this) {
				if (!skipDisable) {
					tween._enabled(false, true);
				}
				tween.timeline = null;
				
				if (tween._prev) {
					tween._prev._next = tween._next;
				} else if (_first === tween) {
					_first = tween._next;
				}
				if (tween._next) {
					tween._next._prev = tween._prev;
				} else if (_last === tween) {
					_last = tween._prev;
				}
				
				if (_timeline) {
					_uncache(true);
				}
			}
			return this;
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			var tween:Animation = _first, next:Animation;
			_totalTime = _time = _rawPrevTime = time;
			while (tween) {
				next = tween._next; //record it here because the value could change after rendering...
				if (tween._active || (time >= tween._startTime && !tween._paused)) {
					if (!tween._reversed) {
						tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, false);
					} else {
						tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale), suppressEvents, false);
					}
				}
				tween = next;
			}
		}
		
		
//---- GETTERS / SETTERS ------------------------------------------------------------------------------
		
		public function rawTime():Number {
			return _totalTime;			
		}
}