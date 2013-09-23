package elmortem.game.entities {
	import elmortem.game.Simulation;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class EntityManager extends EventDispatcher {
		static private var cash:Dictionary = new Dictionary();
		
		private var sim:Simulation;
		private var list:Vector.<Entity>;
		private var dead_list:Vector.<Entity>;
		
		private var isEventInClear:Boolean = false;
		
		public function EntityManager(sim:Simulation) {
			super();
			
			this.sim = sim;
			list = new Vector.<Entity>();
			dead_list = new Vector.<Entity>();
		}
		public function free():void {
			clear();
			list = null;
			dead_list.length = 0;
			dead_list = null;
		}
		public function clear():void {
			for (var i:int = 0; i < list.length; i++) {
				if(isEventInClear) dispatchEvent(new EntityEvent(list[i], EntityEvent.REMOVE));
				if(list[i].alive) list[i].free();
			}
			list.length = 0;
			dead_list.length = 0;
		}
		public function add(entity:Entity):Entity {
			if (entity == null || list == null) {
				trace("Entity or List is empty.");
				return null;
			}
			list.push(entity);
			if(entity.isFree) {
				entity.init(sim);
				entity.addEventListener(EntityEvent.DEAD, onDead);
				dispatchEvent(new EntityEvent(entity, EntityEvent.ADD));
			}
			return entity;
		}
		public function remove(entity:Entity, is_free:Boolean = true):void {
			if (entity == null || list == null) {
				trace("Entity or List is empty.");
				return;
			}
			var idx:int = list.indexOf(entity);
			if(idx >= 0) {
				list.splice(idx, 1);
				if(is_free) {
					dispatchEvent(new EntityEvent(entity, EntityEvent.REMOVE));
					entity.free();
				}
			}
		}
		public function findEntitiesByClass(cls:Class):/*Entity*/Array {
			var arr:/*Entity*/Array = [];
			if (list == null) return arr;
			var len:int = list.length;
			for(var i:int = 0; i < len; i++) {
				if(list[i] is cls) {
					arr.push(list[i]);
				}
			}
			return arr;
		}
		public function findEntityByName(name:String, cls:Class = null):Entity {
			if (list == null) return null;
			if (cls == null) cls = Entity;
			var len:int = list.length;
			for(var i:int = 0; i < len; i++) {
				if (list[i] is cls && (name == null || list[i].name == name)) {
					return list[i];
				}
			}
			return null;
		}
		
		public function getList():Vector.<Entity> {
			return list;
		}
		
		public function update(delta:Number):void {
			var i:int;
			var len:int = list.length;
			for(i = 0; i < len; i++) {
				if(list[i].alive && list[i].isProcessingRule(Entity.PROCESSING_UPDATE)) {
					list[i].update(delta);
				}
			}
			
			// dead list
			if (dead_list.length > 0) {
				len = dead_list.length;
				for(i = 0; i < len; i++) {
					remove(dead_list[i]);
				}
				dead_list.length = 0;
			}
		}
		public function render():void {
			var len:int = list.length;
			for(var i:int = 0; i < len; i++) {
				if (list[i].isProcessingRule(Entity.PROCESSING_RENDER)) {
					list[i].render();
				}
			}
		}
		public function pause(value:Boolean):void {
			var i:int;
			var len:int = list.length;
			for(i = 0; i < len; i++) {
				if(list[i].alive && list[i].isProcessingRule(Entity.PROCESSING_UPDATE)) {
					list[i].pause(value);
				}
			}
		}
		
		public function onDead(e:EntityEvent):void {
			if (dead_list == null) return;
			dead_list.push(e.entity);
		}
	}
}