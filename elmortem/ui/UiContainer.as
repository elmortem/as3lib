package elmortem.ui {
	import elmortem.ui.UiComponent;
	
	public class UiContainer extends UiComponent {
		private var list:Vector.<UiComponent>;
		
		public function UiContainer(attrIn:Object = null):void {
			super(attrIn);
			list = new Vector.<UiComponent>();
		}
		
		override public function get group():String {
			if(parent != null && parent is UiComponent) {
				return (parent as UiComponent).group;
			}
			return null;
		}
		
		override public function add(c:UiComponent):UiComponent {
			if (list.indexOf(c) < 0) {
				list.push(c);
				sortChilds();
			}
			c.render();
			return c;
		}
		override public function remove(c:UiComponent):void {
			var idx:int = list.indexOf(c);
			if (idx >= 0) {
				removeChild(c);
				list.splice(idx, 1);
				sortChilds();
			}
		}
		override public function clear():void {
			var len:int = list.length;
			for (var i:int = 0; i < len; ++i) {
				list[i].clear();
				this.removeChild(list[i]);
			}
			list.splice(0, list.length);
		}
		override public function findChildByName(name:String, child:Boolean = false):UiComponent {
			var i:int;
			var len:int = list.length;
			for (i = 0; i < len; ++i) {
				if (list[i].name == name) return list[i];
			}
			if (child) {
				var c:UiComponent;
				for (i = 0; i < len; ++i) {
					c = list[i].findChildByName(name, true);
					if (c != null) return c;
				}
			}
			return null;
		}
		
		override public function sortChilds():void {
			if (isLock) return;
			list.sort(_sortByZ);
			var len:int = list.length;
			for (var i:int = 0; i < len; ++i){
				this.addChild(list[i]);
			}
		}
		
		private function _sortByZ(x:Number, y:Number):int {
			if (x < y) {
				return -1;
			} else if (x > y) {
				return 1;
			} else {
				return 0;
			}
		}
	}
}