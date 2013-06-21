package org.tinytlf.net
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;

	/**
	 * @author ptaylor
	 */
	public function loadImage(url:String):IObservable {
		
		const request:URLRequest = new URLRequest(url);
		const dataFormat:String = URLLoaderDataFormat.BINARY;
		
		return Observable.urlLoader(request, dataFormat).
			switchMany(function(bytes:ByteArray):IObservable {
				const loader:Loader = new Loader();
				loader.loadBytes(bytes);
				return Observable.fromEvent(loader, Event.COMPLETE);
			}).
			map(function(event:Event):BitmapData {
				
				const loaderInfo:LoaderInfo = LoaderInfo(event.target);
				const loader:Loader = loaderInfo.loader;
				const data:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height, false, 0xFFFFFF);
				data.draw(loaderInfo.loader);
				
				return data;
			});
	}
}