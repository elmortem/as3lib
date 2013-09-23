package elmortem.ads {
	import CPMStar.AdLoader;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class BaseAdsLoader extends Sprite {
		protected var time:Number;
		protected var timer:Number;
		protected var loaded:Boolean;
		
		public function BaseAdsLoader(Time:Number, Width:Number = -1, Height:Number = -1) {
			super();
			time = Time;
			timer = 0;
			
			if(Width > 0 && Height > 0) {
				var g:Graphics = graphics;
				g.beginFill(0x000000);
				g.lineStyle();
				g.drawRect(0, 0, Width, Height);
				g.endFill();
			}
			
			loaded = false;
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		private function onAdLoaded(e:Event):void {
			loaded = true;
		}
		private function onFrame(e:Event):void {
			if (stage == null) return;
			if (loaded) {
				if (timer < time) {
					timer += 1 / stage.frameRate;
					if (timer > time) timer = time;
				}
			}
		}
		public function progress():Number {
			if (time <= 0) return 0;
			return timer / time;
		}
	}
}