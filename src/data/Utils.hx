package data;

enum Dir {
    Left;
    Right;
    Up;
    Down;
}

typedef Wind = {
    var dir:Dir;
    var vel:Float;
}

function stringToDir (dir:String):Dir
    return switch (dir) {
        case 'left': Left;
        case 'right': Right;
        case 'up': Up;
        case 'down': Down;
        case _: throw 'Bad Dir';
    }
