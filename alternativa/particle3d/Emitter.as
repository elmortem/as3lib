package alternativa.particle3d {
	import alternativa.engine3d.core.Object3D;
	import alternativa.types.Point3D;
	
	public class Emitter extends Object3D {
		public static const LIFE_TIME:Number = -1;
		protected var attr:Object;
		protected var particles:Array;
		protected var is_alive:Boolean = true;
		
		protected var max:int = 100;
		protected var life:Number = LIFE_TIME;
		protected var pos:Point3D = new Point3D();
		
		public function Emitter(attrIn:Object) {
			attr = attrIn;
			if (attr.emitter) {
				if (attr.emitter.max != undefined) max = attr.emitter.max;
				if (attr.emitter.life != undefined) life = attr.emitter.life;
				if (attr.emitter.pos != undefined) pos = attr.emitter.pos.clone();
			}
			
			particles = [];
		}
		public function free():void {
			removeAll();
			particles = null;
			attr = null;
		}
		public function add():void {
			
		}
		public function remove(id:int):void {
			if (id < 0 || !particles[id]) return;
			removeChild(particles[id]);
			particles[id].free();
			particles.splice(id, 1);
		}
		public function removeAll():void {
			for (var i:int = 0; i < particles.length; i++) {
				removeChild(particles[i]);
				particles[i].free();
			}
			particles = [];
		}
		public function update(delta:Number):void {			
			if (is_alive && particles.length < max) {
				add();
			}
			if (life >= 0) {
				life -= delta;
				if (life < 0) {
					is_alive = false;
				}
			}
		}
		public function render():void {
			
		}
		public function fireAt(p:Point3D):void {
			pos.x = p.x;
			pos.y = p.y;
			pos.z = p.z;
		}
		public function isAlive():Boolean {
			return is_alive || particles.length > 0;
		}
		public function getCount():int {
			return particles.length;
		}
	}
}