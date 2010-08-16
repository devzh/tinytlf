package org.tinytlf.components.flash
{
	import org.tinytlf.*;
	import org.tinytlf.decor.decorations.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.interaction.gestures.behaviors.*;
	import org.tinytlf.interaction.gestures.behaviors.keyboard.selection.*;
	import org.tinytlf.interaction.gestures.behaviors.mouse.*;
	import org.tinytlf.interaction.gestures.behaviors.mouse.selection.*;
	import org.tinytlf.interaction.gestures.keyboard.arrows.*;
	import org.tinytlf.interaction.gestures.mouse.*;
	import org.tinytlf.interaction.xhtml.*;
	import org.tinytlf.layout.model.factories.xhtml.*;
	import org.tinytlf.layout.model.factories.xhtml.adapters.*;
	import org.tinytlf.styles.fcss.FCSSTextStyler;
	
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
			engine.interactor = new GestureInteractor();
			engine.styler = new FCSSTextStyler();
			engine.layout.textBlockFactory = new XMLModelFactory();
			
			mapDecorations(engine);
			mapEventMirrors(engine);
			mapGestures(engine);
			mapElementAdapters(engine);
		}
		
		protected function mapDecorations(engine:ITextEngine):void
		{
			if (!engine.decor.hasDecoration("backgroundColor"))
				engine.decor.mapDecoration("backgroundColor", BackgroundColorDecoration);
			
			if (!engine.decor.hasDecoration("bullet"))
				engine.decor.mapDecoration("bullet", BulletDecoration);
			
			if (!engine.decor.hasDecoration("selection"))
				engine.decor.mapDecoration("selection", SelectionDecoration);
			
			if (!selectable)
				engine.decor.unMapDecoration("selection");
			
			if (!engine.decor.hasDecoration("underline"))
				engine.decor.mapDecoration("underline", UnderlineDecoration);
			
			if (!engine.decor.hasDecoration("strikethrough"))
				engine.decor.mapDecoration("strikethrough", StrikeThroughDecoration);
			
			if (!engine.decor.hasDecoration("caret"))
				engine.decor.mapDecoration("caret", CaretDecoration);
			
			if (!editable)
				engine.decor.unMapDecoration("caret");
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
				
				mouseClick.addBehavior(mouseCharSelect);
				interactor.addGesture(mouseOver, iBeam);
				interactor.addGesture(mouseOut, iBeam);
				interactor.addGesture(mouseDoubleDown, mouseWordSelect);
				interactor.addGesture(mouseTripleDown, paragraphSelect);
				
				interactor.addGesture(leftArrow, arrowCharSelect);
				interactor.addGesture(rightArrow, arrowCharSelect);
				
				interactor.addGesture(leftCtrlArrow, arrowWordSelect);
				interactor.addGesture(rightCtrlArrow, arrowWordSelect);
				
				if (editable)
				{
					mouseTripleDown.removeBehavior(paragraphSelect);
					mouseTripleDown.addBehavior(mouseLineSelect);
					
					//Experimental
//					var charBack:CharacterBackspaceBehavior = new CharacterBackspaceBehavior();
//					var backspace:BackspaceGesture = new BackspaceGesture();
//					interactor.addGesture(backspace, charBack);
				}
			}
		}
		
		protected function mapElementAdapters(engine:ITextEngine):void
		{
			if (!engine.layout.textBlockFactory.hasElementFactory('ul'))
				engine.layout.textBlockFactory.mapElementFactory('ul', HTMLListAdapter);
			
			if (!engine.layout.textBlockFactory.hasElementFactory('li'))
				engine.layout.textBlockFactory.mapElementFactory('li', HTMLListItemAdapter);
			
			if (!engine.layout.textBlockFactory.hasElementFactory('br'))
				engine.layout.textBlockFactory.mapElementFactory('br', HTMLLineBreakAdapter);
		}
	}
}