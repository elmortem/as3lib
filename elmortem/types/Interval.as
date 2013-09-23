package elmortem.types {
	
	public class Interval {
		private var items:Array;
		
		public function Interval():void {
			items = null;
		}
		public function clear():void {
			items = null;
		}
		public function add(begin:Number, end:Number, obj:Object):void {
			if (items == null) items = [];
			items.push( { b:begin, e:end, o:obj } );
		}
		public function getObject(n:Number):Object {
			for (var i:int = 0; i < items.length; i++) {
				if (n >= items[i].e && n < items[i].b) return items[i].o;
			}
			return null;
		}
	}
}