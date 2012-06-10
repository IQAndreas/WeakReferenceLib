package 
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.display.Sprite;
	import flash.crypto.generateRandomBytes;

	import aRenberg.gc.WeakReference;

	[SWF(backgroundColor="#999999", frameRate="5", width="640", height="480")]
	public class WeakReferenceTestbench extends Sprite 
	{
		public function WeakReferenceTestbench() 
		{
			stage.addEventListener(MouseEvent.CLICK, stageClicked);
		}
		
		private var running:Boolean = false;
		private function stageClicked(event:Event):void
		{
			running = !running;
			
			if (running) { this.beginTest(); }
			else 
			{ 
				this.removeEventListener(Event.ENTER_FRAME, enterFrame);
				trace(" ==== TEST END ===="); 
			}
		}
		
		private function beginTest():void
		{
			var collectedBytes:ByteArray = generateRandomBytes(1024);
			referencedBytes = generateRandomBytes(1024);
			
			ref1 = new WeakReference(collectedBytes);
			ref2 = new WeakReference(referencedBytes);
			
			//And now for a weak reference that gets garbage collected
			var reallyCollectedBytes:ByteArray = generateRandomBytes(1024);
			var collectedRef:WeakReference = new WeakReference(reallyCollectedBytes);
			collectedRef.addEventListener(WeakReference.COLLECTED, garbageCollected);
			
			trace(" ==== TEST BEGIN ====");
			trace("Both byteArrays should still be available");
			trace("\tcollectedBytes", Boolean(ref1.getTarget()));
			trace("\treferencedBytes", Boolean(ref2.getTarget()));
			
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		var referencedBytes:ByteArray;
		
		var ref1:WeakReference;
		var ref2:WeakReference;
		
		private function enterFrame(e:Event):void
		{
			if (!running) { return; }
			
			trace("Updating");
			WeakReference.updateAll();
			trace("\tcollectedBytes", Boolean(ref1.getTarget()));
			trace("\treferencedBytes", Boolean(ref2.getTarget()));
		}
		
		private function garbageCollected(event:Event):void
		{
			trace("reallyCollectedBytes has been collected!");
		}
	}
}
