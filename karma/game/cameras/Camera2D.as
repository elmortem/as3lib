package karma.game.cameras {
	import elmortem.types.Vec2;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import karma.core.Karma;
	import karma.display.Layer;
	import karma.display.Screen;
	import karma.game.Entity;
	import karma.game.GameManager;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public class Camera2D implements ICamera {
		static public const NONE:int = 0;
		
		private var _game:GameManager;
		private var _width:int;
		private var _height:int;
		
		private var _target:Entity;
		private var _type:int;
		private var _pos:Vec2;
		private var _rect:Rectangle;
		private var _offset:Vec2;
		private var _auto:Boolean;
		private var _zoomLayer:Layer;
		
		
		public function Camera2D(game:GameManager, auto:Boolean = false, zoomLayer:Layer = null) {
			_game = game;
			_auto = auto;
			_zoomLayer = zoomLayer;
			if(_zoomLayer != null) {
				_zoomLayer.scrollFactorX = _zoomLayer.scrollFactorY = 0;
			}
			_width = Karma.width;
			_height = Karma.height;
			
			_target = null;
			_type = NONE;
			_pos = new Vec2();
			_rect = null;// new Rectangle();
			_offset = new Vec2(_width * 0.5, _height * 0.5);
		}
		
		public function free():void {
			_game = null;
			_target = null;
			_pos = null;
			_rect = null;
			_offset = null;
		}
		
		public function update(delta:Number):void {
			if (_type == NONE) {
				if (_target != null) {
					_pos.x = (_pos.x + _target.pos.x) * 0.5;
					_pos.y = (_pos.y + _target.pos.y) * 0.5;
					//_pos.setV(_target.pos);
					convert(_pos);
				}
			}
			
			if (_auto) {
				var list:Vector.<Layer> = _game.layers;
				var len:int = list.length;
				for (var i:int = 0; i < len; i++) {
					if (list[i] != _zoomLayer) {
						if(_zoomLayer != null) {
							list[i].x = int(-x);
							list[i].y = int(-y);
						} else {
							list[i].x = int(-x + _offset.x);
							list[i].y = int(-y + _offset.y);
						}
					}
				}
			}
		}
		
		public function get target():Entity {
			return _target;
		}
		public function set target(v:Entity):void {
			_target = v;
		}
		public function get type():int {
			return _type;
		}
		public function set type(v:int):void {
			_type = v;
		}
		public function get bounds():Rectangle {
			return _rect;
		}
		public function set bounds(v:Rectangle):void {
			_rect = v.clone();
			convert(_pos);
		}
		public function get x():int {
			return _pos.x;
		}
		public function set x(v:int):void {
			_pos.x = v;
			convert(_pos);
		}
		public function get y():int {
			return _pos.y;
		}
		public function set y(v:int):void {
			_pos.y = v;
			convert(_pos);
		}
		public function get zoom():Number {
			if (_zoomLayer != null) return _zoomLayer.scaleX;
			return 1;
		}
		public function set zoom(v:Number):void {
			if (_zoomLayer != null) _zoomLayer.scaleX = _zoomLayer.scaleY = v;
		}
		public function get angle():Number {
			if (_zoomLayer != null) return _zoomLayer.rotation;
			return 0;
		}
		public function set angle(v:Number):void {
			if (_zoomLayer != null) _zoomLayer.rotation = v;
		}
		public function set offsetX(v:Number):void {
			if (_zoomLayer != null) {
				_zoomLayer.scrollFactorX = 0;
				_zoomLayer.offsetX = v;
				_zoomLayer.x = 0;
			}
			_offset.x = v;
			//convert(_pos);
		}
		public function get offsetX():Number {
			return _offset.x;
		}
		public function set offsetY(v:Number):void {
			if (_zoomLayer != null) {
				_zoomLayer.scrollFactorY = 0;
				_zoomLayer.offsetY = v;
				_zoomLayer.y = 0;
			}
			_offset.y = v;
			//convert(_pos);
		}
		public function get offsetY():Number {
			return _offset.y;
		}
		public function get auto():Boolean {
			return _auto;
		}
		public function set auto(v:Boolean):void {
			_auto = v;
		}
		
		public function startPoint(x:Number, y:Number):void {
			_pos.setXY(x, y);
			convert(_pos);
		}
		
		public function convert(v:Vec2):void {
			if (_rect == null) return;
			
			v.x = Math.max(_rect.left + _offset.x, v.x);
			v.x = Math.min(_rect.right - _offset.x, v.x);
			v.y = Math.max(_rect.top + _offset.y, v.y);
			v.y = Math.min(_rect.bottom - _offset.y, v.y);
			
			/*v.x = Math.max(_rect.left, v.x);
			v.x = Math.min(_rect.right, v.x);
			v.y = Math.max(_rect.top, v.y);
			v.y = Math.min(_rect.bottom, v.y);*/
		}
		
		
		
		public function screenToCamera(x:Number, y:Number, v:Vec2 = null):Vec2 {
			if (_zoomLayer != null) {
				var p:Point = _zoomLayer.globalToLocal(new Point(x, y));
				x = p.x;// + _offset.x;
				y = p.y;// + _offset.y;
			} else {
				x -= _offset.x;
				y -= _offset.y;
			}
			
			x += Starling.current.viewPort.x;
			y += Starling.current.viewPort.y;
			if (v == null) {
				v = new Vec2(x, y);
			} else {
				v.setXY(x, y);
			}
			v.x += _pos.x;// - _offset.x;
			v.y += _pos.y;// - _offset.y;
			
			return v;
		}
		public function cameraToScreen(x:Number, y:Number, v:Vec2 = null):Vec2 {
			if (v == null) {
				v = new Vec2(x, y);
			} else {
				v.setXY(x, y);
			}
			v.x -= _pos.x /*- _offset.x*/ - Starling.current.viewPort.x;
			v.y -= _pos.y /*- _offset.y*/ - Starling.current.viewPort.y;
			
			if (_zoomLayer != null) {
				var p:Point = _zoomLayer.localToGlobal(new Point(v.x/* - _offset.x*/, v.y/* - _offset.y*/));
				v.x = p.x;
				v.y = p.y;
			} else {
				v.x -= _offset.x;
				v.y -= _offset.y;
			}
			
			return v;
		}
	}

}