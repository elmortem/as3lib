package elmortem.game.editor {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class EditorEvent extends Event {
		
		public var data:Object;
		
		public function EditorEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.data = data;
		} 
		
		public override function clone():Event { 
			return new EditorEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EditorEvent", "data", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}