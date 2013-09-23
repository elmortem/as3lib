package elmortem.ui {
	import elmortem.ui.events.UiEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public class UiComponent extends Sprite {
		static private var ids:int = 0;
		
		public var attr:Object;
		
		private var id:int;
		public var _name:String;
		private var _width:Number;
		private var _height:Number;
		private var _z:int;
		private var _lock:Boolean;
		
		public function UiComponent(attrIn:Object = null) {
			attr = attrIn;
			if (attr == null) attr = { };
			
			id = ++ids;
			_name = (attr.name != null)?attr.name:"com" + id;
			x = (attr.x != null)?attr.x:0;
			y = (attr.y != null)?attr.y:0;
			_width = (attr.y != null)?attr.y:100;
			_height = (attr.y != null)?attr.y:100;
			_z = (attr.z != null)?attr.z:0;
		}
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
			render();
			sendEvent(new UiEvent(UiEvent.RESIZE));
		}
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
			render();
			sendEvent(new UiEvent(UiEvent.RESIZE));
		}
		override public function get z():Number {
			return _z;
		}
		override public function set z(value:Number):void {
			_z = value;
			if (parent != null && parent is UiComponent) {
				(parent as UiComponent).sortChilds();
			}
		}
		public function get group():String {
			if (parent != null && parent is UiComponent) return (parent as UiComponent).group;
			return null;
		}
		public function set group(value:String):void {
		}
		
		public function add(c:UiComponent):UiComponent {
			throw new Error(UiManager.ERR_OVERRIDE_METHOD);
		}
		public function remove(c:UiComponent):void {
			throw new Error(UiManager.ERR_OVERRIDE_METHOD);
		}
		public function clear():void {
			throw new Error(UiManager.ERR_OVERRIDE_METHOD);
		}
		public function findChildByName(name:String, child:Boolean = false):UiComponent {
			throw new Error(UiManager.ERR_OVERRIDE_METHOD);
		}
		
		public function sortChilds():void {
			throw new Error(UiManager.ERR_OVERRIDE_METHOD);
		}
		
		public function addListener(type:String, callback:Function):void {
			UiManager._addListener(this, type, callback);
		}
		public function removeListener(type:String, callback:Function):void {
			UiManager._removeListener(this, type, callback);
		}
		public function clearListeners():void {
			UiManager._clearListeners(this);
		}
		public function sendEvent(event:UiEvent):void {
			UiManager._sendEvent(this, event);
		}
		
		public function lock():void {
			_lock = true;
		}
		public function unlock():void {
			_lock = false;
			render();
		}
		public function get isLock():Boolean {
			return _lock;
		}
		public function render():void {
		}
	}
}