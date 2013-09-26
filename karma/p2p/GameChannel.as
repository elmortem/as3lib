package karma.p2p {
	import elmortem.p2p.hydra2.HydraChannel;
	import elmortem.p2p.hydra2.HydraService;
	import flash.net.GroupSpecifier;
	import karma.core.Karma;
	import karma.events.GameEvent;
	import karma.game.senses.ISense;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public class GameChannel extends HydraChannel implements ISense {
		static public const EVENT_DISTOFLOAD:String = "GameChannel.DistOfLoad";
		static private const DISTOFLOAD_TIME:Number = 10;
		
		private var _sendTimer:Number;
		private var _sendTime:Number;
		private var _requestCreatePacket:Boolean;
		
		private var _objectList:Object;
		private var _localList:Vector.<INetObject>;
		private var _remoteList:Vector.<INetObject>;
		
		private var _timestamp:Number;
		private var distOfLoadTimer:Number;
		
		private var _sendPackets:Array;
		private var _fastPackets:Array;
		
		public function GameChannel(hydraService:HydraService, channelId:String, receiveCallback:Function=null) {
			var groupSpecifier:GroupSpecifier = new GroupSpecifier(channelId);
			groupSpecifier.serverChannelEnabled = true;
			groupSpecifier.postingEnabled = true;
			groupSpecifier.routingEnabled = true;
			//groupSpecifier.multicastEnabled = true;
			//groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
			//groupSpecifier.addIPMulticastAddress("225.225.0.1:30042");
			super(hydraService, channelId, groupSpecifier, true, true, receiveCallback);
			
			_objectList = { };
			_localList = new Vector.<INetObject>();
			_remoteList = new Vector.<INetObject>();
			
			pps = 20;
			_sendTimer = 0;
			_requestCreatePacket = false;
			_timestamp = new Date().getTime();
			distOfLoadTimer = 0;
			
			_sendPackets = [];
			_fastPackets = [];
		}
		
		override public function free():void {
			_localList.length = 0;
			_localList = null;
			_remoteList.length = 0;
			_remoteList = null;
			super.free();
		}
		
		public function set pps(v:Number):void {
			_sendTime = 1 / v;
		}
		public function requestCreatePacket(force:Boolean = false):void {
			_requestCreatePacket = !force;
			
			var len:uint = _localList.length;
			for (var i:int = 0; i < len; i++) {
				_localList[i].requestPacket();
			}
			
			if (force) {
				sendLocal(true);
			}
		}
		
		public function sendLocal(create:Boolean):void {
			var len:uint = _localList.length;
			for (var i:int = 0; i < len; i++) {
				if (create) {
					sendCommand(_localList[i].getPacket(true));
				} else if (_localList[i].isPacketReady) {
					fastCommand(_localList[i].getPacket(false));
				}
			}
		}
		
		override public function sendCommand(command:Object, receive:Boolean = false):void {
			if (command == null) return;
			command.pid = _hydraService.netConnection.nearID;
			command.timestamp = _timestamp;
			_sendPackets.push(command);
		}
		override public function fastCommand(command:Object, receive:Boolean = false):void {
			if (command == null) return;
			command.pid = _hydraService.netConnection.nearID;
			command.timestamp = _timestamp;
			_fastPackets.push(command);
		}
		
		public function get objectList():Object {
			return _objectList;
		}
		public function get localList():Vector.<INetObject> {
			return _localList;
		}
		public function get remoteList():Vector.<INetObject> {
			return _remoteList;
		}
		
		public function addLocal(o:INetObject):void {
			if (o == null) return;
			_objectList[o.uniqId] = o;
			
			o.remote = false;
			if(_localList.indexOf(o) < 0) {
				_localList.push(o);
			}
		}
		public function removeLocal(o:INetObject):void {
			if (o == null) return;
			delete _objectList[o.uniqId];
			
			var idx:int = _localList.indexOf(o);
			if (idx >= 0) {
				_localList.splice(idx, 1);
			}
		}
		public function addRemote(o:INetObject):void {
			if (o == null) return;
			_objectList[o.uniqId] = o;
			
			o.remote = true;
			if(_remoteList.indexOf(o) < 0) {
				_remoteList.push(o);
			}
		}
		public function removeRemote(o:INetObject):void {
			if (o == null) return;
			delete _objectList[o.uniqId];
			
			var idx:int = _remoteList.indexOf(o);
			if (idx >= 0) {
				_remoteList.splice(idx, 1);
			}
		}
		
		public function update(delta:Number):void {
			_timestamp += delta * 1000;
			
			_sendTimer -= delta;
			if(_sendTimer <= 0) {
				sendLocal(!_requestCreatePacket);
				if (_sendPackets.length > 0) {
					super.sendCommand(_sendPackets);
					_sendPackets.length = 0;
				}
				if (_fastPackets.length > 0) {
					super.fastCommand(_fastPackets);
					_fastPackets.length = 0;
				}
				_requestCreatePacket = false;
				_sendTimer = _sendTime;
			}
			
			//
			distOfLoadTimer += delta;
			if (distOfLoadTimer >= DISTOFLOAD_TIME) {
				distOfLoadTimer = 0;
				if (_localList.length > 3 && _localList.length > _remoteList.length) {
					Karma.eventer.dispatchEvent(new GameEvent(EVENT_DISTOFLOAD));
				}
			}
		}
		public function get name():String {
			return "gameChannel";
		}
		
		public function getValue(name:String):Object {
			return null;
		}
		public function setValue(name:String, value:Object):void {
		}
		
	}

}