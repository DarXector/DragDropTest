package model
{
/**
 * Main application model
 * @author Marko Ristic
 */

import flash.net.SharedObject;

import org.osflash.signals.Signal;

import vo.ChildVO;

public class AppModel
{
    private var __xml:XML;
    private var __loaded:Boolean;
    private var __modelLoadedSig:Signal = new Signal();
    private var _useStage3D:Boolean;

    // Default layout, used when the app is first used on a device
    public static var defaultLayout:String = "" +
            '{"children":' +
                '[' +
                    '{' +
                        '"id":"form_0", "shapeType":"rect", "x":175, "y":200, "width":300, "height":300, "radius":0, "color":"0xE9FFA7",' +
                        '"children":' +
                        '[' +
                            '{"id":"form_0_child_0", "shapeType":"rect", "x":-75, "y":-75, "width":100, "height":100, "radius":0, "color":"0x009933"},' +
                            '{"id":"form_0_child_1", "shapeType":"circle", "x":70, "y":-70, "width":0, "height":0, "radius":50, "color":"0x00FF00"},' +
                            '{"id":"form_0_child_2", "shapeType":"round_rect", "x":0, "y":70, "width":100, "height":100, "radius":40, "color":"0x336600"}' +
                        ']' +
                    '},' +
                    '{' +
                        '"id":"form_1", "shapeType":"rect", "x":625, "y":425, "width":300, "height":300, "radius":0, "color":"0xC9DBFF",' +
                        '"children":' +
                        '[' +
                            '{"id":"form_1_child_0", "shapeType":"rect", "x":-75, "y":-75, "width":100, "height":100, "radius":0, "color":"0x528CFF"},' +
                            '{"id":"form_1_child_1", "shapeType":"circle", "x":70, "y":-70, "width":0, "height":0, "radius":50, "color":"0x3366FF"},' +
                            '{"id":"form_1_child_2", "shapeType":"round_rect", "x":0, "y":70, "width":100, "height":100, "radius":40, "color":"0x0066FF"}' +
                        ']' +
                    '}' +
                ']' +
            '}';

    private var _children:Vector.<ChildVO>;


    public function AppModel()
    {

    }

    public function get loaded():Boolean
    {
        return __loaded;
    }

    /**
     * Setting loaded to true dispatches the loaded signal
     *  @public
     */
    public function set loaded(value:Boolean):void{
        __loaded = value;
        if(__loaded) __modelLoadedSig.dispatch();
    }

    /**
     * Parsing data from the config.xml and saved shared object if there is any
     *  @public
     */
    public function setDataFromConfig():void
    {
        __xml = Main.config.data as XML;

        // Parse xml
        _useStage3D = parseInt(__xml["Stage3D"]);

        // Get shared object
        var savedData:SharedObject = SharedObject.getLocal("drag_drop_app");

        // If there is no shared object with this id that has data, load a default layout JSON
        var layout:Object;
        if(savedData.size > 0 && savedData.data.layout)
        {
            layout = JSON.parse(savedData.data.layout);
        }
        else
        {
            layout = JSON.parse(defaultLayout);
        }

        // Store parsed layout inside Child value objects and those VO inside a vector for easy access
        _children = new <ChildVO>[];
        for(var i: int = 0, l:int = layout.children.length; i < l; i++)
        {
            _children.push(new ChildVO(layout.children[i]));
        }

        loaded = true;
    }

    /**
     * Get a VO for a given display object
     *  @public
     */
    public function getVO(sprite:*):ChildVO
    {
        for(var i:int = 0, l:int = _children.length; i < l; i++)
        {
            var formVO:ChildVO = _children[i];

            if(sprite == formVO.view)
            {
                return formVO;
            }

            for(var j:int = 0, k:int = formVO.children.length; j < k; j++)
            {
                var childVO:ChildVO = formVO.children[j];

                if(sprite == childVO.view)
                {
                    return childVO;
                }
            }
        }
        return null;
    }

    /**
     * when saving the current layout we don't need everything, in this case we don't need reference to display objects
     *  @private
     */
    private function _replacer(key:String, value:*):*
    {
        if (key == "view") return undefined;
        else return value;
    }

    /**
     * Save the current layout.
     * Stringify value objects into JSON and save it to shared object.
     *  @public
     */
    public function saveLayout():void
    {
        var saveString:String = '{"children":' + JSON.stringify(_children, _replacer) + '}';
        trace("saveLayout saveString", saveString);

        var savedData:SharedObject = SharedObject.getLocal("drag_drop_app");
        savedData.data.layout = saveString;
        savedData.flush();
    }

    public function get xml():XML { return __xml; }

    public function get modelLoadedSig():Signal { return __modelLoadedSig; }

    public function get useStage3D():Boolean
    {
        return _useStage3D;
    }

    public function get children():Vector.<ChildVO> {
        return _children;
    }
}
}