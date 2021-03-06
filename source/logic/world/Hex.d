module logic.world.Hex;

import std.math;
import std.random;
import std.traits;
import graphics.Constants;
import logic.world.Coordinate;
import logic.world.World;
import d2d;

/**
 * The different factors which affect a climate
 */
enum ClimateFactor {
    TEMPERATURE,
    HUMIDITY,
    SUNLIGHT,
    ATMOSPHERE,
    SOIL
}

/**
 * A single hexagonal tile in the world
 * Hexes are the units for the world map
 * TODO: use std.algorithm.comparison.clamp to keep climate, weather, and elevation values between 0 and 1
 */
class Hex {

    Coordinate location; ///The unchangable location of the hex
    double elevation; ///Stores the elevation of the hex as a percentage of the highest elevation in the world
    double[ClimateFactor] baseClimate; ///The base values that exemplify the overall climate
    Direction waterFlow; ///How the water on the tile flows; if the tile isn't a river, is Direction.NONE
    Direction windFlow; ///How the wind on the tile flows; all tiles have a wind direction, but it can vary over time
    Image tempImage; 

    /**
     * Gets how the tile looks
     */
    @property Image representation() {
        return this.tempImage;
    }

    /**
     * Gets the linear distance to the nearest water tile
     * TODO:
     */
    @property int proximityToWater() {
        return 0;
    }

    /**
     * The current instantaneous weather
     * Dependent on the baseClimate, elevation, and proximityToWater
     * TODO:
     */
    @property double[ClimateFactor] weather() {
        return null;
    }

    /**
     * Returns the movement cost for a player walking on this hex.
     * TODO:
     */
    @property int movementCost() {
        immutable int[Image] movementCosts = [
            Image.BiomePlains : 1,
            Image.BiomeOak : 2,
            Image.BiomeRedwood : 3
        ];
        return movementCosts[this.tempImage];
    }

    /**
     * The Hex constructor
     * Creates a hex based on its location and climate
     */
    this(Coordinate location, double[ClimateFactor] climate = null, string image = null) {
        this.location = location;
        this.baseClimate = climate;
        this.tempImage = choice(biomeImages.dup);
    }

}
