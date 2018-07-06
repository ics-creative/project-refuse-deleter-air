/**
 * copyright(c) flair4.jp
 */
package jp.flair4.lib.events {
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.Dictionary;
    
    /**
    * EnterFrameEventの処理を最適化するクラスです.
    * 本来各 DisplayObject が行う EnterFrame の処理をこのクラスが一括で行うことにより、パフォーマンスが飛躍的に向上します.
    * 注:このクラスを用いた場合 useCapture, priority, weakReference の各項目を扱うことは出来ません.
    * @author KAWAKITA Hirofumi
    * @version 0.1
    */
    public class EnterFrameEventOptimizer {
        
        //------- MEMBER -----------------------------------------------------------------------
        /** static呼び出し用 */
        private static var _PROVIDER:Provider;
        private static var _ONCE_DICTIONARY:Dictionary;
        private static var _EVERY_DICTIONARY:Dictionary;
        /** インスタンスで利用する Provider. */
        private var _provider:Provider;
        
        //------- PUBLIC -----------------------------------------------------------------------
        /**
         * コンストラクタ.
         */
        public function EnterFrameEventOptimizer() {
            _provider = new Provider();
        }
        
        //--- Static Method. -------------------------------------------------------------
        
        /**
         * 指定したフレーム数後に一度だけコールバックを返します.
         * @param	listener             コールバック.
         * @param	delay                フレーム数.
         * @param	monitorDisplayObject
         * ADDED_TO_STAGE 及び REMOVED_FROM_STAGE を監視する対象を指定出来ます.
         * 監視すると,removeChild時に自動的に一時停止されaddChild時に再開します.
         * @param	delegateEventObject  コールバックに Event オブジェクトを渡すか.
         */
        public static function once( listener:Function, delay:uint = 1, monitorDisplayObject:DisplayObject = null, delegateEventObject:Boolean = false ):void {
            if ( !_PROVIDER ) _PROVIDER = new Provider();
            if ( !_ONCE_DICTIONARY ) _ONCE_DICTIONARY = new Dictionary();
            clearOnce(listener);
            _ONCE_DICTIONARY[listener] = _add({
                callback : function(e:Event):void {
                    try{
                        if( e.type == Event.ENTER_FRAME ){
                            if ( --delay <= 0 ) {
                                listener.apply( null, ((delegateEventObject)?e:null) );
                                clearOnce( listener );
                            }
                        }else if ( e.type == Event.ADDED_TO_STAGE ) {
                            _PROVIDER.add( _ONCE_DICTIONARY[listener].callback );
                        }else if ( e.type == Event.REMOVED_FROM_STAGE ) {
                            _PROVIDER.remove( _ONCE_DICTIONARY[listener].callback );
                        }
                    }catch (e:Error) {
                        clearOnce( listener );
                    }
                },
                target : monitorDisplayObject
            });
        }
        
        /**
         * onceで指定した処理をキャンセルします.
         * @param	listener コールバック.
         */
        public static function clearOnce( listener:Function ):void {
            if ( !_PROVIDER || !_ONCE_DICTIONARY || !_ONCE_DICTIONARY[listener] ) return;
            _clear( _ONCE_DICTIONARY[listener] );
            delete _ONCE_DICTIONARY[listener];
        }
        
        /**
         * 指定された関数を false が返却されるまで、毎フレーム実行します。
         * @param	listener コールバック.
         * @param	monitorDisplayObject
         * ADDED_TO_STAGE 及び REMOVED_FROM_STAGE を監視する対象を指定出来ます.
         * 監視すると,removeChild時に自動的に一時停止されaddChild時に再開します.
         */
        public static function every( listener:Function, monitorDisplayObject:DisplayObject = null ):void {
            if ( !_PROVIDER ) _PROVIDER = new Provider();
            if ( !_EVERY_DICTIONARY ) _EVERY_DICTIONARY = new Dictionary();
            clearEvery(listener);
            _EVERY_DICTIONARY[listener] = _add({
                callback : function(e:Event):void {
                    try{
                        if( e.type == Event.ENTER_FRAME ){
                            if ( !listener() ) clearEvery( listener );
                        }else if ( e.type == Event.ADDED_TO_STAGE ) {
                            _PROVIDER.add( _EVERY_DICTIONARY[listener].callback );
                        }else if ( e.type == Event.REMOVED_FROM_STAGE ) {
                            _PROVIDER.remove( _EVERY_DICTIONARY[listener].callback );
                        }
                    }catch(e:Error){
                        clearEvery(listener);
                    }
                },
                target : monitorDisplayObject
            });
        }
        
        /**
         * everyで指定した処理をキャンセルします.
         * @param	listener コールバック.
         */
        public static function clearEvery( listener:Function ):void {
            if ( !_PROVIDER || !_EVERY_DICTIONARY || !_EVERY_DICTIONARY[listener] ) return;
            _clear( _EVERY_DICTIONARY[listener] );
            delete _EVERY_DICTIONARY[listener];
        }
        
        //--- Instance Method. -----------------------------------------------------------
        private static function _add( obj:* ):*{
            if ( obj.target ) {
                obj.target.addEventListener( Event.ADDED_TO_STAGE, obj.callback );
                obj.target.addEventListener( Event.REMOVED_FROM_STAGE, obj.callback );
                if ( obj.target.stage ) _PROVIDER.add( obj.callback );
            }else{
                _PROVIDER.add( obj.callback );
            }
            return obj;
        }
        
        /**
         * クリアメソッド.
         * @param	obj
         */
        private static function _clear( obj:* ):* {
            if ( obj.target ) {
                obj.target.removeEventListener( Event.ADDED_TO_STAGE, obj.callback );
                obj.target.removeEventListener( Event.REMOVED_FROM_STAGE, obj.callback );
            }
            _PROVIDER.remove( obj.callback );
        }
        
        /** 現在登録されているリスナ数. */
        public function get numListeners():Number {
            return _provider.numListeners;
        }
        
        /** EnterFrameが実行されているか. */
        public function get running():Boolean {
            return _provider.running;
        }
        
        /**
         * EnterFrameEventのリスナを追加します.
         * 追加したリスナは,このクラスの管理下に置かれるため,解除する際には
         * このクラスの removeEventListener を実行してください.
         * @param	listener コールバック.
         */
        public function addEventListener( listener:Function ):void {
            _provider.add( listener );
        }
        
        /**
         * EnterFrameEventのリスナを削除します.
         * @param	listener コールバック.
         */
        public function removeEventListener( listener:Function ):void {
            _provider.remove( listener );
        }
        
        /**
         * EnterFrame の処理を停止します.
         */
        public function pause():void {
            _provider.pause();
        }
        
        /**
         * pause によって停止した処理を再開します.
         */
        public function resume():void {
            _provider.resume();
        }
        
    }
    
}

import flash.display.Shape;
import flash.events.Event;
import flash.utils.Dictionary;
/**
 * EnterFrameEventを扱うプライベートクラスです.
 * このクラスを用いてEnterFrameEventが管理されます.
 */
class Provider extends Shape {
    
    //------- MEMBER -----------------------------------------------------------------------
    private var _listenerDict:Dictionary;
    private var _num:uint;
    private var _running:Boolean;
    
    //------- PUBLIC -----------------------------------------------------------------------
    
    /**
     * コンストラクタ.
     */
    public function Provider():void {
        _listenerDict = new Dictionary();
        _num = 0;
        _running = false;
    }
    
    /** 現在登録されているリスナ数. */
    public function get numListeners():Number {
        return _num;
    }
    
    /** EnterFrameが実行されているか. */
    public function get running():Boolean {
        return _running;
    }
    
    /**
     * リスナを追加します.
     * @param	listener
     */
    public function add( listener:Function ):void {
        if ( _listenerDict[listener] ) return;
        _listenerDict[listener] = listener;
        _num++;
        resume();
    }
    
    /**
     * リスナを削除します.
     * @param	listener
     */
    public function remove( listener:Function ):void {
        if ( !_listenerDict[listener] ) return;
        delete _listenerDict[listener];
        if ( --_num <= 0 ) pause();
    }
    
    /**
     * EnterFrame の処理を停止します.
     */
    public function pause():void {
        if ( !_running ) return;
        removeEventListener( Event.ENTER_FRAME, _onEnterFrame );
        _running = false;
    }
    
    /**
     * pause によって停止した処理を再開します.
     */
    public function resume():void {
        if ( _running || _num <= 0 ) return;
        addEventListener( Event.ENTER_FRAME, _onEnterFrame );
        _running = true;
    }
    
    //------- PRIVATE ----------------------------------------------------------------------
    /**
     * EnterFrame実行処理.
     * @param	e
     */
    private function _onEnterFrame(e:Event):void {
        for each( var fnc:Function in _listenerDict ) fnc(e);
    }
    
}