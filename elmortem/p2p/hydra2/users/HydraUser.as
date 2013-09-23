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
	public class HydraUser
	{
		private var _name : String;
		private var _uniqueId : String;
		private var _neighborId : NetGroupNeighbor;
		private var _info:Object;
		private var _timestamp:Number;
		private var _ping:Number;

		public function HydraUser(name : String, uniqueId : String, info:Object, neighborId : NetGroupNeighbor) 
		{
			_uniqueId = uniqueId;
			_name = name;
			_neighborId = neighborId;
			_info = info;
			_timestamp = new Date().getTime();
			_ping = 0;
		}

		public function get name() : String
		{
			return _name;
		}

		public function get uniqueId() : String
		{
			return _uniqueId;
		}

		public function get neighborId() : NetGroupNeighbor
		{
			return _neighborId;
		}

		public function set neighborId(neighborId : NetGroupNeighbor) : void
		{
			_neighborId = neighborId;
		}
		
		public function get info():Object {
			return _info;
		}
		public function set info(value:Object):void {
			_info = value;
		}
		
		public function set timestamp(value:Number):void {
			_ping = (_timestamp + value) * 0.5 * 0.001;
			_timestamp = value;
		}
		public function get timestamp():Number {
			return _timestamp;
		}
		public function get ping():Number {
			return _ping;
		}
	}
}
