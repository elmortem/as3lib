package elmortem.game.cameras {
	import elmortem.types.Vec2;
	import flash.geom.Rectangle;

	public interface ICamera {
		function free():void;
		function update(delta:Number):void;
		function get bounds():Rectangle;
		function get x():int;
		function get y():int;
		function screenToCamera(x:Number, y:Number, v:Vec2 = null):Vec2;
		function cameraToScreen(x:Number, y:Number, v:Vec2 = null):Vec2;
	}
}