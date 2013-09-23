package elmortem.managers {
	import flash.display.MovieClip;

	public class AnimationManager {
		static public const FORVARD:int = 0;
		static public const BACK:int = 1;
		static public const PINPONG:int = 2;

		static private var ani:/*Object*/Array = [];
		static private var dead_ani:Array = [];
		
		static public function set(movie:MovieClip, fps:Number, begin:int, end:int, type:int = FORVARD, is_loop:Boolean = true):int {
			movie.stop();
			var _fps:Number = 0;
			if(fps != 0) _fps = 1 / fps;
			var _curr:int = begin;
			var _step:int = -1;
			if(type != BACK) {
				_step = 1;
				if(type == PINPONG) is_loop = true;
			} else {
				_curr = end;
			}
			var ai:Object = { movie:movie, timer:0.0, fps:_fps, curr:_curr, begin:begin, end:end, type:type, is_loop:is_loop, percent: -1.0, step:_step, is_stop:false, trigger:[], phases:[] };
			var n:int;
			if (dead_ani.length > 0) n = dead_ani.pop();
			else n = ani.length;
			ani[n] = ai;
			return n;
		}
		static public function clearMovie(movie:MovieClip):void {
			var i:int = 0;
			while(i < ani.length) {
				if (ani[i] != null && ani[i].movie == movie) {
					ani[i] = null;
					dead_ani.push(i);
					continue;
				}
				i++;
			}
		}
		static public function clear():void {
			for (var i:int = 0; i < ani.length; i++) {
				ani[i].movie = null;
			}
			ani = [];
			dead_ani = [];
		}
		static public function setEnd(a:int, end:int):void {
			if (ani[a] == null) return;
			ani[a].end = end;
		}
		static public function isStop(a:int):Boolean {
			if (ani[a] == null) return true;
			if (ani[a].is_loop) return false; // !!!
			if (ani[a].is_stop) return true;
			return false;
		}
		static public function setCurr(a:int, frame:int):void {
			if (ani[a] == null) return;
			ani[a].curr = Math.max(ani[a].begin, Math.min(ani[a].end, frame));
			ani[a].movie.gotoAndStop(ani[a].curr);
		}
		static public function getCurr(a:int):int {
			if (ani[a] == null) return -1;
			return ani[a].curr;
		}
		static public function getTime(a:int):Number {
			if(ani[a] == null) return 0;
			return ani[a].fps * (ani[a].end - ani[a].begin);
		}
		static public function reset(a:int):void {
			if(ani[a] == null) return;
			if (ani[a].type == BACK) ani[a].curr = ani[a].end;
			else ani[a].curr = ani[a].begin;
			ani[a].timer = 0;
			ani[a].is_stop = false;
		}
		static public function addTrigger(a:int, frame:int, func:Function):void {
			if (ani[a] == null) return;
			ani[a].trigger.push({frame:frame, func:func});
		}
		static public function setPhase(a:int, begin:int, end:int, phase:int):void {
			if (ani[a] == null) return;
			for (var i:int = begin; i < end; i++) {
				ani[a].phases[i] = phase;
			}
		}
		static public function getPhase(a:int, frame:int = -1):int {
			if (ani[a] == null) return -1;
			if(frame < 0) frame = ani[a].curr;
			return ani[a].phases[frame];
		}
		static public function update(a:int, delta:Number):void {
			if(a < 0 || ani[a] == null) {
				trace("Animation "+a+" not found.");
				return;
			}
			if (ani[a].is_stop) return;
			ani[a].timer += delta;
			var i:int = 0;
			while(ani[a].timer >= ani[a].fps && ani[a].fps > 0) {
				ani[a].timer -= ani[a].fps;
				if (ani[a].fps == 0) ani[a].timer = 0;
				ani[a].curr += ani[a].step;
				ani[a].percent = -1;
				if(ani[a].type == FORVARD) {
					if(ani[a].curr > ani[a].end){
						if(ani[a].is_loop)
							ani[a].curr = ani[a].begin;
						else {
							ani[a].curr = ani[a].end;
							ani[a].is_stop = true;
							return;
						}
					}
				} else if(ani[a].type == BACK) {
					if(ani[a].curr < ani[a].begin) {
						if(ani[a].is_loop)
							ani[a].curr = ani[a].end;
						else {
							ani[a].curr = ani[a].begin;
							ani[a].is_stop = true;
							return;
						}
					}
				} else {
					if(ani[a].curr == ani[a].begin || ani[a].curr == ani[a].end) ani[a].step = -ani[a].step;
				}
				for (var t:int = 0; t < ani[a].trigger.length; t++) {
					if (ani[a].curr == ani[a].trigger[t].frame && ani[a].trigger[t].func != null) {
						ani[a].trigger[t].func();
					}
				}
				i++;
			}
			ani[a].movie.gotoAndStop(ani[a].curr);
		}
	}
}