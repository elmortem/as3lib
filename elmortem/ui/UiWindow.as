package elmortem.ui {
	
	public class UiWindow extends UiContainer {
		private var _group:String;
		
		public function UiWindow(attrIn:Object = null) {
			super(attrIn);
		}
		
		override public function get group():String {
			return _group;
		}
		override public function set group(value:String):void {
			_group = value;
		}
	}
}