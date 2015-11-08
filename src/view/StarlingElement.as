package view
{
import starling.display.Shape;
import starling.display.Sprite;

public class StarlingElement extends Sprite
{
    private var _hitBox:Sprite;

    public function StarlingElement(pParent:Sprite, pType:String = Constants.RECT, pX:Number = 0, pY:Number = 0, pWidth:Number = 100, pHeight:Number = 100, pRadius:Number = 50, pColor:uint = 0xff0000)
    {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(pColor);
        switch (pType)
        {
            case Constants.RECT:
                shape.graphics.drawRect(-pWidth / 2, -pHeight / 2, pWidth, pHeight);
                break;
            case Constants.CIRCLE:
                shape.graphics.drawCircle(0, 0, pRadius);
                break;
            case Constants.ROUND_RECT:
                shape.graphics.drawRoundRect(-pWidth / 2, -pHeight / 2, pWidth, pHeight, pRadius);
                break;
        }

        shape.graphics.endFill();
        addChild(shape);
        x = pX;
        y = pY;
        pParent.addChild(this);

        // using hitbox for correct bounds calculation. to exclude children from bounds calculations
        var hitBoxShape:Shape = new Shape();
        hitBoxShape.graphics.beginFill(0x00ff00, 0);
        hitBoxShape.graphics.drawRect(0, 0, shape.width, shape.height);
        hitBoxShape.graphics.endFill();

        _hitBox = new Sprite();
        _hitBox.x = -shape.width / 2;
        _hitBox.y = -shape.height / 2;
        _hitBox.touchable = false;
        _hitBox.addChild(hitBoxShape);

        addChild(_hitBox);
    }

    public function get hitBox():Sprite {
        return _hitBox;
    }
}
}
