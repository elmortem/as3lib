package elmortem.managers.animations {
	import elmortem.core.Gfx;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public dynamic class CacheMovieClip extends Sprite {
		static public var zoom:Number = 1;
		
		public var clip:MovieClip;
		public var bmp:Bitmap;
		public var frames:Vector.<BitmapData>;
		public var offsets:Vector.<Point>;
		public var labels:Vector.<String>;
		public var currentFrame:int;
		
		public function CacheMovieClip() {
			clip = null;
			addChild(bmp = new Bitmap());
			frames = new Vector.<BitmapData>();
			offsets = new Vector.<Point>();
			labels = new Vector.<String>();
			currentFrame = 1;
			mouseEnabled = false;
			mouseChildren = false;
		}
		public function free():void {
			if (bmp == null) return;
			if (parent != null) parent.removeChild(this);
			clip = null;
			removeChild(bmp);
			bmp = null;
			frames = null;
			offsets = null;
			labels = null;
		}
		
		public function set smoothing(val:Boolean):void {
			bmp.smoothing = val;
		}
		public function get smoothing():Boolean {
			return bmp.smoothing;
		}
		
		public function buildFromLibrary(Name:String):void {
			var clip:MovieClip = Gfx.createMovieClip(Name) as MovieClip;
			if (clip == null) throw("Error: Clip '"+Name+"' not found.");
			buildFromClip(clip);
		}
		public function buildFromClip(Clip:MovieClip):void {
			if (Clip == null) throw("Clip not found.");
			if (clip != null) {
				clip = null;
				frames = new Vector.<BitmapData>();
				offsets = new Vector.<Point>();
			}
			
			clip = Clip;
			clip.scaleX = clip.scaleY = zoom;
			var r:Rectangle;
			var bd:BitmapData;
			var m:Matrix = new Matrix();
			
			var i:int;
			var len:int = clip.totalFrames;
			for (i = 1; i <= len; ++i) {
				clip.gotoAndStop(i);
				r = clip.getBounds(null);
				//r = clip.getRect(clip);
				r.width = Math.round((r.width + 6) * clip.scaleX);
				r.height = Math.round((r.height + 6) * clip.scaleY);
				r.x -= 3;
				r.y -= 3;
				bd = new BitmapData(Math.max(1, r.width), Math.max(1, r.height), true, 0x00000000);
				m.identity();
				m.translate(-r.x, -r.y);
				m.scale(clip.scaleX, clip.scaleY);
				bd.draw(clip, m);
				frames.push(bd);
				r.x = Math.round(r.x * clip.scaleX);
				r.y = Math.round(r.y * clip.scaleY);
				offsets.push(new Point(r.x, r.y));
				labels.push(clip.currentLabel);
			}
			
			gotoAndStop(1);
		}
		
		public function get totalFrames():int {
			if (clip == null) return 0;
			return frames.length;
		}
		public function get currentLabel():String {
			if (clip == null) return "";
			if (totalFrames == 0) return "";
			return labels[currentFrame - 1];
		}
		
		
		public function stop():void {}
		public function gotoAndStop(frame:int):void {
			if (clip == null) return;
			if (totalFrames == 0) return;
			currentFrame = Math.max(1, Math.min(totalFrames, frame));
			var sm:Boolean = smoothing;
			bmp.bitmapData = frames[currentFrame - 1];
			smoothing = sm;
			bmp.x = offsets[currentFrame - 1].x;
			bmp.y = offsets[currentFrame - 1].y;
		}
		
		
		
		/* STATIC */
		static private var clips:Object = { };
		
		static public function getClip(Name:String, Movie:MovieClip = null):CacheMovieClip {
			if(clips[Name] == null) {
				var m:CacheMovieClip = new CacheMovieClip();
				if(Movie == null) {
					m.buildFromLibrary(Name);
				} else {
					m.buildFromClip(Movie);
				}
				clips[Name] = m;
			}
			
			var clip:CacheMovieClip = new CacheMovieClip();
			clip.clip = clips[Name].clip;
			clip.frames = clips[Name].frames;
			clip.offsets = clips[Name].offsets;
			clip.labels = clips[Name].labels;
			clip.gotoAndStop(1);
			return clip;
		}
	}
}