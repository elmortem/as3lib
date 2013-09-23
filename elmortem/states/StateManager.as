package elmortem.states {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import elmortem.states.faders.IFader;

	public class StateManager extends EventDispatcher {
		static private var _instance:StateManager = null;
		static private var _clip:DisplayObjectContainer = null;
		static private var _fader:IFader = null;
		static private var _fade_time:Number = 1;
		static private var _list:Vector.<State> = new Vector.<State>();
		
		static public function init(attrIn:Object):StateManager {
			_instance = new StateManager(attrIn);
			return _instance;
		}
		static public function get instance():StateManager {
			return _instance;
		}
		public function StateManager(attrIn:Object) {
			if (_instance != null) throw("StateManager is singleton!");
			
			if (attrIn is DisplayObjectContainer) {
				_clip = attrIn as DisplayObjectContainer;
			} else {
				_clip = attrIn.clip;
				_fader = attrIn.fader;
			}
		}
		public function free():void {
			if (_list == null) return;
			var ln:int = _list.length;
			for (var i:int = 0; i < ln; i++) {
				_list[i].free();
				_clip.removeChild(_list[i]);
			}
			_list.length = 0;
			_list = null;
			_clip = null;
		}
		
		public function add(state:State):State {
			if (_clip == null || state == null) return null;
			_list.push(state);
			_clip.addChild(state);
			dispatchEvent(new StateEvent(StateEvent.ADDED_TO_MANAGER, state));
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
			dispatchEvent(new StateEvent(StateEvent.REMOVED_FROM_MANAGER, state));
			return true;
		}
		public function clear():void {
			if (_clip == null) return;
			_clip.stage.focus = null;
			var ln:int = _list.length;
			for (var i:int = 0; i < ln; i++) {
				_list[i].free();
				_clip.removeChild(_list[i]);
			}
			_list.length = 0;
		}
		public function show(state:State, fade_time:Number = 0):State {
			_fade_time = fade_time;
			if(_fader == null || fade_time <= 0) {
				clear();
				return add(state);
			} else {
				_fader.fadeIn(fade_time, onFadeIn, [state], true);
				return state;
			}
		}
		private function onFadeIn(state:State):void {
			clear();
			state.addEventListener(Event.ADDED_TO_STAGE, onStateInit);
			add(state);
		}
		private function onStateInit(e:Event):void {
			e.currentTarget.addEventListener(Event.ADDED_TO_STAGE, onStateInit);
			_fader.fadeOut(_fade_time);
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
		
		
		public function get list():Vector.<State> {
			return _list;
		}
	}
}