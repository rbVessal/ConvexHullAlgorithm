package  
{
	
	import flash.display.MovieClip;	
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class Document extends MovieClip 
	{
		//Attributes
		//Arrays for storing the points
		private var pointsArray:Array;
		private var farthestPointsArray:Array;
		//1st iteration min and max points
		var minXPt:Point;
		var minYPt:Point;
		var maxXPt:Point;
		var maxYPt:Point;
		var maxX:Number = stage.stageWidth;
		var maxY:Number = stage.stageHeight;
		var minX:Number = 0;
		var minY:Number = 0;
		private var counter:int = 0;
		
		public function Document() 
		{
			// constructor code
			pointsArray = new Array();
			farthestPointsArray = new Array();
			init();
			//Listen for when the user presses spacebar
			stage.addEventListener(KeyboardEvent.KEY_DOWN, convexHullAlgorithm);
 		}
		
		//Generate points within the stage bounds
		private function init():void
		{
			//Generate points with minX, minY, maxX, or maxY
			generateMinAndMaxPoints();
			
			//Create 26 other random points onto the screen
			for(var i:int = 0; i < 56; i++)
			{
				var pt:Ball = new Ball(2, 0);
				//Generate randomY such that it is in between minY and maxY
				var randomY:Number = Math.random() * stage.stageHeight;
				//Generate randomX such that ti is in between minX and maxX
				var randomX:Number = Math.random() * stage.stageWidth;
				if(randomY == 0)
				{
					randomY = 1;
				}
				if(randomX == 0)
				{
					randomX = 1;
				}
				pt.x = randomX;
				pt.y = randomY;
				addChild(pt);
				pointsArray.push(pt);
			}		
			trace("initial length: " + pointsArray.length);
			
			
		}
		
		private function generateMinAndMaxPoints():void
		{
			trace("beginning length " + pointsArray.length);
			//First generate points with a minX, minY, maxX, or maxY
			//Randomly generate the x for the min and max Ys
			var randomXMinY:Number = Math.random() * stage.stageWidth;
			var randomXMaxY:Number = Math.random() * stage.stageWidth;
			//Randomly generate the y for the min and max Xs
			var randomYMinX:Number = Math.random() * stage.stageHeight;
			var randomYMaxX:Number = Math.random() * stage.stageHeight;
			//Define the min and max X and Y points using the random coordinates provided above
			minXPt = new Point(minX, randomYMinX);
			maxXPt = new Point(maxX, randomYMaxX);
			minYPt = new Point(randomXMinY, minY);
			maxYPt = new Point(randomXMaxY, maxY);
			
			//Generate max and min points on the screen
			var minXPoint:Ball = new Ball(2, 0);
			minXPoint.x = minXPt.x;
			minXPoint.y = minXPt.y;
			
			var maxXPoint:Ball = new Ball(2, 0);
			maxXPoint.x = maxXPt.x;
			maxXPoint.y = maxXPt.y;
			
			var minYPoint:Ball = new Ball(2, 0);
			minYPoint.x = minYPt.x;
			minYPoint.y = minYPt.y;
			
			var maxYPoint:Ball = new Ball(2, 0);
			maxYPoint.x = maxYPt.x;
			maxYPoint.y = maxYPt.y;
			
			pointsArray.push(minXPoint);
			pointsArray.push(maxXPoint);
			pointsArray.push(minYPoint);
			pointsArray.push(maxYPoint);
			
			addChild(minXPoint);
			addChild(maxXPoint);
			addChild(minYPoint);
			addChild(maxYPoint);
		}
		
		private function convexHullAlgorithm(keyboardEvent:KeyboardEvent):void
		{
			
			//Now draw a line connecting those points
			if(keyboardEvent.keyCode == Keyboard.SPACE)
			{
				trace(counter);
				switch(counter)
				{
					case 0:
					{
						drawInitialConvexHull();
						break;
					}
					case 1:
					{
						removePtsInConvexHull();
						break;
					}
					case 2:
					{
						quickHullAlgorithm();
						break;
					}
					case 3:
					{
						removePtsInConvexHull();
					}
				}
				
				counter++;
			}
			if(keyboardEvent.keyCode == Keyboard.SHIFT)
			{
				trace("clear");
				clearEverythingOffScreen();
				resetCounter();
			}
			
			
		}
		
		//Reset the counter
		private function resetCounter():void
		{
			counter = 0;
		}
		
		//Draw the initial convexHull
		private function drawInitialConvexHull():void
		{
			graphics.lineStyle(1, 0, 1);
			graphics.beginFill(0x6495ED);
			graphics.moveTo(minXPt.x, minXPt.y);
			graphics.lineTo(minYPt.x, minYPt.y);
			graphics.lineTo(maxXPt.x, maxXPt.y);
			graphics.lineTo(maxYPt.x, maxYPt.y);
			graphics.lineTo(minXPt.x, minXPt.y);
			graphics.endFill();
		}
		
		//Remove pts in convexHull
		private function removePtsInConvexHull():void
		{
			if(counter == 1)
			{
				for(var i:int = pointsArray.length - 1; i >= 0; i--)
				{
					var ptPX:Number = pointsArray[i].x;
					var ptPY:Number = pointsArray[i].y;
					var ptP:Point = new Point(ptPX, ptPY);
					if(removePtsInTriangle(minYPt, maxXPt, maxYPt, ptP))
					{
						//pointsArray.splice(i, 1);
						removeChild(pointsArray[i]);
						pointsArray.splice(i, 1);
					}
					if(removePtsInTriangle(minYPt, minXPt, maxYPt, ptP))
					{
						removeChild(pointsArray[i]);
						pointsArray.splice(i, 1);
					}
				}
			}
			else if(counter == 3)
			{
				trace("2nd iteration " + pointsArray.length);
				for(var j:int = pointsArray.length - 1; j >= 0; j--)
				{
					var ptPX2:Number = pointsArray[j].x;
					var ptPY2:Number = pointsArray[j].y;
					var ptP2:Point = new Point(ptPX2, ptPY2);
					//trace("length " + farthestPointsArray.length);
					if(removePtsInTriangle(minYPt, farthestPointsArray[0], maxXPt, ptP2))
					{
						removeChild(pointsArray[j]);
						pointsArray.splice(j, 1);
					}
					else if(removePtsInTriangle(maxXPt, farthestPointsArray[1], maxYPt, ptP2))
					{
						removeChild(pointsArray[j]);
						pointsArray.splice(j, 1);
					}
					else if(removePtsInTriangle(maxYPt, farthestPointsArray[2], minXPt, ptP2))
					{
						removeChild(pointsArray[j]);
						pointsArray.splice(j, 1);
					}
					else if(removePtsInTriangle(minXPt, farthestPointsArray[3], minYPt, ptP2))
					{
						removeChild(pointsArray[j]);
						pointsArray.splice(j, 1);
					}
				}
				
			}
		}
		
		//Do the quickHull algorithm
		private function quickHullAlgorithm():void
		{
			quickHullAlgorithmHelper(maxXPt, minYPt, minYPt, maxXPt);
			quickHullAlgorithmHelper(maxYPt, maxXPt, maxXPt, maxYPt);
			quickHullAlgorithmHelper(minXPt, maxYPt, minXPt, maxYPt);
			quickHullAlgorithmHelper(minYPt, minXPt, minXPt, minYPt);
		}
		
		//2nd iteration for quickHull algorithm
		private function quickHullAlgorithmHelper(ptA:Point, ptB:Point, moveInitialPt:Point, moveLastPt:Point):void
		{
			var farthestPointFromAB:int = pointFarthestFromEdge(ptA, ptB, pointsArray.length);
			graphics.moveTo(moveInitialPt.x, moveInitialPt.y);
			//trace(farthestPointFromAB);
			var pointX:Number = pointsArray[farthestPointFromAB].x;
			var pointY:Number = pointsArray[farthestPointFromAB].y;
			var pointFarthestAB:Point = new Point(pointX, pointY);
			farthestPointsArray.push(pointFarthestAB);
			//trace(pointFarthestAB.x);
			graphics.beginFill(0x1E90FF);
			graphics.lineTo(pointFarthestAB.x, pointFarthestAB.y);
			graphics.lineTo(moveLastPt.x, moveLastPt.y);
			graphics.endFill();
		}
		
		//Determine the farthest point from the edge
		private function pointFarthestFromEdge(ptA:Point, ptB:Point, n:int):int
		{
			//Create edge vector and vector (clockwise) perpendicular to it
			//Vector2D e = b - a;
			var edgeVector:Point = subtractVectors(ptB, ptA);
			//eperp = Vector2D(-e.y, e.x);
			var edgeVectorPerp:Point = new Point(-(edgeVector.y), edgeVector.x);
			
			//Track index, distance, and rightmostness of currently best point
			//int bestIndex = -1
			var bestIndex:int = -1;
			//float maxVal = -FLT_MAX
			var maxVal:Number = -1000;
			//rightMostVal = -FLT_MAX;
			var rightMostVal:Number = -1000;
			
			//Test all points to find the one farthest from the edge ab on the left side
			for(var i:int = 1; i < n; i++)
			{
				var pointX:Number = pointsArray[i].x;
				var pointY:Number = pointsArray[i].y;
				var point:Point = new Point(pointX, pointY);
				//d is proportianl to distance along eperp
				//float d = Dot2D(p[i] - a, eperp);
				var d:Number = dotVectors(subtractVectors(point, ptA), edgeVectorPerp);
				//r is proportional to distance along e
				//float r = Dot2D(p[i] - e, e);
				var r:Number = dotVectors(subtractVectors(point, edgeVector), edgeVector);
				if(d > maxVal || (d == maxVal && r > rightMostVal))
				{
					bestIndex = i;
					maxVal = d;
					rightMostVal = r;
				}
				
			}
			return bestIndex;
		}
		
		//Clear everything off the screen and readd random pts
		private function clearEverythingOffScreen():void
		{
			graphics.clear();
			//Remove all of the pts from the screen
			for(var i:int = 0; i < pointsArray.length; i++)
			{
				removeChild(pointsArray[i]);
			}
			//Remove the points from the array
			for(var j:int = pointsArray.length - 1; j >= 0; j--)
			{
				pointsArray.pop();
			}
			//Remove the farthest out points 
			if(farthestPointsArray.length != 0)
			{
				//trace("Before farthestPointsArray.length " + farthestPointsArray.length);
				for(var k:int = farthestPointsArray.length - 1; k >= 0; k--)
				{
					farthestPointsArray.pop();
				}
			}
			//trace("farthestPointsArray.length " + farthestPointsArray.length);
			//trace("points array.length" + pointsArray.length);
			//Add new random points onto the screen
			init();
		}
		
		//Remove all the points in the convexHull using Barycentric coordinates technique
		private function removePtsInTriangle(ptA:Point, ptB:Point, ptC:Point, ptP:Point):Boolean
		{
			//Compute the vectors
			//v0 = C - A
			var v0:Point = subtractVectors(ptC, ptA);
			//v1 = B - A
			var v1:Point = subtractVectors(ptB, ptA);
			//v2 = P - A
			var v2:Point = subtractVectors(ptP, ptA);
			
			//Compute dot products
			//dot00 = dot(v0, v0)
			var dot00:Number = dotVectors(v0, v0);
			//dot01 = dot(v0, v1)
			var dot01:Number = dotVectors(v0, v1);
			//dot02 = dot(v0, v2)
			var dot02:Number = dotVectors(v0, v2);
			//dot11 = dot(v1, v1)
			var dot11:Number = dotVectors(v1, v1);
			//dot12 = dot(v1, v2)
			var dot12:Number = dotVectors(v1, v2);
			
			//Computer baryentric coordinates
			//invDenom = 1/(dot00 * dot11 - dot01 * dot01)
			var invDenom:Number = 1/(dot00 * dot11 - dot01 * dot01);
			//u = (dot11 * dot02 - dot01 * dot12) * invDenom
			var u:Number = (dot11 * dot02 - dot01 * dot12) * invDenom;
			//v = (dot00 * dot12 - dot01 * dot02) * invDenom
			var v:Number = (dot00 * dot12 - dot01 * dot02) * invDenom;
			
			//Check if point is in triangle
			//return (u >=0) && (v >=0) && (u + v < 1)
			return (u >= 0) && (v >= 0) && (u + v < 1);
		}
		
		//Subtract vectors from each other to return a new vector
		private function subtractVectors(ptA:Point, ptB:Point):Point
		{
			return new Point(ptA.x - ptB.x, ptA.y - ptB.y);
		}
		
		//Dot vectors to return a number
		private function dotVectors(ptA:Point, ptB:Point):Number
		{
			return ptA.x * ptB.x + ptA.y * ptB.y;
		}
		
	}
	
}
