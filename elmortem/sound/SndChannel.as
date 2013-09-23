package elmortem.sound {
	import elmortem.core.Sfx;
	import flash.events.Event;
	import flash.media.SoundChannel;
	
	
	public class SndChannel {
		public var sound:Snd;
		public var channel:SoundChannel;
		
		public function SndChannel(snd:Snd, chnl:SoundChannel) {
			sound = snd;
			channel = chnl;
			channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			
			if (Sfx.sndSounds[sound.name] == null) Sfx.sndSounds[sound.name] = 0;
			Sfx.sndSounds[sound.name]++;
		}
		public function free():void {
			if (channel == null) return;
			Sfx.sndSounds[sound.name]--;
			
			sound = null;
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			channel = null;
		}
		
		private function onComplete(e:Event):void {
			free();
		}
	}
	
}