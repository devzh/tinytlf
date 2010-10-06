package org.tinytlf.components
{
	import org.tinytlf.*;
	import org.tinytlf.decor.ITextDecor;
	import org.tinytlf.decor.decorations.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.interaction.behaviors.*;
	import org.tinytlf.interaction.behaviors.keyboard.CharacterBackspaceBehavior;
	import org.tinytlf.interaction.behaviors.keyboard.CopyBehavior;
	import org.tinytlf.interaction.behaviors.keyboard.selection.*;
	import org.tinytlf.interaction.behaviors.mouse.*;
	import org.tinytlf.interaction.behaviors.mouse.selection.*;
	import org.tinytlf.interaction.gestures.keyboard.*;
	import org.tinytlf.interaction.gestures.keyboard.arrows.*;
	import org.tinytlf.interaction.gestures.mouse.*;
	import org.tinytlf.layout.model.factories.*;
	import org.tinytlf.layout.model.factories.adapters.*;
	import org.tinytlf.styles.FCSSTextStyler;
	import org.tinytlf.styles.ITextStyler;
	
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
			engine.layout.textBlockFactory = new XMLModelFactory();
			
			mapDecorations(engine);
			mapEventMirrors(engine);
			mapGestures(engine);
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
				decor.mapDecoration("selection", SelectionDecoration);
			
			if (!decor.hasDecoration("underline"))
				decor.mapDecoration("underline", UnderlineDecoration);
			
			if (!decor.hasDecoration("strikethrough"))
				decor.mapDecoration("strikethrough", StrikeThroughDecoration);
			
			if (!decor.hasDecoration("caret"))
				decor.mapDecoration("caret", CaretDecoration);
			
			if (!selectable)
				decor.unMapDecoration("selection");
			
			if (!editable)
				decor.unMapDecoration("caret");
		}
		
		protected function mapEventMirrors(engine:ITextEngine):void
		{
			if (!engine.interactor.hasMirror("a"))
				engine.interactor.mapMirror("a", AnchorInteractor);
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
				var mouseOver:MouseOverGesture = new MouseOverGesture();
				var mouseOut:MouseOutGesture = new MouseOutGesture();
				var mouseDoubleDown:MouseDoubleDownGesture = new MouseDoubleDownGesture();
				var mouseTripleDown:MouseTripleDownGesture = new MouseTripleDownGesture();
				var leftArrow:LeftArrowGesture = new LeftArrowGesture();
				var leftCtrlArrow:LeftArrowCtrlGesture = new LeftArrowCtrlGesture();
				var rightArrow:RightArrowGesture = new RightArrowGesture();
				var rightCtrlArrow:RightArrowCtrlGesture = new RightArrowCtrlGesture();
				
				var iBeam:IBeamBehavior = new IBeamBehavior();
				var mouseCharSelect:CharacterSelectionBehavior = new CharacterSelectionBehavior();
				var mouseWordSelect:WordSelectionBehavior = new WordSelectionBehavior();
				var mouseLineSelect:LineSelectionBehavior = new LineSelectionBehavior();
				var paragraphSelect:ParagraphSelectionBehavior = new ParagraphSelectionBehavior();
				var arrowCharSelect:CharacterLeftRightBehavior = new CharacterLeftRightBehavior();
				var arrowWordSelect:WordLeftRightBehavior = new WordLeftRightBehavior();
				var copyBehavior:CopyBehavior = new CopyBehavior();
				var selectAllBehavior:SelectAllBehavior = new SelectAllBehavior();
				
				mouseClick.addBehavior(mouseCharSelect);
				
				interactor.addGesture(mouseOver, iBeam);
				interactor.addGesture(mouseOut, iBeam);
				interactor.addGesture(mouseDoubleDown, mouseWordSelect);
				interactor.addGesture(mouseTripleDown, paragraphSelect);
				
				interactor.addGesture(leftArrow, arrowCharSelect);
				interactor.addGesture(rightArrow, arrowCharSelect);
				
				interactor.addGesture(leftCtrlArrow, arrowWordSelect);
				interactor.addGesture(rightCtrlArrow, arrowWordSelect);
				
				interactor.addGesture(new CopyGesture(), copyBehavior);
				interactor.addGesture(new SelectAllGesture(), selectAllBehavior);
				
				if (editable)
				{
					mouseTripleDown.removeBehavior(paragraphSelect);
					mouseTripleDown.addBehavior(mouseLineSelect);
					
					//Experimental
					var charBack:CharacterBackspaceBehavior = new CharacterBackspaceBehavior();
					var backspace:BackspaceGesture = new BackspaceGesture();
					interactor.addGesture(backspace, charBack);
				}
			}
		}
		
		protected function mapElementAdapters(engine:ITextEngine):void
		{
			var factory:ILayoutFactoryMap = engine.layout.textBlockFactory;
			
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

