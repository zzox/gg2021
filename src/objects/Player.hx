package objects;

import data.Utils;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

typedef HoldsObj = {
    var left:Float;
    var right:Float;
    var up:Float;
    var down:Float;
}

typedef VelTween = {
    var tween:Null<FlxTween>;
    var value:Float;
}

class Player extends FlxSprite {
    static inline final GRAVITY_ACCEL = 800;
    static inline final FLY_UP_ACCEL = -1600;
    static inline final X_ACCEL = 800;
    static inline final X_MAX_VEL = 180;
    static inline final MAX_UP_VEL = 120;
    static inline final MAX_FLOAT_DOWN_VEL = 120;
    static inline final MAX_DIVE_DOWN_VEL = 360;

    static inline final MAX_VEL_TWEEN_TIME = 0.5;

    var lrVel:Int = 0;
    var udVel:Int = 0;
    var curVel:Float = 0.;
    var prevPos:FlxPoint;

    var maxXVel:VelTween = { tween: null, value: 200 };
    var maxYVel:VelTween = { tween: null, value: 100 };

    public var currentWind:Null<Wind>;

    var holds:HoldsObj = {
        left: 0,
        right: 0,
        up: 0,
        down: 0
    };

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);

        loadGraphic(AssetPaths.cardinal__png, true, 24, 24);

        setSize(13, 9);
        offset.set(6, 8);

        animation.add('stand', [0]);
        animation.add('run', [0, 1], 15);
        animation.add('dive', [2, 3], 15);
        animation.add('fly', [6, 7, 8], 15);
        animation.add('fly-slow', [9, 10], 15);

        drag.set(100);

        prevPos = new FlxPoint(x, y);

        maxVelocity.set(X_MAX_VEL, MAX_FLOAT_DOWN_VEL);
    }

    override public function update (elapsed:Float) {
        // trace(curVel / elapsed);

        handleInputs(elapsed);
        handleVelocity(elapsed);
        handleAnimation();

        super.update(elapsed);
    }

    function handleAnimation () {
        if (isTouching(FlxObject.DOWN)) {
            if (Math.abs(velocity.x) > 5) {
                animation.play('run');
            } else {
                animation.play('stand');
            }
        } else if (udVel == 1) {
            animation.play('dive');
        } else if (udVel == -1) {
            animation.play('fly-slow');
        } else {
            animation.play('fly');
        }

        if (acceleration.x < 0 && flipX) {
            flipX = false;
        }

        if (acceleration.x > 0 && !flipX) {
            flipX = true;
        }
    }

    function handleVelocity (elapsed:Float) {
        calcVel();

        // set accel vars
        var yAccel:Float = GRAVITY_ACCEL;
        if (udVel == -1) {
            yAccel += FLY_UP_ACCEL;
        }

        var xAccel:Float = X_ACCEL * lrVel;

        // set maxVel vars
        var xMaxVel:Float = X_MAX_VEL;
        var yMaxVel:Float = velocity.y < 0
            ? MAX_UP_VEL
            : udVel == 1
                ? MAX_DIVE_DOWN_VEL
                : MAX_FLOAT_DOWN_VEL;

        // update accel and maxVel from wind
        if (currentWind != null) {
            if (currentWind.dir == Left || currentWind.dir == Right) {
                // only set max accel if going with wind
                if ((currentWind.dir == Left && velocity.x <= 0) || (currentWind.dir == Right && velocity.x >= 0)) {
                    xMaxVel = currentWind.vel;
                }

                xAccel += currentWind.vel * (currentWind.dir == Left ? -1 : 1);
            }

            if (currentWind.dir == Up || currentWind.dir == Down) {
                if ((currentWind.dir == Up && velocity.y <= 0) || (currentWind.dir == Down && velocity.y >= 0)) {
                    yMaxVel = currentWind.vel;
                }

                trace(currentWind.vel * (currentWind.dir == Up ? -1 : 1));

                yAccel += currentWind.vel * (currentWind.dir == Up ? -1 : 1);
            }
        }

        trace(xAccel, yAccel);
        acceleration.set(xAccel, yAccel);

        handleMaxVelocity(xMaxVel, yMaxVel);
    }

    // if max vel is different than what is currently set, tween to it
    function handleMaxVelocity(x:Float, y:Float) {
        if (x == maxVelocity.x) {
            if (maxXVel.tween != null) {
                maxXVel.tween.cancel();
                maxXVel.tween = null;
            }
        } else {
            if (maxXVel.tween == null || x != maxXVel.value) {
                maxXVel.tween = FlxTween.tween(maxVelocity, { x: x }, MAX_VEL_TWEEN_TIME);
            }

            maxXVel.value = x;
        }

        if (y == maxVelocity.y) {
            if (maxYVel.tween != null) {
                maxYVel.tween.cancel();
                maxYVel.tween = null;
            }
        } else {
            if (maxYVel.tween == null || y != maxYVel.value) {
                maxYVel.tween = FlxTween.tween(maxVelocity, { y: y }, MAX_VEL_TWEEN_TIME);
            }

            maxYVel.value = y;
        }
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
