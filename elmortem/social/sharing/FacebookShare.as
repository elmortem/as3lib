package elmortem.social.sharing {
	import elmortem.utils.UrlUtils;
	
	public class FacebookShare {
		
		static public function share(link:String):void {
			UrlUtils.open("http://www.facebook.com/sharer.php?u=" + link);
		}
	}
}