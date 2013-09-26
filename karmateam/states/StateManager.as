package karmateam.states {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import karmateam.core.EventManager;

	public class StateManager extends EventDispatcher {
		private var _clip:DisplayObjectContainer;
		private var _list:Vector.<State>;
		
		/**
		 * 
		 * @param	attrIn clip
		 */
		public function StateManager(clip:DisplayObjectContainer) {
			_clip = clip;
			_list = new Vector.<State>();
		}
		public function free():void {
			if (_list == null) return;
			var ln:int = _list.length;
			for (var i:int = 0; i < ln; i++) {
				_list[i].free();
				_clip.removeChild(_list[i]);
			}
			_list = null;
			_clip = null;
		}
		
		public function add(state:State):State {
			if (_clip == null || state == null) return null;
			_list.push(state);
			_clip.addChild(state);
			EventManager.dispatch(this, new StateEvent(StateEvent.ADDED, state));
			return state;
		}
		public function remove(state:State):Boolean {
			if (_clip == null || state == null) {
				trace("State not found.");
				return false;
			}
			var id:int = _list.indexOf(state);
			if (id < 0) {
				trace("State not found.");
				return false;
			}
			_list.splice(id, 1);
			state.free();
			_clip.removeChild(state);
			EventManager.dispatch(this, new StateEvent(StateEvent.REMOVED, state));
			return true;
		}
		public function clear():void {
			if (_clip == null) return;
			_clip.stage.focus = null;
			var ln:int = _list.length;
			for (var i:int = 0; i < ln; i++) {
				_list[i].free();
				_clip.removeChild(_list[i]);
				EventManager.dispatch(this, new StateEvent(StateEvent.REMOVED, _list[i]));
			}
			_list.length = 0;
		}
		public function show(state:State):State {
			clear();
			return add(state);
		}
		public function swap(state0:State, state1:State):Boolean {
			if (_clip == null || _list.indexOf(state0) < 0 || _list.indexOf(state1) < 0) return false;
			_clip.swapChildren(state0, state1);
			return true;
		}
		public function sendToBack(state:State):Boolean {
			if (_clip == null || _list.indexOf(state) < 0) return false;
			_clip.setChildIndex(state, 0);
			return true;
		}
		public function sendToForward(state:State):Boolean {
			if (_clip == null || _list.indexOf(state) < 0) return false;
			_clip.setChildIndex(state, _clip.numChildren - 1);
			return true;
		}
		
		public function getState(name:String):State {
			var ln:int = _list.length;
			for (var i = 0; i < ln; i++) {
				if (_list[i].name == name) {
					return _list[i];
				}
			}
			return null;
		}
		public function getStateAt(idx:int):State {
			if (idx >= _list.length) return null;
			return _list[idx];
		}
		public function get list():Vector.<State> {
			return _list;
		}
	}
}