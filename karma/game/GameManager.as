package karma.game {
	import karma.core.Karma;
	import karma.display.Layer;
	import karma.display.Screen;
	import karma.events.EntityEvent;
	import karma.events.KarmaEvent;
	import karma.game.cameras.ICamera;
	import karma.game.senses.ISense;
	import starling.animation.IAnimatable;
	import starling.display.Sprite;
	import starling.events.Event;

	public class GameManager implements IAnimatable {
		static private var _this:GameManager = null;
		private var _screen:Screen;
		private var _entities:Vector.<Entity>;
		private var _dead_entities:Vector.<Entity>;
		private var _alive:Boolean;
		
		private var _layers:Vector.<Layer>;
		
		private var _pause:Boolean;
		private var _camera:ICamera;
		private var _senses:Vector.<ISense>;
		private var _pre_senses:Vector.<ISense>;
		private var _post_senses:Vector.<ISense>;
		
		public var slow:Number;
		
		public function GameManager(auto:Boolean = true) {
			super();
			
			_entities = new Vector.<Entity>();
			_dead_entities = new Vector.<Entity>();
			
			_layers = new Vector.<Layer>();
			
			_pause = false;
			_camera = null;
			_senses = new Vector.<ISense>();
			_pre_senses = new Vector.<ISense>();
			_post_senses = new Vector.<ISense>();
			
			Karma.eventer.addEventListener(EntityEvent.DEAD, onDead);
			
			slow = 1;
			_alive = true;
			if(auto) Karma.juggler.add(this);
		}
		public function free():void {
			var i:uint;
			
			_alive = false;
			
			Karma.juggler.remove(this);
			
			clearEntities();
			_entities = null;
			_dead_entities = null;
			
			Karma.eventer.removeEventListener(EntityEvent.DEAD, onDead);
			
			if (_camera != null) {
				_camera.free();
				_camera = null;
			}
			
			var len:uint = _senses.length;
			for (i = 0; i < len; i++) {
				_senses[i].free();
			}
			_senses.length = 0;
			_senses = null;
			_pre_senses.length = 0;
			_pre_senses = null;
			_post_senses.length = 0;
			_post_senses = null;
			
			clearLayers();
			_layers = null;
		}
		public function clearAll():void {
			clearEntities();
			clearLayers();
		}
		
		public function clearEntities():void {
			for (var i:int = 0; i < _entities.length; i++) {
				Karma.eventer.dispatchEvent(new EntityEvent(EntityEvent.REMOVE, _entities[i]));
				if(_entities[i].alive) _entities[i].free();
			}
			_entities.length = 0;
			_dead_entities.length = 0;
		}
		public function addEntity(entity:Entity):Entity {
			if (entity == null || _entities == null) {
				trace("Entity or List is empty.");
				return null;
			}
			_entities.push(entity);
			if(entity.isFree) {
				entity.init(this);
				Karma.eventer.dispatchEvent(new EntityEvent(EntityEvent.ADD, entity));
			}
			return entity;
		}
		public function removeEntity(entity:Entity, is_free:Boolean = true):void {
			if (entity == null || _entities == null) {
				trace("Entity or List is empty.");
				return;
			}
			var idx:int = _entities.indexOf(entity);
			if(idx >= 0) {
				_entities.splice(idx, 1);
				Karma.eventer.dispatchEvent(new EntityEvent(EntityEvent.REMOVE, entity));
				if (is_free) {
					entity.free();
				}
			}
		}
		public function findEntitiesByClass(cls:Class):Vector.<Entity> {
			var list:Vector.<Entity> = new Vector.<Entity>();
			if (_entities == null) return list;
			var len:int = _entities.length;
			for(var i:int = 0; i < len; i++) {
				if(_entities[i] is cls) {
					list.push(_entities[i]);
				}
			}
			return list;
		}
		public function findEntityByName(name:String, cls:Class = null):Entity {
			if (_entities == null) return null;
			if (cls == null) cls = Entity;
			var len:int = _entities.length;
			for(var i:int = 0; i < len; i++) {
				if (_entities[i] is cls && (name == null || _entities[i].name == name)) {
					return _entities[i];
				}
			}
			return null;
		}
		public function get entities():Vector.<Entity> {
			return _entities;
		}
		
		// LAYERS
		public function createLayer(name:String, parent:Sprite = null):Layer {
			if (parent == null) parent = Karma.root as Sprite;
			var layer:Layer = new Layer(name);
			_layers.push(layer);
			parent.addChild(layer);
			return layer;
		}
		public function layerByName(name:String):Layer {
			var len:int = _layers.length;
			for (var i:int = 0; i < len; i++) {
				if (_layers[i].name == name) return _layers[i];
			}
			if (_layers.length <= 0) {
				var lyr:Layer = createLayer("default");
			}
			return _layers[_layers.length-1];
		}
		public function get layers():Vector.<Layer> {
			return _layers;
		}
		public function clearLayers():void {
			var i:int;
			for (i = 0; i < _layers.length; i++) {
				_layers[i].removeFromParent(true);
			}
		}
		
		// CAMERA
		public function get camera():ICamera {
			return _camera;
		}
		public function set camera(value:ICamera):void {
			_camera = value;
		}
		
		// SENSES
		public function addPreSense(v:ISense):void {
			if (_senses.indexOf(v) < 0) {
				_senses.push(v);
				_pre_senses.push(v);
			}
		}
		public function addPostSense(v:ISense):void {
			if (_senses.indexOf(v) < 0) {
				_senses.push(v);
				_post_senses.push(v);
			}
		}
		public function getSense(name:String):ISense {
			var len:uint = _senses.length;
			for (var i:uint = 0; i < len; i++) {
				if (_senses[i].name == name) return _senses[i];
			}
			return null;
		}
		
		// PAUSE
		public function set pause(value:Boolean):void {
			var i:int;
			var len:int = _entities.length;
			for(i = 0; i < len; i++) {
				if(_entities[i].alive) {
					_entities[i].pause(value);
				}
			}
			_pause = value;
		}
		public function get pause():Boolean {
			return _pause;
		}
		
		// UPDATE
		private function update(delta:Number):void {
			var i:int;
			var len:int;
			
			len = _pre_senses.length;
			for(i = 0; i < len; i++) {
				_pre_senses[i].update(delta);
			}
			
			if (!_pause) {
				
				len = _entities.length;
				for(i = 0; i < len; i++) {
					if(_entities[i].alive) {
						_entities[i].update(delta);
						if (_entities == null) return;
					}
				}
				
			}
			
			len = _post_senses.length;
			for(i = 0; i < len; i++) {
				_post_senses[i].update(delta);
			}
			
			if (_camera != null) {
				_camera.update(delta);
			}
			
			// dead list
			if (_dead_entities.length > 0) {
				len = _dead_entities.length;
				for(i = 0; i < len; i++) {
					removeEntity(_dead_entities[i]);
				}
				_dead_entities.length = 0;
			}
		}
		
		public function advanceTime(time:Number):void {
			if (!_alive) return;
			if (time > 0.1) time = 0.1;
			update(time * slow);
		}
		
		private function onDead(e:EntityEvent):void {
			if (_dead_entities == null) return;
			_dead_entities.push(e.entity);
		}
	}
}