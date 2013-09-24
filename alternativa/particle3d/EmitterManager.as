package alternativa.particle3d {
	import alternativa.types.Point3D;
	
	public class EmitterManager {
		public var attr:Object;
		public var emitters:Array;
		public var is_enable:Boolean = true;
		
		public function EmitterManager(attrIn:Object) {
			attr = attrIn;
			
			emitters = [];
		}
		public function free():void {
			removeAll();
			emitters = null;
			attr = null;
		}
		public function set enable(value:Boolean):void {
			is_enable = value;
			if (!is_enable) {
				removeAll();
			}
		}
		public function get enable():Boolean { return is_enable; }
		
		public function add(em:Emitter):Emitter {
			if (!is_enable) return null;
			if (!em) {
				trace("Error: Emitter is null.");
				return null;
			}
			emitters.push(em);
			attr.scene.root.addChild(em);
			return em;
		}
		public function createAt(data:Object, point:Point3D):Emitter {
			if (!is_enable) return null;
			//data.attr.scene = attr.scene;
			var em:Emitter = new data.cls(data.attr);
			return add(em);
		}
		public function remove(em:Emitter):void {
			var id:int = emitters.indexOf(em);
			if (id >= 0) {
				attr.scene.root.removeChild(emitters[id]);
				emitters[id].free();
				emitters.splice(id, 1);
			}
		}
		public function removeAll():void {
			for (var i:int = 0; i < emitters.length; i++) {
				attr.scene.root.removeChild(emitters[i]);
				emitters[i].free();
			}
			emitters = [];
		}
		public function update(delta:Number):void {
			if (!is_enable) return;
			for (var i:int = 0; i < emitters.length; i++) {
				emitters[i].update(delta);
				
				if (!emitters[i].isAlive()) {
					remove(emitters[i]);
					i--;
				}
			}
		}
	}
}