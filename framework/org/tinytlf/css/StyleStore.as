package org.tinytlf.css
{
	import flash.utils.flash_proxy;
	
	import trxcllnt.Store;
	
	use namespace flash_proxy;
	
	internal class StyleStore extends Store
	{
		public function StyleStore()
		{
			super();
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			name = convertFromDashed(name.toString());
			
			if(name in multiProps) {
				const process:Function = multiProps[name];
				process.call(this, value);
			} else {
				super.setProperty(name, value);
			}
		}
		
		private function superSetProperty(name:*, value:*):void {
			super.setProperty(name, value);
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return super.getProperty(convertFromDashed(name.toString()));
		}
		
		private function convertFromDashed(property:String):String
		{
			if(property.indexOf('-') == -1) return property;
			
			return property.split('-').map(function(part:String, i:int, ... args):String {
				return i == 0 ? part : part.charAt(0).toUpperCase() + part.substr(1);
			}).join('');
		}
		
		private static const multiProps:Object = {
			'margin':		expandEdge('margin'),
			'padding':		expandEdge('padding'),
			'borderWidth':	expandEdge('border', 'Width'),
			'borderAlpha':	expandEdge('border', 'Alpha'),
			'borderColor':	expandEdge('border', 'Color'),
			'borderStyle':	expandEdge('border', 'Style')
		};
		
		private static function expandEdge(prefix:String, suffix:String = ''):Function {
			return function(value:String):void {
				const values:Array = value.split(' ');
				
				if(values.length == 0) values.push(0);
				if(values.length == 1) values.push(values[0]);
				if(values.length == 2) values.push(values[0], values[1]);
				if(values.length == 3) values.push(0);
				
				this.superSetProperty(prefix + 'Top'   + suffix, values[0]);
				this.superSetProperty(prefix + 'Right' + suffix, values[1]);
				this.superSetProperty(prefix + 'Bottom'+ suffix, values[2]);
				this.superSetProperty(prefix + 'Left'  + suffix, values[3]);
			}
		}
	}
}