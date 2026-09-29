"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.botBuilds = exports.bot_list = void 0;
const colyseus_1 = require("colyseus");
exports.bot_list = ["speed", "tank", "gun"];
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