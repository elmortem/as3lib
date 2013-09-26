package karmateam.core {
	import flash.display.Sprite;
	import flash.events.Event;
	import karmateam.states.State;
	import karmateam.states.StateManager;
	
	public class Game extends Sprite {
		static public var WIDTH:int;
		static public var HEIGHT:int;
		static public var stateManager:StateManager;
		
		
		public function Game(width:int, height:int) {
			WIDTH = width;
			HEIGHT = height;
			
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		private function onInit(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			init();
		}
		protected function init():void {
			stateManager = new StateManager(this);
		}
	}
}