package elmortem.ads {
	import CPMStar.AdLoader;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class CPMStarLoader extends Sprite {
		private var time:Number;
		private var timer:Number;
		private var ad:AdLoader;
		private var ad_loaded:Boolean;
		
		private var last_time:Number;
		
		public function CPMStarLoader(Time:Number, ContentSpotId:String) {
			super();
			time = Time;
			timer = 0;
			last_time = getTimer();
			
			var g:Graphics = graphics;
			g.beginFill(0x000000);
			g.lineStyle();
			g.drawRect(0, 0, 300, 250);
			g.endFill();
			
			ad_loaded = false;
			addChild(ad = new AdLoader(ContentSpotId));
			ad.addEventListener(Event.COMPLETE, onAdLoaded);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		private function onAdLoaded(e:Event):void {
			trace("CPMStar Ad loaded.");
			ad_loaded = true;
		}
		private function onFrame(e:Event):void {
			if (stage == null) return;
			
			var delta:Number = (getTimer() - last_time) / 1000;
			last_time = getTimer();
			
			if (ad.isLoaded) {
				if (timer < time) {
					timer += delta;
					if (timer > time) {
						timer = time;
						removeEventListener(Event.ENTER_FRAME, onFrame);
					}
				}
			}
		}
		public function progress():Number {
			if (time <= 0) return 0;
			return timer / time;
		}
	}
}