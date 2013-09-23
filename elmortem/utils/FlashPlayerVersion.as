package elmortem.utils
{
	import flash.system.Capabilities;
	
	public class FlashPlayerVersion
	{
		/* static block */
		{
			trace("Initialising class FlashPlayerVersion");
			
			private static var a:Array = Capabilities.version.split(" ");
			
			platform = a[0]; // "WIN", "MAC", "UNIX", etc.
			
			a = a[1].split(",");
			
			majorVersion = int(a[0]);
			minorVersion = int(a[1]);
			buildNumber = int(a[2]);
			internalBuildNumber = int(a[3]);
		}
		
		public static var platform:String;
		
		public static var majorVersion:int;
		public static var minorVersion:int;
		public static var buildNumber:int;
		public static var internalBuildNumber:int;
	}
}