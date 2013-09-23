package elmortem.managers {
	import flash.events.Event;
	
	public class Animation {
		static public const FORVARD:int = 0;
		static public const BACK:int = 1;
		static public const PINPONG:int = 2;
		static public const EVENT_STOP:String = "event.ani.stop";
		
		static private var DELTA:Number = -1;
		static public var FPS:Number = 30;
		
		static private var _pause:Boolean = false;
		
		static public function play(clip:Object, start:int, end:int, fps:Number, onStop:Function = null, onStopParams:Array = null):void {
			if (clip == null/* || clip.stage == null*/) return;
			if (DELTA <= 0) {
				DELTA = 1 / FPS;
			}
			
			if (isPlaying(clip)) stop(clip, false);
			
			if (fps <= 0 || start == end) {
				clip.gotoAndStop(start);
				return;
			}
			clip.ani_start = start;
			clip.ani_end = end;
			if (start < end) clip.ani_step = 1;
			else clip.ani_step = -1;
			clip.ani_curr = start;
			clip.ani_fps = fps;
			clip.ani_time = 1 / fps;
			clip.ani_timer = 0;
			clip.ani_type = 0;
			clip.ani_loop = 0;
			clip.ani_onStop = onStop;
			clip.ani_onStopParams = onStopParams;
			clip.ani_rate = 1;
			
			clip.gotoAndStop(start);
			
			clip.addEventListener(Event.ENTER_FRAME, onClipFrame);
			clip.ani_playing = true;
		}
		static public function stop(clip:Object, waitEnd:Boolean = false):void {
			if (!clip) return;
			if (!clip.ani_playing) {
				clip.stop();
				return;
			}
			clip.ani_loop = 0;
			if (!waitEnd) {
				clip.removeEventListener(Event.ENTER_FRAME, onClipFrame);
				clip.ani_playing = false;
			}
		}
		static public function isPlaying(clip:Object):Boolean {
			return Boolean(clip.ani_playing);
		}
		
		static public function setType(clip:Object, type:int):void {
			clip.ani_type = type;
		}
		static public function setLoop(clip:Object, loop:int):void {
			clip.ani_loop = loop;
		}
		static public function getLoop(clip:Object):int {
			return clip.ani_loop;
		}
		static public function setRate(clip:Object, rate:Number):void {
			rate = Math.max(0, rate);
			clip.ani_rate = rate;
		}
		static public function setStopCallback(clip:Object, onStop:Function, onStopParams:Array = null):void {
			clip.onStop = onStop;
			clip.onStopParams = onStopParams;
		}
		static public function set pause(v:Boolean):void {
			_pause = v;
		}
		static public function get pause():Boolean {
			return _pause;
		}
		
		static private function onClipFrame(e:Event):void {
			if (_pause) return;
			var end:Boolean = false;
			var clip:Object = e.currentTarget as Object;
			clip.ani_timer += DELTA * clip.ani_rate;
			if (clip.ani_timer > clip.ani_time) {
				var n:int = int(clip.ani_timer / clip.ani_time);
				clip.ani_timer -= n * clip.ani_time;
				for (var i:int = 0; i < n; i++) {
					if (clip.ani_curr == clip.ani_end) {
						end = true;
						if (clip.ani_loop == 0) {
							clip.removeEventListener(Event.ENTER_FRAME, onClipFrame);
							clip.ani_playing = false;
							clip.ani_curr = clip.ani_end;
						} else if(clip.ani_loop < 0) {
							clip.ani_curr = clip.ani_start;
						} else if(clip.ani_loop > 0) {
							clip.ani_curr = clip.ani_start;
							clip.ani_loop--;
						}
					} else {
						clip.ani_curr += clip.ani_step;
					}
				}
				clip.gotoAndStop(clip.ani_curr);
				if (end) {
					if (clip.ani_onStop != null) clip.ani_onStop.apply(null, clip.ani_onStopParams);
					clip.dispatchEvent(new Event(EVENT_STOP));
				}
			}
		}
	}
}