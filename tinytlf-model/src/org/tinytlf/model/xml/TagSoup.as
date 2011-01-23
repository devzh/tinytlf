package org.tinytlf.model.xml
{
	import flash.external.ExternalInterface;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Tries to convert weird or possibly invalid HTML into valid XML.
	 * Pass the unwashed HTML to the slurp method to clean it up, or toXML
	 * method if you just want some XML to work with.
	 */
	public final class TagSoup
	{
		public static function toXML(unwashed:String, wrap:Boolean = false):XML
		{
			var x:XML;
			try
			{
				//Maybe our string can be easily converted to XML?
				x = new XML(trim(unwashed.toString()));
			}
			catch(e:Error)
			{
				try{
					//But maybe he's just missing a root node?
					x = new XML('<body>' + unwashed.toString() + ' </body>');
				}
				catch(e:Error){
					//Nope, too optimistic. slurp em up.
					x = new XML('<body>' + slurp(unwashed.toString()) + ' </body>');
				}
			}
			
			if(wrap)
			{
				// if we were passed a string with no root at all
				// or if we were passed the root node and we want 
				// it wrapped inside another root.
				if(	(x..*.length() == 0) || 
					((x.*.length() > 0) && (x.*[0].nodeKind().toString() == 'text'))
				)
				{
					//wrap it upp
					x = <body>{x}</body>;
				}
			}
			
			return x;
		}
		
		/**
		 * Slurp your soup. Do some translation on self-terminating nodes
		 * before and after slurpage, because the browser doesn't understand
		 * self-terminating nodes and it passes back invalid XML but potentially
		 * valid HTML.
		 */
		public static function slurp(tags:String):String
		{
			//Replace self terminating nodes with open/close pairs
			//e.g.: <node some="attributes"/> to <node some="attributes"></node>
			tags = tags.replace(/<[^>\S]*([^>\s|br|hr|img]+)([^>]*)\/[^>\S]*>/g, '<$1$2></$1>');
			tags = soup(tags);
			tags = tags.replace(/<(br|hr|img).*?>/g, "<$1/>");
			return trim(tags);
		}
		
		/**
		 * @private
		 * Attempts to parse the input malformed XML tags with the browser
		 * through an ExternalInterface call.
		 *
		 */
		private static function soup(tags:String):String
		{
			//Are we running in the browser?
			if(ExternalInterface.available)
			{
				return ExternalInterface.call('function(tags)\
					{\
						var div = document.createElement("div");\
						div.innerHTML = tags;\
						return div.innerHTML;\
					}', tags);
			}
			//Might we be running in AIR?
			else if(getDefinitionByName('flash.html.HTMLLoader') != null)
			{
				var htmlLoader:* = new (getDefinitionByName('flash.html.HTMLLoader') as Class)();
				var html:String =	'<body>\
										<script type="text/javascript">\
											window.soup = function(tags)\
											{\
												var div = document.createElement("div");\
												div.innerHTML = tags;\
												return div.innerHTML;\
											}\
										</script>\
									</body>';
				htmlLoader['loadString'](html);
				tags = htmlLoader.window.soup(tags);
			}
			
			return tags;
		}
		
		/**
		 * Trims out the excess white space between XML nodes before parsing, 
		 * but we still want to respect at least one white space between nodes.
		 * This is a feature of HTML.
		 * 
		 * TODO: This will have to be tweaked to take into account the
		 * difference between sibling block-level nodes (Divs and Ps) and 
		 * sibling inline elements (like Spans). Spaces are not respected 
		 * between block-level elements, but are trimmed to one space between
		 * inline elements.
		 */
		private static function trim(input:String):String
		{
			return input.replace(/\n|\r|\t/g, ' ').replace(/>(\s\s+)</g, '><').replace(/(\s\s+)/g, ' ');
		}
	}
}