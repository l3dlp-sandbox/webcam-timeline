/**
* AKWebcam
* @author Florian Morello
* @version 1.0
*/
package {

	import flash.display.Sprite;
	import flash.system.Security;

	// to fit swf size
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	// Jpeg encoding
	import com.adobe.images.JPGEncoder;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import flash.net.URLLoader;

	import flash.net.URLRequestMultipart;

	// video
	import flash.media.Video;

	// webcam
	import flash.media.Camera;

	// events
	import flash.events.*;

	// js call
	import flash.external.ExternalInterface;

	// flashvars
	import flash.display.LoaderInfo;

	import JSON;

	flash.system.Security.allowDomain('*');

	public class AKWebcam extends Sprite
	{
		public var fVars:Object;
		// Stage video
		public var video:Video;
		// Video for capturing image (larger than stage)
		public var vCam:Video;
		// Webcam
		public var cam:Camera;

		function AKWebcam()
		{
			// store externals flash vars
			fVars = LoaderInfo(this.root.loaderInfo).parameters;

			this._dispatchEvent('swf_loaded');
			this._dispatchEvent('params_passed', fVars);
			// fit swf size
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			this._hookExternalCalls();

			// Stage video
			video = new Video(fVars['movieWidth'], fVars['movieHeight']);

			if(this._attachCamera())
			{
				addChild(video);
			}
		}

		private function _attachCamera():Boolean
		{
			if(Camera.isSupported && Camera.names.length > 0)
			{
				this._dispatchEvent('camera_found', Camera.names.length);
				cam = Camera.getCamera();
				cam.addEventListener(StatusEvent.STATUS, _cameraEvents);
				cam.setMode(fVars['cameraWidth'], fVars['cameraHeight'], 30, true);
				video.attachCamera(cam);
				vCam = new Video(cam.width, cam.height);
				vCam.attachCamera(cam);
				// In case of remember checkbox checked
				this._dispatchEvent('camera_event', cam.muted ? 'Camera.Muted' : 'Camera.Unmuted');
				return true;
			}
			else
				this._dispatchEvent('camera_not_found');

			return false;
		}

		private function _cameraEvents(event:StatusEvent):void
		{
			this._dispatchEvent('camera_event', event.code);
		}

		private function _hookExternalCalls():void
		{
			if(ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback("swfCall", _swfCall);
				}
				catch (error:Error)
				{
					this._dispatchEvent('external_interface_error');
				}
			}
			else
			{
				this._dispatchEvent('external_interface_not_available');
			}
		}

		/**
		 * Javascript interface
		 * Allow JS to call AS method
		 **/
		private function _swfCall(calling:String, params:Object):void
		{
 			if(this.hasOwnProperty(calling))
 				this[calling].apply(null, [params]);
 			else
				this._dispatchEvent('unknown_method', calling);
		}

		private function _dispatchEvent(type:String, value:* = null):void
		{
			var event:Object = {
				name: type
			};
			if(value != null)
				event.value = value;

			ExternalInterface.call(fVars['eventListener'], event);
		}

		private function _snapShot():ByteArray
		{
			var jpgSource:BitmapData = new BitmapData(vCam.width, vCam.height);
			addChild(vCam);
			jpgSource.draw(vCam);
			removeChild(vCam);
			var jpgEncoder:JPGEncoder = new JPGEncoder(90);
			return jpgEncoder.encode(jpgSource);
		}

		public function capture(params:Object):void
		{
			var multiPartRequest:URLRequestMultipart = new URLRequestMultipart(params.target);
			// Add Fields
			multiPartRequest.addFormFields(params.fields);
			// Add Picture
			multiPartRequest.addFile(params.fileInputName, "AKWebcam.jpg", "image/jpeg", this._snapShot());
			// Add ending boundary
			multiPartRequest.commitData();

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, _completeHandler);
			loader.load(multiPartRequest.getRequest());
		}

		private function _completeHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			this._dispatchEvent('upload_success', JSON.parse(loader.data));
		}
	}
}