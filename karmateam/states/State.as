package  karmateam.states {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import karma.core.EventManager;
	
	/**
	 * ...
	 * @author Osokin <elmortem> Makar
	 */
	public class State extends Sprite {
		public var attr:Object;
		protected var is_free:Boolean = false;
		protected var list:Vector.<IStateScript>;
		
		public function State(attrIn:Object = null):void {
			attr = attrIn;
			list = new Vector.<IStateScript>();
			addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		
		private function onInit(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			if (stage != null) {
				stage.focus = stage;
				init();
				is_free = false;
				dispatchEvent(new StateEvent(StateEvent.INIT, this));
			}
		}
		protected function init():void {
			name = (attr.name != null)?attr.name:"default";
			
			var ln:int = list.length;
			for (var i:int = 0; i < ln; i++) {
				list[i].init(this);
			}
		}
		public function free():void {
			is_free = true;
			dispatchEvent(new StateEvent(StateEvent.FREE, this));
		}
		public function createLayer(name:String, parent:Sprite = null):Sprite {
			var layer:Sprite = new Sprite();
			layer.name = name;
			if (parent == null) parent = this;
			parent.addChild(layer);
			return layer;
		}
		public function removeAllChilds(is_remove_events:Boolean = false):void {
			while (this.numChildren) {
				if(is_remove_events) EventManager.remove(getChildAt(0));
				removeChildAt(0);
			}
		}
	}
}