package myproject.commands
{
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.utils.getTimer;
	
	import jp.flair4.lib.events.EnterFrameEventOptimizer;
	import jp.progression.commands.Command;
	import jp.progression.commands.Func;
	import jp.progression.commands.Wait;
	import jp.progression.commands.lists.SerialList;
	
	import myproject.data.FileName;
	import myproject.data.FolderName;
	import myproject.data.SelectedForm;

	/**
	 * ...
	 * @author ...
	 */
	public class SearchFileCommand2 extends Command
	{
		private static const ASYNC_RESUME_COUNT:Number = 75;
		private static const WAIT_FRAME:int = 2;

		/**
		 * 新しい MyCommand インスタンスを作成します。
		 */
		public function SearchFileCommand2(dir:File, form:SelectedForm)
		{
			_dir = dir;
			_form = form;

			_stack = [];
			_seachCount = 0;
			_seachTotal = 0;
			_fileArr = new Vector.<File>;

			// 親クラスを初期化します。
			super(_execute, _interrupt, null);
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

		public var onPosition:Function;

		private var _form:SelectedForm;
		private var _seachCount:int = 0;
		private var _seachTotal:int = 0;
		private var _asyncCnt:int;
		private var _fileArr:Vector.<File>;
		private var _dir:File;
		private var _stack:Array;
		private var _interruptFlag:Boolean;

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
			_stack = null;
			onPosition = null;

			super.dispose();
		}

		/**
		 * フォルダリスティングのコア処理です。
		 */
		protected function searchCore(file:File):void
		{
			if (!file)
				return;

			var isDirectory:Boolean;
			var fileName:String;

			try
			{
				isDirectory = file.isDirectory;
				fileName = file.name;
			}
			catch (e:Error)
			{
			}

			if (isDirectory)
			{
				if (_form.selected_DOT_SVN && fileName == FolderName.DOT_SVN)
				{
					_fileArr.push(file);
				}
				else if (_form.selected__NOTES && fileName == FolderName._NOTES)
				{
					_fileArr.push(file);
				}
				else if (_form.selected___MACOSX && fileName == FolderName.__MACOSX)
				{
					_fileArr.push(file);
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
						var files:Array = file.getDirectoryListing();
						
						_seachTotal += files.length;
						
						for (var i:int = 0; i < files.length; i++)
						{
							var element:File = files[i] as File;
							
							// コマンドを追加(再帰処理)
							_addStack(searchCore, element);
						}
					}
				}
			}
			else
			{
				if (_form.selected_DOT_DS_STORE && fileName == FileName.DOT_DS_STORE)
				{
					_fileArr.push(file);
				}
				else if (_form.selected_THUMBS_DB && fileName == FileName.THUMBS_DB)
				{
					_fileArr.push(file);
				}
				else if (_form.selected_DOT_BRIDGE_SORT && fileName == FileName.DOT_BRIDGE_SORT)
				{
					_fileArr.push(file);
				}
				else if (_form.selected_DOT_BRIDGE_LABELS_AND_RATINGS && fileName == FileName.DOT_BRIDGE_LABELS_AND_RATINGS)
				{
					_fileArr.push(file);
				}
				else if (_form.selected_DESKTOP_DOT_INI && fileName.toLowerCase() == FileName.DESKTOP_DOT_INI.toLowerCase())
				{
					_fileArr.push(file);
				}
				else if (_form.selected_APPLE_DOUBLE && fileName.indexOf("._") == 0)
				{
					_fileArr.push(file);
				}
			}

			_seachCount++;

			_next();
		}


		/**
		 * 実行されるコマンドの実装です。
		 */
		private function _execute():void
		{
			searchCore(_dir);
		}

		/**
		 * 中断されるコマンドの実装です。
		 */
		private function _interrupt():void
		{
			_interruptFlag = true;
		}

		private function _addStack(func:Function, ... args):void
		{
			_stack.push({func: func, args: args});
		}

		private function _next():void
		{
			if (_interruptFlag)
				return;

			if (onPosition is Function)
				onPosition();

			var o:Object = _stack.shift();

			if (o && o.func)
			{
				if (_asyncCnt++ % ASYNC_RESUME_COUNT == 0)
				{
					EnterFrameEventOptimizer.once(function():void{
							o.func.apply(this, o.args);
						}, WAIT_FRAME);
				}
				else
				{
					o.func.apply(this, o.args);
				}
			}
			if (_stack.length == 0)
			{
				executeComplete();
				return;
			}
		}
	}
}
