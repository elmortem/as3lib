package elmortem.utils {
	import com.greensock.TweenLite;
	import elmortem.sound.SndChannel;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundUtils {
		
		static public function fadeVolume(channel:SndChannel, vol:Number, time:Number = 1, is_stop:Boolean = false):void {
			if (channel == null || channel.channel == null) return;
			var st:SoundTransform = channel.channel.soundTransform;
			var o:Object = { channel:channel, volume:st.volume };
			TweenLite.to(o, time, { overwrite:1, volume:vol, onUpdate:onFadeVolumeUpdate, onUpdateParams:[o] } );
		}
		
		static private function onFadeVolumeUpdate(o:Object):void {
			if (o.channel.channel == null) return;
			var st:SoundTransform = o.channel.channel.soundTransform;
			st.volume = o.volume;
			o.channel.channel.soundTransform = st;
		}
		
	}
}