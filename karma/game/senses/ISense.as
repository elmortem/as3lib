package karma.game.senses {
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public interface ISense {
		
		function free():void;
		function update(delta:Number):void;
		function get name():String;
		function getValue(name:String):Object;
		function setValue(name:String, value:Object):void;
	}
	
}