package karma.core {
	import flash.display.Sprite;
	import karma.events.KarmaEvent;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class EventManager extends EventDispatcher implements IAnimatable {
		static private var _this:EventManager = null;
		static private var _list:Vector.<Event> = null;
		
		static public function get instance():EventManager {
			if (_this == null) new EventManager();
			return _this;
		}
		public function EventManager() {
			super();
			if (_this != null) throw("EventDispatcher is singltone.");
			_this = this;
			addEventListener(KarmaEvent.CREATED, onCreated);
		}
		private function onCreated(e:KarmaEvent):void {
			_list = new Vector.<Event>();
			Starling.juggler.add(this);
		}
		
		override public function addEventListener(type:String, listener:Function):void {
			if (type == EnterFrameEvent.ENTER_FRAME || type == KeyboardEvent.KEY_DOWN || type == KeyboardEvent.KEY_UP || type == TouchEvent.TOUCH || type == Event.RESIZE) {
				Starling.current.stage.addEventListener(type, listener);
				return;
			}
			super.addEventListener(type, listener);
		}
		override public function removeEventListener(type:String, listener:Function):void {
			if (type == EnterFrameEvent.ENTER_FRAME || type == KeyboardEvent.KEY_DOWN || type == KeyboardEvent.KEY_UP || type == TouchEvent.TOUCH || type == Event.RESIZE) {
				Starling.current.stage.removeEventListener(type, listener);
				return;
			}
			super.removeEventListener(type, listener);
		}
		override public function removeEventListeners(type:String = null):void {
			if (type == KeyboardEvent.KEY_DOWN || type == KeyboardEvent.KEY_UP || type == TouchEvent.TOUCH) {
				Starling.current.stage.removeEventListeners(type);
				return;
			}
			super.removeEventListeners(type);
		}
		override public function dispatchEvent(event:Event):void {
			if(_list == null) {
				super.dispatchEvent(event);
			} else {
				_list.push(event);
			}
		}
		public function dispatchEventNow(event:Event):void {
			super.dispatchEvent(event);
		}
		public function advanceTime(time:Number):void {
			var len:int = _list.length;
			if(len > 0) {
				for (var i:int = 0; i < len; i++) {
					super.dispatchEvent(_list[i]);
				}
				_list.length = 0;
			}
		}
	}
}