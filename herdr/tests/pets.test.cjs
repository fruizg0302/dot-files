const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const { test } = require("node:test");
const root = `${process.env.HERDR_APP || `${process.env.HOME}/.config/herdr-app`}/mods/company-agents`;

class Element {
  constructor() { this.paint = {}; this.nodes = []; this.animations = []; }
  absolute() { return this; }
  relative() { return this; }
  flex_none() { return this; }
  left(value) { this.paint.x = value; return this; }
  top(value) { this.paint.y = value; return this; }
  w(value) { this.paint.width = value; return this; }
  h(value) { this.paint.height = value; return this; }
  bg(value) { this.paint.fill = value; return this; }
  child(value) { if (value) this.nodes.push(value); return this; }
  children(values) { this.nodes.push(...values); return this; }
  when(condition, callback) { return condition ? callback(this) : this; }
  loop(property, options) { this.animations.push({ property, options }); return this; }
}

function load(path) {
  const context = { div: () => new Element() };
  const source = fs.readFileSync(path, "utf8").replace(/^import .*;\n/gm, "")
    .replace(/^export /gm, "");
  vm.runInNewContext(`${source}\nglobalThis.api = { speciesOf, duckMood, MOODS };`, context);
  return context.api;
}
function flatten(node) { return [node, ...node.nodes.flatMap(flatten)]; }
const pets = load(`${root}/duck.js`);
const original = load(process.env.HERDR_ORIGINAL_PETS);
const moods = ["stab", "angry", "scowl", "happy", "content", "snooze", "urge"];
const json = (value) => JSON.parse(JSON.stringify(value));

test("Droid and ZCode receive distinct robot and fox artwork rather than fallback sheep", () => {
  for (const [key, species, colors] of [
    ["Droid", "droid", ["#ff7817", "#00d9df"]],
    ["ZCode", "fox", ["#0878f5", "#fff0d0", "#a44bf0"]],
  ]) {
    assert.equal(pets.speciesOf(key), species);
    const painted = flatten(pets.duckMood("content", 45, { species, still: true }));
    for (const color of colors) assert.ok(painted.some((node) => node.paint.fill === color), `${key}: ${color}`);
    assert.notDeepEqual(json(painted), json(flatten(pets.duckMood("content", 45, { species: "sheep", still: true }))));
  }
});

test("every pet state renders and keeps native animation and still-mode behavior at real sizes", () => {
  for (const species of ["droid", "fox"]) {
    const states = [];
    for (const height of [26, 34, 45]) {
      for (const mood of moods) {
        const animated = pets.duckMood(mood, height, { species });
        const still = pets.duckMood(mood, height, { species, still: true });
        assert.equal(still.paint.height, height);
        assert.equal(still.paint.width, height * 368 / 240);
        assert.ok(flatten(animated).some((node) => node.animations.length));
        assert.ok(flatten(still).every((node) => node.animations.length === 0));
        for (const node of flatten(still)) {
          for (const [key, value] of Object.entries(node.paint)) {
            if (key !== "fill") assert.ok(Number.isFinite(value), `${species}/${mood}/${key}`);
          }
        }
        if (height === 45) states.push(JSON.stringify(still));
      }
    }
    assert.equal(new Set(states).size, 7, `${species} has seven distinct states`);
  }
});

test("existing Claude and other pets remain visually identical in every state", () => {
  for (const species of ["crab", "bot", "penguin", "arch", "sheep"]) {
    for (const mood of moods) {
      assert.deepEqual(json(pets.duckMood(mood, 45, { species })), json(original.duckMood(mood, 45, { species })));
    }
  }
});

test("agent identity resolves Droid and ZCode from existing process inputs", () => {
  const text = fs.readFileSync(`${root}/main.js`, "utf8");
  const definition = text.match(/const progOf = \(a\) => \{[\s\S]*?\n\};/)[0];
  const context = {};
  vm.runInNewContext(`${definition}\nglobalThis.identify = progOf;`, context);
  for (const [input, expected] of [
    [{ program: { key: "droid" } }, "droid"],
    [{ program: { key: "zcode" } }, "zcode"],
    [{ program: { key: "program" }, foreground: { name: "node", argv: ["node", "/tmp/zcode.cjs"] } }, "zcode"],
    [{ program: { key: "shell" }, argv: ["/example/.local/bin/droid"] }, "droid"],
  ]) assert.equal(context.identify(input), expected);
});
