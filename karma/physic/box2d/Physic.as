package karma.physic.box2d {
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import elmortem.types.Vec2;
	import elmortem.utils.AngleUtils;
	import flash.display.Sprite;
	import karma.game.senses.ISense;
	
	public class Physic implements ISense {
		private var _ratio:Number = 40;
		private var _antiRatio:Number = 1 / 40;
		public var fps:Number = 30;
		public var velocityIterations:int = 10;
		public var positionIterations:int = 10;
		public var world:b2World = null;
		public var debugSprite:Sprite = null;
		
		public function Physic(attrIn:Object) {
			_ratio = (attrIn.ratio != null)?attrIn.ratio:_ratio;
			_antiRatio = 1 / _ratio;
			fps = (attrIn.fps != null)?attrIn.fps:fps;
			
			var gravity:b2Vec2 = new b2Vec2(attrIn.gravityX, attrIn.gravityY);
			world = new b2World(gravity, attrIn.doSleep);
			
			if (attrIn.contactListener != null) {
				world.SetContactListener(attrIn.contactListener);
			}
			if (attrIn.contactFilter != null) {
				world.SetContactFilter(attrIn.contactFilter);
			}
			
			//world.SetContinuousPhysics(false);
			//world.SetWarmStarting(true);
			
			debugSprite = attrIn.debugSprite;
			if (debugSprite != null) {
				var debugDraw:b2DebugDraw = new b2DebugDraw();
				debugDraw.SetSprite(debugSprite);
				debugDraw.SetDrawScale(_ratio);
				debugDraw.SetFillAlpha(0.3);
				debugDraw.SetLineThickness(1.0);
				debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
				world.SetDebugDraw(debugDraw);
				world.DrawDebugData();
			}
		}
		public function free():void {
			world.SetContactListener(null);
			world.SetContactFilter(null);
			world = null;
		}
		
		public function get name():String {
			return "physic";
		}
		public function get ratio():Number {
			return _ratio;
		}
		public function get antiRatio():Number {
			return _antiRatio;
		}
		
		public function update(delta:Number):void {
			world.Step(delta, velocityIterations, positionIterations);
			world.ClearForces();
			
			world.DrawDebugData();
		}
		
		public function createBox(x:Number, y:Number, width:Number, height:Number, angle:Number = 0, type:uint = 2/*b2Body.b2_dynamicBody*/, density:Number = 1, friction:Number = 0.5, restitution:Number = 0.3):b2Body {
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsBox(width * 0.5 / _ratio, height * 0.5 / _ratio);
			fixtureDef.shape = shape;
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(x / _ratio, y / _ratio);
			bodyDef.type = type;
			bodyDef.angle = angle;
			
			var body:b2Body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			body.ResetMassData();
			
			return body;
		}
		public function createTriangle(x:Number, y:Number, vertixes:Array, isDynamic:Boolean = true, density:Number = 1, friction:Number = 0.5, restitution:Number = 0.3):b2Body {
			var b:b2Body = createBody(x, y, false, (isDynamic)?b2Body.b2_dynamicBody:b2Body.b2_staticBody, false);
			createFixtureTriangle(b, vertixes, density, friction, restitution);
			b.ResetMassData();
			return b;
		}
		public function createBall(x:Number, y:Number, radius:Number, type:int = 2, density:Number = 1, friction:Number = 0.5, restitution:Number = 0.3):b2Body {
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			var shape:b2CircleShape = new b2CircleShape();
			shape.SetRadius(radius / _ratio);
			fixtureDef.shape = shape;
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(x / _ratio, y / _ratio);
			bodyDef.type = type;
			
			var body:b2Body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			body.ResetMassData();
			
			return body;
		}
		
		public function createBody(x:Number, y:Number, bullet:Boolean, type:uint, fixedRotation:Boolean, linearDamping:Number = 0.01, angularDamping:Number = 0.01):b2Body {
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(x / _ratio, y / _ratio);
			bodyDef.bullet = bullet;
			bodyDef.type = type;
			bodyDef.fixedRotation = fixedRotation;
			bodyDef.allowSleep = false;
			//bodyDef.inertiaScale = 0.5;
			bodyDef.linearDamping = linearDamping;
			bodyDef.angularDamping = angularDamping;
			return world.CreateBody(bodyDef);
		}
		public function createFixtureCircle(body:b2Body, radius:Number, density:Number, friction:Number, restitution:Number, sensor:Boolean = false):b2Fixture {
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			fixtureDef.shape = new b2CircleShape(radius / _ratio);
			fixtureDef.isSensor = sensor;
			return body.CreateFixture(fixtureDef);
		}
		public function createFixtureBox(body:b2Body, x:Number, y:Number, hw:Number, hh:Number, density:Number, friction:Number, restitution:Number, sensor:Boolean = false):b2Fixture {
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			fixtureDef.shape = new b2PolygonShape();
			fixtureDef.isSensor = sensor;
			(fixtureDef.shape as b2PolygonShape).SetAsOrientedBox(hw / _ratio, hh / _ratio, new b2Vec2(x / _ratio, y / _ratio));
			return body.CreateFixture(fixtureDef);
		}
		public function createFixtureTriangle(body:b2Body, vertexes:Array, density:Number, friction:Number, restitution:Number):b2Fixture {
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			fixtureDef.shape = new b2PolygonShape();
			var vertices:Array = [];
			for (var i:int = 0; i < 3; i++) {
				vertices.push(new b2Vec2(vertexes[i][0] / _ratio, vertexes[i][1] / _ratio));
			}
			(fixtureDef.shape as b2PolygonShape).SetAsArray(vertices, 3);
			return body.CreateFixture(fixtureDef);
		}
		
		public function getBodyAtV(v:Vec2, size:Number = 0.001, includeStatic:Boolean = false):Array/*b2Body*/ {
			return getBodyAtXY(v.x, v.y, size, includeStatic);
		}
		public function getBodyAtXY(x:Number, y:Number, size:Number = 0.001, includeStatic:Boolean = false):Array/*b2Body*/ {
			// Make a small box.
			var v:b2Vec2 = new b2Vec2(x / _ratio, y / _ratio);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(v.x - size, v.y - size);
			aabb.upperBound.Set(v.x + size, v.y + size);
			var bodies:Array/*b2Body*/ = [];
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean {
				var shape:b2Shape = fixture.GetShape();
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic) {
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), v);
					if (inside) {
						bodies.push(fixture.GetBody());
						return true;
					}
				}
				return true;
			}
			world.QueryAABB(GetBodyCallback, aabb);
			return bodies;
		}
		public function getBodiesAtXY(x:Number, y:Number, size:Number = 0.001, includeStatic:Boolean = false):Array/*b2Body*/ {
			// Make a small box.
			var v:b2Vec2 = new b2Vec2(x / _ratio, y / _ratio);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(v.x - size, v.y - size);
			aabb.upperBound.Set(v.x + size, v.y + size);
			var bodies:Array/*b2Body*/ = [];
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean {
				var shape:b2Shape = fixture.GetShape();
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic) {
					bodies.push(fixture.GetBody());
					return true;
				}
				return true;
			}
			world.QueryAABB(GetBodyCallback, aabb);
			return bodies;
		}
		
		public function RayCastArrayPoint(point1:b2Vec2, point2:b2Vec2):Array/*[b2Fixture,b2Vec2]*/ {
			var result:Array/*b2Fixture*/ = [];
			function RayCastAllWrapper(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number {
				//!!!???
				//var point:b2Vec2 = new b2Vec2((1.0 - fraction) * point1.x + fraction * point2.x, (1.0 - fraction) * point1.y + fraction * point2.y);
				result[result.length] = [fixture, point];      
				return 1;
			}
			world.RayCast(RayCastAllWrapper, point1, point2);
			return result;
		}
		
		public function getValue(name:String):Object {
			return null;
		}
		public function setValue(name:String, value:Object):void {
		}
	}
}