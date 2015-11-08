package control
{
import flash.geom.Point;

import model.AppModel;

import model.ModelLocator;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import view.StarlingElement;

import view.StarlingScene;

import vo.ChildVO;

/**
 * Control classes for drag and drop logic.
 * Maintained separate Control classes for Starling and Software Sprites in order to maintain type checking and avoid mistakes caused by using too many dynamic types
 * On a project of this small scale this is acceptable
 */

public class StarlingSceneControl
{
    private var _view:StarlingScene;

    private var _xPos:int;
    private var _yPos:int;
    private var _currentDragged:StarlingElement;

    private var _model:AppModel;

    public function StarlingSceneControl(pView:StarlingScene)
    {
        _view = pView;

        _model = ModelLocator.instance.appModel;

        _initObjects();
    }

    /**
     * Initialize forms and their children using the parsed layout JSON
     *  @private
     */
    private function _initObjects():void
    {
        for(var i:int = 0, l:int = _model.children.length; i < l; i++)
        {
            var formVO:ChildVO = _model.children[i];
            formVO.view = new StarlingElement(_view, formVO.shapeType, formVO.x, formVO.y, formVO.width, formVO.height, formVO.radius, formVO.color);
            _addListeners(formVO.view);


            for(var j:int = 0, k:int = formVO.children.length; j < k; j++)
            {
                var childVO:ChildVO = formVO.children[j];
                childVO.view = new StarlingElement(formVO.view, childVO.shapeType, childVO.x, childVO.y, childVO.width, childVO.height, childVO.radius, childVO.color);
                _addListeners(childVO.view);

            }
        }
    }

    /**
     * Get the target position before drag
     * @param target
     *  @private
     */
    private function _getPosition(target:Object):void
    {
        _xPos = target.x;
        _yPos = target.y;
    }

    private function _checkCollision(object1:StarlingElement, object2:StarlingElement):Boolean
    {
        return object1.hitBox.getBounds(_view).intersects(object2.hitBox.getBounds(_view))
    }

    /**
     * Handling touch events needed to simulate dragging
     *  @private
     */
    private function _touchHandler(e : TouchEvent):void
    {
        var target:StarlingElement = e.currentTarget as StarlingElement;
        var touch:Touch = e.getTouch(_view.stage);

        if(!touch)
        {
            return;
        }

        var position:Point = touch.getLocation(target.parent);

        if(touch.phase == TouchPhase.BEGAN)
        {
            if(!e.shiftKey && target.parent == _view)
            {
                _dragObject(target);
            }
            else if(e.shiftKey && target.parent != _view)
            {
                _dragObject(target);
            }
        }
        else if(_currentDragged && _currentDragged == target && touch.phase == TouchPhase.ENDED)
        {
            _stopDragObject(_currentDragged.parent.localToGlobal(position));
        }
        else if (_currentDragged && _currentDragged == target && touch.phase == TouchPhase.MOVED)
        {
            _currentDragged.x = position.x;
            _currentDragged.y = position.y;
        }
    }

    /**
     * Start dragging the object on Touch begin
     *  @private
     */
    private function _dragObject(target:StarlingElement):void
    {
        _currentDragged = target;
        _getPosition(_currentDragged);

        _currentDragged.parent.setChildIndex(_currentDragged, _currentDragged.parent.numChildren - 1);
        if(_currentDragged.parent != _view)
        {
            _view.setChildIndex(_currentDragged.parent, _view.numChildren - 1);
        }
    }

    /**
     * Stop dragging the object on Touch end
     *  @private
     */
    private function _stopDragObject(position:Point):void
    {
        if(!_currentDragged)
            return;

        // Get value object tied to the dragged element
        var currentDraggedVO:ChildVO = _model.getVO(_currentDragged);

        // Separate logic gor the container form and elements of the form
        if(_currentDragged.parent != _view)
        {
            var parentVO:ChildVO = _model.getVO(_currentDragged.parent);

            // Here we put the element at the back of the children vector of the form container
            // This allows for the correct layering after layout has been loaded from the Shared Object
            parentVO.children.splice(parentVO.children.indexOf(currentDraggedVO), 1);
            parentVO.children.push(currentDraggedVO);

            var form:StarlingElement;
            for(var i:int = 0, l:int = _view.numChildren; i < l; i++)
            {
                form = _view.getChildAt(i) as StarlingElement;

                // Check if the form this element is touching is not the form it originated from
                // If it is not place it inside the form with new local coordinates,
                // To correctly save the new layout, remove element's VO from ex parents VO children and push it inside new parents VO children
                var newParentVO:ChildVO;
                if (_checkCollision(_currentDragged, form) && _currentDragged.parent != form)
                {
                    newParentVO = _model.getVO(form);

                    var point:Point = form.globalToLocal(position);
                    _currentDragged.x = point.x;
                    _currentDragged.y = point.y;
                    form.addChild(_currentDragged);

                    newParentVO.children.push(parentVO.children.pop());

                    break;
                }
                else if (_checkCollision(_currentDragged, form))
                {
                    newParentVO = parentVO;
                }
            }

            if(!newParentVO)
            {
                _currentDragged.x = _xPos;
                _currentDragged.y = _yPos;
            }
        }
        else
        {
            // Here we put the form at the back of the children vector of the model
            // This allows for the correct layering after layout has been loaded from the Shared Object
            _model.children.splice(_model.children.indexOf(currentDraggedVO), 1);
            _model.children.push(currentDraggedVO);
        }

        // Remember the new coordinates in the VO in order for them to be saved correctly
        currentDraggedVO.x = _currentDragged.x;
        currentDraggedVO.y = _currentDragged.y;

        _currentDragged = null;

        // Save current layout after every interaction with an element
        _model.saveLayout();
    }

    /**
     * Add listeners to target object
     *  @private
     */
    private function _addListeners(object:Object):void
    {
        object.addEventListener(TouchEvent.TOUCH, _touchHandler);
    }
}
}
