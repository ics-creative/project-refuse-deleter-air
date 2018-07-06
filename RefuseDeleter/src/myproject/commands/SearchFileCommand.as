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
	import flash.filesystem.File;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import jp.progression.commands.Command;
	import jp.progression.commands.Func;
	import jp.progression.commands.Wait;
	import jp.progression.commands.lists.SerialList;
	
	import myproject.data.FileName;
	import myproject.data.FolderName;
	import myproject.data.SelectedForm;

	/**
	 * SearchFileCommand はカスファイルを検索するProgression用のコマンドクラスです。
	 * @author yasu
	 * @version 1.0.0
	 */
	public class SearchFileCommand extends SerialList
	{
		private static const ASYNC_RESUME_COUNT:Number = 50;
		private static const GC_COUNT:Number = 500;
		private static const WAIT_TIME:Number = 1.000 / 60 * 2;

		/**
		 * 新しい SearchFileCommand インスタンスを作成します。
		 */
		public function SearchFileCommand(dir:File, form:SelectedForm)
		{
			_dir = dir;
			_form = form;

			_seachCount = 0;
			_seachTotal = 0;
			_fileArr = new Vector.<File>;
			
			addCommand(
				new Func(searchCore, [ dir ])
				);
		}

		public function get fileArr():Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < _fileArr.length; i++)
			{
				arr[i] = _fileArr[i];
			}
			return arr;
		}

		public function get seachCount():int
		{
			return _seachCount;
		}

		private var _form:SelectedForm;
		private var _seachCount:int = 0;
		private var _seachTotal:int = 0;
		private var _asyncCnt:int;
		private var _fileArr:Vector.<File>;
		private var _dir:File;

		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_form = null;
			_seachCount = 0;
			_seachTotal = 0;
			_asyncCnt = 0;
			_fileArr = null;
			_dir = null;

			super.dispose();
		}

		/**
		 * フォルダリスティングのコア処理です。
		 */
		protected function searchCore(target:File):void
		{
			if (!target)
				return;

			var isDirectory:Boolean;
			var fileName:String;

			try
			{
				isDirectory = target.isDirectory;
				fileName = target.name;
			}
			catch (e:Error)
			{
			}

			if (isDirectory)
			{
				if (_form.selected_DOT_SVN && fileName == FolderName.DOT_SVN)
				{
					_fileArr.push(target);
				}
				else if (_form.selected__NOTES && fileName == FolderName._NOTES)
				{
					_fileArr.push(target);
				}
				else if (_form.selected___MACOSX && fileName == FolderName.__MACOSX)
				{
					_fileArr.push(target);
				}
				else
				{
					// サブパッケージを調べない
					if (!_form.selectedCheckChild && _seachTotal != 0)
					{
					}
					// サブパッケージを調べる
					else
					{
						var getDirectoryListing:Command = new GetDirectoryListing(target);
						insertCommand(
							getDirectoryListing,
							new Func(ret, [getDirectoryListing])
						);
					}
				}
			}
			else
			{
				if (_form.selected_DOT_DS_STORE && fileName == FileName.DOT_DS_STORE)
				{
					_fileArr.push(target);
				}
				else if (_form.selected_THUMBS_DB && fileName == FileName.THUMBS_DB)
				{
					_fileArr.push(target);
				}
				else if (_form.selected_DOT_BRIDGE_SORT && fileName == FileName.DOT_BRIDGE_SORT)
				{
					_fileArr.push(target);
				}
				else if (_form.selected_DOT_BRIDGE_LABELS_AND_RATINGS && fileName == FileName.DOT_BRIDGE_LABELS_AND_RATINGS)
				{
					_fileArr.push(target);
				}
				else if (_form.selected_DESKTOP_DOT_INI && fileName.toLowerCase() == FileName.DESKTOP_DOT_INI.toLowerCase())
				{
					_fileArr.push(target);
				}
				else if (_form.selected_APPLE_DOUBLE && fileName.indexOf("._") == 0)
				{
					_fileArr.push(target);
				}
			}

			_seachCount++;
		}
		
		private function _searchSubDirectory(files:Array):void
		{
			_seachTotal += files.length;
			
			for (var i:int = 0; i < files.length; i++)
			{
				var element:File = files[i] as File;
				
				// ASYNC_RESUME_COUNT 回ごとに1回休憩する(フレームを進ませる)
				if (_asyncCnt++ % ASYNC_RESUME_COUNT == 0)
				{
					insertCommand(new Wait(WAIT_TIME));
				}
				// GC_COUNT 回ごとに1回GCする
//				if (_asyncCnt % GC_COUNT == 0)
//				{
//					insertCommand(
//						new Wait(WAIT_TIME),
//						function():void{
//							var old:Number = getTimer();
//							
//							try{
//								System.gc();
//							}catch(e:*){}
//							
//							trace("gc", getTimer() - old);
//						});
//				}
				
				// コマンドを追加(再帰処理)
				insertCommand(
					new Func(searchCore, [ element ])
				);
			}
		}
		
		private function ret(getDirectoryListing:GetDirectoryListing):void{
			var files:Array = getDirectoryListing.files;
			_searchSubDirectory(files);
		}
	}
}