package skins
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.skins.halo.TabSkin;

	public class ScopeTabSkin extends TabSkin
	{
		public function ScopeTabSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var gradientMatrix:Matrix = new Matrix();
			
			graphics.clear();
			graphics.beginFill(0x2E2E2E, 1);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					
			switch (name)
			{
				case "upSkin":
				{
					//gradient fill
					gradientMatrix.createGradientBox(unscaledWidth-2, unscaledHeight-2, Math.PI/2);
					graphics.beginGradientFill(GradientType.LINEAR, [0xE4E4E4, 0x9A9A9A], [1, 1], [0,255], gradientMatrix);
					graphics.drawRect(1, 1, unscaledWidth-2, unscaledHeight-2);
					
					//inner border
					graphics.beginFill(0xFFFFFF, .33);
					graphics.drawRect(1, 1, unscaledWidth-2, 1);
					
					graphics.beginFill(0xFFFFFF, .05);
					graphics.drawRect(1, unscaledHeight-2, unscaledWidth-2, 1);
					
					graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [.33, .05], [0,255], gradientMatrix);
					graphics.drawRect(1, 2, 1, unscaledHeight-4);
					graphics.drawRect(unscaledWidth-2, 2, 1, unscaledHeight-4);
					
					break;
				}
	   			case "overSkin":
				{
					//gradient fill
					gradientMatrix.createGradientBox(unscaledWidth-2, unscaledHeight-2, Math.PI/2);
					graphics.beginGradientFill(GradientType.LINEAR, [0xF1F1F1, 0xC5C5C5], [1, 1], [0,255], gradientMatrix);
					graphics.drawRect(1, 1, unscaledWidth-2, unscaledHeight-2);
					
					//inner border
					graphics.beginFill(0xFFFFFF, .33);
					graphics.drawRect(1, 1, unscaledWidth-2, 1);
					
					graphics.beginFill(0xFFFFFF, .05);
					graphics.drawRect(1, unscaledHeight-2, unscaledWidth-2, 1);
					
					graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [.33, .05], [0,255], gradientMatrix);
					graphics.drawRect(1, 2, 1, unscaledHeight-4);
					graphics.drawRect(unscaledWidth-2, 2, 1, unscaledHeight-4);
					
					break;
				}
				case "disabledSkin":
				{
					graphics.clear();
					
					//border
					graphics.beginFill(0x2E2E2E, .5);
					graphics.drawRect(0, 0, unscaledWidth, 1);
					graphics.drawRect(0, unscaledHeight-1, unscaledWidth, 1);
					graphics.drawRect(0, 1, 1, unscaledHeight-2);
					graphics.drawRect(unscaledWidth-1, 1, 1, unscaledHeight-2);
					
					//gradient fill
					gradientMatrix.createGradientBox(unscaledWidth-2, unscaledHeight-2, Math.PI/2);
					graphics.beginGradientFill(GradientType.LINEAR, [0xE4E4E4, 0x9A9A9A], [.5, .5], [0,255], gradientMatrix);
					graphics.drawRect(1, 1, unscaledWidth-2, unscaledHeight-2);
					
					//inner border
					graphics.beginFill(0xFFFFFF, .18);
					graphics.drawRect(1, 1, unscaledWidth-2, 1);
					
					graphics.beginFill(0xFFFFFF, .03);
					graphics.drawRect(1, unscaledHeight-2, unscaledWidth-2, 1);
					
					graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [.18, .03], [0,255], gradientMatrix);
					graphics.drawRect(1, 2, 1, unscaledHeight-4);
					graphics.drawRect(unscaledWidth-2, 2, 1, unscaledHeight-4);
					
	   				break;
	   			}
	   			case "downSkin":
				case "selectedUpSkin":
				case "selectedDownSkin":
				case "selectedOverSkin":
				case "selectedDisabledSkin":
				{
					//gradient fill
					gradientMatrix.createGradientBox(unscaledWidth-2, unscaledHeight-1, Math.PI/2);
					graphics.beginGradientFill(GradientType.LINEAR, [0xFBFBFB, 0xE0E0E0], [1, 1], [0,255], gradientMatrix);
					graphics.drawRect(1, 1, unscaledWidth-2, unscaledHeight-1);
					
					//inner border
					graphics.beginFill(0xFFFFFF, 1);
					graphics.drawRect(1, 1, unscaledWidth-2, 1);
					
					graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [1, .22], [0,255], gradientMatrix);
					graphics.drawRect(1, 2, 1, unscaledHeight-3);
					graphics.drawRect(unscaledWidth-2, 2, 1, unscaledHeight-3);
					
					
					break;
				}
				
			}
			
		}
		
	}
}