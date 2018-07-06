/*
カス削除くん

The MIT License

Copyright (c) 2010 Yasunobu Ikeda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package myproject.commands
{
	import flash.errors.IOError;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import jp.progression.commands.Command;

	/**
	 * File.getDirectoryListingAsync の Progression 4 用のコマンドです。
	 * @author yasu
	 * 
	 */
	public class GetDirectoryListing extends Command
	{

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		/**
		 * 新しい GetDirectoryListing インスタンスを作成します。
		 * @param file
		 */
		public function GetDirectoryListing(file:File)
		{
			_file = file;

			super(executeFunction, interruptFunction);
		}

		//----------------------------------------------------------
		//
		//   Property 
		//
		//----------------------------------------------------------

		//--------------------------------------
		// files 
		//--------------------------------------

		private var _files:Array;

		/**
		 * File インスタンスを格納した配列を取得します。
		 */
		public function get files():Array
		{
			return _files;
		}

		private var _file:File;

		//----------------------------------------------------------
		//
		//   Function 
		//
		//----------------------------------------------------------

		/**
		 * @private
		 */
		private function executeFunction():void
		{
			_file.addEventListener(FileListEvent.DIRECTORY_LISTING, _file_directoryListingHandler);
			_file.addEventListener(IOErrorEvent.IO_ERROR, _file_ioErrorHandler);
			_file.getDirectoryListingAsync();
		}

		/**
		 * File.getDirectoryListingAsync() の呼び出し時に致命的なエラーが発生してダウンロードが終了した場合に送出されます。
		 */
		private function _file_ioErrorHandler(event:IOErrorEvent):void
		{
			super.throwError(this, new IOError(event.text, event.errorID));
		}

		/**
		 * getDirectoryListingAsyncが完了したときに送出されます。
		 */
		private function _file_directoryListingHandler(event:FileListEvent):void
		{
			// データを保持する
			_files = event.files;

			// 破棄する
			_destroy();

			// 処理を終了する
			super.executeComplete();
		}

		/**
		 * @private
		 */
		private function interruptFunction():void
		{
			// 読み込みを閉じる
			try {
				_file.cancel();
			}
			catch ( e:Error ) {}
			
			_destroy();
		}

		/**
		 * 破棄します。
		 */
		private function _destroy():void
		{
			if (_file)
			{
				// イベントリスナーを解除する
				_file.removeEventListener(FileListEvent.DIRECTORY_LISTING, _file_directoryListingHandler);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, _file_ioErrorHandler);
				_file = null;
			}
		}
	}
}