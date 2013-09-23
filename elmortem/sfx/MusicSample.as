package elmortem.sfx {
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class MusicSample extends Sample {
		
		public function MusicSample(name:String, sound:Sound):void {
			super(name, sound);
		}
		
		override protected function get globalVolume():Number {
			return Sfx.musicVolume;
		}
	}
}