/**
 * Created by Reesta on 06-Nov-15.
 */
package view
{
import control.SoftwareSceneControl;

import flash.display.Sprite;
import flash.events.Event;

public class SoftwareScene extends Sprite
{
    public function SoftwareScene()
    {
        if (stage) _onStage();
        else addEventListener(Event.ADDED_TO_STAGE, _onStage);
    }

    private function _onStage(e:Event = null):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _onStage);

        new SoftwareSceneControl(this);
    }
}
}
