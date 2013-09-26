package karma.display {
	import karma.core.Karma;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Karma Team
	 */
	public class ExtendedMovieClip extends MovieClip {
		
		public function ExtendedMovieClip(textures:Vector.<Texture>, fps:Number=12) {
			super(textures, fps);
		}
		
		public function playAnimation(begin:int, end:int, fps:Number):void {
			this.fps = fps;
			play();
			
			Karma.juggler.remove(this);
			Karma.juggler.add(this);
		}
		
		public function gotoAndStop(n:int):void {
			currentFrame = n-1;
		}
	}
}