package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

typedef HoldsObj = {
    var left:Float;
    var right:Float;
    var up:Float;
    var down:Float;
}

class Player extends FlxSprite {
    static inline final GRAVITY_ACCEL = 800;
    static inline final FLY_UP_ACCEL = -1000;
    static inline final X_ACCEL = 500;
    static inline final X_MAX_VEL = 200;
    static inline final MAX_UP_VEL = 100;
    static inline final MAX_FLOAT_DOWN_VEL = 100;
    static inline final MAX_DIVE_DOWN_VEL = 300;

    var lrVel:Int = 0;
    var udVel:Int = 0;
    var curVel:Float = 0.;
    var prevPos:FlxPoint;

    var holds:HoldsObj = {
        left: 0,
        right: 0,
        up: 0,
        down: 0
    };

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        makeGraphic(16, 8, 0xff0d2030);
        setSize(16, 8);

        drag.set(100);

        prevPos = new FlxPoint(x, y);
    }

    override public function update (elapsed:Float) {
        handleInputs(elapsed);
        handleVelocity(elapsed);

        super.update(elapsed);
    }

    function handleVelocity (elapsed:Float) {
        calcVel();
        // trace(curVel / elapsed);

        var yAccel = GRAVITY_ACCEL;
        if (udVel == -1) {
            yAccel += FLY_UP_ACCEL;
        }

        acceleration.set(X_ACCEL * lrVel, yAccel);
        maxVelocity.set(
            X_MAX_VEL,
            velocity.y < 0
                ? MAX_UP_VEL
                : udVel == 1
                    ? MAX_DIVE_DOWN_VEL
                    : MAX_FLOAT_DOWN_VEL
        );
    }

    function handleInputs (elapsed:Float) {
        var controlsPressed = {
            left: FlxG.keys.pressed.LEFT,
            right: FlxG.keys.pressed.RIGHT,
            up: FlxG.keys.pressed.UP,
            down: FlxG.keys.pressed.DOWN
        }

        lrVel = 0;
        udVel = 0;

        if (controlsPressed.left) {
            lrVel = -1;
            holds.left += elapsed;
        }

        if (controlsPressed.right) {
            lrVel = 1;
            holds.right += elapsed;
        }

        if (controlsPressed.left && controlsPressed.right) {
            if (holds.right > holds.left) {
                lrVel = -1;
            } else {
                lrVel = 1;
            }
        }

        if (controlsPressed.up) {
            udVel = -1;
            holds.up += elapsed;
        }

        if (controlsPressed.down) {
            udVel = 1;
            holds.down += elapsed;
        }

        if (controlsPressed.up && controlsPressed.down) {
            if (holds.down > holds.up) {
                udVel = -1;
            } else {
                udVel = 1;
            }
        }
    }

    function calcVel () {
        curVel = Math.sqrt(Math.pow(prevPos.x - x, 2) + Math.pow(prevPos.y - y, 2));

        prevPos = new FlxPoint(x, y);
    }
}
