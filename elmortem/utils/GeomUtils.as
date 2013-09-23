package elmortem.utils {
	import elmortem.types.Vec2;
	
	
	public class GeomUtils {
		
		static public function lineIntersection(p1:Vec2, p2:Vec2, p3:Vec2, p4:Vec2):Vec2 {
			var x1:Number=p1.x;
			var x2:Number=p2.x;
			var x3:Number=p3.x;
			var x4:Number=p4.x;
			var y1:Number=p1.y;
			var y2:Number=p2.y;
			var y3:Number=p3.y;
			var y4:Number=p4.y;
			var px:Number=((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
			var py:Number=((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
			var segment1Len:Number=Math.pow(p1.x-p2.x,2)+Math.pow(p1.y-p2.y,2);
			var segment2Len:Number=Math.pow(p3.x-p4.x,2)+Math.pow(p3.y-p4.y,2);
			if (Math.pow(p1.x-px,2)+Math.pow(p1.y-py,2)>segment1Len) {
				return null;
			}
			if (Math.pow(p2.x-px,2)+Math.pow(p2.y-py,2)>segment1Len) {
				return null;
			}
			if (Math.pow(p3.x-px,2)+Math.pow(p3.y-py,2)>segment2Len) {
				return null;
			}
			if (Math.pow(p4.x-px,2)+Math.pow(p4.y-py,2)>segment2Len) {
				return null;
			}
			return new Vec2(px,py);
		}
	}
	
}