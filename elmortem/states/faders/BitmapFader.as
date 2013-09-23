package elmortem.states.faders {
	import com.greensock.TweenLite;
	import elmortem.sfx.Sample;
	import elmortem.sfx.Sfx;
	import elmortem.states.State;
	import elmortem.states.StateManager;
	import elmortem.utils.SpriteUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	
	public class BitmapFader extends Sprite implements IFader {
		static public const LEFT:int = 0;
		static public const RIGHT:int = 1;
		static public const UP:int = 2;
		static public const DOWN:int = 3;
		static private const FILTERS:Array = [new BlurFilter(10, 0, 1)];
		private var bmp:Bitmap;
		private var bitmaps:Vector.<Bitmap>;
		private var transparent:Boolean;
		private var callback:Function;
		private var callback_params:Array;
		private var isOut:Boolean;
		private var type:int;
		
		private var snd_in:Sample;
		private var snd_out:Sample;
		
		private var blur_cnt:int;
		
		public function BitmapFader(width:Number, height:Number, transparent:Boolean, image:DisplayObject, type:int = LEFT, sfx_in:String = null, sfx_out:String = null) {
			if (image is Bitmap) bmp = image as Bitmap;
			else {
				var bd:BitmapData = new BitmapData(width, height, transparent, 0x00000000);
				bd.draw(image, image.transform.matrix, null, null, null, true);
				bmp = new Bitmap(bd, "auto", true);
			}
			addChild(bmp);
			bitmaps = new Vector.<Bitmap>();
			this.transparent = transparent;
			isOut = false;
			visible = false;
			mouseEnabled = true;
			
			snd_in = Sfx.createSound(sfx_in);
			snd_out = Sfx.createSound(sfx_out);
			
			this.type = type;
		}
		public function free():void {
			callback = null;
			callback_params = null;
			snd_in.free();
			snd_in = null;
			snd_out.free();
			snd_out = null;
		}
		
		public function fadeIn(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void {
			if (parent == null || (!force && bmp in TweenLite.masterList)) return;
			
			if(!isOut) {
				var list:Vector.<State> = StateManager.instance.list;
				for (var i:int = 0; i < list.length; i++) {
					var b:Bitmap = list[i].getSnapshot(transparent);
					b.visible = list[i].visible;
					//TweenLite.to(b, time, { delay:0.3, overwrite:1, alpha:0 } );
					bitmaps.push(b);
					addChild(b);
					list[i].visible = false;
				}
			}
			SpriteUtils.toFront(bmp);
			
			bmp.x = bmp.width;
			visible = true;
			
			this.callback = callback;
			this.callback_params = callback_params;
			
			SpriteUtils.toFront(this);
			
			var fromX:Number = 0;
			var fromY:Number = 0;
			var toX:Number = 0;
			var toY:Number = 0;
			
			if (type == LEFT) {
				if(isOut) {
					fromX = (stage.stageWidth - bmp.width) * 0.5 - parent.x;
				} else {
					fromX = stage.stageWidth;
				}
				if(isOut) {
					toX = -bmp.width;
				} else {
					toX = (stage.stageWidth - bmp.width) * 0.5 - parent.x;
				}
				
				fromY = (stage.stageHeight - bmp.height) * 0.5 - parent.y;
				toY = fromY;
			} else if (type == RIGHT) {
				if(isOut) {
					fromX = (stage.stageWidth - bmp.width) * 0.5 - parent.x;
				} else {
					fromX = -bmp.width;
				}
				if(isOut) {
					toX = stage.stageWidth;
				} else {
					toX = (stage.stageWidth - bmp.width) * 0.5 - parent.x;
				}
				
				fromY = (stage.stageHeight - bmp.height) * 0.5 - parent.y;
				toY = fromY;
			} else if (type == UP) {
				
			} else if (type == DOWN) {
				
			}
			
			bmp.x = fromX;
			bmp.y = fromY;
			if (isOut) {
				if (snd_in != null) snd_in.play();
				TweenLite.to(bmp, time, { delay:0.35, overwrite:1, x:toX, y:toY, onUpdate:onUpdate, onComplete:onFadeOutComplete } );
			} else {
				if (snd_out != null) snd_out.play();
				TweenLite.to(bmp, time, { overwrite:1, x:toX, y:toY, onUpdate:onUpdate, onComplete:onFadeInComplete } );
			}
			
			blur_cnt = 0;
			//FILTERS[0].blurX = 30;
			//bmp.filters = FILTERS;
			
			//addEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function fadeOut(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void {
			isOut = true;
			fadeIn(time, callback, callback_params, force);
		}
		
		private function onUpdate():void {
			blur_cnt--;
			if (blur_cnt > 0) return;
			blur_cnt = 5;
			
			var xxx:Number = (stage.stageWidth - bmp.width) * 0.5;
			var yyy:Number = Math.abs(xxx - bmp.x) / bmp.width * 100;
			FILTERS[0].blurX = yyy;
			bmp.filters = FILTERS;
		}
		
		private function onFadeInComplete():void {
			var c:Function = callback;
			var cp:Array = callback_params;
			callback = null;
			callback_params = null;
			
			bmp.filters = [];
			
			var list:Vector.<State> = StateManager.instance.list;
			for (var i:int = 0; i < bitmaps.length; i++) {
				list[i].visible = bitmaps[i].visible;
				removeChild(bitmaps[i]);
			}
			bitmaps.length = 0;
			
			TweenLite.killTweensOf(bmp);
			
			if (c != null) TweenLite.delayedCall(3, c, cp, true);
			//if (c != null) c.apply(null, cp);
			
			isOut = false;
		}
		private function onFadeOutComplete():void {
			onFadeInComplete();
			visible = false;
		}
	}
}