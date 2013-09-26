package karma.display {
	import flash.display.Sprite;
	import flash.events.Event;
	import karma.core.Karma;
	import starling.core.Starling;
	
	public class Screen extends Sprite {
		protected var _attr:Object;
		private var _isFree:Boolean;
		
		public function Screen(attr:Object = null):void {
			super();
			
			_attr = attr;
			_isFree = true;
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		
		private function onInit(e:Event = null):void {
			_isFree = false;
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			init();
			stage.focus = stage;
		}
		protected function init():void { };
		
		public function free():void {
			_attr = null;
			_isFree = true;
			if (parent != null) {
				parent.removeChild(this);
			}
		}
		
		public function get isFree():Boolean {
			return _isFree;
		}
		
		public function resize():void {
		}
		public function activate():void {
		}
		public function deactivate():void {
		}
	}
}