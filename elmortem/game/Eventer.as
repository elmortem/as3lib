package elmortem.game {
	import elmortem.game.senses.ISense;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class Eventer___ {
		private var _events:Array;
		
		public function Eventer() {
			_events = [];
		}
		public function free():void {
			trace("Free eventer.");
			_events = null;
		}
		
		public function add(dispatcher:IEventDispatcher, event:Event):void {
			_events.push( { dispatcher:dispatcher, event:event } );
		}
		
		public function step():void {
			if (_events.length > 0) {
				for (var i:int = 0; i < _events.length; i++) {
				//while(_events.length > 0) {
					var e:Object = _events[i];
					//_events.splice(0, 1);
					e.dispatcher.dispatchEvent(e.event);
					if (_events == null) return;
				}
				_events = [];
			}
		}
	}
}