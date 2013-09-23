package  elmortem.states {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import elmortem.managers.EventManager;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Osokin <elmortem> Makar
	 */
	public class State extends Sprite {
		public var attr:Object;
		protected var is_free:Boolean = false;
		
		public function State(attrIn:Object = null):void {
			attr = attrIn;
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
		protected function init():void {}
		public function free():void {
			is_free = true;
			dispatchEvent(new StateEvent(StateEvent.FREE, this));
		}
		public function restart():void {
			free();
			init();
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
		public function getSnapshot(transparent:Boolean = false):Bitmap {
			var r:Rectangle = getBounds(parent);
			r.width = Math.min(stage.stageWidth, r.width);
			r.height = Math.min(stage.stageHeight, r.height);
			var bd:BitmapData = new BitmapData(Math.max(1, r.width), Math.max(1, r.height), transparent, 0x00000000);
			var mtx:Matrix = this.transform.matrix.clone();
			//mtx.translate(r.x, r.y);
			bd.draw(this, mtx, null, null, null, true);
			return new Bitmap(bd, "auto", false);
		}
	}
}