/**
* Contains methods for creating, breeding, and genetically modifying plants.
*/
module PlantCreation;

import Plant;
import HexTile;
import PlantTraits;
import std.random;
import app;


/**
* Generates a random plant on the specified coordinates.
* Should be used during worldgen.
*/
Plant createPlant(int[] creationCoords){
    HexTile tile = mainWorld.getTileAt(creationCoords);
    Plant plant = new Plant();
    plant.survivableClimate["Temperature"] = [tile.temperature - uniform(0, 0.1), tile.temperature + uniform(0, 0.1)];
    plant.survivableClimate["Water"] = [tile.water - uniform(0, 0.1), tile.water + uniform(0, 0.1)];
    plant.survivableClimate["Soil"] = [tile.soil - uniform(0, 0.1), tile.soil + uniform(0, 0.1)];
    plant.survivableClimate["Elevation"] = [tile.elevation - uniform(0, 0.1), tile.elevation + uniform(0, 0.1)];
    if(tile.isWater){ plant.attributes["Aquatic"] = 1; }
    double chanceBound = 1.0;
    foreach(possibleAttribute; naturallyPossibleAttributes){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.attributes[possibleAttribute] = uniform(1,3);
            chanceBound -= 0.04;
        }
    }
    foreach(possibleAttribute; naturallyPossibleIncrementalActions){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.incrementalActions ~= possibleAttribute;
            chanceBound -= 0.04;
        }
    }
    foreach(possibleAttribute; naturallyPossibleSteppedOnActions){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.steppedOnActions ~= possibleAttribute;
            chanceBound -= 0.04;
        }
    }
    foreach(possibleAttribute; naturallyPossiblePlacedActions){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.placedActions ~= possibleAttribute;
            chanceBound -= 0.04;
        }
    }
    foreach(possibleAttribute; naturallyPossibleDestroyedActions){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.destroyedActions ~= possibleAttribute;
            chanceBound -= 0.04;
        }
    }
    foreach(possibleAttribute; naturallyPossibleMainActions){
        if(uniform(0.0, chanceBound) >= 0.8){
            plant.mainActions ~= possibleAttribute;
            chanceBound -= 0.04;
        }
    }
    int statsToGive =  10;
    string[] statTypes = ["Growth", "Resilience", "Yield", "Seed Strength", "Seed Quantity"];
    foreach(int i; 0..statsToGive+1){
        plant.stats[statTypes[uniform(0,$)]] += 1;
    }
    return plant;
}