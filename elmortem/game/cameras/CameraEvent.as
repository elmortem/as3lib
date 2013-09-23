package elmortem.game.cameras {
	import elmortem.types.Vec2;
	import flash.events.Event;

	public class CameraEvent extends Event {
		public static const START:String = "camera.start";
		public static const PROGRESS:String = "camera.progress";
		public static const FINISH:String = "camera.finish";
		
		public var pos:Vec2;
		
		public function CameraEvent(pos:Vec2, type:String) {
			this.pos = pos;
			super(type);
		}
	}
}