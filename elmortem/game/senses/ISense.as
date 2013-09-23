package elmortem.game.senses {
	
	public interface ISense {
		function free():void;
		function get senseName():String;
		function update(delta:Number):void;
	}
}