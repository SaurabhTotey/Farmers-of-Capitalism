module logic.world.World;

import std.math;
import std.random;
import graphics.Constants;
import logic.world.Coordinate;
import logic.world.Hex;

//A list of all biomes
immutable biomeImages = [Image.BiomePlains, Image.BiomeRedwood, Image.BiomeOak];

/**
 * The world
 * Represents the hexes in the game and actions that can be taken using them
 * Use GameWorld for game content
 */
class World {

    Hex[Coordinate] tiles; ///An array of all the hexes in the world
    ulong size; ///The size of the world

    /**
     * Generates a hexagonal world of a given radius (distance from center to corner)
     * TODO: add worldgen
     */
    this(ulong size) {
        this.size = size;
        for (long i = -1 * size; i <= cast(long)size; i++) {
            for (long j = -1 * size; j <= cast(long)size; j++) {
                if (abs(i + j) <= cast(long)size) {
                    this.tiles[new Coordinate(i, j)] = new Hex(new Coordinate(i, j), null, choice(biomeImages.dup));
                }
            }
        }
    }

    /**
     * Gets the Manhattan distance between two hexes by their coordinates
     * This is equivalent to the shortest path between them if each tile is equally passable
     */
    long getDistance(Coordinate a, Coordinate b) {
        return (abs(a.q - b.q) + abs(a.r - b.r) + abs(a.s - b.s)) / 2;
    }

    /**
     * Gets the cost of moving from one coordinate to another
     */
    long getCost(Coordinate a, Coordinate b) {
        return 1; //TODO:
    }

}
