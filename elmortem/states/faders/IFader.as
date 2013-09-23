package elmortem.states.faders {
	
	public interface IFader {
		function free():void;
		function fadeIn(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void;
		function fadeOut(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void;
	};
}