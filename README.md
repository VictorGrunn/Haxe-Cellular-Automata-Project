Haxe-Cellular-Automata-Project
==============================
  @author Victor Grunn / Joseph Antolick
  
  The unimaginatively named TestGroup comprises the heart of this project.
  This was posed as a programming challenge on Reddit, where users were invited
  to create an environmental simulation/cellular automata following a 
  variety of simple rules.
  
  The grid should contain 50% trees, 10% Lumberjacks, and 2% bears.
  Every 'turn' should comprise a month.
  Each 'month', bears should move 5 random spaces. Lumberjacks, 3.
  If a lumberjack encountered a tree, it should be cut down and 1 wood should be gained.
  If a lumberjack encountered an elder tree, it should be cut down and 2 wood should be gained.
  If a lumberjack encountered a bear, the lumberjack should be removed.
  
  At the end of each year, if wood gathered exceeded total lumberjacks, additional lumberjacks should be added.
  If a lumberjack was eaten, remove 1 bear from the forest.
  
  Initially the game was supposed to end at either the elimination of all trees or a certain year. I have removed the
  year requirement for the purposes of this demonstration.
  
  A caveat: This game makes use of HaxeFlixel 3.5. HaxeFlixel has since been updated to 4.0, breaking some compatibility.
  But the original swf and code and 3.5 still represents the project as it was created.
 
  export/flash/bin contains the .swf, which will run on the latest Flash.
