package embeds
{
	import flash.utils.ByteArray;

	[Embed(source = "assets/css/arabic.css", mimeType = "application/octet-stream")]
//	[Embed(source = "assets/css/style.css", mimeType = "application/octet-stream")]
	public class CSSSource extends ByteArray
	{
		public function CSSSource()
		{
		}
	}
}