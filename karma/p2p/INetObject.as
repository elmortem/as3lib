package karma.p2p {
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public interface INetObject {
		function get createdTime():Number;
		function resetCreatedTime():void;
		function get peerId():String;
		function get uniqId():String;
		function get ping():Number;
		function get timestamp():Number;
		function get remote():Boolean;
		function set remote(v:Boolean):void;
		function get isPacketReady():Boolean;
		function requestPacket():void;
		function getPacket(create:Boolean):Object;
		function setPacket(p:Object):void;
	}
	
}