package elmortem.types {
	
	public class CooldownTimer {
		protected var is_active:Boolean = false;
		protected var time:Number = 0;
		protected var timer:Number = 0;
		
		public function CooldownTimer(timeIn:Number = 0) {
			time = timeIn;
			timer = 0;
		}
		public function start(timeIn:Number = -1):void {
			if (timeIn >= 0) time = timeIn;
			is_active = true;
			timer = time;
		}
		public function stop():void {
			is_active = false;
		}
		public function complete():void {
			is_active = true;
			timer = 0;
		}
		public function update(delta:Number):void {
			if (!is_active) return;
			if (timer > 0) timer -= delta;
		}
		public function isComplete():Boolean {
			return (is_active && timer <= 0);
		}
		public function getTime():Number {
			return time;
		}
		public function getTimePassed():Number {
			return time - timer;
		}
		public function isActive():Boolean {
			return is_active;
		}
	}
}