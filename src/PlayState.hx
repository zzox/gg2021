package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import objects.Player;

class PlayState extends FlxState {
    static inline final Y_MAP_OFFSET = -8;

    var groundLayer:FlxTilemap;
    var player:Player;

    override public function create() {
        super.create();

        camera.pixelPerfectRender = true;

        // MD:
        final map = new TiledMap(AssetPaths.soar_test__tmx);
        groundLayer = createTileLayer(map, 'ground');
        add(groundLayer);

        player = new Player(160, 16, this);
        add(player);

        // MD:
        FlxG.worldBounds.set(0, 0, 640, 360);
        FlxG.camera.setScrollBounds(0, 640, 0, 360);

        FlxG.camera.follow(player);

        bgColor = 0xff98dcff;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        FlxG.collide(groundLayer, player);
    }

    function createTileLayer (map:TiledMap, layerName:String):Null<FlxTilemap> {
        var layerData = map.getLayer(layerName);
        if (layerData != null) {
            var layer = new FlxTilemap();
            layer.loadMapFromArray(cast(layerData, TiledTileLayer).tileArray, map.width, map.height,
                AssetPaths.tiles__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1)
                .setPosition(0, Y_MAP_OFFSET);

            layer.useScaleHack = false;
            add(layer);

            return layer;
        }
        return null;
    }
}
