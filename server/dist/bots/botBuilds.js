"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.botBuilds = exports.bossBuilds = exports.bot_list = void 0;
const colyseus_1 = require("colyseus");
exports.bot_list = ["speed", "tank", "gun"];
class bossBuilds extends colyseus_1.Room {
    constructor() {
        super();
        this.bosses = {};
        this.rabbit_acceleration = 10;
        this.rabbit_resilience = 0;
        this.rabbit_max_speed = 750;
        this.rabbit_fire_rate = 1;
        this.rabbit_projectile_speed = 1;
        this.rabbit_luck = 2;
        this.bosses = {
            "Rabbit": {
                "build": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": "bunny_ears",
                        "shell": null,
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": this.rabbit_acceleration,
                        "resilience": this.rabbit_resilience,
                        "max_speed": this.rabbit_max_speed,
                        "fire_rate": this.rabbit_fire_rate,
                        "projectile_speed": this.rabbit_projectile_speed,
                        "luck": this.rabbit_luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                }
            }
        };
    }
}
exports.bossBuilds = bossBuilds;
class botBuilds extends colyseus_1.Room {
    constructor() {
        super();
        this.turtles = {};
        this.acceleration = 5;
        this.resilience = 0;
        this.max_speed = 500;
        this.fire_rate = 1;
        this.projectile_speed = 1;
        this.luck = 1;
        this.turtles = {
            "1": {
                "speed": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": null,
                        "shell": null,
                        "legs": "rollerskates"
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": null,
                        "rightArm": "fissile_cannon",
                        "head": null,
                        "shell": null,
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "gun": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": null,
                        "shell": "ammo_belt",
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                }
            },
            "2": {
                "speed": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": "propreller",
                        "shell": null,
                        "legs": "rollerskates"
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": "bear_trap",
                        "rightArm": "fissile_cannon",
                        "head": null,
                        "shell": null,
                        "legs": null,
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "gun": {
                    "items": {
                        "leftArm": "fissile_cannon",
                        "rightArm": null,
                        "head": null,
                        "shell": "ammo_belt",
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                }
            },
            "3": {
                "speed": {
                    "items": {
                        "leftArm": "machine_gun",
                        "rightArm": null,
                        "head": "propreller",
                        "shell": null,
                        "legs": "rollerskates"
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": "bear_trap",
                        "rightArm": "fissile_cannon",
                        "head": "propreller",
                        "shell": null,
                        "legs": null,
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                },
                "gun": {
                    "items": {
                        "leftArm": "fissile_cannon",
                        "rightArm": null,
                        "head": "m1_helmet",
                        "shell": "ammo_belt",
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": this.acceleration,
                        "resilience": this.resilience,
                        "max_speed": this.max_speed,
                        "fire_rate": this.fire_rate,
                        "projectile_speed": this.projectile_speed,
                        "luck": this.luck
                    },
                    "econ": {
                        "gold": 0
                    },
                    "results": {
                        "first": 0,
                        "second": 0,
                        "third": 0,
                        "fourth": 0
                    }
                }
            }
        };
    }
    ;
}
exports.botBuilds = botBuilds;
//# sourceMappingURL=botBuilds.js.map