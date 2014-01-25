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
		
		[Embed(source = "../assets/Music/whateversoothsyoubest.mp3")] private var _backgroundMusic:Class;
		private var level:Level;
		private var _currentLevel:uint;
		private var maxWallBreakers:uint = 1;
		
		private var _player:Player;
		private var _wallbreakers:FlxGroup = new FlxGroup();
		
		public function GameState(selectedLevel:uint) 
		{
			super();
			
			_currentLevel = selectedLevel;
			FlxG.playMusic(_backgroundMusic, 1);
		}
		override public function create():void 
		{	
			level = new Level();
			level.LoadLevelData(LevelDataManager.getLevelData(_currentLevel));
			
			add(_wallbreakers);
			
			_player = new Player(level.spawn.x, level.spawn.y);
			add(_player);
			
			FlxG.camera.scroll.x = level.width / 2 - FlxG.width / 2;
			FlxG.camera.scroll.y = level.height / 2 - FlxG.height / 2;
			
			super.create();
		}
		
		override public function update():void 
		{
			FlxG.collide(_player, level.layers[level.currentLayer], CollidePlayerLevel);
			
			FlxG.overlap(_player, level.switches, OverlapPlayerSwitch);
			FlxG.overlap(_player, level.endPortal, OverlapPlayerPortal);
			
			if (FlxG.keys.justPressed("SPACE") && !_player.moving) {
				var tileindex:int = Math.floor(_player.x / 64) + (Math.floor(_player.y / 64) * level.layers[level.currentLayer].widthInTiles);
				ToggleWallbreaker(tileindex);
			}
			super.update();
		}
		
		private function ToggleWallbreaker(tileindex:int):void {
			var exists:Boolean = false;
			var breakersToDelete:Array = new Array();
			for (var i:int = 0; i < _wallbreakers.length; i++) {
				if (_wallbreakers.members[i].tileIndex == tileindex && _wallbreakers.members[i].layerId == level.currentLayer) {
					breakersToDelete.push(_wallbreakers.members[i]);
					for (var j:int = 0; j < _wallbreakers.members[i].breakLayers.length; j++) {
						level.layers[_wallbreakers.members[i].breakLayers[j]].setTileByIndex(_wallbreakers.members[i].breakTileIndex[j], _wallbreakers.members[i].breakTileType[j]);
					}
					_wallbreakers.members[i].kill();
					exists = true;
				} else if (_wallbreakers.members[i].tileIndex == tileindex) {
					exists = true;
				}
			}
			for (var m:int = 0; m < level.switches.length; m++) {
				if (level.switches.members[m].x == _player.x && level.switches.members[m].y == _player.y) {
					exists = true;
				}
			}
			if (!exists && _wallbreakers.length < maxWallBreakers) {
				var wallbreaker:WallBreaker = new WallBreaker(_player.x, _player.y, tileindex, level.currentLayer);
				wallbreaker.color = level.getLayerBackground(level.currentLayer);
				_wallbreakers.add(wallbreaker);
				
				for (var k:int = 0; k < level.layers.length; k++)
				{
					if (level.layers[k].getTileByIndex(tileindex) != 0) {
						wallbreaker.AddBreakPoint(k, tileindex, level.layers[k].getTileByIndex(tileindex));
						level.layers[k].setTileByIndex(tileindex, 0);
					}
				}
			}
			for (var l:int = 0; l < breakersToDelete.length; l++) {
				_wallbreakers.remove(breakersToDelete[l], true);
			}
		}
		
		private function NextLevel():void {
			try{
				level = new Level();
				level.LoadLevelData(LevelDataManager.getLevelData(_currentLevel));
				_wallbreakers = new FlxGroup();
				add(_wallbreakers);
				
				_player = new Player(level.spawn.x, level.spawn.y);
				add(_player);
			}catch (e:Error) {
				trace(e.message);
				if (e.message == "[LDM] level does not exist") {
					trace("NEXT LEVEL");
					FlxG.switchState(new LevelState());
				}
			}
		}
		
		private function CollidePlayerLevel(player:Player, level:FlxTilemap):void {
			player.HandleCollision();
		}
		private function OverlapPlayerSwitch(player:Player, object:Switch):void {
			//trace("switch LL:"+level.currentLayer+"CL" + object.currentLayer + "TL" + object.targetLayer + " touched:" + object.touched);
			//trace(player.x +", "+player.y)
			//trace(Math.floor( player.x) == object.x && Math.floor( player.y ) == Math.floor(object.y));
			if(level.currentLayer == object.currentLayer){
				if (!object.touched && Math.floor( player.x) == object.x && Math.floor( player.y ) == Math.floor(object.y)) {
					//trace("SWITCH LAYER")
					object.touched = true;
					level.SwitchToLayer(object.targetLayer);
					for (var i:int = 0; i < _wallbreakers.length; i++) {
						if (_wallbreakers.members[i].layerId == level.currentLayer) {
							_wallbreakers.members[i].alpha = 1;
						} else {
							_wallbreakers.members[i].alpha = 0.5;
						}
					}
				}else if (!(Math.floor( player.x) == object.x && Math.floor( player.y ) == Math.floor(object.y))) {
					//trace("TOUCH FALSE")
					object.touched = false;
				}
			}
		}
		private function OverlapPlayerPortal(player:Player, object:EndPortal):void {
			if (player.x % 64 == 0 && player.y % 64 == 0) {
				_wallbreakers.clear();
			
				level.kill();
				player.kill();
				_currentLevel++;
				NextLevel();
			}
		}
	}

}