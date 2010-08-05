package org.tinytlf.components.flash
{
	import org.tinytlf.*;
	import org.tinytlf.decor.decorations.*;
	import org.tinytlf.interaction.GestureInteractor;
	import org.tinytlf.interaction.IGestureInteractor;
	import org.tinytlf.interaction.gestures.behaviors.*;
	import org.tinytlf.interaction.gestures.keyboard.*;
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
			if(!engine.decor.hasDecoration("backgroundColor"))
				engine.decor.mapDecoration("backgroundColor", BackgroundColorDecoration);
			
			if(!engine.decor.hasDecoration("bullet"))
				engine.decor.mapDecoration("bullet", BulletDecoration);
			
			if(!engine.decor.hasDecoration("selection"))
				engine.decor.mapDecoration("selection", SelectionDecoration);
			
			if(!selectable)
				engine.decor.unMapDecoration("selection");
			
			if(!engine.decor.hasDecoration("underline"))
				engine.decor.mapDecoration("underline", UnderlineDecoration);
			
			if(!engine.decor.hasDecoration("strikethrough"))
				engine.decor.mapDecoration("strikethrough", StrikeThroughDecoration);
			
			if(!engine.decor.hasDecoration("caret"))
				engine.decor.mapDecoration("caret", CaretDecoration);
			
			if(!editable)
				engine.decor.unMapDecoration("caret");
		}
		
		protected function mapEventMirrors(engine:ITextEngine):void
		{
			if(!engine.interactor.hasMirror("a"))
				engine.interactor.mapMirror("a", AnchorInteractor);
		}
		
		protected function mapGestures(engine:ITextEngine):void
		{
			var interactor:IGestureInteractor = IGestureInteractor(engine.interactor);
			
			interactor.removeAllGestures();
			
			var focus:FocusBehavior = new FocusBehavior();
			var iBeam:IBeamBehavior = new IBeamBehavior();
			var events:EnsureMouseEventsReceivedBehavior = new EnsureMouseEventsReceivedBehavior();
			var charSelect:CharacterSelectionBehavior = new CharacterSelectionBehavior();
			var wordSelect:WordSelectionBehavior = new WordSelectionBehavior();
			var lineSelect:LineSelectionBehavior = new LineSelectionBehavior();
			var paragraphSelect:ParagraphSelectionBehavior = new ParagraphSelectionBehavior();
			var charBack:CharacterBackspaceBehavior = new CharacterBackspaceBehavior();
			
			var keyboard:KeyboardGesture = new KeyboardGesture();
			var mouseOver:MouseOverGesture = new MouseOverGesture();
			var mouseOut:MouseOutGesture = new MouseOutGesture();
			var mouseClick:MouseClickGesture = new MouseClickGesture();
			var mouseDoubleDown:MouseDoubleDownGesture = new MouseDoubleDownGesture();
			var mouseTripleDown:MouseTripleDownGesture = new MouseTripleDownGesture();
			var backspace:BackspaceGesture = new BackspaceGesture();
			
			if(selectable)
			{
				interactor.addGesture(keyboard, focus);
				interactor.addGesture(mouseOver, iBeam);
				interactor.addGesture(mouseOut, iBeam);
				interactor.addGesture(mouseClick, focus, charSelect);
				interactor.addGesture(mouseDoubleDown, wordSelect);
//				interactor.addGesture(mouseTripleDown, paragraphSelect);
				
				if(editable)
				{
					interactor.addGesture(mouseTripleDown, lineSelect);
					interactor.addGesture(backspace, charBack);
				}
			}
		}
		
		protected function mapElementAdapters(engine:ITextEngine):void
		{
			if(!engine.layout.textBlockFactory.hasElementAdapter('ul'))
				engine.layout.textBlockFactory.mapElementAdapter('ul', HTMLListAdapter);
			
			if(!engine.layout.textBlockFactory.hasElementAdapter('li'))
				engine.layout.textBlockFactory.mapElementAdapter('li', HTMLListItemAdapter);
			
			if(!engine.layout.textBlockFactory.hasElementAdapter('br'))
				engine.layout.textBlockFactory.mapElementAdapter('br', HTMLLineBreakAdapter);
		}
	}
}