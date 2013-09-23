package elmortem.game.entities {
	import elmortem.game.Simulation3D;
	import elmortem.types.Vec3;
	import flash.events.EventDispatcher;
	
	public class Entity3D extends EventDispatcher {
		static private var _ids:uint = 0;
		private var pId:uint;
		private var pName:String;
		private var pAlive:Boolean;
		private var pSim:Simulation3D = null;
		public var attr:Object;
		public var pos:Vec3;
		
		public function Entity3D() {
		}
		public function setAttr(attr:Object):Entity3D {
			this.attr = attr;
			pId = ++_ids;
			pName = (attr.name != null)?attr.name:"entity" + pId;
			pAlive = true;
			pos = new Vec3(attr.x, attr.y, attr.z);
			
			return this;
		}
		public function init(sim:Simulation3D):void {
			pSim = sim;
		}
		public function free():void {
			attr = null;
			pName = null;
			pId = 0;
			pSim = null;
			pos = null;
		}
		public function die():void {
			if(!pAlive) return;
			pAlive = false;
			sim.eventer.add(this, new EntityEvent3D(this, EntityEvent3D.DEAD));
		}
		public function update(delta:Number):void {
		}
		public function render():void {
		}
		
		public function get id():uint { return pId; }
		public function get name():String { return pName; }
		public function get alive():Boolean { return pAlive; }
		public function get sim():Simulation3D { return pSim; }
		//public function set sim(val:Simulation):void { pSim = val; }
	}
}