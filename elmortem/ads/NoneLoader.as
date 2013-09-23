package elmortem.ads {
	import CPMStar.AdLoader;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class NoneLoader extends Sprite {
		private var time:Number;
		private var timer:Number;
		
		private var last_time:Number;
		
		public function NoneLoader(Time:Number) {
			super();
			time = Math.max(Time, 0.2);
			timer = 0;
			last_time = getTimer();
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		private function onFrame(e:Event):void {
			if (stage == null) return;
			
			var delta:Number = (getTimer() - last_time) / 1000;
			last_time = getTimer();
			
			if (timer < time) {
				timer += delta;
				if (timer > time) {
					timer = time;
					removeEventListener(Event.ENTER_FRAME, onFrame);
				}
			}
		}
		public function progress():Number {
			if (time <= 0) return 0;
			return timer / time;
		}
	}
}