const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const { test } = require("node:test");

const root = process.env.HERDR_APP || `${process.env.HOME}/.config/herdr-app`;
const source = fs.readFileSync(`${root}/mods/company-agents/main.js`, "utf8");
const start = source.indexOf(".when(!collapsed && this.hiring.open,");
const end = source.indexOf("\n      .when(!collapsed,", start);
const block = source.slice(start, end);

function picker() {
  const nodes = [];
  const element = () => {
    const data = { children: [] };
    const node = new Proxy(data, {
      get(target, name) {
        if (name === "child") return (value) => { target.children.push(value); return node; };
        if (name === "children") return (values) => { target.children.push(...values); return node; };
        if (name === "id") return (id) => { target.id = id; nodes.push(target); return node; };
        if (name === "on_click") return (fn) => { target.click = fn; return node; };
        if (name === "when") return (condition, fn) => condition ? fn(node) : node;
        return () => node;
      },
    });
    return node;
  };
  const state = { hiring: { open: true, program: "claude", error: "" } };
  vm.runInNewContext(`(function() { capture${block}; }).call(state)`, {
    state, collapsed: false, capture: { when: (_condition, render) => render(element()) },
    div: element, h_flex: element, v_flex: element,
    Input: { new: element }, frame: () => [], mono: "monospace",
    t: { foreground: "#ffffff" },
  });
  return { nodes: nodes.filter((node) => /^hire-(claude|zcode|droid|codex|opencode|agy)$/.test(node.id)), state };
}

test("Hire offers Claude, ZCode, and Droid and selects their launch commands", async () => {
  const { nodes, state } = picker();
  assert.deepEqual(nodes.map((node) => node.children[0]), ["Claude", "ZCode", "Droid"]);
  const methodStart = source.indexOf("  async doHire(cx) {");
  const methodEnd = source.indexOf("\n  runUpdate()", methodStart);
  const launches = [];
  const doHire = vm.runInNewContext(`({${source.slice(methodStart, methodEnd)}}).doHire`, {
    hire: async () => ({ path: "/tmp/worktree", branch: "TEST-123" }),
    exec: () => { throw new Error("Unexpected external command"); },
    run: (command, args) => launches.push(JSON.parse(JSON.stringify({ command, args }))),
    spaces: () => [{ id: "test-space", active: true }],
  });
  Object.assign(state, {
    ticketInput: { value: () => "TEST-123", set_value() {} },
    repoInput: { value: () => "/tmp/repo" },
  });
  for (const node of nodes) {
    state.hiring.open = true;
    node.click({}, { notify() {} });
    await doHire.call(state, { notify() {} });
    assert.equal(state.hiring.error, "");
  }
  assert.deepEqual(launches, ["claude", "zcode", "droid"].map((program) => ({
    command: "tab.new",
    args: { name: "TEST-123", folder: "/tmp/worktree", argv: [program], space: "test-space" },
  })));
});

test("all requested agents are registered with matching launch commands", () => {
  const { programs } = JSON.parse(fs.readFileSync(`${root}/programs.json`, "utf8"));
  for (const [key, name] of [["claude", "Claude"], ["zcode", "ZCode"], ["droid", "Droid"]]) {
    assert.deepEqual(programs[key]?.run, [key], `${name} launch command`);
    assert.equal(programs[key]?.name, name);
  }
});
