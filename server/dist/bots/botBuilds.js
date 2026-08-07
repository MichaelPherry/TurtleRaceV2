"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.botBuilds = exports.bot_list = void 0;
const colyseus_1 = require("colyseus");
exports.bot_list = ["speed", "tank", "gun"];
class botBuilds extends colyseus_1.Room {
    constructor() {
        super();
        this.turtles = {};
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
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": null,
                        "shell": null,
                        "legs": "cinderblocks"
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
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
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                }
            },
            "2": {
                "speed": {
                    "items": {
                        "leftArm": null,
                        "rightArm": null,
                        "head": "bunny_ears",
                        "shell": null,
                        "legs": "rollerskates"
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": "bear_trap",
                        "rightArm": null,
                        "head": null,
                        "shell": null,
                        "legs": "cinderblocks"
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                },
                "gun": {
                    "items": {
                        "leftArm": "fissile",
                        "rightArm": null,
                        "head": null,
                        "shell": "ammo_belt",
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                }
            },
            "3": {
                "speed": {
                    "items": {
                        "leftArm": "machine_gun",
                        "rightArm": null,
                        "head": "bunny_ears",
                        "shell": null,
                        "legs": "rollerskates"
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                },
                "tank": {
                    "items": {
                        "leftArm": "bear_trap",
                        "rightArm": null,
                        "head": "propreller",
                        "shell": null,
                        "legs": "cinderblocks"
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                },
                "gun": {
                    "items": {
                        "leftArm": "fissile",
                        "rightArm": null,
                        "head": "m1_helmet",
                        "shell": "ammo_belt",
                        "legs": null
                    },
                    "base_stats": {
                        "acceleration": 5.0,
                        "resilience": 0.1,
                        "max_speed": 300.0,
                        "fire_rate": 1.0,
                        "projectile_speed": 1.0,
                        "luck": 1.0
                    },
                    "econ": {
                        "gold": 0
                    }
                }
            }
        };
    }
    ;
}
exports.botBuilds = botBuilds;
//# sourceMappingURL=botBuilds.js.map