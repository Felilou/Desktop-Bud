# Autoupdate-Plan (Velopack)

Status: **nur Planung, noch nicht umgesetzt.** `links.md` notiert [Velopack](https://velopack.io/)
als angedachten Weg für Auto-Updates aus GitHub Releases. Dieses Dokument hält fest, warum das für
`desktop-bud` nicht trivial ist und welche Bausteine für eine spätere Umsetzung fehlen.

## Warum das hier nicht "einfach nur eine Lib einbinden" ist

`desktop-bud` ist ein reines GDScript-Projekt (`project.godot` → `config/features` listet nur
`"4.7", "GL Compatibility"`, kein Mono/C#-Feature). Velopack ist primär eine **.NET-Bibliothek**:
der In-App-Update-Check (`UpdateManager` API) läuft als .NET-Code. GDScript kann keine .NET-Assemblies
direkt referenzieren — Godot bräuchte dafür die Mono/C#-Variante des Editors bzw. Exports.

Damit gibt es zwei grundsätzlich verschiedene Richtungen:

### Option A: Godot-Mono/C# aktivieren, Velopack als In-App-Update-Check
- Export-Presets auf die .NET/Mono-Build von Godot 4.7 umstellen.
- Einen kleinen C#-Bootstrap-Node schreiben, der beim Start `Velopack.UpdateManager` aufruft (auf
  neue Version prüfen, herunterladen, `ApplyUpdatesAndRestart()`), und diesen Node parallel zur
  bestehenden GDScript-Logik in `Scenes/global.tscn` einhängen.
- Vorteil: "richtiger" In-App-Update-Check mit Delta-Updates, Rollback etc., wie von Velopack gedacht.
- Nachteil: Umstieg auf Mono betrifft den ganzen Build-/Export-Prozess, nicht nur ein Feature; größerer
  Eingriff in die Toolchain als die drei next_steps.md-Punkte.

### Option B: Velopack nur als Packaging-/Installer-Schicht, Update-Check selbstgebaut
- Velopack (`vpk pack`) nur benutzen, um die von Godot exportierte `.exe` in ein installierbares,
  update-fähiges Paket zu verpacken (das geht rein CLI-seitig, ohne dass das Spiel selbst .NET-Code
  enthält).
- Update-*Check* in-App selbst bauen: `HTTPRequest` gegen die GitHub-Releases-API
  (`GET /repos/Felilou/Desktop-Bud/releases/latest`), Versionsstring vergleichen.
- Bei neuer Version: entweder nur einen Hinweis anzeigen ("Update verfügbar, bitte neu installieren"),
  oder ein separates kleines Updater-Binary starten, das Velopack von außen aufruft.
- Vorteil: kein Mono-Umstieg nötig, bleibt reines GDScript.
- Nachteil: kein "nahtloses" In-App-Update wie bei Option A, mehr Marschall-Logik selbst zu bauen.

**Offene Entscheidung für später:** Mono/C#-Route (A) vs. reiner GDScript-Selbstbau-Updater (B). Das
ist bewusst nicht vorentschieden — hängt davon ab, wie wichtig nahtlose Delta-Updates sind gegenüber
dem Aufwand, den Mono-Umstieg für den Rest des Projekts zu verkraften.

## Was davor noch fehlt (unabhängig von A/B)

- **Versionierung**: `project.godot` hat aktuell kein `config/version`. Müsste ergänzt werden, damit
  es überhaupt einen Versionsstring gibt, den ein Update-Check vergleichen kann.
- **Export-Preset**: Es gibt aktuell keine `export_presets.cfg` im Repo (steht auch explizit im
  `.gitignore`) — ein Windows-Export-Preset muss erst eingerichtet werden, bevor überhaupt ein
  releasefähiges Binary gebaut werden kann.
- **CI/Release-Pipeline (grober Entwurf)**:
  1. GitHub-Actions-Job: Godot 4.7 headless exportieren (`godot --headless --export-release "Windows Desktop" ...`).
  2. `vpk pack` auf das exportierte Verzeichnis anwenden → erzeugt Velopack-Release-Artefakte.
  3. Artefakte + `RELEASES`-Datei an ein GitHub Release anhängen (per `gh release upload` oder
     Velopack's eigenem GitHub-Push-Support).
- **Signierung/Codesigning**: für ein sauberes Auto-Update unter Windows i.d.R. relevant (SmartScreen-
  Warnungen), hier noch komplett offen und nicht weiter ausgearbeitet.

## Nächster konkreter Schritt, wenn's losgeht

1. Entscheidung A vs. B treffen (siehe oben).
2. `config/version` in `project.godot` ergänzen.
3. Windows-Export-Preset anlegen und einmal manuell exportieren, um zu sehen was Velopack als Input
   bekommt.
4. Erst danach den eigentlichen Update-Mechanismus (Mono-Bootstrap oder HTTPRequest-Check) bauen.
