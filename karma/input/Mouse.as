package karma.input {
	import karma.core.Karma;
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class Mouse {
		static public const UP_LEFT:uint = 1;
		static public const UP_RIGHT:uint = 2;
		static public const DOWN_LEFT:uint = 4;
		static public const DOWN_RIGHT:uint = 8;
		static public const UP:uint = UP_LEFT | UP_RIGHT;
		static public const DOWN:uint = DOWN_LEFT | DOWN_RIGHT;
		static public const LEFT:uint = UP_LEFT | DOWN_LEFT;
		static public const RIGHT:uint = UP_RIGHT | DOWN_RIGHT;
		static public const ANY:uint = UP | DOWN; // 15
		
		static private var _this:Mouse = null;
		
		private var _states:Vector.<MouseState>;
		
		public var x:Number;
		public var y:Number;
		
		static public function get instance():Mouse {
			if (_this == null) _this = new Mouse();
			return _this;
		}
		
		public function Mouse() {
			if (_this != null) throw("Mouse is singleton.");
			_this = this;
			
			_states = new Vector.<MouseState>();
			
			x = y = -1;
			
			Karma.eventer.addEventListener(TouchEvent.TOUCH, onTouch);
			Karma.eventer.addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
		}
		
		public function reset():void {
			_states.length = 0;
		}
		
		private function onFrame(e:EnterFrameEvent):void {
			var len:uint = _states.length;
			for (var i:int = 0; i < len; i++) {
				var s:MouseState = _states[i];
				if((s.last == -1) && (s.current == -1))
					s.current = 0;
				else if((s.last == 2) && (s.current == 2))
					s.current = 1;
				s.last = s.current;
			}
		}
		private function onTouch(e:TouchEvent):void {
			var len:uint = e.touches.length;
			for (var i:uint = 0; i < len; i++) {
				var t:Touch = e.touches[i];
				var s:MouseState = getStateById(t.id);
				if (s == null) {
					s = new MouseState();
					s.id = t.id;
					_states.push(s);
				}
				
				if (t.id == 0) { // mouse
					x = t.globalX;
					y = t.globalY;
				}
				
				s.plane = getPlane(t.globalX, t.globalY);
				s.x = t.globalX;
				s.y = t.globalY;
				//s.last = s.current;
				if (t.phase == TouchPhase.BEGAN) {
					if(s.current > 0) s.current = 1;
					else s.current = 2;
				} else if (t.phase == TouchPhase.MOVED) {
					//
				} else if (t.phase == TouchPhase.ENDED) {
					if(s.current > 0) s.current = -1;
					else s.current = 0;
				}
			}
		}
		
		private function getStateById(id:int):MouseState {
			var len:uint = _states.length;
			for (var i:uint = 0; i < len; i++) {
				if (_states[i].id == id) return _states[i];
			}
			return null;
		}
		private function getStateByPlane(plane:uint):MouseState {
			var len:uint = _states.length;
			for (var i:uint = 0; i < len; i++) {
				var s:MouseState = _states[i];
				if((plane & s.plane) == s.plane) return _states[i];
			}
			return null;
		}
		public function getPlane(x:Number, y:Number):uint {
			if (x < Starling.current.stage.stageWidth * 0.5) {
				if (y < Starling.current.stage.stageHeight * 0.5) {
					return UP_LEFT;
				} else {
					return DOWN_LEFT;
				}
			} else {
				if (y < Starling.current.stage.stageHeight * 0.5) {
					return UP_RIGHT;
				} else {
					return DOWN_RIGHT;
				}
			}
		}
		public function pressed(plane:uint = 15):Boolean {
			var len:uint = _states.length;
			for (var i:uint = 0; i < len; i++) {
				var s:MouseState = _states[i];
				if ((plane & s.plane) == s.plane && s.current > 0) return true;
			}
			return false;
		}
		public function justPressed(plane:uint = 15):Boolean {
			var len:uint = _states.length;
			for (var i:uint = 0; i < len; i++) {
				var s:MouseState = _states[i];
				if ((plane & s.plane) == s.plane && s.current == 2) {
					return true;
				}
			}
			return false;
		}
		public function justReleased(plane:uint = 15):Boolean {
			var len:uint = _states.length;
			for (var i:uint = 0; i < len; i++) {
				var s:MouseState = _states[i];
				if ((plane & s.plane) == s.plane && s.current == -1) {
					return true;
				}
			}
			return false;
		}
	}
}

internal class MouseState {
	public var id:int;
	public var plane:uint;
	public var current:int;
	public var last:int;
	public var x:Number;
	public var y:Number;
	
	public function MouseState():void {
		plane = 0;
		current = 0;
		last = 0;
		x = -1;
		y = -1;
	}
}