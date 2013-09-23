package elmortem.types {
	import elmortem.utils.NumberUtils;
	
	public class TimeSlow {
		private var val:Number;
		private var val_to:Number;
		private var timer:Number;
		
		private var speed:Number;
		
		public function TimeSlow() {
			val = val_to = 1;
			timer = 0;
			speed = 1;
		}
		
		public function start(time:Number, value:Number = 0.5):void {
			//val_to = Math.min(value, val_to);
			val_to = value;
			//timer = Math.max(time, timer);
			timer = time;
			speed = Math.abs(val_to - val);
		}
		
		public function update(delta:Number):void {
			if (val != val_to) {
				val = NumberUtils.approach(delta * speed, val, val_to);
			}
			timer -= delta;
			if (timer <= 0 && !NumberUtils.equal(val, 1, 0.001)) {
				val_to = 1;
				speed = Math.abs(val_to - val);
			}
		}
		
		public function get value():Number {
			return val;
		}
	}
}