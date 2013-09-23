package elmortem.ui.events {
	
	public class UiMouseEvent extends UiEvent {
		static public const CLICK:String = "ui.mouse.Click";
		static public const DOWN:String = "ui.mouse.Down";
		static public const UP:String = "ui.mouse.Up";
		static public const OVER:String = "ui.mouse.Over";
		static public const OUT:String = "ui.mouse.Out";
		static public const MOVE:String = "ui.mouse.Move";
		
		public var x:Number;
		public var y:Number;
		
		public function UiMouseEvent(type:String, data:Object = null) {
			super(type, data);
		}
		
		override public function clone():UiEvent {
			var e:UiMouseEvent = new UiMouseEvent(type, data);
			e.x = x;
			e.y = y;
			return e;
		}
	}
}