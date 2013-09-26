package karmateam.states {
	
	public interface IStateScript {
		function init(state:State):void;
		function update(delta:Number):void;
		function render():void;
		function get name():String;
	}
}