package elmortem.managers {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class EventManager {
		static private var list:Dictionary = new Dictionary();
		static private var events:Array = [];
		static private var shape:Shape;
		{
			shape = new Shape();
			shape.addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
		}
		
		static public function add(target:IEventDispatcher, type:String, handler:Function, useCapture:Boolean = false):void {
			target.addEventListener(type, handler, useCapture);
			if (list[target] == null) {
				list[target] = [];
			}
			list[target].push({type:type, handler:handler, useCapture:useCapture});
		}
		static public function remove(target:IEventDispatcher, type:String = null, handler:Function = null):void {
			var arr:Array = list[target];
			if (arr == null) return;
			var i:int = 0;
			while (i < arr.length) {
				if (type == null || (arr[i].type == type && (handler == null || handler == arr[i].handler))) {
					target.removeEventListener(arr[i].type, arr[i].handler, arr[i].useCapture);
					arr.splice(i, 1);
				} else i++;
			}
			if (arr.length == 0) delete list[target];
		}
		static public function clear():void {
			events = [];
			for (var target:* in list) {
				remove(target);
			}
		}
		
		static public function dispatch(dispatcher:IEventDispatcher, event:Event):void {
			events.push( { dispatcher:dispatcher, event:event } );
		}
		static private function onFrame(e:Event):void {
			if (events.length > 0) {
				var o:Object;
				for (var i:int = 0; i < events.length; i++) {
					o = events[i];
					if (o.dispatcher == null) continue;
					o.dispatcher.dispatchEvent(o.event);
				}
				events = [];
			}
		}
	}
}