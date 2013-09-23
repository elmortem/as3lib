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
package elmortem.p2p.hydra2.chat
{
	import elmortem.p2p.hydra2.HydraChannel;
	import elmortem.p2p.hydra2.HydraService;
	import elmortem.p2p.hydra2.users.HydraUser;
	import flash.net.GroupSpecifier;
	
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraChatChannel extends HydraChannel
	{
		public function HydraChatChannel(hydraService:HydraService, channelId:String, withAuthorization:Boolean = false, autoConnect:Boolean = true, receiveCallback:Function = null)
		{
			var groupSpecifier:GroupSpecifier = new GroupSpecifier(channelId);
			groupSpecifier.serverChannelEnabled = true;
			groupSpecifier.postingEnabled = true;
			groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
			super(hydraService, channelId, groupSpecifier, withAuthorization, autoConnect, receiveCallback);
			init();
		}
		
		private function init():void
		{
		}
		
		override protected function receiveCommand(message:Object):void {
			if (message.type == "chatMsg") {
				var sender:HydraUser = userTracker.getUserByPeerId(message.senderPeerId);
				if (sender == null) return;
				dispatchEvent(new HydraChatEvent(HydraChatEvent.MESSAGE_RECEIVED, message.msg, sender));
			} else {
				super.receiveCommand(message);
			}
		}
		
		public function sendChatMessage(chatMessage:String):void
		{
			sendCommand( { type:"chatMsg", msg:chatMessage } );
			dispatchEvent(new HydraChatEvent(HydraChatEvent.MESSAGE_SENT, chatMessage, hydraService.user));
		}
	}
}
