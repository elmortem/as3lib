package karmateam.states {
	
	public class StateScript implements IStateScript {
		private var _state:State;
		
		public function StateScript() { }
		
		public function init(state:State):void {
			_state = state;
		}
		public function update(delta:Number):void {
			
		}
		public function render():void {
			
		}
		public function get name():String {
			return "Default";
		}
	}
}