package karmateam.states {
	import flash.display.DisplayObjectContainer;
	import karmateam.core.Game;
	
	public class Fader {
		protected var _clip:DisplayObjectContainer;
		
		public function Fader(clip:DisplayObjectContainer):void {
			_clip = clip;
		}
		
		public function showState(state:State, attr:Object, timeIn:Number, timeOut:Number):void {
			Game.stateManager.show(new state(attr));
		}
		public function addState(state:State, attr:Object, timeIn:Number, timeOut:Number):void {
			Game.stateManager.add(new state(attr));
		}
	}
}