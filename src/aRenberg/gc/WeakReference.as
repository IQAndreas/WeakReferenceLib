package aRenberg.gc 
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;

	/**
	 * @author Andreas Renberg (IQAndreas)
	 * 
	 * A few thoughts, I don't want to have the class check if it's been collected every frame.
	 * If users want that, they can do so manually by calling "WeakReference.updateAll()".
	 * I'd rather save on performance for those projects that need it.
	 * 
	 * Second, I do like the idea of dispatching an Event when the item has been collected, but
	 * since we aren't checking every frame, I decided to put the logic to dispatch the event
	 * inside of the "getTarget()" function. This could lead to some issues if people are using 
	 * the Event listener AND calling "getTarget()" which may cause one of their event handlers
	 * to be called in the middle of the function that's calling "getTarget()".
	 * 
	 * If users aren't warned of these issues, it could lead to some annoying and unexpected results.
	 * 
	 * Where else do I check if a reference has been garbage collected if I'm not calling it 
	 * automatically each frame? Hm...
	 */
	public class WeakReference extends EventDispatcher 
	{
		
		private static var references:Vector.<WeakReference> = new Vector.<WeakReference>();
		public static function updateAll():void
		{
			for each (var reference:WeakReference in references) 
			{
				reference.update();
			}
		}
		
		
		public static const COLLECTED:String = "WeakReference::collected";
		
		public function WeakReference(target:Object) 
		{
			super(this);
			
			if (!isValidTarget(target))
			{
				throw new Error("[WeakReference] Target is not a garbage collectable object.");
			}
			else if (target is WeakReference)
			{
				throw new Error("[WeakReference] Are you trying to pull some sort of Inception crap?");
			}
			else
			{
				dictionary = new Dictionary(true);
				dictionary[target] = true;
				
				//Make sure the WeakReference isn't garbage collected!
				references.push(this);
			}
		}
		
		private function isValidTarget(target:Object):Boolean
		{
			// I really wish the "switch" statement worked with these
			// Perhaps I could use the "constructor" property? 
			// But that can be overridden... Hmmm...
			
			if (!target) 			return false;
			if (target is String) 	return false;
			if (target is int) 		return false;
			if (target is uint) 	return false;
			if (target is Number)	return false;
			
			// The object is garbage collectable!
			return true;
		}
		
		private var dictionary:Dictionary;
		
		// Returns 'null' if the target has already been garbage collected.
		public function getTarget():Object
		{
			//Has already been collected before
			if (!dictionary) return null;
			
			for (var key:Object in dictionary) 
			{
				return key;
			}
			
			//Key has been collected. This message will self destruct.
			this.destroy();
			return null;
		}
		
		public function isCollected():Boolean
		{
			return !this.getTarget();
		}
		
		
		// Checks if the target has been garbage collected.
		// The "getTarget" handles the actual destruction in such an event.
		protected function update():void
		{
			this.getTarget();
		}
		
		// Make yourself available for garbage collection, and alert all listeners of being collected.
		protected function destroy():void
		{			
			var index:int = references.indexOf(this);
			if (index >= 0) { references.splice(index, 1); }

			dictionary = null;
			
			this.dispatchEvent(new Event(WeakReference.COLLECTED, false, false));
		}
		

		
	}
}
