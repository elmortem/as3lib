package karma.game.cameras {
	import elmortem.types.Vec2;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public interface ICamera {
		
		function free():void;
		function update(delta:Number):void;
		function get bounds():Rectangle;
		function set bounds(v:Rectangle):void;
		function get x():int;
		function get y():int;
		function screenToCamera(x:Number, y:Number, v:Vec2 = null):Vec2;
		function cameraToScreen(x:Number, y:Number, v:Vec2 = null):Vec2;
	}
	
}