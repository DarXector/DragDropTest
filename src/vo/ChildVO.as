/**
 * Value Object for app elements
 * Unified for form containers and its' elements
 */
package vo
{

public class ChildVO extends Object
{
    public var shapeType:String;
    public var x:Number;
    public var y:Number;
    public var width:Number;
    public var height:Number;
    public var radius:Number;
    public var color:uint;
    public var children:Vector.<ChildVO>;

    public var view:*;

    public function ChildVO(obj:Object)
    {
        shapeType = obj.shapeType;
        x = obj.x;
        y = obj.y;
        width = obj.width;
        height = obj.height;
        radius = obj.radius;
        color = uint(obj.color);

        // If an element is a form container it will have a children node with elements
        // Used to easily track the display tree
        children = new <ChildVO>[];
        if(obj.children)
        {
            for(var i: int = 0, l:int = obj.children.length; i < l; i++)
            {
                children.push(new ChildVO(obj.children[i]));
            }
        }
    }
}
}
