package
{
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.Capabilities;

import model.AppModel;
import model.Config;
import model.ModelLocator;

import starling.core.Starling;

import view.SoftwareScene;
import view.StarlingScene;


[SWF(width="800", height="600", frameRate="60", backgroundColor="#222222")]
public class Main extends Sprite
{

    private const XML_URL:String = "config.xml";
    public static var config:Config;

    private var _model:AppModel;

    public function Main()
    {
        _model = ModelLocator.instance.appModel;

        if (stage) _onStage();
        else addEventListener(Event.ADDED_TO_STAGE, _onStage);
    }

    private function _onStage(e:Event = null):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _onStage);

        // Initialize the config loader
        config = new Config(this,XML_URL);
        config.addEventListener(Event.COMPLETE, _init);
        config.init();
    }

    /**
     * Config loaded initialize parsing of the config data
     *  @private
     */
    private function _init(e:Event):void
    {
        _model.modelLoadedSig.add(_onLoaded);
        _model.setDataFromConfig();
    }


    /**
     * Config and saved data loaded.
     * Check if Hardware rendering is preferred an supported.
     * Initialize Starling if it is. If not use classic display list
     *  @private
     */
    private function _onLoaded():void
    {
        var stage3DSupported:Boolean = stage.hasOwnProperty("stage3Ds");

        if(_model.useStage3D && stage3DSupported)
        {

            // Covering all of the options.
            // If the flash player version supports Stage3D
            // If wmode is set to direct
            // If the device/browser supports hardware acceleration
            // If any of this fails we initialize the classic display list
            var myStage3D:Stage3D = stage.stage3Ds[0];
            myStage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            myStage3D.requestContext3D(Context3DRenderMode.AUTO);
            myStage3D.addEventListener(ErrorEvent.ERROR, onStage3DError);

            function onStage3DError ( e:ErrorEvent ):void
            {
                myStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
                myStage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError);

                _initSoftware();
            }
            function onContextCreated ( e:Event ):void
            {
                var context3D:Context3D = myStage3D.context3D;
                var isHW:Boolean = context3D.driverInfo.toLowerCase().indexOf("software") == -1;

                myStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
                myStage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError);

                if(isHW)
                {
                    context3D.dispose();
                    _initStarling();
                }
                else
                {
                    _initSoftware();
                }
            }
        }
        else
        {
            _initSoftware();
        }
    }

    /**
     * Initialize Starling
     *  @private
     */
    private function _initStarling():void
    {
        var starling:Starling = new Starling(StarlingScene, stage, null, null, "auto", "auto");
        starling.enableErrorChecking = Capabilities.isDebugger;
        starling.start();
    }

    /**
     * Initialize software rendering
     *  @private
     */
    private function _initSoftware():void
    {
        var softwareScene:SoftwareScene = new SoftwareScene();
        addChild(softwareScene);
    }
}
}