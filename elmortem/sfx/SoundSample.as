package elmortem.sfx {
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class SoundSample extends Sample {
		
		public function SoundSample(name:String, sound:Sound):void {
			super(name, sound);
		}
		
		override protected function get globalVolume():Number {
			return Sfx.soundVolume;
		}
	}
}