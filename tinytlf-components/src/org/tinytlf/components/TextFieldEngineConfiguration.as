package org.tinytlf.components
{
	import org.tinytlf.*;
	import org.tinytlf.decor.*;
	import org.tinytlf.decor.selection.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.interaction.behaviors.*;
	import org.tinytlf.interaction.gestures.*;
	import org.tinytlf.layout.ITextContainer;
	import org.tinytlf.layout.factories.*;
	import org.tinytlf.styles.*;
	
	public class TextFieldEngineConfiguration implements ITextEngineConfiguration
	{
		public function TextFieldEngineConfiguration(selectable:Boolean = true, editable:Boolean = false)
		{
			this.selectable = selectable;
			this.editable = editable;
		}
		
		public var selectable:Boolean = true;
		public var editable:Boolean = false;
		
		public function configure(engine:ITextEngine):void
		{
			engine.interactor = new CascadingTextInteractor();
			engine.styler = new FCSSTextStyler();
			engine.layout.textBlockFactory = new XMLTextBlockFactory();
			
			mapDecorations(engine);
			mapEventMirrors(engine);
			mapGestures(engine);
			applyGestures(engine);
			mapElementAdapters(engine);
			mapStyles(engine);
		}
		
		protected function mapDecorations(engine:ITextEngine):void
		{
			var decor:ITextDecor = engine.decor;
			
			if (!decor.hasDecoration("backgroundColor"))
				decor.mapDecoration("backgroundColor", BackgroundColorDecoration);
			
			if (!decor.hasDecoration("bullet"))
				decor.mapDecoration("bullet", BulletDecoration);
			
			if (!decor.hasDecoration("horizontalRule"))
				decor.mapDecoration("horizontalRule", HorizontalRuleDecoration);
			
			if (!decor.hasDecoration("selection"))
				decor.mapDecoration("selection", StandardSelectionDecoration);
			
			if (!decor.hasDecoration("underline"))
				decor.mapDecoration("underline", UnderlineDecoration);
			
			if (!decor.hasDecoration("strikethrough"))
				decor.mapDecoration("strikethrough", StrikeThroughDecoration);
			
			if (!decor.hasDecoration("caret"))
				decor.mapDecoration("caret", CaretDecoration);
			
			if (!decor.hasDecoration("popup"))
				decor.mapDecoration("popup", PopupDecoration);
			
			if (!decor.hasDecoration("border"))
				decor.mapDecoration("border", BorderDecoration);
			
			if (!selectable)
				decor.unMapDecoration("selection");
			
//			if (!editable)
//				decor.unMapDecoration("caret");
		}
		
		protected function mapEventMirrors(engine:ITextEngine):void
		{
			if (!engine.interactor.hasMirror("a"))
				engine.interactor.mapMirror("a", AnchorMirror);
		}
		
		protected function mapGestures(engine:ITextEngine):void
		{
			var interactor:IGestureInteractor = IGestureInteractor(engine.interactor);
			
			interactor.removeAllGestures();
			
			var focus:FocusBehavior = new FocusBehavior();
			var mouseClick:MouseClickGesture = new MouseClickGesture();
			interactor.addGesture(mouseClick, focus);
			
			if (selectable)
			{
				var iBeam:IBeamBehavior = new IBeamBehavior();
				var scroll:ScrollBehavior = new ScrollBehavior();
				var mouseCharSelect:CharacterSelectionBehavior = new CharacterSelectionBehavior();
				var mouseWordSelect:WordSelectionBehavior = new WordSelectionBehavior();
				var paragraphSelect:ParagraphSelectionBehavior = new ParagraphSelectionBehavior();
				
				var mouseOver:MouseOverGesture = new MouseOverGesture();
				var mouseOut:MouseOutGesture = new MouseOutGesture();
				var mouseDoubleDown:MouseDoubleDownGesture = new MouseDoubleDownGesture();
				var mouseTripleDown:MouseTripleDownGesture = new MouseTripleDownGesture();
				var mouseWheel:MouseWheelGesture = new MouseWheelGesture();
				
				interactor.addGesture(mouseOver, iBeam);
				interactor.addGesture(mouseOut, iBeam);
				interactor.addGesture(mouseClick, mouseCharSelect, scroll);
				interactor.addGesture(mouseDoubleDown, mouseWordSelect, scroll);
				interactor.addGesture(mouseTripleDown, paragraphSelect, scroll);
				interactor.addGesture(mouseWheel, scroll);
				
				if (editable)
				{
					mouseTripleDown.removeBehavior(paragraphSelect);
				}
			}
		}
		
		protected function applyGestures(engine:ITextEngine):void
		{
			var containers:Vector.<ITextContainer> = engine.layout.containers;
			containers.forEach(function(container:ITextContainer, ...args):void{
				engine.interactor.getMirror(container);
			});
		}
		
		protected function mapElementAdapters(engine:ITextEngine):void
		{
			var factory:ITextBlockFactory = engine.layout.textBlockFactory;
			
			if (!factory.hasElementFactory('ul'))
				factory.mapElementFactory('ul', HTMLListAdapter);
			
			if (!factory.hasElementFactory('li'))
				factory.mapElementFactory('li', HTMLListItemAdapter);
			
			if (!factory.hasElementFactory('br'))
				factory.mapElementFactory('br', HTMLLineBreakAdapter);
			
			if (!factory.hasElementFactory('colbr'))
				factory.mapElementFactory('colbr', HTMLColumnBreakAdapter);
			
			if (!factory.hasElementFactory('img'))
				factory.mapElementFactory('img', HTMLImageAdapter);
			
			if (!factory.hasElementFactory('hr'))
				factory.mapElementFactory('hr', HTMLHorizontalRuleAdapter);
		}
		
		protected function mapStyles(engine:ITextEngine):void
		{
			var styler:ITextStyler = engine.styler;
			
			if(!styler.getStyle('selectionColor'))
				styler.setStyle('selectionColor', 0x0068FC);
			if(!styler.getStyle('selectionAlpha'))
				styler.setStyle('selectionAlpha', 0.28);
		}
	}
}

