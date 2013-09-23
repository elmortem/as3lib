package elmortem.ads {
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.components.FlashAd;
	import flash.display.LoaderInfo;
	
	public class NewgroundsLoader extends BaseAdsLoader {
		private var showBackground:Boolean;
		
		public function NewgroundsLoader(Time:Number, loaderInfo:LoaderInfo, Id:String, Key:String, ShowBackground:Boolean = false) {
			super(Time, -1, 275);
			showBackground = ShowBackground;
			API.addEventListener(APIEvent.API_CONNECTED, onConnected);
			API.connect(loaderInfo, Id, Key);
		}
		
		private function onConnected(e:APIEvent):void {
			trace("onConnected");
			API.removeEventListener(APIEvent.API_CONNECTED, onConnected);
			var flashAd:FlashAd = new FlashAd(showBackground);
			flashAd.addEventListener(APIEvent.AD_ATTACHED, onAdLoaded);
			addChild(flashAd);
		}
		private function onAdLoaded(e:APIEvent):void {
			trace("onAdLoaded");
			API.removeEventListener(APIEvent.ADS_APPROVED, onAdLoaded);
			loaded = true;
		}
	}
}