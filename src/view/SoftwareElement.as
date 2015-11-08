package view
{
import flash.display.Sprite;

public class SoftwareElement extends Sprite
{
    private var _hitBox:Sprite;

    public function SoftwareElement(pParent:Sprite, pType:String = Constants.RECT, pX:Number = 0, pY:Number = 0, pWidth:Number = 100, pHeight:Number = 100, pRadius:Number = 50, pColor:uint = 0xff0000)
    {
        graphics.beginFill(pColor);
        switch (pType)
        {
            case Constants.RECT:
                graphics.drawRect(-pWidth / 2, -pHeight / 2, pWidth, pHeight);
                break;
            case Constants.CIRCLE:
                graphics.drawCircle(0, 0, pRadius);
                break;
            case Constants.ROUND_RECT:
                graphics.drawRoundRect(-pWidth / 2, -pHeight / 2, pWidth, pHeight, pRadius, pRadius);
                break;
        }

        graphics.endFill();
        x = pX;
        y = pY;
        pParent.addChild(this);

        // using hitbox for correct bounds calculation. to exclude children from bounds calculations
        _hitBox = new Sprite();
        _hitBox.x = -this.width / 2;
        _hitBox.y = -this.height / 2;
        _hitBox.mouseEnabled = false;

        _hitBox.graphics.beginFill(0x00ff00, 0);
        _hitBox.graphics.drawRect(0, 0, this.width, this.height);
        _hitBox.graphics.endFill();

        addChild(_hitBox);
    }

    public function get hitBox():Sprite {
        return _hitBox;
    }
}
}
