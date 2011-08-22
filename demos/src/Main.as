package
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.content.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.util.*;
	
	[SWF(width = "400", height = "500")]
	public class Main extends Sprite
	{
		[Embed(source = "assets/css/arabic.css", mimeType = "application/octet-stream")]
		private const cssSource:Class;
		
		[Embed(source = "assets/html/arabic.txt", mimeType = "application/octet-stream")]
		private const htmlSource:Class;
		
		[Embed(source = "assets/fonts/Helvetica Regular.ttf", fontFamily = "Helvetica")]
		private const helvetica:Class;
		
		[Embed(source = "assets/fonts/Helvetica Italic.ttf", fontStyle = "italic", fontFamily = "Helvetica")]
		private const helveticaItalic:Class;
		
		[Embed(source = "assets/fonts/Helvetica Bold.ttf", fontWeight = "bold", fontFamily = "Helvetica")]
		private const helveticaBold:Class;
		
		[Embed(source = "assets/fonts/Helvetica Bold Italic.ttf", fontWeight = "bold", fontStyle = "italic", fontFamily = "Helvetica")]
		private const helveticaBoldItalic:Class;
		
		public function Main()
		{
			const container:Sprite = addChild(new Sprite()) as Sprite;
			
			const engine:ITextEngine = new TextEngine();
			const injector:Injector = new TextEngineInjector(engine);
			
			const css:CSS = injector.getInstance(CSS);
			css.inject(new cssSource());
			css.inject('*{font-name: Helvetica;}');
			css.inject('p{' +
				'padding-top: 10px;' +
				'padding-bottom: 10px;' +
				'}');
			
			const html:XML = TagSoup.toXML(new htmlSource(), false);
			const dom:IDOMNode = new DOMNode(html);
			injector.injectInto(dom);
			
			const tsfm:ITextSectorFactoryMap = injector.getInstance(ITextSectorFactoryMap);
			tsfm.mapFactory('div', TSFactory);
			tsfm.mapFactory('body', TSFactory);
			tsfm.mapFactory('br', LineBreakTSF);
			tsfm.mapFactory('table', LineBreakTSF);
			
			const sectors:Array = tsfm.instantiate(dom.name).create(dom);
			
			var totalHeight:Number = 0;
			
			sectors.
				forEach(function(sector:TextSector, ... args):void {
					sector.y = totalHeight;
					sector.width = 400;
					sector.render();
					totalHeight += sector.textHeight;
					sector.textLines.forEach(function(line:TextLine, ... args):void{
						container.addChild(line);
					});
				});
		}
	}
}
