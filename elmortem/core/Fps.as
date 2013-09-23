package elmortem.core {
	import flash.utils.getTimer;
	
	public class Fps {
		static private var last_time:int = 0;
		static private var last_fps_time:int = 0;
		// delta
		static public var delta:Number = 0;
		// fps
		static private var _fps:int = 0;
		static private var fps_num:int = 0;
		
		static public function start():void {
			last_time = last_fps_time = getTimer();
			delta = 0;
			_fps = 0;
			fps_num = 0;
		}
		static public function step():void {
			// delta
			delta = (getTimer() - last_time) / 1000;
			
			last_time = getTimer();
			fps_num++;
			if(last_time - last_fps_time >= 1000) {
				_fps = fps_num;
				fps_num = 0;
				last_fps_time = last_time;
			}
		}
		static public function get fps():int {
			return _fps;
		}
	}
}