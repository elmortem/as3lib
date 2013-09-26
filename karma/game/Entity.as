package karma.game {
	import elmortem.types.Vec2;
	import flash.geom.Rectangle;
	import karma.core.Karma;
	import karma.events.EntityEvent;
	
	public class Entity {
		static private var _ids:uint = 0;
		private var _id:uint;
		private var _name:String;
		private var _alive:Boolean;
		private var _game:GameManager;
		private var _pos:Vec2;
		private var _free:Boolean;
		private var _caching:Boolean;
		
		public var attr:Object;
		
		public function Entity() {
			_game = null;
			_pos = new Vec2();
			_alive = false;
			_free = true;
			_caching = false;
		}
		public function setAttr(attr:Object):Entity {
			this.attr = attr;
			_id = ++_ids;
			_name = (attr.name != null)?attr.name:"entity" + _id;
			_alive = true;
			_pos.setXY(attr.x, attr.y);
			
			return this;
		}
		public function init(game:GameManager):void {
			_free = false;
			_game = game;
		}
		public function free():void {
			attr = null;
			_name = null;
			_id = 0;
			_game = null;
			_alive = false;
			_free = true;
		}
		public function die():void {
			if(!_alive) return;
			_alive = false;
			Karma.eventer.dispatchEventNow(new EntityEvent(EntityEvent.DEAD, this));
		}
		public function update(delta:Number):void {
		}
		public function pause(value:Boolean):void {
		}
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		public function get alive():Boolean { return _alive && !_free; }
		public function get game():GameManager { return _game; }
		public function get pos():Vec2 { return _pos; }
		public function set pos(value:Vec2):void { _pos.setV(value); }
		public function get isFree():Boolean { return _free; }
		public function get caching():Boolean { return _caching; }
		public function set caching(value:Boolean):void { _caching = value; }
	}
}