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
package elmortem.p2p.hydra2.users
{
	import elmortem.p2p.hydra2.HydraChannel;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraUserTracker extends EventDispatcher
	{
		private var _users:Vector.<HydraUser>;
		private var _hydraChannel:HydraChannel;
		
		public function HydraUserTracker(hydraChannel:HydraChannel)
		{
			_hydraChannel = hydraChannel;
			super(this);
			init();
		}
		
		private function init():void
		{
			_users = new Vector.<HydraUser>();
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_CONNECT, neighborEvent);
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_DISCONNECT, neighborEvent);
		}
		
		private function neighborEvent(event:NetGroupNeighborEvent):void
		{
			switch (event.type)
			{
				case NetGroupNeighborEvent.NEIGHBOR_CONNECT:
					_hydraChannel.sendCommand({t:-1, userName: _hydraChannel.hydraService.user.name, userId:_hydraChannel.hydraService.user.uniqueId, userInfo:_hydraChannel.hydraService.user.info});
					break;
				case NetGroupNeighborEvent.NEIGHBOR_DISCONNECT: 
					removeNeighbor(event.netGroupNeighbor);
					break;
			}
		}
		
		private function removeNeighbor(netGroupNeighbor:NetGroupNeighbor):void
		{
			var user:HydraUser = getUserByPeerId(netGroupNeighbor.peerId);
			if (user)
				removeUser(user);
		}
		
		public function addUser(user:HydraUser):void
		{
			var listedUser:HydraUser;
			for each (listedUser in _users)
				if (listedUser.uniqueId == user.uniqueId)
					return;
			
			_users.push(user);
			_hydraChannel.addMemberHint(user.neighborId.peerId);
			_hydraChannel.addNeighbor(user.neighborId.peerId);
			dispatchEvent(new HydraUserEvent(HydraUserEvent.USER_CONNECT, user));
		}
		
		private function removeUser(user:HydraUser):void
		{
			var idx:int = _users.indexOf(user);
			if (idx >= 0)
			{
				var removedUser:HydraUser = user;
				_users.splice(idx, 1);
				dispatchEvent(new HydraUserEvent(HydraUserEvent.USER_DISCONNECT, removedUser));
			}
		}
		
		public function getUserByPeerId(peerId:String):HydraUser {
			var user:HydraUser;
			for each (user in _users)
				if (user.neighborId && user.neighborId.peerId == peerId)
					return user;
			return null;
		}
		
		public function getUserByUniqueId(uniqueId:String):HydraUser {
			var user:HydraUser;
			for each (user in _users)
				if (user.uniqueId == uniqueId)
					return user;
			return null;
		}
		
		public function getUserByName(name:String):HydraUser
		{
			var user:HydraUser;
			for each (user in _users)
				if (user.name == name)
					return user;
			return null;
		}
		
		public function get users():Vector.<HydraUser>
		{
			return _users;
		}
	
	}
}
