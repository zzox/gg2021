package objects;

import flixel.FlxSprite;

class Player extends FlxSprite {
    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        makeGraphic(16, 8, 0xff0d2030);
        setSize(16, 8);

        maxVelocity.set();
    }

    override public function update (elapsed:Float) {
        handleInputs(elapsed);

        super.update(elapsed);
    }

    function handleInputs (elapsed:Float) {
        if (true) {}
    }
}
