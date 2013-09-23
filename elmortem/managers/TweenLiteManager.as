package elmortem.managers {
	import com.greensock.TweenLite;
	
	public class TweenLiteManager {
		static private var lists:Array = [];
		static private var is_new:Boolean = true;
		
		private var obj:Object;
		private var duration:Number;
		private var params:Object;
		private var parent:TweenLiteManager = null;
		private var next:TweenLiteManager = null;
		
		public function TweenLiteManager() {
		}
		
		static public function add(obj:Object, duration:Number, params:Object):void {
			if (is_new) {
				lists.push([]);
				is_new = false;
			}
			var i:int = lists.length - 1;
			var mngr:Object = { };
			mngr.obj = obj;
			mngr.duration = duration;
			var oc:Function = params.onComplete;
			var ocp:Object = params.onCompleteParams;
			params.onComplete = onComplete;
			params.onCompleteParams = [lists[i], oc, ocp];
			mngr.params = params;
			lists[i].push(mngr);
		}
		static public function run():void {
			if (is_new) return;
			var i:int = lists.length - 1;
			is_new = true;
			_run(lists[i]);
		}
		static public function _run(list:Array):void {
			if (list == null || list.length <= 0) return;
			TweenLite.to(list[0].obj, list[0].duration, list[0].params);
			list.splice(0, 1);
			if (list.length <= 0) {
				var id:int = lists.indexOf(list);
				if (id >= 0) lists.splice(id, 1);
			}
		}
		static private function onComplete(list:Array, on_complete:Function, on_complete_params:Array = null):void {
			if (on_complete != null) {
				on_complete.apply(null, on_complete_params);
			}
			_run(list);
		}
	}
}