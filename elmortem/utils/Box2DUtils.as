package elmortem.utils {
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import elmortem.types.Vec2;
	
	public class Box2DUtils {
		
		static public function getNormalAngle(fixture:b2Fixture, contact:b2Contact):Number {
			var wM:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(wM);
			var norm:Vec2 = new Vec2(wM.m_normal.x, wM.m_normal.y);
			if (fixture == contact.GetFixtureA()) {
				norm.mult(-1);
			}
			return AngleUtils.normal(norm.angle());
		}
	}
}