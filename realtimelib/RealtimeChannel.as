package realtimelib
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * Creates a DIRECT_CONNECTIONS NetStream between two peers
	 * This method enables to reach lowest latency possible in a P2P network
	 * Creates a receive stream for receiving data from the opposite side.
	 */
	public class RealtimeChannel {
		public var peerID:String;
		
		private var receiveStream:NetStream;
		
		private var myPeerID:String;
				
		private var client:Object;
		
		public function RealtimeChannel(connection:NetConnection, peerID:String, myPeerID:String, client:Object) {
			Logger.log("create RealtimeChannel and listen to: " + peerID);
			this.peerID = peerID;
			this.myPeerID = myPeerID;
			this.client = client;
			
			try {
				receiveStream = new NetStream(connection, peerID);
				receiveStream.addEventListener(NetStatusEvent.NET_STATUS, netStatus, false, 0, true);
				receiveStream.client = client;
				receiveStream.play("media");
			} catch(err:Error) {
				trace(err);
			}
		}
		
		public function close():void {
			if(receiveStream != null) {
				receiveStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatus, false);	
				//receiveStream.client = null;
				receiveStream.close();
				receiveStream = null;
			}
			client = null;
		}
		protected function netStatus(event:NetStatusEvent):void{
			Logger.log("RealtimeChannel.receiveStream: " + event.info.code);
		}
		
		public function send(handlerName:String, ...rest):void {
			if (receiveStream == null) return;
			rest.unshift(handlerName);
			receiveStream.send.apply(null, rest);
		}
	}
}