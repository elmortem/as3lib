package elmortem.ui.events {
	
	public class UiEvent {
		static public const ADDED:String = "ui.Added";
		static public const REMOVED:String = "ui.Removed";
		static public const ACTIVED:String = "ui.Actived";
		static public const DEACTIVED:String = "ui.Deactived";
		static public const RESIZE:String = "ui.Resize";
		
		public var owner:Object;
		public var type:String;
		public var data:Object;
		
		public function UiEvent(type:String, data:Object = null) { 
			this.type = type;
			this.data = data;
		} 
		
		public function clone():UiEvent { 
			return new UiEvent(type, data);
		} 
		
		public function toString():String { 
			return "[UiEvent type=" + type + ", data=" + data + "]";
		}
		
	}
	
}