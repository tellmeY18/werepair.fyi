// Real HTTP smoke check, including cookies and CSRF. Run against the seeded local server.
import assert from "node:assert/strict";

const base = process.env.BASE_URL || "http://localhost:4000";
let cookie = "";
async function page(path) {
  const response = await fetch(base + path, {headers: {cookie}, redirect: "manual"});
  const setCookie = response.headers.getSetCookie();
  if (setCookie.length) cookie = setCookie.map(value => value.split(";")[0]).join("; ");
  assert.equal(response.status, 200, path);
  return response.text();
}
for (const path of ["/", "/technicians", "/requests", "/events", "/costs", "/learn", "/about", "/requests/1", "/requests/8", "/events/1", "/events/2", "/people/3", "/people/4"])
  await page(path);

for (const [email, paths] of [
  ["asha@example.test", ["/profile", "/requests/new", "/requests/1/journal", "/requests/8"]],
  ["ravi@example.test", ["/profile", "/events/1"]],
  ["admin@example.test", ["/admin", "/events/new", "/events/1"]]
]) {
  cookie = "";
  const html = await page("/sign-in");
  const token = html.match(/name="_csrf_token"[^>]*value="([^"]+)"/)?.[1];
  assert.ok(token, "CSRF field");
  const response = await fetch(base + "/sign-in", {
    method: "POST", redirect: "manual", headers: {cookie},
    body: new URLSearchParams({_csrf_token: token, "session[email]": email, "session[password]": "RepairDemo2026!"})
  });
  assert.equal(response.status, 302, `login ${email}`);
  cookie = response.headers.getSetCookie().map(value => value.split(";")[0]).join("; ");
  for (const path of paths) await page(path);
}
console.log("HTTP smoke passed: public pages, seeded details, CSRF logins and all three demo workflows.");
