package elmortem.social.sharing {
	import elmortem.utils.UrlUtils;
	
	public class TwitterShare {
		
		static public function share(status:String):void {
			UrlUtils.open("http://twitter.com/home?status=" + status);
		}
	}
}