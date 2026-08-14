const fs = require("fs");
const { execSync } = require("child_process");

const bundlePath = "dist/server-bundle.cjs";
const blobPath = "sea-prep.blob";
const exePath = "server.exe";

const SEA_FUSE = "NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2";

function run(command) {
    console.log(`\n> ${command}\n`);

    execSync(command, {
        stdio: "inherit",
        shell: true
    });
}

try {
    // --------------------------------------------------
    // 1. Compile TypeScript
    // --------------------------------------------------

    console.log("\n=== Building TypeScript ===");

    run("npm run build");


    // --------------------------------------------------
    // 2. Bundle server
    // --------------------------------------------------

    console.log("\n=== Bundling server ===");

    run(
        `npx esbuild dist/index.js --bundle --platform=node --format=cjs --outfile=dist/server-bundle.cjs --alias:@colyseus/bun-websockets=./empty-module.js --alias:@colyseus/redis-driver=./empty-module.js --alias:@colyseus/redis-presence=./empty-module.js`
    );


    // --------------------------------------------------
    // 3. Remove optional Colyseus dependencies
    // --------------------------------------------------

    console.log("\n=== Removing optional Colyseus dependencies ===");

    let bundle = fs.readFileSync(bundlePath, "utf8");

    // Redis driver
    bundle = bundle.replace(
        /\(0, import_core\.dynamicImport\)\("@colyseus\/redis-driver"\)/g,
        "(() => Promise.resolve({}))"
    );

    // Redis presence
    bundle = bundle.replace(
        /\(0, import_core\.dynamicImport\)\("@colyseus\/redis-presence"\)/g,
        "(() => Promise.resolve({}))"
    );

    // Bun WebSockets
    bundle = bundle.replace(
        /\(0, import_core\.dynamicImport\)\("@colyseus\/bun-websockets"\)/g,
        "(() => Promise.resolve({}))"
    );

    // Remove Redis re-exports
    bundle = bundle.replace(
        /__reExport\(index_exports, require\("@colyseus\/redis-presence"\), module2\.exports\);\s*/g,
        ""
    );

    bundle = bundle.replace(
        /__reExport\(index_exports, require\("@colyseus\/redis-driver"\), module2\.exports\);\s*/g,
        ""
    );

    fs.writeFileSync(bundlePath, bundle);

    console.log("Bundle fixes applied.");


    // --------------------------------------------------
    // 4. Create SEA blob
    // --------------------------------------------------

    console.log("\n=== Creating SEA blob ===");

    run("node --experimental-sea-config sea-config.json");


    // --------------------------------------------------
    // 5. Get Node executable
    // --------------------------------------------------

    console.log("\n=== Preparing server.exe ===");

    const nodePath = process.execPath;

    console.log(`Using Node: ${nodePath}`);

    if (fs.existsSync(exePath)) {
        fs.unlinkSync(exePath);
    }

    fs.copyFileSync(nodePath, exePath);


    // --------------------------------------------------
    // 6. Inject SEA blob
    // --------------------------------------------------

    console.log("\n=== Injecting SEA blob ===");

    run(
        `npx postject "${exePath}" NODE_SEA_BLOB "${blobPath}" --sentinel-fuse ${SEA_FUSE}`
    );


    // --------------------------------------------------
    // DONE
    // --------------------------------------------------

    console.log("\n========================================");
    console.log(" BUILD SUCCESSFUL!");
    console.log("========================================");
    console.log(`Created: ${exePath}`);
    console.log("");

} catch (error) {

    console.error("\n========================================");
    console.error(" BUILD FAILED");
    console.error("========================================");

    process.exit(1);
}