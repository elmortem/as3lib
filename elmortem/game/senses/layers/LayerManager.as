package elmortem.game.senses.layers {
	import elmortem.game.senses.ISense;
	import flash.display.Sprite;
	
	public class LayerManager implements ISense {
		private var list:Object;
		private var defaultLayer:Sprite;
		
		public function LayerManager() {
			list = {};
			defaultLayer = null;
		}
		public function free():void {
			clear();
			list = null;
		}
		public function get senseName():String {
			return "layerManager";
		}
		public function update(delta:Number):void {
		}
		
		public function clear():void {
			for(var key:String in list) {
				if (list[key].parent != null) {
					list[key].parent.removeChild(list[key]);
				}
			}
			list = {};
			defaultLayer = null;
		}
		public function add(layer:Sprite, name:String = null, def:Boolean = false):Sprite {
			if (name != null) layer.name = name;
			else name = layer.name;
			if (list[name] != null) return list[name];
			list[name] = layer;
			if (def || defaultLayer == null) defaultLayer = layer;
			
			return layer;
		}
		public function find(name:String):Sprite {
			var layer:Sprite = list[name];
			if (layer == null) return defaultLayer;
			return layer;
		}
	}
}