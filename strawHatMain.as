package 
{
	import flash.display.Sprite;
	
	/**
	 * strawHat
	 * @author winterIce
	 */
	public class strawHatMain extends Sprite
	{
		private var mainScene:strawHatMainScene;
		public function strawHatMain():void 
		{
			mainScene = new strawHatMainScene();
			this.addChild(mainScene);
		}
		
	}
	
}