module logic.item.plant.Plant;

import std.algorithm;
import std.traits;
import graphics.Constants;
import logic.item.Attribute;
import logic.item.Inventory;
import logic.item.Item;
import logic.item.plant.Species;
import logic.item.plant.Trait;
import logic.actor.Actor;

/**
 * A plant class that encompasses the behaviour of ALL plants
 * Plant behaviour and attributes are determined mostly by their traits and also potentially partially from their species
 * TODO:
 */
class Plant : Item {

    package double _completion; ///How grown the plant is
    package Actor _actor; ///The player that is currently interacting with the plant
    TraitSet genotype; ///All the traits the plant has
    TraitSet phenotype; ///All observable or visible traits the plant has and expresses
    immutable Breed species; ///What species the plant is

    /**
     * Gets the name of the plant; based on its species
     */
    override @property string name() {
        return this.species.name;
    }

    /**
     * Gets the description of the plant; based on its species
     */
    override @property string description() {
        return this.species.description;
    }

    /**
     * The plant will always look like whatever species it is
     */
    override @property Image representation() {
        return this.species.representation;
    }

    /**
     * Gets how complete or mature the plant is
     */
    override @property double completion() {
        return this._completion;
    }

    /**
     * Gets the qualitative aspects of the plant
     */
    override @property Quality[] qualities() {
        Quality[] allQuals;
        foreach(expr; EnumMembers!TraitExpression) {
            foreach(trait; this.phenotype[expr]) {
                allQuals ~= trait.qualities;
            }
        }
        return allQuals;
    }

    /**
     * Necessary constructor for all items
     */
    this(TraitSet traits) {
        this.genotype = traits;
        this.phenotype = getPhenotype(traits);
        this.species = getSpecies(traits);
    }

    /**
     * Constructs a plant using a species
     * Makes it a default plant of that species; has all common and required traits
     */
    this(Breed species) {
        this.species = species;
        TraitSet combinedTraits;
        foreach(expression; EnumMembers!TraitExpression) {
            combinedTraits[expression] = ((species.requiredTraits.keys.canFind(expression))? 
                    (cast(TraitSet) species.requiredTraits)[expression] : null) ~ 
                    ((species.commonTraits.keys.canFind(expression))? 
                    (cast(TraitSet) species.commonTraits)[expression] : null);
        }
        this.genotype = combinedTraits;
        this.phenotype = getPhenotype(combinedTraits);
    }

    override void onStep(Actor actor) {
        this._actor = actor;
        this.phenotype[TraitExpression.STEPPED_ON].each!(trait => trait(this));
        this._actor = null;
    }

    override void incrementalAction() {
        this.phenotype[TraitExpression.INCREMENT].each!(trait => trait(this));
    }

    override void mainAction(Actor actor) {
        this._actor = actor;
        this.phenotype[TraitExpression.MAIN].each!(trait => trait(this));
        this._actor = null;
    }

    override void onCreate(Actor actor) {
        this._actor = actor;
        this.phenotype[TraitExpression.CREATED].each!(trait => trait(this));
        this._actor = null;
    }

    override void onDestroy(Actor actor) {
        this._actor = actor;
        this.phenotype[TraitExpression.DESTROYED].each!(trait => trait(this));
        this._actor = null;
    }

}
