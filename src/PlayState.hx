package;

import flixel.FlxState;
import objects.Player;

class PlayState extends FlxState {
    override public function create() {
        super.create();

        camera.pixelPerfectRender = true;

        add(new Player(160, 16, this));
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}
