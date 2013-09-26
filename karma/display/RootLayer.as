package karma.display {
	import karma.core.Karma;
	import karma.events.KarmaEvent;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class RootLayer extends Sprite {
		static private var _this:RootLayer = null;
		
		static public function get instance():RootLayer {
			return _this;
		}
		
		public function RootLayer():void {
			super();
			if (_this != null) throw("RootLayer is singleton.");
			_this = this;
			
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		private function onInit(e:Event = null):void {
			Karma.eventer.dispatchEvent(new KarmaEvent(KarmaEvent.CREATED));
		}
	}
}