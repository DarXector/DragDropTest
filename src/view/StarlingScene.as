package view
{
import control.StarlingSceneControl;
import starling.display.Sprite;
import starling.events.Event;

public class StarlingScene extends Sprite
    {
        public function StarlingScene()
        {
            if (stage) _onStage();
            else addEventListener(Event.ADDED_TO_STAGE, _onStage);
        }

        private function _onStage(e:Event = null):void
        {
            new StarlingSceneControl(this);
        }
    }
}