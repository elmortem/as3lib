package elmortem.types {
	import elmortem.utils.AngleUtils;
	import flash.geom.Point;

	public class Vec2 {
		static public var SIN:Array = null;
		static public var COS:Array = null;
		
		static public const ZERO:Vec2 = new Vec2();
		
		public var x:Number;
		public var y:Number;
		public var cached:Boolean;

		public function Vec2(x:Number = 0, y:Number = 0, cached:Boolean = false) {
			if (SIN == null || COS == null) {
				SIN = [];
				COS = [];
				for (var i:int = 0; i < 360; i++) {
					SIN[i] = Math.sin(AngleUtils.toRad(i));
					COS[i] = Math.cos(AngleUtils.toRad(i));
					//trace("sin(" + i + ")=" + SIN[i] + " | cos(" + i + ")=" + COS[i]);
				}
			}
			this.x = isNaN(x)?0:x;
			this.y = isNaN(y)?0:y;
			this.cached = cached;
		}
		public function copy():Vec2 {
			return new Vec2(x, y, cached);
		}
		public function clone():Vec2 {
			return copy();
		}
		public function setXY(x:Number, y:Number):void {
			this.x = x; this.y = y;
		}
		public function setP(p:Point):void {
			this.x = p.x; this.y = p.y;
		}
		public function setV(v:Vec2):void {
			x = v.x; y = v.y;
		}
		
		public function equal(v:Vec2, diff:Number = 0):Boolean {
			if(diff == 0) return (x == v.x && y == v.y);
			return Math.abs(x - v.x) <= diff && Math.abs(y - v.y) <= diff;
		}
		
		public function add(v:Vec2):void{
			x += v.x; y += v.y;
		}
		public function sub(v:Vec2):void{
			x -= v.x; y -= v.y;
		}
		public function mult(a:Number):void{
			x *= a; y *= a;
		}
		public function normalize():Number{
			var length:Number = Math.sqrt(x * x + y * y);
			if(length > 0) {
				var invLength:Number = 1.0 / length;
				x *= invLength;
				y *= invLength;
			}
			
			return length;
		}
		
		// utils
		public function move(dist:Number, angle:Number):void {
			if(!cached) {
				moveRad(dist, AngleUtils.toRad(angle));
			} else {
				x = x + SIN[int(AngleUtils.normal(angle))] * dist;
				y = y - COS[int(AngleUtils.normal(angle))] * dist;
			}
		}
		public function moveRad(dist:Number, angle:Number):void {
			if(!cached) {
				x = x + Math.sin(angle) * dist;
				y = y - Math.cos(angle) * dist;
			} else {
				move(dist, AngleUtils.toDeg(angle));
			}
		}
		public function moveTo(dist:Number, to:Vec2, is_stop:Boolean = true):void {
			if(is_stop) {
				var dst:Number = distancePowTo(to);
				if(dst < dist*dist) {
					x = to.x; y = to.y;
				} else {
					move(dist, angleTo(to));
				}
			} else {
				move(dist, angleTo(to));
			}
		}
		
		public function rotate(ang:Number):void {
			var len:Number = length();
			var a:Number = angle();
			a = AngleUtils.normal(a + ang);
			x = 0; y = 0;
			move(len, a);
		}
		public function rotateFromPivot(pivot:Vec2, ang:Number):void {
			//x' = x0+(x-x0)*cos(A)+(y0-y)*sin(alpha);
			//y' = y0+(x-x0)*sin(A)+(y-y0)*cos(alpha);
		}
		
		public function angleTo(v:Vec2):Number {
			return AngleUtils.normal(AngleUtils.toDeg(Math.atan2(v.y - y, v.x - x)) + 90);
		}
		public function angle():Number {
			return AngleUtils.normal(AngleUtils.toDeg(Math.atan2(y, x)) + 90);
		}
		public function angleToRad(v:Vec2):Number {
			return AngleUtils.normalRad(Math.atan2(v.y - y, v.x - x) + Math.PI * 0.5);
		}
		public function angleRad():Number {
			return AngleUtils.normalRad(Math.atan2(y, x) + Math.PI * 0.5);
		}
		public function distanceTo(v:Vec2):Number {
			return Math.sqrt((v.x - x) * (v.x - x) + (v.y - y) * (v.y - y));
		}
		public function distancePowTo(v:Vec2):Number {
			return (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y);
		}
		public function length():Number {
			return Math.sqrt(x * x + y * y);
		}
		public function lengthPow():Number {
			return x * x + y * y;
		}
		
		public function inTriangleV(a:Vec2, b:Vec2, c:Vec2):Boolean {
			return inTriangleXY(a.x, a.y, b.x, b.y, c.x, c.y);
		}
		public function inTriangleP(a:Point, b:Point, c:Point):Boolean {
			return inTriangleXY(a.x, a.y, b.x, b.y, c.x, c.y);
		}
		public function inTriangleXY(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number):Boolean {
			// Вершины должны быть заданы против часовой стрелки
			if ((x - ax) * (ay - by) - (y - ay) * (ax - bx) >= 0)
				if ((x - bx) * (by - cy) - (y - by) * (bx - cx) >= 0)
					if ((x - cx) * (cy - ay) - (y - cy) * (cx - ax) >= 0)
						return true;
			return false;
		}
		static public function lineIntersect(a1:Vec2, a2:Vec2, b1:Vec2, b2:Vec2, point:Vec2 = null):Boolean {
			if(point == null) point = new Vec2();
			
			var d:Number = (a1.x - a2.x) * (b2.y - b1.y) - (a1.y - a2.y) * (b2.x - b1.x); 
			var da:Number = (a1.x - b1.x) * (b2.y - b1.y) - (a1.y - b1.y) * (b2.x - b1.x);
			var db:Number = (a1.x - a2.x) * (a1.y - b1.y) - (a1.y - a2.y) * (a1.x - b1.x);
			
			if (Math.abs(d) < 0.000001) {
				return false;
			} else {
				var ta:Number = da / d;
				var tb:Number = db / d;
				if ((0 <= ta) && (ta <= 1) && (0 <= tb) && (tb <= 1)) {
					point.x = a1.x + ta * (a2.x - a1.x);
					point.y = a1.y + ta * (a2.y - a1.y);
					return true;
				} 
			}
			return false;
		}
		static public function lineCircleIntersect(v1:Vec2, v2:Vec2, c:Vec2, r:Number, p1:Vec2 = null, p2:Vec2 = null):Boolean {
			var k:Number;
			var b:Number;
			var d:Number;
			var d1:Number;
			var d2:Number;
			var xx:Number;
			var yy:Number;
			var rx1:Number;
			var ry1:Number;
			var rx2:Number;
			var ry2:Number;
			
			//сдвигаем все на координаты круга
			v1.sub(c);
			v2.sub(c);
			
			var res:Boolean = true;
			var res1:Boolean = true;
			var res2:Boolean = true;
			if(p1 == null) p1 = new Vec2();
			if(p2 == null) p2 = new Vec2();
			
			//если первый отрезок вертикальный
			if (int(v1.x) == int(v2.x)) {
				d = r * r - v1.x * v1.x;
				if (d < 0) {
					res = false;
					res1 = false;
					res2 = false;
				} else {
					ry1 = Math.sqrt(d);
					ry2 = -ry1;
					p1.x = v1.x + c.x;
					p1.y = ry1 + c.y;
					p2.x = v2.x + c.x;
					p2.y = ry2 + c.y;
				}
			} else {
				//параметры первого отрезка
				k = (v1.y - v2.y) / (v1.x - v2.x);
				b = v1.y - k * v1.x;
				
				d = k * k * b * b - (k * k + 1) * (b * b - r * r);
				if (d < 0) {
					res = false;
					res1 = false;
					res2 = false;
				} else {
					d = Math.sqrt(d);
					rx1 = (-k * b + d) / (k * k + 1);
					rx2 = (-k * b - d) / (k * k + 1);
					ry1 = k * rx1 + b;
					ry2 = k * rx2 + b;
					p1.x = rx1 + c.x;
					p1.y = ry1 + c.y;
					p2.x = rx2 + c.x;
					p2.y = ry2 + c.y;
				}
			}
			
			v1.add(c);
			v2.add(c);
			
			//осталось отсортировать по близости к (x1, y1)
			if (res) {
				d1 = (p1.x - v1.x) * (p1.x - v1.x) + (p1.y - v1.y) * (p1.y - v1.y);
				d2 = (p2.x - v1.x) * (p2.x - v1.x) + (p2.y - v1.y) * (p2.y - v1.y);
				if (d2 < d1) {
					rx1 = p1.x;
					p1.x = p2.x;
					p2.x = rx1;
					ry1 = p1.y;
					p1.y = p2.y;
					p2.y = ry1;
				}
			}
			
			//и еще нужно проверить что попадаем в отрезок
			if (res) {
				if (v1.x > v2.x) {
					xx = v1.x;
					v1.x = v2.x;
					v2.x = xx;
				}
				if (v1.y > v2.y) {
					yy = v1.y;
					v1.y = v2.y;
					v2.y = yy;
				}
				if (p1.x < v1.x || p1.x > v2.x || p1.y < v1.y || p1.y > v2.y) {
					p1.x = 0;
					p1.y = 0;
					res1 = false;
				}
				if (p2.x < v1.x || p2.x > v2.x || p2.y < v1.y || p2.y > v2.y) {
					p2.x = 0;
					p2.y = 0;
					res2 = false;
				}
			}
			
			return res1 || res2;
		}
		
		static public function circleBySegment(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, radius:Number):Boolean {
			var a:Number = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
			var b:Number = 2 * ((x2 - x1) * (x1 - x3) + (y2 - y1) * (y1 - y3));
			var c:Number = x3 * x3  + y3 * y3 + x1 * x1 + y1 * y1 - 2 * (x3 * x1 + y3 * y1) - radius * radius;

			//т.е. если если есть отрицательные корни, то пересечение есть. анализируем теорему виета и формулу корней
			//на предмет отрицательных корней
			if ( - b < 0) {
				return (c < 0);
			}
			if ( - b < (2 * a)){
				return (4 * a * c - b * b < 0);
			}
			return (a + b + c < 0);
		}
		
		public function toString():String {
			return "[Vec2 x=" + x + ", y=" + y + "]";
		}
	}
}