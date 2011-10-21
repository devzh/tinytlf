package org.tinytlf.util
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
		public static function toXML(unwashed:String):XML
		{
			XML.prettyPrinting = false;
			XML.prettyIndent = 0;
			XML.ignoreWhitespace = false;
			
			unwashed = stripComments(unwashed);
			
			try
			{
				//Maybe our string can be easily converted to XML?
				return new XML(trim(unwashed));
			}
			catch(e:Error)
			{
				try
				{
					//But maybe he's just missing a root node?
					return new XML('<body>' + trim(unwashed) + '</body>');
				}
				catch(e:Error)
				{
					//Nope, too optimistic. Slurp 'em up.
					try
					{
						// Try without a root node first.
						return new XML(slurp(unwashed));
					}
					catch(e:Error)
					{
						// Try one last time with a root node.
						return new XML('<body>' + slurp(unwashed) + '</body>');
					}
				}
			}
			
			return <_/>;
		}
		
		/**
		 * Slurp your soup. Do some translation on self-terminating nodes
		 * before and after slurpage, because the browser doesn't understand
		 * self-terminating nodes and it passes back invalid XML but potentially
		 * valid HTML.
		 */
		public static function slurp(tags:String):String
		{
			// Replace self terminating nodes with open/close pairs because
			// self-terminating nodes aren't valid in HTML
			// 
			// <tag property="value"/> to <tag property="value"></tag>
			tags = tags.replace(/<[^>\S]*([^>\s|br|hr|img]+)([^>]*)\/[^>\S]*>/g, '<$1$2></$1>');
			
			// Parse the HTML into XHTML with the browser or AIR's webkit engine.
			tags = soup(tags);
			
			// Convert any open tags back to self-terminating nodes.
			tags = tags.replace(/<(hr|br|img)(.*?)>/g, '<$1$2/>');
			
			return trim(tags);
		}
		
		/**
		 * @private
		 * Attempts to parse the input malformed XML tags with the browser
		 * through an ExternalInterface call.
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
			else
			{
				var loader:Class;
				try
				{
					loader = getDefinitionByName('flash.html.HTMLLoader') as Class;
				}
				catch(e:Error)
				{
					return '';
				}
				
				const htmlLoader:* = new loader();
				const html:String = '<body>\
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
			return input.
//				replace(/\n|\r|\t/g, '  ').
				replace(/\n|\r|\t/g, '').
				replace(/(<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>)(\s+)(<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>)/g, '$1$6').
				replace(/(<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>)(\s+)(<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>)/g, '$1$6');
//				replace(/>(\s\s+)</g, '><').
//				replace(/(\s\s+)/g, ' ').
		}
		
		private static function stripComments(input:String):String
		{
			return input.replace(/<!--(.*?)-->/g, '');
		}
	}
}
