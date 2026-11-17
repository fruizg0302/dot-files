const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const { test } = require("node:test");

const path = `${process.env.HERDR_APP || `${process.env.HOME}/.config/herdr-app`}/mods/company-new-menu/main.js`;
const source = fs.readFileSync(path, "utf8")
  .replace(/^import .*;\n/gm, "")
  .replace("export default class NewMenu", "globalThis.Menu = class NewMenu");
const agent = (key, name, installed = true) => ({
  key, name, icon: "icons/shell.svg", tint: true,
  tile: "#123456", color: "#ffffff", agent: true, run: [key], installed,
});
const all = [
  agent("codex", "Codex"), agent("droid", "Droid"), agent("pi", "Pi"),
  agent("zcode", "ZCode"), agent("claude", "Claude"), agent("opencode", "OpenCode"),
  agent("gemini", "Gemini", false),
];

function setup(cached = all, refreshed = all) {
  let keydown;
  const launches = [], rows = [], tasks = [];
  const state = {};
  const element = () => {
    let node;
    node = new Proxy({}, {
      get(_target, name) {
        if (name === "when") return (condition, callback) => condition ? callback(node) : node;
        if (name === "on_key_down") return (callback) => { keydown = callback; return node; };
        return () => node;
      },
    });
    return node;
  };
  const context = {
    View: class {}, div: element, svg: element, image: element, h_flex: element, v_flex: element,
    theme: () => ({}), keys: () => [], window: () => ({ platform: "linux" }),
    spaces: () => [{ id: "local-space", active: true, machine: null }],
    panes: () => [{ focused: true, cwd: "/tmp/repo" }],
    props: () => ({ overlay: "test-menu" }), closeOverlay() {}, openOverlay() {},
    shared: (key) => state[key] ?? { "": cached },
    setShared: (key, value) => { state[key] = value; },
    knownAgents: async () => refreshed,
    run: (command, args) => launches.push(JSON.parse(JSON.stringify({ command, args }))),
  };
  vm.runInNewContext(source, context);
  const menu = new context.Menu();
  const cx = {
    focus_handle: () => ({ focus() {} }),
    spawn: (callback) => { tasks.push(callback(cx)); },
    notify() {},
  };
  menu.init({}, cx);
  menu.row = (id, _icon, name, action, hint, enabled = true) => {
    rows.push({ id, name, action, hint, enabled });
    return element();
  };
  return {
    render() { rows.length = 0; menu.render(); return rows; },
    press(key) { keydown({ key, modifiers: {} }); },
    launches, tasks,
  };
}

test("cached and refreshed menus show only the three requested agents in order", async () => {
  const app = setup();
  const expected = ["terminal", "claude", "zcode", "droid", "space", "worktree", "worktree-open"];
  assert.deepEqual(app.render().map((row) => row.id), expected);
  await Promise.all(app.tasks);
  assert.deepEqual(app.render().map((row) => row.id), expected);
});

test("number shortcuts match Claude, ZCode, and Droid and cannot start hidden agents", () => {
  const app = setup();
  app.render();
  for (const key of ["1", "2", "3", "4"]) app.press(key);
  assert.deepEqual(app.launches, [
    { command: "tab.new", args: { name: "Claude", space: "local-space", argv: ["claude"] } },
    { command: "tab.new", args: { name: "ZCode", space: "local-space", argv: ["zcode"] } },
    { command: "tab.new", args: { name: "Droid", space: "local-space", argv: ["droid"] } },
  ]);
});

test("clicking each agent row starts its matching command", () => {
  const app = setup();
  const rows = app.render();
  for (const key of ["claude", "zcode", "droid"]) rows.find((row) => row.id === key).action();
  assert.deepEqual(app.launches.map((launch) => launch.args.argv), [["claude"], ["zcode"], ["droid"]]);
});

test("unavailable agents and unrelated installation suggestions stay out of the menu", () => {
  const app = setup([agent("droid", "Droid"), agent("claude", "Claude", false), agent("codex", "Codex")]);
  assert.deepEqual(app.render().map((row) => row.id), ["terminal", "droid", "space", "worktree", "worktree-open"]);
});
