package model  {

import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;

/**
 *  Dispatched when the Config XML sheet has finished loading
 */
[Event(name="complete", type="flash.events.Event")]

/** 
 *  This class is intended to wrap an XML sheet that contains configuration
 *  values such as: urls, dates, dynamic copy, etc.
 *  
 *  <p>When the object is created, a debug path to an XML sheet can be passed in
 *  for use when running inside the Flash IDE. This value can be overridden by
 *  setting a <em>config</em> flashVar and passing in a URL to the config file.</p>
 *    
 *  @langversion ActionScript 3
 *  @playerversion Flash 9.0.0
 *
 *  @author Marko Ristic
 *  @since  06.08.2009
 */
public class Config extends EventDispatcher {
	
	/**
	 * Config URL
	 *  
	 *  This will either return the value passed in as a debug
	 *  URL when inside the Flash IDE, or the value supplied by
	 *  the config flashVar
	 */
	public function get url():String
	{
	    var configUrl:String;
	    
	    if (__app.root.loaderInfo.parameters.config == null)
	        configUrl = __debugURL;
	    else
	        configUrl = __app.root.loaderInfo.parameters.config;
	    
	    return configUrl;
	}
	
	/**
	 * The XML data that makes up the config file
	 */
	public function get data():XML{ return __data; }
	private var __data:XML;
	
	/**
	 * Flag that says whether the file has finished loading or not
	 */
	public function get loaded():Boolean{ return __loaded; }
	private var __loaded:Boolean = false;
	
	/**
	 * Debug URL string
	 *  @private
	 */
	private var __debugURL:String;
	
	/**
	 * Returns the bytes loaded amount of the loading XML sheet
	 */
	public function get bytesLoaded():Number{ return __bytesLoaded; }
	private var __bytesLoaded:Number;
	
	/**
	 * Returns the total bytes of the loading XML sheet
	 */
	public function get bytesTotal():Number{ return __bytesTotal; }
	private var __bytesTotal:Number;
	
	/**
	 * Reference to main Application
	 *  @private
	 */
	private var __app:Main;
	
	/**
	 * Creates a Config object that is attached to an Application
	 *  
	 *  @param app         Requires that reference to the Main that it is being attached to
	 *                     be passed in
	 *  @param debugURL    The path to the debug url that will be used when the app is run
	 *                     from inside the Flash IDE
	 *  @constructor
	 */
	public function Config(app:Main, debugURL:String = 'xml/config.xml')
	{
		super();
		__app = app;
		__debugURL = debugURL;
	}
	
	/**
	 * Must be run in order to start the loading of the Config file
	 */
	public function init():void
	{
	    __loadConfigXML();
	}
	
	/**
	 * Loads the Config XML sheet
	 *  @private
	 */
	private function __loadConfigXML():void
	{
	    var loader:URLLoader = new URLLoader();
	    loader.addEventListener(Event.COMPLETE, __onXMLLoadComplete);
	    loader.addEventListener(IOErrorEvent.IO_ERROR, __onLoadError);
	    loader.addEventListener(ProgressEvent.PROGRESS, __onLoadProgress);
	    loader.load(new URLRequest(url));
	}
	
	/**
	 * Stores the bytesLoaded and bytesTotal of the loading XML sheet
	 *  @private
	 */
	private function __onLoadProgress($e:ProgressEvent):void
	{
	    __bytesTotal = $e.bytesTotal;
	    __bytesLoaded = $e.bytesLoaded;
	}
	
	/**
	 * Load error handler, is thrown when the XML sheet cannot be found
	 *  @private
	 */
	private function __onLoadError($e:IOErrorEvent):void
	{
	    __bytesLoaded = 0;
	    __bytesTotal = 0;
	    
	    throw new Error('There was an error loading the config file located at: ' + url 
	                    + '. Make sure it exists and that permissions allow it to be read');
	}
	
	/**
	 * XML load COMPLETE handler, throws the COMPLETE event for the config object
	 *  @private
	 */
	private function __onXMLLoadComplete($e:Event):void
	{
	    __data = XML($e.target.data);
	    __loaded = true;
	    dispatchEvent(new Event(Event.COMPLETE));
	}
	
}

}

