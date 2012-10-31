package
{
	import com.bit101.components.*;
	
	import embeds.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import org.tinytlf.components.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.util.*;
	
	[SWF(width = "600", height = "500")]
	public class TinyTLFEditorDemo extends Sprite
	{
		private var helvetica:Helvetica;
		private var tf:TextField;
		private var loadedCSS:String = '';
		private const mainVbox:VBox = new VBox(null, 0, 10);
		
		public function TinyTLFEditorDemo()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			const g:Graphics = graphics;
			g.clear();
			g.beginFill(0xFFFFFF, 1);
			g.lineStyle(1, 0xCCCCCC);
			g.drawRect(1, 1, stage.stageWidth - 2, stage.stageHeight - 2);
			
			addChild(mainVbox);
			mainVbox.width = 160;
			mainVbox.alignment = VBox.RIGHT;
			
			addTextField(org.tinytlf.components.TextField);
			createCSSComponents();
			
			tf.html = '<body style="padding-top: 25px; padding-left: 25px">Some text to start us off.</body>'
			
//			ViewSource.addMenuItem(this, 'http://guyinthechair.com/flash/tinytlf/2.0/explorer/srcview/index.html');
		}
		
		private function addTextField(textFieldClass:Class):TextField
		{
			const newTF:TextField = new textFieldClass(true);
			
			if(tf)
			{
				newTF.html = tf.html;
				newTF.css = tf.css;
				removeChild(tf);
			}
			
			addChild(tf = newTF);
			
			tf.width = stage.stageWidth - 166;
			tf.height = 499;
			tf.x = 165;
			return tf;
		}
		
		private function createCSSComponents():void
		{
			const window:Window = new Window(mainVbox);
			window.draggable = false;
			window.title = 'CSS';
			window.width = 160;
			window.height = 100;
			
			const vbox:VBox = new VBox(window, 0, 0);
			vbox.spacing = 0;
			vbox.width = 160;
			vbox.alignment = VBox.RIGHT;
			
			const list:List = new List(vbox, 0, 0,
				[
					'Default',
					'Helvetica',
					'Idle Words'
				]);
			list.autoHideScrollBar = true;
			list.selectedIndex = 1;
			list.height = 60;
			list.width = 160;
			list.addEventListener('select', function(e:Event):void {
				if(!list.selectedItem)
					return;
				
				const propName:String = String(list.selectedItem).split(' ').join('');
				tf.css = loadedCSS = new (CSSSource[propName] as Class)().toString();
			});
			tf.css = loadedCSS = new CSSSource.Helvetica().toString();
			
			const editWindow:Window = new Window(null,
				(stage.stageWidth - 400) * 0.5,
				(stage.stageHeight - 400) * 0.5,
				'Edit CSS'
			);
			editWindow.width = 400;
			editWindow.height = 400;
			editWindow.hasCloseButton = true;
			
			editWindow.addEventListener('close', function(e:Event):void {
				if(editArea.text != 'Load some CSS!')
					tf.css = loadedCSS = editArea.text;
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStagePress);
				stage.removeChild(editWindow);
			});
			
			const editArea:FormattedTextArea = new FormattedTextArea(editWindow);
			editArea.width = 400;
			editArea.height = 380;
			editArea.draw();
			
			const format:TextFormat = editArea.textField.defaultTextFormat;
			format.size = 14;
			format.font = 'Helvetica';
			editArea.format = format;
			
			const onStagePress:Function = function(e:MouseEvent):void {
				const r:Rectangle = editWindow.getBounds(stage);
				if(r.contains(e.stageX, e.stageY) == false)
					editWindow.dispatchEvent(new Event(Event.CLOSE));
			};
			
			const editButton:PushButton = new PushButton(vbox, 0, 0, 'Edit CSS', function(e:Event):void {
				editArea.text = loadedCSS || 'Load some CSS!';
				stage.addChild(editWindow);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStagePress);
			});
			editButton.width = 50;
		}
	}
}

import com.bit101.components.*;

import flash.display.*;
import flash.text.*;

internal class FormattedTextArea extends TextArea
{
	public function FormattedTextArea(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String = "")
	{
		super(parent, xpos, ypos, text);
	}
	
	public function set format(value:TextFormat):void
	{
		_format = value;
	}
}

