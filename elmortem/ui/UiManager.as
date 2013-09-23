package elmortem.ui {
	import adobe.utils.CustomActions;
	import elmortem.ui.events.UiEvent;
	import elmortem.ui.events.UiMouseEvent;
	import elmortem.utils.DictionaryUtils;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class UiManager {
		static public const ERR_STAGE_NOT_FOUND:String = "UiManager: Stage not found.";
		static public const ERR_OVERRIDE_METHOD:String = "Override this method.";
		
		static private var stage:Stage = null;
		static private var root:UiComponent = new UiContainer();
		static private var listeners:Dictionary = new Dictionary();
		static private var blockedGroups:Vector.<String> = new Vector.<String>();
		
		static public function init(stage:Stage):void {
			UiManager.stage = stage;
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		static public function set parent(value:DisplayObjectContainer):void {
			if (value == null) clear();
			value.addChild(root);
		}
		
		static public function add(c:UiComponent, parent:UiComponent = null):void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			if (parent == null) parent = root;
			root.add(c);
		}
		static public function remove(c:UiComponent):void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			root.remove(c);
		}
		static public function clear():void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			root.clear();
		}
		
		static internal function _addListener(c:UiComponent, type:String, callback:Function):void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			if (c == null) c = root;
			if (listeners[c] == null) {
				listeners[c] = new Dictionary();
			}
			if (listeners[c][type] == null) {
				listeners[c][type] = new Array();
			}
			listeners[c][type].push(callback);
		}
		static internal function _removeListener(c:UiComponent, type:String, callback:Function):void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			if (listeners[c] == null || listeners[c][type] == null) return;
			var idx:int = listeners[c][type].indexOf(callback);
			if (idx >= 0) listeners[c][type].splice(idx, 1);
			if (listeners[c][type].length == 0) {
				delete listeners[c][type];
			}
			if (DictionaryUtils.length(listeners[c]) == 0) {
				delete listeners[c];
			}
		}
		static internal function _clearListeners(c:UiComponent):void {
			if (stage == null) throw new Error(ERR_STAGE_NOT_FOUND);
			for (var key:* in listeners[c]) {
				delete listeners[c][key];
			}
			delete listeners[c];
		}
		static internal function _sendEvent(c:UiComponent, event:UiEvent):void {
			var group:String = c.group;
			if (blockedGroups.indexOf(group) >= 0) return;
			
			if(listeners[c] != null && listeners[c][event.type] != null) {
				event.owner = c;
				for (var i:int = 0; i < listeners[c][event.type].length; i++) {
					(listeners[c][event.type][i] as Function).apply(null, [event]);
				}
			}
		}
		
		static public function blockGroups(groups:Vector.<String>):void {
			var i:int = 0;
			var len:int = groups.length;
			for (i = 0; i < len; ++i) {
				blockedGroups.push(groups[i]);
			}
			// группы могут повторяться, т.к. их могут добавлять несколько раз, 
			// чтобы при разблокировке не снимался блок, установленный другим окном
		}
		static public function unblockGroups(groups:Vector.<String>):void {
			var i:int = 0;
			var len:int = groups.length;
			var idx:int;
			for (i = 0; i < len; ++i) {
				idx = blockedGroups.indexOf(groups[i]);
				if (idx >= 0) blockedGroups.splice(idx, 1);
			}
		}
		static public function unblockAllGroups():void {
			blockedGroups.splice(0, blockedGroups.length);
		}
		
		static private function onMouseClick(e:MouseEvent):void {
			trace(e.target, e.target is UiComponent);
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.CLICK);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
		static private function onMouseOver(e:MouseEvent):void {
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.OVER);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
		static private function onMouseOut(e:MouseEvent):void {
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.OUT);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
		static private function onMouseUp(e:MouseEvent):void {
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.UP);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
		static private function onMouseDown(e:MouseEvent):void {
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.DOWN);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
		static private function onMouseMove(e:MouseEvent):void {
			var c:UiComponent = e.target as UiComponent;
			if (c == null) return;
			
			var me:UiMouseEvent = new UiMouseEvent(UiMouseEvent.MOVE);
			me.x = e.localX;
			me.y = e.localY;
			_sendEvent(root, me);
		}
	}
}