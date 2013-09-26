package karma.physic.simple2d {
	import elmortem.types.Vec2;
	import elmortem.utils.NumberUtils;
	import karma.game.Entity;
	import karma.game.GameManager;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public class Body implements IBody {
		static public const CIRCLE:int = 0;
		static public const POINT:int = 1;
		
		static public const MASS_MOD:Number = 1 / 300;
		
		protected var _physic:Physic;
		
		private var _game:GameManager;
		private var _pos:Vec2;
		private var _enabled:Boolean;
		private var _group:int;
		private var _type:int;
		private var _lastPos:Vec2;
		private var _radius:Number;
		private var _mass:Number;
		private var _velosity:Vec2;
		private var _force:Vec2;
		private var _damping:Number;
		private var _maxVelosity:Number;
		private var _isStatic:Boolean;
		private var _isSensor:Boolean;
		private var _userData:Object;
		private var _onCollide:Function;
		
		public function Body(game:GameManager) {
			_game = game;
			
			_physic = _game.getSense("physic") as Physic;
			
			_pos = new Vec2();
			_enabled = true;
			_group = -1;
			_type = CIRCLE;
			_lastPos = pos.clone();
			_radius = 10;
			_mass = 1;
			_velosity = new Vec2();
			_force = new Vec2();
			_damping = 0.5;
			_maxVelosity = Number.MAX_VALUE;
			_isStatic = false;
			_isSensor = false;
			_userData = null;
			_onCollide = null;
			
			_physic.add(this);
		}
		public function free():void {
			_physic.remove(this);
			_physic = null;
			
			_lastPos = null;
			_velosity = null;
			_force = null;
			_userData = null;
			_onCollide = null;
			
			_game = null;
		}
		
		/* INTERFACE utils.IBody */
		
		public function get pos():Vec2 {
			return _pos;
		}
		public function set pos(v:Vec2):void {
			_pos = v;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		public function set enabled(v:Boolean):void {
			_enabled = v;
		}
		
		public function get group():int {
			return _group;
		}
		public function set group(v:int):void {
			_group = v;
		}
		
		public function get type():int {
			return _type;
		}
		public function set type(v:int):void {
			_type = v;
		}
		
		public function get lastPos():Vec2 {
			return _lastPos;
		}
		public function set lastPos(v:Vec2):void {
			_lastPos.setV(v);
		}
		
		public function get mass():Number {
			return _mass;
		}
		public function set mass(v:Number):void {
			_mass = v;
		}
		public function resetMass():void {
			if (isStatic) _mass = 1;
			_mass = Math.PI * radius * radius * MASS_MOD;
		}
		
		public function get radius():Number {
			return _radius;
		}
		public function set radius(v:Number):void {
			_radius = v;
		}
		
		public function get damping():Number {
			return _damping;
		}
		public function set damping(v:Number):void {
			_damping = Math.max(0, Math.min(1, v));
		}
		
		public function get maxVelosity():Number {
			return _maxVelosity;
		}
		public function set maxVelosity(v:Number):void {
			_maxVelosity = v;
		}
		
		public function get userData():Object {
			return _userData;
		}
		public function set userData(v:Object):void {
			_userData = v;
		}
		public function set onCollide(v:Function):void {
			_onCollide = v;
		}
		
		public function applyForce(f:Vec2):void {
			if (isStatic) return;
			_force.x += f.x;
			_force.y += f.y;
		}
		
		public function applyImpulse(f:Vec2):void {
			if (isStatic) return;
			_velosity.x += f.x / _mass;
			_velosity.y += f.y / _mass;
		}
		
		public function get physic():Physic {
			return _physic;
		}
		
		public function get velosity():Vec2 {
			return _velosity;
		}
		public function set velosity(v:Vec2):void {
			_velosity.setV(v);
		}
		
		public function get force():Vec2 {
			return _force;
		}
		
		public function clearForce():void {
			_force.setXY(0, 0);
		}
		
		public function get isStatic():Boolean {
			return _isStatic;
		}
		public function set isStatic(v:Boolean):void {
			_isStatic = v;
			_physic.add(this);
		}
		public function get isSensor():Boolean {
			return _isSensor;
		}
		public function set isSensor(v:Boolean):void {
			_isSensor = v;
		}
		
		public function collide(b:IBody):Boolean {
			if (_onCollide != null) return _onCollide(b);
			return true;
		}
		
		public function update(delta:Number):void {
			if(!_isStatic) {
				// force
				_velosity.x += _force.x * _mass * delta;
				_velosity.y += _force.y * _mass * delta;
				
				var len_pow:Number = _velosity.lengthPow();
				if (len_pow > (_maxVelosity * _maxVelosity)) {
					_velosity.normalize();
					_velosity.mult(_maxVelosity);
				}
				
				_lastPos.setV(pos);
				pos.x += _velosity.x * delta;
				pos.y += _velosity.y * delta;
				
				// damping
				if (_damping < 1) {
					if(_damping > 0) {
						_velosity.x = NumberUtils.approach(10 * Math.abs(_velosity.x) * delta * (1 - _damping), _velosity.x, 0);
						_velosity.y = NumberUtils.approach(10 * Math.abs(_velosity.y) * delta * (1 - _damping), _velosity.y, 0);
					} else {
						_velosity.setXY(0, 0);
					}
				}
			}
		}
		
	}

}