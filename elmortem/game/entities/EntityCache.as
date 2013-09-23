package elmortem.game.entities {

	public class EntityCache {
		protected var targetClass:Class;
		protected var targetInstances:Array;
		protected var lastInstanceIndex:int;

		public function EntityCache(targetClass:Class, initialCapacity:int) {
			this.targetClass = targetClass;
			targetInstances = new Array(initialCapacity);
			lastInstanceIndex = initialCapacity - 1;
			for (var i : int = 0; i < initialCapacity; i++) {
				targetInstances[i] = createTargetInstance();
			}
		}

		public function destroyEntity(instance:Object):void {
			lastInstanceIndex++;
			if (lastInstanceIndex == targetInstances.length) {
				targetInstances.push(instance);
			} else {
				targetInstances[lastInstanceIndex] = instance; 
			}
		} 

		public function createEntity():Object {
			if (lastInstanceIndex >= 0) {
				lastInstanceIndex--;
				return targetInstances[lastInstanceIndex + 1];
			} else {
				return createTargetInstance();
			}
		}

		protected function createTargetInstance():Object {
			return (new targetClass());
		}
	}
}