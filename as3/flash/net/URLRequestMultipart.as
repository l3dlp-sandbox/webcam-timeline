/**
* URLRequestMultipart
* @author Florian Morello
* @version 1.0
*/
package flash.net
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import flash.net.URLRequestHeader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class URLRequestMultipart
	{
		public var boundary:String;
		private var request:URLRequest;


		function URLRequestMultipart(url:String = null)
		{
			boundary = 'AKMultipart' + URLRequestMultipart.randomBoundary();

			// Init request (cause we can't extend it)
			request = new URLRequest(url);
			request.requestHeaders.push(new URLRequestHeader("Content-type", "multipart/form-data; boundary=" + boundary));
			request.method = URLRequestMethod.POST;
			request.data = new ByteArray();
			request.data.endian = Endian.BIG_ENDIAN;
		}


		public static function randomBoundary(length:Number = 15):String
		{
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var num_chars:Number = chars.length - 1;
			var randomChar:String = "";
			for (var i:Number = 0; i < length; i++)
			{
				randomChar += chars.charAt(Math.floor(Math.random() * num_chars));
			}
			return randomChar;
		}


		private function _writeByte(string:String, endingLineBreak:int = 1):void
		{
			for(var i:int = 0; i < string.length; i++){
				request.data.writeByte(string.charCodeAt(i));
			}
			_linebreak(endingLineBreak);
		}

		/**
		* @param Object {key: value, key2, value, ...}
		**/
		public function addFormFields(parameters:Object = null):void
		{
			//add Filename to parameters
			if(parameters == null)
				parameters = new Object();

			// Parameteres
			for(var name:String in parameters)
			{
				_writeByte('--' + boundary);
				_writeByte('Content-Disposition: form-data; name="' + name + '"', 2);
				request.data.writeUTFBytes(parameters[name]);
				_linebreak();
			}
		}

		public function addFile(inputName:String, fileName:String, contentType:String, data:ByteArray):Boolean
		{
			// File
			_writeByte('--' + boundary);
			_writeByte('Content-Disposition: form-data; name="' + inputName + '"; filename="' + fileName + '"');
			_writeByte('Content-Type: ' + contentType, 2);		   
			request.data.writeBytes(data);
			_linebreak();
			return true;
		}

		public function commitData():Boolean
		{
			// closing boundary
			_writeByte('--' + boundary + '--');
			return true;		
		}

		public function getRequest():URLRequest
		{
			return request;
		}


		/**
		* Add one linebreak
		*/
		private function _linebreak(n:Number = 1):void
		{
			for(var i:int = 0; i < n; i++){
				request.data.writeShort(0x0d0a);
			}
		}
	}
}