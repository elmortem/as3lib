/*
 * Copyright 2010 (c) Dominic Graefen, devboy.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
package elmortem.p2p.hydra2 {
	import elmortem.p2p.hydra2.users.HydraUser;
	import elmortem.p2p.hydra2.users.HydraUserEvent;
	import elmortem.p2p.hydra2.users.HydraUserTracker;
	import elmortem.p2p.hydra2.users.NetGroupNeighbor;
	import elmortem.p2p.hydra2.users.NetGroupNeighborEvent;
	import elmortem.p2p.NetStatusCodes;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> connects
	 *  successfully to the service string.
	 *
	 *  This event is dispatched only when the
	 *  hydra service trys to connect to the service url.
	 *
	 *  @eventType elmortem.p2p.hydra2.HydraEvent.CHANNEL_CONNECT_SUCCESS
	 */
	[Event(name="channelConnectSuccess",type="elmortem.p2p.hydra2.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> connection
	 *  has failed.
	 *
	 *  This event is dispatched only when the
	 *  hydra service trys to connect to the service url.
	 *
	 *  @eventType elmortem.p2p.hydra2.HydraEvent.CHANNEL_CONNECT_FAILED
	 */
	[Event(name="channelConnectFailed",type="elmortem.p2p.hydra2.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> connection
	 *  is rejected.
	 *
	 *  @eventType elmortem.p2p.hydra2.HydraEvent.CHANNEL_CONNECT_REJECTED
	 */
	[Event(name="channelConnectRejected",type="elmortem.p2p.hydra2.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> sends a message.
	 *
	 *  @eventType elmortem.p2p.hydra2.commands.HydraCommandEvent.COMMAND_SENT
	 */
	[Event(name="commandSent",type="elmortem.p2p.hydra2.commands.HydraCommandEvent")]
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> sends a message.
	 *
	 *  @eventType elmortem.p2p.hydra2.commands.HydraCommandEvent.COMMAND_RECEIVED
	 */
	[Event(name="commandReceived",type="elmortem.p2p.hydra2.commands.HydraCommandEvent")]
	
	/**
	 *  Dispatched when the <code>HydraChannel</code> sends a message.
	 *
	 *  @eventType elmortem.p2p.hydra2.commands.HydraCommandEvent.COMMAND_RECEIVED
	 */
	[Event(name="commandReceived",type="elmortem.p2p.hydra2.commands.HydraCommandEvent")]
	
	/**
	 *  Dispatched when a user joins the <code>HydraChannel</code>.
	 *
	 *  @eventType elmortem.p2p.hydra2.users.HydraUserEvent.USER_CONNECT
	 */
	[Event(name="userConnect",type="elmortem.p2p.hydra2.users.HydraUserEvent")]
	
	/**
	 *  Dispatched when a user leaves the <code>HydraChannel</code>.
	 *
	 *  @eventType elmortem.p2p.hydra2.users.HydraUserEvent.USER_DISCONNECT
	 */
	[Event(name="userDisconnect",type="elmortem.p2p.hydra2.users.HydraUserEvent")]
	
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraChannel extends EventDispatcher {
		protected var _channelId:String;
		protected var _netGroup:NetGroup;
		protected var _hydraService:HydraService;
		protected var _connected:Boolean;
		protected var _userTracker:HydraUserTracker;
		protected var _specifier:GroupSpecifier;
		protected var _withAuthorization:Boolean;
		protected var _autoConnect:Boolean;
		protected var _receiveCallback:Function;
		
		public function HydraChannel(hydraService:HydraService, channelId:String, specifier:GroupSpecifier, withAuthorization:Boolean, autoConnect:Boolean = true, receiveCallback:Function = null){
			_receiveCallback = receiveCallback;
			_autoConnect = autoConnect;
			_withAuthorization = withAuthorization;
			_specifier = specifier;
			_hydraService = hydraService;
			_channelId = channelId;
			super(this);
			init();
		}
		
		private function init():void {
			_userTracker = new HydraUserTracker(this);
			_userTracker.addEventListener(HydraUserEvent.USER_CONNECT, dispatchEvent);
			_userTracker.addEventListener(HydraUserEvent.USER_DISCONNECT, dispatchEvent);
			_hydraService.addChannel(this);
		}
		
		public function free():void {
			_receiveCallback = null;
			
			_specifier = null;
			
			_userTracker.removeEventListener(HydraUserEvent.USER_CONNECT, dispatchEvent);
			_userTracker.removeEventListener(HydraUserEvent.USER_DISCONNECT, dispatchEvent);
			_userTracker = null;
			
			_netGroup.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
			_netGroup.close();
			_netGroup = null;
			
			_hydraService.netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
			
			_hydraService.removeChannel(this);
			_hydraService = null;
		}
		
		public function connect():void {
			if (!_hydraService.connected)
				throw new Error("HydraService needs to be connected first");
			
			_hydraService.netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			_netGroup = new NetGroup(_hydraService.netConnection, _withAuthorization ? _specifier.groupspecWithAuthorizations() : _specifier.groupspecWithoutAuthorizations());
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}
		
		public function addNeighbor(peerID:String):Boolean {
			return netGroup.addNeighbor(peerID);
		}
		
		public function addMemberHint(peerID:String):Boolean {
			return netGroup.addMemberHint(peerID);
		}
		
		private function netStatus(event:NetStatusEvent):void {
			var infoCode:String = event.info.code;
			switch (infoCode){
				case NetStatusCodes.NETGROUP_CONNECT_SUCCESS:
				case NetStatusCodes.NETGROUP_CONNECT_REJECTED:
				case NetStatusCodes.NETGROUP_CONNECT_FAILED:
					if (event.info.group && event.info.group == _netGroup){
						_connected = infoCode == NetStatusCodes.NETGROUP_CONNECT_SUCCESS;
						_userTracker.addUser(_hydraService.user);
						_hydraService.netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
						dispatchEvent(new HydraEvent(getEventTypeForNetGroup(infoCode)));
					}
					break;
				case NetStatusCodes.NETGROUP_NEIGHBOUR_CONNECT:
					dispatchEvent(new NetGroupNeighborEvent(NetGroupNeighborEvent.NEIGHBOR_CONNECT, new NetGroupNeighbor(event.info.neighbor as String, event.info.peerID as String, _netGroup.convertPeerIDToGroupAddress(event.info.peerID))));
					break;
				case NetStatusCodes.NETGROUP_NEIGHBOUR_DISCONNECT:
					dispatchEvent(new NetGroupNeighborEvent(NetGroupNeighborEvent.NEIGHBOR_DISCONNECT, new NetGroupNeighbor(event.info.neighbor as String, event.info.peerID as String, _netGroup.convertPeerIDToGroupAddress(event.info.peerID))));
					break;
				case NetStatusCodes.NETGROUP_SENDTO_NOTIFY:
				case NetStatusCodes.NETGROUP_POSTING_NOTIFY:
					receiveCommand(event.info.message);
					break;
			}
		}
		
		protected function receiveCommand(message:Object):void {
			if (!connected) return;
			if (message is Array) {
				for (var i:int = 0; i < message.length; i++) receiveCommand(message[i]);
				return;
			}
			
			var user:HydraUser;
			
			if (message.t == -1){
				user = new HydraUser(message.userName, message.userId, message.userInfo, new NetGroupNeighbor("", message.pid, _netGroup.convertPeerIDToGroupAddress(message.pid)));
				_userTracker.addUser(user);
			} else {
				user = userTracker.getUserByPeerId(message.pid);
				if (user != null) user.timestamp = message.timestamp;
				if (_receiveCallback != null){
					_receiveCallback(message);
				}
			}
		}
		
		public function sendCommand(command:Object, receive:Boolean = false):void {
			if (!connected || command == null) return;
			_netGroup.post(command);
			if (receive)
				receiveCommand(command);
		}
		public function fastCommand(command:Object, receive:Boolean = false):void {
			if (!_specifier.routingEnabled) {
				sendCommand(command);
				return;
			}
			if (!connected || command == null) return;
			_netGroup.sendToAllNeighbors(command);
			if (receive)
				receiveCommand(command);
		}
		public function sendToUser(command:Object, user:HydraUser):void {
			if (!connected || command == null || user == null || user.neighborId.groupAddress == null) return;
			_netGroup.sendToNearest(command, user.neighborId.groupAddress);
		}
		
		private function getEventTypeForNetGroup(infoCode:String):String {
			var eventType:String;
			switch (infoCode){
				case NetStatusCodes.NETGROUP_CONNECT_SUCCESS:
					eventType = HydraEvent.CHANNEL_CONNECT_SUCCESS;
					break;
				case NetStatusCodes.NETGROUP_CONNECT_FAILED:
					eventType = HydraEvent.CHANNEL_CONNECT_FAILED;
					break;
				case NetStatusCodes.NETGROUP_CONNECT_REJECTED:
					eventType = HydraEvent.CHANNEL_CONNECT_REJECTED;
					break;
			}
			return eventType;
		}
		
		public function get connected():Boolean {
			return _connected;
		}
		
		public function get channelId():String {
			return _channelId;
		}
		
		public function get hydraService():HydraService {
			return _hydraService;
		}
		
		public function get autoConnect():Boolean {
			return _autoConnect;
		}
		
		public function get userTracker():HydraUserTracker {
			return _userTracker;
		}
		
		protected function get netGroup():NetGroup {
			return _netGroup;
		}
	}
}
