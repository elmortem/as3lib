package elmortem.ads {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.getTimer;
	
	public class ABSLoader extends Sprite {
		private var time:Number;
		private var timer:Number;
		private var abs:Object;
		private var loaded:Boolean;
		
		private var last_time:Number;
		
		public function ABSLoader(Time:Number) {
			super();
			time = Time;
			timer = 0;
			last_time = getTimer();
			
			/*var g:Graphics = graphics;
			g.beginFill(0x000000);
			g.lineStyle();
			g.drawRect(0, 0, 300, 250);
			g.endFill();*/
			
			loaded = false;
			
			// URL to the ABS swf.
			var abs_url:String = "http://agi.armorgames.com/assets/agi/ABS.swf";
			Security.allowDomain(abs_url);
			 
			// Load the ABS
			var urlRequest:URLRequest = new URLRequest(abs_url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.load(urlRequest);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function free():void {
			abs.hide();
			removeChild(abs as DisplayObject);
			abs = null;
		}
		private function onLoaded(e:Event):void {
			trace("ABS loaded.");
			
			// Save the ABS reference
			abs = e.currentTarget.content;
			// Add the ABS as a child to your document class or lowest level display object (required)
			addChild(abs as DisplayObject);
			// Show the ABS at screen coordinate 100x100
			abs.show( { x:0, y:0 } );
			
			loaded = true;
		}
		private function onFrame(e:Event):void {
			if (stage == null) return;
			
			var delta:Number = (getTimer() - last_time) / 1000;
			last_time = getTimer();
			
			if (loaded) {
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