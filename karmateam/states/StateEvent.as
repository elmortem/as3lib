package karmateam.states {
	import flash.events.Event;
	
	public class StateEvent extends Event {
		static public const INIT:String = "state.init";
		static public const FREE:String = "state.free";
		static public const ADDED:String = "state.added_to_manager";
		static public const REMOVED:String = "state.removed_from_manager";
		
		public var state:State = null;
		
		public function StateEvent(type:String, state:State = null, bubbles:Boolean = false, cancelable:Boolean = true) {
			super(type, bubbles, cancelable);
			this.state = state;
		}
		
		override public function clone():Event {
			return new StateEvent(type, state, bubbles, cancelable);
		}
	}
}