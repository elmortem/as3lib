package elmortem.utils {
	import flash.display.Graphics;
	
	public class GraphicsUtils {
	
		static public function drawArc(graphics:Graphics, centerX:Number, centerY:Number, radius:Number, startAngle:Number, arcAngle:Number, steps:int):void {
			graphics.moveTo(centerX, centerY);
			
			startAngle = AngleUtils.toRad(startAngle-90);
			arcAngle = AngleUtils.toRad(arcAngle);
			
			var angleStep:Number = arcAngle / steps;
			var xx:Number = centerX + Math.cos(startAngle) * radius;
			var yy:Number = centerY + Math.sin(startAngle) * radius;
			
			graphics.lineTo(xx, yy);
			
			var angle:Number;
			for(var i:int = 1; i <= steps; i++) {
				angle = startAngle + i * angleStep;
				
				xx = centerX + Math.cos(angle) * radius;
				yy = centerY + Math.sin(angle) * radius;
				graphics.lineTo(xx, yy);
			}
			
			graphics.lineTo(centerX, centerY);
		}
		
		static public function drawSolidArc(graphics:Graphics, centerX:Number, centerY:Number, innerRadius:Number, outerRadius:Number, startAngle:Number, arcAngle:Number, steps:int):void {
			startAngle = AngleUtils.toRad(startAngle-90);
			arcAngle = AngleUtils.toRad(arcAngle);
			
			var angleStep:Number = arcAngle / steps;
			var angle:Number;
			var i:int;
			var endAngle:Number;
			var xx:Number = centerX + Math.cos(startAngle) * innerRadius;
			var yy:Number = centerY + Math.sin(startAngle) * innerRadius;
			var startPoint:Object = {x:xx, y:yy};
			
			graphics.moveTo(xx, yy);
			
			for (i = 1; i <= steps; i++) {
				angle = startAngle + i * angleStep;
				xx = centerX + Math.cos(angle) * innerRadius;
				yy = centerY + Math.sin(angle) * innerRadius;
				graphics.lineTo(xx, yy);
			}
			endAngle = startAngle + arcAngle;
			
			for (i = 0; i <= steps; i++) {
					//
					// To go the opposite direction, we subtract rather than add.
					angle = endAngle - i * angleStep;
					xx = centerX + Math.cos(angle) * outerRadius;
					yy = centerY + Math.sin(angle) * outerRadius;
					graphics.lineTo(xx, yy);
			}
			graphics.lineTo(startPoint.x, startPoint.y);
		}
	}
}