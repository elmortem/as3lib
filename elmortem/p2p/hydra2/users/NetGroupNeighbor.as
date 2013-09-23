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
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class NetGroupNeighbor
	{
		private var _neighborId : String;
		private var _peerId : String;
		private var _groupAddress:String;

		public function NetGroupNeighbor(neighborId : String, peerId : String, groupAddress:String)
		{
			_peerId = peerId;
			_neighborId = neighborId;
			_groupAddress = groupAddress;
		}

		public function get neighborId() : String
		{
			return _neighborId;
		}

		public function get peerId() : String
		{
			return _peerId;
		}
		
		public function get groupAddress():String {
			return _groupAddress;
		}
	}
}
