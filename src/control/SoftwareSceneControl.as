package control
{
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;

import model.AppModel;

import model.ModelLocator;

import view.SoftwareElement;

import view.SoftwareScene;

import vo.ChildVO;

/**
 * Control classes for drag and drop logic.
 * Maintained separate Control classes for Starling and Software Sprites in order to maintain type checking
 * and avoid mistakes caused by using too many dynamic types.
 * On a project of this small scale this is acceptable
 */

public class SoftwareSceneControl
{
    private var _view:SoftwareScene;

    private var _xPos:int;
    private var _yPos:int;
    private var _currentDragged:SoftwareElement;

    private var _model:AppModel;

    public function SoftwareSceneControl(pView:SoftwareScene)
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
            formVO.view = new SoftwareElement(_view, formVO.shapeType, formVO.x, formVO.y, formVO.width, formVO.height, formVO.radius, formVO.color);
            _addListeners(formVO.view);

            for(var j:int = 0, k:int = formVO.children.length; j < k; j++)
            {
                var childVO:ChildVO = formVO.children[j];
                childVO.view = new SoftwareElement(formVO.view, childVO.shapeType, childVO.x, childVO.y, childVO.width, childVO.height, childVO.radius, childVO.color);
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

    private function _checkCollision(object1:SoftwareElement, object2:SoftwareElement):Boolean
    {
        return object1.hitBox.hitTestObject(object2.hitBox);
    }

    /**
     * Handling mouse events
     *  @private
     */
    private function _mouseHandler(e:MouseEvent):void
    {
        var target:SoftwareElement = (e.shiftKey? e.target : e.currentTarget) as SoftwareElement;

        if(!target)
        {
            return;
        }

        if(e.type == MouseEvent.MOUSE_DOWN)
        {
            _dragObject(target);
        }
        else if(e.type == MouseEvent.MOUSE_UP)
        {
            _stopDragObject(new Point(_view.stage.mouseX, _view.stage.mouseY));
        }
    }


    /**
     * Start dragging the object on mouse down
     *  @private
     */
    private function _dragObject(target:SoftwareElement):void
    {
        _currentDragged = target;
        _getPosition(_currentDragged);

        // Put the dragged element on the top layer and the parent form (if the target is not a form)
        _currentDragged.parent.setChildIndex(_currentDragged, _currentDragged.parent.numChildren - 1);
        if(_currentDragged.parent != _view)
        {
            _view.setChildIndex(_currentDragged.parent, _view.numChildren - 1);
        }
        _currentDragged.startDrag(true);
    }

    /**
     * Stop dragging the object on mouse up
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
            // Get value object tied to the dragged element parent
            var parentVO:ChildVO = _model.getVO(_currentDragged.parent);

            // Here we put the element at the back of the children vector of the form container
            // This allows for the correct layering after layout has been loaded from the Shared Object
            parentVO.children.splice(parentVO.children.indexOf(currentDraggedVO), 1);
            parentVO.children.push(currentDraggedVO);

            var form:SoftwareElement;
            for(var i:int = 0, l:int = _view.numChildren; i < l; i++)
            {
                form = _view.getChildAt(i) as SoftwareElement;

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

            // If element is not touching any form container return it to the last position
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

        _currentDragged.stopDrag();

        _currentDragged = null;

        // Save current layout after every interaction with an element
        _model.saveLayout();
    }

    /**
     * Add listeners to target object
     *  @private
     */
    private function _addListeners(object:DisplayObject):void
    {
        object.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
        object.addEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
    }
}
}
