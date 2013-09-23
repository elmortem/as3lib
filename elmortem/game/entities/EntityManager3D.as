package elmortem.game.entities {
	import elmortem.game.Simulation3D;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class EntityManager3D extends EventDispatcher {
		static private var cash:Dictionary = new Dictionary();
		
		private var sim:Simulation3D;
		private var list:Vector.<Entity3D>;
		private var listDead:Vector.<Entity3D>;
		
		public function EntityManager3D(sim:Simulation3D) {
			super();
			this.sim = sim;
			list = new Vector.<Entity3D>();
			listDead = new Vector.<Entity3D>();
		}
		public function free():void {
			clear();
			list = null;
			listDead = null;
		}
		public function clear():void {
			for (var i:int = 0; i < list.length; i++) {
				list[i].free();
			}
			list.splice(0, list.length);
			listDead.splice(0, listDead.length);;
		}
		public function add(entity:Entity3D):Entity3D {
			if (entity == null || list == null) {
				trace("Entity or List is empty.");
				return null;
			}
			list.push(entity);
			entity.init(sim);
			entity.addEventListener(EntityEvent3D.DEAD, onDead);
			dispatchEvent(new EntityEvent3D(entity, EntityEvent3D.ADD));
			return entity;
		}
		public function remove(entity:Entity3D):void {
			if (entity == null || list == null) {
				trace("Entity or List is empty.");
				return;
			}
			var id:int = list.indexOf(entity);
			if(id >= 0) {
				list.splice(id, 1);
				dispatchEvent(new EntityEvent3D(entity, EntityEvent3D.REMOVE));
				entity.free();
			}
		}
		public function findEntitiesByClass(cls:Class):/*Entity*/Array {
			var arr:/*Entity*/Array = [];
			if (list == null) return arr;
			for(var i:int = 0; i < list.length; i++) {
				if(list[i] is cls) {
					arr.push(list[i]);
				}
			}
			return arr;
		}
		public function findEntityByName(name:String, cls:Class = null):Entity3D {
			if (list == null) return null;
			if(cls == null) cls = Entity;
			for(var i:int = 0; i < list.length; i++) {
				if(list[i] is cls && list[i].name == name) {
					return list[i];
				}
			}
			return null;
		}
		
		public function update(delta:Number):void {
			var i:int;
			for(i = 0; i < list.length; i++) {
				if(list[i].alive) {
					list[i].update(delta);
				}
			}
			
			// dead list
			if (listDead.length > 0) {
				for(i = 0; i < listDead.length; i++) {
					remove(listDead[i]);
				}
				listDead.splice(0, listDead.length);
			}
		}
		public function render():void {
			for(var i:int = 0; i < list.length; i++) {
				list[i].render();
			}
		}
		
		public function onDead(e:EntityEvent3D):void {
			if (listDead == null) return;
			listDead.push(e.entity);
		}
	}
}