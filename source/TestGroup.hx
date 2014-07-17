package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Victor Grunn / Joseph Antolick
 * 
 * The unimaginatively named TestGroup comprises the heart of this project.
 * This was posed as a programming challenge on Reddit, where users were invited
 * to create an environmental simulation/cellular automata following a 
 * variety of simple rules.
 * 
 * The grid should contain 50% trees, 10% Lumberjacks, and 2% bears.
 * Every 'turn' should comprise a month.
 * Each 'month', bears should move 5 random spaces. Lumberjacks, 3.
 * If a lumberjack encountered a tree, it should be cut down and 1 wood should be gained.
 * If a lumberjack encountered an elder tree, it should be cut down and 2 wood should be gained.
 * If a lumberjack encountered a bear, the lumberjack should be removed.
 * 
 * At the end of each year, if wood gathered exceeded total lumberjacks, additional lumberjacks should be added.
 * If a lumberjack was eaten, remove 1 bear from the forest.
 * 
 * Initially the game was supposed to end at either the elimination of all trees or a certain year. I have removed the
 * year requirement for the purposes of this demonstration.
 * 
 * A caveat: This game makes use of HaxeFlixel 3.5. HaxeFlixel has since been updated to 4.0, breaking some compatibility.
 * But the original swf and code and 3.5 still represents the project as it was created.
 */
class TestGroup extends FlxGroup
{
	private var statusText:FlxText;
	private var finalStatus:FlxText;
	private var mapArray:Array < Array < Occupant_Land >> ;
	
	public static var occupantsArray:Array <Occupant_Creature> ;
	
	private var mapGroup:FlxTypedGroup<Occupant_Land>;
	private var occupantsGroup:FlxTypedGroup<Occupant_Creature>;	
	
	public static var mapSize:Int = 50;
	public static var pieceSize:Int = 5;
	public static var mapAccessArray:Array < Array < Occupant_Land >> ;
	
	public static var month:Int = 0;
	public static var year:Int = 0;
	
	public static var TotalWoodThisYear:Int = 0;
	public static var TotalWoodEver:Int = 0;
	
	public static var totalLivingBears:Int = 0;
	public static var totalLivingLumberjacks:Int = 0;
	
	public static var totalDeadLumberjacks:Int = 0;
	public static var totalDeadLumberjacksThisYear:Int = 0;
	
	public static var totalElderTreesLeft:Int = 0;
	public static var totalNormalTreesLeft:Int = 0;
	public static var totalSaplingsLeft:Int = 0;
	
	private var gameTimer:FlxTimer;

	/*
	 * The constructor for the unimaginatively named TestGroup. The grid is initialized, as is the statustext display.
	 * 
	 */
	
	public function new() 
	{
		super();
		
		trace("LOADED.");
		
		mapArray = new Array < Array < Occupant_Land >> ();
		TestGroup.occupantsArray = new Array <Occupant_Creature > ();		
		
		mapAccessArray = mapArray;		
				
		statusText = new FlxText(0, 0, 350);
		statusText.setFormat(null, 12, FlxColor.WHITE, "left");
		statusText.text = "Test.";
		add(statusText);		
		
		mapGroup = new FlxTypedGroup<Occupant_Land>();
		add(mapGroup);		
		
		occupantsGroup = new FlxTypedGroup<Occupant_Creature>();
		add(occupantsGroup);		
		
		initMap();							
		
		gameTimer = new FlxTimer(1, onTimerComplete, 0);			
		
		//A built-in debugger watch to keep track of how many total occupants (Bears + Lumberjacks) are present at any given time.
		FlxG.watch.add(TestGroup.occupantsArray, "length", "Occupants: ");		
	}		
	
	
	/*
	 * HaxeFlixel's 'update' is one of the hearts and souls of the library. It updates as needed, often tuned to the FPS settings,
	 * cycling through every Flixel display object, handling timers, and so on.
	 */
	override public function update():Void
	{
		super.update();
		
		if (!gameTimer.active)
		{
			if (FlxG.keys.justPressed.R)
			{
				FlxG.resetGame();
			}
		}
	}
	/*
	 * A function that updates all of the text as needed in one go. 
	 */
	public function updateText():Void
	{
		statusText.text = 
		"Total Wood Gathered Ever: " + TestGroup.TotalWoodEver +
		"\nTotal Wood Gather This Year: " + TestGroup.TotalWoodThisYear +
		"\nTotal Dead Lumberjacks Ever: " + TestGroup.totalDeadLumberjacks +
		"\nTotal Dead Lumberjacks This Year: " + TestGroup.totalDeadLumberjacksThisYear +
		"\nTotal Living Bears: " + TestGroup.totalLivingBears +
		"\nTotal Living Lumberjacks: " + TestGroup.totalLivingLumberjacks +
		"\nTotal Elder Trees Left: " + TestGroup.totalElderTreesLeft +
		"\nTotal Normal Trees Left: " + TestGroup.totalNormalTreesLeft +
		"\nTotal Saplings Left: " + TestGroup.totalSaplingsLeft +
		"\nYear: " + TestGroup.year +
		"\nMonth: " + TestGroup.month;
	}
	
	/*
	 * The lifeblood of the program. On every tick of the FlxTimer, the following takes places:
	 * 
	 * Every tree is aged one month, which in turn 'upgrades' the tree if 12 months has passed.
	 * The count of trees is also cataloged for text display as well as visual.
	 * 
	 * Every 'occupant' (bear, lumberjack) is given the roam command. Each will roam 3-5 random
	 * spaces depending on whether they are a lumberjack (3) or bear (5), and assuming there are no
	 * encounters in the interim.
	 * 
	 * Other statistics are given either current or lifetime updates as needed. If the trees have
	 * all been eliminated or if year 400 has been reached, the simulation ends and can be restarted.
	 */	
	private function onTimerComplete(t:FlxTimer):Void
	{	
		TestGroup.totalElderTreesLeft = 0;
		TestGroup.totalNormalTreesLeft = 0;
		TestGroup.totalSaplingsLeft = 0;
		
		for (i in 0...mapArray.length)
		{
			for (o in 0...mapArray[i].length)
			{
				mapArray[i][o].ageOneMonth();			
				
				if (mapArray[i][o].ID_TYPE == OCCTYPE_LAND.TREE_ELDER)
				{
					totalElderTreesLeft += 1;
				}
				else if (mapArray[i][o].ID_TYPE == OCCTYPE_LAND.TREE_TREE)
				{
					totalNormalTreesLeft += 1;
				}
				else if (mapArray[i][o].ID_TYPE == OCCTYPE_LAND.TREE_SAPLING)
				{
					totalSaplingsLeft += 1;
				}
			}											
		}						
		
		for (o in 0...TestGroup.occupantsArray.length)
		{
			if (TestGroup.occupantsArray[o] != null)
			{
				TestGroup.occupantsArray[o].roam();
			}				
		}					
		
		TestGroup.totalLivingBears = 0;
		TestGroup.totalLivingLumberjacks = 0;
		
		for (i in 0...TestGroup.occupantsArray.length)
		{
			if (TestGroup.occupantsArray[i] != null)
			{
				if (TestGroup.occupantsArray[i].exists)
				{
					if (TestGroup.occupantsArray[i].ID_TYPE == OCCTYPE_CREATURE.LUMBERJACK)
					{
						TestGroup.totalLivingLumberjacks += 1;
					}
					
					if (TestGroup.occupantsArray[i].ID_TYPE == OCCTYPE_CREATURE.BEAR)
					{
						TestGroup.totalLivingBears += 1;
					}
				}
			}
		}
		
		TestGroup.month += 1;
		
		if (TestGroup.month == 12)
		{
			if (TotalWoodThisYear < totalLivingLumberjacks)
			{
				for (i in 0...occupantsArray.length)
				{
					if (occupantsArray[i] != null && occupantsArray[i].exists && occupantsArray[i].ID_TYPE == OCCTYPE_CREATURE.LUMBERJACK)
					{
						occupantsArray[i].currentLocation.removeOccupant(occupantsArray[i]);
						occupantsArray[i].exists = false;
						occupantsArray.remove(occupantsArray[i]);
						break;
					}
				}
			}
			else if (TotalWoodThisYear >= totalLivingLumberjacks)
			{
				var woodScope:Int = TotalWoodThisYear - totalLivingLumberjacks;
				
				var hires:Int = Math.floor(woodScope / 10);
				if (hires <= 0)
				{
					hires = 1;
				}
				
				for (i in 0...hires)
				{
					generateJack();
				}
			}
			
			if (totalDeadLumberjacksThisYear > 0)
			{
				for (i in 0...occupantsArray.length)
				{
					if (occupantsArray[i] != null && occupantsArray[i].exists && occupantsArray[i].ID_TYPE == OCCTYPE_CREATURE.BEAR)
					{
						occupantsArray[i].currentLocation.removeOccupant(occupantsArray[i]);
						occupantsArray[i].exists = false;
						occupantsArray.remove(occupantsArray[i]);
						break;
					}
				}
			}
			else
			{
				generateBear();
			}
			
			TestGroup.month = 0;
			TestGroup.year += 1;
			TestGroup.TotalWoodThisYear = 0;
			TestGroup.totalDeadLumberjacksThisYear = 0;
		}
		
		updateText();
		
		if (totalElderTreesLeft == 0 && totalNormalTreesLeft == 0 && totalSaplingsLeft == 0)
		{
			gameTimer.cancel();
			finalStatus = new FlxText(0, 0, FlxG.width, "AND THE LORAX WEPT.\nPRESS R TO DEPRESS ANOTHER LORAX.", 30);
			finalStatus.alignment = "center";
			finalStatus.draw();
			finalStatus.y = FlxG.height - finalStatus.height;
			add(finalStatus);
			
			TestGroup.totalDeadLumberjacks = 0;
			TestGroup.totalDeadLumberjacksThisYear = 0;
			TestGroup.totalElderTreesLeft = 0;
			TestGroup.totalLivingBears = 0;
			TestGroup.totalLivingLumberjacks = 0;
			TestGroup.totalNormalTreesLeft = 0;
			TestGroup.totalSaplingsLeft = 0;
			TestGroup.TotalWoodEver = 0;
			TestGroup.TotalWoodThisYear = 0;
			TestGroup.year = 0;
			TestGroup.month = 0;
		}
		
		if (year == 400)
		{
			gameTimer.cancel();
			finalStatus = new FlxText(0, 0, FlxG.width, "AND THE LORAX WEPT.\nPRESS R TO DEPRESS ANOTHER LORAX.", 30);
			finalStatus.alignment = "center";
			finalStatus.draw();
			finalStatus.y = FlxG.height - finalStatus.height;
			add(finalStatus);
		}
	}
	
	//The map initializer. Generates the X by X grid which will contain all of the 'land', and randomly disperses trees throughout the map.
	public function initMap():Void
	{		
		for (i in 0...mapSize)
		{
			mapArray[i] = new Array<Occupant_Land>();
			
			for (o in 0...mapSize)
			{
				//mapArray[i][o] = mapGroup.recycle(Occupant_Land, [OCCTYPE_LAND.EMPTY, mapArray]);
				mapArray[i][o]  = mapGroup.recycle(Occupant_Land);
				mapArray[i][o].setType(OCCTYPE_LAND.EMPTY);
				mapArray[i][o] = mapGroup.recycle(Occupant_Land);
				mapArray[i][o].x = (FlxG.width - (mapSize * pieceSize)) + i * pieceSize;
				mapArray[i][o].y = o * pieceSize;
				mapArray[i][o].xSlot = i;
				mapArray[i][o].ySlot = o;
			}			
		}
		
		var treeCount:Int = Std.int((mapSize * mapSize) * .5);		
		
		while (treeCount > 0)
		{
			var checkX:Int = Math.floor(Math.random() * mapSize);
			var checkY:Int = Math.floor(Math.random() * mapSize);
			
			if (mapArray[checkX][checkY].ID_TYPE == OCCTYPE_LAND.EMPTY)
			{
				mapArray[checkX][checkY].setType(OCCTYPE_LAND.TREE_TREE);
				treeCount -= 1;
			}						
		}				
		
		trace("Map initialized.");
		initOccupants();
	}
	
	//A function for generating and adding a Lumberjack to the occupantsGroup.
	//This group displays on a layer over the land, so neither lumberjacks nor bears 'hide behind' trees.
	private function generateJack():Void
	{
		var checkX:Int = Math.floor(Math.random() * mapSize);
		var checkY:Int = Math.floor(Math.random() * mapSize);
		
		if (mapArray[checkX][checkY].occupying.length == 0)
		{
			//var jack:Occupant_Creature = occupantsGroup.recycle(Occupant_Creature, [OCCTYPE_CREATURE.LUMBERJACK]);	
			var jack:Occupant_Creature = occupantsGroup.recycle(Occupant_Creature);
			jack.setType(OCCTYPE_CREATURE.LUMBERJACK);
			jack.xSlot = checkX;
			jack.ySlot = checkY;
			mapArray[checkX][checkY].setOccupant(jack);				
			TestGroup.occupantsArray.push(jack);
		}
	}
	
	//Generates bears who will randomly wander and, if confronted with a lumberjacks, enjoy a meal.
	private function generateBear():Void
	{
		var checkX:Int = Math.floor(Math.random() * mapSize);
		var checkY:Int = Math.floor(Math.random() * mapSize);
		
		if (mapArray[checkX][checkY].occupying.length == 0)
		{
			//var bear:Occupant_Creature = occupantsGroup.recycle(Occupant_Creature, [OCCTYPE_CREATURE.BEAR]);
			var bear:Occupant_Creature = occupantsGroup.recycle(Occupant_Creature);
			bear.setType(OCCTYPE_CREATURE.BEAR);
			bear.xSlot = checkX;
			bear.ySlot = checkY;
			mapArray[checkX][checkY].setOccupant(bear);				
			TestGroup.occupantsArray.push(bear);			
		}
	}
	
	/*
	 * Initializes the occupants in proportion to the mapsize. 10% Jacks and 2% bears compared to the initial area of the grid.
	 */
	private function initOccupants():Void
	{				
		var jackCount:Int = Std.int((mapSize * mapSize) * .10);			
		var bearCount:Int = Std.int((mapSize * mapSize) * .02);
		
		while (jackCount > 0)
		{
			jackCount -= 1;
			generateJack();
		}
		
		while (bearCount > 0)
		{
			bearCount -= 1;
			generateBear();
		}	
		
		trace("Occupants initialized.");			
	}		
	
}

/*
 * The class which deals with 'land occupants'. In this case: trees, in the form of sapling, normal and elder, along with an 'empty'.
 * Empty is colored green to represent grass. Each Occupant_Land also contains an 'occupying' array/vector of occupant creatures, which
 * allows multiple creatures to occupy a single land space.
 * 
 */
class Occupant_Land extends FlxSprite
{	
	public var ID_TYPE:OCCTYPE_LAND;
	public var occupying:Array<Occupant_Creature>;
	private var age:Int = 0;
	
	public var xSlot:Int = 0;
	public var ySlot:Int = 0;
	
	//public function new(_type:OCCTYPE_LAND, _mapArray:Array<Array<Occupant_Land>>)
	public function new()
	{
		super();
		
		//setType(_type);
		occupying = new Array<Occupant_Creature>();
	}			
	
	//Called on each Timer update, aging trees one month. It also ages empty spaces and elder trees, despite their inability to change into anything.
	//Everyone deserves to celebrate a birthday, after all.
	public function ageOneMonth():Void
	{		
		if (ID_TYPE != OCCTYPE_LAND.EMPTY)
		{
			age += 1;
			
			if (age >= 12)
			{
				age = 0;							
				
				if (ID_TYPE == OCCTYPE_LAND.TREE_SAPLING)
				{
					setType(OCCTYPE_LAND.TREE_TREE);
				}
				else if (ID_TYPE == OCCTYPE_LAND.TREE_TREE)
				{
					setType(OCCTYPE_LAND.TREE_ELDER);
				}
			}						
			
			if (ID_TYPE == OCCTYPE_LAND.TREE_TREE || ID_TYPE == OCCTYPE_LAND.TREE_ELDER)
			{
				spawnSapling(ID_TYPE);
			}
		}						
	}
	
	//Normal and elder trees have a 10% and 20% chance respectively to spawn a sapling in any empty land space adjacent to them (8 way grid.)
	//Eligible spaces are tested for, ruling out invalid spaces (edges, corners, and spaces which already have trees).
	private function spawnSapling(_type:OCCTYPE_LAND):Void
	{
		var threshold:Float = .8;
		
		if (_type == OCCTYPE_LAND.TREE_ELDER)
		{
			threshold = .8;
		}
		else
		{
			threshold = .9;
		}				
		
		if (Math.random() > threshold)
		{
			var myX:Int = 0;
			var myY:Int = 0;													
			
			myX = xSlot;
			myY = ySlot;						
			
			var testArray = new Array<ArrayChecker>();			
			var checkArray = new Array<ArrayChecker>();
			
			testArray[0] = new ArrayChecker(myX - 1, myY - 1);			
			testArray[1] = new ArrayChecker(myX, myY - 1);
			testArray[2] = new ArrayChecker(myX + 1, myY - 1);
			testArray[3] = new ArrayChecker(myX - 1, myY);
			testArray[4] = new ArrayChecker(myX + 1, myY);
			testArray[5] = new ArrayChecker(myX - 1, myY + 1);
			testArray[6] = new ArrayChecker(myX, myY + 1);
			testArray[7] = new ArrayChecker(myX + 1, myY + 1);					
			
			var foundMatch:Bool = false;			
			var spawnChecker:ArrayChecker = new ArrayChecker(0, 0);
			
			for (i in 0...testArray.length)
			{
				if (testArray[i].x < 0 || testArray[i].x > TestGroup.mapSize - 1 || testArray[i].y < 0 || testArray[i].y > TestGroup.mapSize - 1)
				{
					checkArray.push(testArray[i]);		
				}
			}
			
			for (i in 0...checkArray.length)
			{
				testArray.remove(checkArray[i]);
			}
			
			while (checkArray.length > 0)
			{
				checkArray.pop();
			}
			
			while (testArray.length > 0 && foundMatch == false)
			{				
				//var tester:ArrayChecker = testArray.pop();
				var tester:ArrayChecker = testArray[Math.floor(Math.random() * testArray.length)];
				foundMatch = checkSapling(tester.x, tester.y);
				
				if (foundMatch)
				{
					spawnChecker = tester;	
					for (i in 0...testArray.length)
					{
						testArray[i] = null;
					}
				}
				else
				{
					testArray.remove(tester);
				}
			}
			
			if (foundMatch)
			{
				if (spawnChecker != null)
				{
					TestGroup.mapAccessArray[spawnChecker.x][spawnChecker.y].setType(OCCTYPE_LAND.TREE_SAPLING);
				}				
			}						
		}				
	}
	
	//Helper function for spawnSapling, making sure tested grid spaces exist and are empty.
	private function checkSapling(_x:Int, _y:Int):Bool		
	{						
		if (TestGroup.mapAccessArray[_x][_y].ID_TYPE != null && TestGroup.mapAccessArray[_x][_y].ID_TYPE == OCCTYPE_LAND.EMPTY)
		{						
			return true;
		}
		
		return false;
	}	
	
	//Places the wandering occupant in the Occupant_Land's grid, and updates the creature's current location.
	public function setOccupant(_creature:Occupant_Creature):Void
	{
		occupying.push(_creature);
		_creature.x = this.x;
		_creature.y = this.y;
		_creature.xSlot = xSlot;
		_creature.ySlot = ySlot;
		if (_creature.currentLocation != null)
		{
			_creature.currentLocation.removeOccupant(_creature);
		}		
		_creature.currentLocation = this;
		
		resolveOccupants(_creature);
	}
	
	//Helper for setOccupant.
	public function removeOccupant(_creature:Occupant_Creature):Void
	{
		occupying.remove(_creature);
	}
	
	/*
	 * Determines the results of occupants. If this Occupant_Land has a tree/elder tree and a lumberjack, the tree is harvested, the space
	 * is set to empty, and wood is gained. If there is a bear and a lumberjack present, the lumberjack goes to the hospital (is removed)
	 * and the relevant counters are updated.
	 */
	private function resolveOccupants(_creature:Occupant_Creature):Void
	{	
		switch(_creature.ID_TYPE)
		{
			case OCCTYPE_CREATURE.LUMBERJACK:
				for (i in 0...occupying.length)
				{
					if (occupying[i] != null && occupying[i].ID_TYPE == OCCTYPE_CREATURE.BEAR)
					{
						TestGroup.totalDeadLumberjacks += 1;
						TestGroup.occupantsArray.remove(_creature);
						_creature.exists = false;
						_creature.stopMoving();
						removeOccupant(_creature);
						return;
					}																							
				}
				
				if (ID_TYPE == OCCTYPE_LAND.TREE_TREE)
				{
					setType(OCCTYPE_LAND.EMPTY);
					TestGroup.TotalWoodEver += 1;
					TestGroup.TotalWoodThisYear += 1;
					_creature.stopMoving();
				}
				
				if (ID_TYPE == OCCTYPE_LAND.TREE_ELDER)
				{
					setType(OCCTYPE_LAND.EMPTY);
					TestGroup.TotalWoodEver += 2;
					TestGroup.TotalWoodThisYear += 2;
					_creature.stopMoving();
				}
				
			case OCCTYPE_CREATURE.BEAR:
				for (i in 0...occupying.length)
				{
					if (occupying[i] != null && occupying[i].ID_TYPE == OCCTYPE_CREATURE.LUMBERJACK)
					{
						TestGroup.totalDeadLumberjacks += 1;
						TestGroup.totalDeadLumberjacksThisYear += 1;
						occupying[i].exists = false;
						TestGroup.occupantsArray.remove(occupying[i]);
						_creature.stopMoving();
						removeOccupant(occupying[i]);
					}
				}
				
		}
	}
	
	//Changes the color and resets the age to represent a new tree spawn/age.
	public function setType(_type:OCCTYPE_LAND):Void
	{
		ID_TYPE = _type;
		
		switch (ID_TYPE)
		{
			case OCCTYPE_LAND.EMPTY:
				age = 0;
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, 0xffccff00);
				
			case OCCTYPE_LAND.TREE_ELDER:		
				age = 0;
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, 0xff336633);
				
			case OCCTYPE_LAND.TREE_SAPLING:
				age = 0;
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, 0xff00ff33);
				
			case OCCTYPE_LAND.TREE_TREE:				
				age = 0;
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, 0xff009966);
		}		
	}
}

/*
 * 
 * The Occupant_Creature class only has two types - bear and lumberjack.
 * Similar to how Occupant_Land's enum type determines how it 'updates' each turn,
 * the bear or lumberjack will wander in a random pattern (3 spaces for the lumberjack,
 * 5 for the bear), randomly (similar to how saplings spawn for the trees). The Occupant_Land
 * actually resolves conflicts between either of the two.
 */
class Occupant_Creature extends FlxSprite
{
	public var ID_TYPE:OCCTYPE_CREATURE;
	public var currentLocation:Occupant_Land;
	
	public var xSlot:Int = 0;
	public var ySlot:Int = 0;
	
	private var movesLeft:Int = 0;
	
	//public function new(_type:OCCTYPE_CREATURE)
	public function new()
	{
		super();

		//setType(_type);
	}		
	
	public function setType(_type:OCCTYPE_CREATURE)
	{
		ID_TYPE = _type;
		exists = true;
		
		switch (ID_TYPE)
		{
			case OCCTYPE_CREATURE.BEAR:				
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, FlxColor.RED);				
				
			case OCCTYPE_CREATURE.LUMBERJACK:
				makeGraphic(TestGroup.pieceSize, TestGroup.pieceSize, FlxColor.BLUE);
		}
	}
	
	public function roam():Void
	{
		if (ID_TYPE == OCCTYPE_CREATURE.BEAR)
		{
			movesLeft = 5;
		}
		
		if (ID_TYPE == OCCTYPE_CREATURE.LUMBERJACK)
		{
			movesLeft = 3;
		}
		
		while (movesLeft > 0 && exists == true)
		{
			makeMove();
		}
	}
	
	public function stopMoving():Void
	{
		movesLeft = 0;
	}
	
	//The movement, called on a while loop until the moves are exhausted.
	private function makeMove():Void
	{
		var myX:Int = 0;
		var myY:Int = 0;													
		
		myX = xSlot;
		myY = ySlot;						
		
		var testArray = new Array<ArrayChecker>();			
		var checkArray = new Array<ArrayChecker>();
		
		testArray[0] = new ArrayChecker(myX - 1, myY - 1);			
		testArray[1] = new ArrayChecker(myX, myY - 1);
		testArray[2] = new ArrayChecker(myX + 1, myY - 1);
		testArray[3] = new ArrayChecker(myX - 1, myY);
		testArray[4] = new ArrayChecker(myX + 1, myY);
		testArray[5] = new ArrayChecker(myX - 1, myY + 1);
		testArray[6] = new ArrayChecker(myX, myY + 1);
		testArray[7] = new ArrayChecker(myX + 1, myY + 1);					
				
		var spawnChecker:ArrayChecker = new ArrayChecker(0, 0);
		
		for (i in 0...testArray.length)
		{
			if (testArray[i].x < 0 || testArray[i].x > TestGroup.mapSize - 1 || testArray[i].y < 0 || testArray[i].y > TestGroup.mapSize - 1)
			{
				checkArray.push(testArray[i]);		
			}
		}
		
		for (i in 0...checkArray.length)
		{
			testArray.remove(checkArray[i]);
		}
		
		while (checkArray.length > 0)
		{
			checkArray.pop();
		}
		
		var usingCheck:ArrayChecker = testArray[Math.floor(Math.random() * testArray.length)];
		
		for (i in 0...testArray.length)
		{
			testArray[i] = null;
		}
		
		movesLeft -= 1;
		TestGroup.mapAccessArray[usingCheck.x][usingCheck.y].setOccupant(this);						
	}
}

enum OCCTYPE_LAND
{
	EMPTY;
	TREE_SAPLING;
	TREE_TREE;
	TREE_ELDER;
}

enum OCCTYPE_CREATURE
{
	BEAR;
	LUMBERJACK;
}

//A simple ArrayChecker object used to make calculations a bit easier to understand.
class ArrayChecker
{
	public var x:Int;
	public var y:Int;
	
	public function new(_x:Int, _y:Int)
	{
		x = _x;
		y = _y;
	}
}