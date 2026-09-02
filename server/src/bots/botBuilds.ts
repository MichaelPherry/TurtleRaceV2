import { Room } from "colyseus";
import type { Client } from "colyseus";

export const bot_list: string[] = ["speed", "tank", "gun"];

type Turtle = {
    items : {
        leftArm: string | null;
        rightArm: string | null;
        head: string | null;
        shell: string | null;
        legs: string | null;
    },

    base_stats : {
        acceleration: number | 5.0;
        resilience: number | 0.1;
        max_speed: number | 300.0;
        fire_rate: number | 1.0;
        projectile_speed: number | 1.0;
        luck: number | 1.0;
    },

    econ : {
        gold: number | 10;
        //stock1: Int16Array | 0;
        //stock2: Int16Array | 0;
        //stock3: Int16Array | 0;
        //stock4: Int16Array | 0;
    }
};

export class botBuilds extends Room {
    turtles: Record<string, Record<string, Turtle>> = {};

    constructor() {
        super();
        this.turtles = {
        "1": {
                "speed" : {
                    "items" : { 
                        "leftArm" : null,
                        "rightArm" : null,
                        "head" : null,
                        "shell" : null,
                        "legs" : "rollerskates"
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "tank" : {
                    "items" : { 
                        "leftArm" : null,
                        "rightArm" : "fissile_cannon",
                        "head" : null,
                        "shell" : null,
                        "legs" : null
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "gun" : {
                    "items" : { 
                        "leftArm" : null,
                        "rightArm" : null,
                        "head" : null,
                        "shell" : "ammo_belt",
                        "legs" : null
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                }

            },

        "2": {
                "speed" : {
                    "items" : { 
                        "leftArm" : null,
                        "rightArm" : null,
                        "head" : "propreller",
                        "shell" : null,
                        "legs" : "rollerskates"
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "tank" : {
                    "items" : { 
                        "leftArm" : "bear_trap",
                        "rightArm" : "fissile_cannon",
                        "head" : null,
                        "shell" : null,
                        "legs" : null,
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "gun" : {
                    "items" : { 
                        "leftArm" : "fissile_cannon",
                        "rightArm" : null,
                        "head" : null,
                        "shell" : "ammo_belt",
                        "legs" : null
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }
                }
            },
        
        "3": {
                "speed" : {
                    "items" : { 
                        "leftArm" : "machine_gun",
                        "rightArm" : null,
                        "head" : "propreller",
                        "shell" : null,
                        "legs" : "rollerskates"
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "tank" : {
                    "items" : { 
                        "leftArm" : "bear_trap",
                        "rightArm" : "fissile_cannon",
                        "head" : "propreller",
                        "shell" : null,
                        "legs" : null,
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }

                },

                "gun" : {
                    "items" : { 
                        "leftArm" : "fissile_cannon",
                        "rightArm" : null,
                        "head" : "m1_helmet",
                        "shell" : "ammo_belt",
                        "legs" : null
                    },

                    "base_stats" : {
                        "acceleration" : 5.0,
                        "resilience" : 0.1,
                        "max_speed" : 300.0,
                        "fire_rate" : 1.0,
                        "projectile_speed" : 1.0,
                        "luck" : 1.0
                    },

                    "econ" : {
                        "gold" : 0
                    }
                }
            }
        }        
    };
}
