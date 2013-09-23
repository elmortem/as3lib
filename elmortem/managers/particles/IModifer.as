package elmortem.managers.particles {
	
	interface IModifer {
		function init(em:Emitter, cache:int = 20)void;
		function modify(p:IParticle):void;
	};
}