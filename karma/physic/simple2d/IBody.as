package karma.physic.simple2d {
	import elmortem.types.Vec2;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public interface IBody {
		function get group():int;
		function get type():int;
		function get pos():Vec2;
		function set pos(v:Vec2):void;
		function get enabled():Boolean;
		function set enabled(v:Boolean):void;
		function get lastPos():Vec2;
		function get mass():Number;
		function get radius():Number;
		function get damping():Number;
		function applyForce(f:Vec2):void;
		function applyImpulse(f:Vec2):void;
		function get velosity():Vec2;
		function get isStatic():Boolean;
		function get isSensor():Boolean;
		function get userData():Object;
		function collide(b:IBody):Boolean;
		function update(delta:Number):void;
	}
	
}