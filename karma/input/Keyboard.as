package karma.input {
	import karma.core.Karma;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	
	public class Keyboard {
		static private const MAX:uint = 256;
		static private var _this:Keyboard = null;
		
		private var _lookup:Object;
		private var _map:Array;
		
		static public function get instance():Keyboard {
			if (_this == null) _this = new Keyboard();
			return _this;
		}
		
		public function Keyboard() {
			if (_this != null) throw("Keyboard is singleton.");
			_this = this;
			
			_lookup = { };
			_map = new Array(MAX);
			initKeys();
			
			Karma.eventer.addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			Karma.eventer.addEventListener(KeyboardEvent.KEY_DOWN, onDown);
			Karma.eventer.addEventListener(KeyboardEvent.KEY_UP, onUp);
		}
		
		public function reset():void {
			var i:uint = 0;
			while(i < MAX) {
				var o:Object = _map[i++];
				if(o == null) continue;
				this[o.name] = false;
				o.current = 0;
				o.last = 0;
			}
		}
		public function pressed(Key:String):Boolean {
			return _map[_lookup[Key]].current > 0;
		}
		public function justPressed(Key:String):Boolean {
			return _map[_lookup[Key]].current == 2;
		}
		public function justReleased(Key:String):Boolean {
			return _map[_lookup[Key]].current == -1;
		}
		public function getKeyCode(KeyName:String):int {
			return _lookup[KeyName];
		}
		public function any():Boolean {
			var i:uint = 0;
			while(i < MAX) {
				var o:Object = _map[i++];
				if((o != null) && (o.current > 0))
					return true;
			}
			return false;
		}
		
		private function onFrame(e:EnterFrameEvent):void {
			var i:uint = 0;
			while(i < MAX) {
				var o:Object = _map[i++];
				if(o == null) continue;
				if((o.last == -1) && (o.current == -1)) o.current = 0;
				else if((o.last == 2) && (o.current == 2)) o.current = 1;
				o.last = o.current;
			}
		}
		private function onDown(e:KeyboardEvent):void {
			var o:Object = _map[e.keyCode];
			if(o == null) return;
			if(o.current > 0) o.current = 1;
			else o.current = 2;
		}
		private function onUp(e:KeyboardEvent):void {
			var o:Object = _map[e.keyCode];
			if(o == null) return;
			if(o.current > 0) o.current = -1;
			else o.current = 0;
		}
		
		
		private function initKeys():void {
			//LETTERS
			var i:uint = 65;
			while(i <= 90)
				_addKey(String.fromCharCode(i),i++);
			
			//NUMBERS
			i = 48;
			_addKey("ZERO",i++);
			_addKey("ONE",i++);
			_addKey("TWO",i++);
			_addKey("THREE",i++);
			_addKey("FOUR",i++);
			_addKey("FIVE",i++);
			_addKey("SIX",i++);
			_addKey("SEVEN",i++);
			_addKey("EIGHT",i++);
			_addKey("NINE",i++);
			i = 96;
			_addKey("NUMPADZERO",i++);
			_addKey("NUMPADONE",i++);
			_addKey("NUMPADTWO",i++);
			_addKey("NUMPADTHREE",i++);
			_addKey("NUMPADFOUR",i++);
			_addKey("NUMPADFIVE",i++);
			_addKey("NUMPADSIX",i++);
			_addKey("NUMPADSEVEN",i++);
			_addKey("NUMPADEIGHT",i++);
			_addKey("NUMPADNINE",i++);
			_addKey("PAGEUP", 33);
			_addKey("PAGEDOWN", 34);
			_addKey("HOME", 36);
			_addKey("END", 35);
			_addKey("INSERT", 45);
			
			//FUNCTION KEYS
			i = 1;
			while(i <= 12)
				_addKey("F"+i,111+(i++));
			
			//SPECIAL KEYS + PUNCTUATION
			_addKey("ESCAPE",27);
			_addKey("MINUS",189);
			_addKey("NUMPADMINUS",109);
			_addKey("PLUS",187);
			_addKey("NUMPADPLUS",107);
			_addKey("DELETE",46);
			_addKey("BACKSPACE",8);
			_addKey("LBRACKET",219);
			_addKey("RBRACKET",221);
			_addKey("BACKSLASH",220);
			_addKey("CAPSLOCK",20);
			_addKey("SEMICOLON",186);
			_addKey("QUOTE",222);
			_addKey("ENTER",13);
			_addKey("SHIFT",16);
			_addKey("COMMA",188);
			_addKey("PERIOD",190);
			_addKey("NUMPADPERIOD",110);
			_addKey("SLASH",191);
			_addKey("NUMPADSLASH",191);
			_addKey("CONTROL",17);
			_addKey("ALT",18);
			_addKey("SPACE",32);
			_addKey("UP",38);
			_addKey("DOWN",40);
			_addKey("LEFT",37);
			_addKey("RIGHT",39);
			_addKey("TAB",9);
		}
		private function _addKey(KeyName:String, KeyCode:uint):void {
			_lookup[KeyName] = KeyCode;
			_map[KeyCode] = { name: KeyName, current: 0, last: 0 };
		}
	}
}