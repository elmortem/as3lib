package karma.display {
	import karma.core.Karma;
	import karma.events.KarmaEvent;
	import starling.core.Starling;
	
	public class ScreenManager extends Screen {
		static private var _this:ScreenManager = null;
		private var _list:Vector.<Screen> = new Vector.<Screen>();
		//static private var _fader:IFader;
		
		static public function get instance():ScreenManager {
			if (_this == null) new ScreenManager();
			return _this;
		}
		
		public function ScreenManager() {
			super();
			if (_this != null) throw("ScreenManager is singleton.");
			_this = this;
			Starling.current.nativeStage.addChild(this);
		}
		override public function free():void {
			clear();
			_list = null;
			_this = null;
			super.free();
		}
		
		public function add(s:Screen):Screen {
			_list.push(s);
			this.addChild(s);
			s.resize();
			
			// dispatch event
			
			return s;
		}
		public function remove(s:Screen, isFree:Boolean = true):void {
			var idx:int = _list.indexOf(s);
			if (idx >= 0) {
				_list.splice(idx, 1);
				
				if (isFree) {
					s.free();
				}
				
				// dispatch event
			}
		}
		public function clear(isFree:Boolean = true):void {
			if(isFree) {
			for (var i:int = 0; i < _list.length; i++) {
				_list[i].free();
			}
			}
			_list.length = 0;
		}
		public function show(s:Screen):Screen {
			clear();
			return add(s);
		}
		
		public function get screen():Screen {
			if (_list.length <= 0) return null;
			return _list[_list.length-1];
		}
		public function set screen(s:Screen):void {
			show(s);
		}
		
		public function resizeAll():void {
			for (var i:int = 0; i < _list.length; i++) {
				_list[i].resize();
			}
		}
		
		
		override public function activate():void {
			for (var i:int = 0; i < _list.length; i++) {
				_list[i].activate();
			}
		}
		override public function deactivate():void {
			for (var i:int = 0; i < _list.length; i++) {
				_list[i].deactivate();
			}
		}
	}
}