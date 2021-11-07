import data.Utils;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import objects.Player;

// TODO: consider moving?
class Windbox extends FlxObject {
    public var direction:Dir;
    public var vel:Int;

    public function new (x, y, width, height, direction, vel) {
        super(x, y, width, height);
        this.direction = direction;
        this.vel = vel;
    }
}

class PlayState extends FlxState {
    static inline final Y_MAP_OFFSET = -8;

    var groundLayer:FlxTilemap;
    var winds:FlxTypedGroup<Windbox>;
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

        winds = new FlxTypedGroup<Windbox>();
        if (map.getLayer('wind') != null) {
            final w = cast(map.getLayer('wind'), TiledObjectLayer).objects;
            w.map(windItem -> {
                final windDir = windItem.properties.get('direction');

                final wind = new Windbox(
                    windItem.x,
                    windItem.y + Y_MAP_OFFSET,
                    windItem.width,
                    windItem.height,
                    stringToDir(windDir),
                    // MD:
                    600
                );

                winds.add(wind);
            });
        }
        add(winds);

        // MD:
        FlxG.worldBounds.set(0, 0, 640, 360);
        FlxG.camera.setScrollBounds(0, 640, 0, 360);

        FlxG.camera.follow(player);

        bgColor = 0xff98dcff;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        FlxG.collide(groundLayer, player);

        // check if in a wind box.  If not, set wind to null.
        if (!FlxG.overlap(winds, player, windEffectPlayer)) {
            player.currentWind = null;
        }
    }

    function windEffectPlayer (wind:Windbox, player:Player) {
        player.currentWind = { dir: wind.direction, vel: wind.vel };
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
