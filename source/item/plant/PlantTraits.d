module item.plant.PlantTraits;

import std.algorithm;
import std.conv;
import std.math;
import std.random;

import character.Character;
import item.plant.Plant;
import world.Range;
import world.World;

/**
 * Specifies how a trait should show up
 * A higher inheritance type dominates over a lower inheritance type and so the lower ones would not show up
 * Co-dominant and co-recessive traits can show up together, but can be dominated as well
 * Does not support incomplete dominance where traits are mixed because of the slotting nature of traits
 */
enum VisibilityType{
    WEAK_RECESSIVE, CO_RECESSIVE, STRONG_RECESSIVE, WEAK_DOMINANT, CO_DOMINANT, STRONG_DOMINANT
}

/**
 * Stores an trait name, how the trait is visible, and what the trait does when slotted
 * Action is ideally a function
 * Is as it is so that each trait is slottable and has an effect in some way for when it is slotted
 */
class Trait(T){
    VisibilityType type;            ///How the trait would surface
    Point difficulty;               ///The difficulty of this trait; traits close together are closely related and more likely to mutate into each other, but farther away traits are more likely to be mutually exclusive and are harder to obtain together
    T action;                       ///What this trait would do when slotted; is ideally a function
    //alias action this;            Ideally makes it so the trait is accessible as what it does, but it doesn't work

    this(VisibilityType type, Point difficulty, T action){
        this.type = type;
        this.difficulty = difficulty;
        this.action = action;
    }
}

/**
 * A point in 2 dimensional space
 * Is only used to organize traits into a plane to see how related traits may be
 * Traits that are far away from each other are difficult to obtain in a single category
 * Traits that are on opposite axes (eg quadrants 1 and 3 or quadrants 2 and 4) are mutually exclusive
 * Traits close to the origin are naturally occuring
 * The closer traits are, the more related they are and the more likely one will mutate into the other were they to mutate
 */
struct Point{
    int x;              ///The x value of the point
    int y;              ///The y value of the point
    alias coords this;  ///Allows the point to be accessed as an array of its points

    /**
     * Gets the point as an array of its points
     */
    @property int[] coords(){
        return [x, y];
    }
}

/**
 * Gets the distance between two points
 */
double distance(Point first, Point second = Point(0, 0)){
    return sqrt(((first.x - second.x).pow(2) + (first.y - second.y).pow(2)).to!double);
}

/**
 * Returns whether two traits are mutually exclusive
 * Mutually exclusive traits are traits that are respectively in cartesian quadrants 1 and 3 or 2 and 4
 */
bool canWorkTogether(T)(Trait!T first, Trait!T second){
    return (first.difficulty.x < 0) == (second.difficulty.x < 0) || (first.difficulty.y < 0) == (second.difficulty.y < 0);
}

/**
 * A struct that stores a set of traits
 * Stores them by the type of functions an item would require
 */
struct TraitSet{
    Trait!(Coordinate function(Plant))[] locationAsSeedActions;
    Trait!(Character function(Plant))[] getOwnerActions;
    Trait!(bool function(Coordinate, Plant))[] canBePlacedActions;
    Trait!(double function(Character, Plant))[] getMovementCostActions;
    Trait!(void function(Character, Plant))[] steppedOnActions;
    Trait!(void function(Plant))[] incrementalActions;
    Trait!(void function(Character, Plant))[] mainActions;
    Trait!(void function(Character, Plant))[] destroyedActions;
    Trait!(int function(Plant))[] getSizeActions;

    /**
     * Gets all the traits from the set that would actually be visible
     * So if a category were to, for example, have a dominant and a recessive trait in a category, it would return the category with only the dominant trait
     */
    TraitSet getVisibleTraits(){
        //This is the method that actually filters each category into its visible traits
        Trait!(T)[] filterVisible(T)(Trait!(T)[] category){
            Trait!(T)[] visible = [category[0]];
            foreach(trait; category){
                if(trait.type > visible[0].type){
                    visible = [trait];
                }else if(visible[0].type == trait.type){
                    void randVisible(){
                        visible = [(uniform(0, 2) == 0)? visible[0] : trait];
                    }
                    if(trait.type == VisibilityType.CO_RECESSIVE || trait.type == VisibilityType.CO_DOMINANT){
                        if(canWorkTogether!T(visible[0], trait)){
                            visible ~= trait;
                        }else{
                            randVisible();
                        }
                    }else{
                        //Will choose the trait with the lesser distance, or if the distances are the same, a random trait
                        double alreadyExistingDistance = visible[0].difficulty.distance;
                        double challengerDistance = trait.difficulty.distance;
                        if(Range!double(alreadyExistingDistance - 0.000001, alreadyExistingDistance + 0.000001).isInRange(challengerDistance)){
                            randVisible();
                        }else{
                            visible = [(alreadyExistingDistance < challengerDistance)? visible[0] : trait];
                        }
                    }
                }
            }
            return visible;
        }
        //Just returns the above method called on each category
        return TraitSet(
            filterVisible(this.locationAsSeedActions),
            filterVisible(this.getOwnerActions),
            filterVisible(this.canBePlacedActions),
            filterVisible(this.getMovementCostActions),
            filterVisible(this.steppedOnActions),
            filterVisible(this.incrementalActions),
            filterVisible(this.mainActions),
            filterVisible(this.destroyedActions),
            filterVisible(this.getSizeActions)
        );
    }
}

/**
 * A collection of things that would define a pre-defined plant
 * Any plant would be compared to all default plants to figure out what species the plant is by whatever default plant it is closest to
 */
class DefaultPlant{
    string name;                    ///The name of this defualt plant so the player can find out what species their plant is
    TraitSet defaultTraits;         ///The set of traits the plant has by default
    bool isNatural;                 ///Whether the plant occurs naturally

    /**
     * Compares a plant to this pre-defined plant to see how close they are
     * The closest pre-defined plant is its species
     */
    double closenessTo(Plant toCompare){
        double sumOfCategory(T)(Trait!T[] firstCategory, Trait!T[] secondCategory){
            double sum;
            foreach(firstTrait; firstCategory){
                foreach(secondTrait; secondCategory){
                    sum += distance(firstTrait.difficulty, secondTrait.difficulty);
                }
            }
            return sum;
        }
        TraitSet attr = toCompare.traits;
        TraitSet self = this.defaultTraits;
        return [
            sumOfCategory(self.locationAsSeedActions, attr.locationAsSeedActions),
            sumOfCategory(self.getOwnerActions, attr.getOwnerActions),
            sumOfCategory(self.canBePlacedActions, attr.canBePlacedActions),
            sumOfCategory(self.getMovementCostActions, attr.getMovementCostActions),
            sumOfCategory(self.steppedOnActions, attr.steppedOnActions),
            sumOfCategory(self.incrementalActions, attr.incrementalActions),
            sumOfCategory(self.mainActions, attr.mainActions),
            sumOfCategory(self.destroyedActions, attr.destroyedActions),
            sumOfCategory(self.getSizeActions, attr.getSizeActions),
        ].sum;
    }
}

TraitSet allActions = TraitSet();           ///Stores a set of all actions
DefaultPlant[] allDefaultPlants;            ///Stores all default plants so that any plant can be compared to this list, and whichever plant it is closest to is its species
