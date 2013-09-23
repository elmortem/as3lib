package elmortem.game.entities {
	import elmortem.game.Simulation;
	import elmortem.managers.EventManager;
	import elmortem.types.Vec2;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	public class Entity extends EventDispatcher {
		static public const PROCESSING_UPDATE:uint = 1;
		static public const PROCESSING_RENDER:uint = 2;
		static private var _ids:uint = 0;
		private var _id:uint;
		private var _name:String;
		private var _alive:Boolean;
		private var _sim:Simulation;
		private var _pos:Vec2;
		private var _free:Boolean;
		private var _caching:Boolean;
		
		protected var _rect:Rectangle;
		private var _processingRules:uint;
		
		public var attr:Object;
		
		public function Entity() {
			_sim = null;
			_pos = new Vec2();
			_alive = false;
			_free = true;
			_caching = false;
			_rect = new Rectangle();
			_processingRules = PROCESSING_UPDATE | PROCESSING_RENDER;
		}
		public function setAttr(attr:Object):Entity {
			this.attr = attr;
			_id = ++_ids;
			_name = (attr.name != null)?attr.name:"entity" + _id;
			_alive = true;
			_pos.setXY(attr.x, attr.y);
			
			return this;
		}
		public function init(sim:Simulation):void {
			_free = false;
			_sim = sim;
		}
		public function free():void {
			attr = null;
			_name = null;
			_id = 0;
			_sim = null;
			_alive = false;
			_free = true;
		}
		public function die():void {
			if(!_alive) return;
			_alive = false;
			dispatchEvent(new EntityEvent(this, EntityEvent.DEAD));
		}
		public function update(delta:Number):void {
		}
		public function render():void {
		}
		public function pause(value:Boolean):void {
		}
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		public function get alive():Boolean { return _alive && !_free; }
		public function get sim():Simulation { return _sim; }
		//public function set sim(val:Simulation):void { pSim = val; }
		public function get pos():Vec2 { return _pos; }
		public function set pos(value:Vec2):void { _pos = value; }
		public function get isFree():Boolean { return _free; }
		public function get caching():Boolean { return _caching; }
		public function set caching(value:Boolean):void { _caching = value; }
		public function get rect():Rectangle { return _rect; }
		public function setProcessingRule(rule:uint, value:Boolean):void {
			if (value) _processingRules |= rule;
			else _processingRules &= ~rule;
		}
		public function isProcessingRule(rule:uint):Boolean {
			return ((_processingRules & rule) == rule);
		}
	}
}