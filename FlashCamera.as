package {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.media.Video;
    import flash.media.Camera;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    
    
    [SWF(frameRate="30", backgroundColor="0x000000")]
    public class FlashCamera extends Sprite {
    
        private var video:Video;
        private var camera:Camera;
        private var nc:NetConnection;
        private var ns:NetStream;
        private var callback:String;
        private var id:String;

        public function FlashCamera() {
            // Init stage scaling
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;
            
            callback = this.loaderInfo.parameters.callback;
            id = this.loaderInfo.parameters.id;

            // Add addedToStage listener
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
        
        private function addedToStageHandler(e:Event):void {
            // Create the video object and add it to the scene 
            video = new Video();
            video.width = this.stage.stageWidth;
            video.height = this.stage.stageHeight;
            this.addChild(video);
            
            // Export JS API 
            ExternalInterface.addCallback('getNames', getNames);
            ExternalInterface.addCallback('getCamera', getCamera);
            ExternalInterface.addCallback('setMode', setMode);
            ExternalInterface.addCallback('getMode', getMode);
            ExternalInterface.addCallback('setQuality', setQuality);
            ExternalInterface.addCallback('setLoopback', setLoopback);
            ExternalInterface.addCallback('setKeyFrameInterval', setKeyFrameInterval);
            ExternalInterface.addCallback('getInfos', getInfos);
            ExternalInterface.addCallback('connect', connect);
            ExternalInterface.addCallback('publish', publish);
            ExternalInterface.addCallback('close', close);
            ExternalInterface.addCallback('getNearID', getNearID);
            ExternalInterface.addCallback('getFarID', getFarID);
            ExternalInterface.addCallback('getPeerIDs', getPeerIDs);
            
            // Add a listener on stage resize
            this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
            
            ExternalInterface.call(callback, id, new Array('Flash.Ready'));
        }
        
        private function stageResizeHandler(event:Event):void {
            video.width = this.stage.stageWidth;
            video.height = this.stage.stageHeight;
        }
        
        private function getNames():Array {
            // Return the camera list
            return Camera.names;
        }
        
        private function getCamera(name:String):Boolean {
            // Try to get the camera
            camera = Camera.getCamera(name);
            if(camera == null) {
                return false;
            }
            
            // Try to setMode to the stage dimensions
            camera.setMode(video.width, video.height, 30);
            
            // Add event listener for permissions dialog
            camera.addEventListener(StatusEvent.STATUS, statusHandler);

            // Finally attach the camera to our display and return            
            video.attachCamera(camera);
            return true;
        }
        
        private function setMode(width:int, height:int, fps:Number):void {
            // Try to set the requested mode
            camera.setMode(width, height, fps);

            // Adjust the video dimensions accordingly
            video.width = camera.width;
            video.height = camera.height;
        }
        
        private function getMode():Array {
            return new Array(camera.width, camera.height, camera.fps); 
        }
        
        private function setQuality(bandwidth:int, quality:int):void {
            camera.setQuality(bandwidth, quality);
        }
        
        private function setLoopback(value:Boolean):void {
            camera.setLoopback(value);
        }
        
        private function setKeyFrameInterval(value:int):void {
            camera.setKeyFrameInterval(value);
        }
        
        private function getInfos():Object {
            // Return camera properties
            return {
                index: camera.index,
                width: camera.width,
                height: camera.height,
                fps: camera.fps,
                currentFPS: camera.currentFPS,
                activityLevel: camera.activityLevel,
                bandwidth: camera.bandwidth,
                keyFrameInterval: camera.keyFrameInterval,
                loopback: camera.loopback,
                motionLevel: camera.motionLevel,
                motionTimeout: camera.motionTimeout,
                muted: camera.muted,
                name: camera.name,
                quality: camera.quality
            };
        }
        
        private function connect(url:String):void {
            // Create a new connection and connect to the specified url
            nc = new NetConnection();
            nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            nc.connect(url);
        }
        
        private function publish(name:String, rtmfp:Boolean = false):void {
            // Create a new stream on the current connection
            if(rtmfp) {
                ns = new NetStream(nc, NetStream.DIRECT_CONNECTIONS);    
            } else {
                ns = new NetStream(nc);    
            }
            
            // Attach camera and publish stream
            ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            ns.attachCamera(camera);
            ns.publish(name);
        }
        
        private function close():void {
            ns.close();
        }
        
        private function getNearID():String {
            return nc.nearID;
        }
        
        private function getFarID():String {
            return nc.farID;
        }

        private function getPeerIDs():Array {
            // Build and return a list of all connected peerIDs
            var peerIDs:Array = new Array();
            for each(var s:NetStream in ns.peerStreams) {
                peerIDs.push(s.farID);
            }
            return peerIDs;
        }
        
        private function statusHandler(event:StatusEvent):void {
            ExternalInterface.call(callback, id, new Array(event.code));
        }
        
        private function netStatusHandler(event:NetStatusEvent):void {
            if(event.info.code == 'NetStream.Connect.Success') {
                ExternalInterface.call(callback, id, new Array(event.info.code, event.info.stream.farID));
                return;
            } 
            else if(event.info.code == 'NetStream.Connect.Closed') {
                ExternalInterface.call(callback, id, new Array(event.info.code, event.info.stream.farID));
                return;
            }

            ExternalInterface.call(callback, id, new Array(event.info.code));
        }

        private function log(text:String):void {
            ExternalInterface.call('console.log', id, text)
        }
        
    }
}
