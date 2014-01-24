package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Nerdy Boyz
	 */
	public class GameState extends FlxState
	{
		public static var tileSize:int = 64;
		
		[Embed(source = '../assets/TELEPORTER MAN Tiles.png')]private var tiles_img:Class;
		[Embed(source = '../assets/CSV_Level_1.txt', mimeType = 'application/octet-stream')]private var lvl_1:Class;
		private var tilemap:Level;
		
		private var _player:Player;
		
		public function GameState() 
		{
			super();
		}
		override public function create():void 
		{
			tilemap = new Level();
			tilemap.LoadLevelData(null);
			
			_player = new Player(00, 00);
			add(_player);
			
			super.create();
		}
		
		override public function update():void 
		{
			FlxG.collide(_player, tilemap.layers[tilemap.currentLayer]);
			
			FlxG.overlap(_player, tilemap.group1, OverlapPlayerSwitch);
			super.update();
		}
		
		private function OverlapPlayerSwitch(a:Player, b:Switch):void {
			if (!b.touched) {
				b.touched = true;
				tilemap.SwitchToLayer(1);
				trace("haai");
			}
		}
	}

}