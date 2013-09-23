package elmortem.atgorithms {
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Karma Team
	 */
	public class AtlasNode {
		public var childs:Vector.<AtlasNode>;
		public var rect:Rectangle;
		public var data:Object;
		
		public function AtlasNode(x:int = 0, y:int = 0, width:int = 0, height:int = 0) {
			childs = new Vector.<AtlasNode>();
			rect = new Rectangle(x, y, width, height);
			data = null;
		}
		
		public function insert(width:Number, height:Number, data:Object):AtlasNode {
			if(childs.length > 0) {
        var newNode:AtlasNode = childs[0].insert(width, height, data);
        if (newNode != null) return newNode;
        
        return childs[1].insert(width, height, data);
			} else {
        if (this.data != null) return null;
				
				if (width > rect.width || height > rect.height) return null;
				
				if (width == rect.width && height == rect.height) {
					this.data = data;
					return this;
				}
        
        childs.push(new AtlasNode());
        childs.push(new AtlasNode());
        
        var dw:Number = rect.width - width;
        var dh:Number = rect.height - height;
        
				if (dw > dh) {
					childs[0].rect = new Rectangle(rect.left, rect.top, width, rect.height);
					childs[1].rect = new Rectangle(rect.left + width, rect.top, rect.width-width, rect.height);
				} else {
					childs[0].rect = new Rectangle(rect.left, rect.top, rect.width, height);
					childs[1].rect = new Rectangle(rect.left, rect.top + height, rect.width, rect.height-height);
				}
				
        return childs[0].insert(width, height, data);
			}
		}
	}

}